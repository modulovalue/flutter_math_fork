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
import 'parser.dart';
import 'symbols.dart';

final Map<String, FunctionSpec> functions = () {
  void _registerFunctions(
    final Map<String, FunctionSpec> on,
    final Map<List<String>, FunctionSpec> entries,
  ) {
    entries.forEach(
      (final key, final value) {
        for (final name in key) {
          if (on.containsKey(name)) {
            throw Exception(
              "Key " + name + " is already in the map.",
            );
          } else {
            on[name] = value;
          }
        }
      },
    );
  }

  final map = <String, FunctionSpec>{};
  _registerFunctions(map, katexBaseFunctionEntries);
  _registerFunctions(map, katexExtFunctionEntries);
  _registerFunctions(map, cursorEntries);
  return map;
}();

class FunctionContext {
  final String funcName;
  final Token? token;
  final String? breakOnTokenText;
  final List<TexGreen> infixExistingArguments;

  const FunctionContext({
    required final this.funcName,
    required final this.breakOnTokenText,
    final this.token,
    final this.infixExistingArguments = const [],
  });
}

typedef FunctionHandler<T extends TexGreen> = T Function(
  TexParser parser,
  FunctionContext context,
);

class FunctionSpec<T extends TexGreen> {
  final int numArgs;
  final int greediness;
  final bool allowedInText;
  final bool allowedInMath;
  final int numOptionalArgs;
  final bool infix;
  final FunctionHandler<T> handler;

  // Has no real usage during parsing. Serves as hint during encoding.
  final List<TexMode?>? argModes;

  const FunctionSpec({
    required final this.numArgs,
    required final this.handler,
    final this.greediness = 1,
    final this.allowedInText = false,
    final this.allowedInMath = true,
    final this.numOptionalArgs = 0,
    final this.infix = false,
    final this.argModes,
  });

  int get totalArgs => numArgs + numOptionalArgs;
}

const katexBaseFunctionEntries = {
  ..._accentEntries,
  ..._accentUnderEntries,
  ..._arrowEntries,
  ..._arrayEntries,
  ..._breakEntries,
  ..._charEntries,
  ..._colorEntries,
  ..._crEntries,
  ..._delimSizingEntries,
  ..._encloseEntries,
  ..._environmentEntries,
  ..._fontEntries,
  ..._genfracEntries,
  ..._horizBraceEntries,
  ..._kernEntries,
  ..._mathEntries,
  ..._mclassEntries,
  ..._opEntries,
  ..._operatorNameEntries,
  ..._phantomEntries,
  ..._raiseBoxEntries,
  ..._ruleEntries,
  ..._sizingEntries,
  ..._sqrtEntries,
  ..._stylingEntries,
  ..._textEntries,
  ..._underOverEntries,
};

const _accentEntries = {
  [
    '\\acute',
    '\\grave',
    '\\ddot',
    '\\tilde',
    '\\bar',
    '\\breve',
    '\\check',
    '\\hat',
    '\\vec',
    '\\dot',
    '\\mathring',
    '\\widecheck',
    '\\widehat',
    '\\widetilde',
    '\\overrightarrow',
    '\\overleftarrow',
    '\\Overrightarrow',
    '\\overleftrightarrow',
    // '\\overgroup',
    // '\\overlinesegment',
    '\\overleftharpoon',
    '\\overrightharpoon',

    '\\overline'
  ]: FunctionSpec(
    numArgs: 1,
    handler: _accentHandler,
  ),
  [
    "\\'",
    '\\`',
    '\\^',
    '\\~',
    '\\=',
    '\\u',
    '\\.',
    '\\"',
    '\\r',
    '\\H',
    '\\v',
    // '\\textcircled',
  ]: FunctionSpec(
    numArgs: 1,
    allowedInMath: false,
    allowedInText: true,
    handler: _textAccentHandler,
  ),
};

const nonStretchyAccents = {
  '\\acute',
  '\\grave',
  '\\ddot',
  '\\tilde',
  '\\bar',
  '\\breve',
  '\\check',
  '\\hat',
  '\\vec',
  '\\dot',
  '\\mathring',
};

const shiftyAccents = {
  '\\widehat',
  '\\widetilde',
  '\\widecheck',
};

const accentCommandMapping = {
  '\\acute': '\u00B4',
  '\\grave': '\u0060',
  '\\ddot': '\u00A8',
  '\\tilde': '\u007E',
  '\\bar': '\u00AF',
  '\\breve': '\u02D8',
  '\\check': '\u02C7',
  '\\hat': '\u005E',
  '\\vec': '\u2192',
  '\\dot': '\u02D9',
  '\\mathring': '\u02da',
  '\\widecheck': '\u02c7',
  '\\widehat': '\u005e',
  '\\widetilde': '\u007e',
  '\\overrightarrow': '\u2192',
  '\\overleftarrow': '\u2190',
  '\\Overrightarrow': '\u21d2',
  '\\overleftrightarrow': '\u2194',
  // '\\overgroup': '\u',
  // '\\overlinesegment': '\u',
  '\\overleftharpoon': '\u21bc',
  '\\overrightharpoon': '\u21c0',
  "\\'": '\u00b4',
  '\\`': '\u0060',
  '\\^': '\u005e',
  '\\~': '\u007e',
  '\\=': '\u00af',
  '\\u': '\u02d8',
  '\\.': '\u02d9',
  '\\"': '\u00a8',
  '\\r': '\u02da',
  '\\H': '\u02dd',
  '\\v': '\u02c7',
  // '\\textcircled': '\u',

  '\\overline': '\u00AF',
};

TexGreen _accentHandler(final TexParser parser, final FunctionContext context) {
  final base = parser.parseArgNode(mode: TexMode.math, optional: false)!;

  final isStretchy = !nonStretchyAccents.contains(context.funcName);
  final isShifty = !isStretchy || shiftyAccents.contains(context.funcName);

  return TexGreenAccentImpl(
    base: greenNodeWrapWithEquationRow(
      base,
    ),
    label: accentCommandMapping[context.funcName]!,
    isStretchy: isStretchy,
    isShifty: isShifty,
  );
}

const textUnicodeAccentMapping = {
  '\\`': '\u0300',
  '\\"': '\u0308',
  '\\~': '\u0303',
  '\\=': '\u0304',
  "\\'": '\u0301',
  '\\u': '\u0306',
  '\\v': '\u030c',
  '\\^': '\u0302',
  '\\.': '\u0307',
  '\\r': '\u030a',
  '\\H': '\u030b',
  // '\\textcircled': '\u',
};

TexGreen _textAccentHandler(final TexParser parser, final FunctionContext context) {
  final base = parser.parseArgNode(mode: null, optional: false)!;
  if (base is TexGreenSymbol) {
    return base.withSymbol(
      base.symbol + textUnicodeAccentMapping[context.funcName]!,
    );
  }
  if (base is TexGreenEquationrow && base.children.length == 1) {
    final node = base.children[0];
    if (node is TexGreenSymbol) {
      return node.withSymbol(
        node.symbol + textUnicodeAccentMapping[context.funcName]!,
      );
    }
  }
  return TexGreenAccentImpl(
    base: greenNodeWrapWithEquationRow(
      base,
    ),
    label: accentCommandMapping[context.funcName]!,
    isStretchy: false,
    isShifty: true,
  );
}

const _accentUnderEntries = {
  [
    '\\underleftarrow',
    '\\underrightarrow',
    '\\underleftrightarrow',
    '\\undergroup',
    // '\\underlinesegment': ,
    '\\utilde',

    '\\underline'
  ]: FunctionSpec(numArgs: 1, handler: _accentUnderHandler),
};

const accentUnderMapping = {
  '\\underleftarrow': '\u2190',
  '\\underrightarrow': '\u2192',
  '\\underleftrightarrow': '\u2194',
  '\\undergroup': '\u23e0',
  // '\\underlinesegment',
  '\\utilde': '\u007e',

  '\\underline': '\u00af'
};

