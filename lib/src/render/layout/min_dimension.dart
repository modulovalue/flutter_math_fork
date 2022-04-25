import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../utils/render_box_layout.dart';
import '../utils/render_box_offset.dart';

class MinDimension extends SingleChildRenderObjectWidget {
  final double minHeight;
  final double minDepth;
  final double topPadding;
  final double bottomPadding;

  const MinDimension({
    final Key? key,
    this.minHeight = 0,
    this.minDepth = 0,
    this.topPadding = 0,
    this.bottomPadding = 0,
    required final Widget child,
  }) : super(key: key, child: child);

  @override
  RenderMinDimension createRenderObject(final BuildContext context) =>
      RenderMinDimension(
        minHeight: minHeight,
        minDepth: minDepth,
        topPadding: topPadding,
        bottomPadding: bottomPadding,
      );

  @override
  void updateRenderObject(
          final BuildContext context, final RenderMinDimension renderObject) =>
      renderObject
        ..minHeight = minHeight
        ..minDepth = minDepth
        ..topPadding = topPadding
        ..bottomPadding = bottomPadding;
}

class RenderMinDimension extends RenderShiftedBox {
  RenderMinDimension({
    final RenderBox? child,
    double minHeight = 0,
    double minDepth = 0,
    double topPadding = 0,
    double bottomPadding = 0,
  })  : _minHeight = minHeight,
        _minDepth = minDepth,
        _topPadding = topPadding,
        _bottomPadding = bottomPadding,
        super(child);

  double get minHeight => _minHeight;
  double _minHeight;
  set minHeight(final double value) {
    if (_minHeight != value) {
      _minHeight = value;
      markNeedsLayout();
    }
  }

  double get minDepth => _minDepth;
  double _minDepth;
  set minDepth(final double value) {
    if (_minDepth != value) {
      _minDepth = value;
      markNeedsLayout();
    }
  }

  double get topPadding => _topPadding;
  double _topPadding;
  set topPadding(final double value) {
    if (_topPadding != value) {
      _topPadding = value;
      markNeedsLayout();
    }
  }

  double get bottomPadding => _bottomPadding;
  double _bottomPadding;
  set bottomPadding(final double value) {
    if (_bottomPadding != value) {
      _bottomPadding = value;
      markNeedsLayout();
    }
  }

  @override
  double computeMinIntrinsicHeight(final double width) => math.max(
        minHeight + minDepth,
        super.computeMinIntrinsicHeight(width) + topPadding + bottomPadding,
      );

  @override
  double computeMaxIntrinsicHeight(final double width) => math.max(
        minHeight + minDepth,
        super.computeMaxIntrinsicHeight(width) + topPadding + bottomPadding,
      );

  var distanceToBaseline = 0.0;

  @override
  double computeDistanceToActualBaseline(final TextBaseline baseline) =>
      distanceToBaseline;

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
        dry ? 0 : child.getDistanceToBaseline(TextBaseline.alphabetic)!;
    final childDepth = childSize.height - childHeight;
    final width = childSize.width;

    final height = math.max(minHeight, childHeight + topPadding);
    final depth = math.max(minDepth, childDepth + bottomPadding);

    if (!dry) {
      child.offset = Offset(0, height - childHeight);
      distanceToBaseline = height;
    }
    return constraints.constrain(Size(width, height + depth));
  }
}
