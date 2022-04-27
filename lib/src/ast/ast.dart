// ignore_for_file: comment_references

import 'dart:math';
import 'dart:ui' show Color, TextRange;

import 'package:flutter/material.dart';

import '../utils/extensions.dart';
import 'ast_plus.dart';

// region interfaces

/// Roslyn's Red-Green Tree
///
/// [Description of Roslyn's Red-Green Tree](https://docs.microsoft.com/en-us/archive/blogs/ericlippert/persistence-facades-and-roslyns-red-green-trees)
class TexRedEquationrowImpl with TexRed<TexGreenEquationrow> {
  @override
  final TexGreenEquationrowImpl greenValue;

  TexRedEquationrowImpl({
    required final this.greenValue,
  });

  @override
  @override
  int get pos => -1;

  @override
  Null get redParent => null;

  /// Replace node at [pos] with [newNode]
  TexRedEquationrowImpl replaceNode(
    final TexRed pos,
    final TexGreen newNode,
  ) {
    if (identical(pos.greenValue, newNode)) {
      return this;
    } else if (identical(pos, this)) {
      return TexRedEquationrowImpl(
        greenValue: greenNodeWrapWithEquationRow(
          newNode,
        ),
      );
    } else {
      final posParent = pos.redParent;
      if (posParent == null) {
        throw ArgumentError('The replaced node is not the root of this tree but has no parent');
      } else {
        return replaceNode(
          posParent,
          posParent.greenValue.match(
            nonleaf: (final a) => a.updateChildren(
              posParent.children.map(
                (final child) {
                  if (identical(child, pos)) {
                    return newNode;
                  } else {
                    return child?.greenValue;
                  }
                },
              ).toList(
                growable: false,
              ),
            ),
            leaf: (final a) => a,
          ),
        );
      }
    }
  }

  List<TexRed> findNodesAtPosition(
    final int position,
  ) {
    TexRed curr = this;
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
    final int position,
  ) {
    TexRed curr = this;
    TexGreenEquationrow lastEqRow = this.greenValue;
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
    final int position1,
    final int position2,
  ) {
    final redNodes1 = findNodesAtPosition(position1);
    final redNodes2 = findNodesAtPosition(position2);
    for (int index = min(redNodes1.length, redNodes2.length) - 1; index >= 0; index--) {
      final node1 = redNodes1[index].greenValue;
      final node2 = redNodes2[index].greenValue;
      if (node1 == node2 && node1 is TexGreenEquationrowImpl) {
        return node1;
      }
    }
    return this.greenValue;
  }

  List<TexGreen> findSelectedNodes(
    final int position1,
    final int position2,
  ) {
    final rowNode = findLowestCommonRowNode(position1, position2);
    final localPos1 = position1 - rowNode.pos;
    final localPos2 = position2 - rowNode.pos;
    return texClipChildrenBetween<TexGreenEquationrowImpl>(
      rowNode,
      localPos1,
      localPos2,
    ).children;
  }
}

/// An implementation of [TexRed].
class TexRedImpl<GREEN extends TexGreen> with TexRed<GREEN> {
  @override
  final TexRed<TexGreen>? redParent;
  @override
  final GREEN greenValue;
  @override
  final int pos;

  TexRedImpl({
    required final this.redParent,
    required final this.greenValue,
    required final this.pos,
  });
}

