import '../../render/layout/line.dart';
import '../options.dart';
import '../spacing.dart';
import '../syntax_tree.dart';

/// Function node
///
/// Examples: `\sin`, `\lim`, `\operatorname`
class FunctionNode extends SlotableNode<FunctionNode, EquationRowNode> {
  /// Name of the function.
  final EquationRowNode functionName;

  /// Argument of the function.
  final EquationRowNode argument;

  FunctionNode({
    required final this.functionName,
    required final this.argument,
  });

  @override
  BuildResult buildWidget(
          final MathOptions options, final List<BuildResult?> childBuildResults) =>
      BuildResult(
        options: options,
        widget: Line(children: [
          LineElement(
            trailingMargin:
                getSpacingSize(AtomType.op, argument.leftType, options.style)
                    .toLpUnder(options),
            child: childBuildResults[0]!.widget,
          ),
          LineElement(
            trailingMargin: 0.0,
            child: childBuildResults[1]!.widget,
          ),
        ]),
      );

  @override
  List<MathOptions> computeChildOptions(final MathOptions options) =>
      List.filled(2, options, growable: false);

  @override
  List<EquationRowNode> computeChildren() => [functionName, argument];

  @override
  AtomType get leftType => AtomType.op;

  @override
  AtomType get rightType => argument.rightType;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) =>
      false;

  @override
  FunctionNode updateChildren(final List<EquationRowNode> newChildren) =>
      copyWith(functionName: newChildren[0], argument: newChildren[2]);

  FunctionNode copyWith({
    final EquationRowNode? functionName,
    final EquationRowNode? argument,
  }) =>
      FunctionNode(
        functionName: functionName ?? this.functionName,
        argument: argument ?? this.argument,
      );
}
