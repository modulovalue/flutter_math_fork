import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ShiftBaseline extends SingleChildRenderObjectWidget {
  const ShiftBaseline({
    required final Widget child,
    final this.relativePos,
    final this.offset = 0,
    final Key? key,
  }) : super(key: key, child: child);

  final double? relativePos;

  final double offset;

  @override
  RenderShiftBaseline createRenderObject(final BuildContext context) =>
      RenderShiftBaseline(relativePos: relativePos, offset: offset);

  @override
  void updateRenderObject(
      final BuildContext context, final RenderShiftBaseline renderObject) {
    renderObject
      ..relativePos = relativePos
      ..offset = offset;
  }
}

class RenderShiftBaseline extends RenderProxyBox {
  RenderShiftBaseline({
    final RenderBox? child,
    final double? relativePos,
    final double offset = 0,
  })  : _relativePos = relativePos,
        _offset = offset,
        super(child);

  double? get relativePos => _relativePos;
  double? _relativePos;
  set relativePos(final double? value) {
    if (_relativePos != value) {
      _relativePos = value;
      markNeedsLayout();
    }
  }

  double get offset => _offset;
  double _offset;
  set offset(final double value) {
    if (_offset != value) {
      _offset = value;
      markNeedsLayout();
    }
  }

  var _height = 0.0;

  @override
  Size computeDryLayout(final BoxConstraints constraints) =>
      child?.getDryLayout(constraints) ?? Size.zero;

  @override
  double? computeDistanceToActualBaseline(final TextBaseline baseline) {
    if (relativePos != null) {
      return relativePos! * _height + offset;
    }
    if (child != null) {
      // assert(!debugNeedsLayout);
      final childBaselineDistance =
          child!.getDistanceToActualBaseline(baseline) ?? _height;
      //ignore: avoid_returning_null
      // if (childBaselineDistance == null) return null;
      return childBaselineDistance + offset;
    } else {
      return super.computeDistanceToActualBaseline(baseline);
    }
  }

  @override
  void performLayout() {
    super.performLayout();
    // We have to hack like this to know the height of this object!!!
    _height = size.height;
  }
}
