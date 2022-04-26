import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

T? renderBoxHittestFindLowest<T extends HitTestTarget>(
  final RenderBox renderBox,
  final Offset localOffset,
) {
  final result = BoxHitTestResult();
  renderBox.hitTest(
    result,
    position: localOffset,
  );
  for (final element in result.path) {
    final target = element.target;
    if (target is T) {
      return target;
    }
  }
  return null;
}