/// An immutable facade over [TexGreen]. It stores absolute
/// information and context parameters of an abstract syntax node which cannot
/// be stored inside [TexGreen]. Every node of the red tree is evaluated
/// top-down on demand.
mixin TexRed<GREEN extends TexGreen> {
  TexRed<TexGreen>? get redParent;

  GREEN get greenValue;

  int get pos;

  /// Lazily evaluated children of the current [TexRed].
  late final List<TexRed?> children = greenValue.match(
    nonleaf: (final a) => List.generate(
      a.children.length,
      (final index) {
        if (a.children[index] != null) {
          return TexRedImpl(
            redParent: this,
            greenValue: a.children[index]!,
            pos: this.pos + a.childPositions[index],
          );
        } else {
          return null;
        }
      },
      growable: false,
    ),
    leaf: (final a) => List.empty(
      growable: false,
    ),
  );
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
abstract class TexGreenMatrix<SELF extends TexGreenMatrix<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow?> {
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
abstract class TexGreenMultiscripts<SELF extends TexGreenMultiscripts<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow?> {
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
abstract class TexGreenNaryoperator<SELF extends TexGreenNaryoperator<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow?> {
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
abstract class TexGreenSqrt<SELF extends TexGreenSqrt<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow?> {
  /// The index.
  TexGreenEquationrow? get index;

  /// The sqrt-and.
  TexGreenEquationrow get base;
}

/// Stretchy operator node.
///
/// Example: `\xleftarrow`
abstract class TexGreenStretchyop<SELF extends TexGreenStretchyop<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow?> {
  /// Unicode symbol for the operator.
  String get symbol;

  /// Arguments above the operator.
  TexGreenEquationrow? get above;

  /// Arguments below the operator.
  TexGreenEquationrow? get below;
}

/// Equation array node. Brings support for equation alignment.
abstract class TexGreenEquationarray<SELF extends TexGreenEquationarray<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
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
abstract class TexGreenOver<SELF extends TexGreenOver<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
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
abstract class TexGreenUnder<SELF extends TexGreenUnder<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  /// Base where the under node is applied upon.
  TexGreenEquationrow get base;

  /// Arguments below the base.
  TexGreenEquationrow get below;
}

/// Accent node.
///
/// Examples: `\hat`
abstract class TexGreenAccent<SELF extends TexGreenAccent<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
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
abstract class TexGreenAccentunder<SELF extends TexGreenAccentunder<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  /// Base where the accentUnder is applied upon.
  TexGreenEquationrow get base;

  /// Unicode symbol of the accent character.
  String get label;
}

/// Enclosure node
///
/// Examples: `\colorbox`, `\fbox`, `\cancel`.
abstract class TexGreenEnclosure<SELF extends TexGreenEnclosure<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
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
abstract class TexGreenFrac<SELF extends TexGreenFrac<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
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
abstract class TexGreenFunction<SELF extends TexGreenFunction<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  /// Name of the function.
  TexGreenEquationrow get functionName;

  /// Argument of the function.
  TexGreenEquationrow get argument;
}

/// Left right node.
abstract class TexGreenLeftright<SELF extends TexGreenLeftright<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
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
abstract class TexGreenRaisebox<SELF extends TexGreenRaisebox<SELF>> implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
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
abstract class TexGreenEquationrow<SELF extends TexGreenEquationrow<SELF>> implements TexGreenTNonleaf<SELF, TexGreen> {
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

// region mixins

mixin TexGreenNonleafMixin<SELF extends TexGreenNonleafMixin<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreen> {
  @override
  late final cache = TexCacheGreen();

  @override
  Z match<Z>({
    required final Z Function(TexGreenNonleafMixin<SELF> p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      nonleaf(this);
}

mixin TexGreenNullableCapturedMixin<SELF extends TexGreenNullableCapturedMixin<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow?> {
  @override
  late final cache = TexCacheGreen();

  @override
  Z match<Z>({
    required final Z Function(TexGreenNullableCapturedMixin<SELF> p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      nonleaf(this);
}

mixin TexGreenNonnullableCapturedMixin<SELF extends TexGreenNonnullableCapturedMixin<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  @override
  late final cache = TexCacheGreen();

  @override
  Z match<Z>({
    required final Z Function(TexGreenNonnullableCapturedMixin<SELF> p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      nonleaf(this);
}

mixin TexGreenLeafableMixin implements TexGreenLeaf {
  @override
  late final cache = TexCacheGreen();

  @override
  Z match<Z>({
    required final Z Function(TexGreenNonleaf p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      leaf(this);
}

// endregion

// region nullable

class TexGreenMatrixImpl with TexGreenNullableCapturedMixin<TexGreenMatrixImpl> implements TexGreenMatrix<TexGreenMatrixImpl> {
  @override
  final double arrayStretch;
  @override
  final bool hskipBeforeAndAfter;
  @override
  final bool isSmall;
  @override
  final List<MatrixColumnAlign> columnAligns;
  @override
  final List<MatrixSeparatorStyle> vLines;
  @override
  final List<Measurement> rowSpacings;
  @override
  final List<MatrixSeparatorStyle> hLines;
  @override
  final List<List<TexGreenEquationrow?>> body;
  @override
  final int rows;
  @override
  final int cols;

  TexGreenMatrixImpl({
    required final this.rows,
    required final this.cols,
    required final this.columnAligns,
    required final this.vLines,
    required final this.rowSpacings,
    required final this.hLines,
    required final this.body,
    final this.arrayStretch = 1.0,
    final this.hskipBeforeAndAfter = false,
    final this.isSmall = false,
  })  : assert(body.length == rows, ""),
        assert(body.every((final row) => row.length == cols), ""),
        assert(columnAligns.length == cols, ""),
        assert(vLines.length == cols + 1, ""),
        assert(rowSpacings.length == rows, ""),
        assert(hLines.length == rows + 1, "");

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      List.filled(rows * cols, options, growable: false);

  @override
  late final List<TexGreenEquationrow?> children = body
      .expand(
        (final row) => row,
      )
      .toList(
        growable: false,
      );

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  TexGreenMatrixImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) {
    assert(newChildren.length >= rows * cols, "");
    final body = List<List<TexGreenEquationrow>>.generate(
      rows,
      (final i) => newChildren.sublist(i * cols + (i + 1) * cols),
      growable: false,
    );
    return matrixNodeSanitizedInputs(
      arrayStretch: this.arrayStretch,
      hskipBeforeAndAfter: this.hskipBeforeAndAfter,
      isSmall: this.isSmall,
      columnAligns: this.columnAligns,
      vLines: this.vLines,
      rowSpacings:  this.rowSpacings,
      hLines: this.hLines,
      body: body,
    );
  }

  @override
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
  }) =>
      matrix(this);
}

class TexGreenMultiscriptsImpl with TexGreenNullableCapturedMixin<TexGreenMultiscriptsImpl> implements TexGreenMultiscripts<TexGreenMultiscriptsImpl> {
  @override
  final bool alignPostscripts;
  @override
  final TexGreenEquationrow base;
  @override
  final TexGreenEquationrow? sub;
  @override
  final TexGreenEquationrow? sup;
  @override
  final TexGreenEquationrow? presub;
  @override
  final TexGreenEquationrow? presup;

  TexGreenMultiscriptsImpl({
    required final this.base,
    final this.alignPostscripts = false,
    final this.sub,
    final this.sup,
    final this.presub,
    final this.presup,
  });

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) {
    final subOptions = options.havingStyle(mathStyleSub(options.style));
    final supOptions = options.havingStyle(mathStyleSup(options.style));
    return [options, subOptions, supOptions, subOptions, supOptions];
  }

  @override
  late final children = [base, sub, sup, presub, presup];

  @override
  AtomType get leftType {
    if (presub == null && presup == null) {
      return base.leftType;
    } else {
      return AtomType.ord;
    }
  }

  @override
  AtomType get rightType {
    if (sub == null && sup == null) {
      return base.rightType;
    } else {
      return AtomType.ord;
    }
  }

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  TexGreenMultiscriptsImpl updateChildren(
    final List<TexGreenEquationrow?> newChildren,
  ) =>
      TexGreenMultiscriptsImpl(
        alignPostscripts: alignPostscripts,
        base: newChildren[0]!,
        sub: newChildren[1],
        sup: newChildren[2],
        presub: newChildren[3],
        presup: newChildren[4],
      );

  @override
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
  }) =>
      multiscripts(this);
}

class TexGreenNaryoperatorImpl with TexGreenNullableCapturedMixin<TexGreenNaryoperatorImpl> implements TexGreenNaryoperator<TexGreenNaryoperatorImpl> {
  @override
  final String operator;
  @override
  final TexGreenEquationrow? lowerLimit;
  @override
  final TexGreenEquationrow? upperLimit;
  @override
  final TexGreenEquationrow naryand;
  @override
  final bool? limits;
  @override
  final bool allowLargeOp;

  TexGreenNaryoperatorImpl({
    required final this.operator,
    required final this.lowerLimit,
    required final this.upperLimit,
    required final this.naryand,
    final this.limits,
    final this.allowLargeOp = true,
  });

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      [
        options.havingStyle(
          mathStyleSub(options.style),
        ),
        options.havingStyle(
          mathStyleSup(options.style),
        ),
        options,
      ];

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  late final children = [lowerLimit, upperLimit, naryand];

  @override
  AtomType get leftType => AtomType.op;

  @override
  AtomType get rightType => naryand.rightType;

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      oldOptions.sizeMultiplier != newOptions.sizeMultiplier;

  @override
  TexGreenNaryoperatorImpl updateChildren(
    final List<TexGreenEquationrow?> newChildren,
  ) =>
      TexGreenNaryoperatorImpl(
        operator: operator,
        lowerLimit: newChildren[0],
        upperLimit: newChildren[1],
        naryand: newChildren[2]!,
        limits: limits,
        allowLargeOp: allowLargeOp,
      );

  @override
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
  }) =>
      naryoperator(this);
}

class TexGreenSqrtImpl with TexGreenNullableCapturedMixin<TexGreenSqrtImpl> implements TexGreenSqrt<TexGreenSqrtImpl> {
  @override
  final TexGreenEquationrow? index;
  @override
  final TexGreenEquationrow base;

  TexGreenSqrtImpl({
    required final this.index,
    required final this.base,
  });

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      [
        options.havingStyle(
          MathStyle.scriptscript,
        ),
        options.havingStyle(
          mathStyleCramp(
            options.style,
          ),
        ),
      ];

  @override
  late final children = [index, base];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  TexGreenSqrtImpl updateChildren(
    final List<TexGreenEquationrow?> newChildren,
  ) =>
      TexGreenSqrtImpl(
        index: newChildren[0],
        base: newChildren[1]!,
      );

  TexGreenSqrtImpl copyWith({
    final TexGreenEquationrow? index,
    final TexGreenEquationrow? base,
  }) =>
      TexGreenSqrtImpl(
        index: index ?? this.index,
        base: base ?? this.base,
      );

  @override
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
  }) =>
      sqrt(this);
}

class TexGreenStretchyopImpl with TexGreenNullableCapturedMixin<TexGreenStretchyopImpl> implements TexGreenStretchyop<TexGreenStretchyopImpl> {
  @override
  final String symbol;
  @override
  final TexGreenEquationrow? above;
  @override
  final TexGreenEquationrow? below;

  TexGreenStretchyopImpl({
    required final this.above,
    required final this.below,
    required final this.symbol,
  }) : assert(
    above != null || below != null,
    "",
  );

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      [
        options.havingStyle(
          mathStyleSup(options.style),
        ),
        options.havingStyle(mathStyleSub(options.style)),
      ];

  @override
  late final children = [above, below];

  @override
  AtomType get leftType => AtomType.rel;

  @override
  AtomType get rightType => AtomType.rel;

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      oldOptions.sizeMultiplier != newOptions.sizeMultiplier;

  @override
  TexGreenStretchyopImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      TexGreenStretchyopImpl(
        above: newChildren[0],
        below: newChildren[1],
        symbol: symbol,
      );

  @override
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
  }) =>
      stretchyop(this);
}

// endregion

// region nonnullable

class TexGreenEquationarrayImpl with TexGreenNonnullableCapturedMixin<TexGreenEquationarrayImpl> implements TexGreenEquationarray<TexGreenEquationarrayImpl> {
  @override
  final double arrayStretch;
  @override
  final bool addJot;
  @override
  final List<TexGreenEquationrow> body;
  @override
  final List<MatrixSeparatorStyle> hlines;
  @override
  final List<Measurement> rowSpacings;

  TexGreenEquationarrayImpl({
    required final this.body,
    final this.addJot = false,
    final this.arrayStretch = 1.0,
    final List<MatrixSeparatorStyle>? hlines,
    final List<Measurement>? rowSpacings,
  })  : hlines = (hlines ?? []).extendToByFill(body.length + 1, MatrixSeparatorStyle.none),
        rowSpacings = (rowSpacings ?? []).extendToByFill(body.length, Measurement.zeroPt);

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      List.filled(body.length, options, growable: false);

  @override
  List<TexGreenEquationrow> get children => body;

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions,) => false;

  @override
  TexGreenEquationarrayImpl updateChildren(final List<TexGreenEquationrow> newChildren,) =>
      copyWith(body: newChildren);

  TexGreenEquationarrayImpl copyWith({
    final double? arrayStretch,
    final bool? addJot,
    final List<TexGreenEquationrow>? body,
    final List<MatrixSeparatorStyle>? hlines,
    final List<Measurement>? rowSpacings,
  }) =>
      TexGreenEquationarrayImpl(
        arrayStretch: arrayStretch ?? this.arrayStretch,
        addJot: addJot ?? this.addJot,
        body: body ?? this.body,
        hlines: hlines ?? this.hlines,
        rowSpacings: rowSpacings ?? this.rowSpacings,
      );

  @override
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
  }) =>
      equationarray(this);
}

