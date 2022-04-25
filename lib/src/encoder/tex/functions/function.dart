part of '../functions.dart';

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
          matchSelf: (final node) =>
              node.optionsDiff.mathFontOptions ==
              texMathFontOptions['\\mathrm'],
        ),
      ),
    ),
    optimize: (final node) {
      final functionNode = node as FunctionNode;
      texEncodingCache[node] = TransparentTexEncodeResult(<dynamic>[
        TexCommandEncodeResult(command: '\\operatorname', args: <dynamic>[
          _optionsDiffEncode(
            (functionNode.functionName.children.first as StyleNode)
                .optionsDiff
                .removeMathFont(),
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
      final scriptsNode =
          functionNode.functionName.children.first as MultiscriptsNode;
      final name =
          '\\${scriptsNode.base.children.map((final child) => (child as SymbolNode).symbol).join()}';

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
      final name =
          '\\${nameNode.children.map((final child) => (child as SymbolNode).symbol).join()}';

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
