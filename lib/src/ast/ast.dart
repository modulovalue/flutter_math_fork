// ignore_for_file: comment_references

import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../font/font_metrics.dart';
import '../render/layout/custom_layout.dart';
import '../render/layout/eqn_array.dart';
import '../render/layout/layout_builder_baseline.dart';
import '../render/layout/line.dart';
import '../render/layout/line_editable.dart';
import '../render/layout/min_dimension.dart';
import '../render/layout/multiscripts.dart';
import '../render/layout/reset_baseline.dart';
import '../render/layout/reset_dimension.dart';
import '../render/layout/shift_baseline.dart';
import '../render/layout/vlist.dart';
import '../render/svg/static.dart';
import '../render/svg/stretchy.dart';
import '../render/symbols/make_symbol.dart';
import '../utils/extensions.dart';
import '../utils/wrapper.dart';
import '../widgets/controller.dart';
import '../widgets/mode.dart';
import '../widgets/selectable.dart';
import 'ast_plus.dart';
import 'symbols.dart';

// region interfaces

/// Roslyn's Red-Green Tree
///
/// [Description of Roslyn's Red-Green Tree](https://docs.microsoft.com/en-us/archive/blogs/ericlippert/persistence-facades-and-roslyns-red-green-trees)
class TexRoslyn {
  /// Root of the red tree.
  final TexRed<TexGreenEquationrow> redRoot;

  TexRoslyn({
    required final TexGreenEquationrow greenRoot,
  }) : redRoot = TexRed(
          redParent: null,
          greenValue: greenRoot,
          pos: -1, // Important. TODO why?
        );

