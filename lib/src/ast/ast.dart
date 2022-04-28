// ignore_for_file: comment_references

import 'dart:ui' show Color, FontStyle, FontWeight, TextRange;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart' show Colors, GlobalKey, Widget;
import '../font/font_metrics.dart' show getGlobalMetrics;

import 'ast_impl.dart';
import 'ast_plus.dart' show mathSizeSizeMultiplier, mathSizeUnderStyle, mathStyleAtLeastText, mathStyleCramp, mathStyleIsCramped;

// region interfaces

/// Roslyn's Red-Green Tree
///
/// [Description of Roslyn's Red-Green Tree](https://docs.microsoft.com/en-us/archive/blogs/ericlippert/persistence-facades-and-roslyns-red-green-trees)
///
/// An immutable facade over [TexGreen]. It stores absolute
/// information and context parameters of an abstract syntax node which cannot
/// be stored inside [TexGreen]. Every node of the red tree is evaluated
/// top-down on demand.
abstract class TexRed {
  TexGreen get greenValue;

  int? get pos;

  /// Lazily evaluated children of the current [TexRed].
  List<TexRed?> get children;
}

/// Stores any context-free information of a node and is
/// constructed bottom-up. It needs to indicate or store:
/// - Necessary parameters for this math node.
/// - Layout algorithm for this math node, if renderable.
/// - Structural information of the tree ([children])
/// - Context-free properties for other purposes. ([editingWidth], etc.)
///
/// Due to their context-free property, [TexGreen] can be canonicalized and
/// deduplicated.
abstract class TexGreen {
  /// Whether the specific [MathOptions] parameters that this node directly
  /// depends upon have changed.
  ///
  /// Subclasses should override this method. This method is used to determine
  /// whether certain widget rebuilds can be bypassed even when the
  /// [MathOptions] have changed.
  ///
  /// Rebuild bypass is determined by the following process:
  /// - If [oldOptions] == [newOptions], bypass
  /// - If [shouldRebuildWidget], force rebuild
  /// - Call [buildWidget] on [children]. If the results are identical to the
  /// the results returned by [buildWidget] called last time, then bypass.
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  );

  /// [AtomType] observed from the left side.
  AtomType get leftType;

  /// [AtomType] observed from the right side.
  AtomType get rightType;

  TexCacheGreen get cache;

  Z match<Z>({
    required final Z Function(TexGreenNonleaf) nonleaf,
    required final Z Function(TexGreenLeaf) leaf,
  });
}

class TexCacheGreen {
  MathOptions? oldOptions;
  GreenBuildResult? oldBuildResult;
  List<GreenBuildResult?>? oldChildBuildResults;

  TexCacheGreen();
}

abstract class TexGreenNonleaf implements TexGreen {
  /// Returns a copy of this node with new children.
  ///
  /// Subclasses should override this method. This method provides a general
  /// interface to perform structural updates for the green tree (node
  /// replacement, insertion, etc).
  ///
  /// Please ensure [children] works in the same order as [updateChildren],
  /// [computeChildOptions], and buildWidget.
  TexGreen updateChildren(
    final List<TexGreen?> newChildren,
  );

  /// Position of child nodes.
  ///
  /// Used only for editing functionalities.
  ///
  /// This method stores the layout structure for cursor in the editing mode.
  /// You should return positions of children assume this current node is placed
  /// at the starting position. It should be no shorter than [children]. It's
  /// entirely optional to add extra hinting elements.
  List<int> get childPositions;

  /// Children of this node.
  ///
  /// [children] stores structural information of the Red-Green Tree.
  /// Used for green tree updates. The order of children should strictly
  /// adheres to the cursor-visiting order in editing mode, in order to get a
  /// correct cursor range in the editing mode. E.g., for [TexGreenSqrt], when
  /// moving cursor from left to right, the cursor first enters index, then
  /// base, so it should return [index, base].
  ///
  /// Please ensure [children] works in the same order as updateChildren,
  /// [computeChildOptions], and buildWidget.
  List<TexGreen?> get children;

