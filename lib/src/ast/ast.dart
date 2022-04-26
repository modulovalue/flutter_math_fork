import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../font/font_metrics.dart';
import '../render/constants.dart';
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
import '../render/svg/delimiter.dart';
import '../render/svg/static.dart';
import '../render/svg/stretchy.dart';
import '../render/svg/svg_geomertry.dart';
import '../render/svg/svg_string.dart';
import '../render/symbols/make_symbol.dart';
import '../render/utils/render_box_layout.dart';
import '../render/utils/render_box_offset.dart';
import '../utils/extensions.dart';
import '../utils/wrapper.dart';
import '../widgets/controller.dart';
import '../widgets/mode.dart';
import '../widgets/selectable.dart';
import 'ast_plus.dart';
import 'symbols.dart';

/// Roslyn's Red-Green Tree
///
/// [Description of Roslyn's Red-Green Tree](https://docs.microsoft.com/en-us/archive/blogs/ericlippert/persistence-facades-and-roslyns-red-green-trees)
class SyntaxTree {
  /// Root of the green tree
  final EquationRowNode greenRoot;

  SyntaxTree({
    required final this.greenRoot,
  });

  /// Root of the red tree
  late final SyntaxNode root = SyntaxNode(
    parent: null,
    value: greenRoot,
    pos: -1, // Important
  );

  /// Replace node at [pos] with [newNode]
  SyntaxTree replaceNode(
    final SyntaxNode pos,
    final GreenNode newNode,
  ) {
    if (identical(pos.value, newNode)) {
      return this;
    }
    if (identical(pos, root)) {
      return SyntaxTree(greenRoot: greenNodeWrapWithEquationRow(newNode));
    }
    final posParent = pos.parent;
    if (posParent == null) {
      throw ArgumentError('The replaced node is not the root of this tree but has no parent');
    }
    return replaceNode(
        posParent,
        posParent.value.updateChildren(posParent.children
            .map((final child) {
              if (identical(child, pos)) {
                return newNode;
              } else {
                return child?.value;
              }
            })
            .toList(growable: false)));
  }

  List<SyntaxNode> findNodesAtPosition(final int position,) {
    var curr = root;
    final res = <SyntaxNode>[];
    for (;;) {
      res.add(curr);
      final next = curr.children.firstWhereOrNull((final child) {
        if (child == null) {
          return false;
        } else {
          return child.range.start <= position && child.range.end >= position;
        }
      },);
      if (next == null) {
        break;
      }
      curr = next;
    }
    return res;
  }

  EquationRowNode findNodeManagesPosition(final int position,) {
    SyntaxNode curr = root;
    EquationRowNode lastEqRow = root.value as EquationRowNode;
    for (;;) {
      final next = curr.children.firstWhereOrNull(
        (final child) => child == null ? false : child.range.start <= position && child.range.end >= position,
      );
      if (next == null) {
        break;
      }
      if (next.value is EquationRowNode) {
        lastEqRow = next.value as EquationRowNode;
      }
      curr = next;
    }
    // assert(curr.value is EquationRowNode);
    return lastEqRow;
  }

  EquationRowNode findLowestCommonRowNode(final int position1, final int position2,) {
    final redNodes1 = findNodesAtPosition(position1);
    final redNodes2 = findNodesAtPosition(position2);
    for (int index = math.min(redNodes1.length, redNodes2.length) - 1; index >= 0; index--) {
      final node1 = redNodes1[index].value;
      final node2 = redNodes2[index].value;
      if (node1 == node2 && node1 is EquationRowNode) {
        return node1;
      }
    }
    return greenRoot;
  }

  List<GreenNode> findSelectedNodes(
    final int position1,
    final int position2,
  ) {
    final rowNode = findLowestCommonRowNode(position1, position2);
    final localPos1 = position1 - rowNode.pos;
    final localPos2 = position2 - rowNode.pos;
    return rowNode.clipChildrenBetween(localPos1, localPos2).children;
  }

  Widget buildWidget(
    final MathOptions options,
  ) =>
      root.buildWidget(options).widget;
}

/// Red Node. Immutable facade for math nodes.
///
/// [Description of Roslyn's Red-Green Tree](https://docs.microsoft.com/en-us/archive/blogs/ericlippert/persistence-facades-and-roslyns-red-green-trees).
///
/// [SyntaxNode] is an immutable facade over [GreenNode]. It stores absolute
/// information and context parameters of an abstract syntax node which cannot
/// be stored inside [GreenNode]. Every node of the red tree is evaluated
/// top-down on demand.
class SyntaxNode {
  final SyntaxNode? parent;
  final GreenNode value;
  final int pos;

  SyntaxNode({
    required final this.parent,
    required final this.value,
    required final this.pos,
  });

  /// Lazily evaluated children of the current [SyntaxNode].
  late final List<SyntaxNode?> children = List.generate(
    value.children.length,
    (final index) {
      if (value.children[index] != null) {
        return SyntaxNode(
          parent: this,
          value: value.children[index]!,
          pos: this.pos + value.childPositions[index],
        );
      } else {
        return null;
      }
    },
    growable: false,
  );

  /// [GreenNode.getRange]
  late final TextRange range = value.getRange(pos);

  /// [GreenNode.editingWidth]
  int get width => value.editingWidth;

  /// [GreenNode.capturedCursor]
  int get capturedCursor => value.capturedCursor;

  /// This is where the actual widget building process happens.
  ///
  /// This method tries to reduce widget rebuilds. Rebuild bypass is determined
  /// by the following process:
  /// - If oldOptions == newOptions, bypass
  /// - If [GreenNode.shouldRebuildWidget], force rebuild
  /// - Call [buildWidget] on [children]. If the results are identical to the
  /// results returned by [buildWidget] called last time, then bypass.
  BuildResult buildWidget(
    final MathOptions options,
  ) {
    if (value is PositionDependentMixin) {
      (value as PositionDependentMixin).updatePos(pos);
    }
    if (value._oldOptions != null && options == value._oldOptions) {
      return value._oldBuildResult!;
    } else {
      final childOptions = value.computeChildOptions(options);
      final newChildBuildResults = _buildChildWidgets(childOptions);
      final bypassRebuild = value._oldOptions != null &&
          !value.shouldRebuildWidget(value._oldOptions!, options) &&
          listEquals(newChildBuildResults, value._oldChildBuildResults);
      value._oldOptions = options;
      value._oldChildBuildResults = newChildBuildResults;
      if (bypassRebuild) {
        return value._oldBuildResult!;
      } else {
        return value._oldBuildResult = value.buildWidget(options, newChildBuildResults);
      }
    }
  }

  List<BuildResult?> _buildChildWidgets(
    final List<MathOptions> childOptions,
  ) {
    assert(children.length == childOptions.length, "");
    if (children.isEmpty) {
      return const [];
    } else {
      return List.generate(
        children.length,
        (final index) => children[index]?.buildWidget(
          childOptions[index],
        ),
        growable: false,
      );
    }
  }
}

/// Node of Roslyn's Green Tree. Base class of any math nodes.
///
/// [Description of Roslyn's Red-Green Tree](https://docs.microsoft.com/en-us/archive/blogs/ericlippert/persistence-facades-and-roslyns-red-green-trees).
///
/// [GreenNode] stores any context-free information of a node and is
/// constructed bottom-up. It needs to indicate or store:
/// - Necessary parameters for this math node.
/// - Layout algorithm for this math node, if renderable.
/// - Strutural information of the tree ([children])
/// - Context-free properties for other purposes. ([editingWidth], etc.)
///
/// Due to their context-free property, [GreenNode] can be canonicalized and
/// deduplicated.
abstract class GreenNode {
  /// Children of this node.
  ///
  /// [children] stores structural information of the Red-Green Tree.
  /// Used for green tree updates. The order of children should strictly
  /// adheres to the cursor-visiting order in editing mode, in order to get a
  /// correct cursor range in the editing mode. E.g., for [SqrtNode], when
  /// moving cursor from left to right, the cursor first enters index, then
  /// base, so it should return [index, base].
  ///
  /// Please ensure [children] works in the same order as [updateChildren],
  /// [computeChildOptions], and [buildWidget].
  List<GreenNode?> get children;