TexGreen _accentUnderHandler(final TexParser parser, final FunctionContext context) {
  final base = parser.parseArgNode(mode: null, optional: false)!;
  return TexGreenAccentunderImpl(
    base: greenNodeWrapWithEquationRow(
      base,
    ),
    label: accentUnderMapping[context.funcName]!,
  );
}

const _arrayEntries = {
  ['\\hline', '\\hdashline']: FunctionSpec(
    numArgs: 0,
    allowedInText: true,
    allowedInMath: true,
    handler: _throwExceptionHandler,
  )
};

TexGreen _throwExceptionHandler(final TexParser parser, final FunctionContext context) {
  throw ParseException('${context.funcName} valid only within array environment');
}

const _arrowEntries = {
  [
    '\\xleftarrow', '\\xrightarrow', '\\xLeftarrow', '\\xRightarrow',
    '\\xleftrightarrow', '\\xLeftrightarrow', '\\xhookleftarrow',
    '\\xhookrightarrow', '\\xmapsto', '\\xrightharpoondown',
    '\\xrightharpoonup', '\\xleftharpoondown', '\\xleftharpoonup',
    '\\xrightleftharpoons', '\\xleftrightharpoons', '\\xlongequal',
    '\\xtwoheadrightarrow', '\\xtwoheadleftarrow', '\\xtofrom',
    // The next 3 functions are here to support the mhchem extension.
    // Direct use of these functions is discouraged and may break someday.
    '\\xrightleftarrows', '\\xrightequilibrium', '\\xleftequilibrium',
  ]: FunctionSpec(
    numArgs: 1,
    numOptionalArgs: 1,
    handler: _arrowHandler,
  )
};

const arrowCommandMapping = {
  '\\xleftarrow': '\u2190',
  '\\xrightarrow': '\u2192',
  '\\xleftrightarrow': '\u2194',

  '\\xLeftarrow': '\u21d0',
  '\\xRightarrow': '\u21d2',
  '\\xLeftrightarrow': '\u21d4',

  '\\xhookleftarrow': '\u21a9',
  '\\xhookrightarrow': '\u21aa',

  '\\xmapsto': '\u21a6',

  '\\xrightharpoondown': '\u21c1',
  '\\xrightharpoonup': '\u21c0',
  '\\xleftharpoondown': '\u21bd',
  '\\xleftharpoonup': '\u21bc',
  '\\xrightleftharpoons': '\u21cc',
  '\\xleftrightharpoons': '\u21cb',

  '\\xlongequal': '=',

  '\\xtwoheadleftarrow': '\u219e',
  '\\xtwoheadrightarrow': '\u21a0',

  '\\xtofrom': '\u21c4',
  '\\xrightleftarrows': '\u21c4',
  '\\xrightequilibrium': '\u21cc', // Not a perfect match.
  '\\xleftequilibrium': '\u21cb', // None better available.
};

TexGreen _arrowHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final below = parser.parseArgNode(mode: null, optional: true);
  final above = parser.parseArgNode(mode: null, optional: false)!;
  return TexGreenStretchyopImpl(
    above: greenNodeWrapWithEquationRow(
      above,
    ),
    below: greenNodeWrapWithEquationRowOrNull(
      below,
    ),
    symbol: arrowCommandMapping[context.funcName] ?? context.funcName,
  );
}

const _breakEntries = {
  [
    '\\nobreak',
    '\\allowbreak',
  ]: FunctionSpec(
    numArgs: 0,
    handler: _breakHandler,
  )
};

TexGreen _breakHandler(
  final TexParser parser,
  final FunctionContext context,
) =>
    TexGreenSpaceImpl(
      height: zeroPt,
      width: zeroPt,
      breakPenalty: () {
        if (context.funcName == '\\nobreak') {
          return 10000;
        } else {
          return 0;
        }
      }(),
      // noBreak: context.funcName == '\\nobreak',
      mode: parser.mode,
    );

const _charEntries = {
  [
    '\\@char',
  ]: FunctionSpec(
    numArgs: 1,
    allowedInText: true,
    handler: _charHandler,
  ),
};

TexGreen _charHandler(final TexParser parser, final FunctionContext context) {
  final arg = assertNodeType<TexGreenEquationrow>(parser.parseArgNode(mode: null, optional: false));
  final number = arg.children.map((final child) => assertNodeType<TexGreenSymbol>(child).symbol).join('');
  final code = int.tryParse(number);
  if (code == null) {
    throw ParseException('\\@char has non-numeric argument $number');
  }
  return TexGreenSymbolImpl(
    symbol: String.fromCharCode(code),
    mode: parser.mode,
    overrideAtomType: TexAtomType.ord,
  );
}

const _colorEntries = {
  ['\\textcolor']: FunctionSpec(
    numArgs: 2,
    allowedInText: true,
    greediness: 3,
    handler: _textcolorHandler,
  ),
  ['\\color']: FunctionSpec(
    numArgs: 1,
    allowedInText: true,
    greediness: 3,
    handler: _colorHandler,
  ),
};

TexGreen _textcolorHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final color = parser.parseArgColor(optional: false)!;
  final body = parser.parseArgNode(
    mode: null,
    optional: false,
  )!;
  return TexGreenStyleImpl(
    optionsDiff: TexOptionsDiffImpl(
      color: color,
    ),
    children: greenNodeExpandEquationRow(body),
  );
}

TexGreen _colorHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final color = parser.parseArgColor(
    optional: false,
  );
  final body = parser.parseExpression(
    breakOnInfix: true,
    breakOnTokenText: context.breakOnTokenText,
  );
  return TexGreenStyleImpl(
    optionsDiff: TexOptionsDiffImpl(
      color: () {
        if (color == null) {
          return null;
        } else {
          return color;
        }
      }(),
    ),
    children: body,
  );
}

const _crEntries = {
  ['\\cr', '\\newline']: FunctionSpec(
    numArgs: 0,
    numOptionalArgs: 1,
    allowedInText: true,
    handler: _crHandler,
  ),
};

TexGreen _crHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final size = parser.parseArgSize(optional: true);
  final newRow = context.funcName == '\\cr';
  bool newLine = false;
  if (!newRow) {
    if (parser.settings.displayMode &&
        parser.settings.useStrictBehavior(
            'newLineInDisplayMode',
            'In LaTeX, \\\\ or \\newline '
                'does nothing in display mode')) {
      newLine = false;
    } else {
      newLine = true;
    }
  }
  return TexGreenTemporaryCr(newLine: newLine, newRow: newRow, size: size);
}

const _delimSizingEntries = {
  [
    '\\bigl',
    '\\Bigl',
    '\\biggl',
    '\\Biggl',
    '\\bigr',
    '\\Bigr',
    '\\biggr',
    '\\Biggr',
    '\\bigm',
    '\\Bigm',
    '\\biggm',
    '\\Biggm',
    '\\big',
    '\\Big',
    '\\bigg',
    '\\Bigg',
  ]: FunctionSpec(numArgs: 1, handler: _delimSizeHandler),
  ['\\right']: FunctionSpec(
    numArgs: 1,
    // greediness: 3,
    handler: _rightHandler,
  ),
  ['\\left']: FunctionSpec(
    numArgs: 1,
    // greediness: 2,
    handler: _leftHandler,
  ),
  ['\\middle']: FunctionSpec(numArgs: 1, handler: _middleHandler),
};

const _delimiterTypes = {
  '\\bigl': TexAtomType.open,
  '\\Bigl': TexAtomType.open,
  '\\biggl': TexAtomType.open,
  '\\Biggl': TexAtomType.open,
  '\\bigr': TexAtomType.close,
  '\\Bigr': TexAtomType.close,
  '\\biggr': TexAtomType.close,
  '\\Biggr': TexAtomType.close,
  '\\bigm': TexAtomType.rel,
  '\\Bigm': TexAtomType.rel,
  '\\biggm': TexAtomType.rel,
  '\\Biggm': TexAtomType.rel,
  '\\big': TexAtomType.ord,
  '\\Big': TexAtomType.ord,
  '\\bigg': TexAtomType.ord,
  '\\Bigg': TexAtomType.ord,
};