  Z matchNonleaf<Z>({
    required final Z Function(TexGreenMatrix) matrix,
    required final Z Function(TexGreenMultiscripts) multiscripts,
    required final Z Function(TexGreenNaryoperator) naryoperator,
    required final Z Function(TexGreenSqrt) sqrt,
    required final Z Function(TexGreenStretchyop) stretchyop,
    required final Z Function(TexGreenEquationarray) equationarray,
    required final Z Function(TexGreenOver) over,
    required final Z Function(TexGreenUnder) under,
    required final Z Function(TexGreenAccent) accent,
    required final Z Function(TexGreenAccentunder) accentunder,
    required final Z Function(TexGreenEnclosure) enclosure,
    required final Z Function(TexGreenFrac) frac,
    required final Z Function(TexGreenFunction) function,
    required final Z Function(TexGreenLeftright) leftright,
    required final Z Function(TexGreenRaisebox) raisebox,
    required final Z Function(TexGreenStyle) style,
    required final Z Function(TexGreenEquationrow) equationrow,
  });
}

/// A [TexGreen] that has no children.
abstract class TexGreenLeaf implements TexGreen {
  /// [Mode] that this node acquires during parse.
  Mode get mode;

  Z matchLeaf<Z>({
    required final Z Function(TexGreenTemporary) temporary,
    required final Z Function(TexGreenCursor) cursor,
    required final Z Function(TexGreenPhantom) phantom,
    required final Z Function(TexGreenSpace) space,
    required final Z Function(TexGreenSymbol) symbol,
  });
}

/// A [TexGreen] that has children.
abstract class TexGreenTNonleaf<SELF extends TexGreenTNonleaf<SELF, CHILD>, CHILD extends TexGreen?>
    implements TexGreen, TexGreenNonleaf {
  @override
  List<CHILD> get children;

  @override
  SELF updateChildren(
    covariant final List<CHILD> newChildren,
  );
}

abstract class TexGreenFactory {
  TexGreenTemporary makeTemporary();

  TexGreenCursor makeCursor();

  TexGreenPhantom makePhantom();

  TexGreenSpace makeSpace();

  TexGreenSymbol makeSymbol();
}

/// Matrix node.
abstract class TexGreenMatrix<SELF extends TexGreenMatrix<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow?> {
  /// `arrayStretch` parameter from the context.
  ///
  /// Affects the minimum row height and row depth for each row.
  ///
  /// `\smallmatrix` has an `arrayStretch` of 0.5.
  double get arrayStretch;

  /// Whether to create an extra padding before the first column and after the
  /// last column.
  bool get hskipBeforeAndAfter;

  /// Special flags for `\smallmatrix`
  bool get isSmall;

  /// Align types for each column.
  List<MatrixColumnAlign> get columnAligns;

  /// Style for vertical separator lines.
  ///
  /// This includes outermost lines. Different from MathML!
  List<MatrixSeparatorStyle> get vLines;

  /// Spacings between rows;
  List<Measurement> get rowSpacings;

  /// Style for horizontal separator lines.
  ///
  /// This includes outermost lines. Different from MathML!
  List<MatrixSeparatorStyle> get hLines;

  /// Body of the matrix.
  ///
  /// First index is line number. Second index is column number.
  List<List<TexGreenEquationrow?>> get body;

  /// Row number.
  int get rows;

  /// Column number.
  int get cols;
}

/// Node for postscripts and prescripts
///
/// Examples:
///
/// - Word:   _     ^
/// - Latex:  _     ^
/// - MathML: msub  msup  mmultiscripts
abstract class TexGreenMultiscripts<SELF extends TexGreenMultiscripts<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow?> {
  /// Whether to align the subscript to the superscript.
  ///
  /// Mimics MathML's mmultiscripts.
  bool get alignPostscripts;

  /// Base where scripts are applied upon.
  TexGreenEquationrow get base;

  /// Subscript.
  TexGreenEquationrow? get sub;

  /// Superscript.
  TexGreenEquationrow? get sup;