class TexGreenOverImpl with TexGreenNonnullableCapturedMixin<TexGreenOverImpl> implements TexGreenOver<TexGreenOverImpl> {
  @override
  final TexGreenEquationrow base;
  @override
  final TexGreenEquationrow above;
  @override
  final bool stackRel;

  TexGreenOverImpl({
    required final this.base,
    required final this.above,
    final this.stackRel = false,
  });

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      [
        options,
        options.havingStyle(mathStyleSup(options.style)),
      ];

  @override
  late final children = [base, above];

  // TODO: they should align with binrelclass with base
  @override
  AtomType get leftType {
    if (stackRel) {
      return AtomType.rel;
    } else {
      return AtomType.ord;
    }
  }

  // TODO: they should align with binrelclass with base
  @override
  AtomType get rightType {
    if (stackRel) {
      return AtomType.rel;
    } else {
      return AtomType.ord;
    }
  }

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  TexGreenOverImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      copyWith(base: newChildren[0], above: newChildren[1]);

  TexGreenOverImpl copyWith({
    final TexGreenEquationrow? base,
    final TexGreenEquationrow? above,
    final bool? stackRel,
  }) =>
      TexGreenOverImpl(
        base: base ?? this.base,
        above: above ?? this.above,
        stackRel: stackRel ?? this.stackRel,
      );

