import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../font/font_metrics.dart';
import '../render/constants.dart';
import '../render/layout.dart';
import '../render/svg.dart';
import '../render/symbol.dart';
import '../render/util.dart';
import '../utils/extensions.dart';
import 'ast.dart';
import 'ast_impl.dart';
import 'symbols.dart';

TexGreenEquationrow emptyEquationRowNode() {
  return TexGreenEquationrowImpl(children: []);
}

TexGreenMatrixImpl matrixNodeSanitizedInputs({
  required final List<List<TexGreenEquationrow?>> body,
  final double arrayStretch = 1.0,
  final bool hskipBeforeAndAfter = false,
  final bool isSmall = false,
  final List<MatrixColumnAlign> columnAligns = const [],
  final List<MatrixSeparatorStyle> vLines = const [],
  final List<Measurement> rowSpacings = const [],
  final List<MatrixSeparatorStyle> hLines = const [],
}) {
  final cols = max3(
    body.map((final row) => row.length).maxOrNull ?? 0,
    columnAligns.length,
    vLines.length - 1,
  );
  final sanitizedColumnAligns = columnAligns.extendToByFill(cols, MatrixColumnAlign.center);
  final sanitizedVLines = vLines.extendToByFill(cols + 1, MatrixSeparatorStyle.none);
  final rows = max3(
    body.length,
    rowSpacings.length,
    hLines.length - 1,
  );
  final sanitizedBody = body
      .map((final row) => row.extendToByFill(cols, null))
      .toList(growable: false)
      .extendToByFill(rows, List.filled(cols, null));
  final sanitizedRowSpacing = rowSpacings.extendToByFill(rows, Measurement.zeroPt);
  final sanitizedHLines = hLines.extendToByFill(rows + 1, MatrixSeparatorStyle.none);
  return TexGreenMatrixImpl(
    rows: rows,
    cols: cols,
    arrayStretch: arrayStretch,
    hskipBeforeAndAfter: hskipBeforeAndAfter,
    isSmall: isSmall,
    columnAligns: sanitizedColumnAligns,
    vLines: sanitizedVLines,
    rowSpacings: sanitizedRowSpacing,
    hLines: sanitizedHLines,
    body: sanitizedBody,
  );
}

/// Wrap a node in [TexGreenEquationrow]
///
/// If this node is already [TexGreenEquationrow], then it won't be wrapped
TexGreenEquationrowImpl greenNodeWrapWithEquationRow(
  final TexGreen node,
) {
  if (node is TexGreenEquationrowImpl) {
    return node;
  } else {
    return TexGreenEquationrowImpl(
      children: [node],
    );
  }
}

TexGreenEquationrow? greenNodeWrapWithEquationRowOrNull(
  final TexGreen? node,
) {
  if (node == null) {
    return null;
  } else {
    return greenNodeWrapWithEquationRow(
      node,
    );
  }
}

/// If this node is [TexGreenEquationrow], its children will be returned. If not,
/// itself will be returned in a list.
List<TexGreen> greenNodeExpandEquationRow(
  final TexGreen node,
) {
  if (node is TexGreenEquationrow) {
    return node.children;
  } else {
    return [node];
  }
}

/// Wrap list of [TexGreen] in an [TexGreenEquationrow]
///
/// If the list only contain one [TexGreenEquationrow], then this note will be
/// returned.
TexGreenEquationrowImpl greenNodesWrapWithEquationRow(
  final List<TexGreen> nodes,
) {
  if (nodes.length == 1) {
    final first = nodes[0];
    if (first is TexGreenEquationrowImpl) {
      return first;
    } else {
      return TexGreenEquationrowImpl(
        children: nodes,
      );
    }
  }
  return TexGreenEquationrowImpl(
    children: nodes,
  );
}

extension DeOOPd on TexGreen {
  List<TexGreen?> get childrenl => match(
        nonleaf: (final a) => a.children,
        leaf: (final a) => const [],
      );

  int get editingWidthl => match(
        nonleaf: (final a) => a.editingWidth,
        leaf: (final a) => 1,
      );
}

enum Mode {
  math,
  text,
}

class AccentRenderConfig {
  final String? overChar;
  final String? overImageName;
  final String? underImageName;

  const AccentRenderConfig({
    final this.overChar,
    final this.overImageName,
    final this.underImageName,
  });
}

const accentRenderConfigs = {
  '\u005e': AccentRenderConfig(
    // '\u0302'
    overChar: '\u005e', // \hat
    overImageName: 'widehat',
    // alwaysShifty: true,
  ),
  '\u02c7': AccentRenderConfig(
    // '\u030C'
    overChar: '\u02c7', // \check
    overImageName: 'widecheck',
    // alwaysShifty: true,
  ),
  '\u007e': AccentRenderConfig(
    // '\u0303'
    overChar: '\u007e', // \tilde
    overImageName: 'widetilde',
    underImageName: 'utilde',
    // alwaysShifty: true,
  ),
  '\u00b4': AccentRenderConfig(
    // '\u0301'
    overChar: '\u02ca', // \acute
  ),
  '\u0060': AccentRenderConfig(
    // '\u0300'
    overChar: '\u02cb', // \grave
  ),
  '\u02d9': AccentRenderConfig(
    // '\u0307'
    overChar: '\u02d9', // \dot
  ),
  '\u00a8': AccentRenderConfig(
    // '\u0308'
    overChar: '\u00a8', // \ddot
  ),
  // '\u20DB': AccentRenderConfig(
  //   isOverAccent: true,
  //   symbol: '', // \dddot
  //   svgName: '',
  // ),
  '\u00AF': AccentRenderConfig(
    // '\u0304'
    overChar: '\u02c9', // \bar
  ),
  '\u2192': AccentRenderConfig(
    // '\u20D7'
    overChar: '\u20d7', // \vec
    overImageName: 'overrightarrow',
    underImageName: 'underrightarrow',
  ),
  '\u02d8': AccentRenderConfig(
    // '\u0306'
    overChar: '\u02d8', // \breve
  ),
  '\u02da': AccentRenderConfig(
    // '\u030a'
    overChar: '\u02da', // \mathring
  ),
  '\u02dd': AccentRenderConfig(
    // '\u030b'
    overChar: '\u02dd', // \H
  ),
  '\u2190': AccentRenderConfig(
    // '\u20d6'
    overImageName: 'overleftarrow',
    underImageName: 'underleftarrow',
  ),
  '\u2194': AccentRenderConfig(
    // '\u20e1'
    overImageName: 'overleftrightarrow',
    underImageName: 'underleftrightarrow',
  ),

  '\u23de': AccentRenderConfig(
    overImageName: 'overbrace',
  ),

  '\u23df': AccentRenderConfig(
    underImageName: 'underbrace',
  ),

  ...katexCompatibleAccents,
};

const katexCompatibleAccents = {
  '\u21d2': AccentRenderConfig(
    // '\u21d2'
    overImageName: 'Overrightarrow',
  ),
  '\u23e0': AccentRenderConfig(
      // '\u0311'
      overImageName: 'overgroup',
      underImageName: 'undergroup'),
  // '\u': AccentRenderConfig(
  //   overImageName: 'overlinesegment',
  //   underImageName: 'underlinesegment',
  // ),
  '\u21bc': AccentRenderConfig(
    // '\u20d0'
    overImageName: 'overleftharpoon',
  ),
  '\u21c0': AccentRenderConfig(
    // '\u20d1'
    overImageName: 'overrightharpoon',
  ),
};

/// Line breaking results using standard TeX-style line breaking.
///
/// This function will return a list of `SyntaxTree` along with a list
/// of line breaking penalties.
///
/// {@macro flutter_math_fork.widgets.math.tex_break}
BreakResult<TexRedEquationrowImpl> syntaxTreeTexBreak({
  required final TexRedEquationrowImpl tree,
  final int relPenalty = 500,
  final int binOpPenalty = 700,
  final bool enforceNoBreak = true,
}) {
  final eqRowBreakResult = equationRowNodeTexBreak(
    tree: tree.greenValue,
    relPenalty: relPenalty,
    binOpPenalty: binOpPenalty,
    enforceNoBreak: true,
  );
  return BreakResult(
    parts: eqRowBreakResult.parts
        .map(
          (final part) => TexRedEquationrowImpl(
            greenValue: part,
          ),
        )
        .toList(
          growable: false,
        ),
    penalties: eqRowBreakResult.penalties,
  );
}

/// Line breaking results using standard TeX-style line breaking.
///
/// This function will return a list of `EquationRowNode` along with a list
/// of line breaking penalties.
///
/// {@macro flutter_math_fork.widgets.math.tex_break}
BreakResult<TexGreenEquationrowImpl> equationRowNodeTexBreak({
  required final TexGreenEquationrowImpl tree,
  final int relPenalty = 500,
  final int binOpPenalty = 700,
  final bool enforceNoBreak = true,
}) {
  final breakIndices = <int>[];
  final penalties = <int>[];
  for (int i = 0; i < tree.flattenedChildList.length; i++) {
    final child = tree.flattenedChildList[i];
    // Peek ahead to see if the next child is a no-break
    if (i < tree.flattenedChildList.length - 1) {
      final nextChild = tree.flattenedChildList[i + 1];
      if (nextChild is TexGreenSpace && nextChild.breakPenalty != null && nextChild.breakPenalty! >= 10000) {
        if (!enforceNoBreak) {
          // The break point should be moved to the next child, which is a \nobreak.
          continue;
        } else {
          // In enforced mode, we should cancel the break point all together.
          i++;
          continue;
        }
      }
    }
    if (child.rightType == AtomType.bin) {
      breakIndices.add(i);
      penalties.add(binOpPenalty);
    } else if (child.rightType == AtomType.rel) {
      breakIndices.add(i);
      penalties.add(relPenalty);
    } else if (child is TexGreenSpace && child.breakPenalty != null) {
      breakIndices.add(i);
      penalties.add(child.breakPenalty!);
    }
  }
  final res = <TexGreenEquationrowImpl>[];
  int pos = 1;
  for (var i = 0; i < breakIndices.length; i++) {
    final breakEnd = tree.caretPositions[breakIndices[i] + 1];
    res.add(
      greenNodeWrapWithEquationRow(
        texClipChildrenBetween<TexGreenEquationrowImpl>(
          tree,
          pos,
          breakEnd,
        ),
      ),
    );
    pos = breakEnd;
  }
  if (pos != tree.caretPositions.last) {
    res.add(
      greenNodeWrapWithEquationRow(
        texClipChildrenBetween<TexGreenEquationrowImpl>(
          tree,
          pos,
          tree.caretPositions.last,
        ),
      ),
    );
    penalties.add(10000);
  }
  return BreakResult<TexGreenEquationrowImpl>(
    parts: res,
    penalties: penalties,
  );
}