  /// Presubscript.
  TexGreenEquationrow? get presub;

  /// Presuperscript.
  TexGreenEquationrow? get presup;
}

/// N-ary operator node.
///
/// Examples: `\sum`, `\int`
abstract class TexGreenNaryoperator<SELF extends TexGreenNaryoperator<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow?> {
  /// Unicode symbol for the operator character.
  String get operator;

  /// Lower limit.
  TexGreenEquationrow? get lowerLimit;

  /// Upper limit.
  TexGreenEquationrow? get upperLimit;

  /// Argument for the N-ary operator.
  TexGreenEquationrow get naryand;

  /// Whether the limits are displayed as under/over or as scripts.
  bool? get limits;

  /// Special flag for `\smallint`.
  bool get allowLargeOp; // for \smallint
}

/// Square root node.
///
/// Examples:
/// - Word:   `\sqrt`   `\sqrt(index & base)`
/// - Latex:  `\sqrt`   `\sqrt[index]{base}`
/// - MathML: `msqrt`   `mroot`
abstract class TexGreenSqrt<SELF extends TexGreenSqrt<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow?> {
  /// The index.
  TexGreenEquationrow? get index;

  /// The sqrt-and.
  TexGreenEquationrow get base;
}

/// Stretchy operator node.
///
/// Example: `\xleftarrow`
abstract class TexGreenStretchyop<SELF extends TexGreenStretchyop<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow?> {
  /// Unicode symbol for the operator.
  String get symbol;

  /// Arguments above the operator.
  TexGreenEquationrow? get above;

  /// Arguments below the operator.
  TexGreenEquationrow? get below;
}

/// Equation array node. Brings support for equation alignment.
abstract class TexGreenEquationarray<SELF extends TexGreenEquationarray<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  /// `arrayStretch` parameter from the context.
  ///
  /// Affects the minimum row height and row depth for each row.
  ///
  /// `\smallmatrix` has an `arrayStretch` of 0.5.
  double get arrayStretch;

  /// Whether to add an extra 3 pt spacing between each row.
  ///
  /// True for `\aligned` and `\alignedat`
  bool get addJot;

  /// Arrayed equations.
  List<TexGreenEquationrow> get body;

  /// Style for horizontal separator lines.
  ///
  /// This includes outermost lines. Different from MathML!
  List<MatrixSeparatorStyle> get hlines;

  /// Spacings between rows;
  List<Measurement> get rowSpacings;
}

/// Over node.
///
/// Examples: `\underset`
abstract class TexGreenOver<SELF extends TexGreenOver<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  /// Base where the over node is applied upon.
  TexGreenEquationrow get base;

  /// Argument above the base.
  TexGreenEquationrow get above;

  /// Special flag for `\stackrel`
  bool get stackRel;
}

/// Under node.
///
/// Examples: `\underset`
abstract class TexGreenUnder<SELF extends TexGreenUnder<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  /// Base where the under node is applied upon.
  TexGreenEquationrow get base;

  /// Arguments below the base.
  TexGreenEquationrow get below;
}

/// Accent node.
///
/// Examples: `\hat`
abstract class TexGreenAccent<SELF extends TexGreenAccent<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  /// Base where the accent is applied upon.
  TexGreenEquationrow get base;

  /// Unicode symbol of the accent character.
  String get label;

  /// Is the accent stretchy?
  ///
  /// Stretchy accent will stretch according to the width of [base].
  bool get isStretchy;

  /// Is the accent shifty?
  ///
  /// Shifty accent will shift according to the italic of [base].
  bool get isShifty;
}

/// AccentUnder Nodes.
///
/// Examples: `\utilde`
abstract class TexGreenAccentunder<SELF extends TexGreenAccentunder<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  /// Base where the accentUnder is applied upon.
  TexGreenEquationrow get base;

  /// Unicode symbol of the accent character.
  String get label;
}