  @override
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
  }) =>
      over(this);
}

class TexGreenUnderImpl with TexGreenNonnullableCapturedMixin<TexGreenUnderImpl> implements TexGreenUnder<TexGreenUnderImpl> {
  @override
  final TexGreenEquationrow base;
  @override
  final TexGreenEquationrow below;

  TexGreenUnderImpl({
    required final this.base,
    required final this.below,
  });

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      [
        options,
        options.havingStyle(mathStyleSub(options.style)),
      ];

  @override
  late final children = [base, below];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  TexGreenUnderImpl updateChildren(final List<TexGreenEquationrow> newChildren) =>
      copyWith(base: newChildren[0], below: newChildren[1]);

  TexGreenUnderImpl copyWith({
    final TexGreenEquationrow? base,
    final TexGreenEquationrow? below,
  }) =>
      TexGreenUnderImpl(
        base: base ?? this.base,
        below: below ?? this.below,
      );

  @override
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
  }) =>
      under(this);
}

class TexGreenAccentImpl with TexGreenNonnullableCapturedMixin<TexGreenAccentImpl> implements TexGreenAccent<TexGreenAccentImpl> {
  @override
  final TexGreenEquationrow base;
  @override
  final String label;
  @override
  final bool isStretchy;
  @override
  final bool isShifty;

