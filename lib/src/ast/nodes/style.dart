import '../options.dart';
import '../syntax_tree.dart';

/// Node to denote all kinds of style changes.
class StyleNode extends TransparentNode {
  @override
  final List<GreenNode> children;

  /// The difference of [MathOptions].
  final OptionsDiff optionsDiff;

  StyleNode({
    required this.children,
    required this.optionsDiff,
  });

  @override
  List<MathOptions> computeChildOptions(final MathOptions options) =>
      List.filled(children.length, options.merge(optionsDiff), growable: false);

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) =>
      false;

  @override
  ParentableNode<GreenNode> updateChildren(final List<GreenNode> newChildren) =>
      copyWith(children: newChildren);

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'children': children.map((final e) => e.toJson()).toList(growable: false),
      'optionsDiff': optionsDiff.toString(),
    });

  StyleNode copyWith({
    final List<GreenNode>? children,
    final OptionsDiff? optionsDiff,
  }) =>
      StyleNode(
        children: children ?? this.children,
        optionsDiff: optionsDiff ?? this.optionsDiff,
      );
}