/// Enclosure node
///
/// Examples: `\colorbox`, `\fbox`, `\cancel`.
abstract class TexGreenEnclosure<SELF extends TexGreenEnclosure<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  /// Base where the enclosure is applied upon
  TexGreenEquationrow get base;

  /// Whether the enclosure has a border.
  bool get hasBorder;

  /// Border color.
  ///
  /// If null, will default to options.color.
  Color? get bordercolor;

  /// Background color.
  Color? get backgroundcolor;

  /// Special styles for this enclosure.
  ///
  /// Including `'updiagonalstrike'`, `'downdiagnoalstrike'`,
  /// and `'horizontalstrike'`.
  List<String> get notation;

  /// Horizontal padding.
  Measurement? get horizontalPadding;

  /// Vertical padding.
  Measurement? get verticalPadding;
}

/// Frac node.
abstract class TexGreenFrac<SELF extends TexGreenFrac<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  /// Numerator.
  TexGreenEquationrow get numerator;

  /// Denumerator.
  TexGreenEquationrow get denominator;

  /// Bar size.
  ///
  /// If null, will use default bar size.
  Measurement? get barSize;

  /// Whether it is a continued frac `\cfrac`.
  bool get continued;
}

/// Function node
///
/// Examples: `\sin`, `\lim`, `\operatorname`
abstract class TexGreenFunction<SELF extends TexGreenFunction<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  /// Name of the function.
  TexGreenEquationrow get functionName;

  /// Argument of the function.
  TexGreenEquationrow get argument;
}

/// Left right node.
abstract class TexGreenLeftright<SELF extends TexGreenLeftright<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  /// Unicode symbol for the left delimiter character.
  String? get leftDelim;

  /// Unicode symbol for the right delimiter character.
  String? get rightDelim;

  /// List of inside bodys.
  ///
  /// Its length should be 1 longer than [middle].
  List<TexGreenEquationrow> get body;

  /// List of middle delimiter characters.
  List<String?> get middle;
}

/// Raise box node which vertically displace its child.
///
/// Example: `\raisebox`
abstract class TexGreenRaisebox<SELF extends TexGreenRaisebox<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  /// Child to raise.
  TexGreenEquationrow get body;

  /// Vertical displacement.
  Measurement get dy;
}

/// Node to denote all kinds of style changes.
///
/// [TexGreenStyle] refers to a node who have zero rendering content
/// itself, and are expected to be unwrapped for its children during rendering.
///
/// [TexGreenStyle]s are only allowed to appear directly under
/// [TexGreenEquationrow]s and other [TexGreenStyle]s. And those nodes have to
/// explicitly unwrap transparent nodes during building stage.
abstract class TexGreenStyle<SELF extends TexGreenStyle<SELF>> implements TexGreenTNonleaf<SELF, TexGreen> {
  /// The difference of [MathOptions].
  OptionsDiff get optionsDiff;

  /// Children list when fully expand any underlying [TexGreenStyle]
  List<TexGreen> get flattenedChildList;
}

/// A row of unrelated [TexGreen]s.
///
/// [TexGreenEquationrow] provides cursor-reachability and editability. It
/// represents a collection of nodes that you can freely edit and navigate.
abstract class TexGreenEquationrow<SELF extends TexGreenEquationrow<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreen> {
  /// If non-null, the leftmost and rightmost [AtomType] will be overridden.
  AtomType? get overrideType;

  /// Children list when fully expanded any underlying [TexGreenStyle].
  List<TexGreen> get flattenedChildList;

  /// Children positions when fully expanded underlying [TexGreenStyle], but
  /// appended an extra position entry for the end.
  List<int> get caretPositions;

  TextRange get range;

  void updatePos(
    final int? pos,
  );

  abstract GlobalKey? key;
}

/// Only for provisional use during parsing. Do not use.
abstract class TexGreenTemporary implements TexGreenLeaf {}

/// Node displays vertical bar the size of [MathOptions.fontSize]
/// to replicate a text edit field cursor
abstract class TexGreenCursor implements TexGreenLeaf {}

/// Phantom node.
///
/// Example: `\phantom` `\hphantom`.
abstract class TexGreenPhantom implements TexGreenLeaf {
  /// The phantomed child.
  TexGreenEquationrow get phantomChild;