  TexGreenAccentImpl({
    required final this.base,
    required final this.label,
    required final this.isStretchy,
    required final this.isShifty,
  });

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      [
        options.havingCrampedStyle(),
      ];

  @override
  late final children = [base];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  TexGreenAccentImpl updateChildren(final List<TexGreenEquationrow> newChildren) =>
      copyWith(base: newChildren[0]);

  TexGreenAccentImpl copyWith({
    final TexGreenEquationrow? base,
    final String? label,
    final bool? isStretchy,
    final bool? isShifty,
  }) =>
      TexGreenAccentImpl(
        base: base ?? this.base,
        label: label ?? this.label,
        isStretchy: isStretchy ?? this.isStretchy,
        isShifty: isShifty ?? this.isShifty,
      );

  @override
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
  }) =>
      accent(this);
}

class TexGreenAccentunderImpl with TexGreenNonnullableCapturedMixin<TexGreenAccentunderImpl> implements TexGreenAccentunder<TexGreenAccentunderImpl> {
  @override
  final TexGreenEquationrow base;
  @override
  final String label;

  TexGreenAccentunderImpl({
    required final this.base,
    required final this.label,
  });

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      [
        options.havingCrampedStyle(),
      ];

  @override
  late final children = [
    base,
  ];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  TexGreenAccentunderImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      copyWith(base: newChildren[0]);

  TexGreenAccentunderImpl copyWith({
    final TexGreenEquationrow? base,
    final String? label,
  }) =>
      TexGreenAccentunderImpl(
        base: base ?? this.base,
        label: label ?? this.label,
      );

  @override
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
  }) =>
      accentunder(this);
}

class TexGreenEnclosureImpl with TexGreenNonnullableCapturedMixin<TexGreenEnclosureImpl> implements TexGreenEnclosure<TexGreenEnclosureImpl> {
  @override
  final TexGreenEquationrow base;
  @override
  final bool hasBorder;
  @override
  final Color? bordercolor;
  @override
  final Color? backgroundcolor;
  @override
  final List<String> notation;
  @override
  final Measurement? horizontalPadding;
  @override
  final Measurement? verticalPadding;

  TexGreenEnclosureImpl({
    required final this.base,
    required final this.hasBorder,
    final this.bordercolor,
    final this.backgroundcolor,
    final this.notation = const [],
    final this.horizontalPadding,
    final this.verticalPadding,
  });

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      [
        options,
      ];

  @override
  late final children = [base];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  TexGreenEnclosureImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      TexGreenEnclosureImpl(
        base: newChildren[0],
        hasBorder: hasBorder,
        bordercolor: bordercolor,
        backgroundcolor: backgroundcolor,
        notation: notation,
        horizontalPadding: horizontalPadding,
        verticalPadding: verticalPadding,
      );

  @override
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
  }) =>
      enclosure(this);
}

