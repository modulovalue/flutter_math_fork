import '../ast/ast.dart';
import '../ast/ast_plus.dart';
import '../ast/symbols.dart';
import '../parser/functions.dart';
import '../parser/symbols.dart';
import '../utils/alpha_numeric.dart';
import '../utils/extensions.dart';
import '../utils/unicode_literal.dart';
import 'encoder.dart';
import 'tex_encoder.dart';

EncodeResult encoderFunctions(
  final TexGreen node,
) =>
    node.match(
      nonleaf: (final a) => a.matchNonleaf(
        nullable: (final a) => a.matchNonleafNullable(
          naryoperator: _naryEncoder,
          sqrt: _sqrtEncoder,
          stretchyop: _stretchyOpEncoder,
          matrix: (final a) => NonStrictEncodeResult(
            'unknown node type',
            'Unrecognized node type $a encountered during encoding',
          ),
          multiscripts: _multisciprtsEncoder,
        ),
        nonnullable: (final a) => a.matchNonleafNonnullable(
          accent: _accentEncoder,
          accentunder: _accentUnderEncoder,
          frac: _fracEncoder,
          function: _functionEncoder,
          leftright: _leftRightEncoder,
          style: _styleEncoder,
          equationrow: _equationRowNodeEncoderFun,
          equationarray: (final a) => NonStrictEncodeResult(
            'unknown node type',
            'Unrecognized node type $a encountered during encoding',
          ),
          over: (final a) => NonStrictEncodeResult(
            'unknown node type',
            'Unrecognized node type $a encountered during encoding',
          ),
          under: (final a) => NonStrictEncodeResult(
            'unknown node type',
            'Unrecognized node type $a encountered during encoding',
          ),
          enclosure: (final a) => NonStrictEncodeResult(
            'unknown node type',
            'Unrecognized node type $a encountered during encoding',
          ),
          raisebox: (final a) => NonStrictEncodeResult(
            'unknown node type',
            'Unrecognized node type $a encountered during encoding',
          ),
        ),
      ),
      leaf: (final a) => a.matchLeaf(
        temporary: (final a) => NonStrictEncodeResult(
          'unknown node type',
          'Unrecognized node type $a encountered during encoding',
        ),
        cursor: (final a) => NonStrictEncodeResult(
          'unknown node type',
          'Unrecognized node type $a encountered during encoding',
        ),
        phantom: (final a) => NonStrictEncodeResult(
          'unknown node type',
          'Unrecognized node type $a encountered during encoding',
        ),
        space: (final a) => NonStrictEncodeResult(
          'unknown node type',
          'Unrecognized node type $a encountered during encoding',
        ),
        symbol: _symbolEncoder,
      ),
    );

EncodeResult _equationRowNodeEncoderFun(
  final TexGreenEquationrow node,
) =>
    EquationRowTexEncodeResult(
      node.children.map(encodeTex).toList(
            growable: false,
          ),
    );

