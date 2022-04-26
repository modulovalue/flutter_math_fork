import 'dart:ui';

import 'package:flutter/rendering.dart';

Offset renderBoxOffset(
  final RenderBox box,
) {
  return (box.parentData as BoxParentData?)!.offset;
}

void setRenderBoxOffset(
  final RenderBox box,
  final Offset value,
) {
  (box.parentData as BoxParentData?)!.offset = value;
}

double renderBoxLayoutHeight(
  final RenderBox box,
) {
  return box.getDistanceToBaseline(
    TextBaseline.alphabetic,
  )!;
}

double renderBoxLayoutDepth(
  final RenderBox box,
) {
  return box.size.height -
      box.getDistanceToBaseline(
        TextBaseline.alphabetic,
      )!;
}