class BreakResult<T> {
  final List<T> parts;
  final List<int> penalties;

  const BreakResult({
    required final this.parts,
    required final this.penalties,
  });
}

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

final thinspace = Measurement.mu(3);
final mediumspace = Measurement.mu(4);
final thickspace = Measurement.mu(5);

final Map<AtomType, Map<AtomType, Measurement>> _spacings = {
  AtomType.ord: {
    AtomType.op: thinspace,
    AtomType.bin: mediumspace,
    AtomType.rel: thickspace,
    AtomType.inner: thinspace,
  },
  AtomType.op: {
    AtomType.ord: thinspace,
    AtomType.op: thinspace,
    AtomType.rel: thickspace,
    AtomType.inner: thinspace,
  },
  AtomType.bin: {
    AtomType.ord: mediumspace,
    AtomType.op: mediumspace,
    AtomType.open: mediumspace,
    AtomType.inner: mediumspace,
  },
  AtomType.rel: {
    AtomType.ord: thickspace,
    AtomType.op: thickspace,
    AtomType.open: thickspace,
    AtomType.inner: thickspace,
  },
  AtomType.open: {},
  AtomType.close: {
    AtomType.op: thinspace,
    AtomType.bin: mediumspace,
    AtomType.rel: thickspace,
    AtomType.inner: thinspace,
  },
  AtomType.punct: {
    AtomType.ord: thinspace,
    AtomType.op: thinspace,
    AtomType.rel: thickspace,
    AtomType.open: thinspace,
    AtomType.close: thinspace,
    AtomType.punct: thinspace,
    AtomType.inner: thinspace,
  },
  AtomType.inner: {
    AtomType.ord: thinspace,
    AtomType.op: thinspace,
    AtomType.bin: mediumspace,
    AtomType.rel: thickspace,
    AtomType.open: thinspace,
    AtomType.punct: thinspace,
    AtomType.inner: thinspace,
  },
  AtomType.spacing: {},
};

final Map<AtomType, Map<AtomType, Measurement>> _tightSpacings = {
  AtomType.ord: {
    AtomType.op: thinspace,
  },
  AtomType.op: {
    AtomType.ord: thinspace,
    AtomType.op: thinspace,
  },
  AtomType.bin: {},
  AtomType.rel: {},
  AtomType.open: {},
  AtomType.close: {
    AtomType.op: thinspace,
  },
  AtomType.punct: {},
  AtomType.inner: {
    AtomType.op: thinspace,
  },
  AtomType.spacing: {},
};

Measurement getSpacingSize(
  final AtomType left,
  final AtomType right,
  final MathStyle style,
) =>
    (mathStyleLessEquals(style, MathStyle.script)
        ? (_tightSpacings[left]?[right])
        : _spacings[left]?[right]) ??
    Measurement.zeroPt;

/// Options for equation element rendering.
///
/// Every [TexGreen] is rendered with an [MathOptions]. It controls their size,
/// color, font, etc.
///
/// [MathOptions] is immutable. Each modification returns a new instance of
/// [MathOptions].
class MathOptions {
  /// The style used to render the math node.
  ///
  /// For displayed equations, use [MathStyle.display].
  ///
  /// For in-line equations, use [MathStyle.text].
  final MathStyle style;

  /// Text color.
  final Color color;

  /// Real size applied to equation elements under current style.
  late final MathSize size = mathSizeUnderStyle(
    sizeUnderTextStyle,
    style,
  );

  /// Declared size for equation elements.
  ///
  /// User declared size such as \tiny \Huge. The real size applied to equation
  /// elements also depends on current style.
  final MathSize sizeUnderTextStyle;

  /// Font options for text mode.
  ///
  /// Text-mode font options will merge on top of each other. And they will be
  /// reset if any math-mode font style is declared
  final FontOptions? textFontOptions;

  /// Font options for math mode.
  ///
  /// Math-mode font options will override each other.
  final FontOptions? mathFontOptions;

  /// Size multiplier applied to equation elements.
  late final double sizeMultiplier = mathSizeSizeMultiplier(
    this.size,
  );

  // final double maxSize;
  // final num minRuleThickness; //???
  // final bool isBlank;

  /// Font metrics under current size.
  late final FontMetrics fontMetrics = getGlobalMetrics(size);

  /// Font size under current size.
  ///
  /// This is the font size passed to Flutter's [RichText] widget to build math
  /// symbols.
  final double fontSize;

  /// {@template flutter_math_fork.math_options.logicalPpi}
  /// Logical pixels per inch on screen.
  ///
  /// This parameter decides how big 1 inch is rendered on the screen. Affects
  /// the size of all equation elements whose size uses an absolute unit (e.g.
  /// pt, cm, inch).
  /// {@endtemplate}
  final double logicalPpi;

  /// Default factory for [MathOptions].
  ///
  /// If [fontSize] is null, then [MathOptions.defaultFontSize] will be used.
  ///
  /// If [logicalPpi] is null, then it will scale with [fontSize]. The default
  /// value for [MathOptions.defaultFontSize] is
  /// [MathOptions.defaultLogicalPpi].
  static MathOptions deflt({
    final MathStyle style = MathStyle.display,
    final Color color = Colors.black,
    final MathSize sizeUnderTextStyle = MathSize.normalsize,
    final FontOptions? textFontOptions,
    final FontOptions? mathFontOptions,
    final double? fontSize,
    final double? logicalPpi,
  }) {
    final effectiveFontSize = fontSize ??
        (() {
          if (logicalPpi == null) {
            return _defaultPtPerEm / Measurement.lp(1.0).toPoint()!;
          } else {
            return defaultFontSizeFor(logicalPpi: logicalPpi);
          }
        }());
    final effectiveLogicalPPI = logicalPpi ??
        defaultLogicalPpiFor(
          fontSize: effectiveFontSize,
        );
    return MathOptions._(
      fontSize: effectiveFontSize,
      logicalPpi: effectiveLogicalPPI,
      style: style,
      color: color,
      sizeUnderTextStyle: sizeUnderTextStyle,
      mathFontOptions: mathFontOptions,
      textFontOptions: textFontOptions,
    );
  }

  MathOptions._({
    required final this.fontSize,
    required final this.logicalPpi,
    required final this.style,
    final this.color = Colors.black,
    final this.sizeUnderTextStyle = MathSize.normalsize,
    final this.textFontOptions,
    final this.mathFontOptions,
  });

  static const _defaultLpPerPt = 72.27 / 160;

  static const _defaultPtPerEm = 10;

  /// Default value for [logicalPpi] is 160.
  ///
  /// The value 160 comes from the definition of an Android dp.
  ///
  /// Though Flutter provies a reference value for its logical pixel of
  /// [38 lp/cm](https://api.flutter.dev/flutter/dart-ui/Window/devicePixelRatio.html).
  /// However this value is simply too off from the scale so we use 160 lp/in.
  static const defaultLogicalPpi = 72.27 / _defaultLpPerPt;

  /// Default logical pixel count for 1 em is 1600/72.27.
  ///
  /// By default 1 em = 10 pt. 1 inch = 72.27 pt.
  ///
  /// See also [MathOptions.defaultLogicalPpi].
  static const defaultFontSize = _defaultPtPerEm / _defaultLpPerPt;

  /// Default value for [logicalPpi] when [fontSize] has been set.
  static double defaultLogicalPpiFor({
    required final double fontSize,
  }) =>
      fontSize * Measurement.inches(1.0).toPoint()! / _defaultPtPerEm;

  /// Default value for [fontSize] when [logicalPpi] has been set.
  static double defaultFontSizeFor({
    required final double logicalPpi,
  }) =>
      _defaultPtPerEm / Measurement.inches(1.0).toPoint()! * logicalPpi;

  /// Default options for displayed equations
  static final displayOptions = MathOptions._(
    fontSize: defaultFontSize,
    logicalPpi: defaultLogicalPpi,
    style: MathStyle.display,
  );

  /// Default options for in-line equations
  static final textOptions = MathOptions._(
    fontSize: defaultFontSize,
    logicalPpi: defaultLogicalPpi,
    style: MathStyle.text,
  );

  /// Returns [MathOptions] with given [MathStyle]
  MathOptions havingStyle(final MathStyle style) {
    if (this.style == style) return this;
    return this.copyWith(
      style: style,
    );
  }

  /// Returns [MathOptions] with their styles set to cramped (e.g. textCramped)
  MathOptions havingCrampedStyle() {
    if (mathStyleIsCramped(this.style)) {
      return this;
    } else {
      return this.copyWith(
        style: mathStyleCramp(style),
      );
    }
  }

  /// Returns [MathOptions] with their user-declared size set to given size
  MathOptions havingSize(
    final MathSize size,
  ) {
    if (this.size == size && this.sizeUnderTextStyle == size) {
      return this;
    }
    return this.copyWith(
      style: mathStyleAtLeastText(style),
      sizeUnderTextStyle: size,
    );
  }

  /// Returns [MathOptions] with size reset to [MathSize.normalsize] and given
  /// style. If style is not given, then the current style will be increased to
  /// at least [MathStyle.text]
  MathOptions havingStyleUnderBaseSize(MathStyle? style) {
    // ignore: parameter_assignments
    style = style ?? mathStyleAtLeastText(this.style);
    if (this.sizeUnderTextStyle == MathSize.normalsize && this.style == style) {
      return this;
    }
    return this.copyWith(
      style: style,
      sizeUnderTextStyle: MathSize.normalsize,
    );
  }

  /// Returns [MathOptions] with size reset to [MathSize.normalsize]
  MathOptions havingBaseSize() {
    if (this.sizeUnderTextStyle == MathSize.normalsize) return this;
    return this.copyWith(
      sizeUnderTextStyle: MathSize.normalsize,
    );
  }