EncodeResult _accentEncoder(
  final TexGreenAccent node,
) {
  final accentNode = node;
  final commandCandidates = accentCommandMapping.entries
      .where((final entry) => entry.value == accentNode.label)
      .map((final entry) => entry.key)
      .toList(growable: false);
  final textCommandCandidates =
      commandCandidates.where((final candidate) => functions[candidate]?.allowedInText == true);
  final mathCommandCandidates =
      commandCandidates.where((final candidate) => functions[candidate]?.allowedInMath == true);
  if (commandCandidates.isEmpty) {
    return NonStrictEncodeResult(
      'unknown accent',
      'Unrecognized accent symbol encountered during TeX encoding: '
          '${unicodeLiteral(accentNode.label)}',
      encodeTex(node.children.first),
    );
  }
  bool isCommandMatched(final String command) =>
      accentNode.isStretchy == !nonStretchyAccents.contains(command) &&
      accentNode.isShifty == (!accentNode.isStretchy || shiftyAccents.contains(command));
  final mathCommand = mathCommandCandidates.firstWhereOrNull(isCommandMatched);
  final math = mathCommand != null
      ? TexCommandEncodeResult(command: mathCommand, args: node.children)
      : mathCommandCandidates.firstOrNull != null
          ? NonStrictEncodeResult(
              'imprecise accent',
              'No strict match for accent symbol under math mode: '
                  '${unicodeLiteral(accentNode.label)}, '
                  '${accentNode.isStretchy ? '' : 'not '}stretchy and '
                  '${accentNode.isShifty ? '' : 'not '}shifty',
              TexCommandEncodeResult(
                command: mathCommandCandidates.first,
                args: node.children,
              ),
            )
          : NonStrictEncodeResult(
              'unknown accent',
              'No strict match for accent symbol under math mode: '
                  '${unicodeLiteral(accentNode.label)}, '
                  '${accentNode.isStretchy ? '' : 'not '}stretchy and '
                  '${accentNode.isShifty ? '' : 'not '}shifty',
              TexCommandEncodeResult(command: commandCandidates.first, args: node.children),
            );
  final textCommand = accentNode.isStretchy == false && accentNode.isShifty == true
      ? textCommandCandidates.firstOrNull
      : null;
  final text = textCommand != null
      ? TexCommandEncodeResult(command: textCommand, args: node.children)
      : textCommandCandidates.firstOrNull != null
          ? NonStrictEncodeResult(
              'imprecise accent',
              'No strict match for accent symbol under text mode: '
                  '${unicodeLiteral(accentNode.label)}, '
                  '${accentNode.isStretchy ? '' : 'not '}stretchy and '
                  '${accentNode.isShifty ? '' : 'not '}shifty',
              TexCommandEncodeResult(
                command: textCommandCandidates.first,
                args: node.children,
              ),
            )
          : NonStrictEncodeResult(
              'unknown accent',
              'No strict match for accent symbol under text mode: '
                  '${unicodeLiteral(accentNode.label)}, '
                  '${accentNode.isStretchy ? '' : 'not '}stretchy and '
                  '${accentNode.isShifty ? '' : 'not '}shifty',
              TexCommandEncodeResult(command: commandCandidates.first, args: node.children),
            );
  return ModeDependentEncodeResult(
    math: math,
    text: text,
  );
}

EncodeResult _accentUnderEncoder(
  final TexGreenAccentunder node,
) {
  final accentNode = node;
  final label = accentNode.label;
  final command = accentUnderMapping.entries.firstWhereOrNull((final entry) => entry.value == label)?.key;
  if (command == null) {
    return NonStrictEncodeResult(
      'unknown accent_under',
      'No strict match for accent_under symbol under math mode: '
          '${unicodeLiteral(accentNode.label)}',
    );
  } else {
    return TexCommandEncodeResult(
      command: command,
      args: accentNode.children,
    );
  }
}

EncodeResult _functionEncoder(
  final TexGreenFunction node,
) {
  return NonStrictEncodeResult(
    'imprecise function encoding',
    'The default encoder for FunctionNode is used, which is imprecise. '
        'Non better alternatives were found.',
    TransparentTexEncodeResult(
      <dynamic>[
        TexCommandEncodeResult(
          command: '\\operatorname',
          args: <dynamic>[
            node.functionName,
          ],
        ),
        node.argument,
      ],
    ),
  );
}

EncodeResult _fracEncoder(
  final TexGreenFrac node,
) {
  final fracNode = node;
  if (fracNode.barSize == null) {
    if (fracNode.continued) {
      return TexCommandEncodeResult(
        command: '\\cfrac',
        args: fracNode.children,
      );
    } else {
      return TexCommandEncodeResult(
        command: '\\frac',
        args: fracNode.children,
      );
    }
  } else {
    return TexCommandEncodeResult(
      command: '\\genfrac',
      args: <dynamic>[
        null,
        null,
        fracNode.barSize,
        null,
        ...fracNode.children,
      ],
    );
  }
}

EncodeResult _leftRightEncoder(
  final TexGreenLeftright node,
) {
  final leftRightNode = node;
  final left = _delimEncoder(leftRightNode.leftDelim);
  final right = _delimEncoder(leftRightNode.rightDelim);
  final middles = leftRightNode.middle.map(_delimEncoder).toList(growable: false);
  return TransparentTexEncodeResult(<dynamic>[
    '\\left',
    left,
    ...leftRightNode.body.first.children,
    for (var i = 1; i < leftRightNode.body.length; i++) ...[
      '\\middle',
      middles[i - 1],
      ...leftRightNode.body[i].children,
    ],
    '\\right',
    right,
  ]);
}

EncodeResult _delimEncoder(final String? delim) {
  if (delim == null) {
    return const StaticEncodeResult('.');
  } else {
    final result = _baseSymbolEncoder(delim, TexMode.math);
    return result != null
        ? delimiterCommands.contains(result)
            ? StaticEncodeResult(result)
            : NonStrictEncodeResult.string(
                'illegal delimiter',
                'Non-delimiter symbol ${unicodeLiteral(delim)} '
                    'occured for delimiter',
                result,
              )
        : NonStrictEncodeResult.string(
            'unknown symbol',
            'Unrecognized symbol encountered during TeX encoding: '
                '${unicodeLiteral(delim)} with mode Math',
            '.',
          );
  }
}

