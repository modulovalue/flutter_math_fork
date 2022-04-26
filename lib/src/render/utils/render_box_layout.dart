import 'dart:ui';

import 'package:flutter/rendering.dart';

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