  /// Returns [MathOptions] with given text color
  MathOptions withColor(final Color color) {
    if (this.color == color) return this;
    return this.copyWith(color: color);
  }

  /// Returns [MathOptions] with current text-mode font options merged with
  /// given font differences
  MathOptions withTextFont(final PartialFontOptions font) => this.copyWith(
        mathFontOptions: null,
        textFontOptions: (this.textFontOptions ?? const FontOptions()).mergeWith(font),
      );

  /// Returns [MathOptions] with given math font
  MathOptions withMathFont(final FontOptions font) {
    if (font == this.mathFontOptions) return this;
    return this.copyWith(mathFontOptions: font);
  }

  /// Utility method copyWith
  MathOptions copyWith({
    final MathStyle? style,
    final Color? color,
    final MathSize? sizeUnderTextStyle,
    final FontOptions? textFontOptions,
    final FontOptions? mathFontOptions,
    // double maxSize,
    // num minRuleThickness,
  }) =>
      MathOptions._(
        fontSize: this.fontSize,
        logicalPpi: this.logicalPpi,
        style: style ?? this.style,
        color: color ?? this.color,
        sizeUnderTextStyle: sizeUnderTextStyle ?? this.sizeUnderTextStyle,
        textFontOptions: textFontOptions ?? this.textFontOptions,
        mathFontOptions: mathFontOptions ?? this.mathFontOptions,
        // maxSize: maxSize ?? this.maxSize,
        // minRuleThickness: minRuleThickness ?? this.minRuleThickness,
      );

  /// Merge an [OptionsDiff] into current [MathOptions]
  MathOptions merge(final OptionsDiff partialOptions) {
    var res = this;
    if (partialOptions.size != null) {
      res = res.havingSize(partialOptions.size!);
    }
    if (partialOptions.style != null) {
      res = res.havingStyle(partialOptions.style!);
    }
    if (partialOptions.color != null) {
      res = res.withColor(partialOptions.color!);
    }
    // if (partialOptions.phantom == true) {
    //   res = res.withPhantom();
    // }
    if (partialOptions.textFontOptions != null) {
      res = res.withTextFont(partialOptions.textFontOptions!);
    }
    if (partialOptions.mathFontOptions != null) {
      res = res.withMathFont(partialOptions.mathFontOptions!);
    }
    return res;
  }
}

/// Difference between the current [MathOptions] and the desired [MathOptions].
///
/// This is used to declaratively describe the modifications to [MathOptions].
class OptionsDiff {
  /// Override [MathOptions.style]
  final MathStyle? style;

  /// Override declared size.
  final MathSize? size;

  /// Override text color.
  final Color? color;

  /// Merge font differences into text-mode font options.
  final PartialFontOptions? textFontOptions;

  /// Override math-mode font.
  final FontOptions? mathFontOptions;

  const OptionsDiff({
    final this.style,
    final this.color,
    final this.size,
    final this.textFontOptions,
    final this.mathFontOptions,
  });

  /// Whether this diff has no effect.
  bool get isEmpty =>
      style == null && color == null && size == null && textFontOptions == null && mathFontOptions == null;

  /// Strip the style change.
  OptionsDiff removeStyle() {
    if (style == null) return this;
    return OptionsDiff(
      color: this.color,
      size: this.size,
      textFontOptions: this.textFontOptions,
      mathFontOptions: this.mathFontOptions,
    );
  }

  /// Strip math font changes.
  OptionsDiff removeMathFont() {
    if (mathFontOptions == null) return this;
    return OptionsDiff(
      color: this.color,
      size: this.size,
      style: this.style,
      textFontOptions: this.textFontOptions,
    );
  }
}

/// Options for font selection.
class FontOptions {
  /// Font family. E.g. Main, Math, Sans-Serif, etc.
  final String fontFamily;

  /// Font weight. Bold or normal.
  final FontWeight fontWeight;

  /// Font weight. Italic or normal.
  final FontStyle fontShape;

  /// Fallback font options if a character cannot be found in this font.
  final List<FontOptions> fallback;

  const FontOptions({
    final this.fontFamily = 'Main',
    final this.fontWeight = FontWeight.normal,
    final this.fontShape = FontStyle.normal,
    final this.fallback = const [],
  });

  /// Complete font name. Used to index [CharacterMetrics].
  String get fontName {
    final postfix = '${fontWeight == FontWeight.bold ? 'Bold' : ''}'
        '${fontShape == FontStyle.italic ? "Italic" : ""}';
    return '$fontFamily-${postfix.isEmpty ? "Regular" : postfix}';
  }

  /// Utility method.
  FontOptions copyWith({
    final String? fontFamily,
    final FontWeight? fontWeight,
    final FontStyle? fontShape,
    final List<FontOptions>? fallback,
  }) =>
      FontOptions(
        fontFamily: fontFamily ?? this.fontFamily,
        fontWeight: fontWeight ?? this.fontWeight,
        fontShape: fontShape ?? this.fontShape,
        fallback: fallback ?? this.fallback,
      );

  /// Merge a font difference into current font.
  FontOptions mergeWith(final PartialFontOptions? value) {
    if (value == null) return this;
    return copyWith(
      fontFamily: value.fontFamily,
      fontWeight: value.fontWeight,
      fontShape: value.fontShape,
    );
  }

  @override
  bool operator ==(final Object o) {
    if (identical(this, o)) return true;

    return o is FontOptions &&
        o.fontFamily == fontFamily &&
        o.fontWeight == fontWeight &&
        o.fontShape == fontShape &&
        listEquals(o.fallback, fallback);
  }

  @override
  int get hashCode => hashValues(fontFamily.hashCode, fontWeight.hashCode, fontShape.hashCode);
}

/// Difference between the current [FontOptions] and the desired [FontOptions].
///
/// This is used to declaratively describe the modifications to [FontOptions].
class PartialFontOptions {
  /// Override font family.
  final String? fontFamily;

  /// Override font weight.
  final FontWeight? fontWeight;

  /// Override font style.
  final FontStyle? fontShape;

  const PartialFontOptions({
    final this.fontFamily,
    final this.fontWeight,
    final this.fontShape,
  });

  @override
  bool operator ==(final Object o) {
    if (identical(this, o)) return true;
    return o is PartialFontOptions &&
        o.fontFamily == fontFamily &&
        o.fontWeight == fontWeight &&
        o.fontShape == fontShape;
  }

  @override
  int get hashCode => hashValues(fontFamily.hashCode, fontWeight.hashCode, fontShape.hashCode);
}

class LinePainter extends CustomPainter {
  final double startRelativeX;
  final double startRelativeY;
  final double endRelativeX;
  final double endRelativeY;
  final double lineWidth;
  final Color color;