EncodeResult _multisciprtsEncoder(
  final TexGreenMultiscripts node,
) {
  final scriptsNode = node;
  return TexMultiscriptEncodeResult(
    base: scriptsNode.base,
    sub: scriptsNode.sub,
    sup: scriptsNode.sup,
    presub: scriptsNode.presub,
    presup: scriptsNode.presup,
  );
}

EncodeResult _naryEncoder(
  final TexGreenNaryoperator node,
) {
  final naryNode = node;
  final command = _naryOperatorMapping[naryNode.operator];
  if (command == null) {
    return NonStrictEncodeResult(
      'unknown Nary opertor',
      'Unknown Nary opertor symbol ${unicodeLiteral(naryNode.operator)} '
          'encountered during encoding.',
    );
  }
  return TransparentTexEncodeResult(<dynamic>[
    TexMultiscriptEncodeResult(
      base: naryNode.limits != null ? '$command\\${naryNode.limits! ? '' : 'no'}limits' : command,
      sub: naryNode.lowerLimit,
      sup: naryNode.upperLimit,
    ),
    naryNode.naryand,
  ]);
}

// Dart compiler bug here. Cannot set it to const
final _naryOperatorMapping = {
  ...singleCharBigOps,
  ...singleCharIntegrals,
};

EncodeResult _sqrtEncoder(final TexGreenSqrt node) {
  final sqrtNode = node;
  return TexCommandEncodeResult(
    command: '\\sqrt',
    args: sqrtNode.children,
  );
}

EncodeResult _stretchyOpEncoder(
  final TexGreenStretchyop node,
) {
  final arrowNode = node;
  final command = arrowCommandMapping.entries
      .firstWhereOrNull(
        (final entry) => entry.value == arrowNode.symbol,
      )
      ?.key;
  if (command == null) {
    return NonStrictEncodeResult(
      'unknown strechy_op',
      'No strict match for stretchy_op symbol under math mode: '
          '${unicodeLiteral(arrowNode.symbol)}',
    );
  } else {
    return TexCommandEncodeResult(
      command: command,
      args: <dynamic>[
        arrowNode.above,
        arrowNode.below,
      ],
    );
  }
}

EncodeResult _styleEncoder(
  final TexGreenStyle node,
) {
  final styleNode = node;
  return optionsDiffEncode(
    styleNode.optionsDiff,
    styleNode.children,
  );
}

EncodeResult optionsDiffEncode(
  final TexOptionsDiff diff,
  final List<dynamic> children,
) {
  EncodeResult res = TransparentTexEncodeResult(children);
  if (diff.size != null) {
    final sizeCommand = _sizeCommands[diff.size];
    res = TexModeCommandEncodeResult(
      command: sizeCommand ?? '\\tiny',
      children: <dynamic>[res],
    );
    if (sizeCommand == null) {
      res = NonStrictEncodeResult(
        'imprecise size',
        'Non-strict MethSize encountered during TeX encoding: '
            '${diff.size}',
        res,
      );
    }
  }

  if (diff.style != null) {
    final styleCommand = _styleCommands[diff.style];
    res = TexModeCommandEncodeResult(
      command: styleCommand ?? _styleCommands[mathStyleUncramp(diff.style!)]!,
      children: <dynamic>[res],
    );
    if (styleCommand == null) {
      NonStrictEncodeResult(
        'imprecise style',
        'Non-strict MathStyle encountered during TeX encoding: '
            '${diff.style}',
        res,
      );
    }
  }

  if (diff.textFontOptions != null) {
    final command = texTextFontOptions.entries
        .firstWhereOrNull((final entry) => entry.value == diff.textFontOptions)
        ?.key;
    if (command == null) {
      res = NonStrictEncodeResult(
        'unknown font',
        'Unrecognized text font encountered during TeX encoding: '
            '${diff.textFontOptions}',
        res,
      );
    } else {
      res = TexCommandEncodeResult(
        command: command,
        args: <dynamic>[res],
      );
    }
  }

  if (diff.mathFontOptions != null) {
    final command = texMathFontOptions.entries
        .firstWhereOrNull((final entry) => entry.value == diff.mathFontOptions)
        ?.key;
    if (command == null) {
      res = NonStrictEncodeResult(
        'unknown font',
        'Unrecognized math font encountered during TeX encoding: '
            '${diff.mathFontOptions}',
        res,
      );
    } else {
      res = TexCommandEncodeResult(
        command: command,
        args: <dynamic>[res],
      );
    }
  }
  if (diff.color != null) {
    res = TexCommandEncodeResult(
      command: '\\textcolor',
      args: <dynamic>[
        '#${diff.color!.argb.toRadixString(16).padLeft(6, '0')}',
        res,
      ],
    );
  }
  return res;
}

