import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../render/constants.dart';
import '../render/layout.dart';
import '../render/svg.dart';
import '../render/symbol.dart';
import '../render/util.dart';
import '../utils/extensions.dart';
import 'ast.dart';
import 'ast_impl.dart';
import 'symbols.dart';

TexGreenEquationrow emptyEquationRowNode() {
  return TexGreenEquationrowImpl(children: []);
}

TexGreenMatrixImpl matrixNodeSanitizedInputs({
  required final List<List<TexGreenEquationrow?>> body,
  final double arrayStretch = 1.0,
  final bool hskipBeforeAndAfter = false,
  final bool isSmall = false,
  final List<TexMatrixColumnAlign> columnAligns = const [],
  final List<TexMatrixSeparatorStyle> vLines = const [],
  final List<TexMeasurement> rowSpacings = const [],
  final List<TexMatrixSeparatorStyle> hLines = const [],
}) {
  final cols = max3(
    body.map((final row) => row.length).maxOrNull ?? 0,
    columnAligns.length,
    vLines.length - 1,
  );
  final sanitizedColumnAligns = columnAligns.extendToByFill(cols, TexMatrixColumnAlign.center);
  final sanitizedVLines = vLines.extendToByFill(cols + 1, TexMatrixSeparatorStyle.none);
  final rows = max3(
    body.length,
    rowSpacings.length,
    hLines.length - 1,
  );
  final sanitizedBody = body
      .map((final row) => row.extendToByFill(cols, null))
      .toList(growable: false)
      .extendToByFill(rows, List.filled(cols, null));
  final sanitizedRowSpacing = rowSpacings.extendToByFill(rows, zeroPt);
  final sanitizedHLines = hLines.extendToByFill(rows + 1, TexMatrixSeparatorStyle.none);
  return TexGreenMatrixImpl(
    rows: rows,
    cols: cols,
    arrayStretch: arrayStretch,
    hskipBeforeAndAfter: hskipBeforeAndAfter,
    isSmall: isSmall,
    columnAligns: sanitizedColumnAligns,
    vLines: sanitizedVLines,
    rowSpacings: sanitizedRowSpacing,
    hLines: sanitizedHLines,
    body: sanitizedBody,
  );
}

/// Wrap a node in [TexGreenEquationrow]
///
/// If this node is already [TexGreenEquationrow], then it won't be wrapped
TexGreenEquationrowImpl greenNodeWrapWithEquationRow(
  final TexGreen node,
) {
  if (node is TexGreenEquationrowImpl) {
    return node;
  } else {
    return TexGreenEquationrowImpl(
      children: [node],
    );
  }
}

TexGreenEquationrow? greenNodeWrapWithEquationRowOrNull(
  final TexGreen? node,
) {
  if (node == null) {
    return null;
  } else {
    return greenNodeWrapWithEquationRow(
      node,
    );
  }
}

/// If this node is [TexGreenEquationrow], its children will be returned. If not,
/// itself will be returned in a list.
List<TexGreen> greenNodeExpandEquationRow(
  final TexGreen node,
) {
  if (node is TexGreenEquationrow) {
    return node.children;
  } else {
    return [node];
  }
}

/// Wrap list of [TexGreen] in an [TexGreenEquationrow]
///
/// If the list only contain one [TexGreenEquationrow], then this note will be
/// returned.
TexGreenEquationrowImpl greenNodesWrapWithEquationRow(
  final List<TexGreen> nodes,
) {
  if (nodes.length == 1) {
    final first = nodes[0];
    if (first is TexGreenEquationrowImpl) {
      return first;
    } else {
      return TexGreenEquationrowImpl(
        children: nodes,
      );
    }
  }
  return TexGreenEquationrowImpl(
    children: nodes,
  );
}

extension DeOOPd on TexGreen {
  List<TexGreen?> get childrenl => match(
        nonleaf: (final a) => a.children,
        leaf: (final a) => const [],
      );

  int get editingWidthl => match(
        nonleaf: (final a) => a.editingWidth,
        leaf: (final a) => 1,
      );
}

extension DeOOPdNonleaf on TexGreenNonleaf {
  int get editingWidth {
    int childrenEditingWidth(
      final TexGreenNonleaf node,
    ) {
      return integerSum(
        node.children.map(
          (final child) {
            if (child == null) {
              return 0;
            } else {
              return texCapturedCursor(child);
            }
          },
        ),
      );
    }

    return matchNonleaf(
      matrix: (final a) => childrenEditingWidth(a) + 1,
      multiscripts: (final a) => childrenEditingWidth(a) + 1,
      naryoperator: (final a) => childrenEditingWidth(a) + 1,
      sqrt: (final a) => childrenEditingWidth(a) + 1,
      stretchyop: (final a) => childrenEditingWidth(a) + 1,
      equationarray: (final a) => childrenEditingWidth(a) + 1,
      over: (final a) => childrenEditingWidth(a) + 1,
      under: (final a) => childrenEditingWidth(a) + 1,
      accent: (final a) => childrenEditingWidth(a) + 1,
      accentunder: (final a) => childrenEditingWidth(a) + 1,
      enclosure: (final a) => childrenEditingWidth(a) + 1,
      frac: (final a) => childrenEditingWidth(a) + 1,
      function: (final a) => childrenEditingWidth(a) + 1,
      leftright: (final a) => childrenEditingWidth(a) + 1,
      raisebox: (final a) => childrenEditingWidth(a) + 1,
      style: (final a) => integerSum(
        a.children.map(
          (final child) => child.editingWidthl,
        ),
      ),
      equationrow: (final a) =>
          integerSum(
            a.children.map(
              (final child) => child.editingWidthl,
            ),
          ) +
          2,
    );
  }
}

class AccentRenderConfig {
  final String? overChar;
  final String? overImageName;
  final String? underImageName;

  const AccentRenderConfig({
    final this.overChar,
    final this.overImageName,
    final this.underImageName,
  });
}

const accentRenderConfigs = {
  '\u005e': AccentRenderConfig(
    // '\u0302'
    overChar: '\u005e', // \hat
    overImageName: 'widehat',
    // alwaysShifty: true,
  ),
  '\u02c7': AccentRenderConfig(
    // '\u030C'
    overChar: '\u02c7', // \check
    overImageName: 'widecheck',
    // alwaysShifty: true,
  ),
  '\u007e': AccentRenderConfig(
    // '\u0303'
    overChar: '\u007e', // \tilde
    overImageName: 'widetilde',
    underImageName: 'utilde',
    // alwaysShifty: true,
  ),
  '\u00b4': AccentRenderConfig(
    // '\u0301'
    overChar: '\u02ca', // \acute
  ),
  '\u0060': AccentRenderConfig(
    // '\u0300'
    overChar: '\u02cb', // \grave
  ),
  '\u02d9': AccentRenderConfig(
    // '\u0307'
    overChar: '\u02d9', // \dot
  ),
  '\u00a8': AccentRenderConfig(
    // '\u0308'
    overChar: '\u00a8', // \ddot
  ),
  // '\u20DB': AccentRenderConfig(
  //   isOverAccent: true,
  //   symbol: '', // \dddot
  //   svgName: '',
  // ),
  '\u00AF': AccentRenderConfig(
    // '\u0304'
    overChar: '\u02c9', // \bar
  ),
  '\u2192': AccentRenderConfig(
    // '\u20D7'
    overChar: '\u20d7', // \vec
    overImageName: 'overrightarrow',
    underImageName: 'underrightarrow',
  ),
  '\u02d8': AccentRenderConfig(
    // '\u0306'
    overChar: '\u02d8', // \breve
  ),
  '\u02da': AccentRenderConfig(
    // '\u030a'
    overChar: '\u02da', // \mathring
  ),
  '\u02dd': AccentRenderConfig(
    // '\u030b'
    overChar: '\u02dd', // \H
  ),
  '\u2190': AccentRenderConfig(
    // '\u20d6'
    overImageName: 'overleftarrow',
    underImageName: 'underleftarrow',
  ),
  '\u2194': AccentRenderConfig(
    // '\u20e1'
    overImageName: 'overleftrightarrow',
    underImageName: 'underleftrightarrow',
  ),

  '\u23de': AccentRenderConfig(
    overImageName: 'overbrace',
  ),

  '\u23df': AccentRenderConfig(
    underImageName: 'underbrace',
  ),

  ...katexCompatibleAccents,
};