class TexGreenFracImpl with TexGreenNonnullableCapturedMixin<TexGreenFracImpl> implements TexGreenFrac<TexGreenFracImpl> {
  @override
  final TexGreenEquationrow numerator;
  @override
  final TexGreenEquationrow denominator;
  @override
  final Measurement? barSize;
  @override
  final bool continued; // TODO continued

  TexGreenFracImpl({
    // this.options,
    required final this.numerator,
    required final this.denominator,
    final this.barSize,
    final this.continued = false,
  });

  @override
  late final children = [
    numerator,
    denominator,
  ];

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      [
        options.havingStyle(
          mathStyleFracNum(
            options.style,
          ),
        ),
        options.havingStyle(
          mathStyleFracDen(
            options.style,
          ),
        ),
      ];

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) => false;

  @override
  TexGreenFracImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) => TexGreenFracImpl(
        // options: options ?? this.options,
        numerator: newChildren[0],
        denominator: newChildren[1],
        barSize: barSize,
      );

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
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
  }) =>
      frac(this);
}

class TexGreenFunctionImpl with TexGreenNonnullableCapturedMixin<TexGreenFunctionImpl> implements TexGreenFunction<TexGreenFunctionImpl> {
  @override
  final TexGreenEquationrow functionName;
  @override
  final TexGreenEquationrow argument;

  TexGreenFunctionImpl({
    required final this.functionName,
    required final this.argument,
  });

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      List.filled(
        2,
        options,
        growable: false,
      );

  @override
  late final children = [
    functionName,
    argument,
  ];

  @override
  AtomType get leftType => AtomType.op;

  @override
  AtomType get rightType => argument.rightType;

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) => false;

  @override
  TexGreenFunctionImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      copyWith(functionName: newChildren[0], argument: newChildren[2]);

  TexGreenFunctionImpl copyWith({
    final TexGreenEquationrow? functionName,
    final TexGreenEquationrow? argument,
  }) =>
      TexGreenFunctionImpl(
        functionName: functionName ?? this.functionName,
        argument: argument ?? this.argument,
      );

  @override
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
  }) =>
      function(this);
}

class TexGreenLeftrightImpl with TexGreenNonnullableCapturedMixin<TexGreenLeftrightImpl> implements TexGreenLeftright<TexGreenLeftrightImpl> {
  @override
  final String? leftDelim;
  @override
  final String? rightDelim;
  @override
  final List<TexGreenEquationrow> body;
  @override
  final List<String?> middle;

  TexGreenLeftrightImpl({
    required final this.leftDelim,
    required final this.rightDelim,
    required final this.body,
    final this.middle = const [],
  })  : assert(body.isNotEmpty, ""),
        assert(middle.length == body.length - 1, "");

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      List.filled(
        body.length,
        options,
        growable: false,
      );

  @override
  late final children = body;

  @override
  AtomType get leftType => AtomType.open;

  @override
  AtomType get rightType => AtomType.close;

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  TexGreenLeftrightImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      TexGreenLeftrightImpl(
        leftDelim: leftDelim,
        rightDelim: rightDelim,
        body: newChildren,
        middle: middle,
      );

  @override
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
  }) =>
      leftright(this);
}

class TexGreenRaiseboxImpl with TexGreenNonnullableCapturedMixin<TexGreenRaiseboxImpl> implements TexGreenRaisebox<TexGreenRaiseboxImpl> {
  @override
  final TexGreenEquationrow body;
  @override
  final Measurement dy;

  TexGreenRaiseboxImpl({
    required final this.body,
    required final this.dy,
  });

  @override
  late final editingWidth = makeCommonEditingWidth(this);

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      [options];

  @override
  late final children = [body];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  TexGreenRaiseboxImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      copyWith(body: newChildren[0]);

  TexGreenRaiseboxImpl copyWith({
    final TexGreenEquationrow? body,
    final Measurement? dy,
  }) =>
      TexGreenRaiseboxImpl(
        body: body ?? this.body,
        dy: dy ?? this.dy,
      );

  @override
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
  }) =>
      raisebox(this);
}

// endregion

// region can contain any tex node.

class TexGreenStyleImpl with TexGreenNonleafMixin<TexGreenStyleImpl> implements TexGreenStyle<TexGreenStyleImpl> {
  @override
  final List<TexGreen> children;

  @override
  final OptionsDiff optionsDiff;

  TexGreenStyleImpl({
    required final this.children,
    required final this.optionsDiff,
  });

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      List.filled(
        children.length,
        options.merge(optionsDiff),
        growable: false,
      );

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  TexGreenStyleImpl updateChildren(
    final List<TexGreen> newChildren,
  ) =>
      TexGreenStyleImpl(
        children: newChildren,
        optionsDiff: optionsDiff,
      );