  /// Return a copy of this node with new children.
  ///
  /// Subclasses should override this method. This method provides a general
  /// interface to perform structural updates for the green tree (node
  /// replacement, insertion, etc).
  ///
  /// Please ensure [children] works in the same order as [updateChildren],
  /// [computeChildOptions], and [buildWidget].
  GreenNode updateChildren(
    final List<GreenNode?> newChildren,
  );

  /// Calculate the options passed to children when given [options] from parent
  ///
  /// Subclasses should override this method. This method provides a general
  /// description of the context & style modification introduced by this node.
  ///
  /// Please ensure [children] works in the same order as [updateChildren],
  /// [computeChildOptions], and [buildWidget].
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  );

  /// Compose Flutter widget with child widgets already built
  ///
  /// Subclasses should override this method. This method provides a general
  /// description of the layout of this math node. The child nodes are built in
  /// prior. This method is only responsible for the placement of those child
  /// widgets accroding to the layout & other interactions.
  ///
  /// Please ensure [children] works in the same order as [updateChildren],
  /// [computeChildOptions], and [buildWidget].
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
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

  /// Minimum number of "right" keystrokes needed to move the cursor pass
  /// through this node (from the rightmost of the previous node, to the
  /// leftmost of the next node)
  ///
  /// Used only for editing functionalities.
  ///
  /// [editingWidth] stores intrinsic width in the editing mode.
  ///
  /// Please calculate (and cache) the width based on [children]'s widths.
  /// Note that it should strictly simulate the movement of the curosr.
  int get editingWidth;

  /// Number of cursor positions that can be captured within this node.
  ///
  /// By definition, [capturedCursor] = [editingWidth] - 1.
  /// By definition, [TextRange.end] - [TextRange.start] = capturedCursor - 1.
  int get capturedCursor;

  /// [TextRange]
  TextRange getRange(
    final int pos,
  );

  /// Position of child nodes.
  ///
  /// Used only for editing functionalities.
  ///
  /// This method stores the layout strucuture for cursor in the editing mode.
  /// You should return positions of children assume this current node is placed
  /// at the starting position. It should be no shorter than [children]. It's
  /// entirely optional to add extra hinting elements.
  List<int> get childPositions;

  /// [AtomType] observed from the left side.
  AtomType get leftType;

  /// [AtomType] observed from the right side.
  AtomType get rightType;

  abstract MathOptions? _oldOptions;

  abstract BuildResult? _oldBuildResult;

  abstract List<BuildResult?>? _oldChildBuildResults;
}

abstract class GreenNodeT<SELF extends GreenNode, CHILD extends GreenNode?> implements GreenNode {
  @override
  List<CHILD> get children;

  @override
  SELF updateChildren(
    covariant final List<CHILD> newChildren,
  );
}

mixin GreenNodeMixin<SELF extends GreenNode, CHILD extends GreenNode?> implements GreenNodeT<SELF, CHILD> {
  @override
  int get capturedCursor => editingWidth - 1;

  @override
  TextRange getRange(
    final int pos,
  ) =>
      TextRange(
        start: pos + 1,
        end: pos + capturedCursor,
      );

  @override
  MathOptions? _oldOptions;

  @override
  BuildResult? _oldBuildResult;

  @override
  List<BuildResult?>? _oldChildBuildResults;
}

/// [GreenNode] that can have children
mixin ParentableNode<SELF extends ParentableNode<SELF, CHILD>, CHILD extends GreenNode?> implements GreenNodeMixin<SELF, CHILD> {
  @override
  List<CHILD> get children;

  @override
  late final int editingWidth = computeWidth();

  /// Compute width from children. Abstract.
  int computeWidth();

  @override
  late final List<int> childPositions = computeChildPositions();

  /// Compute children positions. Abstract.
  List<int> computeChildPositions();

  @override
  SELF updateChildren(
    final List<CHILD?> newChildren,
  );
}

mixin PositionDependentMixin<SELF extends PositionDependentMixin<SELF, T>, T extends GreenNode>
    implements ParentableNode<SELF, T> {
  TextRange range = const TextRange(
    start: 0,
    end: -1,
  );

  int get pos => range.start - 1;

  void updatePos(final int pos) {
    range = getRange(pos);
  }
}

/// [SlotableNode] is those composite node that has editable [EquationRowNode]
/// as children and lay them out into certain slots.
///
/// [SlotableNode] is the most commonly-used node. They share cursor logic and
/// editing logic.
///
/// Depending on node type, some [SlotableNode] can have nulls inside their
/// children list. When null is allowed, it usually means that node will have
/// different layout slot logic depending on non-null children number.
mixin SlotableNode<SELF extends SlotableNode<SELF, T>, T extends EquationRowNode?> implements GreenNodeT<SELF, T>, ParentableNode<SELF, T> {
  @override
  late final List<T> children = computeChildren();

  /// Compute children. Abstract.
  ///
  /// Used to cache children list.
  List<T> computeChildren();

  @override
  int computeWidth() =>
      integerSum(
        children.map(
          (final child) => child?.capturedCursor ?? 0,
        ),
      ) +
      1;

  @override
  List<int> computeChildPositions() {
    var curPos = 0;
    final result = <int>[];
    for (final child in children) {
      result.add(curPos);
      curPos += child?.capturedCursor ?? 0;
    }
    return result;
  }
}

