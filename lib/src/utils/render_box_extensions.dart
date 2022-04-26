import 'package:flutter/rendering.dart';
import 'iterable_extensions.dart';

extension HittestExtension on RenderBox {
  T? hittestFindLowest<T>(
    final Offset localOffset,
  ) {
    final result = BoxHitTestResult();
    this.hitTest(
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
}