  const LinePainter({
    required final this.startRelativeX,
    required final this.startRelativeY,
    required final this.endRelativeX,
    required final this.endRelativeY,
    required final this.lineWidth,
    required final this.color,
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    canvas.drawLine(
      Offset(startRelativeX * size.width, startRelativeY * size.height),
      Offset(endRelativeX * size.width, endRelativeY * size.height),
      Paint()
        ..strokeWidth = lineWidth
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(
    final CustomPainter oldDelegate,
  ) =>
      this != oldDelegate;
}

class LayerLinkSelectionTuple {
  final TextSelection selection;
  final LayerLink? start;
  final LayerLink? end;

  const LayerLinkSelectionTuple({
    required final this.selection,
    required final this.start,
    required final this.end,
  });
}

class GreenBuildResult {
  final Widget widget;
  final MathOptions options;
  final double italic;
  final double skew;
  final List<GreenBuildResult>? results;

  const GreenBuildResult({
    required final this.widget,
    required final this.options,
    final this.italic = 0.0,
    final this.skew = 0.0,
    final this.results,
  });
}

/// Type of atoms. See TeXBook Chap.17
///
/// These following types will be determined by their repective [TexGreen] type
/// - over
/// - under
/// - acc
/// - rad
/// - vcent
enum AtomType {
  ord,
  op,
  bin,
  rel,
  open,
  close,
  punct,
  inner,
  spacing, // symbols
}

void traverseNonSpaceNodes(
  final List<NodeSpacingConf> childTypeList,
  final void Function(NodeSpacingConf? prev, NodeSpacingConf? curr) callback,
) {
  NodeSpacingConf? prev;
  // Tuple2<AtomType, AtomType> curr;
  for (final child in childTypeList) {
    if (child.leftType == AtomType.spacing || child.rightType == AtomType.spacing) {
      continue;
    }
    callback(prev, child);
    prev = child;
  }
  if (prev != null) {
    callback(prev, null);
  }
}

class NodeSpacingConf {
  AtomType leftType;
  AtomType rightType;
  MathOptions options;
  double spacingAfter;

  NodeSpacingConf(
    this.leftType,
    this.rightType,
    this.options,
    this.spacingAfter,
  );
}

const sqrtDelimieterSequence = [
  // DelimiterConf(mainRegular, MathStyle.scriptscript),
  // DelimiterConf(mainRegular, MathStyle.script),
  DelimiterConf(mainRegular, MathStyle.text),
  DelimiterConf(size1Regular, MathStyle.text),
  DelimiterConf(size2Regular, MathStyle.text),
  DelimiterConf(size3Regular, MathStyle.text),
  DelimiterConf(size4Regular, MathStyle.text),
];

const vbPad = 80;
const emPad = vbPad / 1000;

// We use a different strategy of picking \\surd font than KaTeX
// KaTeX chooses the style and font of the \\surd to cover inner at *normalsize*
// We will use a highly similar strategy while sticking to the strict meaning
// of TexBook Rule 11. We do not choose the style at *normalsize*
double getSqrtAdvanceWidth(
  final double minDelimiterHeight,
  final double baseWidth,
  final MathOptions options,
) {
  // final newOptions = options.havingBaseSize();
  final delimConf = sqrtDelimieterSequence.firstWhereOrNull(
    (final element) =>
        getHeightForDelim(
          delim: '\u221A', // √
          fontName: element.font.fontName,
          style: element.style,
          options: options,
        ) >
        minDelimiterHeight,
  );
  if (delimConf != null) {
    final delimOptions = options.havingStyle(delimConf.style);
    if (delimConf.font.fontName == 'Main-Regular') {
      return Measurement.cssem(0.833).toLpUnder(delimOptions);
    } else {
      // We will directly apply corresponding font
      final advanceWidth = Measurement.cssem(1.0).toLpUnder(delimOptions);
      return advanceWidth;
    }
  } else {
    final advanceWidth = Measurement.cssem(1.056).toLpUnder(options);
    return advanceWidth;
  }
}

// We use a different strategy of picking \\surd font than KaTeX
// KaTeX chooses the style and font of the \\surd to cover inner at *normalsize*
// We will use a highly similar strategy while sticking to the strict meaning
// of TexBook Rule 11. We do not choose the style at *normalsize*
Widget sqrtSvg({
  required final double minDelimiterHeight,
  required final double baseWidth,
  required final MathOptions options,
}) {
  // final newOptions = options.havingBaseSize();
  final delimConf = sqrtDelimieterSequence.firstWhereOrNull(
    (final element) =>
        getHeightForDelim(
          delim: '\u221A', // √
          fontName: element.font.fontName,
          style: element.style,
          options: options,
        ) >
        minDelimiterHeight,
  );

  const extraViniculum = 0.0; //math.max(0.0, options)
  // final ruleWidth =
  //     options.fontMetrics.sqrtRuleThickness.cssEm.toLpUnder(options);
  // TODO: support Settings.minRuleThickness.

  // These are the known height + depth for \u221A
  if (delimConf != null) {
    final fontHeight = const {
      'Main-Regular': 1.0,
      'Size1-Regular': 1.2,
      'Size2-Regular': 1.8,
      'Size3-Regular': 2.4,
      'Size4-Regular': 3.0,
    }[delimConf.font.fontName]!;
    final delimOptions = options.havingStyle(delimConf.style);
    final viewPortHeight = Measurement.cssem(fontHeight + extraViniculum + emPad).toLpUnder(delimOptions);
    if (delimConf.font.fontName == 'Main-Regular') {
      // We will be vertically stretching the sqrtMain path (by viewPort vs
      // viewBox) to mimic the height of \u221A under Main-Regular font and
      // corresponding Mathstyle.
      final advanceWidth = Measurement.cssem(0.833).toLpUnder(delimOptions);
      final viewPortWidth = advanceWidth + baseWidth;
      const viewBoxHeight = 1000 + 1000 * extraViniculum + vbPad;
      final viewBoxWidth = Measurement.lp(viewPortWidth).toCssEmUnder(delimOptions) * 1000;
      final svgPath = sqrtPath('sqrtMain', extraViniculum, viewBoxHeight);
      return ResetBaseline(
        height:
            Measurement.cssem(options.fontMetrics.sqrtRuleThickness + extraViniculum).toLpUnder(delimOptions),
        child: MinDimension(
          topPadding: Measurement.cssem(-emPad).toLpUnder(delimOptions),
          child: svgWidgetFromPath(
            svgPath,
            Size(viewPortWidth, viewPortHeight),
            Rect.fromLTWH(0, 0, viewBoxWidth, viewBoxHeight),
            options.color,
            align: Alignment.topLeft,
            fit: BoxFit.fill,
          ),
        ),
      );
    } else {
      // We will directly apply corresponding font
      final advanceWidth = Measurement.cssem(1.0).toLpUnder(delimOptions);
      final viewPortWidth = max(
        advanceWidth + baseWidth,
        Measurement.cssem(1.02).toCssEmUnder(delimOptions),
      );
      final viewBoxHeight = (1000 + vbPad) * fontHeight;
      final viewBoxWidth = Measurement.lp(viewPortWidth).toCssEmUnder(delimOptions) * 1000;
      final svgPath =
          sqrtPath('sqrt${delimConf.font.fontName.substring(0, 5)}', extraViniculum, viewBoxHeight);
      return ResetBaseline(
        height:
            Measurement.cssem(options.fontMetrics.sqrtRuleThickness + extraViniculum).toLpUnder(delimOptions),
        child: MinDimension(
          topPadding: Measurement.cssem(-emPad).toLpUnder(delimOptions),
          child: svgWidgetFromPath(
            svgPath,
            Size(viewPortWidth, viewPortHeight),
            Rect.fromLTWH(0, 0, viewBoxWidth, viewBoxHeight),
            options.color,
            align: Alignment.topLeft,
            fit: BoxFit.cover, // BoxFit.fitHeight, // For DomCanvas compatibility
          ),
        ),
      );
    }
  } else {
    // We will use the viewBoxHeight parameter in sqrtTall path
    final viewPortHeight = minDelimiterHeight + Measurement.cssem(extraViniculum + emPad).toLpUnder(options);
    final viewBoxHeight =
        1000 * Measurement.lp(minDelimiterHeight).toCssEmUnder(options) + extraViniculum + vbPad;
    final advanceWidth = Measurement.cssem(1.056).toLpUnder(options);
    final viewPortWidth = advanceWidth + baseWidth;
    final viewBoxWidth = Measurement.lp(viewPortWidth).toCssEmUnder(options) * 1000;
    final svgPath = sqrtPath('sqrtTall', extraViniculum, viewBoxHeight);
    return ResetBaseline(
      height: Measurement.cssem(options.fontMetrics.sqrtRuleThickness + extraViniculum).toLpUnder(options),
      child: MinDimension(
        topPadding: Measurement.cssem(-emPad).toLpUnder(options),
        child: svgWidgetFromPath(
          svgPath,
          Size(viewPortWidth, viewPortHeight),
          Rect.fromLTWH(0, 0, viewBoxWidth, viewBoxHeight),
          options.color,
          align: Alignment.topLeft,
          fit: BoxFit.cover, // BoxFit.fitHeight, // For DomCanvas compatibility
        ),
      ),
    );
  }
}

const stretchyOpMapping = {
  '\u2190': 'xleftarrow',
  '\u2192': 'xrightarrow',
  '\u2194': 'xleftrightarrow',
  '\u21d0': 'xLeftarrow',
  '\u21d2': 'xRightarrow',
  '\u21d4': 'xLeftrightarrow',
  '\u21a9': 'xhookleftarrow',
  '\u21aa': 'xhookrightarrow',
  '\u21a6': 'xmapsto',
  '\u21c1': 'xrightharpoondown',
  '\u21c0': 'xrightharpoonup',
  '\u21bd': 'xleftharpoondown',
  '\u21bc': 'xleftharpoonup',
  '\u21cc': 'xrightleftharpoons',
  '\u21cb': 'xleftrightharpoons',
  '=': 'xlongequal',
  '\u219e': 'xtwoheadleftarrow',
  '\u21a0': 'xtwoheadrightarrow',
  // '\u21c4': '\\xtofrom',
  '\u21c4': 'xrightleftarrows',
  // '\\xrightequilibrium': '\u21cc', // Not a perfect match.
  // '\\xleftequilibrium': '\u21cb', // None better available.
};

TexGreenEquationrow stringToNode(
  final String string, [
  final Mode mode = Mode.text,
]) =>
    TexGreenEquationrowImpl(
      children: string
          .split('')
          .map(
            (final ch) => TexGreenSymbolImpl(
              symbol: ch,
              mode: mode,
            ),
          )
          .toList(
            growable: false,
          ),
    );

AtomType getDefaultAtomTypeForSymbol(
  final String symbol, {
  required final Mode mode,
  final bool variantForm = false,
}) {
  SymbolRenderConfig? symbolRenderConfig = symbolRenderConfigs[symbol];
  if (variantForm) {
    symbolRenderConfig = symbolRenderConfig?.variantForm;
  }
  final renderConfig = mode == Mode.math ? symbolRenderConfig?.math : symbolRenderConfig?.text;
  if (renderConfig != null) {
    return renderConfig.defaultType ?? AtomType.ord;
  }
  if (variantForm == false && mode == Mode.math) {
    if (negatedOperatorSymbols.containsKey(symbol)) {
      return AtomType.rel;
    }
    if (compactedCompositeSymbols.containsKey(symbol)) {
      return compactedCompositeSymbolTypes[symbol]!;
    }
    if (decoratedEqualSymbols.contains(symbol)) {
      return AtomType.rel;
    }
  }
  return AtomType.ord;
}

bool isCombiningMark(
  final String ch,
) {
  final code = ch.codeUnitAt(0);
  return code >= 0x0300 && code <= 0x036f;
}

/// This render object overrides the return value of
// ignore: comment_references
/// [RenderProxyBox.computeDistanceToActualBaseline]
// ignore: comment_references
/// to align [TexGreenCursor] properly in a [RenderLine] with respect to symbols.
class BaselineDistance extends SingleChildRenderObjectWidget {
  const BaselineDistance({
    required final this.baselineDistance,
    final Key? key,
    final Widget? child,
  }) : super(key: key, child: child);

  final double baselineDistance;

  @override
  BaselineDistanceBox createRenderObject(
    final BuildContext context,
  ) =>
      BaselineDistanceBox(baselineDistance);
}

class BaselineDistanceBox extends RenderProxyBox {
  final double baselineDistance;

  BaselineDistanceBox(
    final this.baselineDistance,
  );

  @override
  double? computeDistanceToActualBaseline(
    final TextBaseline baseline,
  ) =>
      baselineDistance;
}

// TexBook Appendix B
const delimiterFactor = 901;

final delimiterShorfall = Measurement.pt(5.0);

const stackLargeDelimiters = {
  '(', ')',
  '[', ']',
  '{', '}',
  '\u230a', '\u230b', // '\\lfloor', '\\rfloor',
  '\u2308', '\u2309', // '\\lceil', '\\rceil',
  '\u221a', // '\\surd'
};

// delimiters that always stack
const stackAlwaysDelimiters = {
  '\u2191', // '\\uparrow',
  '\u2193', // '\\downarrow',
  '\u2195', // '\\updownarrow',
  '\u21d1', // '\\Uparrow',
  '\u21d3', // '\\Downarrow',
  '\u21d5', // '\\Updownarrow',
  '|',
  // '\\|',
  // '\\vert',
  '\u2016', // '\\Vert', '\u2225'
  '\u2223', // '\\lvert', '\\rvert', '\\mid'
  '\u2225', // '\\lVert', '\\rVert',
  '\u27ee', // '\\lgroup',
  '\u27ef', // '\\rgroup',
  '\u23b0', // '\\lmoustache',
  '\u23b1', // '\\rmoustache',
};

// and delimiters that never stack
const stackNeverDelimiters = {
  '\u27e8', //'<',
  '\u27e9', //'>',
  '/',
};

Widget buildCustomSizedDelimWidget(
  final String? delim,
  final double minDelimiterHeight,
  final MathOptions options,
) {
  if (delim == null) {
    final axisHeight = options.fontMetrics.xHeight2.toLpUnder(options);
    return ShiftBaseline(
      relativePos: 0.5,
      offset: axisHeight,
      child: SizedBox(
        height: minDelimiterHeight,
        width: nullDelimiterSpace.toLpUnder(options),
      ),
    );
  }
  List<DelimiterConf> sequence;
  if (stackNeverDelimiters.contains(delim)) {
    sequence = stackNeverDelimiterSequence;
  } else if (stackLargeDelimiters.contains(delim)) {
    sequence = stackLargeDelimiterSequence;
  } else {
    sequence = stackAlwaysDelimiterSequence;
  }
  var delimConf = sequence.firstWhereOrNull(
    (final element) =>
        getHeightForDelim(
          delim: delim,
          fontName: element.font.fontName,
          style: element.style,
          options: options,
        ) >
        minDelimiterHeight,
  );
  if (stackNeverDelimiters.contains(delim)) {
    delimConf ??= sequence.last;
  }

  if (delimConf != null) {
    final axisHeight = options.fontMetrics.axisHeight2.toLpUnder(options);
    return ShiftBaseline(
      relativePos: 0.5,
      offset: axisHeight,
      child: makeChar(delim, delimConf.font, lookupChar(delim, delimConf.font, Mode.math), options),
    );
  } else {
    return makeStackedDelim(delim, minDelimiterHeight, Mode.math, options);
  }
}

Widget makeStackedDelim(
  final String delim,
  final double minDelimiterHeight,
  final Mode mode,
  final MathOptions options,
) {
  final conf = stackDelimiterConfs[delim]!;
  final topMetrics = lookupChar(conf.top, conf.font, Mode.math)!;
  final repeatMetrics = lookupChar(conf.repeat, conf.font, Mode.math)!;
  final bottomMetrics = lookupChar(conf.bottom, conf.font, Mode.math)!;
  final topHeight = Measurement.cssem(topMetrics.height + topMetrics.depth).toLpUnder(options);
  final repeatHeight = Measurement.cssem(repeatMetrics.height + repeatMetrics.depth).toLpUnder(options);
  final bottomHeight = Measurement.cssem(bottomMetrics.height + bottomMetrics.depth).toLpUnder(options);
  double middleHeight = 0.0;
  int middleFactor = 1;
  CharacterMetrics? middleMetrics;
  if (conf.middle != null) {
    middleMetrics = lookupChar(conf.middle!, conf.font, Mode.math)!;
    middleHeight = Measurement.cssem(middleMetrics.height + middleMetrics.depth).toLpUnder(options);
    middleFactor = 2;
  }
  final minHeight = topHeight + bottomHeight + middleHeight;
  final repeatCount = max(0, (minDelimiterHeight - minHeight) / (repeatHeight * middleFactor)).ceil();
  // final realHeight = minHeight + repeatCount * middleFactor * repeatHeight;
  final axisHeight = options.fontMetrics.axisHeight2.toLpUnder(options);
  return ShiftBaseline(
    relativePos: 0.5,
    offset: axisHeight,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        makeChar(conf.top, conf.font, topMetrics, options),
        for (var i = 0; i < repeatCount; i++) makeChar(conf.repeat, conf.font, repeatMetrics, options),
        if (conf.middle != null) makeChar(conf.middle!, conf.font, middleMetrics!, options),
        if (conf.middle != null)
          for (var i = 0; i < repeatCount; i++) makeChar(conf.repeat, conf.font, repeatMetrics, options),
        makeChar(conf.bottom, conf.font, bottomMetrics, options),
      ],
    ),
  );
}

const size4Font = FontOptions(fontFamily: 'Size4');
const size1Font = FontOptions(fontFamily: 'Size1');

class StackDelimiterConf {
  final String top;
  final String? middle;
  final String repeat;
  final String bottom;
  final FontOptions font;

