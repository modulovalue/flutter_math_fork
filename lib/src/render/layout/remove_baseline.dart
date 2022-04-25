import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class RemoveBaseline extends SingleChildRenderObjectWidget {
  const RemoveBaseline({
    final Key? key,
    required final Widget child,
  }) : super(key: key, child: child);

  @override
  RenderRemoveBaseline createRenderObject(final BuildContext context) =>
      RenderRemoveBaseline();
}

class RenderRemoveBaseline extends RenderProxyBox {
  RenderRemoveBaseline({final RenderBox? child}) : super(child);

  @override
  // ignore: avoid_returning_null
  double? computeDistanceToActualBaseline(final TextBaseline baseline) => null;
}
