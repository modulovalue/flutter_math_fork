// ignore_for_file: comment_references

import 'package:flutter/material.dart' show GlobalKey, Widget;

/// Roslyn's Red-Green Tree
///
/// [Description of Roslyn's Red-Green Tree](https://docs.microsoft.com/en-us/archive/blogs/ericlippert/persistence-facades-and-roslyns-red-green-trees)
///
/// An immutable facade over [TexGreen]. It stores absolute
/// information and context parameters of an abstract syntax node which cannot
/// be stored inside [TexGreen]. Every node of the red tree is evaluated
/// top-down on demand.
///
///
/// ### Text and Math mode AST design Rationale:
///
/// We merge text-mode symbols and math-mode symbols into a single SymbolNode class but separated by their AtomTypes at the parsing time. This distinction of symbols will be preserved throughout any editing. We did not choose the following alternatives:
/// - Make a TextNode extend from EquationRowNode and only allow this type to hold TextSymbolNode as children
/// - Good for editing experience
/// - Horrible nesting of math inside text inside math while editing (which KaTeX supports). Type safety concerns for TextSymbolNode's occurance.
/// - We could straightfoward avoid math inside text during parsing. But it requires a complete re-write of the parser.
/// - Make a TextNode same as before, but adding a property in Options to change the behavior of child MathSymbolNode
/// - Similar as before without type safety concern. However a symbol will behave vastly different in two modes. Some lazy initialization become impossible and inefficient.
/// - Add a property in Options, and using a StyleNode to express mode changes
/// - Similar to above option. This StyleNode will require extra caution during AST optimization due to its property and all the text style commands beneath it.
/// - Use a tree of TextNode inspired by TextSpan
/// - How can I nest math inside text?
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
  /// Whether the specific [TexMathOptions] parameters that this node directly
  /// depends upon have changed.
  ///
  /// Subclasses should override this method. This method is used to determine
  /// whether certain widget rebuilds can be bypassed even when the
  /// [TexMathOptions] have changed.
  ///
  /// Rebuild bypass is determined by the following process:
  /// - If [oldOptions] == [newOptions], bypass
  /// - If [shouldRebuildWidget], force rebuild
  /// - Call [buildWidget] on [children]. If the results are identical to the
  /// the results returned by [buildWidget] called last time, then bypass.
  bool shouldRebuildWidget(
    final TexMathOptions oldOptions,
    final TexMathOptions newOptions,
  );

  /// [TexAtomType] observed from the left side.
  TexAtomType get leftType;

  /// [TexAtomType] observed from the right side.
  TexAtomType get rightType;

  TexCache get cache;

  Z match<Z>({
    required final Z Function(TexGreenNonleaf) nonleaf,
    required final Z Function(TexGreenLeaf) leaf,
  });
}

class TexCache {
  TexMathOptions? oldOptions;
  TexGreenBuildResult? oldBuildResult;
  List<TexGreenBuildResult?>? oldChildBuildResults;

  TexCache();
}

abstract class TexGreenNonleaf implements TexGreen {
  /// Position of child nodes.
  ///
  /// Used only for editing functionalities.
  ///
  /// This method stores the layout structure for cursor in the editing mode.
  /// You should return positions of children assume this current node is placed
  /// at the starting position. It should be no shorter than [children]. It's
  /// entirely optional to add extra hinting elements.
  List<int> get childPositions;

  Z matchNonleaf<Z>({
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  });
}

abstract class TexGreenNonleafNullable implements TexGreenNonleaf {
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

  Z matchNonleafNullable<Z>({
    required final Z Function(TexGreenMatrix) matrix,
    required final Z Function(TexGreenMultiscripts) multiscripts,
    required final Z Function(TexGreenNaryoperator) naryoperator,
    required final Z Function(TexGreenSqrt) sqrt,
    required final Z Function(TexGreenStretchyop) stretchyop,
  });
}

abstract class TexGreenNonleafNonnullable implements TexGreenNonleaf {
  /// Returns a copy of this node with new children.
  ///
  /// Subclasses should override this method. This method provides a general
  /// interface to perform structural updates for the green tree (node
  /// replacement, insertion, etc).
  ///
  /// Please ensure [children] works in the same order as [updateChildren],
  /// [computeChildOptions], and buildWidget.
  TexGreen updateChildren(
    final List<TexGreen> newChildren,
  );