  const StackDelimiterConf({
    required final this.top,
    required final this.repeat,
    required final this.bottom,
    final this.middle,
    final this.font = size4Font,
  });
}

const stackDelimiterConfs = {
  '\u2191': // '\\uparrow',
      StackDelimiterConf(top: '\u2191', repeat: '\u23d0', bottom: '\u23d0', font: size1Font),
  '\u2193': // '\\downarrow',
      StackDelimiterConf(top: '\u23d0', repeat: '\u23d0', bottom: '\u2193', font: size1Font),
  '\u2195': // '\\updownarrow',
      StackDelimiterConf(top: '\u2191', repeat: '\u23d0', bottom: '\u2193', font: size1Font),
  '\u21d1': // '\\Uparrow',
      StackDelimiterConf(top: '\u21d1', repeat: '\u2016', bottom: '\u2016', font: size1Font),
  '\u21d3': // '\\Downarrow',
      StackDelimiterConf(top: '\u2016', repeat: '\u2016', bottom: '\u21d3', font: size1Font),
  '\u21d5': // '\\Updownarrow',
      StackDelimiterConf(top: '\u21d1', repeat: '\u2016', bottom: '\u21d3', font: size1Font),
  '|': // '\\|' ,'\\vert',
      StackDelimiterConf(top: '\u2223', repeat: '\u2223', bottom: '\u2223', font: size1Font),
  '\u2016': // '\\Vert', '\u2225'
      StackDelimiterConf(top: '\u2016', repeat: '\u2016', bottom: '\u2016', font: size1Font),
  '\u2223': // '\\lvert', '\\rvert', '\\mid'
      StackDelimiterConf(top: '\u2223', repeat: '\u2223', bottom: '\u2223', font: size1Font),
  '\u2225': // '\\lVert', '\\rVert',
      StackDelimiterConf(top: '\u2225', repeat: '\u2225', bottom: '\u2225', font: size1Font),
  '(': StackDelimiterConf(top: '\u239b', repeat: '\u239c', bottom: '\u239d'),
  ')': StackDelimiterConf(top: '\u239e', repeat: '\u239f', bottom: '\u23a0'),
  '[': StackDelimiterConf(top: '\u23a1', repeat: '\u23a2', bottom: '\u23a3'),
  ']': StackDelimiterConf(top: '\u23a4', repeat: '\u23a5', bottom: '\u23a6'),
  '{': StackDelimiterConf(top: '\u23a7', middle: '\u23a8', bottom: '\u23a9', repeat: '\u23aa'),
  '}': StackDelimiterConf(top: '\u23ab', middle: '\u23ac', bottom: '\u23ad', repeat: '\u23aa'),
  '\u230a': // '\\lfloor',
      StackDelimiterConf(top: '\u23a2', repeat: '\u23a2', bottom: '\u23a3'),
  '\u230b': // '\\rfloor',
      StackDelimiterConf(top: '\u23a5', repeat: '\u23a5', bottom: '\u23a6'),
  '\u2308': // '\\lceil',
      StackDelimiterConf(top: '\u23a1', repeat: '\u23a2', bottom: '\u23a2'),
  '\u2309': // '\\rceil',
      StackDelimiterConf(top: '\u23a4', repeat: '\u23a5', bottom: '\u23a5'),
  '\u27ee': // '\\lgroup',
      StackDelimiterConf(top: '\u23a7', repeat: '\u23aa', bottom: '\u23a9'),
  '\u27ef': // '\\rgroup',
      StackDelimiterConf(top: '\u23ab', repeat: '\u23aa', bottom: '\u23ad'),
  '\u23b0': // '\\lmoustache',
      StackDelimiterConf(top: '\u23a7', repeat: '\u23aa', bottom: '\u23ad'),
  '\u23b1': // '\\rmoustache',
      StackDelimiterConf(top: '\u23ab', repeat: '\u23aa', bottom: '\u23a9'),
};

enum MatrixSeparatorStyle {
  solid,
  dashed,
  none,
}

enum MatrixColumnAlign {
  left,
  center,
  right,
}

enum MatrixRowAlign {
  top,
  bottom,
  center,
  baseline,
  // axis,
}

class MatrixLayoutDelegate extends IntrinsicLayoutDelegate<int> {
  final int rows;
  final int cols;
  final double ruleThickness;
  final double arrayskip;
  final List<double> rowSpacings;
  final List<MatrixSeparatorStyle> hLines;
  final bool hskipBeforeAndAfter;
  final double arraycolsep;
  final List<MatrixSeparatorStyle> vLines;
  final List<MatrixColumnAlign> columnAligns;

  MatrixLayoutDelegate({
    required final this.rows,
    required final this.cols,
    required final this.ruleThickness,
    required final this.arrayskip,
    required final this.rowSpacings,
    required final this.hLines,
    required final this.hskipBeforeAndAfter,
    required final this.arraycolsep,
    required final this.vLines,
    required final this.columnAligns,
  })  : vLinePos = List.filled(cols + 1, 0.0, growable: false),
        hLinePos = List.filled(rows + 1, 0.0, growable: false);
  List<double> hLinePos;
  List<double> vLinePos;
  double totalHeight = 0.0;
  double width = 0.0;

  @override
  double? computeDistanceToActualBaseline(
    final TextBaseline baseline,
    final Map<int, RenderBox> childrenTable,
  ) =>
      null;

