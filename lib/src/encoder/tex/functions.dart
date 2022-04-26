import '../../ast/nodes/accent.dart';
import '../../ast/nodes/accent_under.dart';
import '../../ast/nodes/frac.dart';
import '../../ast/nodes/function.dart';
import '../../ast/nodes/left_right.dart';
import '../../ast/nodes/multiscripts.dart';
import '../../ast/nodes/nary_op.dart';
import '../../ast/nodes/over.dart';
import '../../ast/nodes/sqrt.dart';
import '../../ast/nodes/stretchy_op.dart';
import '../../ast/nodes/style.dart';
import '../../ast/nodes/symbol.dart';
import '../../ast/nodes/under.dart';
import '../../ast/options.dart';
import '../../ast/size.dart';
import '../../ast/style.dart';
import '../../ast/symbols.dart';
import '../../ast/syntax_tree.dart';
import '../../ast/types.dart';
import '../../parser/tex/font.dart';
import '../../parser/tex/functions.dart';
import '../../parser/tex/functions/katex_base.dart';
import '../../parser/tex/symbols.dart';
import '../../utils/alpha_numeric.dart';
import '../../utils/iterable_extensions.dart';
import '../../utils/unicode_literal.dart';
import '../encoder.dart';
import '../matcher.dart';
import '../optimization.dart';
import 'encoder.dart';

const Map<Type, EncoderFun> encoderFunctions = {
  EquationRowNode: _equationRowNodeEncoderFun,
  AccentNode: _accentEncoder,
  AccentUnderNode: _accentUnderEncoder,
  FracNode: _fracEncoder,
  FunctionNode: _functionEncoder,
  LeftRightNode: _leftRightEncoder,
  MultiscriptsNode: _multisciprtsEncoder,
  NaryOperatorNode: _naryEncoder,
  SqrtNode: _sqrtEncoder,
  StretchyOpNode: _stretchyOpEncoder,
  SymbolNode: _symbolEncoder,
  StyleNode: _styleEncoder,
};

EncodeResult _equationRowNodeEncoderFun(
  final GreenNode node,
) =>
    EquationRowTexEncodeResult(
      (node as EquationRowNode).children.map(encodeTex).toList(
            growable: false,
          ),
    );

final optimizationEntries = [
  ..._fracOptimizationEntries,
  ..._functionOptimizationEntries,
]..sortBy<num>((final entry) => -entry.priority);