const katexCompatibleAccents = {
  '\u21d2': AccentRenderConfig(
    // '\u21d2'
    overImageName: 'Overrightarrow',
  ),
  '\u23e0': AccentRenderConfig(
      // '\u0311'
      overImageName: 'overgroup',
      underImageName: 'undergroup'),
  // '\u': AccentRenderConfig(
  //   overImageName: 'overlinesegment',
  //   underImageName: 'underlinesegment',
  // ),
  '\u21bc': AccentRenderConfig(
    // '\u20d0'
    overImageName: 'overleftharpoon',
  ),
  '\u21c0': AccentRenderConfig(
    // '\u20d1'
    overImageName: 'overrightharpoon',
  ),
};

/// Line breaking results using standard TeX-style line breaking.
///
/// This function will return a list of `SyntaxTree` along with a list
/// of line breaking penalties.
///
/// {@macro flutter_math_fork.widgets.math.tex_break}
BreakResult<TexRedEquationrowImpl> syntaxTreeTexBreak({
  required final TexRedEquationrowImpl tree,
  final int relPenalty = 500,
  final int binOpPenalty = 700,
  final bool enforceNoBreak = true,
}) {
  final eqRowBreakResult = equationRowNodeTexBreak(
    tree: tree.greenValue,
    relPenalty: relPenalty,
    binOpPenalty: binOpPenalty,
    enforceNoBreak: true,
  );
  return BreakResult(
    parts: eqRowBreakResult.parts
        .map(
          (final part) => TexRedEquationrowImpl(
            greenValue: part,
          ),
        )
        .toList(
          growable: false,
        ),
    penalties: eqRowBreakResult.penalties,
  );
}

/// Line breaking results using standard TeX-style line breaking.
///
/// This function will return a list of `EquationRowNode` along with a list
/// of line breaking penalties.
///
/// {@macro flutter_math_fork.widgets.math.tex_break}
BreakResult<TexGreenEquationrowImpl> equationRowNodeTexBreak({
  required final TexGreenEquationrowImpl tree,
  final int relPenalty = 500,
  final int binOpPenalty = 700,
  final bool enforceNoBreak = true,
}) {
  final breakIndices = <int>[];
  final penalties = <int>[];
  for (int i = 0; i < tree.flattenedChildList.length; i++) {
    final child = tree.flattenedChildList[i];
    // Peek ahead to see if the next child is a no-break
    if (i < tree.flattenedChildList.length - 1) {
      final nextChild = tree.flattenedChildList[i + 1];
      if (nextChild is TexGreenSpace && nextChild.breakPenalty != null && nextChild.breakPenalty! >= 10000) {
        if (!enforceNoBreak) {
          // The break point should be moved to the next child, which is a \nobreak.
          continue;
        } else {
          // In enforced mode, we should cancel the break point all together.
          i++;
          continue;
        }
      }
    }
    if (child.rightType == TexAtomType.bin) {
      breakIndices.add(i);
      penalties.add(binOpPenalty);
    } else if (child.rightType == TexAtomType.rel) {
      breakIndices.add(i);
      penalties.add(relPenalty);
    } else if (child is TexGreenSpace && child.breakPenalty != null) {
      breakIndices.add(i);
      penalties.add(child.breakPenalty!);
    }
  }
  final res = <TexGreenEquationrowImpl>[];
  int pos = 1;
  for (var i = 0; i < breakIndices.length; i++) {
    final breakEnd = tree.caretPositions[breakIndices[i] + 1];
    res.add(
      greenNodeWrapWithEquationRow(
        texClipChildrenBetween<TexGreenEquationrowImpl>(
          tree,
          pos,
          breakEnd,
        ),
      ),
    );
    pos = breakEnd;
  }
  if (pos != tree.caretPositions.last) {
    res.add(
      greenNodeWrapWithEquationRow(
        texClipChildrenBetween<TexGreenEquationrowImpl>(
          tree,
          pos,
          tree.caretPositions.last,
        ),
      ),
    );
    penalties.add(10000);
  }
  return BreakResult<TexGreenEquationrowImpl>(
    parts: res,
    penalties: penalties,
  );
}

class BreakResult<T> {
  final List<T> parts;
  final List<int> penalties;

  const BreakResult({
    required final this.parts,
    required final this.penalties,
  });
}

TexMathStyle? parseMathStyle(
  final String string,
) =>
    const {
      'display': TexMathStyle.display,
      'displayCramped': TexMathStyle.displayCramped,
      'text': TexMathStyle.text,
      'textCramped': TexMathStyle.textCramped,
      'script': TexMathStyle.script,
      'scriptCramped': TexMathStyle.scriptCramped,
      'scriptscript': TexMathStyle.scriptscript,
      'scriptscriptCramped': TexMathStyle.scriptscriptCramped,
    }[string];

bool mathStyleIsCramped(
  final TexMathStyle style,
) {
  return style.index.isEven;
}

int mathStyleSize(
  final TexMathStyle style,
) {
  return style.index ~/ 2;
}

// MathStyle get pureStyle => MathStyle.values[(this.index / 2).floor()];

TexMathStyle mathStyleReduce(
  final TexMathStyle style,
  final MathStyleDiff? diff,
) {
  if (diff == null) {
    return style;
  } else {
    return TexMathStyle.values[[
      [4, 5, 4, 5, 6, 7, 6, 7], //sup
      [5, 5, 5, 5, 7, 7, 7, 7], //sub
      [2, 3, 4, 5, 6, 7, 6, 7], //fracNum
      [3, 3, 5, 5, 7, 7, 7, 7], //fracDen
      [1, 1, 3, 3, 5, 5, 7, 7], //cramp
      [0, 1, 2, 3, 2, 3, 2, 3], //text
      [0, 0, 2, 2, 4, 4, 6, 6], //uncramp
    ][diff.index][style.index]];
  }
}

// MathStyle atLeastText() => this.index > MathStyle.textCramped.index ? this : MathStyle.text;

TexMathStyle mathStyleSup(
  final TexMathStyle style,
) =>
    mathStyleReduce(
      style,
      MathStyleDiff.sup,
    );

TexMathStyle mathStyleSub(
  final TexMathStyle style,
) =>
    mathStyleReduce(
      style,
      MathStyleDiff.sub,
    );

TexMathStyle mathStyleFracNum(
  final TexMathStyle style,
) =>
    mathStyleReduce(
      style,
      MathStyleDiff.fracNum,
    );

TexMathStyle mathStyleFracDen(
  final TexMathStyle style,
) =>
    mathStyleReduce(
      style,
      MathStyleDiff.fracDen,
    );

TexMathStyle mathStyleCramp(
  final TexMathStyle style,
) =>
    mathStyleReduce(
      style,
      MathStyleDiff.cramp,
    );

TexMathStyle mathStyleAtLeastText(
  final TexMathStyle style,
) =>
    mathStyleReduce(
      style,
      MathStyleDiff.text,
    );

TexMathStyle mathStyleUncramp(
  final TexMathStyle style,
) =>
    mathStyleReduce(
      style,
      MathStyleDiff.uncramp,
    );

// bool mathStyleIsTight(
//   final MathStyle style,
// ) =>
//     mathStyleSize(style) >= 2;

bool mathStyleGreater(
  final TexMathStyle left,
  final TexMathStyle right,
) =>
    left.index < right.index;

bool mathStyleLess(
  final TexMathStyle left,
  final TexMathStyle right,
) =>
    left.index > right.index;

bool mathStyleGreaterEquals(
  final TexMathStyle left,
  final TexMathStyle right,
) =>
    left.index <= right.index;

bool mathStyleLessEquals(
  final TexMathStyle left,
  final TexMathStyle right,
) =>
    left.index >= right.index;

TexMathStyle integerToMathStyle(
  final int i,
) =>
    TexMathStyle.values[(i * 2).clamp(0, 6)];

/// katex/src/Options.js/sizeStyleMap
TexMathSize mathSizeUnderStyle(
  final TexMathSize size,
  final TexMathStyle style,
) {
  if (mathStyleGreaterEquals(style, TexMathStyle.textCramped)) {
    return size;
  } else {
    final index = [
          [1, 1, 1],
          [2, 1, 1],
          [3, 1, 1],
          [4, 2, 1],
          [5, 2, 1],
          [6, 3, 1],
          [7, 4, 2],
          [8, 6, 3],
          [9, 7, 6],
          [10, 8, 7],
          [11, 10, 9],
        ][size.index][mathStyleSize(style) - 1] -
        1;
    return TexMathSize.values[index];
  }
}