  @override
  AxisConfiguration<int> performHorizontalIntrinsicLayout({
    required final Map<int, double> childrenWidths,
    final bool isComputingIntrinsics = false,
  }) {
    final childWidths = List.generate(
      cols * rows,
      (final index) => childrenWidths[index] ?? 0.0,
      growable: false,
    );
    // Calculate width for each column
    final colWidths = List.filled(cols, 0.0, growable: false);
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        colWidths[i] = max(
          colWidths[i],
          childWidths[j * cols + i],
        );
      }
    }
    // Layout each column
    final colPos = List.filled(cols, 0.0, growable: false);
    final vLinePos = List.filled(cols + 1, 0.0, growable: false);
    double pos = 0.0;
    vLinePos[0] = pos;
    pos += (vLines[0] != MatrixSeparatorStyle.none) ? ruleThickness : 0.0;
    pos += hskipBeforeAndAfter ? arraycolsep : 0.0;
    for (int i = 0; i < cols - 1; i++) {
      colPos[i] = pos;
      pos += colWidths[i] + arraycolsep;
      vLinePos[i + 1] = pos;
      pos += (vLines[i + 1] != MatrixSeparatorStyle.none) ? ruleThickness : 0.0;
      pos += arraycolsep;
    }
    colPos[cols - 1] = pos;
    pos += colWidths[cols - 1];
    pos += hskipBeforeAndAfter ? arraycolsep : 0.0;
    vLinePos[cols] = pos;
    pos += (vLines[cols] != MatrixSeparatorStyle.none) ? ruleThickness : 0.0;
    width = pos;
    // Determine position of children
    final childPos = List.generate(
      rows * cols,
      (final index) {
        final col = index % cols;
        switch (columnAligns[col]) {
          case MatrixColumnAlign.left:
            return colPos[col];
          case MatrixColumnAlign.right:
            return colPos[col] + colWidths[col] - childWidths[index];
          case MatrixColumnAlign.center:
            return colPos[col] + (colWidths[col] - childWidths[index]) / 2;
        }
      },
      growable: false,
    );
    if (!isComputingIntrinsics) {
      this.vLinePos = vLinePos;
    }
    return AxisConfiguration(
      size: width,
      offsetTable: childPos.asMap(),
    );
  }

  @override
  AxisConfiguration<int> performVerticalIntrinsicLayout({
    required final Map<int, double> childrenHeights,
    required final Map<int, double> childrenBaselines,
    final bool isComputingIntrinsics = false,
  }) {
    final childHeights = List.generate(
      cols * rows,
      (final index) => childrenBaselines[index] ?? 0.0,
      growable: false,
    );
    final childDepth = List.generate(
      cols * rows,
      (final index) {
        final height = childrenBaselines[index];
        if (height != null) {
          return childrenHeights[index]! - height;
        } else {
          return 0.0;
        }
      },
      growable: false,
    );
    // Calculate height and depth for each row
    // Minimum height and depth are 0.7 * arrayskip and 0.3 * arrayskip
    final rowHeights = List.filled(rows, 0.7 * arrayskip, growable: false);
    final rowDepth = List.filled(rows, 0.3 * arrayskip, growable: false);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        rowHeights[i] = max(
          rowHeights[i],
          childHeights[i * cols + j],
        );
        rowDepth[i] = max(
          rowDepth[i],
          childDepth[i * cols + j],
        );
      }
    }
    // Layout rows
    double pos = 0.0;
    final rowBaselinePos = List.filled(rows, 0.0, growable: false);
    final hLinePos = List.filled(rows + 1, 0.0, growable: false);
    for (int i = 0; i < rows; i++) {
      hLinePos[i] = pos;
      pos += (hLines[i] != MatrixSeparatorStyle.none) ? ruleThickness : 0.0;
      pos += rowHeights[i];
      rowBaselinePos[i] = pos;
      pos += rowDepth[i];
      pos += i < rows - 1 ? rowSpacings[i] : 0;
    }
    hLinePos[rows] = pos;
    pos += (hLines[rows] != MatrixSeparatorStyle.none) ? ruleThickness : 0.0;
    totalHeight = pos;
    // Calculate position for each children
    final childPos = List.generate(
      rows * cols,
      (final index) {
        final row = index ~/ cols;
        return rowBaselinePos[row] - childHeights[index];
      },
      growable: false,
    );
    if (!isComputingIntrinsics) {
      this.hLinePos = hLinePos;
    }
    return AxisConfiguration(
      size: totalHeight,
      offsetTable: childPos.asMap(),
    );
  }

  // Paint vlines and hlines
  @override
  void additionalPaint(
    final PaintingContext context,
    final Offset offset,
  ) {
    const dashSize = 4;
    final paint = Paint()..strokeWidth = ruleThickness;
    for (int i = 0; i < hLines.length; i++) {
      switch (hLines[i]) {
        case MatrixSeparatorStyle.solid:
          context.canvas.drawLine(
            Offset(
              offset.dx,
              offset.dy + hLinePos[i] + ruleThickness / 2,
            ),
            Offset(
              offset.dx + width,
              offset.dy + hLinePos[i] + ruleThickness / 2,
            ),
            paint,
          );
          break;
        case MatrixSeparatorStyle.dashed:
          for (var dx = 0.0; dx < width; dx += dashSize) {
            context.canvas.drawLine(
              Offset(
                offset.dx + dx,
                offset.dy + hLinePos[i] + ruleThickness / 2,
              ),
              Offset(
                offset.dx + min(dx + dashSize / 2, width),
                offset.dy + hLinePos[i] + ruleThickness / 2,
              ),
              paint,
            );
          }
          break;
        case MatrixSeparatorStyle.none:
      }
    }

    for (var i = 0; i < vLines.length; i++) {
      switch (vLines[i]) {
        case MatrixSeparatorStyle.solid:
          context.canvas.drawLine(
              Offset(
                offset.dx + vLinePos[i] + ruleThickness / 2,
                offset.dy,
              ),
              Offset(
                offset.dx + vLinePos[i] + ruleThickness / 2,
                offset.dy + totalHeight,
              ),
              paint);
          break;
        case MatrixSeparatorStyle.dashed:
          for (var dy = 0.0; dy < totalHeight; dy += dashSize) {
            context.canvas.drawLine(
              Offset(
                offset.dx + vLinePos[i] + ruleThickness / 2,
                offset.dy + dy,
              ),
              Offset(
                offset.dx + vLinePos[i] + ruleThickness / 2,
                offset.dy + min(dy + dashSize / 2, totalHeight),
              ),
              paint,
            );
          }
          break;
        case MatrixSeparatorStyle.none:
          continue;
      }
    }
  }
}

const naryDefaultLimit = {
  '\u220F',
  '\u2210',
  '\u2211',
  '\u22c0',
  '\u22c1',
  '\u22c2',
  '\u22c3',
  '\u2a00',
  '\u2a01',
  '\u2a02',
  '\u2a04',
  '\u2a06',
};

const stashedOvalNaryOperator = {
  '\u222F': '\u222C',
  '\u2230': '\u222D',
};

enum SqrtPos {
  base,
  ind, // Name collision here
  surd,
}

// Square roots are handled in the TeXbook pg. 443, Rule 11.
class SqrtLayoutDelegate extends CustomLayoutDelegate<SqrtPos> {
  final MathOptions options;
  final MathOptions baseOptions;

  // final MathOptions indexOptions;

  SqrtLayoutDelegate({
    required final this.options,
    required final this.baseOptions,
    // required this.indexOptions,
  });

  double heightAboveBaseline = 0.0;
  double svgHorizontalPos = 0.0;
  double svgVerticalPos = 0.0;

  @override
  double computeDistanceToActualBaseline(
    final TextBaseline baseline,
    final Map<SqrtPos, RenderBox> childrenTable,
  ) =>
      heightAboveBaseline;

  @override
  double getIntrinsicSize({
    required final Axis sizingDirection,
    required final bool max,
    required final double extent,
    required final double Function(RenderBox child, double extent) childSize,
    required final Map<SqrtPos, RenderBox> childrenTable,
  }) =>
      0;

  @override
  Size computeLayout(
    final BoxConstraints constraints,
    final Map<SqrtPos, RenderBox> childrenTable, {
    final bool dry = true,
  }) {
    final base = childrenTable[SqrtPos.base]!;
    final index = childrenTable[SqrtPos.ind];
    final surd = childrenTable[SqrtPos.surd]!;
    final baseSize = renderBoxGetLayoutSize(
      base,
      infiniteConstraint,
      dry: dry,
    );
    final indexSize = () {
      if (index == null) {
        return Size.zero;
      } else {
        return renderBoxGetLayoutSize(
          index,
          infiniteConstraint,
          dry: dry,
        );
      }
    }();
    final baseHeight = () {
      if (dry) {
        return 0;
      } else {
        return renderBoxLayoutHeight(base);
      }
    }();
    final baseWidth = baseSize.width;
    final indexHeight = () {
      if (dry) {
        return 0;
      } else {
        if (index == null) {
          return 0.0;
        } else {
          return renderBoxLayoutHeight(index);
        }
      }
    }();
    final indexWidth = indexSize.width;
    final theta = Measurement.cssem(baseOptions.fontMetrics.defaultRuleThickness).toLpUnder(baseOptions);
    final phi = () {
      if (mathStyleGreater(baseOptions.style, MathStyle.text)) {
        return baseOptions.fontMetrics.xHeight2.toLpUnder(baseOptions);
      } else {
        return theta;
      }
    }();
    double psi = theta + 0.25 * phi.abs();
    final minSqrtHeight = baseSize.height + psi + theta;
    final surdConstraints = BoxConstraints(
      minWidth: baseWidth,
      minHeight: minSqrtHeight,
    );
    final surdSize = renderBoxGetLayoutSize(
      surd,
      surdConstraints,
      dry: dry,
    );
    final advanceWidth = getSqrtAdvanceWidth(minSqrtHeight, baseWidth, options);
    // Parameters for index
    // from KaTeX/src/katex.less
    final indexRightPadding = Measurement.mu(-10.0).toLpUnder(options);
    // KaTeX chose a way to large value (5mu). We will use a smaller one.
    final indexLeftPadding = Measurement.pt(0.5).toLpUnder(options);
    // Horizontal layout
    final sqrtHorizontalPos = max(0.0, indexLeftPadding + indexSize.width + indexRightPadding);
    final width = sqrtHorizontalPos + surdSize.width;
    // Vertical layout
    final ruleWidth = dry ? 0 : renderBoxLayoutHeight(surd);
    if (!dry) {
      final delimDepth = dry ? surdSize.height : renderBoxLayoutDepth(surd);
      if (delimDepth > baseSize.height + psi) {
        psi += 0.5 * (delimDepth - baseSize.height - psi);
      }
    }
    final bodyHeight = baseHeight + psi + ruleWidth;
    final bodyDepth = surdSize.height - bodyHeight;
    final indexShift = 0.6 * (bodyHeight - bodyDepth);
    final sqrtVerticalPos = max(0.0, indexHeight + indexShift - baseHeight - psi - ruleWidth);
    final height = sqrtVerticalPos + surdSize.height;
    // Position children
    if (!dry) {
      svgHorizontalPos = sqrtHorizontalPos;
      heightAboveBaseline = bodyHeight + sqrtVerticalPos;
      setRenderBoxOffset(
        base,
        Offset(
          sqrtHorizontalPos + advanceWidth,
          heightAboveBaseline - baseHeight,
        ),
      );
      if (index != null) {
        setRenderBoxOffset(
          index,
          Offset(
            sqrtHorizontalPos - indexRightPadding - indexWidth,
            heightAboveBaseline - indexShift - indexHeight,
          ),
        );
      }
      setRenderBoxOffset(
        surd,
        Offset(
          sqrtHorizontalPos,
          sqrtVerticalPos,
        ),
      );
    }
    return Size(width, height);
  }
}

