import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class LayoutBuilderPreserveBaseline
    extends ConstrainedLayoutBuilder<BoxConstraints> {
  /// Creates a widget that defers its building until layout.
  ///
  /// The [builder] argument must not be null.
  const LayoutBuilderPreserveBaseline({
    final Key? key,
    required final LayoutWidgetBuilder builder,
  }) : super(key: key, builder: builder);

  @override
  LayoutWidgetBuilder get builder => super.builder;

  @override
  _RenderLayoutBuilderPreserveBaseline createRenderObject(
          final BuildContext context) =>
      _RenderLayoutBuilderPreserveBaseline();
}

class _RenderLayoutBuilderPreserveBaseline extends RenderBox
    with
        RenderObjectWithChildMixin<RenderBox>,
        RenderConstrainedLayoutBuilder<BoxConstraints, RenderBox> {
  @override
  double? computeDistanceToActualBaseline(final TextBaseline baseline) =>
      child?.getDistanceToActualBaseline(baseline);

  @override
  double computeMinIntrinsicWidth(final double height) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(final double height) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(final double width) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(final double width) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  Size computeDryLayout(final BoxConstraints constraints) =>
      child?.getDryLayout(constraints) ?? Size.zero;

  @override
  void performLayout() {
    final constraints = this.constraints;
    // layoutAndBuildChild(); // Flutter >=1.17.0 <1.18.0
    rebuildIfNecessary(); // Flutter >=1.18.0
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child!.size);
    } else {
      size = constraints.biggest;
    }
  }

  @override
  bool hitTestChildren(final BoxHitTestResult result, {required final Offset position}) =>
      child?.hitTest(result, position: position) ?? false;

  @override
  void paint(final PaintingContext context, final Offset offset) {
    if (child != null) context.paintChild(child!, offset);
  }

  bool _debugThrowIfNotCheckingIntrinsics() {
    assert(() {
      if (!RenderObject.debugCheckingIntrinsics) {
        throw FlutterError(
            'LayoutBuilder does not support returning intrinsic dimensions.\n'
            'Calculating the intrinsic dimensions would require '
            'running the layout '
            'callback speculatively, which might mutate the live '
            'render object tree.');
      }
      return true;
    }());

    return true;
  }
}
