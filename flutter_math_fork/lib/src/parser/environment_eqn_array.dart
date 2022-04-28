// The MIT License (MIT)
//
// Copyright (c) 2013-2019 Khan Academy and other contributors
// Copyright (c) 2020 znjameswu <znjameswu@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import '../ast/ast.dart';
import '../ast/ast_impl.dart';
import '../ast/ast_plus.dart';
import '../utils/extensions.dart';
import 'define_environment.dart';
import 'environment_array.dart';
import 'macro_expander.dart';
import 'parser.dart';

const eqnArrayEntries = {
  [
    'cases',
    'dcases',
    'rcases',
    'drcases',
  ]: EnvSpec(
    numArgs: 0,
    handler: _casesHandler,
  ),
  ['aligned']: EnvSpec(
    numArgs: 0,
    handler: _alignedHandler,
  ),
  // ['gathered']: EnvSpec(numArgs: 0, handler: _gatheredHandler),
  ['alignedat']: EnvSpec(numArgs: 1, handler: _alignedAtHandler),
};

TexGreen _casesHandler(
  final TexParser parser,
  final EnvContext context,
) {
  final body = parseEqnArray(
    parser,
    concatRow: (final cells) {
      final children = [
        TexGreenSpaceImpl.alignerOrSpacer(),
        if (cells.isNotEmpty) ...cells[0].children,
        if (cells.length > 1) TexGreenSpaceImpl.alignerOrSpacer(),
        if (cells.length > 1)
          TexGreenSpaceImpl(
            height: zeroPt,
            width: em(1.0),
            mode: TexMode.math,
          ),
      ];
      for (var i = 1; i < cells.length; i++) {
        children.add(TexGreenSpaceImpl.alignerOrSpacer());
        children.addAll(cells[i].children);
        children.add(TexGreenSpaceImpl.alignerOrSpacer());
      }
      if (context.envName == 'dcases' || context.envName == 'drcases') {
        return TexGreenEquationrowImpl(
          children: [
            TexGreenStyleImpl(
              optionsDiff: const TexOptionsDiffImpl(
                style: TexMathStyle.display,
              ),
              children: children,
            )
          ],
        );
      } else {
        return TexGreenEquationrowImpl(
          children: children,
        );
      }
    },
  );
  if (context.envName == 'rcases' || context.envName == 'drcases') {
    return TexGreenLeftrightImpl(
      leftDelim: null,
      rightDelim: '}',
      body: [
        greenNodeWrapWithEquationRow(
          body,
        ),
      ],
    );
  } else {
    return TexGreenLeftrightImpl(
      leftDelim: '{',
      rightDelim: null,
      body: [
        greenNodeWrapWithEquationRow(
          body,
        ),
      ],
    );
  }
}

TexGreen _alignedHandler(
  final TexParser parser,
  final EnvContext context,
) =>
    parseEqnArray(
      parser,
      addJot: true,
      concatRow: (final cells) {
        final expanded = cells
            .expand(
              (final cell) => [
                ...cell.children,
                TexGreenSpaceImpl.alignerOrSpacer(),
              ],
            )
            .toList(
              growable: true,
            );
        return TexGreenEquationrowImpl(
          children: expanded,
        );
      },
    );

// GreenNode _gatheredHandler(TexParser parser, EnvContext context) {}

TexGreen _alignedAtHandler(
  final TexParser parser,
  final EnvContext context,
) {
  final arg = parser.parseArgNode(mode: null, optional: false);
  final numNode = assertNodeType<TexGreenEquationrow>(arg);
  final string = numNode.children.map((final e) => assertNodeType<TexGreenSymbol>(e).symbol).join('');
  final cols = int.tryParse(string);
  if (cols == null) {
    throw ParseException('Invalid argument for environment: alignedat');
  } else {
    return parseEqnArray(
      parser,
      addJot: true,
      concatRow: (final cells) {
        if (cells.length > 2 * cols) {
          throw ParseException('Too many math in a row: '
              'expected ${2 * cols}, but got ${cells.length}');
        }
        final expanded = cells
            .expand(
              (final cell) => [
                ...cell.children,
                TexGreenSpaceImpl.alignerOrSpacer(),
              ],
            )
            .toList(growable: true);
        return TexGreenEquationrowImpl(
          children: expanded,
        );
      },
    );
  }
}

TexGreenEquationarray parseEqnArray(
  final TexParser parser, {
  required final TexGreenEquationrow Function(List<TexGreenEquationrow> cells) concatRow,
  final bool addJot = false,
}) {
  // Parse body of array with \\ temporarily mapped to \cr
  parser.macroExpander.beginGroup();
  parser.macroExpander.macros.set('\\\\', MacroDefinition.fromString('\\cr'));
  // Get current arraystretch if it's not set by the environment
  double? arrayStretch = 1.0;
  // if (arrayStretch == null) {
  final stretch = parser.macroExpander.expandMacroAsText('\\arraystretch');
  if (stretch == null) {
    // Default \arraystretch from lttab.dtx
    arrayStretch = 1.0;
  } else {
    arrayStretch = double.tryParse(stretch);
    if (arrayStretch == null || arrayStretch < 0) {
      throw ParseException('Invalid \\arraystretch: $stretch');
    }
  }
  // }
  // Start group for first cell
  parser.macroExpander.beginGroup();
  var row = <TexGreenEquationrow>[];
  final body = [row];
  final rowGaps = <TexMeasurement>[];
  final hLinesBeforeRow = <TexMatrixSeparatorStyle>[];
  // Test for \hline at the top of the array.
  hLinesBeforeRow.add(getHLines(parser).lastOrNull ?? TexMatrixSeparatorStyle.none);
  for (;;) {
    // Parse each cell in its own group (namespace)
    final cellBody = parser.parseExpression(
      breakOnInfix: false,
      breakOnTokenText: '\\cr',
    );
    parser.macroExpander.endGroup();
    parser.macroExpander.beginGroup();
    final cell = greenNodesWrapWithEquationRow(
      cellBody,
    );
    row.add(cell);
    final next = parser.fetch().text;
    if (next == '&') {
      parser.consume();
    } else if (next == '\\end') {
      // Arrays terminate newlines with `\crcr` which consumes a `\cr` if
      // the last line is empty.
      // NOTE: Currently, `cell` is the last item added into `row`.
      if (row.length == 1 && cell is TexGreenStyle && cell.children.isEmpty) {
        body.removeLast();
      }
      if (hLinesBeforeRow.length < body.length + 1) {
        hLinesBeforeRow.add(TexMatrixSeparatorStyle.none);
      }
      break;
    } else if (next == '\\cr') {
      final cr = assertNodeType<TexGreenTemporaryCr>(parser.parseFunction(null, null, null));
      rowGaps.add(cr.size ?? zeroPt);
      // check for \hline(s) following the row separator
      hLinesBeforeRow.add(getHLines(parser).lastOrNull ?? TexMatrixSeparatorStyle.none);
      row = [];
      body.add(row);
    } else {
      throw ParseException('Expected & or \\\\ or \\cr or \\end', parser.nextToken);
    }
  }
  // End cell group
  parser.macroExpander.endGroup();
  // End array group defining \\
  parser.macroExpander.endGroup();
  final rows = body.map<TexGreenEquationrow>(concatRow).toList();
  return TexGreenEquationarrayImpl(
    arrayStretch: arrayStretch,
    hlines: hLinesBeforeRow,
    rowSpacings: rowGaps,
    addJot: addJot,
    body: rows,
  );
}