final thinspace = mu(3);
final mediumspace = mu(4);
final thickspace = mu(5);

final Map<TexAtomType, Map<TexAtomType, TexMeasurement>> _spacings = {
  TexAtomType.ord: {
    TexAtomType.op: thinspace,
    TexAtomType.bin: mediumspace,
    TexAtomType.rel: thickspace,
    TexAtomType.inner: thinspace,
  },
  TexAtomType.op: {
    TexAtomType.ord: thinspace,
    TexAtomType.op: thinspace,
    TexAtomType.rel: thickspace,
    TexAtomType.inner: thinspace,
  },
  TexAtomType.bin: {
    TexAtomType.ord: mediumspace,
    TexAtomType.op: mediumspace,
    TexAtomType.open: mediumspace,
    TexAtomType.inner: mediumspace,
  },
  TexAtomType.rel: {
    TexAtomType.ord: thickspace,
    TexAtomType.op: thickspace,
    TexAtomType.open: thickspace,
    TexAtomType.inner: thickspace,
  },
  TexAtomType.open: {},
  TexAtomType.close: {
    TexAtomType.op: thinspace,
    TexAtomType.bin: mediumspace,
    TexAtomType.rel: thickspace,
    TexAtomType.inner: thinspace,
  },
  TexAtomType.punct: {
    TexAtomType.ord: thinspace,
    TexAtomType.op: thinspace,
    TexAtomType.rel: thickspace,
    TexAtomType.open: thinspace,
    TexAtomType.close: thinspace,
    TexAtomType.punct: thinspace,
    TexAtomType.inner: thinspace,
  },
  TexAtomType.inner: {
    TexAtomType.ord: thinspace,
    TexAtomType.op: thinspace,
    TexAtomType.bin: mediumspace,
    TexAtomType.rel: thickspace,
    TexAtomType.open: thinspace,
    TexAtomType.punct: thinspace,
    TexAtomType.inner: thinspace,
  },
  TexAtomType.spacing: {},
};

final Map<TexAtomType, Map<TexAtomType, TexMeasurement>> _tightSpacings = {
  TexAtomType.ord: {
    TexAtomType.op: thinspace,
  },
  TexAtomType.op: {
    TexAtomType.ord: thinspace,
    TexAtomType.op: thinspace,
  },
  TexAtomType.bin: {},
  TexAtomType.rel: {},
  TexAtomType.open: {},
  TexAtomType.close: {
    TexAtomType.op: thinspace,
  },
  TexAtomType.punct: {},
  TexAtomType.inner: {
    TexAtomType.op: thinspace,
  },
  TexAtomType.spacing: {},
};

TexMeasurement getSpacingSize(
  final TexAtomType left,
  final TexAtomType right,
  final TexMathStyle style,
) =>
    (mathStyleLessEquals(style, TexMathStyle.script)
        ? (_tightSpacings[left]?[right])
        : _spacings[left]?[right]) ??
    zeroPt;

class LinePainter extends CustomPainter {
  final double startRelativeX;
  final double startRelativeY;
  final double endRelativeX;
  final double endRelativeY;
  final double lineWidth;
  final Color color;