class HorizontalStrikeDelegate extends CustomLayoutDelegate<int> {
  final double ruleThickness;
  final double vShift;
  final Color color;

  HorizontalStrikeDelegate({
    required final this.ruleThickness,
    required final this.vShift,
    required final this.color,
  });

  double height = 0.0;
  double width = 0.0;

  @override
  double computeDistanceToActualBaseline(
          final TextBaseline baseline, final Map<int, RenderBox> childrenTable) =>
      height;

  @override
  double getIntrinsicSize({
    required final Axis sizingDirection,
    required final bool max,
    required final double extent,
    required final double Function(RenderBox child, double extent) childSize,
    required final Map<int, RenderBox> childrenTable,
  }) =>
      childSize(childrenTable[0]!, double.infinity);

  @override
  Size computeLayout(
    final BoxConstraints constraints,
    final Map<int, RenderBox> childrenTable, {
    final bool dry = true,
  }) {
    final base = childrenTable[0]!;

    if (dry) {
      return base.getDryLayout(constraints);
    }

    base.layout(constraints, parentUsesSize: true);
    height = renderBoxLayoutHeight(base);
    width = base.size.width;

    return base.size;
  }

  @override
  void additionalPaint(final PaintingContext context, final Offset offset) {
    context.canvas.drawLine(
      Offset(
        offset.dx,
        offset.dy + height - vShift,
      ),
      Offset(
        offset.dx + width,
        offset.dy + height - vShift,
      ),
      Paint()
        ..strokeWidth = ruleThickness
        ..color = color,
    );
  }
}

enum FracPos {
  numer,
  denom,
}

class FracLayoutDelegate extends IntrinsicLayoutDelegate<FracPos> {
  final Measurement? barSize;
  final MathOptions options;

  FracLayoutDelegate({
    required final this.barSize,
    required final this.options,
  });

  double theta = 0.0;
  double height = 0.0;
  double a = 0.0;
  double width = 0.0;
  double barLength = 0.0;

  @override
  double computeDistanceToActualBaseline(
    final TextBaseline baseline,
    final Map<FracPos, RenderBox> childrenTable,
  ) =>
      height;

  @override
  AxisConfiguration<FracPos> performHorizontalIntrinsicLayout({
    required final Map<FracPos, double> childrenWidths,
    final bool isComputingIntrinsics = false,
  }) {
    final numerSize = childrenWidths[FracPos.numer]!;
    final denomSize = childrenWidths[FracPos.denom]!;
    final barLength = max(numerSize, denomSize);
    // KaTeX/src/katex.less
    final nullDelimiterWidth = Measurement.cssem(0.12).toLpUnder(options);
    final width = barLength + 2 * nullDelimiterWidth;
    if (!isComputingIntrinsics) {
      this.barLength = barLength;
      this.width = width;
    }

    return AxisConfiguration(
      size: width,
      offsetTable: {
        FracPos.numer: 0.5 * (width - numerSize),
        FracPos.denom: 0.5 * (width - denomSize),
      },
    );
  }

  @override
  AxisConfiguration<FracPos> performVerticalIntrinsicLayout({
    required final Map<FracPos, double> childrenHeights,
    required final Map<FracPos, double> childrenBaselines,
    final bool isComputingIntrinsics = false,
  }) {
    final numerSize = childrenHeights[FracPos.numer]!;
    final denomSize = childrenHeights[FracPos.denom]!;
    final numerHeight = childrenBaselines[FracPos.numer]!;
    final denomHeight = childrenBaselines[FracPos.denom]!;
    final metrics = options.fontMetrics;
    final xi8 = Measurement.cssem(metrics.defaultRuleThickness).toLpUnder(options);
    final theta = barSize?.toLpUnder(options) ?? xi8;
    // Rule 15b
    double u = Measurement.cssem(
      mathStyleGreater(options.style, MathStyle.text)
          ? metrics.num1
          : (theta != 0 ? metrics.num2 : metrics.num3),
    ).toLpUnder(options);
    double v =
        Measurement.cssem(mathStyleGreater(options.style, MathStyle.text) ? metrics.denom1 : metrics.denom2)
            .toLpUnder(options);
    final a = metrics.axisHeight2.toLpUnder(options);
    final hx = numerHeight;
    final dx = numerSize - numerHeight;
    final hz = denomHeight;
    final dz = denomSize - denomHeight;
    if (theta == 0) {
      // Rule 15c
      final phi = mathStyleGreater(options.style, MathStyle.text) ? 7 * xi8 : 3 * xi8;
      final psi = (u - dx) - (hz - v);
      if (psi < phi) {
        u += 0.5 * (phi - psi);
        v += 0.5 * (phi - psi);
      }
    } else {
      // Rule 15d
      final phi = mathStyleGreater(options.style, MathStyle.text) ? 3 * theta : theta;
      if (u - dx - a - 0.5 * theta < phi) {
        u = phi + dx + a + 0.5 * theta;
      }
      if (a - 0.5 * theta - hz + v < phi) {
        v = phi + hz - a + 0.5 * theta;
      }
    }
    final height = hx + u;
    final depth = dz + v;
    if (!isComputingIntrinsics) {
      this.height = height;
      this.theta = theta;
      this.a = a;
    }
    return AxisConfiguration(
      size: height + depth,
      offsetTable: {
        FracPos.numer: height - u - hx,
        FracPos.denom: height + v - hz,
      },
    );
  }

  @override
  void additionalPaint(
    final PaintingContext context,
    final Offset offset,
  ) {
    if (theta != 0) {
      final paint = Paint()
        ..color = options.color
        ..strokeWidth = theta;
      context.canvas.drawLine(
        Offset(0.5 * (width - barLength), height - a) + offset,
        Offset(0.5 * (width + barLength), height - a) + offset,
        paint,
      );
    }
  }
}

SELF texClipChildrenBetween<SELF extends TexGreenTNonleaf<SELF, TexGreen>>(
  final SELF node,
  final int pos1,
  final int pos2,
) {
  final childIndex1 = node.childPositions.slotFor(pos1);
  final childIndex2 = node.childPositions.slotFor(pos2);
  final childIndex1Floor = childIndex1.floor();
  final childIndex1Ceil = childIndex1.ceil();
  final childIndex2Floor = childIndex2.floor();
  final childIndex2Ceil = childIndex2.ceil();
  TexGreen? head;
  TexGreen? tail;
  if (childIndex1Floor != childIndex1 &&
      childIndex1Floor >= 0 &&
      childIndex1Floor <= node.children.length - 1) {
    final child = node.children[childIndex1Floor];
    if (child is TexGreenStyleImpl) {
      head = texClipChildrenBetween<TexGreenStyleImpl>(
        child,
        pos1 - node.childPositions[childIndex1Floor],
        pos2 - node.childPositions[childIndex1Floor],
      );
    } else {
      head = child;
    }
  }
  if (childIndex2Ceil != childIndex2 &&
      childIndex2Floor >= 0 &&
      childIndex2Floor <= node.children.length - 1) {
    final child = node.children[childIndex2Floor];
    if (child is TexGreenStyleImpl) {
      tail = texClipChildrenBetween<TexGreenStyleImpl>(
        child,
        pos1 - node.childPositions[childIndex2Floor],
        pos2 - node.childPositions[childIndex2Floor],
      );
    } else {
      tail = child;
    }
  }
  return node.updateChildren(
    [
      if (head != null) head,
      for (int i = childIndex1Ceil; i < childIndex2Floor; i++) node.children[i],
      if (tail != null) tail,
    ],
  );
}

int makeCommonEditingWidth(
  final TexGreenNonleaf node,
) {
  return integerSum(
        node.children.map(
          (final child) {
            if (child == null) {
              return 0;
            } else {
              return texCapturedCursor(child);
            }
          },
        ),
      ) +
      1;
}

List<int> makeCommonChildPositions(
  final TexGreenNonleaf node,
) {
  int curPos = 0;
  final result = <int>[];
  for (final child in node.children) {
    result.add(curPos);
    curPos += () {
      if (child == null) {
        return 0;
      } else {
        return texCapturedCursor(child);
      }
    }();
  }
  return result;
}

/// Number of cursor positions that can be captured within this node.
int texCapturedCursor(
  final TexGreen node,
) =>
    node.match(
      nonleaf: (final a) => a.editingWidth - 1,
      leaf: (final a) => 0,
    );

TextRange texGetRange(
  final TexGreen node,
  final int pos,
) {
  return TextRange(
    start: pos + 1,
    end: pos + texCapturedCursor(node),
  );
}
List<TexRed> findNodesAtPosition(
    final TexRed texRed,
    final int position,
    ) {
  TexRed curr = texRed;
  final res = <TexRed>[];
  for (;;) {
    res.add(curr);
    final next = curr.children.firstWhereOrNull(
          (final child) {
        if (child == null) {
          return false;
        } else {
          final range = texGetRange(
            child.greenValue,
            child.pos,
          );
          return range.start <= position && range.end >= position;
        }
      },
    );
    if (next == null) {
      break;
    }
    curr = next;
  }
  return res;
}