  /// Whether to eliminate width.
  bool get zeroWidth;

  /// Whether to eliminate height.
  bool get zeroHeight;

  /// Whether to eliminate depth.
  bool get zeroDepth;
}

/// Space node. Also used for equation alignment.
abstract class TexGreenSpace implements TexGreenLeaf {
  /// Height.
  Measurement get height;

  /// Width.
  Measurement get width;

  /// Depth.
  Measurement? get depth;

  /// Vertical shift.
  ///
  ///  For the sole purpose of `\rule`
  Measurement? get shift;

  /// Break penalty for a manual line breaking command.
  ///
  /// Related TeX command: \nobreak, \allowbreak, \penalty<number>.
  ///
  /// Should be null for normal space commands.
  int? get breakPenalty;

  /// Whether to fill with text color.
  bool get fill;

  bool get alignerOrSpacer;
}

/// Node for an unbreakable symbol.
abstract class TexGreenSymbol implements TexGreenLeaf {
  /// Unicode symbol.
  String get symbol;

  /// Whether it is a variant form.
  ///
  /// Refer to MathJaX's variantForm
  bool get variantForm;

  /// Effective atom type for this symbol;
  AtomType get atomType;

  /// Overriding atom type;
  AtomType? get overrideAtomType;

  /// Overriding atom font;
  FontOptions? get overrideFont;

  TexGreenSymbol withSymbol(
    final String symbol,
  );
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

enum Mode {
  math,
  text,
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

// endregion

// region rest

/// Options for equation element rendering.
///
/// Every [TexGreen] is rendered with a [MathOptions]. It controls their size,
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
  final MathSize size;

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
  late final FontMetrics fontMetrics = getGlobalMetrics(
    size,
  );

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
            return _defaultPtPerEm / lp(1.0).toPoint()!;
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
  }) : size = mathSizeUnderStyle(
        sizeUnderTextStyle,
        style,
      );

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
      fontSize * inches(1.0).toPoint()! / _defaultPtPerEm;

  /// Default value for [fontSize] when [logicalPpi] has been set.
  static double defaultFontSizeFor({
    required final double logicalPpi,
  }) =>
      _defaultPtPerEm / inches(1.0).toPoint()! * logicalPpi;

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
  int get hashCode => Object.hash(fontFamily.hashCode, fontWeight.hashCode, fontShape.hashCode);
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

abstract class Measurement {
  double get value;

  bool isMu();

  bool isEm();

  bool isEx();

  double? toPoint();

  double toLpUnder(
    final MathOptions options,
  );

  double toCssEmUnder(
    final MathOptions options,
  );

  String describe();
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
  int get hashCode => Object.hash(fontFamily.hashCode, fontWeight.hashCode, fontShape.hashCode);
}

class FontMetrics {
  double get cssEmPerMu => quad / 18;

  final double slant; // sigma1
  final double space; // sigma2
  final double stretch; // sigma3
  final double shrink; // sigma4
  final Measurement xHeight2; // sigma5
  final double quad; // sigma6
  final double extraSpace; // sigma7
  final double num1; // sigma8
  final double num2; // sigma9
  final double num3; // sigma10
  final double denom1; // sigma11
  final double denom2; // sigma12
  final double sup1; // sigma13
  final double sup2; // sigma14
  final double sup3; // sigma15
  final double sub1; // sigma16
  final double sub2; // sigma17
  final double supDrop; // sigma18
  final double subDrop; // sigma19
  final double delim1; // sigma20
  final double delim2; // sigma21
  final Measurement axisHeight2; // sigma22

  // These font metrics are extracted from TeX by using tftopl on cmex10.tfm;
  // they correspond to the font parameters of the extension fonts (family 3).
  // See the TeXbook, page 441. In AMSTeX, the extension fonts scale; to
  // match cmex7, we'd use cmex7.tfm values for script and scriptscript
  // values.
  final double defaultRuleThickness; // xi8; cmex7: 0.049
  final double bigOpSpacing1; // xi9
  final double bigOpSpacing2; // xi10
  final double bigOpSpacing3; // xi11
  final double bigOpSpacing4; // xi12; cmex7: 0.611
  final double bigOpSpacing5; // xi13; cmex7: 0.143