  const LinePainter({
    required final this.startRelativeX,
    required final this.startRelativeY,
    required final this.endRelativeX,
    required final this.endRelativeY,
    required final this.lineWidth,
    required final this.color,
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    canvas.drawLine(
      Offset(startRelativeX * size.width, startRelativeY * size.height),
      Offset(endRelativeX * size.width, endRelativeY * size.height),
      Paint()
        ..strokeWidth = lineWidth
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(
    final CustomPainter oldDelegate,
  ) =>
      this != oldDelegate;
}

class LayerLinkSelectionTuple {
  final TextSelection selection;
  final LayerLink? start;
  final LayerLink? end;

  const LayerLinkSelectionTuple({
    required final this.selection,
    required final this.start,
    required final this.end,
  });
}

void traverseNonSpaceNodes(
  final List<NodeSpacingConf> childTypeList,
  final void Function(NodeSpacingConf? prev, NodeSpacingConf? curr) callback,
) {
  NodeSpacingConf? prev;
  // Tuple2<AtomType, AtomType> curr;
  for (final child in childTypeList) {
    if (child.leftType == TexAtomType.spacing || child.rightType == TexAtomType.spacing) {
      continue;
    }
    callback(prev, child);
    prev = child;
  }
  if (prev != null) {
    callback(prev, null);
  }
}

class NodeSpacingConf {
  TexAtomType leftType;
  TexAtomType rightType;
  TexMathOptions options;
  double spacingAfter;

  NodeSpacingConf(
    this.leftType,
    this.rightType,
    this.options,
    this.spacingAfter,
  );
}

const sqrtDelimieterSequence = [
  // DelimiterConf(mainRegular, MathStyle.scriptscript),
  // DelimiterConf(mainRegular, MathStyle.script),
  DelimiterConf(mainRegular, TexMathStyle.text),
  DelimiterConf(size1Regular, TexMathStyle.text),
  DelimiterConf(size2Regular, TexMathStyle.text),
  DelimiterConf(size3Regular, TexMathStyle.text),
  DelimiterConf(size4Regular, TexMathStyle.text),
];

const vbPad = 80;
const emPad = vbPad / 1000;

// We use a different strategy of picking \\surd font than KaTeX
// KaTeX chooses the style and font of the \\surd to cover inner at *normalsize*
// We will use a highly similar strategy while sticking to the strict meaning
// of TexBook Rule 11. We do not choose the style at *normalsize*
double getSqrtAdvanceWidth(
  final double minDelimiterHeight,
  final double baseWidth,
  final TexMathOptions options,
) {
  // final newOptions = options.havingBaseSize();
  final delimConf = sqrtDelimieterSequence.firstWhereOrNull(
    (final element) =>
        getHeightForDelim(
          delim: '\u221A', // √
          fontName: element.font.fontName,
          style: element.style,
          options: options,
        ) >
        minDelimiterHeight,
  );
  if (delimConf != null) {
    final delimOptions = options.havingStyle(delimConf.style);
    if (delimConf.font.fontName == 'Main-Regular') {
      return cssem(0.833).toLpUnder(delimOptions);
    } else {
      // We will directly apply corresponding font
      final advanceWidth = cssem(1.0).toLpUnder(delimOptions);
      return advanceWidth;
    }
  } else {
    return cssem(1.056).toLpUnder(options);
  }
}

// We use a different strategy of picking \\surd font than KaTeX
// KaTeX chooses the style and font of the \\surd to cover inner at *normalsize*
// We will use a highly similar strategy while sticking to the strict meaning
// of TexBook Rule 11. We do not choose the style at *normalsize*
Widget sqrtSvg({
  required final double minDelimiterHeight,
  required final double baseWidth,
  required final TexMathOptions options,
}) {
  // final newOptions = options.havingBaseSize();
  final delimConf = sqrtDelimieterSequence.firstWhereOrNull(
    (final element) =>
        getHeightForDelim(
          delim: '\u221A', // √
          fontName: element.font.fontName,
          style: element.style,
          options: options,
        ) >
        minDelimiterHeight,
  );

  const extraViniculum = 0.0; //math.max(0.0, options)
  // final ruleWidth =
  //     options.fontMetrics.sqrtRuleThickness.cssEm.toLpUnder(options);
  // TODO: support Settings.minRuleThickness.

  // These are the known height + depth for \u221A
  if (delimConf != null) {
    final fontHeight = const {
      'Main-Regular': 1.0,
      'Size1-Regular': 1.2,
      'Size2-Regular': 1.8,
      'Size3-Regular': 2.4,
      'Size4-Regular': 3.0,
    }[delimConf.font.fontName]!;
    final delimOptions = options.havingStyle(delimConf.style);
    final viewPortHeight = cssem(fontHeight + extraViniculum + emPad).toLpUnder(delimOptions);
    if (delimConf.font.fontName == 'Main-Regular') {
      // We will be vertically stretching the sqrtMain path (by viewPort vs
      // viewBox) to mimic the height of \u221A under Main-Regular font and
      // corresponding Mathstyle.
      final advanceWidth = cssem(0.833).toLpUnder(delimOptions);
      final viewPortWidth = advanceWidth + baseWidth;
      const viewBoxHeight = 1000 + 1000 * extraViniculum + vbPad;
      final viewBoxWidth = lp(viewPortWidth).toCssEmUnder(delimOptions) * 1000;
      final svgPath = sqrtPath('sqrtMain', extraViniculum, viewBoxHeight);
      return ResetBaseline(
        height: cssem(options.fontMetrics.sqrtRuleThickness + extraViniculum).toLpUnder(delimOptions),
        child: MinDimension(
          topPadding: cssem(-emPad).toLpUnder(delimOptions),
          child: svgWidgetFromPath(
            svgPath,
            Size(viewPortWidth, viewPortHeight),
            Rect.fromLTWH(0, 0, viewBoxWidth, viewBoxHeight),
            Color(options.color.argb),
            align: Alignment.topLeft,
            fit: BoxFit.fill,
          ),
        ),
      );
    } else {
      // We will directly apply corresponding font
      final advanceWidth = cssem(1.0).toLpUnder(delimOptions);
      final viewPortWidth = max(
        advanceWidth + baseWidth,
        cssem(1.02).toCssEmUnder(delimOptions),
      );
      final viewBoxHeight = (1000 + vbPad) * fontHeight;
      final viewBoxWidth = lp(viewPortWidth).toCssEmUnder(delimOptions) * 1000;
      final svgPath =
          sqrtPath('sqrt${delimConf.font.fontName.substring(0, 5)}', extraViniculum, viewBoxHeight);
      return ResetBaseline(
        height: cssem(options.fontMetrics.sqrtRuleThickness + extraViniculum).toLpUnder(delimOptions),
        child: MinDimension(
          topPadding: cssem(-emPad).toLpUnder(delimOptions),
          child: svgWidgetFromPath(
            svgPath,
            Size(viewPortWidth, viewPortHeight),
            Rect.fromLTWH(0, 0, viewBoxWidth, viewBoxHeight),
            Color(options.color.argb),
            align: Alignment.topLeft,
            fit: BoxFit.cover, // BoxFit.fitHeight, // For DomCanvas compatibility
          ),
        ),
      );
    }
  } else {
    // We will use the viewBoxHeight parameter in sqrtTall path
    final viewPortHeight = minDelimiterHeight + cssem(extraViniculum + emPad).toLpUnder(options);
    final viewBoxHeight =
        1000 * lp(minDelimiterHeight).toCssEmUnder(options) + extraViniculum + vbPad;
    final advanceWidth = cssem(1.056).toLpUnder(options);
    final viewPortWidth = advanceWidth + baseWidth;
    final viewBoxWidth = lp(viewPortWidth).toCssEmUnder(options) * 1000;
    final svgPath = sqrtPath('sqrtTall', extraViniculum, viewBoxHeight);
    return ResetBaseline(
      height: cssem(options.fontMetrics.sqrtRuleThickness + extraViniculum).toLpUnder(options),
      child: MinDimension(
        topPadding: cssem(-emPad).toLpUnder(options),
        child: svgWidgetFromPath(
          svgPath,
          Size(viewPortWidth, viewPortHeight),
          Rect.fromLTWH(0, 0, viewBoxWidth, viewBoxHeight),
          Color(options.color.argb),
          align: Alignment.topLeft,
          fit: BoxFit.cover, // BoxFit.fitHeight, // For DomCanvas compatibility
        ),
      ),
    );
  }
}

const stretchyOpMapping = {
  '\u2190': 'xleftarrow',
  '\u2192': 'xrightarrow',
  '\u2194': 'xleftrightarrow',
  '\u21d0': 'xLeftarrow',
  '\u21d2': 'xRightarrow',
  '\u21d4': 'xLeftrightarrow',
  '\u21a9': 'xhookleftarrow',
  '\u21aa': 'xhookrightarrow',
  '\u21a6': 'xmapsto',
  '\u21c1': 'xrightharpoondown',
  '\u21c0': 'xrightharpoonup',
  '\u21bd': 'xleftharpoondown',
  '\u21bc': 'xleftharpoonup',
  '\u21cc': 'xrightleftharpoons',
  '\u21cb': 'xleftrightharpoons',
  '=': 'xlongequal',
  '\u219e': 'xtwoheadleftarrow',
  '\u21a0': 'xtwoheadrightarrow',
  // '\u21c4': '\\xtofrom',
  '\u21c4': 'xrightleftarrows',
  // '\\xrightequilibrium': '\u21cc', // Not a perfect match.
  // '\\xleftequilibrium': '\u21cb', // None better available.
};

TexGreenEquationrow stringToNode(
  final String string, [
  final TexMode mode = TexMode.text,
]) =>
    TexGreenEquationrowImpl(
      children: string
          .split('')
          .map(
            (final ch) => TexGreenSymbolImpl(
              symbol: ch,
              mode: mode,
            ),
          )
          .toList(
            growable: false,
          ),
    );

TexAtomType getDefaultAtomTypeForSymbol(
  final String symbol, {
  required final TexMode mode,
  final bool variantForm = false,
}) {
  SymbolRenderConfig? symbolRenderConfig = symbolRenderConfigs[symbol];
  if (variantForm) {
    symbolRenderConfig = symbolRenderConfig?.variantForm;
  }
  final renderConfig = mode == TexMode.math ? symbolRenderConfig?.math : symbolRenderConfig?.text;
  if (renderConfig != null) {
    return renderConfig.defaultType ?? TexAtomType.ord;
  }
  if (variantForm == false && mode == TexMode.math) {
    if (negatedOperatorSymbols.containsKey(symbol)) {
      return TexAtomType.rel;
    }
    if (compactedCompositeSymbols.containsKey(symbol)) {
      return compactedCompositeSymbolTypes[symbol]!;
    }
    if (decoratedEqualSymbols.contains(symbol)) {
      return TexAtomType.rel;
    }
  }
  return TexAtomType.ord;
}

bool isCombiningMark(
  final String ch,
) {
  final code = ch.codeUnitAt(0);
  return code >= 0x0300 && code <= 0x036f;
}

/// This render object overrides the return value of
// ignore: comment_references
/// [RenderProxyBox.computeDistanceToActualBaseline]
// ignore: comment_references
/// to align [TexGreenCursor] properly in a [RenderLine] with respect to symbols.
class BaselineDistance extends SingleChildRenderObjectWidget {
  const BaselineDistance({
    required final this.baselineDistance,
    final Key? key,
    final Widget? child,
  }) : super(key: key, child: child);

  final double baselineDistance;

  @override
  BaselineDistanceBox createRenderObject(
    final BuildContext context,
  ) =>
      BaselineDistanceBox(baselineDistance);
}

class BaselineDistanceBox extends RenderProxyBox {
  final double baselineDistance;

  BaselineDistanceBox(
    final this.baselineDistance,
  );

  @override
  double? computeDistanceToActualBaseline(
    final TextBaseline baseline,
  ) =>
      baselineDistance;
}

// TexBook Appendix B
const delimiterFactor = 901;

final delimiterShorfall = pt(5.0);

const stackLargeDelimiters = {
  '(', ')',
  '[', ']',
  '{', '}',
  '\u230a', '\u230b', // '\\lfloor', '\\rfloor',
  '\u2308', '\u2309', // '\\lceil', '\\rceil',
  '\u221a', // '\\surd'
};

// delimiters that always stack
const stackAlwaysDelimiters = {
  '\u2191', // '\\uparrow',
  '\u2193', // '\\downarrow',
  '\u2195', // '\\updownarrow',
  '\u21d1', // '\\Uparrow',
  '\u21d3', // '\\Downarrow',
  '\u21d5', // '\\Updownarrow',
  '|',
  // '\\|',
  // '\\vert',
  '\u2016', // '\\Vert', '\u2225'
  '\u2223', // '\\lvert', '\\rvert', '\\mid'
  '\u2225', // '\\lVert', '\\rVert',
  '\u27ee', // '\\lgroup',
  '\u27ef', // '\\rgroup',
  '\u23b0', // '\\lmoustache',
  '\u23b1', // '\\rmoustache',
};

// and delimiters that never stack
const stackNeverDelimiters = {
  '\u27e8', //'<',
  '\u27e9', //'>',
  '/',
};

Widget buildCustomSizedDelimWidget(
  final String? delim,
  final double minDelimiterHeight,
  final TexMathOptions options,
) {
  if (delim == null) {
    final axisHeight = options.fontMetrics.xHeight2.toLpUnder(options);
    return ShiftBaseline(
      relativePos: 0.5,
      offset: axisHeight,
      child: SizedBox(
        height: minDelimiterHeight,
        width: nullDelimiterSpace.toLpUnder(options),
      ),
    );
  }
  List<DelimiterConf> sequence;
  if (stackNeverDelimiters.contains(delim)) {
    sequence = stackNeverDelimiterSequence;
  } else if (stackLargeDelimiters.contains(delim)) {
    sequence = stackLargeDelimiterSequence;
  } else {
    sequence = stackAlwaysDelimiterSequence;
  }
  var delimConf = sequence.firstWhereOrNull(
    (final element) =>
        getHeightForDelim(
          delim: delim,
          fontName: element.font.fontName,
          style: element.style,
          options: options,
        ) >
        minDelimiterHeight,
  );
  if (stackNeverDelimiters.contains(delim)) {
    delimConf ??= sequence.last;
  }

  if (delimConf != null) {
    final axisHeight = options.fontMetrics.axisHeight2.toLpUnder(options);
    return ShiftBaseline(
      relativePos: 0.5,
      offset: axisHeight,
      child: makeChar(delim, delimConf.font, lookupChar(delim, delimConf.font, TexMode.math), options),
    );
  } else {
    return makeStackedDelim(delim, minDelimiterHeight, TexMode.math, options);
  }
}

Widget makeStackedDelim(
  final String delim,
  final double minDelimiterHeight,
  final TexMode mode,
  final TexMathOptions options,
) {
  final conf = stackDelimiterConfs[delim]!;
  final topMetrics = lookupChar(conf.top, conf.font, TexMode.math)!;
  final repeatMetrics = lookupChar(conf.repeat, conf.font, TexMode.math)!;
  final bottomMetrics = lookupChar(conf.bottom, conf.font, TexMode.math)!;
  final topHeight = cssem(topMetrics.height + topMetrics.depth).toLpUnder(options);
  final repeatHeight = cssem(repeatMetrics.height + repeatMetrics.depth).toLpUnder(options);
  final bottomHeight = cssem(bottomMetrics.height + bottomMetrics.depth).toLpUnder(options);
  double middleHeight = 0.0;
  int middleFactor = 1;
  TexCharacterMetrics? middleMetrics;
  if (conf.middle != null) {
    middleMetrics = lookupChar(conf.middle!, conf.font, TexMode.math)!;
    middleHeight = cssem(middleMetrics.height + middleMetrics.depth).toLpUnder(options);
    middleFactor = 2;
  }
  final minHeight = topHeight + bottomHeight + middleHeight;
  final repeatCount = max(0, (minDelimiterHeight - minHeight) / (repeatHeight * middleFactor)).ceil();
  // final realHeight = minHeight + repeatCount * middleFactor * repeatHeight;
  final axisHeight = options.fontMetrics.axisHeight2.toLpUnder(options);
  return ShiftBaseline(
    relativePos: 0.5,
    offset: axisHeight,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        makeChar(conf.top, conf.font, topMetrics, options),
        for (var i = 0; i < repeatCount; i++) makeChar(conf.repeat, conf.font, repeatMetrics, options),
        if (conf.middle != null) makeChar(conf.middle!, conf.font, middleMetrics!, options),
        if (conf.middle != null)
          for (var i = 0; i < repeatCount; i++) makeChar(conf.repeat, conf.font, repeatMetrics, options),
        makeChar(conf.bottom, conf.font, bottomMetrics, options),
      ],
    ),
  );
}

const size4Font = TexFontOptionsImpl(fontFamily: 'Size4');
const size1Font = TexFontOptionsImpl(fontFamily: 'Size1');

class StackDelimiterConf {
  final String top;
  final String? middle;
  final String repeat;
  final String bottom;
  final TexFontOptions font;