const _delimiterSizes = {
  '\\bigl': 1,
  '\\Bigl': 2,
  '\\biggl': 3,
  '\\Biggl': 4,
  '\\bigr': 1,
  '\\Bigr': 2,
  '\\biggr': 3,
  '\\Biggr': 4,
  '\\bigm': 1,
  '\\Bigm': 2,
  '\\biggm': 3,
  '\\Biggm': 4,
  '\\big': 1,
  '\\Big': 2,
  '\\bigg': 3,
  '\\Bigg': 4,
};

const delimiterCommands = [
  '(',
  '\\lparen',
  ')',
  '\\rparen',
  '[',
  '\\lbrack',
  ']',
  '\\rbrack',
  '\\{',
  '\\lbrace',
  '\\}',
  '\\rbrace',
  '\\lfloor',
  '\\rfloor',
  '\u230a',
  '\u230b',
  '\\lceil',
  '\\rceil',
  '\u2308',
  '\u2309',
  '<',
  '>',
  '\\langle',
  '\u27e8',
  '\\rangle',
  '\u27e9',
  '\\lt',
  '\\gt',
  '\\lvert',
  '\\rvert',
  '\\lVert',
  '\\rVert',
  '\\lgroup',
  '\\rgroup',
  '\u27ee',
  '\u27ef',
  '\\lmoustache',
  '\\rmoustache',
  '\u23b0',
  '\u23b1',
  '/',
  '\\backslash',
  '|',
  '\\vert',
  '\\|',
  '\\Vert',
  '\\uparrow',
  '\\Uparrow',
  '\\downarrow',
  '\\Downarrow',
  '\\updownarrow',
  '\\Updownarrow',
  '.',
];

final _delimiterSymbols = delimiterCommands
    .map((final command) => texSymbolCommandConfigs[TexMode.math]![command]!)
    .toList(growable: false);

String? _checkDelimiter(final TexGreen delim, final FunctionContext context) {
  if (delim is TexGreenSymbol) {
    if (_delimiterSymbols
        .any((final symbol) => symbol.symbol == delim.symbol && symbol.variantForm == delim.variantForm)) {
      if (delim.symbol == '<' || delim.symbol == 'lt') {
        return '\u27e8';
      } else if (delim.symbol == '>' || delim.symbol == 'gt') {
        return '\u27e9';
      } else if (delim.symbol == '.') {
        return null;
      } else {
        return delim.symbol;
      }
    } else {
      // TODO: this throw omitted the token location
      throw ParseException("Invalid delimiter '${delim.symbol}' after '${context.funcName}'");
    }
  } else {
    throw ParseException("Invalid delimiter type '${delim.runtimeType}'");
  }
}

TexGreen _delimSizeHandler(final TexParser parser, final FunctionContext context) {
  final delimArg = parser.parseArgNode(mode: TexMode.math, optional: false)!;
  final delim = _checkDelimiter(delimArg, context);
  if (delim == null) {
    return TexGreenSpaceImpl(
      height: zeroPt,
      width: zeroPt,
      mode: TexMode.math,
    );
  } else {
    return TexGreenSymbolImpl(
      symbol: delim,
      overrideAtomType: _delimiterTypes[context.funcName],
      overrideFont: TexFontOptionsImpl(
        fontFamily: 'Size${_delimiterSizes[context.funcName]}',
      ),
    );
  }
}

/// KaTeX's \color command will affect the right delimiter.
/// MathJax's \color command will not affect the right delimiter.
/// Here we choose to follow MathJax's behavior because it fits out AST design
/// better. KaTeX's solution is messy.
TexGreen _rightHandler(final TexParser parser, final FunctionContext context) {
  final delimArg = parser.parseArgNode(mode: TexMode.math, optional: false)!;
  return TexGreenTemporaryLeftRightRight(
    delim: _checkDelimiter(delimArg, context),
  );
}

TexGreen _leftHandler(final TexParser parser, final FunctionContext context) {
  final leftArg = parser.parseArgNode(mode: TexMode.math, optional: false)!;
  final delim = _checkDelimiter(leftArg, context);
  // Parse out the implicit body
  ++parser.leftrightDepth;
  // parseExpression stops before '\\right'
  final body = parser.parseExpression(breakOnInfix: false);
  --parser.leftrightDepth;
  // Check the next token
  parser.expect('\\right', consume: false);
  // Use parseArgNode instead of parseFunction like KaTeX
  final rightArg = parser.parseFunction(null, null, null);
  final right = assertNodeType<TexGreenTemporaryLeftRightRight>(rightArg);

  final splittedBody = [<TexGreen>[]];
  final middles = <String?>[];
  for (final element in body) {
    if (element is TexGreenTemporaryMiddle) {
      splittedBody.add([]);
      middles.add(() {
        if (element.delim == '.') {
          return null;
        } else {
          return element.delim;
        }
      }());
    } else {
      splittedBody.last.add(element);
    }
  }
  return TexGreenLeftrightImpl(
    leftDelim: () {
      if (delim == '.') {
        return null;
      } else {
        return delim;
      }
    }(),
    rightDelim: () {
      if (right.delim == '.') {
        return null;
      } else {
        return right.delim;
      }
    }(),
    body: splittedBody
        .map(
          greenNodesWrapWithEquationRow,
        )
        .toList(
          growable: false,
        ),
    middle: middles,
  );
}

/// Middle can only appear directly between \left and \right. Wrapping \middle
/// will cause error. This is in accordance with MathJax and different from
/// KaTeX, and is more compatible with our AST structure.
TexGreen _middleHandler(final TexParser parser, final FunctionContext context) {
  final delimArg = parser.parseArgNode(mode: TexMode.math, optional: false)!;
  final delim = _checkDelimiter(delimArg, context);
  if (parser.leftrightDepth <= 0) {
    throw ParseException('\\middle without preceding \\left');
  }
  final contexts = parser.argParsingContexts.toList(growable: false);
  final lastContext = contexts[contexts.length - 2];
  if (lastContext.funcName != '\\left') {
    throw ParseException('\\middle must be within \\left and \\right');
  }

  return TexGreenTemporaryMiddle(delim: delim);
}

const _encloseEntries = {
  ['\\colorbox']: FunctionSpec(numArgs: 2, allowedInText: true, greediness: 3, handler: _colorboxHandler),
  ['\\fcolorbox']: FunctionSpec(numArgs: 3, allowedInText: true, greediness: 3, handler: _fcolorboxHandler),
  ['\\fbox']: FunctionSpec(numArgs: 1, allowedInText: true, handler: _fboxHandler),
  ['\\cancel', '\\bcancel', '\\xcancel', '\\sout']: FunctionSpec(numArgs: 1, handler: _cancelHandler),
};

TexGreen _colorboxHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final color = parser.parseArgColor(optional: false);
  final body = parser.parseArgNode(mode: TexMode.text, optional: false)!;
  return TexGreenEnclosureImpl(
    backgroundcolor: color,
    base: greenNodeWrapWithEquationRow(
      body,
    ),
    hasBorder: false,
    // FontMetrics.fboxsep
    verticalPadding: cssem(0.3),
    // katex.less/.boxpad
    horizontalPadding: cssem(0.3),
  );
}

TexGreen _fcolorboxHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final borderColor = parser.parseArgColor(optional: false)!;
  final color = parser.parseArgColor(optional: false)!;
  final body = parser.parseArgNode(
    mode: TexMode.text,
    optional: false,
  )!;
  return TexGreenEnclosureImpl(
    hasBorder: true,
    bordercolor: borderColor,
    backgroundcolor: color,
    base: greenNodeWrapWithEquationRow(
      body,
    ),
    // FontMetrics.fboxsep
    verticalPadding: cssem(0.3),
    // katex.less/.boxpad
    horizontalPadding: cssem(0.3),
  );
}

TexGreen _fboxHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final body = parser.parseArgHbox(optional: false);
  return TexGreenEnclosureImpl(
    hasBorder: true,
    base: greenNodeWrapWithEquationRow(
      body,
    ),
    // FontMetrics.fboxsep
    verticalPadding: cssem(0.3),
    // katex.less/.boxpad
    horizontalPadding: cssem(0.3),
  );
}

