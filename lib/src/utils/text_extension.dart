import 'package:flutter/widgets.dart';
import 'num_extension.dart';

extension TextSelectionExt on TextSelection {
  bool within(final TextRange range) =>
      this.start >= range.start && this.end <= range.end;
  TextSelection constrainedBy(final TextRange range) => TextSelection(
        baseOffset: this.baseOffset.clampInt(range.start, range.end),
        extentOffset: this.extentOffset.clampInt(range.start, range.end),
      );
}
