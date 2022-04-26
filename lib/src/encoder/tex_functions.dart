import '../ast/ast.dart';
import '../ast/ast_plus.dart';
import '../ast/symbols.dart';
import '../parser/font.dart';
import '../parser/functions.dart';
import '../parser/functions_katex_base.dart';
import '../parser/symbols.dart';
import '../utils/alpha_numeric.dart';
import '../utils/extensions.dart';
import '../utils/unicode_literal.dart';
import 'encoder.dart';
import 'matcher.dart';
import 'optimization.dart';
import 'tex_encoder.dart';

const Map<Type, EncoderFun> encoderFunctions = {
  TexGreenEquationrow: _equationRowNodeEncoderFun,
  TexGreenAccent: _accentEncoder,
  TexGreenAccentunder: _accentUnderEncoder,
  TexGreenFrac: _fracEncoder,
  TexGreenFunction: _functionEncoder,
  TexGreenLeftright: _leftRightEncoder,
  TexGreenMultiscripts: _multisciprtsEncoder,
  TexGreenNaryoperator: _naryEncoder,
  TexGreenSqrt: _sqrtEncoder,
  TexGreenStretchyop: _stretchyOpEncoder,
  TexGreenSymbol: _symbolEncoder,
  TexGreenStyle: _styleEncoder,
};

EncodeResult _equationRowNodeEncoderFun(
  final TexGreen node,
) =>
    EquationRowTexEncodeResult(
      (node as TexGreenEquationrow).children.map(encodeTex).toList(
            growable: false,
          ),
    );

final optimizationEntries = sortBy(
  [
    ..._fracOptimizationEntries,
    ..._functionOptimizationEntries,
  ],
)<num>(
  (final entry) => -entry.priority,
);