  /// Replace node at [pos] with [newNode]
  TexRoslyn replaceNode(
    final TexRed pos,
    final TexGreen newNode,
  ) {
    if (identical(pos.greenValue, newNode)) {
      return this;
    } else if (identical(pos, redRoot)) {
      return TexRoslyn(greenRoot: greenNodeWrapWithEquationRow(newNode));
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
    TexRed curr = redRoot;
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
    TexRed curr = redRoot;
    TexGreenEquationrow lastEqRow = redRoot.greenValue;
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
    return redRoot.greenValue;
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
class TexRed<GREEN extends TexGreen> {
  final TexRed<TexGreen>? redParent;
  final GREEN greenValue;
  final int pos;

  TexRed({
    required final this.redParent,
    required final this.greenValue,
    required final this.pos,
  });

  /// Lazily evaluated children of the current [TexRed].
  late final List<TexRed?> children = greenValue.match(
    nonleaf: (final a) => List.generate(
      a.children.length,
      (final index) {
        if (a.children[index] != null) {
          return TexRed(
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

  /// This is where the actual widget building process happens.
  ///
  /// This method tries to reduce widget rebuilds. Rebuild bypass is determined
  /// by the following process:
  /// - If oldOptions == newOptions, bypass
  /// - If [TexGreen.shouldRebuildWidget], force rebuild
  /// - Call [buildWidget] on [children]. If the results are identical to the
  /// results returned by [buildWidget] called last time, then bypass.
  // TODO(modulovalue) it would make sense to have a caching scheme that maintains some history.
  GreenBuildResult buildWidget(
    final MathOptions newOptions,
  ) {
    final _greenValue = greenValue;
    if (_greenValue is TexGreenEquationrow) {
      _greenValue.updatePos(pos);
    }
    final makeNewChildBuildResults = () {
      return greenValue.match(
        nonleaf: (final a) {
          final childOptions = a.computeChildOptions(newOptions);
          assert(children.length == childOptions.length, "");
          if (children.isEmpty) {
            return const <GreenBuildResult>[];
          } else {
            return List.generate(
              children.length,
              (final index) => children[index]?.buildWidget(
                childOptions[index],
              ),
              growable: false,
            );
          }
        },
        leaf: (final a) => <GreenBuildResult>[],
      );
    };
    final previousOptions = greenValue.cache.oldOptions;
    final previousChildBuildResults = greenValue.cache.oldChildBuildResults;
    greenValue.cache.oldOptions = newOptions;
    if (previousOptions != null) {
      // Previous options are not null so this can't
      // be the first frame because data exists.
      if (newOptions == previousOptions) {
        // Previous options are the same as new
        // options so we can return the cached result.
        return greenValue.cache.oldBuildResult!;
      } else {
        // Not the first frame and the options are new.
        if (greenValue.shouldRebuildWidget(previousOptions, newOptions)) {
          final newWidget = greenValue.buildWidget(
            newOptions,
            () {
              final newChildBuildResults = makeNewChildBuildResults();
              // Store the new build results.
              greenValue.cache.oldChildBuildResults = newChildBuildResults;
              return newChildBuildResults;
            }(),
          );
          // We are forced to rebuild.
          greenValue.cache.oldBuildResult = newWidget;
          return newWidget;
        } else {
          final newChildBuildResults = makeNewChildBuildResults();
          if (listEquals(newChildBuildResults, previousChildBuildResults)) {
            // Do nothing and return the cached data because the
            // previous and new children build results are the same.
            return greenValue.cache.oldBuildResult!;
          } else {
            // Child results have changed. Rebuild results.
            final newWidget = greenValue.buildWidget(
              newOptions,
              newChildBuildResults,
            );
            // Store the new widget.
            greenValue.cache.oldBuildResult = newWidget;
            // Store the new results.
            greenValue.cache.oldChildBuildResults = newChildBuildResults;
            return newWidget;
          }
        }
      }
    } else {
      // The previous options were null which means
      // this is the first frame so we have to build.
      final newWidget = greenValue.buildWidget(
        newOptions,
        () {
          final newChildBuildResults = makeNewChildBuildResults();
          // Store the new build results.
          greenValue.cache.oldChildBuildResults = newChildBuildResults;
          return newChildBuildResults;
        }(),
      );
      greenValue.cache.oldBuildResult = newWidget;
      return newWidget;
    }
  }
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
  /// Compose Flutter widget with child widgets already built
  ///
  /// Subclasses should override this method. This method provides a general
  /// description of the layout of this math node. The child nodes are built in
  /// prior. This method is only responsible for the placement of those child
  /// widgets accroding to the layout & other interactions.
  ///
  /// Please ensure [children] works in the same order as [updateChildren],
  /// [computeChildOptions], and [buildWidget].
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  );

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
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) {
    assert(childBuildResults.length == rows * cols, "");
    // Flutter's Table does not provide fine-grained control of borders
    return GreenBuildResult(
      options: options,
      widget: ShiftBaseline(
        relativePos: 0.5,
        offset: cssEmMeasurement(options.fontMetrics.axisHeight).toLpUnder(options),
        child: CustomLayout<int>(
          delegate: MatrixLayoutDelegate(
            rows: rows,
            cols: cols,
            ruleThickness: cssEmMeasurement(options.fontMetrics.defaultRuleThickness).toLpUnder(options),
            arrayskip: arrayStretch * ptMeasurement(12.0).toLpUnder(options),
            rowSpacings: rowSpacings.map((final e) => e.toLpUnder(options)).toList(growable: false),
            hLines: hLines,
            hskipBeforeAndAfter: hskipBeforeAndAfter,
            arraycolsep: () {
              if (isSmall) {
                return cssEmMeasurement(5 / 18).toLpUnder(options.havingStyle(MathStyle.script));
              } else {
                return ptMeasurement(5.0).toLpUnder(options);
              }
            }(),
            vLines: vLines,
            columnAligns: columnAligns,
          ),
          children: childBuildResults
              .mapIndexed(
                (final index, final result) {
                  if (result == null) {
                    return null;
                  } else {
                    return CustomLayoutId(
                      id: index,
                      child: result.widget,
                    );
                  }
                },
              )
              .whereNotNull()
              .toList(growable: false),
        ),
      ),
    );
  }

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
  }) => matrix(this);
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
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) =>
      GreenBuildResult(
        options: options,
        widget: Multiscripts(
          alignPostscripts: alignPostscripts,
          isBaseCharacterBox:
              base.flattenedChildList.length == 1 && base.flattenedChildList[0] is TexGreenSymbol,
          baseResult: childBuildResults[0]!,
          subResult: childBuildResults[1],
          supResult: childBuildResults[2],
          presubResult: childBuildResults[3],
          presupResult: childBuildResults[4],
        ),
      );

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
  }) => multiscripts(this);
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
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) {
    final large = allowLargeOp && (mathStyleSize(options.style) == mathStyleSize(MathStyle.display));
    final font = large ? const FontOptions(fontFamily: 'Size2') : const FontOptions(fontFamily: 'Size1');
    Widget operatorWidget;
    CharacterMetrics symbolMetrics;
    if (!stashedOvalNaryOperator.containsKey(operator)) {
      final lookupResult = lookupChar(operator, font, Mode.math);
      if (lookupResult == null) {
        symbolMetrics = const CharacterMetrics(0, 0, 0, 0, 0);
        operatorWidget = Container();
      } else {
        symbolMetrics = lookupResult;
        final symbolWidget = makeChar(operator, font, symbolMetrics, options, needItalic: true);
        operatorWidget = symbolWidget;
      }
    } else {
      final baseSymbol = stashedOvalNaryOperator[operator]!;
      symbolMetrics = lookupChar(baseSymbol, font, Mode.math)!;
      final baseSymbolWidget = makeChar(baseSymbol, font, symbolMetrics, options, needItalic: true);
      final oval = staticSvg(
        '${operator == '\u222F' ? 'oiint' : 'oiiint'}'
        'Size${large ? '2' : '1'}',
        options,
      );
      operatorWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ResetDimension(
            horizontalAlignment: CrossAxisAlignment.start,
            width: 0.0,
            child: ShiftBaseline(
              offset: large ? cssEmMeasurement(0.08).toLpUnder(options) : 0.0,
              child: oval,
            ),
          ),
          baseSymbolWidget,
        ],
      );
    }
    // Attach limits to the base symbol
    if (lowerLimit != null || upperLimit != null) {
      // Should we place the limit as under/over or sub/sup
      final shouldLimits = limits ??
          (naryDefaultLimit.contains(operator) &&
              mathStyleSize(options.style) == mathStyleSize(MathStyle.display));
      final italic = cssEmMeasurement(symbolMetrics.italic).toLpUnder(options);
      if (!shouldLimits) {
        operatorWidget = Multiscripts(
          isBaseCharacterBox: false,
          baseResult: GreenBuildResult(widget: operatorWidget, options: options, italic: italic),
          subResult: childBuildResults[0],
          supResult: childBuildResults[1],
        );
      } else {
        final spacing = cssEmMeasurement(options.fontMetrics.bigOpSpacing5).toLpUnder(options);
        operatorWidget = Padding(
          padding: EdgeInsets.only(
            top: upperLimit != null ? spacing : 0,
            bottom: lowerLimit != null ? spacing : 0,
          ),
          child: VList(
            baselineReferenceWidgetIndex: upperLimit != null ? 1 : 0,
            children: [
              if (upperLimit != null)
                VListElement(
                  hShift: 0.5 * italic,
                  child: MinDimension(
                    minDepth: cssEmMeasurement(options.fontMetrics.bigOpSpacing3).toLpUnder(options),
                    bottomPadding: cssEmMeasurement(options.fontMetrics.bigOpSpacing1).toLpUnder(options),
                    child: childBuildResults[1]!.widget,
                  ),
                ),
              operatorWidget,
              if (lowerLimit != null)
                VListElement(
                  hShift: -0.5 * italic,
                  child: MinDimension(
                    minHeight: cssEmMeasurement(options.fontMetrics.bigOpSpacing4).toLpUnder(options),
                    topPadding: cssEmMeasurement(options.fontMetrics.bigOpSpacing2).toLpUnder(options),
                    child: childBuildResults[0]!.widget,
                  ),
                ),
            ],
          ),
        );
      }
    }
    final widget = Line(
      children: [
        LineElement(
          child: operatorWidget,
          trailingMargin: getSpacingSize(
            AtomType.op,
            naryand.leftType,
            options.style,
          ).toLpUnder(options),
        ),
        LineElement(
          child: childBuildResults[2]!.widget,
          trailingMargin: 0.0,
        ),
      ],
    );
    return GreenBuildResult(
      widget: widget,
      options: options,
      italic: childBuildResults[2]!.italic,
    );
  }

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
  }) => naryoperator(this);
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
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) {
    final baseResult = childBuildResults[1]!;
    final indexResult = childBuildResults[0];
    return GreenBuildResult(
      options: options,
      widget: CustomLayout<SqrtPos>(
        delegate: SqrtLayoutDelegate(
          options: options,
          baseOptions: baseResult.options,
          // indexOptions: indexResult?.options,
        ),
        children: <Widget>[
          CustomLayoutId(
            id: SqrtPos.base,
            child: MinDimension(
              minHeight: cssEmMeasurement(options.fontMetrics.xHeight).toLpUnder(options),
              topPadding: 0,
              child: baseResult.widget,
            ),
          ),
          CustomLayoutId(
            id: SqrtPos.surd,
            child: LayoutBuilderPreserveBaseline(
              builder: (final context, final constraints) => sqrtSvg(
                minDelimiterHeight: constraints.minHeight,
                baseWidth: constraints.minWidth,
                options: options,
              ),
            ),
          ),
          if (index != null)
            CustomLayoutId(
              id: SqrtPos.ind,
              child: indexResult!.widget,
            ),
        ],
      ),
    );
  }

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
  }) => sqrt(this);
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
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) {
    final verticalPadding = muMeasurement(2.0).toLpUnder(options);
    return GreenBuildResult(
      options: options,
      italic: 0.0,
      widget: VList(
        baselineReferenceWidgetIndex: above != null ? 1 : 0,
        children: <Widget>[
          if (above != null)
            Padding(
              padding: EdgeInsets.only(
                bottom: verticalPadding,
              ),
              child: childBuildResults[0]!.widget,
            ),
          VListElement(
            // From katex.less/x-arrow-pad
            customCrossSize: (final width) =>
                BoxConstraints(minWidth: width + cssEmMeasurement(1.0).toLpUnder(options)),
            child: LayoutBuilderPreserveBaseline(
              builder: (final context, final constraints) => ShiftBaseline(
                relativePos: 0.5,
                offset: cssEmMeasurement(options.fontMetrics.xHeight).toLpUnder(options),
                child: strechySvgSpan(
                  stretchyOpMapping[symbol] ?? symbol,
                  constraints.minWidth,
                  options,
                ),
              ),
            ),
          ),
          if (below != null)
            Padding(
              padding: EdgeInsets.only(top: verticalPadding),
              child: childBuildResults[1]!.widget,
            )
        ],
      ),
    );
  }

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
  }) => stretchyop(this);
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
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) =>
      GreenBuildResult(
        options: options,
        widget: ShiftBaseline(
          relativePos: 0.5,
          offset: cssEmMeasurement(options.fontMetrics.axisHeight).toLpUnder(options),
          child: EqnArray(
            ruleThickness: cssEmMeasurement(options.fontMetrics.defaultRuleThickness).toLpUnder(options),
            jotSize: addJot ? ptMeasurement(3.0).toLpUnder(options) : 0.0,
            arrayskip: ptMeasurement(12.0).toLpUnder(options) * arrayStretch,
            hlines: hlines,
            rowSpacings: rowSpacings.map((final e) => e.toLpUnder(options)).toList(growable: false),
            children: childBuildResults.map((final e) => e!.widget).toList(growable: false),
          ),
        ),
      );

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
  }) => equationarray(this);
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

  // KaTeX's corresponding code is in /src/functions/utils/assembleSubSup.js
  @override
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) {
    final spacing = cssEmMeasurement(options.fontMetrics.bigOpSpacing5).toLpUnder(options);
    return GreenBuildResult(
      options: options,
      widget: Padding(
        padding: EdgeInsets.only(
          top: spacing,
        ),
        child: VList(
          baselineReferenceWidgetIndex: 1,
          children: <Widget>[
            // TexBook Rule 13a
            MinDimension(
              minDepth: cssEmMeasurement(options.fontMetrics.bigOpSpacing3).toLpUnder(options),
              bottomPadding: cssEmMeasurement(options.fontMetrics.bigOpSpacing1).toLpUnder(options),
              child: childBuildResults[1]!.widget,
            ),
            childBuildResults[0]!.widget,
          ],
        ),
      ),
    );
  }

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
  }) => over(this);
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

  // KaTeX's corresponding code is in /src/functions/utils/assembleSubSup.js
  @override
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) {
    final spacing = cssEmMeasurement(options.fontMetrics.bigOpSpacing5).toLpUnder(options);
    return GreenBuildResult(
      italic: 0.0,
      options: options,
      widget: Padding(
        padding: EdgeInsets.only(bottom: spacing),
        child: VList(
          baselineReferenceWidgetIndex: 0,
          children: <Widget>[
            childBuildResults[0]!.widget,
            // TexBook Rule 13a
            MinDimension(
              minHeight: cssEmMeasurement(options.fontMetrics.bigOpSpacing4).toLpUnder(options),
              topPadding: cssEmMeasurement(options.fontMetrics.bigOpSpacing2).toLpUnder(options),
              child: childBuildResults[1]!.widget,
            ),
          ],
        ),
      ),
    );
  }

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
  }) => under(this);
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
  GreenBuildResult buildWidget(final MathOptions options, final List<GreenBuildResult?> childBuildResults) {
    // Checking of character box is done automatically by the passing of
    // BuildResult, so we don't need to check it here.
    final baseResult = childBuildResults[0]!;
    final skew = isShifty ? baseResult.skew : 0.0;
    Widget accentWidget;
    if (!isStretchy) {
      Widget accentSymbolWidget;
      // Following comment are selected from KaTeX:
      //
      // Before version 0.9, \vec used the combining font glyph U+20D7.
      // But browsers, especially Safari, are not consistent in how they
      // render combining characters when not preceded by a character.
      // So now we use an SVG.
      // If Safari reforms, we should consider reverting to the glyph.
      if (label == '\u2192') {
        // We need non-null baseline. Because ShiftBaseline cannot deal with a
        // baseline distance of null due to Flutter rendering pipeline design.
        accentSymbolWidget = staticSvg('vec', options, needBaseline: true);
      } else {
        final accentRenderConfig = accentRenderConfigs[label];
        if (accentRenderConfig == null || accentRenderConfig.overChar == null) {
          accentSymbolWidget = Container();
        } else {
          accentSymbolWidget = makeBaseSymbol(
            symbol: accentRenderConfig.overChar!,
            variantForm: false,
            atomType: AtomType.ord,
            mode: Mode.text,
            options: options,
          ).widget;
        }
      }

      // Non stretchy accent can not contribute to overall width, thus they must
      // fit exactly with the width even if it means overflow.
      accentWidget = LayoutBuilder(
        builder: (final context, final constraints) => ResetDimension(
          depth: 0.0, // Cut off xHeight
          width: constraints.minWidth, // Ensure width
          child: ShiftBaseline(
            // \tilde is submerged below baseline in KaTeX fonts
            relativePos: 1.0,
            // Shift baseline up by xHeight
            offset: cssEmMeasurement(-options.fontMetrics.xHeight).toLpUnder(options),
            child: accentSymbolWidget,
          ),
        ),
      );
    } else {
      // Strechy accent
      accentWidget = LayoutBuilder(
        builder: (final context, final constraints) {
          // \overline needs a special case, as KaTeX does.
          if (label == '\u00AF') {
            final defaultRuleThickness =
                cssEmMeasurement(options.fontMetrics.defaultRuleThickness).toLpUnder(options);
            return Padding(
              padding: EdgeInsets.only(bottom: 3 * defaultRuleThickness),
              child: Container(
                width: constraints.minWidth,
                height: defaultRuleThickness, // TODO minRuleThickness
                color: options.color,
              ),
            );
          } else {
            final accentRenderConfig = accentRenderConfigs[label];
            if (accentRenderConfig == null || accentRenderConfig.overImageName == null) {
              return Container();
            }
            final svgWidget = strechySvgSpan(
              accentRenderConfig.overImageName!,
              constraints.minWidth,
              options,
            );
            // \horizBrace also needs a special case, as KaTeX does.
            if (label == '\u23de') {
              return Padding(
                padding: EdgeInsets.only(bottom: cssEmMeasurement(0.1).toLpUnder(options)),
                child: svgWidget,
              );
            } else {
              return svgWidget;
            }
          }
        },
      );
    }
    return GreenBuildResult(
      options: options,
      italic: baseResult.italic,
      skew: baseResult.skew,
      widget: VList(
        baselineReferenceWidgetIndex: 1,
        children: <Widget>[
          VListElement(
            customCrossSize: (final width) => BoxConstraints(minWidth: width - 2 * skew),
            hShift: skew,
            child: accentWidget,
          ),
          // Set min height
          MinDimension(
            minHeight: cssEmMeasurement(options.fontMetrics.xHeight).toLpUnder(options),
            topPadding: 0,
            child: baseResult.widget,
          ),
        ],
      ),
    );
  }

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
  }) => accent(this);
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
  GreenBuildResult buildWidget(final MathOptions options, final List<GreenBuildResult?> childBuildResults) {
    final baseResult = childBuildResults[0]!;
    return GreenBuildResult(
      options: options,
      italic: baseResult.italic,
      skew: baseResult.skew,
      widget: VList(
        baselineReferenceWidgetIndex: 0,
        children: <Widget>[
          VListElement(
            trailingMargin: label == '\u007e' ? cssEmMeasurement(0.12).toLpUnder(options) : 0.0,
            // Special case for \utilde
            child: baseResult.widget,
          ),
          VListElement(
            customCrossSize: (final width) => BoxConstraints(minWidth: width),
            child: LayoutBuilder(
              builder: (final context, final constraints) {
                if (label == '\u00AF') {
                  final defaultRuleThickness =
                      cssEmMeasurement(options.fontMetrics.defaultRuleThickness).toLpUnder(options);
                  return Padding(
                    padding: EdgeInsets.only(top: 3 * defaultRuleThickness),
                    child: Container(
                      width: constraints.minWidth,
                      height: defaultRuleThickness, // TODO minRuleThickness
                      color: options.color,
                    ),
                  );
                } else {
                  final accentRenderConfig = accentRenderConfigs[label];
                  if (accentRenderConfig == null || accentRenderConfig.underImageName == null) {
                    return Container();
                  } else {
                    return strechySvgSpan(
                      accentRenderConfig.underImageName!,
                      constraints.minWidth,
                      options,
                    );
                  }
                }
              },
            ),
          )
        ],
      ),
    );
  }

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
  }) => accentunder(this);
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
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) {
    final horizontalPadding = this.horizontalPadding.toLpUnder(options);
    final verticalPadding = this.verticalPadding.toLpUnder(options);
    Widget widget = Stack(
      children: <Widget>[
        Container(
          // color: backgroundcolor,
          decoration: hasBorder
              ? BoxDecoration(
                  color: backgroundcolor,
                  border: Border.all(
                    // TODO minRuleThickness
                    width: cssEmMeasurement(options.fontMetrics.fboxrule).toLpUnder(options),
                    color: bordercolor ?? options.color,
                  ),
                )
              : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: horizontalPadding,
            ),
            child: childBuildResults[0]!.widget,
          ),
        ),
        if (notation.contains('updiagonalstrike'))
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: LayoutBuilder(
              builder: (final context, final constraints) => CustomPaint(
                size: constraints.biggest,
                painter: LinePainter(
                  startRelativeX: 0,
                  startRelativeY: 1,
                  endRelativeX: 1,
                  endRelativeY: 0,
                  lineWidth: cssEmMeasurement(0.046).toLpUnder(options),
                  color: bordercolor ?? options.color,
                ),
              ),
            ),
          ),
        if (notation.contains('downdiagnoalstrike'))
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: LayoutBuilder(
              builder: (final context, final constraints) => CustomPaint(
                size: constraints.biggest,
                painter: LinePainter(
                  startRelativeX: 0,
                  startRelativeY: 0,
                  endRelativeX: 1,
                  endRelativeY: 1,
                  lineWidth: cssEmMeasurement(0.046).toLpUnder(options),
                  color: bordercolor ?? options.color,
                ),
              ),
            ),
          ),
      ],
    );
    if (notation.contains('horizontalstrike')) {
      widget = CustomLayout<int>(
        delegate: HorizontalStrikeDelegate(
          vShift: cssEmMeasurement(options.fontMetrics.xHeight).toLpUnder(options) / 2,
          ruleThickness: cssEmMeasurement(options.fontMetrics.defaultRuleThickness).toLpUnder(options),
          color: bordercolor ?? options.color,
        ),
        children: <Widget>[
          CustomLayoutId(
            id: 0,
            child: widget,
          ),
        ],
      );
    }
    return GreenBuildResult(
      options: options,
      widget: widget,
    );
  }

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
  ) => false;

  @override
  TexGreenEnclosure updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) => TexGreenEnclosure(
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
  }) => enclosure(this);
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
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) =>
      GreenBuildResult(
        options: options,
        widget: CustomLayout(
          delegate: FracLayoutDelegate(
            barSize: barSize,
            options: options,
          ),
          children: <Widget>[
            CustomLayoutId(
              id: FracPos.numer,
              child: childBuildResults[0]!.widget,
            ),
            CustomLayoutId(
              id: FracPos.denom,
              child: childBuildResults[1]!.widget,
            ),
          ],
        ),
      );

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
  }) => frac(this);
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
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) =>
      GreenBuildResult(
        options: options,
        widget: Line(
          children: [
            LineElement(
              trailingMargin:
                  getSpacingSize(AtomType.op, argument.leftType, options.style).toLpUnder(options),
              child: childBuildResults[0]!.widget,
            ),
            LineElement(
              trailingMargin: 0.0,
              child: childBuildResults[1]!.widget,
            ),
          ],
        ),
      );

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
  }) => function(this);
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
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) {
    final numElements = 2 + body.length + middle.length;
    final a = cssEmMeasurement(options.fontMetrics.axisHeight).toLpUnder(options);
    final childWidgets = List.generate(
      numElements,
      (final index) {
        if (index.isEven) {
          // Delimiter
          return LineElement(
            customCrossSize: (final height, final depth) {
              final delta = max(height - a, depth + a);
              final delimeterFullHeight =
                  max(delta / 500 * delimiterFactor, 2 * delta - delimiterShorfall.toLpUnder(options));
              return BoxConstraints(
                minHeight: delimeterFullHeight,
              );
            },
            trailingMargin: index == numElements - 1
                ? 0.0
                : getSpacingSize(index == 0 ? AtomType.open : AtomType.rel, body[(index + 1) ~/ 2].leftType,
                        options.style)
                    .toLpUnder(options),
            child: LayoutBuilderPreserveBaseline(
              builder: (final context, final constraints) => buildCustomSizedDelimWidget(
                index == 0
                    ? leftDelim
                    : index == numElements - 1
                        ? rightDelim
                        : middle[index ~/ 2 - 1],
                constraints.minHeight,
                options,
              ),
            ),
          );
        } else {
          // Content
          return LineElement(
            trailingMargin: getSpacingSize(body[index ~/ 2].rightType,
                    index == numElements - 2 ? AtomType.close : AtomType.rel, options.style)
                .toLpUnder(options),
            child: childBuildResults[index ~/ 2]!.widget,
          );
        }
      },
      growable: false,
    );
    return GreenBuildResult(
      options: options,
      widget: Line(
        children: childWidgets,
      ),
    );
  }

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
  }) => leftright(this);
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
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) =>
      GreenBuildResult(
        options: options,
        widget: ShiftBaseline(
          offset: dy.toLpUnder(options),
          child: childBuildResults[0]!.widget,
        ),
      );

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
  }) => raisebox(this);
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

  @override
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) =>
      GreenBuildResult(
        widget: const Text('This widget should not appear. '
            'It means one of FlutterMath\'s AST nodes '
            'forgot to handle the case for StyleNodes'),
        options: options,
        results: childBuildResults
            .expand(
              (final result) => result!.results ?? [result],
            )
            .toList(
              growable: false,
            ),
      );

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
  }) => style(this);
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

  GlobalKey? _key;

  GlobalKey? get key => _key;

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
    var curPos = 1;
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
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) {
    final flattenedBuildResults = childBuildResults
        .expand(
          (final result) => result!.results ?? [result],
        )
        .toList(
          growable: false,
        );
    final flattenedChildOptions = flattenedBuildResults
        .map(
          (final e) => e.options,
        )
        .toList(
          growable: false,
        );
    // assert(flattenedChildList.length == actualChildWidgets.length);
    // We need to calculate spacings between nodes
    // There are several caveats to consider
    // - bin can only be bin, if it satisfies some conditions. Otherwise it will
    //   be seen as an ord
    // - There could aligners and spacers. We need to calculate the spacing
    //   after filtering them out, hence the [traverseNonSpaceNodes]
    final childSpacingConfs = List.generate(
      flattenedChildList.length,
      (final index) {
        final e = flattenedChildList[index];
        return NodeSpacingConf(
          e.leftType,
          e.rightType,
          flattenedChildOptions[index],
          0.0,
        );
      },
      growable: false,
    );
    traverseNonSpaceNodes(childSpacingConfs, (final prev, final curr) {
      if (prev?.rightType == AtomType.bin &&
          const {
            AtomType.rel,
            AtomType.close,
            AtomType.punct,
            null,
          }.contains(curr?.leftType)) {
        prev!.rightType = AtomType.ord;
        if (prev.leftType == AtomType.bin) {
          prev.leftType = AtomType.ord;
        }
      } else if (curr?.leftType == AtomType.bin &&
          const {
            AtomType.bin,
            AtomType.open,
            AtomType.rel,
            AtomType.op,
            AtomType.punct,
            null,
          }.contains(prev?.rightType)) {
        curr!.leftType = AtomType.ord;
        if (curr.rightType == AtomType.bin) {
          curr.rightType = AtomType.ord;
        }
      }
    });
    traverseNonSpaceNodes(childSpacingConfs, (final prev, final curr) {
      if (prev != null && curr != null) {
        prev.spacingAfter = getSpacingSize(
          prev.rightType,
          curr.leftType,
          curr.options.style,
        ).toLpUnder(curr.options);
      }
    });
    _key = GlobalKey();
    final lineChildren = List.generate(
      flattenedBuildResults.length,
      (final index) => LineElement(
        child: flattenedBuildResults[index].widget,
        canBreakBefore: false, // TODO
        alignerOrSpacer: () {
          final cur = flattenedChildList[index];
          return cur is TexGreenSpace && cur.alignerOrSpacer;
        }(),
        trailingMargin: childSpacingConfs[index].spacingAfter,
      ),
      growable: false,
    );
    final widget = Consumer<FlutterMathMode>(
      builder: (final context, final mode, final child) {
        if (mode == FlutterMathMode.view) {
          return Line(
            key: _key!,
            children: lineChildren,
          );
        } else {
          // Each EquationRow will filter out unrelated selection changes (changes
          // happen entirely outside the range of this EquationRow)
          return ProxyProvider<MathController, TextSelection>(
            create: (final _) => const TextSelection.collapsed(offset: -1),
            update: (final context, final controller, final _) {
              final selection = controller.selection;
              return selection.copyWith(
                baseOffset: clampInteger(
                  selection.baseOffset,
                  range.start - 1,
                  range.end + 1,
                ),
                extentOffset: clampInteger(
                  selection.extentOffset,
                  range.start - 1,
                  range.end + 1,
                ),
              );
            },
            // Selector translates global cursor position to local caret index
            // Will only update Line when selection range actually changes
            child: Selector2<TextSelection, LayerLinkTuple, LayerLinkSelectionTuple>(
              selector: (final context, final selection, final handleLayerLinks) {
                final start = selection.start - this.pos;
                final end = selection.end - this.pos;
                final caretStart = caretPositions.slotFor(start).ceil();
                final caretEnd = caretPositions.slotFor(end).floor();
                return LayerLinkSelectionTuple(
                  selection: () {
                    if (caretStart <= caretEnd) {
                      if (selection.baseOffset <= selection.extentOffset) {
                        return TextSelection(baseOffset: caretStart, extentOffset: caretEnd);
                      } else {
                        return TextSelection(baseOffset: caretEnd, extentOffset: caretStart);
                      }
                    } else {
                      return const TextSelection.collapsed(offset: -1);
                    }
                  }(),
                  start: caretPositions.contains(start) ? handleLayerLinks.start : null,
                  end: caretPositions.contains(end) ? handleLayerLinks.end : null,
                );
              },
              builder: (final context, final conf, final _) {
                final value = Provider.of<SelectionStyle>(context);
                return EditableLine(
                  key: _key,
                  children: lineChildren,
                  devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
                  node: this,
                  preferredLineHeight: options.fontSize,
                  cursorBlinkOpacityController: Provider.of<Wrapper<AnimationController>>(context).value,
                  selection: conf.selection,
                  startHandleLayerLink: conf.start,
                  endHandleLayerLink: conf.end,
                  cursorColor: value.cursorColor,
                  cursorOffset: value.cursorOffset,
                  cursorRadius: value.cursorRadius,
                  cursorWidth: value.cursorWidth,
                  cursorHeight: value.cursorHeight,
                  hintingColor: value.hintingColor,
                  paintCursorAboveText: value.paintCursorAboveText,
                  selectionColor: value.selectionColor,
                  showCursor: value.showCursor,
                );
              },
            ),
          );
        }
      },
    );
    return GreenBuildResult(
      options: options,
      italic: flattenedBuildResults.lastOrNull?.italic ?? 0.0,
      skew: flattenedBuildResults.length == 1 ? flattenedBuildResults.first.italic : 0.0,
      widget: widget,
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
  }) => equationrow(this);
}