TexGreen _cancelHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final body = parser.parseArgNode(
    mode: null,
    optional: false,
  )!;
  return TexGreenEnclosureImpl(
    notation: const {
      '\\cancel': ['updiagonalstrike'],
      '\\bcancel': ['downdiagonalstrike'],
      '\\xcancel': ['updiagonalstrike, downdiagonalstrike'],
      '\\sout': ['horizontalstrike'],
    }[context.funcName]!,
    hasBorder: false,
    base: greenNodeWrapWithEquationRow(
      body,
    ),
    // KaTeX/src/functions/enclose.js line 59
    // KaTeX will remove this padding if base is not single char. We won't, as
    // MathJax neither.
    verticalPadding: cssem(0.2),
    // katex.less/.cancel-pad
    // KaTeX failed to apply this value, but we will, as MathJax had
    horizontalPadding: cssem(0.2),
  );
}

const _environmentEntries = {
  ['\\begin', '\\end']: FunctionSpec(numArgs: 1, handler: _enviromentHandler)
};

TexGreen _enviromentHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final nameGroup = parser.parseArgNode(
    mode: TexMode.text,
    optional: false,
  )!;
  if (nameGroup.childrenl.any((final element) => element is! TexGreenSymbol)) {
    throw ParseException('Invalid environment name');
  } else {
    final envName = nameGroup.childrenl.map(
      (final node) {
        if (node is TexGreenSymbol) {
          return node.symbol;
        } else {
          throw Exception("Expected node to be a $TexGreenSymbol");
        }
      },
    ).join();
    if (context.funcName == '\\begin') {
      // begin...end is similar to left...right
      if (!environments.containsKey(envName)) {
        throw ParseException('No such environment: $envName');
      } else {
        // Build the environment object. Arguments and other information will
        // be made available to the begin and end methods using properties.
        final env = environments[envName]!;
        final result = env.handler(
          parser,
          EnvContext(
            mode: parser.mode,
            envName: envName,
          ),
        );
        parser.expect('\\end', consume: false);
        final endNameToken = parser.nextToken;
        final end = assertNodeType<TexGreenTemporaryEndEnvironment>(
          parser.parseFunction(null, null, null),
        );
        if (end.name != envName) {
          throw ParseException('Mismatch: \\begin{$envName} matched by \\end{${end.name}}', endNameToken);
        } else {
          return result;
        }
      }
    } else {
      return TexGreenTemporaryEndEnvironment(
        name: envName,
      );
    }
  }
}

const _fontEntries = {
  [
    // styles, except \boldsymbol defined below
    '\\mathrm',
    '\\mathit',
    '\\mathbf', //'\\mathnormal',
    // families
    '\\mathbb',
    '\\mathcal',
    '\\mathfrak',
    '\\mathscr',
    '\\mathsf',
    '\\mathtt',
    // aliases, except \bm defined below
    '\\Bbb', '\\bold', '\\frak',
  ]: FunctionSpec(
    numArgs: 1,
    greediness: 2,
    handler: _fontHandler,
  ),
  [
    '\\boldsymbol',
    '\\bm',
  ]: FunctionSpec(
    numArgs: 1,
    greediness: 2,
    handler: _boldSymbolHandler,
  ),
  [
    '\\rm',
    '\\sf',
    '\\tt',
    '\\bf',
    '\\it',
    '\\cal',
  ]: FunctionSpec(
    numArgs: 0,
    allowedInText: true,
    handler: _textFontHandler,
  ),
};
const fontAliases = {
  '\\Bbb': '\\mathbb',
  '\\bold': '\\mathbf',
  '\\frak': '\\mathfrak',
  '\\bm': '\\boldsymbol',
};

TexGreen _fontHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final body = parser.parseArgNode(
    mode: null,
    optional: false,
  )!;
  final func = () {
    if (fontAliases.containsKey(context.funcName)) {
      return fontAliases[context.funcName];
    } else {
      return context.funcName;
    }
  }();
  return TexGreenStyleImpl(
    children: greenNodeExpandEquationRow(body),
    optionsDiff: TexOptionsDiffImpl(
      mathFontOptions: texMathFontOptions[func],
    ),
  );
}

TexGreen _boldSymbolHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final body = parser.parseArgNode(
    mode: null,
    optional: false,
  )!;
  // TODO
  // amsbsy.sty's \boldsymbol uses \binrel spacing to inherit the
  // argument's bin|rel|ord status
  return TexGreenStyleImpl(
    children: greenNodeExpandEquationRow(body),
    optionsDiff: TexOptionsDiffImpl(
      mathFontOptions: texMathFontOptions['\\boldsymbol'],
    ),
  );
}

TexGreen _textFontHandler(final TexParser parser, final FunctionContext context) {
  final body = parser.parseExpression(breakOnInfix: true, breakOnTokenText: context.breakOnTokenText);
  final style = '\\math${context.funcName.substring(1)}';

  return TexGreenStyleImpl(
    children: body,
    optionsDiff: TexOptionsDiffImpl(
      mathFontOptions: texMathFontOptions[style],
    ),
  );
}

const _genfracEntries = {
  [
    '\\cfrac', '\\dfrac', '\\frac', '\\tfrac',
    '\\dbinom', '\\binom', '\\tbinom',
    '\\\\atopfrac', // can’t be entered directly
    '\\\\bracefrac', '\\\\brackfrac', // ditto
  ]: FunctionSpec<TexGreen>(
    numArgs: 2,
    greediness: 2,
    handler: _fracHandler,
  ),

  // Infix generalized fractions -- these are not rendered directly, but
  // replaced immediately by one of the variants above.
  ['\\over', '\\choose', '\\atop', '\\brace', '\\brack']: FunctionSpec<TexGreen>(
    numArgs: 0,
    infix: true,
    handler: _overHandler,
  ),

  ['\\genfrac']: FunctionSpec<TexGreen>(
    numArgs: 6,
    greediness: 6,
    handler: _genfracHandler,
  ),

  // \above is an infix fraction that also defines a fraction bar size.
  ['\\above']: FunctionSpec<TexGreen>(
    numArgs: 1,
    infix: true,
    handler: _aboveHandler,
  ),

  ['\\\\abovefrac']: FunctionSpec(
    numArgs: 3,
    handler: _aboveFracHandler,
  ),
};

TexGreen _fracHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final numer = parser.parseArgNode(
    mode: null,
    optional: false,
  )!;
  final denom = parser.parseArgNode(
    mode: null,
    optional: false,
  )!;
  return _internalFracHandler(
    funcName: context.funcName,
    numer: greenNodeWrapWithEquationRow(
      numer,
    ),
    denom: greenNodeWrapWithEquationRow(
      denom,
    ),
  );
}

TexGreen _internalFracHandler({
  required final String funcName,
  required final TexGreenEquationrow numer,
  required final TexGreenEquationrow denom,
}) {
  bool hasBarLine;
  String? leftDelim;
  String? rightDelim;
  TexMathStyle? size;

  switch (funcName) {
    case '\\cfrac':
    case '\\dfrac':
    case '\\frac':
    case '\\tfrac':
      hasBarLine = true;
      break;
    case '\\\\atopfrac':
      hasBarLine = false;
      break;
    case '\\dbinom':
    case '\\binom':
    case '\\tbinom':
      hasBarLine = false;
      leftDelim = '(';
      rightDelim = ')';
      break;
    case '\\\\bracefrac':
      hasBarLine = false;
      leftDelim = '{';
      rightDelim = '}';
      break;
    case '\\\\brackfrac':
      hasBarLine = false;
      leftDelim = '[';
      rightDelim = ']';
      break;
    default:
      throw ParseException('Unrecognized genfrac command');
  }
  switch (funcName) {
    case '\\cfrac':
    case '\\dfrac':
    case '\\dbinom':
      size = TexMathStyle.display;
      break;
    case '\\tfrac':
    case '\\tbinom':
      size = TexMathStyle.text;
      break;
  }
  TexGreen res = TexGreenFracImpl(
    numerator: numer,
    denominator: denom,
    barSize: () {
      if (hasBarLine) {
        return null;
      } else {
        return zeroPt;
      }
    }(),
    continued: funcName == '\\cfrac',
  );
  if (leftDelim != null || rightDelim != null) {
    res = TexGreenLeftrightImpl(
      body: [
        greenNodeWrapWithEquationRow(
          res,
        ),
      ],
      leftDelim: leftDelim,
      rightDelim: rightDelim,
    );
  }
  if (size != null) {
    res = TexGreenStyleImpl(
      children: [res],
      optionsDiff: TexOptionsDiffImpl(
        style: size,
      ),
    );
  }
  return res;
}

