import 'package:flutter/widgets.dart';
import 'extensions.dart';

TextSelection textSelectionConstrainedBy(
  final TextSelection selection,
  final TextRange range,
) =>
    TextSelection(
      baseOffset: selection.baseOffset.clampInt(range.start, range.end),
      extentOffset: selection.extentOffset.clampInt(range.start, range.end),
    );

bool textSelectionWithin(
  final TextSelection selection,
  final TextRange range,
) =>
    selection.start >= range.start && selection.end <= range.end;