const _styleCommands = {
  TexMathStyle.display: '\\displaystyle',
  TexMathStyle.text: '\\textstyle',
  TexMathStyle.script: '\\scriptstyle',
  TexMathStyle.scriptscript: '\\scriptscriptstyle'
};

const _sizeCommands = {
  TexMathSize.tiny: '\\tiny',
  TexMathSize.size2: '\\tiny',
  TexMathSize.scriptsize: '\\scriptsize',
  TexMathSize.footnotesize: '\\footnotesize',
  TexMathSize.small: '\\small',
  TexMathSize.normalsize: '\\normalsize',
  TexMathSize.large: '\\large',
  TexMathSize.Large: '\\Large',
  TexMathSize.LARGE: '\\LARGE',
  TexMathSize.huge: '\\huge',
  TexMathSize.HUGE: '\\HUGE',
};

EncodeResult _symbolEncoder(
  final TexGreenSymbol node,
) {
  final symbolNode = node;
  final symbol = symbolNode.symbol;
  final mode = symbolNode.mode;
  final encodeAsBaseSymbol = _baseSymbolEncoder(
    symbol,
    mode,
    symbolNode.overrideFont,
    symbolNode.atomType,
    symbolNode.overrideAtomType,
  );
  if (encodeAsBaseSymbol != null) {
    return StaticEncodeResult(encodeAsBaseSymbol);
  }
  if (mode == TexMode.math && negatedOperatorSymbols.containsKey(symbol)) {
    final encodeAsNegatedOp = _baseSymbolEncoder(negatedOperatorSymbols[symbol]![1], TexMode.math);
    if (encodeAsNegatedOp != null) {
      return StaticEncodeResult('\\not $encodeAsNegatedOp');
    }
  }
  return NonStrictEncodeResult(
    'unknown symbol',
    'Unrecognized symbol encountered during TeX encoding: '
        '${unicodeLiteral(symbol)} with mode $mode type ${symbolNode.atomType} '
        'font ${symbolNode.overrideFont?.fontName}',
    StaticEncodeResult(symbolNode.symbol),
  );
}

String? _baseSymbolEncoder(final String symbol, final TexMode mode,
    [final TexFontOptions? overrideFont, final TexAtomType? type, final TexAtomType? overrideType]) {
  // For alpha-numeric and unescaped symbols, provide a fast track
  if (overrideFont == null && overrideType == null && symbol.length == 1) {
    if (isAlphaNumericUnit(symbol) ||
        const {
          '!', '*', '(', ')', '-', '+', '=', //
          '|', ':', ';', "'", '"', ',', '<', '.', '>', '?', '/'
        }.contains(symbol)) {
      return symbol;
    }
  }
  final candidates = <MapEntry<String, TexSymbolConfig>>[];
  if (mode != TexMode.text) {
    candidates.addAll(
      texSymbolCommandConfigs[TexMode.math]!.entries.where((final entry) => entry.value.symbol == symbol),
    );
  }
  if (mode != TexMode.math) {
    candidates.addAll(
      texSymbolCommandConfigs[TexMode.text]!.entries.where((final entry) => entry.value.symbol == symbol),
    );
  }
  sortBy(candidates)<num>(
    (final candidate) {
      final candidFont = candidate.value.font;
      final fontScore = () {
        if (candidFont == overrideFont) {
          return 1000;
        } else {
          return (candidFont?.fontFamily == overrideFont?.fontFamily ? 500 : 0) +
              (candidFont?.fontShape == overrideFont?.fontShape ? 300 : 0) +
              (candidFont?.fontWeight == overrideFont?.fontWeight ? 200 : 0);
        }
      }();
      final typeScore = () {
        if (candidate.value.type == overrideType) {
          return 150;
        } else {
          return candidate.value.type == type ? 100 : 0;
        }
      }();
      final commandConciseness = 100 ~/ candidate.key.length -
          100 * candidate.key.runes.where((final point) => point > 126 || point < 32).length;
      return fontScore + typeScore + commandConciseness;
    },
  );
  return candidates.lastOrNull?.key;
}