  const StackDelimiterConf({
    required final this.top,
    required final this.repeat,
    required final this.bottom,
    final this.middle,
    final this.font = size4Font,
  });
}

const stackDelimiterConfs = {
  '\u2191': // '\\uparrow',
      StackDelimiterConf(top: '\u2191', repeat: '\u23d0', bottom: '\u23d0', font: size1Font),
  '\u2193': // '\\downarrow',
      StackDelimiterConf(top: '\u23d0', repeat: '\u23d0', bottom: '\u2193', font: size1Font),
  '\u2195': // '\\updownarrow',
      StackDelimiterConf(top: '\u2191', repeat: '\u23d0', bottom: '\u2193', font: size1Font),
  '\u21d1': // '\\Uparrow',
      StackDelimiterConf(top: '\u21d1', repeat: '\u2016', bottom: '\u2016', font: size1Font),
  '\u21d3': // '\\Downarrow',
      StackDelimiterConf(top: '\u2016', repeat: '\u2016', bottom: '\u21d3', font: size1Font),
  '\u21d5': // '\\Updownarrow',
      StackDelimiterConf(top: '\u21d1', repeat: '\u2016', bottom: '\u21d3', font: size1Font),
  '|': // '\\|' ,'\\vert',
      StackDelimiterConf(top: '\u2223', repeat: '\u2223', bottom: '\u2223', font: size1Font),
  '\u2016': // '\\Vert', '\u2225'
      StackDelimiterConf(top: '\u2016', repeat: '\u2016', bottom: '\u2016', font: size1Font),
  '\u2223': // '\\lvert', '\\rvert', '\\mid'
      StackDelimiterConf(top: '\u2223', repeat: '\u2223', bottom: '\u2223', font: size1Font),
  '\u2225': // '\\lVert', '\\rVert',
      StackDelimiterConf(top: '\u2225', repeat: '\u2225', bottom: '\u2225', font: size1Font),
  '(': StackDelimiterConf(top: '\u239b', repeat: '\u239c', bottom: '\u239d'),
  ')': StackDelimiterConf(top: '\u239e', repeat: '\u239f', bottom: '\u23a0'),
  '[': StackDelimiterConf(top: '\u23a1', repeat: '\u23a2', bottom: '\u23a3'),
  ']': StackDelimiterConf(top: '\u23a4', repeat: '\u23a5', bottom: '\u23a6'),
  '{': StackDelimiterConf(top: '\u23a7', middle: '\u23a8', bottom: '\u23a9', repeat: '\u23aa'),
  '}': StackDelimiterConf(top: '\u23ab', middle: '\u23ac', bottom: '\u23ad', repeat: '\u23aa'),
  '\u230a': // '\\lfloor',
      StackDelimiterConf(top: '\u23a2', repeat: '\u23a2', bottom: '\u23a3'),
  '\u230b': // '\\rfloor',
      StackDelimiterConf(top: '\u23a5', repeat: '\u23a5', bottom: '\u23a6'),
  '\u2308': // '\\lceil',
      StackDelimiterConf(top: '\u23a1', repeat: '\u23a2', bottom: '\u23a2'),
  '\u2309': // '\\rceil',
      StackDelimiterConf(top: '\u23a4', repeat: '\u23a5', bottom: '\u23a5'),
  '\u27ee': // '\\lgroup',
      StackDelimiterConf(top: '\u23a7', repeat: '\u23aa', bottom: '\u23a9'),
  '\u27ef': // '\\rgroup',
      StackDelimiterConf(top: '\u23ab', repeat: '\u23aa', bottom: '\u23ad'),
  '\u23b0': // '\\lmoustache',
      StackDelimiterConf(top: '\u23a7', repeat: '\u23aa', bottom: '\u23ad'),
  '\u23b1': // '\\rmoustache',
      StackDelimiterConf(top: '\u23ab', repeat: '\u23aa', bottom: '\u23a9'),
};

enum MatrixRowAlign {
  top,
  bottom,
  center,
  baseline,
  // axis,
}

class MatrixLayoutDelegate extends IntrinsicLayoutDelegate<int> {
  final int rows;
  final int cols;
  final double ruleThickness;
  final double arrayskip;
  final List<double> rowSpacings;
  final List<TexMatrixSeparatorStyle> hLines;
  final bool hskipBeforeAndAfter;
  final double arraycolsep;
  final List<TexMatrixSeparatorStyle> vLines;
  final List<TexMatrixColumnAlign> columnAligns;

  MatrixLayoutDelegate({
    required final this.rows,
    required final this.cols,
    required final this.ruleThickness,
    required final this.arrayskip,
    required final this.rowSpacings,
    required final this.hLines,
    required final this.hskipBeforeAndAfter,
    required final this.arraycolsep,
    required final this.vLines,
    required final this.columnAligns,
  })  : vLinePos = List.filled(cols + 1, 0.0, growable: false),
        hLinePos = List.filled(rows + 1, 0.0, growable: false);
  List<double> hLinePos;
  List<double> vLinePos;
  double totalHeight = 0.0;
  double width = 0.0;