TexGreen _overHandler(final TexParser parser, final FunctionContext context) {
  String replaceWith;
  switch (context.funcName) {
    case '\\over':
      replaceWith = '\\frac';
      break;
    case '\\choose':
      replaceWith = '\\binom';
      break;
    case '\\atop':
      replaceWith = '\\\\atopfrac';
      break;
    case '\\brace':
      replaceWith = '\\\\bracefrac';
      break;
    case '\\brack':
      replaceWith = '\\\\brackfrac';
      break;
    default:
      throw ArgumentError('Unrecognized infix genfrac command');
  }
  final numerBody = context.infixExistingArguments;
  final denomBody = parser.parseExpression(
    breakOnTokenText: context.breakOnTokenText,
    infixArgumentMode: true,
  );
  return _internalFracHandler(
    funcName: replaceWith,
    numer: greenNodesWrapWithEquationRow(numerBody),
    denom: greenNodesWrapWithEquationRow(denomBody),
  );
}

TexGreen _genfracHandler(final TexParser parser, final FunctionContext context) {
  final leftDelimArg = parser.parseArgNode(mode: TexMode.math, optional: false)!;
  final rightDelimArg = parser.parseArgNode(mode: TexMode.math, optional: false)!;
  final barSize = parser.parseArgSize(optional: false)!;
  final styleArg = parser.parseArgNode(mode: TexMode.text, optional: false)!;
  final numer = parser.parseArgNode(mode: TexMode.math, optional: false)!;
  final denom = parser.parseArgNode(mode: TexMode.math, optional: false)!;
  final leftDelimNode = () {
    if (leftDelimArg is TexGreenEquationrow) {
      if (leftDelimArg.children.length == 1) {
        return leftDelimArg.children.first;
      } else {
        return null;
      }
    } else {
      return leftDelimArg;
    }
  }();
  final rightDelimNode = () {
    if (rightDelimArg is TexGreenEquationrow) {
      if (rightDelimArg.children.length == 1) {
        return rightDelimArg.children.first;
      } else {
        return null;
      }
    } else {
      return rightDelimArg;
    }
  }();
  final leftDelim = () {
    if (leftDelimNode is TexGreenSymbol && leftDelimNode.atomType == TexAtomType.open) {
      return leftDelimNode.symbol;
    } else {
      return null;
    }
  }();
  final rightDelim = () {
    if (rightDelimNode is TexGreenSymbol && rightDelimNode.atomType == TexAtomType.close) {
      return rightDelimNode.symbol;
    } else {
      return null;
    }
  }();
  int? style;
  if (greenNodeExpandEquationRow(styleArg).isNotEmpty) {
    final textOrd = assertNodeType<TexGreenSymbol>(greenNodeExpandEquationRow(styleArg)[0]);
    style = int.tryParse(textOrd.symbol);
  }
  TexGreen res = TexGreenFracImpl(
    numerator: greenNodeWrapWithEquationRow(
      numer,
    ),
    denominator: greenNodeWrapWithEquationRow(
      denom,
    ),
    barSize: barSize,
  );
  if (leftDelim != null || rightDelim != null) {
    res = TexGreenLeftrightImpl(
      body: [
        greenNodeWrapWithEquationRow(
          res,
        ),
      ],
      leftDelim: leftDelim,
      rightDelim: rightDelim,
    );
  }
  if (style != null) {
    res = TexGreenStyleImpl(
      children: [res],
      optionsDiff: TexOptionsDiffImpl(
        style: integerToMathStyle(
          style,
        ),
      ),
    );
  }
  return res;
}

TexGreen _aboveHandler(final TexParser parser, final FunctionContext context) {
  final numerBody = context.infixExistingArguments;
  final barSize = parser.parseArgSize(optional: false);
  final denomBody = parser.parseExpression(
    breakOnTokenText: context.breakOnTokenText,
    infixArgumentMode: true,
  );
  return TexGreenFracImpl(
    numerator: greenNodesWrapWithEquationRow(numerBody),
    denominator: greenNodesWrapWithEquationRow(denomBody),
    barSize: barSize,
  );
}

TexGreen _aboveFracHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final numer = parser.parseArgNode(mode: TexMode.math, optional: false)!;
  final barSize = parser.parseArgSize(optional: false)!;
  final denom = parser.parseArgNode(mode: TexMode.math, optional: false)!;
  return TexGreenFracImpl(
    numerator: greenNodeWrapWithEquationRow(
      numer,
    ),
    denominator: greenNodeWrapWithEquationRow(
      denom,
    ),
    barSize: barSize,
  );
}

const _horizBraceEntries = {
  ['\\overbrace', '\\underbrace']: FunctionSpec(numArgs: 1, handler: _horizBraceHandler),
};

TexGreen _horizBraceHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final base = parser.parseArgNode(mode: null, optional: false)!;
  final scripts = parser.parseScripts();
  TexGreen res = base;
  if (context.funcName == '\\overbrace') {
    res = TexGreenAccentImpl(
      base: greenNodeWrapWithEquationRow(
        res,
      ),
      label: '\u23de',
      isStretchy: true,
      isShifty: false,
    );
    if (scripts.superscript != null) {
      res = TexGreenOverImpl(
        base: greenNodeWrapWithEquationRow(
          res,
        ),
        above: scripts.superscript!,
      );
    }
    if (scripts.subscript != null) {
      res = TexGreenUnderImpl(
        base: greenNodeWrapWithEquationRow(
          res,
        ),
        below: scripts.subscript!,
      );
    }
    return res;
  } else {
    res = TexGreenAccentunderImpl(
      base: greenNodeWrapWithEquationRow(
        res,
      ),
      label: '\u23df',
    );
    if (scripts.subscript != null) {
      res = TexGreenUnderImpl(
        base: greenNodeWrapWithEquationRow(
          res,
        ),
        below: scripts.subscript!,
      );
    }
    if (scripts.superscript != null) {
      res = TexGreenOverImpl(
        base: greenNodeWrapWithEquationRow(
          res,
        ),
        above: scripts.superscript!,
      );
    }
    return res;
  }
}

const _kernEntries = {
  ['\\kern', '\\mkern', '\\hskip', '\\mskip']: FunctionSpec(
    numArgs: 1,
    allowedInText: true,
    handler: _kernHandler,
  ),
};

TexGreen _kernHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final size = parser.parseArgSize(optional: false) ?? zeroPt;
  final mathFunction = context.funcName[1] == 'm';
  final muUnit = size.isMu();
  if (mathFunction) {
    if (!muUnit) {
      parser.settings.reportNonstrict(
          'mathVsTextUnits',
          "LaTeX's ${context.funcName} supports only mu units, "
              'not ${size.describe()} units');
    }
    if (parser.mode != TexMode.math) {
      parser.settings
          .reportNonstrict('mathVsTextUnits', "LaTeX's ${context.funcName} works only in math mode");
    }
  } else {
    if (muUnit) {
      parser.settings
          .reportNonstrict('mathVsTextUnits', "LaTeX's ${context.funcName} doesn't support mu units");
    }
  }
  return TexGreenSpaceImpl(
    height: zeroPt,
    width: size,
    mode: parser.mode,
  );
}

