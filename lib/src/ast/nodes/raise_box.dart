import '../../render/layout/shift_baseline.dart';
import '../options.dart';
import '../size.dart';
import '../syntax_tree.dart';

/// Raise box node which vertically displace its child.
///
/// Example: `\raisebox`
class RaiseBoxNode extends SlotableNode<EquationRowNode> {
  /// Child to raise.
  final EquationRowNode body;

  /// Vertical displacement.
  final Measurement dy;

  RaiseBoxNode({
    required this.body,
    required this.dy,
  });

  @override
  BuildResult buildWidget(
          final MathOptions options, final List<BuildResult?> childBuildResults) =>
      BuildResult(
        options: options,
        widget: ShiftBaseline(
          offset: dy.toLpUnder(options),
          child: childBuildResults[0]!.widget,
        ),
      );

  @override
  List<MathOptions> computeChildOptions(final MathOptions options) => [options];

  @override
  List<EquationRowNode> computeChildren() => [body];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) =>
      false;

  @override
  RaiseBoxNode updateChildren(final List<EquationRowNode> newChildren) =>
      copyWith(body: newChildren[0]);

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'body': body.toJson(),
      'dy': dy.toString(),
    });

  RaiseBoxNode copyWith({
    final EquationRowNode? body,
    final Measurement? dy,
  }) =>
      RaiseBoxNode(
        body: body ?? this.body,
        dy: dy ?? this.dy,
      );
}