  @override
  double? computeDistanceToActualBaseline(
    final TextBaseline baseline,
    final Map<int, RenderBox> childrenTable,
  ) =>
      null;

  @override
  AxisConfiguration<int> performHorizontalIntrinsicLayout({
    required final Map<int, double> childrenWidths,
    final bool isComputingIntrinsics = false,
  }) {
    final childWidths = List.generate(
      cols * rows,
      (final index) => childrenWidths[index] ?? 0.0,
      growable: false,
    );
    // Calculate width for each column
    final colWidths = List.filled(cols, 0.0, growable: false);
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        colWidths[i] = max(
          colWidths[i],
          childWidths[j * cols + i],
        );
      }
    }
    // Layout each column
    final colPos = List.filled(cols, 0.0, growable: false);
    final vLinePos = List.filled(cols + 1, 0.0, growable: false);
    double pos = 0.0;
    vLinePos[0] = pos;
    pos += (vLines[0] != TexMatrixSeparatorStyle.none) ? ruleThickness : 0.0;
    pos += hskipBeforeAndAfter ? arraycolsep : 0.0;
    for (int i = 0; i < cols - 1; i++) {
      colPos[i] = pos;
      pos += colWidths[i] + arraycolsep;
      vLinePos[i + 1] = pos;
      pos += (vLines[i + 1] != TexMatrixSeparatorStyle.none) ? ruleThickness : 0.0;
      pos += arraycolsep;
    }
    colPos[cols - 1] = pos;
    pos += colWidths[cols - 1];
    pos += hskipBeforeAndAfter ? arraycolsep : 0.0;
    vLinePos[cols] = pos;
    pos += (vLines[cols] != TexMatrixSeparatorStyle.none) ? ruleThickness : 0.0;
    width = pos;
    // Determine position of children
    final childPos = List.generate(
      rows * cols,
      (final index) {
        final col = index % cols;
        switch (columnAligns[col]) {
          case TexMatrixColumnAlign.left:
            return colPos[col];
          case TexMatrixColumnAlign.right:
            return colPos[col] + colWidths[col] - childWidths[index];
          case TexMatrixColumnAlign.center:
            return colPos[col] + (colWidths[col] - childWidths[index]) / 2;
        }
      },
      growable: false,
    );
    if (!isComputingIntrinsics) {
      this.vLinePos = vLinePos;
    }
    return AxisConfiguration(
      size: width,
      offsetTable: childPos.asMap(),
    );
  }

  @override
  AxisConfiguration<int> performVerticalIntrinsicLayout({
    required final Map<int, double> childrenHeights,
    required final Map<int, double> childrenBaselines,
    final bool isComputingIntrinsics = false,
  }) {
    final childHeights = List.generate(
      cols * rows,
      (final index) => childrenBaselines[index] ?? 0.0,
      growable: false,
    );
    final childDepth = List.generate(
      cols * rows,
      (final index) {
        final height = childrenBaselines[index];
        if (height != null) {
          return childrenHeights[index]! - height;
        } else {
          return 0.0;
        }
      },
      growable: false,
    );
    // Calculate height and depth for each row
    // Minimum height and depth are 0.7 * arrayskip and 0.3 * arrayskip
    final rowHeights = List.filled(rows, 0.7 * arrayskip, growable: false);
    final rowDepth = List.filled(rows, 0.3 * arrayskip, growable: false);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        rowHeights[i] = max(
          rowHeights[i],
          childHeights[i * cols + j],
        );
        rowDepth[i] = max(
          rowDepth[i],
          childDepth[i * cols + j],
        );
      }
    }
    // Layout rows
    double pos = 0.0;
    final rowBaselinePos = List.filled(rows, 0.0, growable: false);
    final hLinePos = List.filled(rows + 1, 0.0, growable: false);
    for (int i = 0; i < rows; i++) {
      hLinePos[i] = pos;
      pos += (hLines[i] != TexMatrixSeparatorStyle.none) ? ruleThickness : 0.0;
      pos += rowHeights[i];
      rowBaselinePos[i] = pos;
      pos += rowDepth[i];
      pos += i < rows - 1 ? rowSpacings[i] : 0;
    }
    hLinePos[rows] = pos;
    pos += (hLines[rows] != TexMatrixSeparatorStyle.none) ? ruleThickness : 0.0;
    totalHeight = pos;
    // Calculate position for each children
    final childPos = List.generate(
      rows * cols,
      (final index) {
        final row = index ~/ cols;
        return rowBaselinePos[row] - childHeights[index];
      },
      growable: false,
    );
    if (!isComputingIntrinsics) {
      this.hLinePos = hLinePos;
    }
    return AxisConfiguration(
      size: totalHeight,
      offsetTable: childPos.asMap(),
    );
  }

  // Paint vlines and hlines
  @override
  void additionalPaint(
    final PaintingContext context,
    final Offset offset,
  ) {
    const dashSize = 4;
    final paint = Paint()..strokeWidth = ruleThickness;
    for (int i = 0; i < hLines.length; i++) {
      switch (hLines[i]) {
        case TexMatrixSeparatorStyle.solid:
          context.canvas.drawLine(
            Offset(
              offset.dx,
              offset.dy + hLinePos[i] + ruleThickness / 2,
            ),
            Offset(
              offset.dx + width,
              offset.dy + hLinePos[i] + ruleThickness / 2,
            ),
            paint,
          );
          break;
        case TexMatrixSeparatorStyle.dashed:
          for (var dx = 0.0; dx < width; dx += dashSize) {
            context.canvas.drawLine(
              Offset(
                offset.dx + dx,
                offset.dy + hLinePos[i] + ruleThickness / 2,
              ),
              Offset(
                offset.dx + min(dx + dashSize / 2, width),
                offset.dy + hLinePos[i] + ruleThickness / 2,
              ),
              paint,
            );
          }
          break;
        case TexMatrixSeparatorStyle.none:
      }
    }

    for (var i = 0; i < vLines.length; i++) {
      switch (vLines[i]) {
        case TexMatrixSeparatorStyle.solid:
          context.canvas.drawLine(
              Offset(
                offset.dx + vLinePos[i] + ruleThickness / 2,
                offset.dy,
              ),
              Offset(
                offset.dx + vLinePos[i] + ruleThickness / 2,
                offset.dy + totalHeight,
              ),
              paint);
          break;
        case TexMatrixSeparatorStyle.dashed:
          for (var dy = 0.0; dy < totalHeight; dy += dashSize) {
            context.canvas.drawLine(
              Offset(
                offset.dx + vLinePos[i] + ruleThickness / 2,
                offset.dy + dy,
              ),
              Offset(
                offset.dx + vLinePos[i] + ruleThickness / 2,
                offset.dy + min(dy + dashSize / 2, totalHeight),
              ),
              paint,
            );
          }
          break;
        case TexMatrixSeparatorStyle.none:
          continue;
      }
    }
  }
}

const naryDefaultLimit = {
  '\u220F',
  '\u2210',
  '\u2211',
  '\u22c0',
  '\u22c1',
  '\u22c2',
  '\u22c3',
  '\u2a00',
  '\u2a01',
  '\u2a02',
  '\u2a04',
  '\u2a06',
};

const stashedOvalNaryOperator = {
  '\u222F': '\u222C',
  '\u2230': '\u222D',
};

enum SqrtPos {
  base,
  ind, // Name collision here
  surd,
}

// Square roots are handled in the TeXbook pg. 443, Rule 11.
class SqrtLayoutDelegate extends CustomLayoutDelegate<SqrtPos> {
  final TexMathOptions options;
  final TexMathOptions baseOptions;

  // final MathOptions indexOptions;

  SqrtLayoutDelegate({
    required final this.options,
    required final this.baseOptions,
    // required this.indexOptions,
  });

  double heightAboveBaseline = 0.0;
  double svgHorizontalPos = 0.0;
  double svgVerticalPos = 0.0;

  @override
  double computeDistanceToActualBaseline(
    final TextBaseline baseline,
    final Map<SqrtPos, RenderBox> childrenTable,
  ) =>
      heightAboveBaseline;

