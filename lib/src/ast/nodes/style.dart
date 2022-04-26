import '../options.dart';
import '../syntax_tree.dart';

/// Node to denote all kinds of style changes.
class StyleNode extends TransparentNode<StyleNode> {
  @override
  final List<GreenNode> children;

  /// The difference of [MathOptions].
  final OptionsDiff optionsDiff;

  StyleNode({
    required final this.children,
    required final this.optionsDiff,
  });

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      List.filled(
        children.length,
        options.merge(optionsDiff),
        growable: false,
      );

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  StyleNode updateChildren(
    final List<GreenNode> newChildren,
  ) =>
      copyWith(children: newChildren);

  StyleNode copyWith({
    final List<GreenNode>? children,
    final OptionsDiff? optionsDiff,
  }) =>
      StyleNode(
        children: children ?? this.children,
        optionsDiff: optionsDiff ?? this.optionsDiff,
      );
}
