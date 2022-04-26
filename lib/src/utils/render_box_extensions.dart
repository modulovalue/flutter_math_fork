import 'package:flutter/rendering.dart';
import 'extensions.dart';

T? renderBoxHittestFindLowest<T>(
  final RenderBox renderBox,
  final Offset localOffset,
) {
  final result = BoxHitTestResult();
  renderBox.hitTest(
    result,
    position: localOffset,
  );
  final target = result.path
      .firstWhereOrNull(
        (final element) => element.target is T,
      )
      ?.target as T?;
  return target;
}
