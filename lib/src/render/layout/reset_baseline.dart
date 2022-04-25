import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ResetBaseline extends SingleChildRenderObjectWidget {
  final double height;
  const ResetBaseline({
    required final this.height,
    required final Widget child,
    final Key? key,
  }) : super(key: key, child: child,);

  @override
  RenderResetBaseline createRenderObject(final BuildContext context) =>
      RenderResetBaseline(height: height);

  @override
  void updateRenderObject(
          final BuildContext context, final RenderResetBaseline renderObject) =>
      renderObject..height = height;
}

class RenderResetBaseline extends RenderProxyBox {
  RenderResetBaseline({required final double height, final RenderBox? child})
      : _height = height,
        super(child);

  double get height => _height;
  double _height;
  set height(final double value) {
    if (_height != value) {
      _height = value;
      markNeedsLayout();
    }
  }

  @override
  double computeDistanceToActualBaseline(final TextBaseline baseline) => height;
}