  // The \sqrt rule width is taken from the height of the surd character.
  // Since we use the same font at all sizes, this thickness doesn't scale.
  final double sqrtRuleThickness;

  // This value determines how large a pt is, for metrics which are defined
  // in terms of pts.
  // This value is also used in katex.less; if you change it make sure the
  // values match.
  final double ptPerEm;

  // The space between adjacent `|` columns in an array definition. From
  // `\showthe\doublerulesep` in LaTeX. Equals 2.0 / ptPerEm.
  final double doubleRuleSep;

  // The width of separator lines in {array} environments. From
  // `\showthe\arrayrulewidth` in LaTeX. Equals 0.4 / ptPerEm.
  final double arrayRuleWidth; // Two values from LaTeX source2e:
  final double fboxsep; // 3 pt / ptPerEm
  final double fboxrule; // 0.4 pt / ptPerEm

  const FontMetrics({
    required final this.slant,
    required final this.space,
    required final this.stretch,
    required final this.shrink,
    required final this.xHeight2,
    required final this.quad,
    required final this.extraSpace,
    required final this.num1,
    required final this.num2,
    required final this.num3,
    required final this.denom1,
    required final this.denom2,
    required final this.sup1,
    required final this.sup2,
    required final this.sup3,
    required final this.sub1,
    required final this.sub2,
    required final this.supDrop,
    required final this.subDrop,
    required final this.delim1,
    required final this.delim2,
    required final this.axisHeight2,
    required final this.defaultRuleThickness,
    required final this.bigOpSpacing1,
    required final this.bigOpSpacing2,
    required final this.bigOpSpacing3,
    required final this.bigOpSpacing4,
    required final this.bigOpSpacing5,
    required final this.sqrtRuleThickness,
    required final this.ptPerEm,
    required final this.doubleRuleSep,
    required final this.arrayRuleWidth,
    required final this.fboxsep,
    required final this.fboxrule,
  });

