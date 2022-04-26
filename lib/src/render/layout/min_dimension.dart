import 'dart:math';

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
    required final Widget child,
    final this.minHeight = 0,
    final this.minDepth = 0,
    final this.topPadding = 0,
    final this.bottomPadding = 0,
    final Key? key,
  }) : super(
          key: key,
          child: child,
        );

  @override
  RenderMinDimension createRenderObject(
    final BuildContext context,
  ) =>
      RenderMinDimension(
        minHeight: minHeight,
        minDepth: minDepth,
        topPadding: topPadding,
        bottomPadding: bottomPadding,
      );

  @override
  void updateRenderObject(
    final BuildContext context,
    final RenderMinDimension renderObject,
  ) =>
      renderObject
        ..minHeight = minHeight
        ..minDepth = minDepth
        ..topPadding = topPadding
        ..bottomPadding = bottomPadding;
}

class RenderMinDimension extends RenderShiftedBox {
  RenderMinDimension({
    final RenderBox? child,
    final double minHeight = 0,
    final double minDepth = 0,
    final double topPadding = 0,
    final double bottomPadding = 0,
  })  : _minHeight = minHeight,
        _minDepth = minDepth,
        _topPadding = topPadding,
        _bottomPadding = bottomPadding,
        super(child);

  double get minHeight => _minHeight;
  double _minHeight;

  set minHeight(
    final double value,
  ) {
    if (_minHeight != value) {
      _minHeight = value;
      markNeedsLayout();
    }
  }

  double get minDepth => _minDepth;
  double _minDepth;

  set minDepth(
    final double value,
  ) {
    if (_minDepth != value) {
      _minDepth = value;
      markNeedsLayout();
    }
  }

  double get topPadding => _topPadding;
  double _topPadding;

  set topPadding(
    final double value,
  ) {
    if (_topPadding != value) {
      _topPadding = value;
      markNeedsLayout();
    }
  }

  double get bottomPadding => _bottomPadding;
  double _bottomPadding;

  set bottomPadding(
    final double value,
  ) {
    if (_bottomPadding != value) {
      _bottomPadding = value;
      markNeedsLayout();
    }
  }

  @override
  double computeMinIntrinsicHeight(
    final double width,
  ) =>
      max(
        minHeight + minDepth,
        super.computeMinIntrinsicHeight(width) + topPadding + bottomPadding,
      );

  @override
  double computeMaxIntrinsicHeight(
    final double width,
  ) =>
      max(
        minHeight + minDepth,
        super.computeMaxIntrinsicHeight(width) + topPadding + bottomPadding,
      );

  double distanceToBaseline = 0.0;

  @override
  double computeDistanceToActualBaseline(
    final TextBaseline baseline,
  ) =>
      distanceToBaseline;

  @override
  Size computeDryLayout(
    final BoxConstraints constraints,
  ) =>
      _computeLayout(constraints);

  @override
  void performLayout() {
    size = _computeLayout(constraints, dry: false);
  }

  Size _computeLayout(
    final BoxConstraints constraints, {
    final bool dry = true,
  }) {
    final child = this.child!;
    final childSize = renderBoxGetLayoutSize(
      child,
      constraints,
      dry: dry,
    );
    final childHeight = () {
      if (dry) {
        return 0;
      } else {
        return child.getDistanceToBaseline(
          TextBaseline.alphabetic,
        )!;
      }
    }();
    final childDepth = childSize.height - childHeight;
    final width = childSize.width;
    final height = max(
      minHeight,
      childHeight + topPadding,
    );
    final depth = max(
      minDepth,
      childDepth + bottomPadding,
    );
    if (!dry) {
      setRenderBoxOffset(
        child,
        Offset(
          0,
          height - childHeight,
        ),
      );
      distanceToBaseline = height;
    }
    return constraints.constrain(
      Size(
        width,
        height + depth,
      ),
    );
  }
}