const _mathEntries = {
  [
    '\\(',
    '\$',
  ]: FunctionSpec(
    numArgs: 0,
    allowedInMath: false,
    allowedInText: true,
    handler: _mathLeftHandler,
  ),
  [
    '\\)',
    '\\]',
  ]: FunctionSpec(
    numArgs: 0,
    allowedInMath: false,
    allowedInText: true,
    handler: _mathRightHandler,
  ),
};

TexGreen _mathLeftHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final outerMode = parser.mode;
  parser.switchMode(TexMode.math);
  final close = () {
    if (context.funcName == '\\(') {
      return '\\)';
    } else {
      return '\$';
    }
  }();
  final body = parser.parseExpression(
    breakOnInfix: false,
    breakOnTokenText: close,
  );
  parser.expect(close);
  parser.switchMode(outerMode);
  return TexGreenStyleImpl(
    optionsDiff: const TexOptionsDiffImpl(
      style: TexMathStyle.text,
    ),
    children: body,
  );
}

TexGreen _mathRightHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  throw ParseException('Mismatched ${context.funcName}');
}

const _mclassEntries = {
  [
    '\\mathop',
    '\\mathord',
    '\\mathbin',
    '\\mathrel',
    '\\mathopen',
    '\\mathclose',
    '\\mathpunct',
    '\\mathinner',
  ]: FunctionSpec(numArgs: 1, handler: _mclassHandler),
};

TexGreen _mclassHandler(final TexParser parser, final FunctionContext context) {
  final body = parser.parseArgNode(mode: null, optional: false)!;
  return TexGreenEquationrowImpl(
    children: greenNodeExpandEquationRow(body),
    overrideType: const {
      '\\mathop': TexAtomType.op,
      '\\mathord': TexAtomType.ord,
      '\\mathbin': TexAtomType.bin,
      '\\mathrel': TexAtomType.rel,
      '\\mathopen': TexAtomType.open,
      '\\mathclose': TexAtomType.close,
      '\\mathpunct': TexAtomType.punct,
      '\\mathinner': TexAtomType.inner,
    }[context.funcName],
  );
}

const _opEntries = {
  [
    '\\coprod',
    '\\bigvee',
    '\\bigwedge',
    '\\biguplus',
    '\\bigcap',
    '\\bigcup',
    '\\intop',
    '\\prod',
    '\\sum',
    '\\bigotimes',
    '\\bigoplus',
    '\\bigodot',
    '\\bigsqcup',
    '\\smallint',
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
  ]: FunctionSpec(
    numArgs: 0,
    handler: _bigOpHandler,
  ),
  // ['\\mathop']: FunctionSpec(
  //   numArgs: 1,
  //   handler: _mathopHandler,
  // ),
  mathFunctions: FunctionSpec(
    numArgs: 0,
    handler: _mathFunctionHandler,
  ),
  mathLimits: FunctionSpec(
    numArgs: 0,
    handler: _mathLimitsHandler,
  ),
  [
    '\\int',
    '\\iint',
    '\\iiint',
    '\\oint',
    '\\oiint',
    '\\oiiint',
    '\u222b',
    '\u222c',
    '\u222d',
    '\u222e',
    '\u222f',
    '\u2230',
  ]: FunctionSpec(
    numArgs: 0,
    handler: _integralHandler,
  ),
};

TexGreenNaryoperator _parseNaryOperator(
  final String command,
  final TexParser parser,
  final FunctionContext context,
) {
  final scriptsResult = parser.parseScripts(allowLimits: true);
  final arg = greenNodeWrapWithEquationRowOrNull(
    parser.parseAtom(context.breakOnTokenText),
  );
  return TexGreenNaryoperatorImpl(
    operator: texSymbolCommandConfigs[TexMode.math]![command]!.symbol,
    lowerLimit: scriptsResult.subscript,
    upperLimit: scriptsResult.superscript,
    naryand: arg ?? emptyEquationRowNode(),
    limits: scriptsResult.limits,
    allowLargeOp: () {
      if (command == '\\smallint') {
        return false;
      } else {
        return true;
      }
    }(),
  );
}

///This behavior is in accordance with UnicodeMath, and is different from KaTeX.
///Math functions' default limits behavior is fixed on creation and will NOT
///change form according to style.
TexGreenFunction _parseMathFunction(
  final TexGreen funcNameBase,
  final TexParser parser,
  final FunctionContext context, {
  final bool defaultLimits = false,
}) {
  final scriptsResult = parser.parseScripts(allowLimits: true);
  final arg = greenNodeWrapWithEquationRowOrNull(
        parser.parseAtom(
          context.breakOnTokenText,
        ),
      ) ??
      emptyEquationRowNode();
  final limits = scriptsResult.limits ?? defaultLimits;
  final base = greenNodeWrapWithEquationRow(funcNameBase);
  if (scriptsResult.subscript == null && scriptsResult.superscript == null) {
    return TexGreenFunctionImpl(
      functionName: base,
      argument: arg,
    );
  }
  if (limits) {
    TexGreenEquationrowImpl functionName = base;
    if (scriptsResult.subscript != null) {
      functionName = greenNodeWrapWithEquationRow(
        TexGreenUnderImpl(
          base: functionName,
          below: scriptsResult.subscript!,
        ),
      );
    }
    if (scriptsResult.superscript != null) {
      functionName = greenNodeWrapWithEquationRow(
        TexGreenOverImpl(
          base: functionName,
          above: scriptsResult.superscript!,
        ),
      );
    }
    return TexGreenFunctionImpl(
      functionName: greenNodeWrapWithEquationRow(
        functionName,
      ),
      argument: arg,
    );
  } else {
    return TexGreenFunctionImpl(
      functionName: greenNodeWrapWithEquationRow(
        TexGreenMultiscriptsImpl(
          base: base,
          sub: scriptsResult.subscript,
          sup: scriptsResult.superscript,
        ),
      ),
      argument: arg,
    );
  }
}

const singleCharBigOps = {
  '\u220F': '\\prod',
  '\u2210': '\\coprod',
  '\u2211': '\\sum',
  '\u22c0': '\\bigwedge',
  '\u22c1': '\\bigvee',
  '\u22c2': '\\bigcap',
  '\u22c3': '\\bigcup',
  '\u2a00': '\\bigodot',
  '\u2a01': '\\bigoplus',
  '\u2a02': '\\bigotimes',
  '\u2a04': '\\biguplus',
  '\u2a06': '\\bigsqcup',
};

TexGreen _bigOpHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  return _parseNaryOperator(
    () {
      if (context.funcName.length == 1) {
        return singleCharBigOps[context.funcName]!;
      } else {
        return context.funcName;
      }
    }(),
    parser,
    context,
  );
}

// GreenNode _mathopHandler(TexParser parser, FunctionContext context) {
//   final fName = parser.parseArgNode(mode: Mode.math, optional: false);
//   return _parseMathFunction(fName, parser, context);
// }

const mathFunctions = [
  '\\arcsin',
  '\\arccos',
  '\\arctan',
  '\\arctg',
  '\\arcctg',
  '\\arg',
  '\\ch',
  '\\cos',
  '\\cosec',
  '\\cosh',
  '\\cot',
  '\\cotg',
  '\\coth',
  '\\csc',
  '\\ctg',
  '\\cth',
  '\\deg',
  '\\dim',
  '\\exp',
  '\\hom',
  '\\ker',
  '\\lg',
  '\\ln',
  '\\log',
  '\\sec',
  '\\sin',
  '\\sinh',
  '\\sh',
  '\\tan',
  '\\tanh',
  '\\tg',
  '\\th',
];

TexGreen _mathFunctionHandler(final TexParser parser, final FunctionContext context) => _parseMathFunction(
      stringToNode(context.funcName.substring(1), TexMode.text),
      parser,
      context,
      defaultLimits: false,
    );

const mathLimits = [
  '\\det',
  '\\gcd',
  '\\inf',
  '\\lim',
  '\\max',
  '\\min',
  '\\Pr',
  '\\sup',
];

TexGreen _mathLimitsHandler(final TexParser parser, final FunctionContext context) => _parseMathFunction(
      stringToNode(context.funcName.substring(1), TexMode.text),
      parser,
      context,
      defaultLimits: true,
    );

