import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../utils/render_box_layout.dart';
import '../utils/render_box_offset.dart';

class ResetDimension extends SingleChildRenderObjectWidget {
  final double? height;
  final double? depth;
  final double? width;
  final CrossAxisAlignment horizontalAlignment;

  const ResetDimension({
    required final Widget child,
    final this.height,
    final this.depth,
    final this.width,
    final this.horizontalAlignment = CrossAxisAlignment.center,
    final Key? key,
  }) : super(key: key, child: child);

  @override
  RenderResetDimension createRenderObject(final BuildContext context) =>
      RenderResetDimension(
        layoutHeight: height,
        layoutWidth: width,
        layoutDepth: depth,
        horizontalAlignment: horizontalAlignment,
      );

  @override
  void updateRenderObject(
          final BuildContext context, final RenderResetDimension renderObject) =>
      renderObject
        ..layoutHeight = height
        ..layoutDepth = depth
        ..layoutWidth = width
        ..horizontalAlignment = horizontalAlignment;
}

class RenderResetDimension extends RenderShiftedBox {
  RenderResetDimension({
    final RenderBox? child,
    final double? layoutHeight,
    final double? layoutDepth,
    final double? layoutWidth,
    CrossAxisAlignment horizontalAlignment = CrossAxisAlignment.center,
  })  : _layoutHeight = layoutHeight,
        _layoutDepth = layoutDepth,
        _layoutWidth = layoutWidth,
        _horizontalAlignment = horizontalAlignment,
        super(child);

  double? get layoutHeight => _layoutHeight;
  double? _layoutHeight;
  set layoutHeight(final double? value) {
    if (_layoutHeight != value) {
      _layoutHeight = value;
      markNeedsLayout();
    }
  }

  double? get layoutDepth => _layoutDepth;
  double? _layoutDepth;
  set layoutDepth(final double? value) {
    if (_layoutDepth != value) {
      _layoutDepth = value;
      markNeedsLayout();
    }
  }

  double? get layoutWidth => _layoutWidth;
  double? _layoutWidth;
  set layoutWidth(final double? value) {
    if (_layoutWidth != value) {
      _layoutWidth = value;
      markNeedsLayout();
    }
  }

  CrossAxisAlignment get horizontalAlignment => _horizontalAlignment;
  CrossAxisAlignment _horizontalAlignment;
  set horizontalAlignment(final CrossAxisAlignment value) {
    if (_horizontalAlignment != value) {
      _horizontalAlignment = value;
      markNeedsLayout();
    }
  }

  @override
  double computeMinIntrinsicWidth(final double height) =>
      layoutWidth ?? super.computeMinIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(final double height) =>
      layoutWidth ?? super.computeMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(final double width) {
    if (layoutHeight == null && layoutDepth == null) {
      return super.computeMinIntrinsicHeight(width);
    }
    if (layoutHeight != null && layoutDepth != null) {
      return layoutHeight! + layoutDepth!;
    }
    return 0;
  }

  @override
  double computeMaxIntrinsicHeight(final double width) {
    if (layoutHeight == null && layoutDepth == null) {
      return super.computeMaxIntrinsicHeight(width);
    }
    if (layoutHeight != null && layoutDepth != null) {
      return layoutHeight! + layoutDepth!;
    }
    return 0;
  }

  @override
  double? computeDistanceToActualBaseline(final TextBaseline baseline) =>
      layoutHeight ?? super.computeDistanceToActualBaseline(baseline);

  @override
  Size computeDryLayout(final BoxConstraints constraints) =>
      _computeLayout(constraints);

  @override
  void performLayout() {
    size = _computeLayout(constraints, dry: false);
  }

  Size _computeLayout(
    final BoxConstraints constraints, {
    bool dry = true,
  }) {
    final child = this.child!;
    final childSize = child.getLayoutSize(constraints, dry: dry);

    final childHeight =
        dry ? 0.0 : child.getDistanceToBaseline(TextBaseline.alphabetic)!;
    final childDepth = childSize.height - childHeight;
    final childWidth = childSize.width;

    final height = layoutHeight ?? childHeight;
    final depth = layoutDepth ?? childDepth;
    final width = layoutWidth ?? childWidth;

    var dx = 0.0;
    switch (horizontalAlignment) {
      case CrossAxisAlignment.start:
      case CrossAxisAlignment.stretch:
      case CrossAxisAlignment.baseline:
        break;
      case CrossAxisAlignment.end:
        dx = width - childWidth;
        break;
      case CrossAxisAlignment.center:
        dx = (width - childWidth) / 2;
        break;
    }

    if (!dry) {
      child.offset = Offset(dx, height - childHeight);
    }

    return Size(width, height + depth);
  }
}