  Z matchNonleafNonnullable<Z>({
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
  /// [TexMode] that this node acquires during parse.
  TexMode get mode;

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
}

/// A [TexGreen] that has children.
abstract class TexGreenTNonleafNullable<SELF extends TexGreenTNonleafNullable<SELF, CHILD>, CHILD extends TexGreen?>
    implements TexGreen, TexGreenNonleafNullable {
  @override
  SELF updateChildren(
    covariant final List<CHILD> newChildren,
  );
}

/// A [TexGreen] that has children.
abstract class TexGreenTNonleafNonnullable<SELF extends TexGreenTNonleafNonnullable<SELF, CHILD>, CHILD extends TexGreen>
    implements TexGreen, TexGreenNonleafNonnullable {
  @override
  SELF updateChildren(
    covariant final List<CHILD> newChildren,
  );
}

abstract class TexGreenFactory {
  TexGreenMatrix makeMatrix();

  TexGreenMultiscripts makeMultiscripts();

  TexGreenNaryoperator makeNaryoperator();

  TexGreenSqrt makeSqrt();

  TexGreenStretchyop makeStretchyop();

  TexGreenEquationarray makeEquationarray();

  TexGreenOver makeOver();

  TexGreenUnder makeUnder();

  TexGreenAccent makeAccent();

  TexGreenAccentunder makeAccentunder();

  TexGreenEnclosure makeEnclosure();

  TexGreenFrac makeFrac();

  TexGreenFunction makeFunction();

  TexGreenLeftright makeLeftright();

  TexGreenRaisebox makeRaisebox();

  TexGreenStyle makeStyle();

  TexGreenEquationrow makeEquationrow();

  TexGreenTemporary makeTemporary();

  TexGreenCursor makeCursor();

  TexGreenPhantom makePhantom();

  TexGreenSpace makeSpace();

  TexGreenSymbol makeSymbol();
}

/// Matrix node.
abstract class TexGreenMatrix<SELF extends TexGreenMatrix<SELF>>
    implements TexGreenTNonleafNullable<SELF, TexGreenEquationrow?> {
  List<TexGreenEquationrow?> get children;

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
  List<TexMatrixColumnAlign> get columnAligns;

  /// Style for vertical separator lines.
  ///
  /// This includes outermost lines. Different from MathML!
  List<TexMatrixSeparatorStyle> get vLines;

  /// Spacings between rows;
  List<TexMeasurement> get rowSpacings;

  /// Style for horizontal separator lines.
  ///
  /// This includes outermost lines. Different from MathML!
  List<TexMatrixSeparatorStyle> get hLines;

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
    implements TexGreenTNonleafNullable<SELF, TexGreenEquationrow?> {
  List<TexGreenEquationrow?> get children;

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
    implements TexGreenTNonleafNullable<SELF, TexGreenEquationrow?> {
  List<TexGreenEquationrow?> get children;

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
    implements TexGreenTNonleafNullable<SELF, TexGreenEquationrow?> {
  List<TexGreenEquationrow?> get children;
  /// The index.
  TexGreenEquationrow? get index;

  /// The sqrt-and.
  TexGreenEquationrow get base;
}

/// Stretchy operator node.
///
/// Example: `\xleftarrow`
abstract class TexGreenStretchyop<SELF extends TexGreenStretchyop<SELF>>
    implements TexGreenTNonleafNullable<SELF, TexGreenEquationrow?> {
  List<TexGreenEquationrow?> get children;
  /// Unicode symbol for the operator.
  String get symbol;

  /// Arguments above the operator.
  TexGreenEquationrow? get above;

  /// Arguments below the operator.
  TexGreenEquationrow? get below;
}

/// Equation array node. Brings support for equation alignment.
abstract class TexGreenEquationarray<SELF extends TexGreenEquationarray<SELF>>
    implements TexGreenTNonleafNonnullable<SELF, TexGreenEquationrow> {
  List<TexGreenEquationrow> get children;
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
  List<TexMatrixSeparatorStyle> get hlines;

  /// Spacings between rows;
  List<TexMeasurement> get rowSpacings;
}

/// Over node.
///
/// Examples: `\underset`
abstract class TexGreenOver<SELF extends TexGreenOver<SELF>>
    implements TexGreenTNonleafNonnullable<SELF, TexGreenEquationrow> {
  List<TexGreenEquationrow> get children;
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
    implements TexGreenTNonleafNonnullable<SELF, TexGreenEquationrow> {
  List<TexGreenEquationrow> get children;
  /// Base where the under node is applied upon.
  TexGreenEquationrow get base;

  /// Arguments below the base.
  TexGreenEquationrow get below;
}

/// Accent node.
///
/// Examples: `\hat`
abstract class TexGreenAccent<SELF extends TexGreenAccent<SELF>>
    implements TexGreenTNonleafNonnullable<SELF, TexGreenEquationrow> {
  List<TexGreenEquationrow> get children;
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
    implements TexGreenTNonleafNonnullable<SELF, TexGreenEquationrow> {
  List<TexGreenEquationrow> get children;
  /// Base where the accentUnder is applied upon.
  TexGreenEquationrow get base;

  /// Unicode symbol of the accent character.
  String get label;
}

/// Enclosure node
///
/// Examples: `\colorbox`, `\fbox`, `\cancel`.
abstract class TexGreenEnclosure<SELF extends TexGreenEnclosure<SELF>>
    implements TexGreenTNonleafNonnullable<SELF, TexGreenEquationrow> {
  List<TexGreenEquationrow> get children;
  /// Base where the enclosure is applied upon
  TexGreenEquationrow get base;

  /// Whether the enclosure has a border.
  bool get hasBorder;

  /// Border color.
  ///
  /// If null, will default to options.color.
  TexColor? get bordercolor;

  /// Background color.
  TexColor? get backgroundcolor;

  /// Special styles for this enclosure.
  ///
  /// Including `'updiagonalstrike'`, `'downdiagnoalstrike'`,
  /// and `'horizontalstrike'`.
  List<String> get notation;

  /// Horizontal padding.
  TexMeasurement? get horizontalPadding;

  /// Vertical padding.
  TexMeasurement? get verticalPadding;
}

/// Frac node.
abstract class TexGreenFrac<SELF extends TexGreenFrac<SELF>>
    implements TexGreenTNonleafNonnullable<SELF, TexGreenEquationrow> {
  List<TexGreenEquationrow> get children;
  /// Numerator.
  TexGreenEquationrow get numerator;

  /// Denumerator.
  TexGreenEquationrow get denominator;

  /// Bar size.
  ///
  /// If null, will use default bar size.
  TexMeasurement? get barSize;

  /// Whether it is a continued frac `\cfrac`.
  bool get continued;
}

/// Function node
///
/// Examples: `\sin`, `\lim`, `\operatorname`
abstract class TexGreenFunction<SELF extends TexGreenFunction<SELF>>
    implements TexGreenTNonleafNonnullable<SELF, TexGreenEquationrow> {
  List<TexGreenEquationrow> get children;
  /// Name of the function.
  TexGreenEquationrow get functionName;

  /// Argument of the function.
  TexGreenEquationrow get argument;
}

/// Left right node.
abstract class TexGreenLeftright<SELF extends TexGreenLeftright<SELF>>
    implements TexGreenTNonleafNonnullable<SELF, TexGreenEquationrow> {
  List<TexGreenEquationrow> get children;
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
    implements TexGreenTNonleafNonnullable<SELF, TexGreenEquationrow> {
  List<TexGreenEquationrow> get children;
  /// Child to raise.
  TexGreenEquationrow get body;

  /// Vertical displacement.
  TexMeasurement get dy;
}

/// Node to denote all kinds of style changes.
///
/// [TexGreenStyle] refers to a node who have zero rendering content
/// itself, and are expected to be unwrapped for its children during rendering.
///
/// [TexGreenStyle]s are only allowed to appear directly under
/// [TexGreenEquationrow]s and other [TexGreenStyle]s. And those nodes have to
/// explicitly unwrap transparent nodes during building stage.
abstract class TexGreenStyle<SELF extends TexGreenStyle<SELF>> implements TexGreenTNonleafNonnullable<SELF, TexGreen> {
  List<TexGreen> get children;
  /// The difference of [TexMathOptions].
  TexOptionsDiff get optionsDiff;

  /// Children list when fully expand any underlying [TexGreenStyle]
  List<TexGreen> get flattenedChildList;
}

/// A row of unrelated [TexGreen]s.
///
/// [TexGreenEquationrow] provides cursor-reachability and editability. It
/// represents a collection of nodes that you can freely edit and navigate.
abstract class TexGreenEquationrow<SELF extends TexGreenEquationrow<SELF>>
    implements TexGreenTNonleafNonnullable<SELF, TexGreen> {
  List<TexGreen> get children;
  /// If non-null, the leftmost and rightmost [TexAtomType] will be overridden.
  TexAtomType? get overrideType;

  /// Children list when fully expanded any underlying [TexGreenStyle].
  List<TexGreen> get flattenedChildList;

  /// Children positions when fully expanded underlying [TexGreenStyle], but
  /// appended an extra position entry for the end.
  List<int> get caretPositions;

  TexTextRange get range;

  void updatePos(
    final int? pos,
  );

  abstract GlobalKey? key;
}

/// Only for provisional use during parsing. Do not use.
abstract class TexGreenTemporary implements TexGreenLeaf {}

/// Node displays vertical bar the size of [TexMathOptions.fontSize]
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
  TexMeasurement get height;

  /// Width.
  TexMeasurement get width;

  /// Depth.
  TexMeasurement? get depth;

  /// Vertical shift.
  ///
  ///  For the sole purpose of `\rule`
  TexMeasurement? get shift;

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
  TexAtomType get atomType;

  /// Overriding atom type;
  TexAtomType? get overrideAtomType;

  /// Overriding atom font;
  TexFontOptions? get overrideFont;

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
enum TexAtomType {
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

enum TexMode {
  math,
  text,
}

enum TexMathSize {
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
enum TexMathStyle {
  display,
  displayCramped,
  text,
  textCramped,
  script,
  scriptCramped,
  scriptscript,
  scriptscriptCramped,
}

enum TexMatrixSeparatorStyle {
  solid,
  dashed,
  none,
}

enum TexMatrixColumnAlign {
  left,
  center,
  right,
}

abstract class TexMeasurement {
  double get value;

  bool isMu();

  bool isEm();

  bool isEx();

  double? toPoint();

  double toLpUnder(
    final TexMathOptions options,
  );

  double toCssEmUnder(
    final TexMathOptions options,
  );

  String describe();
}

/// Options for equation element rendering.
///
/// Every [TexGreen] is rendered with a [TexMathOptions]. It controls their size,
/// color, font, etc.
///
/// [TexMathOptions] is immutable. Each modification returns a new instance of
/// [TexMathOptions].
///
/// ### Use TextStyle to control the size of your equation
/// 1. `TextStyle.fontSize` will be the size of any math symbols.
/// 2. `logicalPpi` will be used to decide the size of absolute units (pt, cm, inch, etc).
/// 3. If `logicalPpi` is null, then absolute units will resize on different `TextStyle.fontSize` /// to keep a consistent ratio (Just like current `baseSizeMultiplier`'s behavior).
/// 4. `baseSizeMultiplier` is deprecated. If you still wish similar behavior, calculate relevant /// parameters from `MathOptions.defaultFontSize` and `double defaultLogicalPpi(double fontSize)`.
/// 5. If neither `TextStyle.fontSize` nor `logicalPpi` is supplied, then the widget will use the /// default `TextStyle` supplied by Flutter's build context.
///
/// ## Sanitized Error System
/// `ParseError` will be renamed to `ParseException`. Also, other throws within the library will be /// sanitized to throw either `ParseException`, `BuildException`, `EncodeExecption`. All of them /// extends `FlutterMathException`. As a result, `onErrorFallback` will have a different signature /// and allows users to handle exceptions with type safety.
///
/// Detailed exception variant can be found in their respective API documentations.
///
/// The final API will look like
/// ```
/// Math.tex(
///   r'\frac a b',
///   textStyle: TextStyle(fontSize: 42),
///   // settings: TexParserSettings(),
///   // logicalPpi: defaultLogicalPpi(42),
///   onErrorFallback: (err) => {
///     if (error is ParseException)
///       return SelectableText('ParseError: ${err.message}');
///     return Container(
///       color: Colors.red,
///       SelectableText(err.toString());
///     )
///   },
/// )
/// ```
abstract class TexMathOptions {
  /// The style used to render the math node.
  ///
  /// For displayed equations, use [TexMathStyle.display].
  ///
  /// For in-line equations, use [TexMathStyle.text].
  TexMathStyle get style;

  /// Text color.
  TexColor get color;

  /// Real size applied to equation elements under current style.
  TexMathSize get size;

  /// Declared size for equation elements.
  ///
  /// User declared size such as \tiny \Huge. The real size applied to equation
  /// elements also depends on current style.
  TexMathSize get sizeUnderTextStyle;

  /// Font options for text mode.
  ///
  /// Text-mode font options will merge on top of each other. And they will be
  /// reset if any math-mode font style is declared
  TexFontOptions? get textFontOptions;

  /// Font options for math mode.
  ///
  /// Math-mode font options will override each other.
  TexFontOptions? get mathFontOptions;

  /// Size multiplier applied to equation elements.
  double get sizeMultiplier;

  /// Font metrics under current size.
  TexFontMetrics get fontMetrics;

  /// Font size under current size.
  ///
  /// This is the font size passed to Flutter's [RichText] widget to build math
  /// symbols.
  double get fontSize;

  /// {@template flutter_math_fork.math_options.logicalPpi}
  /// Logical pixels per inch on screen.
  ///
  /// This parameter decides how big 1 inch is rendered on the screen. Affects
  /// the size of all equation elements whose size uses an absolute unit (e.g.
  /// pt, cm, inch).
  /// {@endtemplate}
  double get logicalPpi;

  /// Returns [TexMathOptions] with given [TexMathStyle]
  TexMathOptions havingStyle(final TexMathStyle style);

  /// Returns [TexMathOptions] with their styles set to cramped (e.g. textCramped)
  TexMathOptions havingCrampedStyle();

  /// Returns [TexMathOptions] with their user-declared size set to given size
  TexMathOptions havingSize(
      final TexMathSize size,
      );

  /// Returns [TexMathOptions] with size reset to [TexMathSize.normalsize] and given
  /// style. If style is not given, then the current style will be increased to
  /// at least [TexMathStyle.text]
  TexMathOptions havingStyleUnderBaseSize(
    final TexMathStyle? style,
  );

  /// Returns [TexMathOptions] with size reset to [TexMathSize.normalsize]
  TexMathOptions havingBaseSize();

  /// Returns [TexMathOptions] with given text color
  TexMathOptions withColor(
    final TexColor color,
  );

  /// Returns [TexMathOptions] with current text-mode font options merged with
  /// given font differences
  TexMathOptions withTextFont(
    final TexPartialFontOptions font,
  );

  /// Returns [TexMathOptions] with given math font
  TexMathOptions withMathFont(
    final TexFontOptions font,
  );

  /// Utility method copyWith
  TexMathOptions copyWith({
    final TexMathStyle? style,
    final TexColor? color,
    final TexMathSize? sizeUnderTextStyle,
    final TexFontOptions? textFontOptions,
    final TexFontOptions? mathFontOptions,
  });

  /// Merge an [TexOptionsDiff] into current [TexMathOptions]
  TexMathOptions merge(
      final TexOptionsDiff partialOptions,
      );
}

/// Options for font selection.
abstract class TexFontOptions {
  /// Font family. E.g. Main, Math, Sans-Serif, etc.
  String get fontFamily;

  /// Font weight. Bold or normal.
  TexFontWeight get fontWeight;

  /// Font weight. Italic or normal.
  TexFontStyle get fontShape;

  /// Fallback font options if a character cannot be found in this font.
  List<TexFontOptions> get fallback;

  /// Complete font name. Used to index [CharacterMetrics].
  String get fontName;

  /// Utility method.
  TexFontOptions copyWith({
    final String? fontFamily,
    final TexFontWeight? fontWeight,
    final TexFontStyle? fontShape,
    final List<TexFontOptions>? fallback,
  });

  /// Merge a font difference into current font.
  TexFontOptions mergeWith(
      final TexPartialFontOptions? value,
      );

  @override
  bool operator ==(
      final Object o,
      );

  @override
  int get hashCode;
}

abstract class TexFontMetrics {
  double get cssEmPerMu;

  /// sigma1
  double get slant;
  /// sigma2
  double get space;
  /// sigma3
  double get stretch;
  /// sigma4
  double get shrink;
  /// sigma5
  TexMeasurement get xHeight2;
  /// sigma6
  double get quad;
  /// sigma7
  double get extraSpace;
  /// sigma8
  double get num1;
  /// sigma9
  double get num2;
  /// sigma10
  double get num3;
  /// sigma11
  double get denom1;
  /// sigma12
  double get denom2;
  /// sigma13
  double get sup1;
  /// sigma14
  double get sup2;
  /// sigma15
  double get sup3;
  /// sigma16
  double get sub1;
  /// sigma17
  double get sub2;
  /// sigma18
  double get supDrop;
  /// sigma19
  double get subDrop;
  /// sigma20
  double get delim1;
  /// sigma21
  double get delim2;
  /// sigma22
  TexMeasurement get axisHeight2;

  // These font metrics are extracted from TeX by using tftopl on cmex10.tfm;
  // they correspond to the font parameters of the extension fonts (family 3).
  // See the TeXbook, page 441. In AMSTeX, the extension fonts scale; to
  // match cmex7, we'd use cmex7.tfm values for script and scriptscript
  // values.

  /// xi8; cmex7: 0.049
  double get defaultRuleThickness;
  /// xi9
  double get bigOpSpacing1;
  /// xi10
  double get bigOpSpacing2;
  /// xi11
  double get bigOpSpacing3;
  /// xi12; cmex7: 0.611
  double get bigOpSpacing4;
  /// xi13; cmex7: 0.143
  double get bigOpSpacing5;

  /// The \sqrt rule width is taken from the height of the surd character.
  /// Since we use the same font at all sizes, this thickness doesn't scale.
  double get sqrtRuleThickness;

  /// This value determines how large a pt is, for metrics which are defined
  /// in terms of pts.
  /// This value is also used in katex.less; if you change it make sure the
  /// values match.
  double get ptPerEm;

  /// The space between adjacent `|` columns in an array definition. From
  /// `\showthe\doublerulesep` in LaTeX. Equals 2.0 / ptPerEm.
  double get doubleRuleSep;

  /// The width of separator lines in {array} environments. From
  /// `\showthe\arrayrulewidth` in LaTeX. Equals 0.4 / ptPerEm.
  double get arrayRuleWidth;

  // Two values from LaTeX source2e:

  /// 3 pt / ptPerEm
  double get fboxsep;
  /// 0.4 pt / ptPerEm
  double get fboxrule;
}

abstract class TexGreenBuildResult {
  Widget get widget;

  TexMathOptions get options;

  double get italic;

  double get skew;

  List<TexGreenBuildResult>? get results;
}

/// Difference between the current [TexMathOptions] and the desired [TexMathOptions].
///
/// This is used to declaratively describe the modifications to [TexMathOptions].
abstract class TexOptionsDiff {
  /// Override [TexMathOptions.style]
  TexMathStyle? get style;

  /// Override declared size.
  TexMathSize? get size;

  /// Override text color.
  TexColor? get color;

  /// Merge font differences into text-mode font options.
  TexPartialFontOptions? get textFontOptions;

  /// Override math-mode font.
  TexFontOptions? get mathFontOptions;

  /// Whether this diff has no effect.
  bool get isEmpty;

  /// Strip the style change.
  TexOptionsDiff removeStyle();

  /// Strip math font changes.
  TexOptionsDiff removeMathFont();
}

/// Difference between the current [TexFontOptions] and the desired [TexFontOptions].
///
/// This is used to declaratively describe the modifications to [TexFontOptions].
abstract class TexPartialFontOptions {
  /// Override font family.
  String? get fontFamily;

  /// Override font weight.
  TexFontWeight? get fontWeight;

  /// Override font style.
  TexFontStyle? get fontShape;

  @override
  bool operator ==(
    final Object o,
  );

  @override
  int get hashCode;
}

enum TexFontWeight {
  w100,
  w200,
  w300,
  w400,
  w500,
  w600,
  w700,
  w800,
  w900,
}

abstract class TexTextRange {
  int get start;

  int get end;
}

enum TexFontStyle {
  /// Use the upright glyphs.
  normal,

  /// Use glyphs designed for slanting.
  italic,
}

abstract class TexColor {
  int get argb;

  @override
  bool operator ==(
    final Object other,
  );

  @override
  int get hashCode;
}
