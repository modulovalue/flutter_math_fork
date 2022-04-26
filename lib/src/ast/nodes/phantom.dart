import 'package:flutter/cupertino.dart';

import '../../render/layout/reset_dimension.dart';
import '../options.dart';
import '../syntax_tree.dart';
import '../types.dart';

/// Phantom node.
///
/// Example: `\phantom` `\hphantom`.
class PhantomNode extends LeafNode {
  @override
  Mode get mode => Mode.math;

  /// The phantomed child.
  // TODO: suppress editbox in edit mode
  // If we use arbitrary GreenNode here, then we will face the danger of
  // transparent node
  final EquationRowNode phantomChild;

  /// Whether to eliminate width.
  final bool zeroWidth;

  /// Whether to eliminate height.
  final bool zeroHeight;

  /// Whether to eliminate depth.
  final bool zeroDepth;

  PhantomNode({
    required final this.phantomChild,
    final this.zeroHeight = false,
    final this.zeroWidth = false,
    final this.zeroDepth = false,
  });

  @override
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) {
    final phantomRedNode = SyntaxNode(parent: null, value: phantomChild, pos: 0);
    final phantomResult = phantomRedNode.buildWidget(options);
    Widget widget = Opacity(
      opacity: 0.0,
      child: phantomResult.widget,
    );
    widget = ResetDimension(
      width: zeroWidth ? 0 : null,
      height: zeroHeight ? 0 : null,
      depth: zeroDepth ? 0 : null,
      child: widget,
    );
    return BuildResult(
      options: options,
      italic: phantomResult.italic,
      widget: widget,
    );
  }

  @override
  AtomType get leftType => phantomChild.leftType;

  @override
  AtomType get rightType => phantomChild.rightType;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) =>
      phantomChild.shouldRebuildWidget(oldOptions, newOptions);
}
