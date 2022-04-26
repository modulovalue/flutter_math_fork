import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../font/font_metrics.dart';
import '../utils/extensions.dart';
import 'ast.dart';

EquationRowNode emptyEquationRowNode() {
  return EquationRowNode(children: []);
}

MatrixNode matrixNodeSanitizedInputs({
  required final List<List<EquationRowNode?>> body,
  final double arrayStretch = 1.0,
  final bool hskipBeforeAndAfter = false,
  final bool isSmall = false,
  final List<MatrixColumnAlign> columnAligns = const [],
  final List<MatrixSeparatorStyle> vLines = const [],
  final List<Measurement> rowSpacings = const [],
  final List<MatrixSeparatorStyle> hLines = const [],
}) {
  final cols = max3(
    body
        .map((final row) => row.length)
        .maxOrNull ?? 0,
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
  final sanitizedRowSpacing = rowSpacings.extendToByFill(rows, Measurement.zero);
  final sanitizedHLines = hLines.extendToByFill(rows + 1, MatrixSeparatorStyle.none);
  return MatrixNode(
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

/// Wrap a node in [EquationRowNode]
///
/// If this node is already [EquationRowNode], then it won't be wrapped
EquationRowNode greenNodeWrapWithEquationRow(
    final GreenNode node,
    ) {
  if (node is EquationRowNode) {
    return node;
  } else {
    return EquationRowNode(
      children: [node],
    );
  }
}

EquationRowNode? greenNodeWrapWithEquationRowOrNull(
    final GreenNode? node,
    ) {
  if (node == null) {
    return null;
  } else {
    return greenNodeWrapWithEquationRow(
      node,
    );
  }
}

/// If this node is [EquationRowNode], its children will be returned. If not,
/// itself will be returned in a list.
List<GreenNode> greenNodeExpandEquationRow(
    final GreenNode node,
    ) {
  if (node is EquationRowNode) {
    return node.children;
  } else {
    return [node];
  }
}

/// Wrap list of [GreenNode] in an [EquationRowNode]
///
/// If the list only contain one [EquationRowNode], then this note will be
/// returned.
EquationRowNode greenNodesWrapWithEquationRow(
    final List<GreenNode> nodes,
    ) {
  if (nodes.length == 1) {
    final first = nodes[0];
    if (first is EquationRowNode) {
      return first;
    } else {
      return EquationRowNode(children: nodes);
    }
  }
  return EquationRowNode(children: nodes);
}

enum Mode { math, text }

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
BreakResult<SyntaxTree> syntaxTreeTexBreak({
  required final SyntaxTree tree,
  final int relPenalty = 500,
  final int binOpPenalty = 700,
  final bool enforceNoBreak = true,
}) {
  final eqRowBreakResult = equationRowNodeTexBreak(
    tree: tree.greenRoot,
    relPenalty: relPenalty,
    binOpPenalty: binOpPenalty,
    enforceNoBreak: true,
  );
  return BreakResult(
    parts: eqRowBreakResult.parts.map((final part) => SyntaxTree(greenRoot: part)).toList(growable: false),
    penalties: eqRowBreakResult.penalties,
  );
}

/// Line breaking results using standard TeX-style line breaking.
///
/// This function will return a list of `EquationRowNode` along with a list
/// of line breaking penalties.
///
/// {@macro flutter_math_fork.widgets.math.tex_break}
BreakResult<EquationRowNode> equationRowNodeTexBreak({
  required final EquationRowNode tree,
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
      if (nextChild is SpaceNode && nextChild.breakPenalty != null && nextChild.breakPenalty! >= 10000) {
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
    } else if (child is SpaceNode && child.breakPenalty != null) {
      breakIndices.add(i);
      penalties.add(child.breakPenalty!);
    }
  }
  final res = <EquationRowNode>[];
  int pos = 1;
  for (var i = 0; i < breakIndices.length; i++) {
    final breakEnd = tree.caretPositions[breakIndices[i] + 1];
    res.add(
      greenNodeWrapWithEquationRow(
        tree.clipChildrenBetween(
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
        tree.clipChildrenBetween(
          pos,
          tree.caretPositions.last,
        ),
      ),
    );
    penalties.add(10000);
  }
  return BreakResult<EquationRowNode>(
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

MathStyle? parseMathStyle(final String string,) =>
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

bool mathStyleIsCramped(final MathStyle style,) {
  return style.index.isEven;
}

int mathStyleSize(final MathStyle style,) {
  return style.index ~/ 2;
}

// MathStyle get pureStyle => MathStyle.values[(this.index / 2).floor()];

MathStyle mathStyleReduce(final MathStyle style,
    final MathStyleDiff? diff,) {
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

MathStyle mathStyleSup(final MathStyle style,) =>
    mathStyleReduce(
      style,
      MathStyleDiff.sup,
    );

MathStyle mathStyleSub(final MathStyle style,) =>
    mathStyleReduce(
      style,
      MathStyleDiff.sub,
    );

MathStyle mathStyleFracNum(final MathStyle style,) =>
    mathStyleReduce(
      style,
      MathStyleDiff.fracNum,
    );

MathStyle mathStyleFracDen(final MathStyle style,) =>
    mathStyleReduce(
      style,
      MathStyleDiff.fracDen,
    );

MathStyle mathStyleCramp(final MathStyle style,) =>
    mathStyleReduce(
      style,
      MathStyleDiff.cramp,
    );

MathStyle mathStyleAtLeastText(final MathStyle style,) =>
    mathStyleReduce(
      style,
      MathStyleDiff.text,
    );

MathStyle mathStyleUncramp(final MathStyle style,) =>
    mathStyleReduce(
      style,
      MathStyleDiff.uncramp,
    );

// bool mathStyleIsTight(
//   final MathStyle style,
// ) =>
//     mathStyleSize(style) >= 2;

bool mathStyleGreater(final MathStyle left,
    final MathStyle right,) =>
    left.index < right.index;

bool mathStyleLess(final MathStyle left,
    final MathStyle right,) =>
    left.index > right.index;

bool mathStyleGreaterEquals(final MathStyle left,
    final MathStyle right,) =>
    left.index <= right.index;

bool mathStyleLessEquals(final MathStyle left,
    final MathStyle right,) =>
    left.index >= right.index;

MathStyle integerToMathStyle(final int i,) =>
    MathStyle.values[(i * 2).clamp(0, 6)];

/// katex/src/Options.js/sizeStyleMap
MathSize mathSizeUnderStyle(final MathSize size,
    final MathStyle style,) {
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

const thinspace = Measurement(value: 3, unit: Unit.mu);
const mediumspace = Measurement(value: 4, unit: Unit.mu);
const thickspace = Measurement(value: 5, unit: Unit.mu);

const Map<AtomType, Map<AtomType, Measurement>> _spacings = {
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

const Map<AtomType, Map<AtomType, Measurement>> _tightSpacings = {
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

Measurement getSpacingSize(final AtomType left,
    final AtomType right,
    final MathStyle style,) =>
    (mathStyleLessEquals(style, MathStyle.script)
        ? (_tightSpacings[left]?[right])
        : _spacings[left]?[right]) ??
        Measurement.zero;

/// Options for equation element rendering.
///
/// Every [GreenNode] is rendered with an [MathOptions]. It controls their size,
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
            return _defaultPtPerEm / unitToPoint(Unit.lp)!;
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
      fontSize * unitToPoint(Unit.inches)! / _defaultPtPerEm;

  /// Default value for [fontSize] when [logicalPpi] has been set.
  static double defaultFontSizeFor({
    required final double logicalPpi,
  }) =>
      _defaultPtPerEm / unitToPoint(Unit.inches)! * logicalPpi;

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
  MathOptions havingSize(final MathSize size,) {
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
  MathOptions withTextFont(final PartialFontOptions font) =>
      this.copyWith(
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

// This table gives the number of TeX pts in one of each *absolute* TeX unit.
// Thus, multiplying a length by this number converts the length from units
// into pts.  Dividing the result by ptPerEm gives the number of ems
// *assuming* a font size of ptPerEm (normal size, normal style).

// TODO phantom type
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

double? unitToPoint(final Unit unit,) {
  return {
    Unit.pt: 1.0,
    Unit.mm: 7227 / 2540,
    Unit.cm: 7227 / 254,
    Unit.inches: 72.27,
    Unit.bp: 803 / 800,
    Unit.pc: 12.0,
    Unit.dd: 1238 / 1157,
    Unit.cc: 14856 / 1157,
    Unit.nd: 685 / 642,
    Unit.nc: 1370 / 107,
    Unit.sp: 1 / 65536,
    // https://tex.stackexchange.com/a/41371
    Unit.px: 803 / 800,

    Unit.ex: null,
    Unit.em: null,
    Unit.mu: null,
    // https://api.flutter.dev/flutter/dart-ui/Window/devicePixelRatio.html
    // Unit.lp: 72.27 / 96,
    Unit.lp: 72.27 / 160, // This is more accurate
    // Unit.lp: 72.27 / 200,
    Unit.cssEm: null,
  }[unit];
}

String unitToName(final Unit unit,) {
  return const {
    Unit.pt: 'pt',
    Unit.mm: 'mm',
    Unit.cm: 'cm',
    Unit.inches: 'inches',
    Unit.bp: 'bp',
    Unit.pc: 'pc',
    Unit.dd: 'dd',
    Unit.cc: 'cc',
    Unit.nd: 'nd',
    Unit.nc: 'nc',
    Unit.sp: 'sp',
    Unit.px: 'px',
    Unit.ex: 'ex',
    Unit.em: 'em',
    Unit.mu: 'mu',
    Unit.lp: 'lp',
    Unit.cssEm: 'cssEm',
  }[unit]!;
}

Unit? parseUnit(final String str,) =>
    const {
      'pt': Unit.pt,
      'mm': Unit.mm,
      'cm': Unit.cm,
      'inches': Unit.inches,
      'bp': Unit.bp,
      'pc': Unit.pc,
      'dd': Unit.dd,
      'cc': Unit.cc,
      'nd': Unit.nd,
      'nc': Unit.nc,
      'sp': Unit.sp,
      'px': Unit.px,
      'ex': Unit.ex,
      'em': Unit.em,
      'mu': Unit.mu,
      'lp': Unit.lp,
      'cssEm': Unit.cssEm,
    }[str];

class Measurement {
  final double value;
  final Unit unit;

  const Measurement({
    required final this.value,
    required final this.unit,
  });

  double toLpUnder(final MathOptions options,) {
    if (unit == Unit.lp) return value;
    if (unitToPoint(unit) != null) {
      return value * unitToPoint(unit)! / unitToPoint(Unit.inches)! * options.logicalPpi;
    }
    switch (unit) {
      case Unit.cssEm:
        return value * options.fontSize * options.sizeMultiplier;
    // `mu` units scale with scriptstyle/scriptscriptstyle.
      case Unit.mu:
        return value * options.fontSize * options.fontMetrics.cssEmPerMu * options.sizeMultiplier;
    // `ex` and `em` always refer to the *textstyle* font
    // in the current size.
      case Unit.ex:
        return value *
            options.fontSize *
            options.fontMetrics.xHeight *
            options
                .havingStyle(mathStyleAtLeastText(options.style))
                .sizeMultiplier;
      case Unit.em:
        return value *
            options.fontSize *
            options.fontMetrics.quad *
            options
                .havingStyle(mathStyleAtLeastText(options.style))
                .sizeMultiplier;
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

  double toCssEmUnder(final MathOptions options,) =>
      toLpUnder(options) / options.fontSize;

  @override
  String toString() => value.toString() + unitToName(unit);

  static const zero = Measurement(
    value: 0,
    unit: Unit.pt,
  );
}

Measurement ptMeasurement(final double value) => Measurement(value: value, unit: Unit.pt);

Measurement mmMeasurement(final double value) => Measurement(value: value, unit: Unit.mm);

Measurement cmMeasurement(final double value) => Measurement(value: value, unit: Unit.cm);

Measurement inchesMeasurement(final double value) => Measurement(value: value, unit: Unit.inches);

Measurement bpMeasurement(final double value) => Measurement(value: value, unit: Unit.bp);

Measurement pcMeasurement(final double value) => Measurement(value: value, unit: Unit.pc);

Measurement ddMeasurement(final double value) => Measurement(value: value, unit: Unit.dd);

Measurement ccMeasurement(final double value) => Measurement(value: value, unit: Unit.cc);

Measurement ndMeasurement(final double value) => Measurement(value: value, unit: Unit.nd);

Measurement ncMeasurement(final double value) => Measurement(value: value, unit: Unit.nc);

Measurement spMeasurement(final double value) => Measurement(value: value, unit: Unit.sp);

Measurement pxMeasurement(final double value) => Measurement(value: value, unit: Unit.px);

Measurement exMeasurement(final double value) => Measurement(value: value, unit: Unit.ex);

Measurement emMeasurement(final double value) => Measurement(value: value, unit: Unit.em);

Measurement muMeasurement(final double value) => Measurement(value: value, unit: Unit.mu);

Measurement lpMeasurement(final double value) => Measurement(value: value, unit: Unit.lp);

Measurement cssEmMeasurement(final double value) => Measurement(value: value, unit: Unit.cssEm);

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

double mathSizeSizeMultiplier(final MathSize size,) =>
    const [
      0.5,
      0.6,
      0.7,
      0.8,
      0.9,
      1.0,
      1.2,
      1.44,
      1.728,
      2.074,
      2.488,
    ][size.index];