EncodeResult _accentEncoder(final GreenNode node) {
  final accentNode = node as AccentNode;
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
  final GreenNode node,
) {
  final accentNode = node as AccentUnderNode;
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

EncodeResult _functionEncoder(final GreenNode node) {
  final functionNode = node as FunctionNode;

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
    matcher: isA<FunctionNode>(
      firstChild: isA<EquationRowNode>(
        child: isA<StyleNode>(
          matchSelf: (final node) => node.optionsDiff.mathFontOptions == texMathFontOptions['\\mathrm'],
        ),
      ),
    ),
    optimize: (final node) {
      final functionNode = node as FunctionNode;
      texEncodingCache[node] = TransparentTexEncodeResult(<dynamic>[
        TexCommandEncodeResult(command: '\\operatorname', args: <dynamic>[
          _optionsDiffEncode(
            (functionNode.functionName.children.first as StyleNode).optionsDiff.removeMathFont(),
            functionNode.functionName.children.first.children,
          )
        ]),
        functionNode.argument,
      ]);
    },
  ),
  // Optimization for plain invocations like \sin \lim
  OptimizationEntry(
    matcher: isA<FunctionNode>(
      firstChild: isA<EquationRowNode>(
        everyChild: isA<SymbolNode>(),
      ),
    ),
    optimize: (final node) {
      final functionNode = node as FunctionNode;
      final name =
          '\\${functionNode.functionName.children.map((final child) => (child as SymbolNode).symbol).join()}';
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
    matcher: isA<FunctionNode>(
      firstChild: isA<EquationRowNode>(
        child: isA<MultiscriptsNode>(
          matchSelf: (final node) =>
              node.presub == null &&
              node.presup == null &&
              isA<EquationRowNode>(
                everyChild: isA<SymbolNode>(),
              ).match(node.base),
          selfSpecificity: 500,
        ),
      ),
    ),
    optimize: (final node) {
      final functionNode = node as FunctionNode;
      final scriptsNode = functionNode.functionName.children.first as MultiscriptsNode;
      final name = '\\${scriptsNode.base.children.map((final child) => (child as SymbolNode).symbol).join()}';

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
    matcher: isA<FunctionNode>(
      firstChild: isA<EquationRowNode>(
        child: isA<OverNode>(
          firstChild: _nameMatcher.or(isA<EquationRowNode>(
            child: isA<UnderNode>(firstChild: _nameMatcher),
          )),
        ).or(isA<UnderNode>(
          firstChild: _nameMatcher.or(isA<EquationRowNode>(
            child: isA<OverNode>(firstChild: _nameMatcher),
          )),
        )),
      ),
    ),
    optimize: (final node) {
      final functionNode = node as FunctionNode;
      var nameNode = functionNode.functionName.children.first;
      GreenNode? sub, sup;
      final outer = nameNode;
      if (outer is OverNode) {
        sup = outer.above;
        nameNode = outer.base;
        // If we detect an UnderNode in the children, combined with the design
        // of the matcher, we can know that there must be a inner under/over.
        final inner = nameNode.children.firstOrNull;
        if (inner is UnderNode) {
          sub = inner.below;
          nameNode = inner.base;
        }
      } else if (outer is UnderNode) {
        sub = outer.below;
        nameNode = outer.base;
        final inner = nameNode.children.firstOrNull;
        if (inner is OverNode) {
          sup = inner.above;
          nameNode = inner.base;
        }
      }
      final name = '\\${nameNode.children.map((final child) => (child as SymbolNode?)!.symbol).join()}';

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

final _nameMatcher = isA<EquationRowNode>(
  everyChild: isA<SymbolNode>(),
);

EncodeResult _fracEncoder(final GreenNode node) {
  final fracNode = node as FracNode;
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
    matcher: isA<StyleNode>(
      matchSelf: (final node) {
        final style = node.optionsDiff.style;
        return style == MathStyle.display || style == MathStyle.text;
      },
      child: isA<FracNode>(
        matchSelf: (final node) => node.barSize == null,
        selfSpecificity: 110,
      ),
    ),
    optimize: (final node) {
      final style = (node as StyleNode).optionsDiff.style;
      final continued = (node.children.first as FracNode).continued;
      if (style == MathStyle.text && continued) return;

      final res = TexCommandEncodeResult(
        command: style == MathStyle.display ? (continued ? '\\cfrac' : '\\dfrac') : '\\tfrac',
        args: node.children.first.children,
      );
      final remainingOptions = node.optionsDiff.removeStyle();
      texEncodingCache[node] =
          remainingOptions.isEmpty ? res : _optionsDiffEncode(remainingOptions, <dynamic>[res]);
    },
  ),

  // \binom
  OptimizationEntry(
    matcher: isA<LeftRightNode>(
      matchSelf: (final node) => node.leftDelim == '(' && node.rightDelim == ')',
      child: isA<EquationRowNode>(
        child: isA<FracNode>(
          matchSelf: (final node) => node.continued == false && node.barSize?.value == 0,
        ),
      ),
    ),
    optimize: (final node) {
      texEncodingCache[node] = TexCommandEncodeResult(
        command: '\\binom',
        args: node.children.first!.children.first!.children,
      );
    },
  ),

  // \tbinom \dbinom

  // \genfrac
  OptimizationEntry(
    matcher: isA<StyleNode>(
      matchSelf: (final node) => node.optionsDiff.style != null,
      child: isA<LeftRightNode>(
        child: isA<EquationRowNode>(
          child: isA<FracNode>(
            matchSelf: (final node) => node.continued == false,
          ),
        ),
      ),
    ),
    optimize: (final node) {
      final leftRight = (node.children.first as LeftRightNode?)!;
      final frac = leftRight.children.first.children.first as FracNode;
      final res = TexCommandEncodeResult(
        command: '\\genfrac',
        args: <dynamic>[
          // TODO
          leftRight.leftDelim == null ? null : SymbolNode(symbol: leftRight.leftDelim!),
          leftRight.rightDelim == null ? null : SymbolNode(symbol: leftRight.rightDelim!),
          frac.barSize,
          (node as StyleNode).optionsDiff.style?.size,
          ...frac.children,
        ],
      );
      final remainingOptions = node.optionsDiff.removeStyle();
      texEncodingCache[node] =
          remainingOptions.isEmpty ? res : _optionsDiffEncode(remainingOptions, <dynamic>[res]);
    },
  ),
  OptimizationEntry(
    matcher: isA<StyleNode>(
      matchSelf: (final node) => node.optionsDiff.style != null,
      child: isA<FracNode>(
        matchSelf: (final node) => node.continued == false,
      ),
    ),
    optimize: (final node) {
      final frac = (node.children.first as FracNode?)!;
      final res = TexCommandEncodeResult(
        command: '\\genfrac',
        args: <dynamic>[
          null,
          null,
          frac.barSize,
          (node as StyleNode).optionsDiff.style?.size,
          ...frac.children,
        ],
      );
      final remainingOptions = node.optionsDiff.removeStyle();
      texEncodingCache[node] =
          remainingOptions.isEmpty ? res : _optionsDiffEncode(remainingOptions, <dynamic>[res]);
    },
  ),
];

EncodeResult _leftRightEncoder(final GreenNode node) {
  final leftRightNode = node as LeftRightNode;
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

EncodeResult _multisciprtsEncoder(final GreenNode node) {
  final scriptsNode = node as MultiscriptsNode;
  return TexMultiscriptEncodeResult(
    base: scriptsNode.base,
    sub: scriptsNode.sub,
    sup: scriptsNode.sup,
    presub: scriptsNode.presub,
    presup: scriptsNode.presup,
  );
}

EncodeResult _naryEncoder(final GreenNode node) {
  final naryNode = node as NaryOperatorNode;
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

EncodeResult _sqrtEncoder(final GreenNode node) {
  final sqrtNode = node as SqrtNode;
  return TexCommandEncodeResult(
    command: '\\sqrt',
    args: sqrtNode.children,
  );
}

EncodeResult _stretchyOpEncoder(
  final GreenNode node,
) {
  final arrowNode = node as StretchyOpNode;
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

EncodeResult _styleEncoder(final GreenNode node) {
  final styleNode = node as StyleNode;
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
      command: styleCommand ?? _styleCommands[diff.style!.uncramp()]!,
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

EncodeResult _symbolEncoder(final GreenNode node) {
  final symbolNode = node as SymbolNode;
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
  candidates.sortBy<num>((final candidate) {
    final candidFont = candidate.value.font;
    final fontScore = candidFont == overrideFont
        ? 1000
        : (candidFont?.fontFamily == overrideFont?.fontFamily ? 500 : 0) +
            (candidFont?.fontShape == overrideFont?.fontShape ? 300 : 0) +
            (candidFont?.fontWeight == overrideFont?.fontWeight ? 200 : 0);
    final typeScore = candidate.value.type == overrideType
        ? 150
        : candidate.value.type == type
            ? 100
            : 0;
    final commandConciseness = 100 ~/ candidate.key.length -
        100 * candidate.key.runes.where((final point) => point > 126 || point < 32).length;
    return fontScore + typeScore + commandConciseness;
  });
  return candidates.lastOrNull?.key;
}
