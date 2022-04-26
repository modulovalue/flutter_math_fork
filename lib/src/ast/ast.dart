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
class TexRedRootImpl with TexRed<TexGreenEquationrow> {
  @override
  final TexGreenEquationrow greenValue;

  TexRedRootImpl({
    required final this.greenValue,
  });

  @override
  @override
  int get pos => -1;

  @override
  Null get redParent => null;

  /// Replace node at [pos] with [newNode]
  TexRedRootImpl replaceNode(
    final TexRed pos,
    final TexGreen newNode,
  ) {
    if (identical(pos.greenValue, newNode)) {
      return this;
    } else if (identical(pos, this)) {
      return TexRedRootImpl(greenValue: greenNodeWrapWithEquationRow(newNode));
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
              ).toList(growable: false),
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
            return child.range.start <= position && child.range.end >= position;
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
            return child.range.start <= position && child.range.end >= position;
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

  TexGreenEquationrow findLowestCommonRowNode(
    final int position1,
    final int position2,
  ) {
    final redNodes1 = findNodesAtPosition(position1);
    final redNodes2 = findNodesAtPosition(position2);
    for (int index = min(redNodes1.length, redNodes2.length) - 1; index >= 0; index--) {
      final node1 = redNodes1[index].greenValue;
      final node2 = redNodes2[index].greenValue;
      if (node1 == node2 && node1 is TexGreenEquationrow) {
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
    return texClipChildrenBetween<TexGreenEquationrow>(
      rowNode,
      localPos1,
      localPos2,
    ).children;
  }
}

/// An immutable facade over [TexGreen]. It stores absolute
/// information and context parameters of an abstract syntax node which cannot
/// be stored inside [TexGreen]. Every node of the red tree is evaluated
/// top-down on demand.
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

  late final TextRange range = texGetRange(
    greenValue,
    pos,
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

// endregion

// region bases

abstract class TexGreenNonleafBase<SELF extends TexGreenNonleafBase<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreen> {
  @override
  late final cache = TexCacheGreen();

  @override
  Z match<Z>({
    required final Z Function(TexGreenNonleafBase<SELF> p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      nonleaf(this);
}

abstract class TexGreenNullableCapturedBase<SELF extends TexGreenNullableCapturedBase<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow?> {
  @override
  late final cache = TexCacheGreen();

  @override
  Z match<Z>({
    required final Z Function(TexGreenNullableCapturedBase<SELF> p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      nonleaf(this);
}

abstract class TexGreenNonnullableCapturedBase<SELF extends TexGreenNonnullableCapturedBase<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  @override
  late final cache = TexCacheGreen();

  @override
  Z match<Z>({
    required final Z Function(TexGreenNonnullableCapturedBase<SELF> p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      nonleaf(this);
}

abstract class TexGreenLeafableBase implements TexGreenLeaf {
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

/// Matrix node
class TexGreenMatrix extends TexGreenNullableCapturedBase<TexGreenMatrix> {
  /// `arrayStretch` parameter from the context.
  ///
  /// Affects the minimum row height and row depth for each row.
  ///
  /// `\smallmatrix` has an `arrayStretch` of 0.5.
  final double arrayStretch;

  /// Whether to create an extra padding before the first column and after the
  /// last column.
  final bool hskipBeforeAndAfter;

  /// Special flags for `\smallmatrix`
  final bool isSmall;

  /// Align types for each column.
  final List<MatrixColumnAlign> columnAligns;

  /// Style for vertical separator lines.
  ///
  /// This includes outermost lines. Different from MathML!
  final List<MatrixSeparatorStyle> vLines;

  /// Spacings between rows;
  final List<Measurement> rowSpacings;

  /// Style for horizontal separator lines.
  ///
  /// This includes outermost lines. Different from MathML!
  final List<MatrixSeparatorStyle> hLines;

  /// Body of the matrix.
  ///
  /// First index is line number. Second index is column number.
  final List<List<TexGreenEquationrow?>> body;

  /// Row number.
  final int rows;

  /// Column number.
  final int cols;

  TexGreenMatrix({
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
  TexGreenMatrix updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) {
    assert(newChildren.length >= rows * cols, "");
    final body = List<List<TexGreenEquationrow>>.generate(
      rows,
      (final i) => newChildren.sublist(i * cols + (i + 1) * cols),
      growable: false,
    );
    return copyWith(body: body);
  }

  TexGreenMatrix copyWith({
    final double? arrayStretch,
    final bool? hskipBeforeAndAfter,
    final bool? isSmall,
    final List<MatrixColumnAlign>? columnAligns,
    final List<MatrixSeparatorStyle>? columnLines,
    final List<Measurement>? rowSpacing,
    final List<MatrixSeparatorStyle>? rowLines,
    final List<List<TexGreenEquationrow?>>? body,
  }) =>
      matrixNodeSanitizedInputs(
        arrayStretch: arrayStretch ?? this.arrayStretch,
        hskipBeforeAndAfter: hskipBeforeAndAfter ?? this.hskipBeforeAndAfter,
        isSmall: isSmall ?? this.isSmall,
        columnAligns: columnAligns ?? this.columnAligns,
        vLines: columnLines ?? this.vLines,
        rowSpacings: rowSpacing ?? this.rowSpacings,
        hLines: rowLines ?? this.hLines,
        body: body ?? this.body,
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
      matrix(this);
}

/// Node for postscripts and prescripts
///
/// Examples:
///
/// - Word:   _     ^
/// - Latex:  _     ^
/// - MathML: msub  msup  mmultiscripts
class TexGreenMultiscripts extends TexGreenNullableCapturedBase<TexGreenMultiscripts> {
  /// Whether to align the subscript to the superscript.
  ///
  /// Mimics MathML's mmultiscripts.
  final bool alignPostscripts;

  /// Base where scripts are applied upon.
  final TexGreenEquationrow base;

  /// Subscript.
  final TexGreenEquationrow? sub;

  /// Superscript.
  final TexGreenEquationrow? sup;

  /// Presubscript.
  final TexGreenEquationrow? presub;

  /// Presuperscript.
  final TexGreenEquationrow? presup;

  TexGreenMultiscripts({
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
  TexGreenMultiscripts updateChildren(
    final List<TexGreenEquationrow?> newChildren,
  ) =>
      TexGreenMultiscripts(
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

/// N-ary operator node.
///
/// Examples: `\sum`, `\int`
class TexGreenNaryoperator extends TexGreenNullableCapturedBase<TexGreenNaryoperator> {
  /// Unicode symbol for the operator character.
  final String operator;

  /// Lower limit.
  final TexGreenEquationrow? lowerLimit;

  /// Upper limit.
  final TexGreenEquationrow? upperLimit;

  /// Argument for the N-ary operator.
  final TexGreenEquationrow naryand;

  /// Whether the limits are displayed as under/over or as scripts.
  final bool? limits;

  /// Special flag for `\smallint`.
  final bool allowLargeOp; // for \smallint

  TexGreenNaryoperator({
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
  TexGreenNaryoperator updateChildren(
    final List<TexGreenEquationrow?> newChildren,
  ) =>
      TexGreenNaryoperator(
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

/// Square root node.
///
/// Examples:
/// - Word:   `\sqrt`   `\sqrt(index & base)`
/// - Latex:  `\sqrt`   `\sqrt[index]{base}`
/// - MathML: `msqrt`   `mroot`
class TexGreenSqrt extends TexGreenNullableCapturedBase<TexGreenSqrt> {
  /// The index.
  final TexGreenEquationrow? index;

  /// The sqrt-and.
  final TexGreenEquationrow base;

  TexGreenSqrt({
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
  TexGreenSqrt updateChildren(
    final List<TexGreenEquationrow?> newChildren,
  ) =>
      TexGreenSqrt(
        index: newChildren[0],
        base: newChildren[1]!,
      );

  TexGreenSqrt copyWith({
    final TexGreenEquationrow? index,
    final TexGreenEquationrow? base,
  }) =>
      TexGreenSqrt(
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

/// Stretchy operator node.
///
/// Example: `\xleftarrow`
class TexGreenStretchyop extends TexGreenNullableCapturedBase<TexGreenStretchyop> {
  /// Unicode symbol for the operator.
  final String symbol;

  /// Arguments above the operator.
  final TexGreenEquationrow? above;

  /// Arguments below the operator.
  final TexGreenEquationrow? below;

  TexGreenStretchyop({
    required final this.above,
    required final this.below,
    required final this.symbol,
  }) : assert(above != null || below != null, "");

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
  TexGreenStretchyop updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      TexGreenStretchyop(
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

/// Equation array node. Brings support for equation alignment.
class TexGreenEquationarray extends TexGreenNonnullableCapturedBase<TexGreenEquationarray> {
  /// `arrayStretch` parameter from the context.
  ///
  /// Affects the minimum row height and row depth for each row.
  ///
  /// `\smallmatrix` has an `arrayStretch` of 0.5.
  final double arrayStretch;

  /// Whether to add an extra 3 pt spacing between each row.
  ///
  /// True for `\aligned` and `\alignedat`
  final bool addJot;

  /// Arrayed equations.
  final List<TexGreenEquationrow> body;

  /// Style for horizontal separator lines.
  ///
  /// This includes outermost lines. Different from MathML!
  final List<MatrixSeparatorStyle> hlines;

  /// Spacings between rows;
  final List<Measurement> rowSpacings;

  TexGreenEquationarray({
    required final this.body,
    final this.addJot = false,
    final this.arrayStretch = 1.0,
    final List<MatrixSeparatorStyle>? hlines,
    final List<Measurement>? rowSpacings,
  })  : hlines = (hlines ?? []).extendToByFill(body.length + 1, MatrixSeparatorStyle.none),
        rowSpacings = (rowSpacings ?? []).extendToByFill(body.length, Measurement.zero);

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
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  TexGreenEquationarray updateChildren(final List<TexGreenEquationrow> newChildren) =>
      copyWith(body: newChildren);

  TexGreenEquationarray copyWith({
    final double? arrayStretch,
    final bool? addJot,
    final List<TexGreenEquationrow>? body,
    final List<MatrixSeparatorStyle>? hlines,
    final List<Measurement>? rowSpacings,
  }) =>
      TexGreenEquationarray(
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

/// Over node.
///
/// Examples: `\underset`
class TexGreenOver extends TexGreenNonnullableCapturedBase<TexGreenOver> {
  /// Base where the over node is applied upon.
  final TexGreenEquationrow base;

  /// Argument above the base.
  final TexGreenEquationrow above;

  /// Special flag for `\stackrel`
  final bool stackRel;

  TexGreenOver({
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
  TexGreenOver updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      copyWith(base: newChildren[0], above: newChildren[1]);

  TexGreenOver copyWith({
    final TexGreenEquationrow? base,
    final TexGreenEquationrow? above,
    final bool? stackRel,
  }) =>
      TexGreenOver(
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

/// Under node.
///
/// Examples: `\underset`
class TexGreenUnder extends TexGreenNonnullableCapturedBase<TexGreenUnder> {
  /// Base where the under node is applied upon.
  final TexGreenEquationrow base;

  /// Argumentn below the base.
  final TexGreenEquationrow below;

  TexGreenUnder({
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
  TexGreenUnder updateChildren(final List<TexGreenEquationrow> newChildren) =>
      copyWith(base: newChildren[0], below: newChildren[1]);

  TexGreenUnder copyWith({
    final TexGreenEquationrow? base,
    final TexGreenEquationrow? below,
  }) =>
      TexGreenUnder(
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

/// Accent node.
///
/// Examples: `\hat`
class TexGreenAccent extends TexGreenNonnullableCapturedBase<TexGreenAccent> {
  /// Base where the accent is applied upon.
  final TexGreenEquationrow base;

  /// Unicode symbol of the accent character.
  final String label;

  /// Is the accent strecthy?
  ///
  /// Stretchy accent will stretch according to the width of [base].
  final bool isStretchy;

  /// Is the accent shifty?
  ///
  /// Shifty accent will shift according to the italic of [base].
  final bool isShifty;

  TexGreenAccent({
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
  TexGreenAccent updateChildren(final List<TexGreenEquationrow> newChildren) =>
      copyWith(base: newChildren[0]);

  TexGreenAccent copyWith({
    final TexGreenEquationrow? base,
    final String? label,
    final bool? isStretchy,
    final bool? isShifty,
  }) =>
      TexGreenAccent(
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

/// AccentUnder Nodes.
///
/// Examples: `\utilde`
class TexGreenAccentunder extends TexGreenNonnullableCapturedBase<TexGreenAccentunder> {
  /// Base where the accentUnder is applied upon.
  final TexGreenEquationrow base;

  /// Unicode symbol of the accent character.
  final String label;

  TexGreenAccentunder({
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
  TexGreenAccentunder updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      copyWith(base: newChildren[0]);

  TexGreenAccentunder copyWith({
    final TexGreenEquationrow? base,
    final String? label,
  }) =>
      TexGreenAccentunder(
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

/// Enclosure node
///
/// Examples: `\colorbox`, `\fbox`, `\cancel`.
class TexGreenEnclosure extends TexGreenNonnullableCapturedBase<TexGreenEnclosure> {
  /// Base where the enclosure is applied upon
  final TexGreenEquationrow base;

  /// Whether the enclosure has a border.
  final bool hasBorder;

  /// Border color.
  ///
  /// If null, will default to options.color.
  final Color? bordercolor;

  /// Background color.
  final Color? backgroundcolor;

  /// Special styles for this enclosure.
  ///
  /// Including `'updiagonalstrike'`, `'downdiagnoalstrike'`,
  /// and `'horizontalstrike'`.
  final List<String> notation;

  /// Horizontal padding.
  final Measurement horizontalPadding;

  /// Vertical padding.
  final Measurement verticalPadding;

  TexGreenEnclosure({
    required final this.base,
    required final this.hasBorder,
    final this.bordercolor,
    final this.backgroundcolor,
    final this.notation = const [],
    final this.horizontalPadding = Measurement.zero,
    final this.verticalPadding = Measurement.zero,
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
  TexGreenEnclosure updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      TexGreenEnclosure(
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

/// Frac node.
class TexGreenFrac extends TexGreenNonnullableCapturedBase<TexGreenFrac> {
  /// Numerator.
  final TexGreenEquationrow numerator;

  /// Denumerator.
  final TexGreenEquationrow denominator;

  /// Bar size.
  ///
  /// If null, will use default bar size.
  final Measurement? barSize;

  /// Whether it is a continued frac `\cfrac`.
  final bool continued; // TODO continued

  TexGreenFrac({
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
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  TexGreenFrac updateChildren(final List<TexGreenEquationrow> newChildren) => TexGreenFrac(
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

/// Function node
///
/// Examples: `\sin`, `\lim`, `\operatorname`
class TexGreenFunction extends TexGreenNonnullableCapturedBase<TexGreenFunction> {
  /// Name of the function.
  final TexGreenEquationrow functionName;

  /// Argument of the function.
  final TexGreenEquationrow argument;

  TexGreenFunction({
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
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  TexGreenFunction updateChildren(final List<TexGreenEquationrow> newChildren) =>
      copyWith(functionName: newChildren[0], argument: newChildren[2]);

  TexGreenFunction copyWith({
    final TexGreenEquationrow? functionName,
    final TexGreenEquationrow? argument,
  }) =>
      TexGreenFunction(
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

/// Left right node.
class TexGreenLeftright extends TexGreenNonnullableCapturedBase<TexGreenLeftright> {
  /// Unicode symbol for the left delimiter character.
  final String? leftDelim;

  /// Unicode symbol for the right delimiter character.
  final String? rightDelim;

  /// List of inside bodys.
  ///
  /// Its length should be 1 longer than [middle].
  final List<TexGreenEquationrow> body;

  /// List of middle delimiter characters.
  final List<String?> middle;

  TexGreenLeftright({
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
  TexGreenLeftright updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      TexGreenLeftright(
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

/// Raise box node which vertically displace its child.
///
/// Example: `\raisebox`
class TexGreenRaisebox extends TexGreenNonnullableCapturedBase<TexGreenRaisebox> {
  /// Child to raise.
  final TexGreenEquationrow body;

  /// Vertical displacement.
  final Measurement dy;

  TexGreenRaisebox({
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
  TexGreenRaisebox updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      copyWith(body: newChildren[0]);

  TexGreenRaisebox copyWith({
    final TexGreenEquationrow? body,
    final Measurement? dy,
  }) =>
      TexGreenRaisebox(
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

/// Node to denote all kinds of style changes.
///
/// [TexGreenStyle] refers to a node who have zero rendering content
/// itself, and are expected to be unwrapped for its children during rendering.
///
/// [TexGreenStyle]s are only allowed to appear directly under
/// [TexGreenEquationrow]s and other [TexGreenStyle]s. And those nodes have to
/// explicitly unwrap transparent nodes during building stage.
class TexGreenStyle extends TexGreenNonleafBase<TexGreenStyle> {
  @override
  final List<TexGreen> children;

  /// The difference of [MathOptions].
  final OptionsDiff optionsDiff;

  TexGreenStyle({
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
  TexGreenStyle updateChildren(
    final List<TexGreen> newChildren,
  ) =>
      TexGreenStyle(
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

  /// Children list when fully expand any underlying [TexGreenStyle]
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

/// A row of unrelated [TexGreen]s.
///
/// [TexGreenEquationrow] provides cursor-reachability and editability. It
/// represents a collection of nodes that you can freely edit and navigate.
class TexGreenEquationrow extends TexGreenNonleafBase<TexGreenEquationrow> {
  /// If non-null, the leftmost and rightmost [AtomType] will be overridden.
  final AtomType? overrideType;
  @override
  final List<TexGreen> children;

  GlobalKey? key;

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

  TexGreenEquationrow({
    required final this.children,
    final this.overrideType,
  });

  /// Children list when fully expanded any underlying [TexGreenStyle].
  late final List<TexGreen> flattenedChildList = children.expand(
    (final child) {
      if (child is TexGreenStyle) {
        return child.flattenedChildList;
      } else {
        return [child];
      }
    },
  ).toList(growable: false);

  /// Children positions when fully expanded underlying [TexGreenStyle], but
  /// appended an extra position entry for the end.
  late final List<int> caretPositions = computeCaretPositions();

  List<int> computeCaretPositions() {
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
  }

  @override
  List<MathOptions> computeChildOptions(final MathOptions options) =>
      List.filled(children.length, options, growable: false);

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  TexGreenEquationrow updateChildren(final List<TexGreen> newChildren) => copyWith(children: newChildren);

  @override
  AtomType get leftType => overrideType ?? AtomType.ord;

  @override
  AtomType get rightType => overrideType ?? AtomType.ord;

  /// Utility method.
  TexGreenEquationrow copyWith({
    final AtomType? overrideType,
    final List<TexGreen>? children,
  }) =>
      TexGreenEquationrow(
        overrideType: overrideType ?? this.overrideType,
        children: children ?? this.children,
      );

  TextRange range = const TextRange(
    start: 0,
    end: -1,
  );

  int get pos => range.start - 1;

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

/// Only for provisional use during parsing. Do not use.
abstract class TexGreenTemporary extends TexGreenLeafableBase {
  TexGreenTemporary();

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

/// Node displays vertical bar the size of [MathOptions.fontSize]
/// to replicate a text edit field cursor
class TexGreenCursor extends TexGreenLeafableBase {
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

/// Phantom node.
///
/// Example: `\phantom` `\hphantom`.
class TexGreenPhantom extends TexGreenLeafableBase {
  @override
  Mode get mode => Mode.math;

  /// The phantomed child.
  // TODO: suppress editbox in edit mode
  // If we use arbitrary GreenNode here, then we will face the danger of
  // transparent node
  final TexGreenEquationrow phantomChild;

  /// Whether to eliminate width.
  final bool zeroWidth;

  /// Whether to eliminate height.
  final bool zeroHeight;

  /// Whether to eliminate depth.
  final bool zeroDepth;

  TexGreenPhantom({
    required final this.phantomChild,
    final this.zeroHeight = false,
    final this.zeroWidth = false,
    final this.zeroDepth = false,
  });

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

/// Space node. Also used for equation alignment.
class TexGreenSpace extends TexGreenLeafableBase {
  /// Height.
  final Measurement height;

  /// Width.
  final Measurement width;

  /// Depth.
  final Measurement depth;

  /// Vertical shift.
  ///
  ///  For the sole purpose of `\rule`
  final Measurement shift;

  /// Break penalty for a manual line breaking command.
  ///
  /// Related TeX command: \nobreak, \allowbreak, \penalty<number>.
  ///
  /// Should be null for normal space commands.
  final int? breakPenalty;

  /// Whether to fill with text color.
  final bool fill;

  @override
  final Mode mode;

  final bool alignerOrSpacer;

  TexGreenSpace({
    required final this.height,
    required final this.width,
    required final this.mode,
    final this.shift = Measurement.zero,
    final this.depth = Measurement.zero,
    final this.breakPenalty,
    final this.fill = false,
    final this.alignerOrSpacer = false,
  });

  TexGreenSpace.alignerOrSpacer()
      : height = Measurement.zero,
        width = Measurement.zero,
        shift = Measurement.zero,
        depth = Measurement.zero,
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

/// Node for an unbreakable symbol.
class TexGreenSymbol extends TexGreenLeafableBase {
  /// Unicode symbol.
  final String symbol;

  /// Whether it is a variant form.
  ///
  /// Refer to MathJaX's variantForm
  final bool variantForm;

  /// Effective atom type for this symbol;
  late final AtomType atomType = overrideAtomType ??
      getDefaultAtomTypeForSymbol(
        symbol,
        variantForm: variantForm,
        mode: mode,
      );

  /// Overriding atom type;
  final AtomType? overrideAtomType;

  /// Overriding atom font;
  final FontOptions? overrideFont;

  @override
  final Mode mode;

  // bool get noBreak => symbol == '\u00AF';

  TexGreenSymbol({
    required final this.symbol,
    final this.variantForm = false,
    final this.overrideAtomType,
    final this.overrideFont,
    final this.mode = Mode.math,
  }) : assert(symbol.isNotEmpty, "");

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) =>
      oldOptions.mathFontOptions != newOptions.mathFontOptions ||
      oldOptions.textFontOptions != newOptions.textFontOptions ||
      oldOptions.sizeMultiplier != newOptions.sizeMultiplier;

  @override
  AtomType get leftType => atomType;

  @override
  AtomType get rightType => atomType;

  TexGreenSymbol withSymbol(
    final String symbol,
  ) {
    if (symbol == this.symbol) {
      return this;
    } else {
      return TexGreenSymbol(
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
