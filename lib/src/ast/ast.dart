// ignore_for_file: comment_references

import 'dart:ui' show Color, TextRange;

import 'package:flutter/material.dart';

import 'ast_plus.dart';

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
  TexRed? get redParent;

  TexGreen get greenValue;

  int get pos;

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

  /// Calculate the options passed to children when given [options] from parent
  ///
  /// Subclasses should override this method. This method provides a general
  /// description of the context & style modification introduced by this node.
  ///
  /// Please ensure [children] works in the same order as updateChildren,
  /// [computeChildOptions], and buildWidget.
  List<MathOptions> computeChildOptions(
    final MathOptions options,
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

  /// Minimum number of "right" keystrokes needed to move the cursor pass
  /// through this node (from the rightmost of the previous node, to the
  /// leftmost of the next node)
  ///
  /// Used only for editing functionalities.
  ///
  /// [editingWidth] stores intrinsic width in the editing mode.
  ///
  /// Please calculate (and cache) the width based on [children]'s widths.
  /// Note that it should strictly simulate the movement of the cursor.
  int get editingWidth;

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

  abstract GlobalKey? key;

  /// Children list when fully expanded any underlying [TexGreenStyle].
  List<TexGreen> get flattenedChildList;

  /// Children positions when fully expanded underlying [TexGreenStyle], but
  /// appended an extra position entry for the end.
  List<int> get caretPositions;

  TextRange get range;

  int get pos;

  void updatePos(
    final int pos,
  );
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

// endregion