  @override
  double getIntrinsicSize({
    required final Axis sizingDirection,
    required final bool max,
    required final double extent,
    required final double Function(RenderBox child, double extent) childSize,
    required final Map<SqrtPos, RenderBox> childrenTable,
  }) =>
      0;

  @override
  Size computeLayout(
    final BoxConstraints constraints,
    final Map<SqrtPos, RenderBox> childrenTable, {
    final bool dry = true,
  }) {
    final base = childrenTable[SqrtPos.base]!;
    final index = childrenTable[SqrtPos.ind];
    final surd = childrenTable[SqrtPos.surd]!;
    final baseSize = renderBoxGetLayoutSize(
      base,
      infiniteConstraint,
      dry: dry,
    );
    final indexSize = () {
      if (index == null) {
        return Size.zero;
      } else {
        return renderBoxGetLayoutSize(
          index,
          infiniteConstraint,
          dry: dry,
        );
      }
    }();
    final baseHeight = () {
      if (dry) {
        return 0;
      } else {
        return renderBoxLayoutHeight(base);
      }
    }();
    final baseWidth = baseSize.width;
    final indexHeight = () {
      if (dry) {
        return 0;
      } else {
        if (index == null) {
          return 0.0;
        } else {
          return renderBoxLayoutHeight(index);
        }
      }
    }();
    final indexWidth = indexSize.width;
    final theta = cssem(baseOptions.fontMetrics.defaultRuleThickness).toLpUnder(baseOptions);
    final phi = () {
      if (mathStyleGreater(baseOptions.style, TexMathStyle.text)) {
        return baseOptions.fontMetrics.xHeight2.toLpUnder(baseOptions);
      } else {
        return theta;
      }
    }();
    double psi = theta + 0.25 * phi.abs();
    final minSqrtHeight = baseSize.height + psi + theta;
    final surdConstraints = BoxConstraints(
      minWidth: baseWidth,
      minHeight: minSqrtHeight,
    );
    final surdSize = renderBoxGetLayoutSize(
      surd,
      surdConstraints,
      dry: dry,
    );
    final advanceWidth = getSqrtAdvanceWidth(minSqrtHeight, baseWidth, options);
    // Parameters for index
    // from KaTeX/src/katex.less
    final indexRightPadding = mu(-10.0).toLpUnder(options);
    // KaTeX chose a way to large value (5mu). We will use a smaller one.
    final indexLeftPadding = pt(0.5).toLpUnder(options);
    // Horizontal layout
    final sqrtHorizontalPos = max(0.0, indexLeftPadding + indexSize.width + indexRightPadding);
    final width = sqrtHorizontalPos + surdSize.width;
    // Vertical layout
    final ruleWidth = dry ? 0 : renderBoxLayoutHeight(surd);
    if (!dry) {
      final delimDepth = dry ? surdSize.height : renderBoxLayoutDepth(surd);
      if (delimDepth > baseSize.height + psi) {
        psi += 0.5 * (delimDepth - baseSize.height - psi);
      }
    }
    final bodyHeight = baseHeight + psi + ruleWidth;
    final bodyDepth = surdSize.height - bodyHeight;
    final indexShift = 0.6 * (bodyHeight - bodyDepth);
    final sqrtVerticalPos = max(0.0, indexHeight + indexShift - baseHeight - psi - ruleWidth);
    final height = sqrtVerticalPos + surdSize.height;
    // Position children
    if (!dry) {
      svgHorizontalPos = sqrtHorizontalPos;
      heightAboveBaseline = bodyHeight + sqrtVerticalPos;
      setRenderBoxOffset(
        base,
        Offset(
          sqrtHorizontalPos + advanceWidth,
          heightAboveBaseline - baseHeight,
        ),
      );
      if (index != null) {
        setRenderBoxOffset(
          index,
          Offset(
            sqrtHorizontalPos - indexRightPadding - indexWidth,
            heightAboveBaseline - indexShift - indexHeight,
          ),
        );
      }
      setRenderBoxOffset(
        surd,
        Offset(
          sqrtHorizontalPos,
          sqrtVerticalPos,
        ),
      );
    }
    return Size(width, height);
  }
}

class HorizontalStrikeDelegate extends CustomLayoutDelegate<int> {
  final double ruleThickness;
  final double vShift;
  final Color color;

  HorizontalStrikeDelegate({
    required final this.ruleThickness,
    required final this.vShift,
    required final this.color,
  });

  double height = 0.0;
  double width = 0.0;

  @override
  double computeDistanceToActualBaseline(
          final TextBaseline baseline, final Map<int, RenderBox> childrenTable) =>
      height;

  @override
  double getIntrinsicSize({
    required final Axis sizingDirection,
    required final bool max,
    required final double extent,
    required final double Function(RenderBox child, double extent) childSize,
    required final Map<int, RenderBox> childrenTable,
  }) =>
      childSize(childrenTable[0]!, double.infinity);

  @override
  Size computeLayout(
    final BoxConstraints constraints,
    final Map<int, RenderBox> childrenTable, {
    final bool dry = true,
  }) {
    final base = childrenTable[0]!;

    if (dry) {
      return base.getDryLayout(constraints);
    }

    base.layout(constraints, parentUsesSize: true);
    height = renderBoxLayoutHeight(base);
    width = base.size.width;

    return base.size;
  }

  @override
  void additionalPaint(final PaintingContext context, final Offset offset) {
    context.canvas.drawLine(
      Offset(
        offset.dx,
        offset.dy + height - vShift,
      ),
      Offset(
        offset.dx + width,
        offset.dy + height - vShift,
      ),
      Paint()
        ..strokeWidth = ruleThickness
        ..color = color,
    );
  }
}

enum FracPos {
  numer,
  denom,
}

class FracLayoutDelegate extends IntrinsicLayoutDelegate<FracPos> {
  final TexMeasurement? barSize;
  final TexMathOptions options;

  FracLayoutDelegate({
    required final this.barSize,
    required final this.options,
  });

  double theta = 0.0;
  double height = 0.0;
  double a = 0.0;
  double width = 0.0;
  double barLength = 0.0;

  @override
  double computeDistanceToActualBaseline(
    final TextBaseline baseline,
    final Map<FracPos, RenderBox> childrenTable,
  ) =>
      height;

  @override
  AxisConfiguration<FracPos> performHorizontalIntrinsicLayout({
    required final Map<FracPos, double> childrenWidths,
    final bool isComputingIntrinsics = false,
  }) {
    final numerSize = childrenWidths[FracPos.numer]!;
    final denomSize = childrenWidths[FracPos.denom]!;
    final barLength = max(numerSize, denomSize);
    // KaTeX/src/katex.less
    final nullDelimiterWidth = cssem(0.12).toLpUnder(options);
    final width = barLength + 2 * nullDelimiterWidth;
    if (!isComputingIntrinsics) {
      this.barLength = barLength;
      this.width = width;
    }

    return AxisConfiguration(
      size: width,
      offsetTable: {
        FracPos.numer: 0.5 * (width - numerSize),
        FracPos.denom: 0.5 * (width - denomSize),
      },
    );
  }

  @override
  AxisConfiguration<FracPos> performVerticalIntrinsicLayout({
    required final Map<FracPos, double> childrenHeights,
    required final Map<FracPos, double> childrenBaselines,
    final bool isComputingIntrinsics = false,
  }) {
    final numerSize = childrenHeights[FracPos.numer]!;
    final denomSize = childrenHeights[FracPos.denom]!;
    final numerHeight = childrenBaselines[FracPos.numer]!;
    final denomHeight = childrenBaselines[FracPos.denom]!;
    final metrics = options.fontMetrics;
    final xi8 = cssem(metrics.defaultRuleThickness).toLpUnder(options);
    final theta = barSize?.toLpUnder(options) ?? xi8;
    // Rule 15b
    double u = cssem(
      mathStyleGreater(options.style, TexMathStyle.text)
          ? metrics.num1
          : (theta != 0 ? metrics.num2 : metrics.num3),
    ).toLpUnder(options);
    double v =
        cssem(mathStyleGreater(options.style, TexMathStyle.text) ? metrics.denom1 : metrics.denom2)
            .toLpUnder(options);
    final a = metrics.axisHeight2.toLpUnder(options);
    final hx = numerHeight;
    final dx = numerSize - numerHeight;
    final hz = denomHeight;
    final dz = denomSize - denomHeight;
    if (theta == 0) {
      // Rule 15c
      final phi = mathStyleGreater(options.style, TexMathStyle.text) ? 7 * xi8 : 3 * xi8;
      final psi = (u - dx) - (hz - v);
      if (psi < phi) {
        u += 0.5 * (phi - psi);
        v += 0.5 * (phi - psi);
      }
    } else {
      // Rule 15d
      final phi = mathStyleGreater(options.style, TexMathStyle.text) ? 3 * theta : theta;
      if (u - dx - a - 0.5 * theta < phi) {
        u = phi + dx + a + 0.5 * theta;
      }
      if (a - 0.5 * theta - hz + v < phi) {
        v = phi + hz - a + 0.5 * theta;
      }
    }
    final height = hx + u;
    final depth = dz + v;
    if (!isComputingIntrinsics) {
      this.height = height;
      this.theta = theta;
      this.a = a;
    }
    return AxisConfiguration(
      size: height + depth,
      offsetTable: {
        FracPos.numer: height - u - hx,
        FracPos.denom: height + v - hz,
      },
    );
  }

