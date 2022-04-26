import '../../../ast/ast.dart';

import '../../../ast/options.dart';
import '../../../ast/size.dart';
import '../../../ast/style.dart';
import '../../../ast/types.dart';
import '../define_environment.dart';
import '../font.dart';
import '../functions.dart';
import '../parse_error.dart';
import '../parser.dart';
import '../symbols.dart';

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

GreenNode _accentHandler(final TexParser parser, final FunctionContext context) {
  final base = parser.parseArgNode(mode: Mode.math, optional: false)!;

  final isStretchy = !nonStretchyAccents.contains(context.funcName);
  final isShifty = !isStretchy || shiftyAccents.contains(context.funcName);

  return AccentNode(
    base: base.wrapWithEquationRow(),
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

GreenNode _textAccentHandler(final TexParser parser, final FunctionContext context) {
  final base = parser.parseArgNode(mode: null, optional: false)!;
  if (base is SymbolNode) {
    return base.withSymbol(
      base.symbol + textUnicodeAccentMapping[context.funcName]!,
    );
  }
  if (base is EquationRowNode && base.children.length == 1) {
    final node = base.children[0];
    if (node is SymbolNode) {
      return node.withSymbol(
        node.symbol + textUnicodeAccentMapping[context.funcName]!,
      );
    }
  }
  return AccentNode(
    base: base.wrapWithEquationRow(),
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

GreenNode _accentUnderHandler(final TexParser parser, final FunctionContext context) {
  final base = parser.parseArgNode(mode: null, optional: false)!;
  return AccentUnderNode(
    base: base.wrapWithEquationRow(),
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

GreenNode _throwExceptionHandler(final TexParser parser, final FunctionContext context) {
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

GreenNode _arrowHandler(final TexParser parser, final FunctionContext context) {
  final below = parser.parseArgNode(mode: null, optional: true);
  final above = parser.parseArgNode(mode: null, optional: false)!;
  return StretchyOpNode(
    above: above.wrapWithEquationRow(),
    below: below?.wrapWithEquationRow(),
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

GreenNode _breakHandler(
  final TexParser parser,
  final FunctionContext context,
) =>
    SpaceNode(
      height: Measurement.zero,
      width: Measurement.zero,
      breakPenalty: context.funcName == '\\nobreak' ? 10000 : 0,
      // noBreak: context.funcName == '\\nobreak',
      mode: parser.mode,
    );

const _charEntries = {
  ['\\@char']: FunctionSpec(numArgs: 1, allowedInText: true, handler: _charHandler),
};

GreenNode _charHandler(final TexParser parser, final FunctionContext context) {
  final arg = assertNodeType<EquationRowNode>(parser.parseArgNode(mode: null, optional: false));
  final number = arg.children.map((final child) => assertNodeType<SymbolNode>(child).symbol).join('');
  final code = int.tryParse(number);
  if (code == null) {
    throw ParseException('\\@char has non-numeric argument $number');
  }
  return SymbolNode(
    symbol: String.fromCharCode(code),
    mode: parser.mode,
    overrideAtomType: AtomType.ord,
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

GreenNode _textcolorHandler(final TexParser parser, final FunctionContext context) {
  final color = parser.parseArgColor(optional: false)!;
  final body = parser.parseArgNode(mode: null, optional: false)!;
  return StyleNode(
    optionsDiff: OptionsDiff(color: color),
    children: body.expandEquationRow(),
  );
}

GreenNode _colorHandler(final TexParser parser, final FunctionContext context) {
  final color = parser.parseArgColor(optional: false);

  final body = parser.parseExpression(breakOnInfix: true, breakOnTokenText: context.breakOnTokenText);
  return StyleNode(
    optionsDiff: OptionsDiff(color: color),
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

class CrNode extends TemporaryNode {
  final bool newLine;
  final bool newRow;
  final Measurement? size;

  CrNode({
    required final this.newLine,
    required final this.newRow,
    final this.size,
  });
}

GreenNode _crHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final size = parser.parseArgSize(optional: true);
  final newRow = context.funcName == '\\cr';
  var newLine = false;
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
  return CrNode(newLine: newLine, newRow: newRow, size: size);
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
  '\\bigl': AtomType.open,
  '\\Bigl': AtomType.open,
  '\\biggl': AtomType.open,
  '\\Biggl': AtomType.open,
  '\\bigr': AtomType.close,
  '\\Bigr': AtomType.close,
  '\\biggr': AtomType.close,
  '\\Biggr': AtomType.close,
  '\\bigm': AtomType.rel,
  '\\Bigm': AtomType.rel,
  '\\biggm': AtomType.rel,
  '\\Biggm': AtomType.rel,
  '\\big': AtomType.ord,
  '\\Big': AtomType.ord,
  '\\bigg': AtomType.ord,
  '\\Bigg': AtomType.ord,
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
    .map((final command) => texSymbolCommandConfigs[Mode.math]![command]!)
    .toList(growable: false);

String? _checkDelimiter(final GreenNode delim, final FunctionContext context) {
  if (delim is SymbolNode) {
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

GreenNode _delimSizeHandler(final TexParser parser, final FunctionContext context) {
  final delimArg = parser.parseArgNode(mode: Mode.math, optional: false)!;
  final delim = _checkDelimiter(delimArg, context);
  return delim == null
      ? SpaceNode(height: Measurement.zero, width: Measurement.zero, mode: Mode.math)
      : SymbolNode(
          symbol: delim,
          overrideAtomType: _delimiterTypes[context.funcName],
          overrideFont: FontOptions(fontFamily: 'Size${_delimiterSizes[context.funcName]}'),
        );
}

class _LeftRightRightNode extends TemporaryNode {
  final String? delim;

  _LeftRightRightNode({
    final this.delim,
  });
}

/// KaTeX's \color command will affect the right delimiter.
/// MathJax's \color command will not affect the right delimiter.
/// Here we choose to follow MathJax's behavior because it fits out AST design
/// better. KaTeX's solution is messy.
GreenNode _rightHandler(final TexParser parser, final FunctionContext context) {
  final delimArg = parser.parseArgNode(mode: Mode.math, optional: false)!;
  return _LeftRightRightNode(
    delim: _checkDelimiter(delimArg, context),
  );
}

GreenNode _leftHandler(final TexParser parser, final FunctionContext context) {
  final leftArg = parser.parseArgNode(mode: Mode.math, optional: false)!;
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
  final right = assertNodeType<_LeftRightRightNode>(rightArg);

  final splittedBody = [<GreenNode>[]];
  final middles = <String?>[];
  for (final element in body) {
    if (element is _MiddleNode) {
      splittedBody.add([]);
      middles.add(element.delim == '.' ? null : element.delim);
    } else {
      splittedBody.last.add(element);
    }
  }
  return LeftRightNode(
    leftDelim: delim == '.' ? null : delim,
    rightDelim: right.delim == '.' ? null : right.delim,
    body: splittedBody.map((final part) => part.wrapWithEquationRow()).toList(growable: false),
    middle: middles,
  );
}

class _MiddleNode extends TemporaryNode {
  final String? delim;

  _MiddleNode({
    final this.delim,
  });
}

/// Middle can only appear directly between \left and \right. Wrapping \middle
/// will cause error. This is in accordance with MathJax and different from
/// KaTeX, and is more compatible with our AST structure.
GreenNode _middleHandler(final TexParser parser, final FunctionContext context) {
  final delimArg = parser.parseArgNode(mode: Mode.math, optional: false)!;
  final delim = _checkDelimiter(delimArg, context);
  if (parser.leftrightDepth <= 0) {
    throw ParseException('\\middle without preceding \\left');
  }
  final contexts = parser.argParsingContexts.toList(growable: false);
  final lastContext = contexts[contexts.length - 2];
  if (lastContext.funcName != '\\left') {
    throw ParseException('\\middle must be within \\left and \\right');
  }

  return _MiddleNode(delim: delim);
}

const _encloseEntries = {
  ['\\colorbox']: FunctionSpec(numArgs: 2, allowedInText: true, greediness: 3, handler: _colorboxHandler),
  ['\\fcolorbox']: FunctionSpec(numArgs: 3, allowedInText: true, greediness: 3, handler: _fcolorboxHandler),
  ['\\fbox']: FunctionSpec(numArgs: 1, allowedInText: true, handler: _fboxHandler),
  ['\\cancel', '\\bcancel', '\\xcancel', '\\sout']: FunctionSpec(numArgs: 1, handler: _cancelHandler),
};

GreenNode _colorboxHandler(final TexParser parser, final FunctionContext context) {
  final color = parser.parseArgColor(optional: false);
  final body = parser.parseArgNode(mode: Mode.text, optional: false)!;
  return EnclosureNode(
    backgroundcolor: color,
    base: body.wrapWithEquationRow(),
    hasBorder: false,
    // FontMetrics.fboxsep
    verticalPadding: 0.3.cssEm,
    // katex.less/.boxpad
    horizontalPadding: 0.3.cssEm,
  );
}

GreenNode _fcolorboxHandler(final TexParser parser, final FunctionContext context) {
  final borderColor = parser.parseArgColor(optional: false)!;
  final color = parser.parseArgColor(optional: false)!;
  final body = parser.parseArgNode(mode: Mode.text, optional: false)!;
  return EnclosureNode(
    hasBorder: true,
    bordercolor: borderColor,
    backgroundcolor: color,
    base: body.wrapWithEquationRow(),
    // FontMetrics.fboxsep
    verticalPadding: 0.3.cssEm,
    // katex.less/.boxpad
    horizontalPadding: 0.3.cssEm,
  );
}

GreenNode _fboxHandler(final TexParser parser, final FunctionContext context) {
  final body = parser.parseArgHbox(optional: false);
  return EnclosureNode(
    hasBorder: true,
    base: body.wrapWithEquationRow(),
    // FontMetrics.fboxsep
    verticalPadding: 0.3.cssEm,
    // katex.less/.boxpad
    horizontalPadding: 0.3.cssEm,
  );
}

GreenNode _cancelHandler(final TexParser parser, final FunctionContext context) {
  final body = parser.parseArgNode(mode: null, optional: false)!;
  return EnclosureNode(
    notation: const {
      '\\cancel': ['updiagonalstrike'],
      '\\bcancel': ['downdiagonalstrike'],
      '\\xcancel': ['updiagonalstrike, downdiagonalstrike'],
      '\\sout': ['horizontalstrike'],
    }[context.funcName]!,
    hasBorder: false,
    base: body.wrapWithEquationRow(),
    // KaTeX/src/functions/enclose.js line 59
    // KaTeX will remove this padding if base is not single char. We won't, as
    // MathJax neither.
    verticalPadding: 0.2.cssEm,
    // katex.less/.cancel-pad
    // KaTeX failed to apply this value, but we will, as MathJax had
    horizontalPadding: 0.2.cssEm,
  );
}

const _environmentEntries = {
  ['\\begin', '\\end']: FunctionSpec(numArgs: 1, handler: _enviromentHandler)
};

GreenNode _enviromentHandler(final TexParser parser, final FunctionContext context) {
  final nameGroup = parser.parseArgNode(mode: Mode.text, optional: false)!;
  if (nameGroup.children.any((final element) => element is! SymbolNode)) {
    throw ParseException('Invalid environment name');
  }
  final envName = nameGroup.children.map((final node) => (node as SymbolNode?)!.symbol).join();

  if (context.funcName == '\\begin') {
    // begin...end is similar to left...right
    if (!environments.containsKey(envName)) {
      throw ParseException('No such environment: $envName');
    }
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
    final end = assertNodeType<_EndEnvironmentNode>(parser.parseFunction(null, null, null));
    if (end.name != envName) {
      throw ParseException('Mismatch: \\begin{$envName} matched by \\end{${end.name}}', endNameToken);
    }
    return result;
  } else {
    return _EndEnvironmentNode(
      name: envName,
    );
  }
}

class _EndEnvironmentNode extends TemporaryNode {
  final String name;

  _EndEnvironmentNode({
    required final this.name,
  });
}

const _fontEntries = {
  [
    // styles, except \boldsymbol defined below
    '\\mathrm', '\\mathit', '\\mathbf', //'\\mathnormal',

    // families
    '\\mathbb', '\\mathcal', '\\mathfrak', '\\mathscr', '\\mathsf',
    '\\mathtt',

    // aliases, except \bm defined below
    '\\Bbb', '\\bold', '\\frak',
  ]: FunctionSpec(numArgs: 1, greediness: 2, handler: _fontHandler),
  ['\\boldsymbol', '\\bm']: FunctionSpec(numArgs: 1, greediness: 2, handler: _boldSymbolHandler),
  ['\\rm', '\\sf', '\\tt', '\\bf', '\\it', '\\cal']:
      FunctionSpec(numArgs: 0, allowedInText: true, handler: _textFontHandler),
};
const fontAliases = {
  '\\Bbb': '\\mathbb',
  '\\bold': '\\mathbf',
  '\\frak': '\\mathfrak',
  '\\bm': '\\boldsymbol',
};

GreenNode _fontHandler(final TexParser parser, final FunctionContext context) {
  final body = parser.parseArgNode(mode: null, optional: false)!;
  final func = fontAliases.containsKey(context.funcName) ? fontAliases[context.funcName] : context.funcName;
  return StyleNode(
    children: body.expandEquationRow(),
    optionsDiff: OptionsDiff(
      mathFontOptions: texMathFontOptions[func],
    ),
  );
}

GreenNode _boldSymbolHandler(final TexParser parser, final FunctionContext context) {
  final body = parser.parseArgNode(mode: null, optional: false)!;
  // TODO
  // amsbsy.sty's \boldsymbol uses \binrel spacing to inherit the
  // argument's bin|rel|ord status
  return StyleNode(
    children: body.expandEquationRow(),
    optionsDiff: OptionsDiff(
      mathFontOptions: texMathFontOptions['\\boldsymbol'],
    ),
  );
}

GreenNode _textFontHandler(final TexParser parser, final FunctionContext context) {
  final body = parser.parseExpression(breakOnInfix: true, breakOnTokenText: context.breakOnTokenText);
  final style = '\\math${context.funcName.substring(1)}';

  return StyleNode(
    children: body,
    optionsDiff: OptionsDiff(
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
  ]: FunctionSpec<GreenNode>(
    numArgs: 2,
    greediness: 2,
    handler: _fracHandler,
  ),

  // Infix generalized fractions -- these are not rendered directly, but
  // replaced immediately by one of the variants above.
  ['\\over', '\\choose', '\\atop', '\\brace', '\\brack']: FunctionSpec<GreenNode>(
    numArgs: 0,
    infix: true,
    handler: _overHandler,
  ),

  ['\\genfrac']: FunctionSpec<GreenNode>(
    numArgs: 6,
    greediness: 6,
    handler: _genfracHandler,
  ),

  // \above is an infix fraction that also defines a fraction bar size.
  ['\\above']: FunctionSpec<GreenNode>(
    numArgs: 1,
    infix: true,
    handler: _aboveHandler,
  ),

  ['\\\\abovefrac']: FunctionSpec(
    numArgs: 3,
    handler: _aboveFracHandler,
  ),
};

GreenNode _fracHandler(final TexParser parser, final FunctionContext context) {
  final numer = parser.parseArgNode(mode: null, optional: false)!;
  final denom = parser.parseArgNode(mode: null, optional: false)!;
  return _internalFracHandler(
    funcName: context.funcName,
    numer: numer.wrapWithEquationRow(),
    denom: denom.wrapWithEquationRow(),
  );
}

GreenNode _internalFracHandler({
  required final String funcName,
  required final EquationRowNode numer,
  required final EquationRowNode denom,
}) {
  bool hasBarLine;
  String? leftDelim;
  String? rightDelim;
  MathStyle? size;

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
      size = MathStyle.display;
      break;
    case '\\tfrac':
    case '\\tbinom':
      size = MathStyle.text;
      break;
  }
  GreenNode res = FracNode(
    numerator: numer,
    denominator: denom,
    barSize: hasBarLine ? null : Measurement.zero,
    continued: funcName == '\\cfrac',
  );
  if (leftDelim != null || rightDelim != null) {
    res = LeftRightNode(
      body: [res.wrapWithEquationRow()],
      leftDelim: leftDelim,
      rightDelim: rightDelim,
    );
  }
  if (size != null) {
    res = StyleNode(
      children: [res],
      optionsDiff: OptionsDiff(style: size),
    );
  }
  return res;
}

GreenNode _overHandler(final TexParser parser, final FunctionContext context) {
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
    numer: numerBody.wrapWithEquationRow(),
    denom: denomBody.wrapWithEquationRow(),
  );
}

GreenNode _genfracHandler(final TexParser parser, final FunctionContext context) {
  final leftDelimArg = parser.parseArgNode(mode: Mode.math, optional: false)!;
  final rightDelimArg = parser.parseArgNode(mode: Mode.math, optional: false)!;
  final barSize = parser.parseArgSize(optional: false)!;
  final styleArg = parser.parseArgNode(mode: Mode.text, optional: false)!;
  final numer = parser.parseArgNode(mode: Mode.math, optional: false)!;
  final denom = parser.parseArgNode(mode: Mode.math, optional: false)!;
  final leftDelimNode = leftDelimArg is EquationRowNode
      ? leftDelimArg.children.length == 1
          ? leftDelimArg.children.first
          : null
      : leftDelimArg;
  final rightDelimNode = rightDelimArg is EquationRowNode
      ? rightDelimArg.children.length == 1
          ? rightDelimArg.children.first
          : null
      : rightDelimArg;
  final leftDelim =
      (leftDelimNode is SymbolNode && leftDelimNode.atomType == AtomType.open) ? leftDelimNode.symbol : null;
  final rightDelim = (rightDelimNode is SymbolNode && rightDelimNode.atomType == AtomType.close)
      ? rightDelimNode.symbol
      : null;
  int? style;
  if (styleArg.expandEquationRow().isNotEmpty) {
    final textOrd = assertNodeType<SymbolNode>(styleArg.expandEquationRow()[0]);
    style = int.tryParse(textOrd.symbol);
  }
  GreenNode res = FracNode(
    numerator: numer.wrapWithEquationRow(),
    denominator: denom.wrapWithEquationRow(),
    barSize: barSize,
  );
  if (leftDelim != null || rightDelim != null) {
    res = LeftRightNode(
      body: [res.wrapWithEquationRow()],
      leftDelim: leftDelim,
      rightDelim: rightDelim,
    );
  }
  if (style != null) {
    res = StyleNode(
      children: [res],
      optionsDiff: OptionsDiff(style: style.toMathStyle()),
    );
  }
  return res;
}

GreenNode _aboveHandler(final TexParser parser, final FunctionContext context) {
  final numerBody = context.infixExistingArguments;
  final barSize = parser.parseArgSize(optional: false);
  final denomBody = parser.parseExpression(
    breakOnTokenText: context.breakOnTokenText,
    infixArgumentMode: true,
  );
  return FracNode(
    numerator: numerBody.wrapWithEquationRow(),
    denominator: denomBody.wrapWithEquationRow(),
    barSize: barSize,
  );
}

GreenNode _aboveFracHandler(final TexParser parser, final FunctionContext context) {
  final numer = parser.parseArgNode(mode: Mode.math, optional: false)!;
  final barSize = parser.parseArgSize(optional: false)!;
  final denom = parser.parseArgNode(mode: Mode.math, optional: false)!;

  return FracNode(
    numerator: numer.wrapWithEquationRow(),
    denominator: denom.wrapWithEquationRow(),
    barSize: barSize,
  );
}

const _horizBraceEntries = {
  ['\\overbrace', '\\underbrace']: FunctionSpec(numArgs: 1, handler: _horizBraceHandler),
};

GreenNode _horizBraceHandler(final TexParser parser, final FunctionContext context) {
  final base = parser.parseArgNode(mode: null, optional: false)!;
  final scripts = parser.parseScripts();
  var res = base;
  if (context.funcName == '\\overbrace') {
    res = AccentNode(
      base: res.wrapWithEquationRow(),
      label: '\u23de',
      isStretchy: true,
      isShifty: false,
    );
    if (scripts.superscript != null) {
      res = OverNode(
        base: res.wrapWithEquationRow(),
        above: scripts.superscript!,
      );
    }
    if (scripts.subscript != null) {
      res = UnderNode(
        base: res.wrapWithEquationRow(),
        below: scripts.subscript!,
      );
    }
    return res;
  } else {
    res = AccentUnderNode(
      base: res.wrapWithEquationRow(),
      label: '\u23df',
    );
    if (scripts.subscript != null) {
      res = UnderNode(
        base: res.wrapWithEquationRow(),
        below: scripts.subscript!,
      );
    }
    if (scripts.superscript != null) {
      res = OverNode(
        base: res.wrapWithEquationRow(),
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

GreenNode _kernHandler(final TexParser parser, final FunctionContext context) {
  final size = parser.parseArgSize(optional: false) ?? Measurement.zero;

  final mathFunction = context.funcName[1] == 'm';
  final muUnit = size.unit == Unit.mu;
  if (mathFunction) {
    if (!muUnit) {
      parser.settings.reportNonstrict(
          'mathVsTextUnits',
          "LaTeX's ${context.funcName} supports only mu units, "
              'not ${size.unit} units');
    }
    if (parser.mode != Mode.math) {
      parser.settings
          .reportNonstrict('mathVsTextUnits', "LaTeX's ${context.funcName} works only in math mode");
    }
  } else {
    if (muUnit) {
      parser.settings
          .reportNonstrict('mathVsTextUnits', "LaTeX's ${context.funcName} doesn't support mu units");
    }
  }

  return SpaceNode(
    height: Measurement.zero,
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

GreenNode _mathLeftHandler(
  final TexParser parser,
  final FunctionContext context,
) {
  final outerMode = parser.mode;
  parser.switchMode(Mode.math);
  final close = context.funcName == '\\(' ? '\\)' : '\$';
  final body = parser.parseExpression(breakOnInfix: false, breakOnTokenText: close);

  parser.expect(close);
  parser.switchMode(outerMode);

  return StyleNode(
    optionsDiff: const OptionsDiff(
      style: MathStyle.text,
    ),
    children: body,
  );
}

GreenNode _mathRightHandler(
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

GreenNode _mclassHandler(final TexParser parser, final FunctionContext context) {
  final body = parser.parseArgNode(mode: null, optional: false)!;
  return EquationRowNode(
      children: body.expandEquationRow(),
      overrideType: const {
        '\\mathop': AtomType.op,
        '\\mathord': AtomType.ord,
        '\\mathbin': AtomType.bin,
        '\\mathrel': AtomType.rel,
        '\\mathopen': AtomType.open,
        '\\mathclose': AtomType.close,
        '\\mathpunct': AtomType.punct,
        '\\mathinner': AtomType.inner,
      }[context.funcName]);
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

NaryOperatorNode _parseNaryOperator(
  final String command,
  final TexParser parser,
  final FunctionContext context,
) {
  final scriptsResult = parser.parseScripts(allowLimits: true);
  final arg = parser.parseAtom(context.breakOnTokenText)?.wrapWithEquationRow();

  return NaryOperatorNode(
    operator: texSymbolCommandConfigs[Mode.math]![command]!.symbol,
    lowerLimit: scriptsResult.subscript,
    upperLimit: scriptsResult.superscript,
    naryand: arg ?? EquationRowNode.empty(),
    limits: scriptsResult.limits,
    allowLargeOp: command == '\\smallint' ? false : true,
  );
}

///This behavior is in accordance with UnicodeMath, and is different from KaTeX.
///Math functions' default limits behavior is fixed on creation and will NOT
///change form according to style.
FunctionNode _parseMathFunction(
  final GreenNode funcNameBase,
  final TexParser parser,
  final FunctionContext context, {
  final bool defaultLimits = false,
}) {
  final scriptsResult = parser.parseScripts(allowLimits: true);
  EquationRowNode arg;
  arg = parser
          .parseAtom(context.breakOnTokenText)
          // .parseArgNode(mode: Mode.math, optional: false)
          ?.wrapWithEquationRow() ??
      EquationRowNode.empty();
  final limits = scriptsResult.limits ?? defaultLimits;
  final base = funcNameBase.wrapWithEquationRow();
  if (scriptsResult.subscript == null && scriptsResult.superscript == null) {
    return FunctionNode(
      functionName: base,
      argument: arg,
    );
  }
  if (limits) {
    var functionName = base;
    if (scriptsResult.subscript != null) {
      functionName = UnderNode(
        base: functionName,
        below: scriptsResult.subscript!,
      ).wrapWithEquationRow();
    }
    if (scriptsResult.superscript != null) {
      functionName = OverNode(
        base: functionName,
        above: scriptsResult.superscript!,
      ).wrapWithEquationRow();
    }
    return FunctionNode(
      functionName: functionName.wrapWithEquationRow(),
      argument: arg,
    );
  } else {
    return FunctionNode(
      functionName: MultiscriptsNode(
        base: base,
        sub: scriptsResult.subscript,
        sup: scriptsResult.superscript,
      ).wrapWithEquationRow(),
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

GreenNode _bigOpHandler(final TexParser parser, final FunctionContext context) {
  final fName = context.funcName.length == 1 ? singleCharBigOps[context.funcName]! : context.funcName;
  return _parseNaryOperator(fName, parser, context);
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

GreenNode _mathFunctionHandler(final TexParser parser, final FunctionContext context) => _parseMathFunction(
      stringToNode(context.funcName.substring(1), Mode.text),
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

GreenNode _mathLimitsHandler(final TexParser parser, final FunctionContext context) => _parseMathFunction(
      stringToNode(context.funcName.substring(1), Mode.text),
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

GreenNode _integralHandler(final TexParser parser, final FunctionContext context) {
  final fName = context.funcName.length == 1 ? singleCharIntegrals[context.funcName]! : context.funcName;
  return _parseNaryOperator(fName, parser, context);
}

const _operatorNameEntries = {
  ['\\operatorname', '\\operatorname*']: FunctionSpec(numArgs: 1, handler: _operatorNameHandler),
};

GreenNode _operatorNameHandler(final TexParser parser, final FunctionContext context) {
  var name = parser.parseArgNode(mode: null, optional: false)!;
  final scripts = parser.parseScripts(allowLimits: context.funcName == '\\operatorname*');
  final body =
      parser.parseGroup(context.funcName, optional: false, greediness: 1, mode: null, consumeSpaces: true) ??
          EquationRowNode.empty();

  name = StyleNode(
    children: name.expandEquationRow(),
    optionsDiff: OptionsDiff(
      mathFontOptions: texMathFontOptions['\\mathrm'],
    ),
  );

  if (!scripts.empty) {
    if (scripts.limits == true) {
      name = scripts.superscript != null
          ? OverNode(
              base: name.wrapWithEquationRow(),
              above: scripts.superscript!,
            )
          : name;
      name = scripts.subscript != null
          ? UnderNode(
              base: name.wrapWithEquationRow(),
              below: scripts.subscript!,
            )
          : name;
    } else {
      name = MultiscriptsNode(
        base: name.wrapWithEquationRow(),
        sub: scripts.subscript,
        sup: scripts.superscript,
      );
    }
  }

  return FunctionNode(
    functionName: name.wrapWithEquationRow(),
    argument: body.wrapWithEquationRow(),
  );
}

const _phantomEntries = {
  ['\\phantom', '\\hphantom', '\\vphantom']:
      FunctionSpec(numArgs: 1, allowedInText: true, handler: _phantomHandler),
};

GreenNode _phantomHandler(final TexParser parser, final FunctionContext context) {
  final body = parser.parseArgNode(mode: null, optional: false)!;
  return PhantomNode(
    phantomChild: body.wrapWithEquationRow(),
    zeroHeight: context.funcName == '\\hphantom',
    zeroDepth: context.funcName == '\\hphantom',
    zeroWidth: context.funcName == '\\vphantom',
  );
}

const _raiseBoxEntries = {
  ['\\raisebox']: FunctionSpec(numArgs: 2, allowedInText: true, handler: _raiseBoxHandler),
};

GreenNode _raiseBoxHandler(final TexParser parser, final FunctionContext context) {
  final dy = parser.parseArgSize(optional: false) ?? Measurement.zero;
  final body = parser.parseArgHbox(optional: false);
  return RaiseBoxNode(
    body: body.wrapWithEquationRow(),
    dy: dy,
  );
}

const _ruleEntries = {
  ['\\rule']: FunctionSpec(numArgs: 2, numOptionalArgs: 1, handler: _ruleHandler),
};

GreenNode _ruleHandler(final TexParser parser, final FunctionContext context) {
  final shift = parser.parseArgSize(optional: true) ?? Measurement.zero;
  final width = parser.parseArgSize(optional: false) ?? Measurement.zero;
  final height = parser.parseArgSize(optional: false) ?? Measurement.zero;

  return SpaceNode(
    height: height,
    width: width,
    shift: shift,
    fill: true,
    // background: Colors.black,
    mode: Mode.math,
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

GreenNode _sizingHandler(final TexParser parser, final FunctionContext context) {
  final body = parser.parseExpression(breakOnInfix: false, breakOnTokenText: context.breakOnTokenText);
  return StyleNode(
    children: body,
    optionsDiff: OptionsDiff(
      size: MathSize.values[_sizeFuncs.indexOf(context.funcName)],
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

GreenNode _sqrtHandler(final TexParser parser, final FunctionContext context) {
  final index = parser.parseArgNode(mode: null, optional: true);
  final body = parser.parseArgNode(mode: null, optional: false)!;
  return SqrtNode(
    index: index?.wrapWithEquationRow(),
    base: body.wrapWithEquationRow(),
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

GreenNode _stylingHandler(final TexParser parser, final FunctionContext context) {
  final body = parser.parseExpression(breakOnInfix: true, breakOnTokenText: context.breakOnTokenText);
  final style = parseMathStyle(context.funcName.substring(1, context.funcName.length - 5));
  return StyleNode(
    children: body,
    optionsDiff: OptionsDiff(style: style),
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

GreenNode _textHandler(final TexParser parser, final FunctionContext context) {
  final body = parser.parseArgNode(mode: Mode.text, optional: false)!;
  final fontOptions = texTextFontOptions[context.funcName];
  if (fontOptions == null) return body;
  return StyleNode(
    optionsDiff: OptionsDiff(textFontOptions: fontOptions),
    children: body.expandEquationRow(),
  );
}

const _underOverEntries = {
  ['\\stackrel', '\\overset', '\\underset']: FunctionSpec(
    numArgs: 2,
    handler: _underOverHandler,
  )
};

GreenNode _underOverHandler(final TexParser parser, final FunctionContext context) {
  final shiftedArg = parser.parseArgNode(mode: null, optional: false)!;
  final baseArg = parser.parseArgNode(mode: null, optional: false)!;
  if (context.funcName == '\\underset') {
    return UnderNode(
      base: baseArg.wrapWithEquationRow(),
      below: shiftedArg.wrapWithEquationRow(),
    );
  } else {
    return OverNode(
      base: baseArg.wrapWithEquationRow(),
      above: shiftedArg.wrapWithEquationRow(),
      stackRel: context.funcName == '\\stackrel',
    );
  }
}