  static FontMetrics fromMap(
      final Map<String, double> map,
      ) {
    final _slant = map['slant'];
    final _space = map['space'];
    final _stretch = map['stretch'];
    final _shrink = map['shrink'];
    final _xHeight = map['xHeight'];
    final _quad = map['quad'];
    final _extraSpace = map['extraSpace'];
    final _num1 = map['num1'];
    final _num2 = map['num2'];
    final _num3 = map['num3'];
    final _denom1 = map['denom1'];
    final _denom2 = map['denom2'];
    final _sup1 = map['sup1'];
    final _sup2 = map['sup2'];
    final _sup3 = map['sup3'];
    final _sub1 = map['sub1'];
    final _sub2 = map['sub2'];
    final _supDrop = map['supDrop'];
    final _subDrop = map['subDrop'];
    final _delim1 = map['delim1'];
    final _delim2 = map['delim2'];
    final _axisHeight = map['axisHeight'];
    final _defaultRuleThickness = map['defaultRuleThickness'];
    final _bigOpSpacing1 = map['bigOpSpacing1'];
    final _bigOpSpacing2 = map['bigOpSpacing2'];
    final _bigOpSpacing3 = map['bigOpSpacing3'];
    final _bigOpSpacing4 = map['bigOpSpacing4'];
    final _bigOpSpacing5 = map['bigOpSpacing5'];
    final _sqrtRuleThickness = map['sqrtRuleThickness'];
    final _ptPerEm = map['ptPerEm'];
    final _doubleRuleSep = map['doubleRuleSep'];
    final _arrayRuleWidth = map['arrayRuleWidth'];
    final _fboxsep = map['fboxsep'];
    final _fboxrule = map['fboxrule'];
    if (_slant == null) throw Exception("Expected _slant to not be null");
    if (_space == null) throw Exception("Expected _space to not be null");
    if (_stretch == null) throw Exception("Expected _stretch to not be null");
    if (_shrink == null) throw Exception("Expected _shrink to not be null");
    if (_xHeight == null) throw Exception("Expected _xHeight to not be null");
    if (_quad == null) throw Exception("Expected _quad to not be null");
    if (_extraSpace == null) throw Exception("Expected _extraSpace to not be null");
    if (_num1 == null) throw Exception("Expected _num1 to not be null");
    if (_num2 == null) throw Exception("Expected _num2 to not be null");
    if (_num3 == null) throw Exception("Expected _num3 to not be null");
    if (_denom1 == null) throw Exception("Expected _denom1 to not be null");
    if (_denom2 == null) throw Exception("Expected _denom2 to not be null");
    if (_sup1 == null) throw Exception("Expected _sup1 to not be null");
    if (_sup2 == null) throw Exception("Expected _sup2 to not be null");
    if (_sup3 == null) throw Exception("Expected _sup3 to not be null");
    if (_sub1 == null) throw Exception("Expected _sub1 to not be null");
    if (_sub2 == null) throw Exception("Expected _sub2 to not be null");
    if (_supDrop == null) throw Exception("Expected _supDrop to not be null");
    if (_subDrop == null) throw Exception("Expected _subDrop to not be null");
    if (_delim1 == null) throw Exception("Expected _delim1 to not be null");
    if (_delim2 == null) throw Exception("Expected _delim2 to not be null");
    if (_axisHeight == null) throw Exception("Expected _axisHeight to not be null");
    if (_defaultRuleThickness == null) throw Exception("Expected _defaultRuleThickness to not be null");
    if (_bigOpSpacing1 == null) throw Exception("Expected _bigOpSpacing1 to not be null");
    if (_bigOpSpacing2 == null) throw Exception("Expected _bigOpSpacing2 to not be null");
    if (_bigOpSpacing3 == null) throw Exception("Expected _bigOpSpacing3 to not be null");
    if (_bigOpSpacing4 == null) throw Exception("Expected _bigOpSpacing4 to not be null");
    if (_bigOpSpacing5 == null) throw Exception("Expected _bigOpSpacing5 to not be null");
    if (_sqrtRuleThickness == null) throw Exception("Expected _sqrtRuleThickness to not be null");
    if (_ptPerEm == null) throw Exception("Expected _ptPerEm to not be null");
    if (_doubleRuleSep == null) throw Exception("Expected _doubleRuleSep to not be null");
    if (_arrayRuleWidth == null) throw Exception("Expected _arrayRuleWidth to not be null");
    if (_fboxsep == null) throw Exception("Expected _fboxsep to not be null");
    if (_fboxrule == null) throw Exception("Expected _fboxrule to not be null");
    return FontMetrics(
      slant: _slant,
      space: _space,
      stretch: _stretch,
      shrink: _shrink,
      xHeight2: cssem(_xHeight),
      quad: _quad,
      extraSpace: _extraSpace,
      num1: _num1,
      num2: _num2,
      num3: _num3,
      denom1: _denom1,
      denom2: _denom2,
      sup1: _sup1,
      sup2: _sup2,
      sup3: _sup3,
      sub1: _sub1,
      sub2: _sub2,
      supDrop: _supDrop,
      subDrop: _subDrop,
      delim1: _delim1,
      delim2: _delim2,
      axisHeight2: cssem(_axisHeight),
      defaultRuleThickness: _defaultRuleThickness,
      bigOpSpacing1: _bigOpSpacing1,
      bigOpSpacing2: _bigOpSpacing2,
      bigOpSpacing3: _bigOpSpacing3,
      bigOpSpacing4: _bigOpSpacing4,
      bigOpSpacing5: _bigOpSpacing5,
      sqrtRuleThickness: _sqrtRuleThickness,
      ptPerEm: _ptPerEm,
      doubleRuleSep: _doubleRuleSep,
      arrayRuleWidth: _arrayRuleWidth,
      fboxsep: _fboxsep,
      fboxrule: _fboxrule,
    );
  }
}

// endregion