  @override
  late final editingWidth = integerSum(
    children.map(
      (final child) => child.editingWidthl,
    ),
  );

  @override
  late final childPositions = () {
    int curPos = 0;
    return List.generate(
      children.length + 1,
      (final index) {
        if (index == 0) return curPos;
        return curPos += children[index - 1].editingWidthl;
      },
      growable: false,
    );
  }();

  @override
  late final List<TexGreen> flattenedChildList = children.expand(
    (final child) {
      if (child is TexGreenStyle) {
        return child.flattenedChildList;
      } else {
        return [child];
      }
    },
  ).toList(growable: false);

  @override
  late final AtomType leftType = children[0].leftType;

  @override
  late final AtomType rightType = children.last.rightType;

  @override
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
  }) =>
      style(this);
}

class TexGreenEquationrowImpl with TexGreenNonleafMixin<TexGreenEquationrowImpl> implements TexGreenEquationrow<TexGreenEquationrowImpl> {
  @override
  final AtomType? overrideType;
  @override
  final List<TexGreen> children;
  @override
  GlobalKey? key;

  TexGreenEquationrowImpl({
    required final this.children,
    final this.overrideType,
  });

  @override
  late final int editingWidth = integerSum(
        children.map(
          (final child) => child.editingWidthl,
        ),
      ) +
      2;

  @override
  late final childPositions = () {
    int curPos = 1;
    return List.generate(
      children.length + 1,
      (final index) {
        if (index == 0) return curPos;
        return curPos += children[index - 1].editingWidthl;
      },
      growable: false,
    );
  }();

  @override
  late final List<TexGreen> flattenedChildList = children.expand(
    (final child) {
      if (child is TexGreenStyle) {
        return child.flattenedChildList;
      } else {
        return [child];
      }
    },
  ).toList(growable: false);

  @override
  late final List<int> caretPositions = () {
    int curPos = 1;
    return List.generate(
      flattenedChildList.length + 1,
          (final index) {
        if (index == 0) {
          return curPos;
        } else {
          return curPos += flattenedChildList[index - 1].editingWidthl;
        }
      },
      growable: false,
    );
  }();
  @override
  List<MathOptions> computeChildOptions(final MathOptions options,) =>
      List.filled(children.length, options, growable: false);

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions,) => false;

  @override
  TexGreenEquationrowImpl updateChildren(final List<TexGreen> newChildren,) => copyWith(children: newChildren);

  @override
  AtomType get leftType => overrideType ?? AtomType.ord;

  @override
  AtomType get rightType => overrideType ?? AtomType.ord;

  TexGreenEquationrowImpl copyWith({
    final AtomType? overrideType,
    final List<TexGreen>? children,
  }) =>
      TexGreenEquationrowImpl(
        overrideType: overrideType ?? this.overrideType,
        children: children ?? this.children,
      );

  @override
  TextRange range = const TextRange(
    start: 0,
    end: -1,
  );

  @override
  int get pos => range.start - 1;

  @override
  void updatePos(
    final int pos,
  ) {
    range = texGetRange(this, pos);
  }

  @override
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
  }) =>
      equationrow(this);
}

// endregion

// region leafs

abstract class TexGreenTemporaryImpl with TexGreenLeafableMixin implements TexGreenTemporary {
  @override
  Mode get mode => Mode.math;

  @override
  AtomType get leftType => throw UnsupportedError('Temporary node $runtimeType encountered.');

  @override
  AtomType get rightType => throw UnsupportedError('Temporary node $runtimeType encountered.');

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      throw UnsupportedError('Temporary node $runtimeType encountered.');

  @override
  Z matchLeaf<Z>({
    required final Z Function(TexGreenTemporary) temporary,
    required final Z Function(TexGreenCursor) cursor,
    required final Z Function(TexGreenPhantom) phantom,
    required final Z Function(TexGreenSpace) space,
    required final Z Function(TexGreenSymbol) symbol,
  }) =>
      temporary(this);
}

class TexGreenCursorImpl with TexGreenLeafableMixin implements TexGreenCursor {
  @override
  AtomType get leftType => AtomType.ord;

  @override
  Mode get mode => Mode.text;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  Z matchLeaf<Z>({
    required final Z Function(TexGreenTemporary) temporary,
    required final Z Function(TexGreenCursor) cursor,
    required final Z Function(TexGreenPhantom) phantom,
    required final Z Function(TexGreenSpace) space,
    required final Z Function(TexGreenSymbol) symbol,
  }) =>
      cursor(this);
}