/// [TransparentNode] refers to those node who have zero rendering content
/// iteself, and are expected to be unwrapped for its children during rendering.
///
/// [TransparentNode]s are only allowed to appear directly under
/// [EquationRowNode]s and other [TransparentNode]s. And those nodes have to
/// explicitly unwrap transparent nodes during building stage.
mixin TransparentNode<SELF extends TransparentNode<SELF>> implements GreenNodeT<SELF, GreenNode>, ParentableNode<SELF, GreenNode>,
    GreenNodeMixin<SELF, GreenNode>,
    ClipChildrenMixin<SELF> {
  @override
  int computeWidth() => integerSum(
        children.map(
          (final child) => child.editingWidth,
        ),
      );

  @override
  List<int> computeChildPositions() {
    int curPos = 0;
    return List.generate(
      children.length + 1,
      (final index) {
        if (index == 0) return curPos;
        return curPos += children[index - 1].editingWidth;
      },
      growable: false,
    );
  }

  @override
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) =>
      BuildResult(
        widget: const Text('This widget should not appear. '
            'It means one of FlutterMath\'s AST nodes '
            'forgot to handle the case for TransparentNodes'),
        options: options,
        results: childBuildResults
            .expand(
              (final result) => result!.results ?? [result],
            )
            .toList(
              growable: false,
            ),
      );

  /// Children list when fully expand any underlying [TransparentNode]
  late final List<GreenNode> flattenedChildList = children.expand(
    (final child) {
      if (child is TransparentNode) {
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
}

mixin ClipChildrenMixin<SELF extends ClipChildrenMixin<SELF>> implements ParentableNode<SELF, GreenNode> {
  SELF clipChildrenBetween(
      final int pos1,
      final int pos2,
      ) {
    final childIndex1 = childPositions.slotFor(pos1);
    final childIndex2 = childPositions.slotFor(pos2);
    final childIndex1Floor = childIndex1.floor();
    final childIndex1Ceil = childIndex1.ceil();
    final childIndex2Floor = childIndex2.floor();
    final childIndex2Ceil = childIndex2.ceil();
    GreenNode? head;
    GreenNode? tail;
    if (childIndex1Floor != childIndex1 && childIndex1Floor >= 0 && childIndex1Floor <= children.length - 1) {
      final child = children[childIndex1Floor];
      if (child is TransparentNode) {
        head = child.clipChildrenBetween(
            pos1 - childPositions[childIndex1Floor], pos2 - childPositions[childIndex1Floor]);
      } else {
        head = child;
      }
    }
    if (childIndex2Ceil != childIndex2 && childIndex2Floor >= 0 && childIndex2Floor <= children.length - 1) {
      final child = children[childIndex2Floor];
      if (child is TransparentNode) {
        tail = child.clipChildrenBetween(
            pos1 - childPositions[childIndex2Floor], pos2 - childPositions[childIndex2Floor]);
      } else {
        tail = child;
      }
    }
    return this.updateChildren(
      <GreenNode>[
        if (head != null) head,
        for (int i = childIndex1Ceil; i < childIndex2Floor; i++) children[i],
        if (tail != null) tail,
      ],
    );
  }
}

/// [GreenNode] that doesn't have any children
mixin LeafNode<SELF extends GreenNode> implements GreenNodeT<SELF, GreenNode> {
  /// [Mode] that this node acquires during parse.
  Mode get mode;

  @override
  List<GreenNode> get children => const [];

  @override
  SELF updateChildren(
      final List<GreenNode> newChildren,
      ) {
    assert(newChildren.isEmpty, "");
    return self();
  }

  SELF self();

  @override
  List<MathOptions> computeChildOptions(
      final MathOptions options,
      ) =>
      const [];

  @override
  List<int> get childPositions => const [];

  @override
  int get editingWidth => 1;
}

/// A row of unrelated [GreenNode]s.
///
/// [EquationRowNode] provides cursor-reachability and editability. It
/// represents a collection of nodes that you can freely edit and navigate.
class EquationRowNode with ParentableNode<EquationRowNode, GreenNode>,
        GreenNodeMixin<EquationRowNode, GreenNode>,
        PositionDependentMixin<EquationRowNode, GreenNode>,
        ClipChildrenMixin<EquationRowNode>,
        GreenNodeMixin<EquationRowNode, GreenNode> {
  /// If non-null, the leftmost and rightmost [AtomType] will be overridden.
  final AtomType? overrideType;

  @override
  final List<GreenNode> children;

  GlobalKey? _key;

  GlobalKey? get key => _key;

  @override
  int computeWidth() =>
      integerSum(
        children.map(
          (final child) => child.editingWidth,
        ),
      ) +
      2;

  @override
  List<int> computeChildPositions() {
    int curPos = 1;
    return List.generate(
      children.length + 1,
      (final index) {
        if (index == 0) return curPos;
        return curPos += children[index - 1].editingWidth;
      },
      growable: false,
    );
  }

  EquationRowNode({
    required final this.children,
    final this.overrideType,
  });

  /// Children list when fully expanded any underlying [TransparentNode].
  late final List<GreenNode> flattenedChildList = children.expand(
    (final child) {
      if (child is TransparentNode) {
        return child.flattenedChildList;
      } else {
        return [child];
      }
    },
  ).toList(growable: false);

  /// Children positions when fully expanded underlying [TransparentNode], but
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
          return curPos += flattenedChildList[index - 1].editingWidth;
        }
      },
      growable: false,
    );
  }

  @override
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
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
        return _NodeSpacingConf(
          e.leftType,
          e.rightType,
          flattenedChildOptions[index],
          0.0,
        );
      },
      growable: false,
    );
    _traverseNonSpaceNodes(childSpacingConfs, (final prev, final curr) {
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
    _traverseNonSpaceNodes(childSpacingConfs, (final prev, final curr) {
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
        alignerOrSpacer: flattenedChildList[index] is SpaceNode &&
            (flattenedChildList[index] as SpaceNode).alignerOrSpacer,
        trailingMargin: childSpacingConfs[index].spacingAfter,
      ),
      growable: false,
    );
    final widget = Consumer<FlutterMathMode>(builder: (final context, final mode, final child) {
      if (mode == FlutterMathMode.view) {
        return Line(
          key: _key!,
          children: lineChildren,
        );
      }
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
    });
    return BuildResult(
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
  EquationRowNode updateChildren(final List<GreenNode> newChildren) => copyWith(children: newChildren);

  @override
  AtomType get leftType => overrideType ?? AtomType.ord;

  @override
  AtomType get rightType => overrideType ?? AtomType.ord;

  /// Utility method.
  EquationRowNode copyWith({
    final AtomType? overrideType,
    final List<GreenNode>? children,
  }) =>
      EquationRowNode(
        overrideType: overrideType ?? this.overrideType,
        children: children ?? this.children,
      );
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

/// Type of atoms. See TeXBook Chap.17
///
/// These following types will be determined by their repective [GreenNode] type
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

/// Only for provisional use during parsing. Do not use.
class TemporaryNode with LeafNode<TemporaryNode>, GreenNodeMixin<TemporaryNode, GreenNode> {
  @override
  Mode get mode => Mode.math;

  @override
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) =>
      throw UnsupportedError('Temporary node $runtimeType encountered.');

  @override
  TemporaryNode self() => this;

  @override
  AtomType get leftType => throw UnsupportedError('Temporary node $runtimeType encountered.');

  @override
  AtomType get rightType => throw UnsupportedError('Temporary node $runtimeType encountered.');

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) =>
      throw UnsupportedError('Temporary node $runtimeType encountered.');

  @override
  int get editingWidth => throw UnsupportedError('Temporary node $runtimeType encountered.');
}

class BuildResult {
  final Widget widget;
  final MathOptions options;
  final double italic;
  final double skew;
  final List<BuildResult>? results;

  const BuildResult({
    required final this.widget,
    required final this.options,
    final this.italic = 0.0,
    final this.skew = 0.0,
    final this.results,
  });
}

void _traverseNonSpaceNodes(
  final List<_NodeSpacingConf> childTypeList,
  final void Function(_NodeSpacingConf? prev, _NodeSpacingConf? curr) callback,
) {
  _NodeSpacingConf? prev;
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

class _NodeSpacingConf {
  AtomType leftType;
  AtomType rightType;
  MathOptions options;
  double spacingAfter;

  _NodeSpacingConf(
    this.leftType,
    this.rightType,
    this.options,
    this.spacingAfter,
  );
}

/// Accent node.
///
/// Examples: `\hat`
class AccentNode with SlotableNode<AccentNode, EquationRowNode>, ParentableNode<AccentNode, EquationRowNode>, GreenNodeMixin<AccentNode, EquationRowNode> {
  /// Base where the accent is applied upon.
  final EquationRowNode base;

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

  AccentNode({
    required final this.base,
    required final this.label,
    required final this.isStretchy,
    required final this.isShifty,
  });

  @override
  BuildResult buildWidget(final MathOptions options, final List<BuildResult?> childBuildResults) {
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
    return BuildResult(
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
  List<MathOptions> computeChildOptions(final MathOptions options) => [options.havingCrampedStyle()];

  @override
  List<EquationRowNode> computeChildren() => [base];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  AccentNode updateChildren(final List<EquationRowNode> newChildren) => copyWith(base: newChildren[0]);

  AccentNode copyWith({
    final EquationRowNode? base,
    final String? label,
    final bool? isStretchy,
    final bool? isShifty,
  }) =>
      AccentNode(
        base: base ?? this.base,
        label: label ?? this.label,
        isStretchy: isStretchy ?? this.isStretchy,
        isShifty: isShifty ?? this.isShifty,
      );
}

/// AccentUnder Nodes.
///
/// Examples: `\utilde`
class AccentUnderNode with SlotableNode<AccentUnderNode, EquationRowNode>, ParentableNode<AccentUnderNode, EquationRowNode>, GreenNodeMixin<AccentUnderNode, EquationRowNode> {
  /// Base where the accentUnder is applied upon.
  final EquationRowNode base;

  /// Unicode symbol of the accent character.
  final String label;

  AccentUnderNode({
    required final this.base,
    required final this.label,
  });

  @override
  BuildResult buildWidget(final MathOptions options, final List<BuildResult?> childBuildResults) {
    final baseResult = childBuildResults[0]!;
    return BuildResult(
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
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      [options.havingCrampedStyle()];

  @override
  List<EquationRowNode> computeChildren() => [base];

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
  AccentUnderNode updateChildren(
    final List<EquationRowNode> newChildren,
  ) =>
      copyWith(base: newChildren[0]);

  AccentUnderNode copyWith({
    final EquationRowNode? base,
    final String? label,
  }) =>
      AccentUnderNode(
        base: base ?? this.base,
        label: label ?? this.label,
      );
}

/// Node displays vertical bar the size of [MathOptions.fontSize]
/// to replicate a text edit field cursor
class CursorNode with LeafNode<CursorNode>, GreenNodeMixin<CursorNode, GreenNode> {
  @override
  CursorNode self() => this;

  @override
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) {
    final baselinePart = 1 - options.fontMetrics.axisHeight / 2;
    final height = options.fontSize * baselinePart * options.sizeMultiplier;
    final baselineDistance = height * baselinePart;
    final cursor = Container(height: height, width: 1.5, color: options.color);
    return BuildResult(
        options: options,
        widget: _BaselineDistance(
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
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;
}

/// This render object overrides the return value of
// ignore: comment_references
/// [RenderProxyBox.computeDistanceToActualBaseline]
///
/// Used to align [CursorNode] properly in a [RenderLine] in respect to symbols
class _BaselineDistance extends SingleChildRenderObjectWidget {
  const _BaselineDistance({
    required final this.baselineDistance,
    final Key? key,
    final Widget? child,
  }) : super(key: key, child: child);

  final double baselineDistance;

  @override
  _BaselineDistanceBox createRenderObject(final BuildContext context) =>
      _BaselineDistanceBox(baselineDistance);
}

class _BaselineDistanceBox extends RenderProxyBox {
  final double baselineDistance;

  _BaselineDistanceBox(
    final this.baselineDistance,
  );

  @override
  double? computeDistanceToActualBaseline(
    final TextBaseline baseline,
  ) => baselineDistance;
}

/// Enclosure node
///
/// Examples: `\colorbox`, `\fbox`, `\cancel`.
class EnclosureNode with SlotableNode<EnclosureNode, EquationRowNode>, ParentableNode<EnclosureNode, EquationRowNode>, GreenNodeMixin<EnclosureNode, EquationRowNode> {
  /// Base where the enclosure is applied upon
  final EquationRowNode base;

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

  EnclosureNode({
    required final this.base,
    required final this.hasBorder,
    final this.bordercolor,
    final this.backgroundcolor,
    final this.notation = const [],
    final this.horizontalPadding = Measurement.zero,
    final this.verticalPadding = Measurement.zero,
  });

  @override
  BuildResult buildWidget(final MathOptions options, final List<BuildResult?> childBuildResults) {
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
    return BuildResult(
      options: options,
      widget: widget,
    );
  }

  @override
  List<MathOptions> computeChildOptions(final MathOptions options) => [options];

  @override
  List<EquationRowNode> computeChildren() => [base];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  EnclosureNode updateChildren(final List<EquationRowNode> newChildren) => EnclosureNode(
        base: newChildren[0],
        hasBorder: hasBorder,
        bordercolor: bordercolor,
        backgroundcolor: backgroundcolor,
        notation: notation,
        horizontalPadding: horizontalPadding,
        verticalPadding: verticalPadding,
      );
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
  bool shouldRepaint(final CustomPainter oldDelegate) => this != oldDelegate;
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

/// Equantion array node. Brings support for equationa alignment.
class EquationArrayNode with SlotableNode<EquationArrayNode, EquationRowNode?>, ParentableNode<EquationArrayNode, EquationRowNode?>, GreenNodeMixin<EquationArrayNode, EquationRowNode?> {
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
  final List<EquationRowNode> body;

  /// Style for horizontal separator lines.
  ///
  /// This includes outermost lines. Different from MathML!
  final List<MatrixSeparatorStyle> hlines;

  /// Spacings between rows;
  final List<Measurement> rowSpacings;

  EquationArrayNode({
    required final this.body,
    final this.addJot = false,
    final this.arrayStretch = 1.0,
    final List<MatrixSeparatorStyle>? hlines,
    final List<Measurement>? rowSpacings,
  })  : hlines = (hlines ?? []).extendToByFill(body.length + 1, MatrixSeparatorStyle.none),
        rowSpacings = (rowSpacings ?? []).extendToByFill(body.length, Measurement.zero);

  @override
  BuildResult buildWidget(final MathOptions options, final List<BuildResult?> childBuildResults) =>
      BuildResult(
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
  List<MathOptions> computeChildOptions(final MathOptions options) =>
      List.filled(body.length, options, growable: false);

  @override
  List<EquationRowNode> computeChildren() => body;

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  EquationArrayNode updateChildren(final List<EquationRowNode> newChildren) => copyWith(body: newChildren);

  EquationArrayNode copyWith({
    final double? arrayStretch,
    final bool? addJot,
    final List<EquationRowNode>? body,
    final List<MatrixSeparatorStyle>? hlines,
    final List<Measurement>? rowSpacings,
  }) =>
      EquationArrayNode(
        arrayStretch: arrayStretch ?? this.arrayStretch,
        addJot: addJot ?? this.addJot,
        body: body ?? this.body,
        hlines: hlines ?? this.hlines,
        rowSpacings: rowSpacings ?? this.rowSpacings,
      );
}

/// Frac node.
class FracNode with SlotableNode<FracNode, EquationRowNode>, ParentableNode<FracNode, EquationRowNode>, GreenNodeMixin<FracNode, EquationRowNode> {
  /// Numerator.
  final EquationRowNode numerator;

  /// Denumerator.
  final EquationRowNode denominator;

  /// Bar size.
  ///
  /// If null, will use default bar size.
  final Measurement? barSize;

  /// Whether it is a continued frac `\cfrac`.
  final bool continued; // TODO continued

  FracNode({
    // this.options,
    required final this.numerator,
    required final this.denominator,
    final this.barSize,
    final this.continued = false,
  });

  @override
  List<EquationRowNode> computeChildren() => [numerator, denominator];

  @override
  BuildResult buildWidget(final MathOptions options, final List<BuildResult?> childBuildResults) =>
      BuildResult(
        options: options,
        widget: CustomLayout(
          delegate: FracLayoutDelegate(
            barSize: barSize,
            options: options,
          ),
          children: <Widget>[
            CustomLayoutId(
              id: _FracPos.numer,
              child: childBuildResults[0]!.widget,
            ),
            CustomLayoutId(
              id: _FracPos.denom,
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
  FracNode updateChildren(final List<EquationRowNode> newChildren) => FracNode(
        // options: options ?? this.options,
        numerator: newChildren[0],
        denominator: newChildren[1],
        barSize: barSize,
      );

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;
}

enum _FracPos {
  numer,
  denom,
}

class FracLayoutDelegate extends IntrinsicLayoutDelegate<_FracPos> {
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
    final Map<_FracPos, RenderBox> childrenTable,
  ) =>
      height;

  @override
  AxisConfiguration<_FracPos> performHorizontalIntrinsicLayout({
    required final Map<_FracPos, double> childrenWidths,
    final bool isComputingIntrinsics = false,
  }) {
    final numerSize = childrenWidths[_FracPos.numer]!;
    final denomSize = childrenWidths[_FracPos.denom]!;
    final barLength = math.max(numerSize, denomSize);
    // KaTeX/src/katex.less
    final nullDelimiterWidth = cssEmMeasurement(0.12).toLpUnder(options);
    final width = barLength + 2 * nullDelimiterWidth;
    if (!isComputingIntrinsics) {
      this.barLength = barLength;
      this.width = width;
    }

    return AxisConfiguration(
      size: width,
      offsetTable: {
        _FracPos.numer: 0.5 * (width - numerSize),
        _FracPos.denom: 0.5 * (width - denomSize),
      },
    );
  }

  @override
  AxisConfiguration<_FracPos> performVerticalIntrinsicLayout({
    required final Map<_FracPos, double> childrenHeights,
    required final Map<_FracPos, double> childrenBaselines,
    final bool isComputingIntrinsics = false,
  }) {
    final numerSize = childrenHeights[_FracPos.numer]!;
    final denomSize = childrenHeights[_FracPos.denom]!;
    final numerHeight = childrenBaselines[_FracPos.numer]!;
    final denomHeight = childrenBaselines[_FracPos.denom]!;
    final metrics = options.fontMetrics;
    final xi8 = cssEmMeasurement(metrics.defaultRuleThickness).toLpUnder(options);
    final theta = barSize?.toLpUnder(options) ?? xi8;
    // Rule 15b
    double u = cssEmMeasurement(
      mathStyleGreater(options.style, MathStyle.text)
          ? metrics.num1
          : (theta != 0 ? metrics.num2 : metrics.num3),
    ).toLpUnder(options);
    double v =
        cssEmMeasurement(mathStyleGreater(options.style, MathStyle.text) ? metrics.denom1 : metrics.denom2)
            .toLpUnder(options);
    final a = cssEmMeasurement(metrics.axisHeight).toLpUnder(options);
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
        _FracPos.numer: height - u - hx,
        _FracPos.denom: height + v - hz,
      },
    );
  }

  @override
  void additionalPaint(final PaintingContext context, final Offset offset) {
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

/// Function node
///
/// Examples: `\sin`, `\lim`, `\operatorname`
class FunctionNode with SlotableNode<FunctionNode, EquationRowNode>, ParentableNode<FunctionNode, EquationRowNode>, GreenNodeMixin<FunctionNode, EquationRowNode> {
  /// Name of the function.
  final EquationRowNode functionName;

  /// Argument of the function.
  final EquationRowNode argument;

  FunctionNode({
    required final this.functionName,
    required final this.argument,
  });

  @override
  BuildResult buildWidget(final MathOptions options, final List<BuildResult?> childBuildResults) =>
      BuildResult(
        options: options,
        widget: Line(children: [
          LineElement(
            trailingMargin: getSpacingSize(AtomType.op, argument.leftType, options.style).toLpUnder(options),
            child: childBuildResults[0]!.widget,
          ),
          LineElement(
            trailingMargin: 0.0,
            child: childBuildResults[1]!.widget,
          ),
        ]),
      );

  @override
  List<MathOptions> computeChildOptions(final MathOptions options) =>
      List.filled(2, options, growable: false);

  @override
  List<EquationRowNode> computeChildren() => [functionName, argument];

  @override
  AtomType get leftType => AtomType.op;

  @override
  AtomType get rightType => argument.rightType;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  FunctionNode updateChildren(final List<EquationRowNode> newChildren) =>
      copyWith(functionName: newChildren[0], argument: newChildren[2]);

  FunctionNode copyWith({
    final EquationRowNode? functionName,
    final EquationRowNode? argument,
  }) =>
      FunctionNode(
        functionName: functionName ?? this.functionName,
        argument: argument ?? this.argument,
      );
}

/// Left right node.
class LeftRightNode with SlotableNode<LeftRightNode, EquationRowNode>, ParentableNode<LeftRightNode, EquationRowNode>, GreenNodeMixin<LeftRightNode, EquationRowNode> {
  /// Unicode symbol for the left delimiter character.
  final String? leftDelim;

  /// Unicode symbol for the right delimiter character.
  final String? rightDelim;

  /// List of inside bodys.
  ///
  /// Its length should be 1 longer than [middle].
  final List<EquationRowNode> body;

  /// List of middle delimiter characters.
  final List<String?> middle;

  LeftRightNode({
    required final this.leftDelim,
    required final this.rightDelim,
    required final this.body,
    final this.middle = const [],
  })  : assert(body.isNotEmpty, ""),
        assert(middle.length == body.length - 1, "");

  @override
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) {
    final numElements = 2 + body.length + middle.length;
    final a = cssEmMeasurement(options.fontMetrics.axisHeight).toLpUnder(options);
    final childWidgets = List.generate(numElements, (final index) {
      if (index.isEven) {
        // Delimiter
        return LineElement(
          customCrossSize: (final height, final depth) {
            final delta = math.max(height - a, depth + a);
            final delimeterFullHeight =
                math.max(delta / 500 * delimiterFactor, 2 * delta - delimiterShorfall.toLpUnder(options));
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
    }, growable: false);
    return BuildResult(
      options: options,
      widget: Line(
        children: childWidgets,
      ),
    );
  }

  @override
  List<MathOptions> computeChildOptions(final MathOptions options) =>
      List.filled(body.length, options, growable: false);

  @override
  List<EquationRowNode> computeChildren() => body;

  @override
  AtomType get leftType => AtomType.open;

  @override
  AtomType get rightType => AtomType.close;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  LeftRightNode updateChildren(final List<EquationRowNode> newChildren) => LeftRightNode(
        leftDelim: leftDelim,
        rightDelim: rightDelim,
        body: newChildren,
        middle: middle,
      );
}

// TexBook Appendix B
const delimiterFactor = 901;

const delimiterShorfall = Measurement(value: 5.0, unit: Unit.pt);

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
    final axisHeight = cssEmMeasurement(options.fontMetrics.xHeight).toLpUnder(options);
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
    final axisHeight = cssEmMeasurement(options.fontMetrics.axisHeight).toLpUnder(options);
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
  final topHeight = cssEmMeasurement(topMetrics.height + topMetrics.depth).toLpUnder(options);
  final repeatHeight = cssEmMeasurement(repeatMetrics.height + repeatMetrics.depth).toLpUnder(options);
  final bottomHeight = cssEmMeasurement(bottomMetrics.height + bottomMetrics.depth).toLpUnder(options);
  double middleHeight = 0.0;
  int middleFactor = 1;
  CharacterMetrics? middleMetrics;
  if (conf.middle != null) {
    middleMetrics = lookupChar(conf.middle!, conf.font, Mode.math)!;
    middleHeight = cssEmMeasurement(middleMetrics.height + middleMetrics.depth).toLpUnder(options);
    middleFactor = 2;
  }
  final minHeight = topHeight + bottomHeight + middleHeight;
  final repeatCount = math.max(0, (minDelimiterHeight - minHeight) / (repeatHeight * middleFactor)).ceil();
  // final realHeight = minHeight + repeatCount * middleFactor * repeatHeight;
  final axisHeight = cssEmMeasurement(options.fontMetrics.axisHeight).toLpUnder(options);
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

/// Matrix node
class MatrixNode with SlotableNode<MatrixNode, EquationRowNode?>, ParentableNode<MatrixNode, EquationRowNode?>, GreenNodeMixin<MatrixNode, EquationRowNode?> {
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
  final List<List<EquationRowNode?>> body;

  /// Row number.
  final int rows;

  /// Column number.
  final int cols;

  MatrixNode({
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
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) {
    assert(childBuildResults.length == rows * cols, "");
    // Flutter's Table does not provide fine-grained control of borders
    return BuildResult(
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
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      List.filled(rows * cols, options, growable: false);

  @override
  List<EquationRowNode?> computeChildren() => body
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
  MatrixNode updateChildren(
    final List<EquationRowNode> newChildren,
  ) {
    assert(newChildren.length >= rows * cols, "");
    final body = List<List<EquationRowNode>>.generate(
      rows,
      (final i) => newChildren.sublist(i * cols + (i + 1) * cols),
      growable: false,
    );
    return copyWith(body: body);
  }

  MatrixNode copyWith({
    final double? arrayStretch,
    final bool? hskipBeforeAndAfter,
    final bool? isSmall,
    final List<MatrixColumnAlign>? columnAligns,
    final List<MatrixSeparatorStyle>? columnLines,
    final List<Measurement>? rowSpacing,
    final List<MatrixSeparatorStyle>? rowLines,
    final List<List<EquationRowNode?>>? body,
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
        colWidths[i] = math.max(
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
        rowHeights[i] = math.max(
          rowHeights[i],
          childHeights[i * cols + j],
        );
        rowDepth[i] = math.max(
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
                offset.dx + math.min(dx + dashSize / 2, width),
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
                offset.dy + math.min(dy + dashSize / 2, totalHeight),
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

/// Node for postscripts and prescripts
///
/// Examples:
///
/// - Word:   _     ^
/// - Latex:  _     ^
/// - MathML: msub  msup  mmultiscripts
class MultiscriptsNode with SlotableNode<MultiscriptsNode, EquationRowNode?>, ParentableNode<MultiscriptsNode, EquationRowNode?>, GreenNodeMixin<MultiscriptsNode, EquationRowNode?> {
  /// Whether to align the subscript to the superscript.
  ///
  /// Mimics MathML's mmultiscripts.
  final bool alignPostscripts;

  /// Base where scripts are applied upon.
  final EquationRowNode base;

  /// Subscript.
  final EquationRowNode? sub;

  /// Superscript.
  final EquationRowNode? sup;

  /// Presubscript.
  final EquationRowNode? presub;

  /// Presuperscript.
  final EquationRowNode? presup;

  MultiscriptsNode({
    required final this.base,
    final this.alignPostscripts = false,
    final this.sub,
    final this.sup,
    final this.presub,
    final this.presup,
  });

  @override
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) =>
      BuildResult(
        options: options,
        widget: Multiscripts(
          alignPostscripts: alignPostscripts,
          isBaseCharacterBox: base.flattenedChildList.length == 1 && base.flattenedChildList[0] is SymbolNode,
          baseResult: childBuildResults[0]!,
          subResult: childBuildResults[1],
          supResult: childBuildResults[2],
          presubResult: childBuildResults[3],
          presupResult: childBuildResults[4],
        ),
      );

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) {
    final subOptions = options.havingStyle(mathStyleSub(options.style));
    final supOptions = options.havingStyle(mathStyleSup(options.style));
    return [options, subOptions, supOptions, subOptions, supOptions];
  }

  @override
  List<EquationRowNode?> computeChildren() => [base, sub, sup, presub, presup];

  @override
  AtomType get leftType => presub == null && presup == null ? base.leftType : AtomType.ord;

  @override
  AtomType get rightType => sub == null && sup == null ? base.rightType : AtomType.ord;

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  MultiscriptsNode updateChildren(
    final List<EquationRowNode?> newChildren,
  ) =>
      MultiscriptsNode(
        alignPostscripts: alignPostscripts,
        base: newChildren[0]!,
        sub: newChildren[1],
        sup: newChildren[2],
        presub: newChildren[3],
        presup: newChildren[4],
      );
}

/// N-ary operator node.
///
/// Examples: `\sum`, `\int`
class NaryOperatorNode with SlotableNode<NaryOperatorNode, EquationRowNode?>, ParentableNode<NaryOperatorNode, EquationRowNode?>, GreenNodeMixin<NaryOperatorNode, EquationRowNode?> {
  /// Unicode symbol for the operator character.
  final String operator;

  /// Lower limit.
  final EquationRowNode? lowerLimit;

  /// Upper limit.
  final EquationRowNode? upperLimit;

  /// Argument for the N-ary operator.
  final EquationRowNode naryand;

  /// Whether the limits are displayed as under/over or as scripts.
  final bool? limits;

  /// Special flag for `\smallint`.
  final bool allowLargeOp; // for \smallint

  NaryOperatorNode({
    required final this.operator,
    required final this.lowerLimit,
    required final this.upperLimit,
    required final this.naryand,
    final this.limits,
    final this.allowLargeOp = true,
  });

  @override
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) {
    final large = allowLargeOp && (mathStyleSize(options.style) == mathStyleSize(MathStyle.display));
    final font = large ? const FontOptions(fontFamily: 'Size2') : const FontOptions(fontFamily: 'Size1');
    Widget operatorWidget;
    CharacterMetrics symbolMetrics;
    if (!_stashedOvalNaryOperator.containsKey(operator)) {
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
      final baseSymbol = _stashedOvalNaryOperator[operator]!;
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
          (_naryDefaultLimit.contains(operator) &&
              mathStyleSize(options.style) == mathStyleSize(MathStyle.display));
      final italic = cssEmMeasurement(symbolMetrics.italic).toLpUnder(options);
      if (!shouldLimits) {
        operatorWidget = Multiscripts(
          isBaseCharacterBox: false,
          baseResult: BuildResult(widget: operatorWidget, options: options, italic: italic),
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
    return BuildResult(
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
  List<EquationRowNode?> computeChildren() => [
        lowerLimit,
        upperLimit,
        naryand,
      ];

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
  NaryOperatorNode updateChildren(
    final List<EquationRowNode?> newChildren,
  ) =>
      NaryOperatorNode(
        operator: operator,
        lowerLimit: newChildren[0],
        upperLimit: newChildren[1],
        naryand: newChildren[2]!,
        limits: limits,
        allowLargeOp: allowLargeOp,
      );
}

const _naryDefaultLimit = {
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

const _stashedOvalNaryOperator = {
  '\u222F': '\u222C',
  '\u2230': '\u222D',
};

/// Over node.
///
/// Examples: `\underset`
class OverNode with SlotableNode<OverNode, EquationRowNode?>, ParentableNode<OverNode, EquationRowNode?>, GreenNodeMixin<OverNode, EquationRowNode?> {
  /// Base where the over node is applied upon.
  final EquationRowNode base;

  /// Argument above the base.
  final EquationRowNode above;

  /// Special flag for `\stackrel`
  final bool stackRel;

  OverNode({
    required final this.base,
    required final this.above,
    final this.stackRel = false,
  });

  // KaTeX's corresponding code is in /src/functions/utils/assembleSubSup.js
  @override
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) {
    final spacing = cssEmMeasurement(options.fontMetrics.bigOpSpacing5).toLpUnder(options);
    return BuildResult(
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
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      [
        options,
        options.havingStyle(mathStyleSup(options.style)),
      ];

  @override
  List<EquationRowNode> computeChildren() => [base, above];

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
  OverNode updateChildren(
    final List<EquationRowNode> newChildren,
  ) =>
      copyWith(base: newChildren[0], above: newChildren[1]);

  OverNode copyWith({
    final EquationRowNode? base,
    final EquationRowNode? above,
    final bool? stackRel,
  }) =>
      OverNode(
        base: base ?? this.base,
        above: above ?? this.above,
        stackRel: stackRel ?? this.stackRel,
      );
}

/// Phantom node.
///
/// Example: `\phantom` `\hphantom`.
class PhantomNode with LeafNode<PhantomNode>, GreenNodeMixin<PhantomNode, GreenNode> {
  @override
  PhantomNode self() => this;

  @override
  Mode get mode => Mode.math;

  /// The phantomed child.
  // TODO: suppress editbox in edit mode
  // If we use arbitrary GreenNode here, then we will face the danger of
  // transparent node
  final EquationRowNode phantomChild;

  /// Whether to eliminate width.
  final bool zeroWidth;

  /// Whether to eliminate height.
  final bool zeroHeight;

  /// Whether to eliminate depth.
  final bool zeroDepth;

  PhantomNode({
    required final this.phantomChild,
    final this.zeroHeight = false,
    final this.zeroWidth = false,
    final this.zeroDepth = false,
  });

  @override
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) {
    final phantomRedNode = SyntaxNode(parent: null, value: phantomChild, pos: 0);
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
    return BuildResult(
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
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) =>
      phantomChild.shouldRebuildWidget(oldOptions, newOptions);
}

/// Raise box node which vertically displace its child.
///
/// Example: `\raisebox`
class RaiseBoxNode with SlotableNode<RaiseBoxNode, EquationRowNode>, ParentableNode<RaiseBoxNode, EquationRowNode>, GreenNodeMixin<RaiseBoxNode, EquationRowNode> {
  /// Child to raise.
  final EquationRowNode body;

  /// Vertical displacement.
  final Measurement dy;

  RaiseBoxNode({
    required final this.body,
    required final this.dy,
  });

  @override
  BuildResult buildWidget(final MathOptions options, final List<BuildResult?> childBuildResults) =>
      BuildResult(
        options: options,
        widget: ShiftBaseline(
          offset: dy.toLpUnder(options),
          child: childBuildResults[0]!.widget,
        ),
      );

  @override
  List<MathOptions> computeChildOptions(final MathOptions options) => [options];

  @override
  List<EquationRowNode> computeChildren() => [body];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  RaiseBoxNode updateChildren(final List<EquationRowNode> newChildren) => copyWith(body: newChildren[0]);

  RaiseBoxNode copyWith({
    final EquationRowNode? body,
    final Measurement? dy,
  }) =>
      RaiseBoxNode(
        body: body ?? this.body,
        dy: dy ?? this.dy,
      );
}

/// Space node. Also used for equation alignment.
class SpaceNode with LeafNode<SpaceNode>, GreenNodeMixin<SpaceNode, GreenNode> {
  @override
  SpaceNode self() => this;

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

  SpaceNode({
    required final this.height,
    required final this.width,
    required final this.mode,
    final this.shift = Measurement.zero,
    final this.depth = Measurement.zero,
    final this.breakPenalty,
    final this.fill = false,
    final this.alignerOrSpacer = false,
  });

  SpaceNode.alignerOrSpacer()
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
  BuildResult buildWidget(final MathOptions options, final List<BuildResult?> childBuildResults) {
    if (alignerOrSpacer == true) {
      return BuildResult(
        options: options,
        widget: Container(height: 0.0),
      );
    }

    final height = this.height.toLpUnder(options);
    final depth = this.depth.toLpUnder(options);
    final width = this.width.toLpUnder(options);
    final shift = this.shift.toLpUnder(options);
    final topMost = math.max(height, -depth) + shift;
    final bottomMost = math.min(height, -depth) + shift;
    return BuildResult(
      options: options,
      widget: ResetBaseline(
        height: topMost,
        child: Container(
          color: fill ? options.color : null,
          height: topMost - bottomMost,
          width: math.max(0.0, width),
        ),
      ),
    );
  }

  @override
  AtomType get leftType => AtomType.spacing;

  @override
  AtomType get rightType => AtomType.spacing;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) =>
      oldOptions.sizeMultiplier != newOptions.sizeMultiplier;
}

/// Square root node.
///
/// Examples:
/// - Word:   `\sqrt`   `\sqrt(index & base)`
/// - Latex:  `\sqrt`   `\sqrt[index]{base}`
/// - MathML: `msqrt`   `mroot`
class SqrtNode with SlotableNode<SqrtNode, EquationRowNode?>, ParentableNode<SqrtNode, EquationRowNode?>, GreenNodeMixin<SqrtNode, EquationRowNode?> {
  /// The index.
  final EquationRowNode? index;

  /// The sqrt-and.
  final EquationRowNode base;

  SqrtNode({
    required final this.index,
    required final this.base,
  });

  @override
  BuildResult buildWidget(final MathOptions options, final List<BuildResult?> childBuildResults) {
    final baseResult = childBuildResults[1]!;
    final indexResult = childBuildResults[0];
    return BuildResult(
      options: options,
      widget: CustomLayout<_SqrtPos>(
        delegate: SqrtLayoutDelegate(
          options: options,
          baseOptions: baseResult.options,
          // indexOptions: indexResult?.options,
        ),
        children: <Widget>[
          CustomLayoutId(
            id: _SqrtPos.base,
            child: MinDimension(
              minHeight: cssEmMeasurement(options.fontMetrics.xHeight).toLpUnder(options),
              topPadding: 0,
              child: baseResult.widget,
            ),
          ),
          CustomLayoutId(
            id: _SqrtPos.surd,
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
              id: _SqrtPos.ind,
              child: indexResult!.widget,
            ),
        ],
      ),
    );
  }

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
  List<EquationRowNode?> computeChildren() => [index, base];

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
  SqrtNode updateChildren(
    final List<EquationRowNode?> newChildren,
  ) =>
      SqrtNode(
        index: newChildren[0],
        base: newChildren[1]!,
      );

  SqrtNode copyWith({
    final EquationRowNode? index,
    final EquationRowNode? base,
  }) =>
      SqrtNode(
        index: index ?? this.index,
        base: base ?? this.base,
      );
}

enum _SqrtPos {
  base,
  ind, // Name collision here
  surd,
}

// Square roots are handled in the TeXbook pg. 443, Rule 11.
class SqrtLayoutDelegate extends CustomLayoutDelegate<_SqrtPos> {
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
    final Map<_SqrtPos, RenderBox> childrenTable,
  ) =>
      heightAboveBaseline;

  @override
  double getIntrinsicSize({
    required final Axis sizingDirection,
    required final bool max,
    required final double extent,
    required final double Function(RenderBox child, double extent) childSize,
    required final Map<_SqrtPos, RenderBox> childrenTable,
  }) =>
      0;

  @override
  Size computeLayout(
    final BoxConstraints constraints,
    final Map<_SqrtPos, RenderBox> childrenTable, {
    final bool dry = true,
  }) {
    final base = childrenTable[_SqrtPos.base]!;
    final index = childrenTable[_SqrtPos.ind];
    final surd = childrenTable[_SqrtPos.surd]!;
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
    final theta = cssEmMeasurement(baseOptions.fontMetrics.defaultRuleThickness).toLpUnder(baseOptions);
    final phi = () {
      if (mathStyleGreater(baseOptions.style, MathStyle.text)) {
        return cssEmMeasurement(baseOptions.fontMetrics.xHeight).toLpUnder(baseOptions);
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
    final indexRightPadding = muMeasurement(-10.0).toLpUnder(options);
    // KaTeX chose a way to large value (5mu). We will use a smaller one.
    final indexLeftPadding = ptMeasurement(0.5).toLpUnder(options);
    // Horizontal layout
    final sqrtHorizontalPos = math.max(0.0, indexLeftPadding + indexSize.width + indexRightPadding);
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
    final sqrtVerticalPos = math.max(0.0, indexHeight + indexShift - baseHeight - psi - ruleWidth);
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
      return cssEmMeasurement(0.833).toLpUnder(delimOptions);
    } else {
      // We will directly apply corresponding font
      final advanceWidth = cssEmMeasurement(1.0).toLpUnder(delimOptions);
      return advanceWidth;
    }
  } else {
    final advanceWidth = cssEmMeasurement(1.056).toLpUnder(options);
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
    final viewPortHeight = cssEmMeasurement(fontHeight + extraViniculum + emPad).toLpUnder(delimOptions);
    if (delimConf.font.fontName == 'Main-Regular') {
      // We will be vertically stretching the sqrtMain path (by viewPort vs
      // viewBox) to mimic the height of \u221A under Main-Regular font and
      // corresponding Mathstyle.
      final advanceWidth = cssEmMeasurement(0.833).toLpUnder(delimOptions);
      final viewPortWidth = advanceWidth + baseWidth;
      const viewBoxHeight = 1000 + 1000 * extraViniculum + vbPad;
      final viewBoxWidth = lpMeasurement(viewPortWidth).toCssEmUnder(delimOptions) * 1000;
      final svgPath = sqrtPath('sqrtMain', extraViniculum, viewBoxHeight);
      return ResetBaseline(
        height:
            cssEmMeasurement(options.fontMetrics.sqrtRuleThickness + extraViniculum).toLpUnder(delimOptions),
        child: MinDimension(
          topPadding: cssEmMeasurement(-emPad).toLpUnder(delimOptions),
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
      final advanceWidth = cssEmMeasurement(1.0).toLpUnder(delimOptions);
      final viewPortWidth = math.max(
        advanceWidth + baseWidth,
        cssEmMeasurement(1.02).toCssEmUnder(delimOptions),
      );
      final viewBoxHeight = (1000 + vbPad) * fontHeight;
      final viewBoxWidth = lpMeasurement(viewPortWidth).toCssEmUnder(delimOptions) * 1000;
      final svgPath =
          sqrtPath('sqrt${delimConf.font.fontName.substring(0, 5)}', extraViniculum, viewBoxHeight);
      return ResetBaseline(
        height:
            cssEmMeasurement(options.fontMetrics.sqrtRuleThickness + extraViniculum).toLpUnder(delimOptions),
        child: MinDimension(
          topPadding: cssEmMeasurement(-emPad).toLpUnder(delimOptions),
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
    final viewPortHeight = minDelimiterHeight + cssEmMeasurement(extraViniculum + emPad).toLpUnder(options);
    final viewBoxHeight =
        1000 * lpMeasurement(minDelimiterHeight).toCssEmUnder(options) + extraViniculum + vbPad;
    final advanceWidth = cssEmMeasurement(1.056).toLpUnder(options);
    final viewPortWidth = advanceWidth + baseWidth;
    final viewBoxWidth = lpMeasurement(viewPortWidth).toCssEmUnder(options) * 1000;
    final svgPath = sqrtPath('sqrtTall', extraViniculum, viewBoxHeight);
    return ResetBaseline(
      height: cssEmMeasurement(options.fontMetrics.sqrtRuleThickness + extraViniculum).toLpUnder(options),
      child: MinDimension(
        topPadding: cssEmMeasurement(-emPad).toLpUnder(options),
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

/// Stretchy operator node.
///
/// Example: `\xleftarrow`
class StretchyOpNode with SlotableNode<StretchyOpNode, EquationRowNode?>, ParentableNode<StretchyOpNode, EquationRowNode?>, GreenNodeMixin<StretchyOpNode, EquationRowNode?> {
  /// Unicode symbol for the operator.
  final String symbol;

  /// Arguments above the operator.
  final EquationRowNode? above;

  /// Arguments below the operator.
  final EquationRowNode? below;

  StretchyOpNode({
    required final this.above,
    required final this.below,
    required final this.symbol,
  }) : assert(above != null || below != null, "");

  @override
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) {
    final verticalPadding = muMeasurement(2.0).toLpUnder(options);
    return BuildResult(
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
  List<EquationRowNode?> computeChildren() => [above, below];

  @override
  AtomType get leftType => AtomType.rel;

  @override
  AtomType get rightType => AtomType.rel;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) =>
      oldOptions.sizeMultiplier != newOptions.sizeMultiplier;

  @override
  StretchyOpNode updateChildren(final List<EquationRowNode> newChildren) => StretchyOpNode(
        above: newChildren[0],
        below: newChildren[1],
        symbol: symbol,
      );
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

/// Node to denote all kinds of style changes.
class StyleNode with TransparentNode<StyleNode>,
    ParentableNode<StyleNode, GreenNode>,
    GreenNodeMixin<StyleNode, GreenNode>,
    ClipChildrenMixin<StyleNode> {
  @override
  final List<GreenNode> children;

  /// The difference of [MathOptions].
  final OptionsDiff optionsDiff;

  StyleNode({
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
  StyleNode updateChildren(
    final List<GreenNode> newChildren,
  ) =>
      copyWith(children: newChildren);

  StyleNode copyWith({
    final List<GreenNode>? children,
    final OptionsDiff? optionsDiff,
  }) =>
      StyleNode(
        children: children ?? this.children,
        optionsDiff: optionsDiff ?? this.optionsDiff,
      );
}

/// Node for an unbreakable symbol.
class SymbolNode with LeafNode<SymbolNode>, GreenNodeMixin<SymbolNode, GreenNode> {
  @override
  SymbolNode self() => this;

  /// Unicode symbol.
  final String symbol;

  /// Whether it is a varaint form.
  ///
  /// Refer to MathJaX's variantForm
  final bool variantForm;

  /// Effective atom type for this symbol;
  late final AtomType atomType =
      overrideAtomType ?? getDefaultAtomTypeForSymbol(symbol, variantForm: variantForm, mode: mode);

  /// Overriding atom type;
  final AtomType? overrideAtomType;

  /// Overriding atom font;
  final FontOptions? overrideFont;

  @override
  final Mode mode;

  // bool get noBreak => symbol == '\u00AF';

  SymbolNode({
    required final this.symbol,
    final this.variantForm = false,
    final this.overrideAtomType,
    final this.overrideFont,
    final this.mode = Mode.math,
  }) : assert(symbol.isNotEmpty, "");

  @override
  BuildResult buildWidget(final MathOptions options, final List<BuildResult?> childBuildResults) {
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
      GreenNode res = this.withSymbol(expanded[0]);
      for (final ch in expanded.skip(1)) {
        final accent = unicodeAccentsSymbols[ch];
        if (accent == null) {
          break;
        } else {
          res = AccentNode(
            base: greenNodeWrapWithEquationRow(res),
            label: accent,
            isStretchy: false,
            isShifty: true,
          );
        }
      }
      return SyntaxNode(parent: null, value: res, pos: 0).buildWidget(options);
    } else {
      // TODO: log a warning here.
      return BuildResult(
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

  SymbolNode withSymbol(final String symbol) {
    if (symbol == this.symbol) return this;
    return SymbolNode(
      symbol: symbol,
      variantForm: variantForm,
      overrideAtomType: overrideAtomType,
      overrideFont: overrideFont,
      mode: mode,
    );
  }
}

EquationRowNode stringToNode(
  final String string, [
  final Mode mode = Mode.text,
]) =>
    EquationRowNode(
      children:
          string.split('').map((final ch) => SymbolNode(symbol: ch, mode: mode)).toList(growable: false),
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

/// Under node.
///
/// Examples: `\underset`
class UnderNode with SlotableNode<UnderNode, EquationRowNode?>, ParentableNode<UnderNode, EquationRowNode?>, GreenNodeMixin<UnderNode, EquationRowNode?> {
  /// Base where the under node is applied upon.
  final EquationRowNode base;

  /// Argumentn below the base.
  final EquationRowNode below;

  UnderNode({
    required final this.base,
    required final this.below,
  });

  // KaTeX's corresponding code is in /src/functions/utils/assembleSubSup.js
  @override
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) {
    final spacing = cssEmMeasurement(options.fontMetrics.bigOpSpacing5).toLpUnder(options);
    return BuildResult(
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
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      [
        options,
        options.havingStyle(mathStyleSub(options.style)),
      ];

  @override
  List<EquationRowNode> computeChildren() => [base, below];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  UnderNode updateChildren(final List<EquationRowNode> newChildren) =>
      copyWith(base: newChildren[0], below: newChildren[1]);

  UnderNode copyWith({
    final EquationRowNode? base,
    final EquationRowNode? below,
  }) =>
      UnderNode(
        base: base ?? this.base,
        below: below ?? this.below,
      );
}
