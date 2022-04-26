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

/// Returns the size of render box given the provided [BoxConstraints].
///
/// The `dry` flag indicates that no real layout pass but only a dry
/// layout pass should be executed on the render box.
/// Defaults to true.
Size renderBoxGetLayoutSize(
  final RenderBox renderBox,
  final BoxConstraints constraints, {
  final bool dry = true,
}) {
  if (dry) {
    return renderBox.getDryLayout(
      constraints,
    );
  } else {
    renderBox.layout(
      constraints,
      parentUsesSize: true,
    );
    return renderBox.size;
  }
}

Type getTypeOf<T>() => T;