TexGreenEquationrow findNodeManagesPosition(
    final TexRedEquationrowImpl texRed,
    final int position,
    ) {
  TexRed curr = texRed;
  TexGreenEquationrow lastEqRow = texRed.greenValue;
  for (;;) {
    final next = curr.children.firstWhereOrNull(
          (final child) {
        if (child == null) {
          return false;
        } else {
          final range = texGetRange(
            child.greenValue,
            child.pos,
          );
          return range.start <= position && range.end >= position;
        }
      },
    );
    if (next == null) {
      break;
    }
    final nextGreenValue = next.greenValue;
    if (nextGreenValue is TexGreenEquationrow) {
      lastEqRow = nextGreenValue;
    }
    curr = next;
  }
  // assert(curr.value is EquationRowNode);
  return lastEqRow;
}

TexGreenEquationrowImpl findLowestCommonRowNode(
    final TexRedEquationrowImpl texRed,
    final int position1,
    final int position2,
    ) {
  final redNodes1 = findNodesAtPosition(texRed, position1);
  final redNodes2 = findNodesAtPosition(texRed, position2);
  for (int index = min(redNodes1.length, redNodes2.length) - 1; index >= 0; index--) {
    final node1 = redNodes1[index].greenValue;
    final node2 = redNodes2[index].greenValue;
    if (node1 == node2) {
      if (node1 is TexGreenEquationrowImpl) {
        return node1;
      } else {
        // Continue.
      }
    } else {
      // Continue.
    }
  }
  return texRed.greenValue;
}

List<TexGreen> findSelectedNodes(
    final TexRedEquationrowImpl texRed,
    final int position1,
    final int position2,
    ) {
  final rowNode = findLowestCommonRowNode(texRed, position1, position2);
  final localPos1 = position1 - rowNode.pos;
  final localPos2 = position2 - rowNode.pos;
  return texClipChildrenBetween<TexGreenEquationrowImpl>(
    rowNode,
    localPos1,
    localPos2,
  ).children;
}

// This table gives the number of TeX pts in one of each *absolute* TeX unit.
// Thus, multiplying a length by this number converts the length from units
// into pts.  Dividing the result by ptPerEm gives the number of ems
// *assuming* a font size of ptPerEm (normal size, normal style).

enum Unit {
  // https://en.wikibooks.org/wiki/LaTeX/Lengths and
  // https://tex.stackexchange.com/a/8263
  pt, // TeX point
  mm, // millimeter
  cm, // centimeter
  inches, // inch //Avoid name collision
  bp, // big (PostScript) points
  pc, // pica
  dd, // didot
  cc, // cicero (12 didot)
  nd, // new didot
  nc, // new cicero (12 new didot)
  sp, // scaled point (TeX's internal smallest unit)
  px, // \pdfpxdimen defaults to 1 bp in pdfTeX and LuaTeX

  ex, // The height of 'x'
  em, // The width of 'M', which is often the size of the font. ()
  mu,
  lp, // Flutter's logical pixel (96 lp per inch)
  cssEm, // Unit used for font metrics. Analogous to KaTeX's internal unit, but
  // always scale with options.
}

class Measurement {
  final double value;
  final Unit unit;

  bool isMu() => unit == Unit.mu;

  bool isEm() => unit == Unit.em;

  bool isEx() => unit == Unit.ex;

  static Measurement? parse({
    required final String str,
    required final double value,
  }) {
    switch (str) {
      case 'pt':
        return Measurement.pt(value);
      case 'mm':
        return Measurement.mm(value);
      case 'cm':
        return Measurement.cm(value);
      case 'inches':
        return Measurement.inches(value);
      case 'bp':
        return Measurement.bp(value);
      case 'pc':
        return Measurement.pc(value);
      case 'dd':
        return Measurement.dd(value);
      case 'cc':
        return Measurement.cc(value);
      case 'nd':
        return Measurement.nd(value);
      case 'nc':
        return Measurement.nc(value);
      case 'sp':
        return Measurement.sp(value);
      case 'px':
        return Measurement.px(value);
      case 'ex':
        return Measurement.ex(value);
      case 'em':
        return Measurement.em(value);
      case 'mu':
        return Measurement.mu(value);
      case 'lp':
        return Measurement.lp(value);
      case 'cssEm':
        return Measurement.cssem(value);
      default:
        return null;
    }
  }

  static final Measurement zeroPt = Measurement.pt(0.0);

  static Measurement pt(final double value) => Measurement._(value: value, unit: Unit.pt);

  static Measurement mm(final double value) => Measurement._(value: value, unit: Unit.mm);

  static Measurement cm(final double value) => Measurement._(value: value, unit: Unit.cm);

  static Measurement inches(final double value) => Measurement._(value: value, unit: Unit.inches);

  static Measurement bp(final double value) => Measurement._(value: value, unit: Unit.bp);

  static Measurement pc(final double value) => Measurement._(value: value, unit: Unit.pc);

  static Measurement dd(final double value) => Measurement._(value: value, unit: Unit.dd);

  static Measurement cc(final double value) => Measurement._(value: value, unit: Unit.cc);

  static Measurement nd(final double value) => Measurement._(value: value, unit: Unit.nd);

  static Measurement nc(final double value) => Measurement._(value: value, unit: Unit.nc);

  static Measurement sp(final double value) => Measurement._(value: value, unit: Unit.sp);

  static Measurement px(final double value) => Measurement._(value: value, unit: Unit.px);

  static Measurement ex(final double value) => Measurement._(value: value, unit: Unit.ex);

  static Measurement em(final double value) => Measurement._(value: value, unit: Unit.em);

  static Measurement mu(final double value) => Measurement._(value: value, unit: Unit.mu);

  static Measurement lp(final double value) => Measurement._(value: value, unit: Unit.lp);

  static Measurement cssem(final double value) => Measurement._(value: value, unit: Unit.cssEm);

  const Measurement._({
    required final this.value,
    required final this.unit,
  });

  double? toPoint() {
    final conv = () {
      switch (unit) {
        case Unit.pt:
          return 1.0;
        case Unit.mm:
          return 7227 / 2540;
        case Unit.cm:
          return 7227 / 254;
        case Unit.inches:
          return 72.27;
        case Unit.bp:
          return 803 / 800;
        case Unit.pc:
          return 12.0;
        case Unit.dd:
          return 1238 / 1157;
        case Unit.cc:
          return 14856 / 1157;
        case Unit.nd:
          return 685 / 642;
        case Unit.nc:
          return 1370 / 107;
        case Unit.sp:
          return 1 / 65536;
        // https://tex.stackexchange.com/a/41371
        case Unit.px:
          return 803 / 800;
        case Unit.ex:
          return null;
        case Unit.em:
          return null;
        case Unit.mu:
          return null;
        // https://api.flutter.dev/flutter/dart-ui/Window/devicePixelRatio.html
        // Unit.lp: 72.27 / 96,
        case Unit.lp:
          return 72.27 / 160; // This is more accurate
        // Unit.lp: 72.27 / 200,
        case Unit.cssEm:
          return null;
      }
    }();
    if (conv == null) {
      return null;
    } else {
      return value * conv;
    }
  }

  double toLpUnder(
    final MathOptions options,
  ) {
    if (unit == Unit.lp) {
      return value;
    } else {
      final inPoint = toPoint();
      if (inPoint != null) {
        return value * inPoint / Measurement.inches(1.0).toPoint()! * options.logicalPpi;
      } else {
        switch (unit) {
          case Unit.cssEm:
            return value * options.fontSize * options.sizeMultiplier;
          case Unit.mu:
            // `mu` units scale with scriptstyle/scriptscriptstyle.
            return value * options.fontSize * options.fontMetrics.cssEmPerMu * options.sizeMultiplier;
          case Unit.ex:
            // `ex` and `em` always refer to the *textstyle* font
            // in the current size.
            return value *
                options.fontSize *
                options.fontMetrics.xHeight2.value *
                options.havingStyle(mathStyleAtLeastText(options.style)).sizeMultiplier;
          case Unit.em:
            return value *
                options.fontSize *
                options.fontMetrics.quad *
                options.havingStyle(mathStyleAtLeastText(options.style)).sizeMultiplier;
          case Unit.pt:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case Unit.mm:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case Unit.cm:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case Unit.inches:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case Unit.bp:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case Unit.pc:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case Unit.dd:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case Unit.cc:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case Unit.nd:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case Unit.nc:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case Unit.sp:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case Unit.px:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case Unit.lp:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
        }
      }
    }
  }

  double toCssEmUnder(
    final MathOptions options,
  ) {
    return toLpUnder(options) / options.fontSize;
  }

  @override
  String toString() {
    switch (unit) {
      case Unit.pt:
        return value.toString() + 'pt';
      case Unit.mm:
        return value.toString() + 'mm';
      case Unit.cm:
        return value.toString() + 'cm';
      case Unit.inches:
        return value.toString() + 'inches';
      case Unit.bp:
        return value.toString() + 'bp';
      case Unit.pc:
        return value.toString() + 'pc';
      case Unit.dd:
        return value.toString() + 'dd';
      case Unit.cc:
        return value.toString() + 'cc';
      case Unit.nd:
        return value.toString() + 'nd';
      case Unit.nc:
        return value.toString() + 'nc';
      case Unit.sp:
        return value.toString() + 'sp';
      case Unit.px:
        return value.toString() + 'px';
      case Unit.ex:
        return value.toString() + 'ex';
      case Unit.em:
        return value.toString() + 'em';
      case Unit.mu:
        return value.toString() + 'mu';
      case Unit.lp:
        return value.toString() + 'lp';
      case Unit.cssEm:
        return value.toString() + 'cssEm';
    }
  }
}

enum MathSize {
  tiny,
  size2,
  scriptsize,
  footnotesize,
  small,
  normalsize,
  large,
  Large,
  LARGE,
  huge,
  HUGE,
}

double mathSizeSizeMultiplier(
  final MathSize size,
) {
  switch (size) {
    case MathSize.tiny:
      return 0.5;
    case MathSize.size2:
      return 0.6;
    case MathSize.scriptsize:
      return 0.7;
    case MathSize.footnotesize:
      return 0.8;
    case MathSize.small:
      return 0.9;
    case MathSize.normalsize:
      return 1.0;
    case MathSize.large:
      return 1.2;
    case MathSize.Large:
      return 1.44;
    case MathSize.LARGE:
      return 1.728;
    case MathSize.huge:
      return 2.074;
    case MathSize.HUGE:
      return 2.488;
  }
}