  @override
  void additionalPaint(
    final PaintingContext context,
    final Offset offset,
  ) {
    if (theta != 0) {
      final paint = Paint()
        ..color = Color(options.color.argb)
        ..strokeWidth = theta;
      context.canvas.drawLine(
        Offset(0.5 * (width - barLength), height - a) + offset,
        Offset(0.5 * (width + barLength), height - a) + offset,
        paint,
      );
    }
  }
}

SELF texClipChildrenBetween<SELF extends TexGreenTNonleaf<SELF, TexGreen>>(
  final SELF node,
  final int pos1,
  final int pos2,
) {
  final childIndex1 = node.childPositions.slotFor(pos1);
  final childIndex2 = node.childPositions.slotFor(pos2);
  final childIndex1Floor = childIndex1.floor();
  final childIndex2Floor = childIndex2.floor();
  final head = () {
    if (childIndex1Floor != childIndex1 &&
        childIndex1Floor >= 0 &&
        childIndex1Floor <= node.children.length - 1) {
      final child = node.children[childIndex1Floor];
      if (child is TexGreenStyleImpl) {
        return texClipChildrenBetween<TexGreenStyleImpl>(
          child,
          pos1 - node.childPositions[childIndex1Floor],
          pos2 - node.childPositions[childIndex1Floor],
        );
      } else {
        return child;
      }
    } else {
      return null;
    }
  }();
  final childIndex1Ceil = childIndex1.ceil();
  final tail = () {
    final childIndex2Ceil = childIndex2.ceil();
    if (childIndex2Ceil != childIndex2 &&
        childIndex2Floor >= 0 &&
        childIndex2Floor <= node.children.length - 1) {
      final child = node.children[childIndex2Floor];
      if (child is TexGreenStyleImpl) {
        return texClipChildrenBetween<TexGreenStyleImpl>(
          child,
          pos1 - node.childPositions[childIndex2Floor],
          pos2 - node.childPositions[childIndex2Floor],
        );
      } else {
        return child;
      }
    }
  }();
  return node.updateChildren(
    [
      if (head != null) head,
      ...node.children.sublist(childIndex1Ceil, childIndex2Floor),
      if (tail != null) tail,
    ],
  );
}

List<int> makeCommonChildPositions(
  final TexGreenNonleaf node,
) {
  int curPos = 0;
  final result = <int>[];
  for (final child in node.children) {
    result.add(curPos);
    curPos += () {
      if (child == null) {
        return 0;
      } else {
        return texCapturedCursor(child);
      }
    }();
  }
  return result;
}

/// Number of cursor positions that can be captured within this node.
int texCapturedCursor(
  final TexGreen node,
) =>
    node.match(
      nonleaf: (final a) => a.editingWidth - 1,
      leaf: (final a) => 0,
    );

TexTextRangeImpl texGetRange(
  final TexGreen node,
  final int? pos,
) {
  if (pos == null) {
    return TexTextRangeImpl(
      start: 0,
      end: -1 + texCapturedCursor(node),
    );
  } else {
    return TexTextRangeImpl(
      start: pos + 1,
      end: pos + texCapturedCursor(node),
    );
  }
}

List<TexRed> findNodesAtPosition(
  final TexRed texRed,
  final int position,
) {
  TexRed curr = texRed;
  final res = <TexRed>[];
  for (;;) {
    res.add(curr);
    final next = curr.children.firstWhereOrNull(
      (final child) {
        if (child == null) {
          return false;
        } else {
          final range = texGetRange(
            child.greenValue,
            child.pos,
          );
          return range.start <= position && range.end >= position;
        }
      },
    );
    if (next == null) {
      break;
    }
    curr = next;
  }
  return res;
}

TexGreenEquationrow findNodeManagesPosition(
  final TexRedEquationrowImpl texRed,
  final int position,
) {
  TexRed curr = texRed;
  TexGreenEquationrow lastEqRow = texRed.greenValue;
  for (;;) {
    final next = curr.children.firstWhereOrNull(
      (final child) {
        if (child == null) {
          return false;
        } else {
          final range = texGetRange(
            child.greenValue,
            child.pos,
          );
          return range.start <= position && range.end >= position;
        }
      },
    );
    if (next == null) {
      break;
    }
    final nextGreenValue = next.greenValue;
    if (nextGreenValue is TexGreenEquationrow) {
      lastEqRow = nextGreenValue;
    }
    curr = next;
  }
  // assert(curr.value is EquationRowNode);
  return lastEqRow;
}

TexGreenEquationrowImpl findLowestCommonRowNode(
  final TexRedEquationrowImpl texRed,
  final int position1,
  final int position2,
) {
  final redNodes1 = findNodesAtPosition(texRed, position1);
  final redNodes2 = findNodesAtPosition(texRed, position2);
  for (int index = min(redNodes1.length, redNodes2.length) - 1; index >= 0; index--) {
    final node1 = redNodes1[index].greenValue;
    final node2 = redNodes2[index].greenValue;
    if (node1 == node2) {
      if (node1 is TexGreenEquationrowImpl) {
        return node1;
      } else {
        // Continue.
      }
    } else {
      // Continue.
    }
  }
  return texRed.greenValue;
}

List<TexGreen> findSelectedNodes(
  final TexRedEquationrowImpl texRed,
  final int position1,
  final int position2,
) {
  final rowNode = findLowestCommonRowNode(texRed, position1, position2);
  final localPos1 = position1 - rowNode.pos;
  final localPos2 = position2 - rowNode.pos;
  return texClipChildrenBetween<TexGreenEquationrowImpl>(
    rowNode,
    localPos1,
    localPos2,
  ).children;
}

double mathSizeSizeMultiplier(
  final TexMathSize size,
) {
  switch (size) {
    case TexMathSize.tiny:
      return 0.5;
    case TexMathSize.size2:
      return 0.6;
    case TexMathSize.scriptsize:
      return 0.7;
    case TexMathSize.footnotesize:
      return 0.8;
    case TexMathSize.small:
      return 0.9;
    case TexMathSize.normalsize:
      return 1.0;
    case TexMathSize.large:
      return 1.2;
    case TexMathSize.Large:
      return 1.44;
    case TexMathSize.LARGE:
      return 1.728;
    case TexMathSize.huge:
      return 2.074;
    case TexMathSize.HUGE:
      return 2.488;
  }
}

extension TexGreenEquationrowPos on TexGreenEquationrow {
  int get pos => range.start - 1;
}

enum MathStyleDiff {
  sub,
  sup,
  fracNum,
  fracDen,
  cramp,
  text,
  uncramp,
}

TexMeasurement? parseMeasurement({
  required final String str,
  required final double value,
}) {
  switch (str) {
    case 'pt':
      return pt(value);
    case 'mm':
      return mm(value);
    case 'cm':
      return cm(value);
    case 'inches':
      return inches(value);
    case 'bp':
      return bp(value);
    case 'pc':
      return pc(value);
    case 'dd':
      return dd(value);
    case 'cc':
      return cc(value);
    case 'nd':
      return nd(value);
    case 'nc':
      return nc(value);
    case 'sp':
      return sp(value);
    case 'px':
      return px(value);
    case 'ex':
      return ex(value);
    case 'em':
      return em(value);
    case 'mu':
      return mu(value);
    case 'lp':
      return lp(value);
    case 'cssEm':
      return cssem(value);
    default:
      return null;
  }
}

final TexMeasurement zeroPt = pt(0.0);