EncodeResult _accentEncoder(final TexGreen node) {
  final accentNode = node as TexGreenAccent;
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
  final TexGreen node,
) {
  final accentNode = node as TexGreenAccentunder;
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

EncodeResult _functionEncoder(final TexGreen node) {
  final functionNode = node as TexGreenFunction;

  return NonStrictEncodeResult(
    'imprecise function encoding',
    'The default encoder for FunctionNode is used, which is imprecise. '
        'Non better alternatives were found.',
    TransparentTexEncodeResult(<dynamic>[
      TexCommandEncodeResult(command: '\\operatorname', args: <dynamic>[
        functionNode.functionName,
      ]),
      functionNode.argument,
    ]),
  );
}

final _functionOptimizationEntries = [
  OptimizationEntry(
    matcher: isA<TexGreenFunction>(
      firstChild: isA<TexGreenEquationrow>(
        child: isA<TexGreenStyle>(
          matchSelf: (final node) => node.optionsDiff.mathFontOptions == texMathFontOptions['\\mathrm'],
        ),
      ),
    ),
    optimize: (final node) {
      final functionNode = node as TexGreenFunction;
      texEncodingCache[node] = TransparentTexEncodeResult(<dynamic>[
        TexCommandEncodeResult(command: '\\operatorname', args: <dynamic>[
          _optionsDiffEncode(
            (functionNode.functionName.children.first as TexGreenStyle).optionsDiff.removeMathFont(),
            functionNode.functionName.children.first.childrenl,
          )
        ]),
        functionNode.argument,
      ]);
    },
  ),
  // Optimization for plain invocations like \sin \lim
  OptimizationEntry(
    matcher: isA<TexGreenFunction>(
      firstChild: isA<TexGreenEquationrow>(
        everyChild: isA<TexGreenSymbol>(),
      ),
    ),
    optimize: (final node) {
      final functionNode = node as TexGreenFunction;
      final name =
          '\\${functionNode.functionName.children.map((final child) => (child as TexGreenSymbol).symbol).join()}';
      if (mathFunctions.contains(name) || mathLimits.contains(name)) {
        texEncodingCache[node] = TexCommandEncodeResult(
          numArgs: 1,
          command: name,
          args: <dynamic>[functionNode.argument],
        );
      }
    },
  ),
  // Optimization for non-limits-like functions with scripts
  OptimizationEntry(
    matcher: isA<TexGreenFunction>(
      firstChild: isA<TexGreenEquationrow>(
        child: isA<TexGreenMultiscripts>(
          matchSelf: (final node) =>
              node.presub == null &&
              node.presup == null &&
              isA<TexGreenEquationrow>(
                everyChild: isA<TexGreenSymbol>(),
              ).match(node.base),
          selfSpecificity: 500,
        ),
      ),
    ),
    optimize: (final node) {
      final functionNode = node as TexGreenFunction;
      final scriptsNode = functionNode.functionName.children.first as TexGreenMultiscripts;
      final name = '\\${scriptsNode.base.children.map((final child) => (child as TexGreenSymbol).symbol).join()}';

      final isFunction = mathFunctions.contains(name);
      final isLimit = mathLimits.contains(name);
      if (isFunction || isLimit) {
        texEncodingCache[node] = TransparentTexEncodeResult(<dynamic>[
          TexMultiscriptEncodeResult(
            base: name + (isLimit ? '\\nolimits' : ''),
            sub: scriptsNode.sub,
            sup: scriptsNode.sup,
          ),
          functionNode.argument,
        ]);
      }
    },
  ),
  // Optimization for limits-like functions with scripts
  OptimizationEntry(
    matcher: isA<TexGreenFunction>(
      firstChild: isA<TexGreenEquationrow>(
        child: isA<TexGreenOver>(
          firstChild: _nameMatcher.or(isA<TexGreenEquationrow>(
            child: isA<TexGreenUnder>(firstChild: _nameMatcher),
          )),
        ).or(isA<TexGreenUnder>(
          firstChild: _nameMatcher.or(isA<TexGreenEquationrow>(
            child: isA<TexGreenOver>(firstChild: _nameMatcher),
          )),
        )),
      ),
    ),
    optimize: (final node) {
      final functionNode = node as TexGreenFunction;
      var nameNode = functionNode.functionName.children.first;
      TexGreen? sub, sup;
      final outer = nameNode;
      if (outer is TexGreenOver) {
        sup = outer.above;
        nameNode = outer.base;
        // If we detect an UnderNode in the children, combined with the design
        // of the matcher, we can know that there must be a inner under/over.
        final inner = nameNode.childrenl.firstOrNull;
        if (inner is TexGreenUnder) {
          sub = inner.below;
          nameNode = inner.base;
        }
      } else if (outer is TexGreenUnder) {
        sub = outer.below;
        nameNode = outer.base;
        final inner = nameNode.childrenl.firstOrNull;
        if (inner is TexGreenOver) {
          sup = inner.above;
          nameNode = inner.base;
        }
      }
      final name = '\\${nameNode.childrenl.map((final child) => (child as TexGreenSymbol?)!.symbol).join()}';

      final isFunction = mathFunctions.contains(name);
      final isLimit = mathLimits.contains(name);
      if (isFunction || isLimit) {
        texEncodingCache[node] = TransparentTexEncodeResult(<dynamic>[
          TexMultiscriptEncodeResult(
            base: name + (isFunction ? '\\limits' : ''),
            sub: sub,
            sup: sup,
          ),
          functionNode.argument,
        ]);
      }
    },
  ),
];

final _nameMatcher = isA<TexGreenEquationrow>(
  everyChild: isA<TexGreenSymbol>(),
);

EncodeResult _fracEncoder(final TexGreen node) {
  final fracNode = node as TexGreenFrac;
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

final _fracOptimizationEntries = [
  // \dfrac \tfrac
  OptimizationEntry(
    matcher: isA<TexGreenStyle>(
      matchSelf: (final node) {
        final style = node.optionsDiff.style;
        return style == MathStyle.display || style == MathStyle.text;
      },
      child: isA<TexGreenFrac>(
        matchSelf: (final node) => node.barSize == null,
        selfSpecificity: 110,
      ),
    ),
    optimize: (final node) {
      final style = (node as TexGreenStyle).optionsDiff.style;
      final continued = (node.children.first as TexGreenFrac).continued;
      if (style == MathStyle.text && continued) return;

      final res = TexCommandEncodeResult(
        command: style == MathStyle.display ? (continued ? '\\cfrac' : '\\dfrac') : '\\tfrac',
        args: node.children.first.childrenl,
      );
      final remainingOptions = node.optionsDiff.removeStyle();
      texEncodingCache[node] =
          remainingOptions.isEmpty ? res : _optionsDiffEncode(remainingOptions, <dynamic>[res]);
    },
  ),

  // \binom
  OptimizationEntry(
    matcher: isA<TexGreenLeftright>(
      matchSelf: (final node) => node.leftDelim == '(' && node.rightDelim == ')',
      child: isA<TexGreenEquationrow>(
        child: isA<TexGreenFrac>(
          matchSelf: (final node) => node.continued == false && node.barSize?.value == 0,
        ),
      ),
    ),
    optimize: (final node) {
      texEncodingCache[node] = TexCommandEncodeResult(
        command: '\\binom',
        args: node.childrenl.first!.childrenl.first!.childrenl,
      );
    },
  ),

  // \tbinom \dbinom

  // \genfrac
  OptimizationEntry(
    matcher: isA<TexGreenStyle>(
      matchSelf: (final node) => node.optionsDiff.style != null,
      child: isA<TexGreenLeftright>(
        child: isA<TexGreenEquationrow>(
          child: isA<TexGreenFrac>(
            matchSelf: (final node) => node.continued == false,
          ),
        ),
      ),
    ),
    optimize: (final node) {
      final leftRight = (node.childrenl.first as TexGreenLeftright?)!;
      final frac = leftRight.children.first.children.first as TexGreenFrac;
      final res = TexCommandEncodeResult(
        command: '\\genfrac',
        args: <dynamic>[
          // TODO
          leftRight.leftDelim == null ? null : TexGreenSymbol(symbol: leftRight.leftDelim!),
          leftRight.rightDelim == null ? null : TexGreenSymbol(symbol: leftRight.rightDelim!),
          frac.barSize,
          () {
            final style = (node as TexGreenStyle).optionsDiff.style;
            if (style == null) {
              return null;
            } else {
              return mathStyleSize(style);
            }
          }(),
          ...frac.children,
        ],
      );
      final remainingOptions = (node as TexGreenStyle).optionsDiff.removeStyle();
      texEncodingCache[node] = () {
        if (remainingOptions.isEmpty) {
          return res;
        } else {
          return _optionsDiffEncode(remainingOptions, <dynamic>[res]);
        }
      }();
    },
  ),
  OptimizationEntry(
    matcher: isA<TexGreenStyle>(
      matchSelf: (final node) => node.optionsDiff.style != null,
      child: isA<TexGreenFrac>(
        matchSelf: (final node) => node.continued == false,
      ),
    ),
    optimize: (final node) {
      final frac = (node.childrenl.first as TexGreenFrac?)!;
      final res = TexCommandEncodeResult(
        command: '\\genfrac',
        args: <dynamic>[
          null,
          null,
          frac.barSize,
          () {
            final style = (node as TexGreenStyle).optionsDiff.style;
            if (style == null) {
              return null;
            } else {
              return mathStyleSize(style);
            }
          }(),
          ...frac.children,
        ],
      );
      final remainingOptions = (node as TexGreenStyle).optionsDiff.removeStyle();
      texEncodingCache[node] = () {
        if (remainingOptions.isEmpty) {
          return res;
        } else {
          return _optionsDiffEncode(remainingOptions, <dynamic>[res]);
        }
      }();
    },
  ),
];

EncodeResult _leftRightEncoder(final TexGreen node) {
  final leftRightNode = node as TexGreenLeftright;
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
    final result = _baseSymbolEncoder(delim, Mode.math);
    return result != null
        ? delimiterCommands.contains(result)
            ? StaticEncodeResult(result)
            : NonStrictEncodeResult.string(
                'illegal delimiter',
                'Non-delimiter symbol ${unicodeLiteral(delim)} '
                    'occured as delimiter',
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

EncodeResult _multisciprtsEncoder(final TexGreen node) {
  final scriptsNode = node as TexGreenMultiscripts;
  return TexMultiscriptEncodeResult(
    base: scriptsNode.base,
    sub: scriptsNode.sub,
    sup: scriptsNode.sup,
    presub: scriptsNode.presub,
    presup: scriptsNode.presup,
  );
}

EncodeResult _naryEncoder(final TexGreen node) {
  final naryNode = node as TexGreenNaryoperator;
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

EncodeResult _sqrtEncoder(final TexGreen node) {
  final sqrtNode = node as TexGreenSqrt;
  return TexCommandEncodeResult(
    command: '\\sqrt',
    args: sqrtNode.children,
  );
}

EncodeResult _stretchyOpEncoder(
  final TexGreen node,
) {
  final arrowNode = node as TexGreenStretchyop;
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

EncodeResult _styleEncoder(final TexGreen node) {
  final styleNode = node as TexGreenStyle;
  return _optionsDiffEncode(styleNode.optionsDiff, styleNode.children);
}

EncodeResult _optionsDiffEncode(final OptionsDiff diff, final List<dynamic> children) {
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
        '#${diff.color!.value.toRadixString(16).padLeft(6, '0')}',
        res,
      ],
    );
  }
  return res;
}

const _styleCommands = {
  MathStyle.display: '\\displaystyle',
  MathStyle.text: '\\textstyle',
  MathStyle.script: '\\scriptstyle',
  MathStyle.scriptscript: '\\scriptscriptstyle'
};

const _sizeCommands = {
  MathSize.tiny: '\\tiny',
  MathSize.size2: '\\tiny',
  MathSize.scriptsize: '\\scriptsize',
  MathSize.footnotesize: '\\footnotesize',
  MathSize.small: '\\small',
  MathSize.normalsize: '\\normalsize',
  MathSize.large: '\\large',
  MathSize.Large: '\\Large',
  MathSize.LARGE: '\\LARGE',
  MathSize.huge: '\\huge',
  MathSize.HUGE: '\\HUGE',
};

EncodeResult _symbolEncoder(final TexGreen node) {
  final symbolNode = node as TexGreenSymbol;
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
  if (mode == Mode.math && negatedOperatorSymbols.containsKey(symbol)) {
    final encodeAsNegatedOp = _baseSymbolEncoder(negatedOperatorSymbols[symbol]![1], Mode.math);
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

String? _baseSymbolEncoder(final String symbol, final Mode mode,
    [final FontOptions? overrideFont, final AtomType? type, final AtomType? overrideType]) {
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
  if (mode != Mode.text) {
    candidates.addAll(
      texSymbolCommandConfigs[Mode.math]!.entries.where((final entry) => entry.value.symbol == symbol),
    );
  }
  if (mode != Mode.math) {
    candidates.addAll(
      texSymbolCommandConfigs[Mode.text]!.entries.where((final entry) => entry.value.symbol == symbol),
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
