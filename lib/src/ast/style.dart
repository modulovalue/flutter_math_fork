import 'size.dart';

/// Math styles for equation elements.
///
/// \displaystyle \textstyle etc.
enum MathStyle {
  display,
  displayCramped,
  text,
  textCramped,
  script,
  scriptCramped,
  scriptscript,
  scriptscriptCramped,
}

enum MathStyleDiff {
  sub,
  sup,
  fracNum,
  fracDen,
  cramp,
  text,
  uncramp,
}

MathStyle? parseMathStyle(
  final String string,
) =>
    const {
      'display': MathStyle.display,
      'displayCramped': MathStyle.displayCramped,
      'text': MathStyle.text,
      'textCramped': MathStyle.textCramped,
      'script': MathStyle.script,
      'scriptCramped': MathStyle.scriptCramped,
      'scriptscript': MathStyle.scriptscript,
      'scriptscriptCramped': MathStyle.scriptscriptCramped,
    }[string];

bool mathStyleIsCramped(
  final MathStyle style,
) {
  return style.index.isEven;
}

int mathStyleSize(
  final MathStyle style,
) {
  return style.index ~/ 2;
}

// MathStyle get pureStyle => MathStyle.values[(this.index / 2).floor()];

MathStyle mathStyleReduce(
  final MathStyle style,
  final MathStyleDiff? diff,
) {
  if (diff == null) {
    return style;
  } else {
    return MathStyle.values[[
      [4, 5, 4, 5, 6, 7, 6, 7], //sup
      [5, 5, 5, 5, 7, 7, 7, 7], //sub
      [2, 3, 4, 5, 6, 7, 6, 7], //fracNum
      [3, 3, 5, 5, 7, 7, 7, 7], //fracDen
      [1, 1, 3, 3, 5, 5, 7, 7], //cramp
      [0, 1, 2, 3, 2, 3, 2, 3], //text
      [0, 0, 2, 2, 4, 4, 6, 6], //uncramp
    ][diff.index][style.index]];
  }
}

// MathStyle atLeastText() => this.index > MathStyle.textCramped.index ? this : MathStyle.text;

MathStyle mathStyleSup(
  final MathStyle style,
) =>
    mathStyleReduce(
      style,
      MathStyleDiff.sup,
    );

MathStyle mathStyleSub(
  final MathStyle style,
) =>
    mathStyleReduce(
      style,
      MathStyleDiff.sub,
    );

MathStyle mathStyleFracNum(
  final MathStyle style,
) =>
    mathStyleReduce(
      style,
      MathStyleDiff.fracNum,
    );

MathStyle mathStyleFracDen(
  final MathStyle style,
) =>
    mathStyleReduce(
      style,
      MathStyleDiff.fracDen,
    );

MathStyle mathStyleCramp(
  final MathStyle style,
) =>
    mathStyleReduce(
      style,
      MathStyleDiff.cramp,
    );

MathStyle mathStyleAtLeastText(
  final MathStyle style,
) =>
    mathStyleReduce(
      style,
      MathStyleDiff.text,
    );

MathStyle mathStyleUncramp(
  final MathStyle style,
) =>
    mathStyleReduce(
      style,
      MathStyleDiff.uncramp,
    );

// bool mathStyleIsTight(
//   final MathStyle style,
// ) =>
//     mathStyleSize(style) >= 2;

bool mathStyleGreater(
  final MathStyle left,
  final MathStyle right,
) =>
    left.index < right.index;

bool mathStyleLess(
  final MathStyle left,
  final MathStyle right,
) =>
    left.index > right.index;

bool mathStyleGreaterEquals(
  final MathStyle left,
  final MathStyle right,
) =>
    left.index <= right.index;

bool mathStyleLessEquals(
  final MathStyle left,
  final MathStyle right,
) =>
    left.index >= right.index;

MathStyle integerToMathStyle(
  final int i,
) =>
    MathStyle.values[(i * 2).clamp(0, 6)];

/// katex/src/Options.js/sizeStyleMap
MathSize mathSizeUnderStyle(
  final MathSize size,
  final MathStyle style,
) {
  if (mathStyleGreaterEquals(style, MathStyle.textCramped)) {
    return size;
  } else {
    final index = [
          [1, 1, 1],
          [2, 1, 1],
          [3, 1, 1],
          [4, 2, 1],
          [5, 2, 1],
          [6, 3, 1],
          [7, 4, 2],
          [8, 6, 3],
          [9, 7, 6],
          [10, 8, 7],
          [11, 10, 9],
        ][size.index][mathStyleSize(style) - 1] -
        1;
    return MathSize.values[index];
  }
}