const singleCharIntegrals = {
  '\u222b': '\\int',
  '\u222c': '\\iint',
  '\u222d': '\\iiint',
  '\u222e': '\\oint',
  '\u222f': '\\oiint',
  '\u2230': '\\oiiint',
};

TexGreen _integralHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  return _parseNaryOperator(
    () {
      if (context.funcName.length == 1) {
        return singleCharIntegrals[context.funcName]!;
      } else {
        return context.funcName;
      }
    }(),
    parser,
    context,
  );
}

const _operatorNameEntries = {
  ['\\operatorname', '\\operatorname*']: FunctionSpec(numArgs: 1, handler: _operatorNameHandler),
};

TexGreen _operatorNameHandler(final TexParser parser, final FunctionContext context) {
  TexGreen name = parser.parseArgNode(mode: null, optional: false)!;
  final scripts = parser.parseScripts(allowLimits: context.funcName == '\\operatorname*');
  final body =
      parser.parseGroup(context.funcName, optional: false, greediness: 1, mode: null, consumeSpaces: true) ??
          emptyEquationRowNode();
  name = TexGreenStyleImpl(
    children: greenNodeExpandEquationRow(name),
    optionsDiff: TexOptionsDiffImpl(
      mathFontOptions: texMathFontOptions['\\mathrm'],
    ),
  );
  if (!scripts.empty) {
    if (scripts.limits == true) {
      if (scripts.superscript != null) {
        name = TexGreenOverImpl(
          base: greenNodeWrapWithEquationRow(
            name,
          ),
          above: scripts.superscript!,
        );
      }
      if (scripts.subscript != null) {
        name = TexGreenUnderImpl(
          base: greenNodeWrapWithEquationRow(
            name,
          ),
          below: scripts.subscript!,
        );
      }
    } else {
      name = TexGreenMultiscriptsImpl(
        base: greenNodeWrapWithEquationRow(
          name,
        ),
        sub: scripts.subscript,
        sup: scripts.superscript,
      );
    }
  }

  return TexGreenFunctionImpl(
    functionName: greenNodeWrapWithEquationRow(
      name,
    ),
    argument: greenNodeWrapWithEquationRow(
      body,
    ),
  );
}

const _phantomEntries = {
  ['\\phantom', '\\hphantom', '\\vphantom']:
      FunctionSpec(numArgs: 1, allowedInText: true, handler: _phantomHandler),
};

TexGreen _phantomHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final body = parser.parseArgNode(mode: null, optional: false)!;
  return TexGreenPhantomImpl(
    phantomChild: greenNodeWrapWithEquationRow(
      body,
    ),
    zeroHeight: context.funcName == '\\hphantom',
    zeroDepth: context.funcName == '\\hphantom',
    zeroWidth: context.funcName == '\\vphantom',
  );
}

const _raiseBoxEntries = {
  ['\\raisebox']: FunctionSpec(numArgs: 2, allowedInText: true, handler: _raiseBoxHandler),
};

TexGreen _raiseBoxHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final dy = parser.parseArgSize(optional: false) ?? zeroPt;
  final body = parser.parseArgHbox(optional: false);
  return TexGreenRaiseboxImpl(
    body: greenNodeWrapWithEquationRow(
      body,
    ),
    dy: dy,
  );
}

const _ruleEntries = {
  ['\\rule']: FunctionSpec(numArgs: 2, numOptionalArgs: 1, handler: _ruleHandler),
};

TexGreen _ruleHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final shift = parser.parseArgSize(optional: true) ?? zeroPt;
  final width = parser.parseArgSize(optional: false) ?? zeroPt;
  final height = parser.parseArgSize(optional: false) ?? zeroPt;
  return TexGreenSpaceImpl(
    height: height,
    width: width,
    shift: shift,
    fill: true,
    // background: Colors.black,
    mode: TexMode.math,
  );
}

const _sizeFuncs = [
  '\\tiny',
  '\\sixptsize',
  '\\scriptsize',
  '\\footnotesize',
  '\\small',
  '\\normalsize',
  '\\large',
  '\\Large',
  '\\LARGE',
  '\\huge',
  '\\Huge',
];

const _sizingEntries = {
  _sizeFuncs: FunctionSpec(
    numArgs: 0,
    allowedInText: true,
    handler: _sizingHandler,
  ),
};

TexGreen _sizingHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final body = parser.parseExpression(breakOnInfix: false, breakOnTokenText: context.breakOnTokenText);
  return TexGreenStyleImpl(
    children: body,
    optionsDiff: TexOptionsDiffImpl(
      size: TexMathSize.values[_sizeFuncs.indexOf(context.funcName)],
    ),
  );
}

const _sqrtEntries = {
  ['\\sqrt']: FunctionSpec(
    numArgs: 1,
    numOptionalArgs: 1,
    handler: _sqrtHandler,
  ),
};

TexGreen _sqrtHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final index = parser.parseArgNode(
    mode: null,
    optional: true,
  );
  final body = parser.parseArgNode(
    mode: null,
    optional: false,
  )!;
  return TexGreenSqrtImpl(
    index: greenNodeWrapWithEquationRowOrNull(
      index,
    ),
    base: greenNodeWrapWithEquationRow(
      body,
    ),
  );
}

const _stylingEntries = {
  [
    '\\displaystyle',
    '\\textstyle',
    '\\scriptstyle',
    '\\scriptscriptstyle',
  ]: FunctionSpec(
    numArgs: 0,
    allowedInText: true,
    handler: _stylingHandler,
  ),
};

TexGreen _stylingHandler(final TexParser parser, final FunctionContext context) {
  final body = parser.parseExpression(breakOnInfix: true, breakOnTokenText: context.breakOnTokenText);
  final style = parseMathStyle(context.funcName.substring(1, context.funcName.length - 5));
  return TexGreenStyleImpl(
    children: body,
    optionsDiff: TexOptionsDiffImpl(
      style: style,
    ),
  );
}

const _textEntries = {
  [
    // Font families
    '\\text', '\\textrm', '\\textsf', '\\texttt', '\\textnormal',
    // Font weights
    '\\textbf', '\\textmd',
    // Font Shapes
    '\\textit', '\\textup',
  ]: FunctionSpec(
    numArgs: 1,
    greediness: 2,
    allowedInText: true,
    handler: _textHandler,
  )
};

TexGreen _textHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final body = parser.parseArgNode(mode: TexMode.text, optional: false)!;
  final fontOptions = texTextFontOptions[context.funcName];
  if (fontOptions == null) return body;
  return TexGreenStyleImpl(
    optionsDiff: TexOptionsDiffImpl(
      textFontOptions: fontOptions,
    ),
    children: greenNodeExpandEquationRow(body),
  );
}

const _underOverEntries = {
  ['\\stackrel', '\\overset', '\\underset']: FunctionSpec(
    numArgs: 2,
    handler: _underOverHandler,
  )
};

TexGreen _underOverHandler(final TexParser parser, final FunctionContext context) {
  final shiftedArg = parser.parseArgNode(mode: null, optional: false)!;
  final baseArg = parser.parseArgNode(mode: null, optional: false)!;
  if (context.funcName == '\\underset') {
    return TexGreenUnderImpl(
      base: greenNodeWrapWithEquationRow(
        baseArg,
      ),
      below: greenNodeWrapWithEquationRow(
        shiftedArg,
      ),
    );
  } else {
    return TexGreenOverImpl(
      base: greenNodeWrapWithEquationRow(
        baseArg,
      ),
      above: greenNodeWrapWithEquationRow(
        shiftedArg,
      ),
      stackRel: context.funcName == '\\stackrel',
    );
  }
}

const Map<List<String>, FunctionSpec<TexGreen>> katexExtFunctionEntries = {
  ..._notEntries,
};

const _notEntries = {
  [
    '\\not',
  ]: FunctionSpec(numArgs: 1, handler: _notHandler)
};