// endregion

// region leafs

/// Only for provisional use during parsing. Do not use.
abstract class TexGreenTemporary extends TexGreenLeafableBase {
  TexGreenTemporary();

  @override
  Mode get mode => Mode.math;

  @override
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) =>
      throw UnsupportedError('Temporary node $runtimeType encountered.');

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
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) {
    final baselinePart = 1 - options.fontMetrics.axisHeight / 2;
    final height = options.fontSize * baselinePart * options.sizeMultiplier;
    final baselineDistance = height * baselinePart;
    final cursor = Container(height: height, width: 1.5, color: options.color);
    return GreenBuildResult(
        options: options,
        widget: BaselineDistance(
          baselineDistance: baselineDistance,
          child: cursor,
        ));
  }

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
  GreenBuildResult buildWidget(
    final MathOptions options,
    final List<GreenBuildResult?> childBuildResults,
  ) {
    final phantomRedNode = TexRed(redParent: null, greenValue: phantomChild, pos: 0);
    final phantomResult = phantomRedNode.buildWidget(options);
    Widget widget = Opacity(
      opacity: 0.0,
      child: phantomResult.widget,
    );
    widget = ResetDimension(
      width: zeroWidth ? 0 : null,
      height: zeroHeight ? 0 : null,
      depth: zeroDepth ? 0 : null,
      child: widget,
    );
    return GreenBuildResult(
      options: options,
      italic: phantomResult.italic,
      widget: widget,
    );
  }

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
  GreenBuildResult buildWidget(final MathOptions options, final List<GreenBuildResult?> childBuildResults) {
    if (alignerOrSpacer == true) {
      return GreenBuildResult(
        options: options,
        widget: Container(height: 0.0),
      );
    }

    final height = this.height.toLpUnder(options);
    final depth = this.depth.toLpUnder(options);
    final width = this.width.toLpUnder(options);
    final shift = this.shift.toLpUnder(options);
    final topMost = max(height, -depth) + shift;
    final bottomMost = min(height, -depth) + shift;
    return GreenBuildResult(
      options: options,
      widget: ResetBaseline(
        height: topMost,
        child: Container(
          color: fill ? options.color : null,
          height: topMost - bottomMost,
          width: max(0.0, width),
        ),
      ),
    );
  }

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
  GreenBuildResult buildWidget(final MathOptions options, final List<GreenBuildResult?> childBuildResults) {
    final expanded = symbol.runes.expand((final code) {
      final ch = String.fromCharCode(code);
      return unicodeSymbols[ch]?.split('') ?? [ch];
    }).toList(growable: false);

    // If symbol is single code
    if (expanded.length == 1) {
      return makeBaseSymbol(
        symbol: expanded[0],
        variantForm: variantForm,
        atomType: atomType,
        overrideFont: overrideFont,
        mode: mode,
        options: options,
      );
    } else if (expanded.length > 1) {
      if (isCombiningMark(expanded[1])) {
        if (expanded[0] == 'i') {
          expanded[0] = '\u0131'; // dotless i, in math and text mode
        } else if (expanded[0] == 'j') {
          expanded[0] = '\u0237'; // dotless j, in math and text mode
        }
      }
      TexGreen res = this.withSymbol(expanded[0]);
      for (final ch in expanded.skip(1)) {
        final accent = unicodeAccentsSymbols[ch];
        if (accent == null) {
          break;
        } else {
          res = TexGreenAccent(
            base: greenNodeWrapWithEquationRow(res),
            label: accent,
            isStretchy: false,
            isShifty: true,
          );
        }
      }
      return TexRed(
        redParent: null,
        greenValue: res,
        pos: 0,
      ).buildWidget(
        options,
      );
    } else {
      // TODO: log a warning here.
      return GreenBuildResult(
        widget: const SizedBox(
          height: 0,
          width: 0,
        ),
        options: options,
        italic: 0,
      );
    }
  }

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
