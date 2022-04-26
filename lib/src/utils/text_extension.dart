import 'package:flutter/widgets.dart';
import 'extensions.dart';

TextSelection textSelectionConstrainedBy(
  final TextSelection selection,
  final TextRange range,
) =>
    TextSelection(
      baseOffset: clampInteger(
        selection.baseOffset,
        range.start,
        range.end,
      ),
      extentOffset: clampInteger(
        selection.extentOffset,
        range.start,
        range.end,
      ),
    );

bool textSelectionWithin(
  final TextSelection selection,
  final TextRange range,
) =>
    selection.start >= range.start && selection.end <= range.end;