const _notRemap = {
  '\u2190': '\u219A',
  '\u2192': '\u219B',
  '\u2194': '\u21AE',
  '\u21D0': '\u21CD',
  '\u21D2': '\u21CF',
  '\u21D4': '\u21CE',
  '\u2208': '\u2209',
  '\u220B': '\u220C',
  '\u2223': '\u2224',
  '\u2225': '\u2226',
  '\u223C': '\u2241',
  '\u007E': '\u2241',
  '\u2243': '\u2244',
  '\u2245': '\u2247',
  '\u2248': '\u2249',
  '\u224D': '\u226D',
  '\u003D': '\u2260',
  '\u2261': '\u2262',
  '\u003C': '\u226E',
  '\u003E': '\u226F',
  '\u2264': '\u2270',
  '\u2265': '\u2271',
  '\u2272': '\u2274',
  '\u2273': '\u2275',
  '\u2276': '\u2278',
  '\u2277': '\u2279',
  '\u227A': '\u2280',
  '\u227B': '\u2281',
  '\u2282': '\u2284',
  '\u2283': '\u2285',
  '\u2286': '\u2288',
  '\u2287': '\u2289',
  '\u22A2': '\u22AC',
  '\u22A8': '\u22AD',
  '\u22A9': '\u22AE',
  '\u22AB': '\u22AF',
  '\u227C': '\u22E0',
  '\u227D': '\u22E1',
  '\u2291': '\u22E2',
  '\u2292': '\u22E3',
  '\u22B2': '\u22EA',
  '\u22B3': '\u22EB',
  '\u22B4': '\u22EC',
  '\u22B5': '\u22ED',
  '\u2203': '\u2204'
};

TexGreen _notHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final base = parser.parseArgNode(
    mode: null,
    optional: false,
  )!;
  final node = assertNodeType<TexGreenSymbol>(base);
  final remappedSymbol = _notRemap[node.symbol];
  if (node.mode != TexMode.math || node.variantForm == true || remappedSymbol == null) {
    throw ParseException('\\not has to be followed by a combinable character');
  }
  return node.withSymbol(
    remappedSymbol,
  );
}

const Map<List<String>, FunctionSpec<TexGreen>> cursorEntries = {
  [
    '\\cursor',
  ]: FunctionSpec(
    numArgs: 1,
    handler: _cursorHandler,
  )
};

TexGreen _cursorHandler(
  final TexParser parser,
  final FunctionContext context,
) =>
    TexGreenCursorImpl();

/// Converted from KaTeX/src/katex.less

// Map<String, FontOptions> _fontOptionsTable;
// Map<String, FontOptions> get fontOptionsTable {
//   if (_fontOptionsTable != null) return _fontOptionsTable;
//   _fontOptionsTable = {};
//   _fontOptionsEntries.forEach((key, value) {
//     for (final name in key) {
//       _fontOptionsTable[name] = value;
//     }
//   });
//   return _fontOptionsTable;
// }

// const _fontOptionsEntries = {
//   // Text font weights.
//   ['textbf']: FontOptionsImpl(
//     fontWeight: FontWeight.bold,
//   ),

//   // Text font shapes.
//   ['textit']: FontOptionsImpl(
//     fontShape: FontStyle.italic,
//   ),

//   // Text font families.
//   ['textrm']: FontOptionsImpl(fontFamily: 'Main'),

//   ['textsf']: FontOptionsImpl(fontFamily: 'SansSerif'),

//   ['texttt']: FontOptionsImpl(fontFamily: 'Typewriter'),

//   // Math fonts.
//   ['mathdefault']: FontOptionsImpl(
//     fontFamily: 'Math',
//     fontShape: FontStyle.italic,
//   ),

//   ['mathit']: FontOptionsImpl(
//     fontFamily: 'Main',
//     fontShape: FontStyle.italic,
//   ),

//   ['mathrm']: FontOptionsImpl(
//     fontFamily: 'Main',
//     fontShape: FontStyle.normal,
//   ),

//   ['mathbf']: FontOptionsImpl(
//     fontFamily: 'Main',
//     fontWeight: FontWeight.bold,
//   ),

//   ['boldsymbol']: FontOptionsImpl(
//     fontFamily: 'Math',
//     fontWeight: FontWeight.bold,
//     fontShape: FontStyle.italic,
//     fallback: [
//       FontOptionsImpl(
//         fontFamily: 'Math',
//         fontWeight: FontWeight.bold,
//       )
//     ],
//   ),

//   ['amsrm']: FontOptionsImpl(fontFamily: 'AMS'),

//   ['mathbb', 'textbb']: FontOptionsImpl(fontFamily: 'AMS'),

//   ['mathcal']: FontOptionsImpl(fontFamily: 'Caligraphic'),

//   ['mathfrak', 'textfrak']: FontOptionsImpl(fontFamily: 'Fraktur'),

//   ['mathtt']: FontOptionsImpl(fontFamily: 'Typewriter'),

//   ['mathscr', 'textscr']: FontOptionsImpl(fontFamily: 'Script'),

//   ['mathsf', 'textsf']: FontOptionsImpl(fontFamily: 'SansSerif'),

//   ['mathboldsf', 'textboldsf']: FontOptionsImpl(
//     fontFamily: 'SansSerif',
//     fontWeight: FontWeight.bold,
//   ),

//   ['mathitsf', 'textitsf']: FontOptionsImpl(
//     fontFamily: 'SansSerif',
//     fontShape: FontStyle.italic,
//   ),

//   ['mainrm']: FontOptionsImpl(
//     fontFamily: 'Main',
//     fontShape: FontStyle.normal,
//   ),
// };

// const fontFamilyFallback = ['Main', 'Times New Roman', 'serif'];

const texMathFontOptions = {
  // Math fonts.
  // 'mathdefault': FontOptionsImpl(
  //   fontFamily: 'Math',
  //   fontShape: FontStyle.italic,
  // ),

  '\\mathit': TexFontOptionsImpl(
    fontFamily: 'Main',
    fontShape: TexFontStyle.italic,
  ),

  '\\mathrm': TexFontOptionsImpl(
    fontFamily: 'Main',
    fontShape: TexFontStyle.normal,
  ),

  '\\mathbf': TexFontOptionsImpl(
    fontFamily: 'Main',
    fontWeight: TexFontWeight.w700,
  ),

  '\\boldsymbol': TexFontOptionsImpl(
    fontFamily: 'Math',
    fontWeight: TexFontWeight.w700,
    fontShape: TexFontStyle.italic,
    fallback: [
      TexFontOptionsImpl(
        fontFamily: 'Math',
        fontWeight: TexFontWeight.w700,
      )
    ],
  ),

  '\\mathbb': TexFontOptionsImpl(fontFamily: 'AMS'),

  '\\mathcal': TexFontOptionsImpl(fontFamily: 'Caligraphic'),

  '\\mathfrak': TexFontOptionsImpl(fontFamily: 'Fraktur'),

  '\\mathtt': TexFontOptionsImpl(fontFamily: 'Typewriter'),

  '\\mathscr': TexFontOptionsImpl(fontFamily: 'Script'),

  '\\mathsf': TexFontOptionsImpl(fontFamily: 'SansSerif'),
};

const texTextFontOptions = {
  '\\textrm': TexPartialFontOptionsImpl(
    fontFamily: 'Main',
  ),
  '\\textsf': TexPartialFontOptionsImpl(
    fontFamily: 'SansSerif',
  ),
  '\\texttt': TexPartialFontOptionsImpl(
    fontFamily: 'Typewriter',
  ),
  '\\textnormal': TexPartialFontOptionsImpl(
    fontFamily: 'Main',
  ),
  '\\textbf': TexPartialFontOptionsImpl(
    fontWeight: TexFontWeight.w700,
  ),
  '\\textmd': TexPartialFontOptionsImpl(
    fontWeight: TexFontWeight.w400,
  ),
  '\\textit': TexPartialFontOptionsImpl(
    fontShape: TexFontStyle.italic,
  ),
  '\\textup': TexPartialFontOptionsImpl(
    fontShape: TexFontStyle.normal,
  ),
};