class TexGreenPhantomImpl with TexGreenLeafableMixin implements TexGreenPhantom {
  // TODO: suppress editbox in edit mode
  // If we use arbitrary GreenNode here, then we will face the danger of
  // transparent node
  @override
  final TexGreenEquationrow phantomChild;
  @override
  final bool zeroWidth;
  @override
  final bool zeroHeight;
  @override
  final bool zeroDepth;

  TexGreenPhantomImpl({
    required final this.phantomChild,
    final this.zeroHeight = false,
    final this.zeroWidth = false,
    final this.zeroDepth = false,
  });

  @override
  Mode get mode => Mode.math;

  @override
  AtomType get leftType => phantomChild.leftType;

  @override
  AtomType get rightType => phantomChild.rightType;

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      phantomChild.shouldRebuildWidget(oldOptions, newOptions);

  @override
  Z matchLeaf<Z>({
    required final Z Function(TexGreenTemporary) temporary,
    required final Z Function(TexGreenCursor) cursor,
    required final Z Function(TexGreenPhantom) phantom,
    required final Z Function(TexGreenSpace) space,
    required final Z Function(TexGreenSymbol) symbol,
  }) =>
      phantom(this);
}

class TexGreenSpaceImpl with TexGreenLeafableMixin implements TexGreenSpace {
  @override
  final Measurement height;
  @override
  final Measurement width;
  @override
  final Measurement? depth;
  @override
  final Measurement? shift;
  @override
  final int? breakPenalty;
  @override
  final bool fill;
  @override
  final Mode mode;
  @override
  final bool alignerOrSpacer;

  TexGreenSpaceImpl({
    required final this.height,
    required final this.width,
    required final this.mode,
    final this.shift,
    final this.depth,
    final this.breakPenalty,
    final this.fill = false,
    final this.alignerOrSpacer = false,
  });

  TexGreenSpaceImpl.alignerOrSpacer()
      : height = Measurement.zeroPt,
        width = Measurement.zeroPt,
        shift = Measurement.zeroPt,
        depth = Measurement.zeroPt,
        breakPenalty = null,
        fill = true,
        // background = null,
        mode = Mode.math,
        alignerOrSpacer = true;

  @override
  AtomType get leftType => AtomType.spacing;

  @override
  AtomType get rightType => AtomType.spacing;

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      oldOptions.sizeMultiplier != newOptions.sizeMultiplier;

  @override
  Z matchLeaf<Z>({
    required final Z Function(TexGreenTemporary) temporary,
    required final Z Function(TexGreenCursor) cursor,
    required final Z Function(TexGreenPhantom) phantom,
    required final Z Function(TexGreenSpace) space,
    required final Z Function(TexGreenSymbol) symbol,
  }) =>
      space(this);
}

class TexGreenSymbolImpl with TexGreenLeafableMixin implements TexGreenSymbol {
  @override
  final String symbol;
  @override
  final bool variantForm;
  @override
  late final AtomType atomType = overrideAtomType ??
      getDefaultAtomTypeForSymbol(
        symbol,
        variantForm: variantForm,
        mode: mode,
      );
  @override
  final AtomType? overrideAtomType;
  @override
  final FontOptions? overrideFont;
  @override
  final Mode mode;

  // bool get noBreak => symbol == '\u00AF';

  TexGreenSymbolImpl({
    required final this.symbol,
    final this.variantForm = false,
    final this.overrideAtomType,
    final this.overrideFont,
    final this.mode = Mode.math,
  }) : assert(symbol.isNotEmpty, "");

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      oldOptions.mathFontOptions != newOptions.mathFontOptions ||
      oldOptions.textFontOptions != newOptions.textFontOptions ||
      oldOptions.sizeMultiplier != newOptions.sizeMultiplier;

  @override
  AtomType get leftType => atomType;

  @override
  AtomType get rightType => atomType;

  @override
  TexGreenSymbolImpl withSymbol(
    final String symbol,
  ) {
    if (symbol == this.symbol) {
      return this;
    } else {
      return TexGreenSymbolImpl(
        symbol: symbol,
        variantForm: variantForm,
        overrideAtomType: overrideAtomType,
        overrideFont: overrideFont,
        mode: mode,
      );
    }
  }

  @override
  Z matchLeaf<Z>({
    required final Z Function(TexGreenTemporary) temporary,
    required final Z Function(TexGreenCursor) cursor,
    required final Z Function(TexGreenPhantom) phantom,
    required final Z Function(TexGreenSpace) space,
    required final Z Function(TexGreenSymbol) symbol,
  }) =>
      symbol(this);
}

// endregion
