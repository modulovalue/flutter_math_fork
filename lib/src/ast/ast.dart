import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
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

/// Node of Roslyn's Green Tree. Base class of any math nodes.
///
/// [Description of Roslyn's Red-Green Tree](https://docs.microsoft.com/en-us/archive/blogs/ericlippert/persistence-facades-and-roslyns-red-green-trees).
///
/// [TexGreen] stores any context-free information of a node and is
/// constructed bottom-up. It needs to indicate or store:
/// - Necessary parameters for this math node.
/// - Layout algorithm for this math node, if renderable.
/// - Strutural information of the tree ([children])
/// - Context-free properties for other purposes. ([editingWidth], etc.)
///
/// Due to their context-free property, [TexGreen] can be canonicalized and
/// deduplicated.
abstract class TexGreen {
  /// Children of this node.
  ///
  /// [children] stores structural information of the Red-Green Tree.
  /// Used for green tree updates. The order of children should strictly
  /// adheres to the cursor-visiting order in editing mode, in order to get a
  /// correct cursor range in the editing mode. E.g., for [TexGreenSqrt], when
  /// moving cursor from left to right, the cursor first enters index, then
  /// base, so it should return [index, base].
  ///
  /// Please ensure [children] works in the same order as [updateChildren],
  /// [computeChildOptions], and [buildWidget].
  List<TexGreen?> get children;

  /// Return a copy of this node with new children.
  ///
  /// Subclasses should override this method. This method provides a general
  /// interface to perform structural updates for the green tree (node
  /// replacement, insertion, etc).
  ///
  /// Please ensure [children] works in the same order as [updateChildren],
  /// [computeChildOptions], and [buildWidget].
  TexGreen updateChildren(
    final List<TexGreen?> newChildren,
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

  abstract MathOptions? oldOptions;

  abstract BuildResult? oldBuildResult;

  abstract List<BuildResult?>? oldChildBuildResults;
}

abstract class TexGreenT<SELF extends TexGreen, CHILD extends TexGreen?> implements TexGreen {
  @override
  List<CHILD> get children;

  @override
  SELF updateChildren(
    covariant final List<CHILD> newChildren,
  );
}

/// A [TexGreen] that has children.
abstract class TexGreenTNonleaf<SELF extends TexGreenTNonleaf<SELF, CHILD>, CHILD extends TexGreen?> implements TexGreenT<SELF, CHILD> {}

/// A [TexGreen] that has no children.
abstract class TexGreenTLeaf<SELF extends TexGreenTLeaf<SELF, CHILD>, CHILD extends TexGreen?> implements TexGreenT<SELF, CHILD> {
  /// [Mode] that this node acquires during parse.
  Mode get mode;
}

// endregion

// region mixins

mixin TexGreenMixin<SELF extends TexGreen, CHILD extends TexGreen?> implements TexGreenT<SELF, CHILD> {
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
  MathOptions? oldOptions;

  @override
  BuildResult? oldBuildResult;

  @override
  List<BuildResult?>? oldChildBuildResults;
}

/// [TexGreenSlotableMixin] is those composite node that has editable [TexGreenEquationrow]
/// as children and lay them out into certain slots.
///
/// [TexGreenSlotableMixin] is the most commonly-used node. They share cursor logic and
/// editing logic.
///
/// Depending on node type, some [TexGreenSlotableMixin] can have nulls inside their
/// children list. When null is allowed, it usually means that node will have
/// different layout slot logic depending on non-null children number.
mixin TexGreenSlotableMixin<SELF extends TexGreenSlotableMixin<SELF, T>, T extends TexGreenEquationrow?>
    implements TexGreenT<SELF, T> {
  @override
  late final editingWidth =
      integerSum(
        children.map(
          (final child) => child?.capturedCursor ?? 0,
        ),
      ) +
      1;

  @override
  late final childPositions = () {
    int curPos = 0;
    final result = <int>[];
    for (final child in children) {
      result.add(curPos);
      curPos += child?.capturedCursor ?? 0;
    }
    return result;
  }();
}

/// [TexGreen] that doesn't have any children
mixin TexGreenLeafableMixin<SELF extends TexGreenTLeaf<SELF, TexGreen>> implements TexGreenTLeaf<SELF, TexGreen> {
  @override
  List<TexGreen> get children => const [];

  @override
  SELF updateChildren(
    final List<TexGreen> newChildren,
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

// endregion

// region bases

abstract class TexGreenParentableBase<SELF extends TexGreenParentableBase<SELF>> with
    TexGreenMixin<SELF, TexGreen>
    implements TexGreenTNonleaf<SELF, TexGreen> {}

abstract class TexGreenNullableSlotableParentableBase<SELF extends TexGreenNullableSlotableParentableBase<SELF>> with
    TexGreenSlotableMixin<SELF, TexGreenEquationrow?>,
    TexGreenMixin<SELF, TexGreenEquationrow?>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow?> {}

abstract class TexGreenNonnullableSlotableParentableBase<SELF extends TexGreenNonnullableSlotableParentableBase<SELF>> with
    TexGreenSlotableMixin<SELF, TexGreenEquationrow>,
    TexGreenMixin<SELF, TexGreenEquationrow>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {}


abstract class TexGreenLeafableBase<SELF extends TexGreenLeafableBase<SELF>> with TexGreenLeafableMixin<SELF>, TexGreenMixin<SELF, TexGreen> implements TexGreenTLeaf<SELF, TexGreen> {}

// endregion

// region parentable nullable

/// Matrix node
class TexGreenMatrix extends TexGreenNullableSlotableParentableBase<TexGreenMatrix> {
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
}

/// Node for postscripts and prescripts
///
/// Examples:
///
/// - Word:   _     ^
/// - Latex:  _     ^
/// - MathML: msub  msup  mmultiscripts
class TexGreenMultiscripts extends TexGreenNullableSlotableParentableBase<TexGreenMultiscripts> {
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
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) =>
      BuildResult(
        options: options,
        widget: Multiscripts(
          alignPostscripts: alignPostscripts,
          isBaseCharacterBox: base.flattenedChildList.length == 1 && base.flattenedChildList[0] is TexGreenSymbol,
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
  late final children = [base, sub, sup, presub, presup];

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
}

/// N-ary operator node.
///
/// Examples: `\sum`, `\int`
class TexGreenNaryoperator extends TexGreenNullableSlotableParentableBase<TexGreenNaryoperator> {
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
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
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
}

/// Square root node.
///
/// Examples:
/// - Word:   `\sqrt`   `\sqrt(index & base)`
/// - Latex:  `\sqrt`   `\sqrt[index]{base}`
/// - MathML: `msqrt`   `mroot`
class TexGreenSqrt extends TexGreenNullableSlotableParentableBase<TexGreenSqrt> {
  /// The index.
  final TexGreenEquationrow? index;

  /// The sqrt-and.
  final TexGreenEquationrow base;

  TexGreenSqrt({
    required final this.index,
    required final this.base,
  });

  @override
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) {
    final baseResult = childBuildResults[1]!;
    final indexResult = childBuildResults[0];
    return BuildResult(
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
}

/// Stretchy operator node.
///
/// Example: `\xleftarrow`
class TexGreenStretchyop extends TexGreenNullableSlotableParentableBase<TexGreenStretchyop> {
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
  late final children = [above, below];

  @override
  AtomType get leftType => AtomType.rel;

  @override
  AtomType get rightType => AtomType.rel;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) =>
      oldOptions.sizeMultiplier != newOptions.sizeMultiplier;

  @override
  TexGreenStretchyop updateChildren(final List<TexGreenEquationrow> newChildren) => TexGreenStretchyop(
        above: newChildren[0],
        below: newChildren[1],
        symbol: symbol,
      );
}

// endregion

// region parentable nonnullable

/// Equation array node. Brings support for equation alignment.
class TexGreenEquationarray extends TexGreenNonnullableSlotableParentableBase<TexGreenEquationarray> {
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
  List<TexGreenEquationrow> get children => body;

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  TexGreenEquationarray updateChildren(final List<TexGreenEquationrow> newChildren) => copyWith(body: newChildren);

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
}

/// Over node.
///
/// Examples: `\underset`
class TexGreenOver extends TexGreenNonnullableSlotableParentableBase<TexGreenOver> {
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
}

/// Under node.
///
/// Examples: `\underset`
class TexGreenUnder extends TexGreenNonnullableSlotableParentableBase<TexGreenUnder> {
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
}

/// Accent node.
///
/// Examples: `\hat`
class TexGreenAccent extends TexGreenNonnullableSlotableParentableBase<TexGreenAccent> {
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
  late final children = [base];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  TexGreenAccent updateChildren(final List<TexGreenEquationrow> newChildren) => copyWith(base: newChildren[0]);

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
}

/// AccentUnder Nodes.
///
/// Examples: `\utilde`
class TexGreenAccentunder extends TexGreenNonnullableSlotableParentableBase<TexGreenAccentunder> {
  /// Base where the accentUnder is applied upon.
  final TexGreenEquationrow base;

  /// Unicode symbol of the accent character.
  final String label;

  TexGreenAccentunder({
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
}

/// Enclosure node
///
/// Examples: `\colorbox`, `\fbox`, `\cancel`.
class TexGreenEnclosure extends TexGreenNonnullableSlotableParentableBase<TexGreenEnclosure> {
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
  late final children = [base];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  TexGreenEnclosure updateChildren(final List<TexGreenEquationrow> newChildren) => TexGreenEnclosure(
    base: newChildren[0],
    hasBorder: hasBorder,
    bordercolor: bordercolor,
    backgroundcolor: backgroundcolor,
    notation: notation,
    horizontalPadding: horizontalPadding,
    verticalPadding: verticalPadding,
  );
}

/// Frac node.
class TexGreenFrac extends TexGreenNonnullableSlotableParentableBase<TexGreenFrac> {
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
  late final children = [numerator, denominator];

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
}

/// Function node
///
/// Examples: `\sin`, `\lim`, `\operatorname`
class TexGreenFunction extends TexGreenNonnullableSlotableParentableBase<TexGreenFunction> {
  /// Name of the function.
  final TexGreenEquationrow functionName;

  /// Argument of the function.
  final TexGreenEquationrow argument;

  TexGreenFunction({
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
        ],),
      );

  @override
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      List.filled(2, options, growable: false);

  @override
  late final children = [functionName, argument];

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
}

/// Left right node.
class TexGreenLeftright extends TexGreenNonnullableSlotableParentableBase<TexGreenLeftright> {
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
  late final children = body;

  @override
  AtomType get leftType => AtomType.open;

  @override
  AtomType get rightType => AtomType.close;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  TexGreenLeftright updateChildren(final List<TexGreenEquationrow> newChildren) => TexGreenLeftright(
    leftDelim: leftDelim,
    rightDelim: rightDelim,
    body: newChildren,
    middle: middle,
  );
}

/// Raise box node which vertically displace its child.
///
/// Example: `\raisebox`
class TexGreenRaisebox extends TexGreenNonnullableSlotableParentableBase<TexGreenRaisebox> {
  /// Child to raise.
  final TexGreenEquationrow body;

  /// Vertical displacement.
  final Measurement dy;

  TexGreenRaisebox({
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
  late final children = [body];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  TexGreenRaisebox updateChildren(final List<TexGreenEquationrow> newChildren) => copyWith(body: newChildren[0]);

  TexGreenRaisebox copyWith({
    final TexGreenEquationrow? body,
    final Measurement? dy,
  }) =>
      TexGreenRaisebox(
        body: body ?? this.body,
        dy: dy ?? this.dy,
      );
}

// endregion

// region parentable clip

/// Node to denote all kinds of style changes.
///
/// [TexGreenStyle] refers to a node who have zero rendering content
/// itself, and are expected to be unwrapped for its children during rendering.
///
/// [TexGreenStyle]s are only allowed to appear directly under
/// [TexGreenEquationrow]s and other [TexGreenStyle]s. And those nodes have to
/// explicitly unwrap transparent nodes during building stage.
class TexGreenStyle extends TexGreenParentableBase<TexGreenStyle> {
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
      copyWith(children: newChildren);

  TexGreenStyle copyWith({
    final List<TexGreen>? children,
    final OptionsDiff? optionsDiff,
  }) =>
      TexGreenStyle(
        children: children ?? this.children,
        optionsDiff: optionsDiff ?? this.optionsDiff,
      );

  @override
  late final editingWidth = integerSum(
    children.map(
      (final child) => child.editingWidth,
    ),
  );

  @override
  late final childPositions = () {
    int curPos = 0;
    return List.generate(
      children.length + 1,
          (final index) {
        if (index == 0) return curPos;
        return curPos += children[index - 1].editingWidth;
      },
      growable: false,
    );
  }();

  @override
  BuildResult buildWidget(
      final MathOptions options,
      final List<BuildResult?> childBuildResults,
      ) =>
      BuildResult(
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
}

/// A row of unrelated [TexGreen]s.
///
/// [TexGreenEquationrow] provides cursor-reachability and editability. It
/// represents a collection of nodes that you can freely edit and navigate.
class TexGreenEquationrow extends TexGreenParentableBase<TexGreenEquationrow> {
  /// If non-null, the leftmost and rightmost [AtomType] will be overridden.
  final AtomType? overrideType;

  @override
  final List<TexGreen> children;

  GlobalKey? _key;

  GlobalKey? get key => _key;

  @override
  late final int editingWidth =
      integerSum(
        children.map(
          (final child) => child.editingWidth,
        ),
      ) + 2;

  @override
  late final childPositions = (){
    int curPos = 1;
    return List.generate(
      children.length + 1,
          (final index) {
        if (index == 0) return curPos;
        return curPos += children[index - 1].editingWidth;
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
        alignerOrSpacer: flattenedChildList[index] is TexGreenSpace &&
            (flattenedChildList[index] as TexGreenSpace).alignerOrSpacer,
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

  void updatePos(final int pos) {
    range = getRange(pos);
  }
}

// endregion

// region leafs

/// Only for provisional use during parsing. Do not use.
class TexGreenTemporary extends TexGreenLeafableBase<TexGreenTemporary> {
  @override
  Mode get mode => Mode.math;

  @override
  BuildResult buildWidget(
    final MathOptions options,
    final List<BuildResult?> childBuildResults,
  ) =>
      throw UnsupportedError('Temporary node $runtimeType encountered.');

  @override
  TexGreenTemporary self() => this;

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

/// Node displays vertical bar the size of [MathOptions.fontSize]
/// to replicate a text edit field cursor
class TexGreenCursor extends TexGreenLeafableBase<TexGreenCursor> {
  @override
  TexGreenCursor self() => this;

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
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;
}

/// Phantom node.
///
/// Example: `\phantom` `\hphantom`.
class TexGreenPhantom extends TexGreenLeafableBase<TexGreenPhantom> {
  @override
  TexGreenPhantom self() => this;

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

/// Space node. Also used for equation alignment.
class TexGreenSpace extends TexGreenLeafableBase<TexGreenSpace> {
  @override
  TexGreenSpace self() => this;

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

/// Node for an unbreakable symbol.
class TexGreenSymbol extends TexGreenLeafableBase<TexGreenSymbol> {
  @override
  TexGreenSymbol self() => this;

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

  TexGreenSymbol({
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

  TexGreenSymbol withSymbol(final String symbol) {
    if (symbol == this.symbol) return this;
    return TexGreenSymbol(
      symbol: symbol,
      variantForm: variantForm,
      overrideAtomType: overrideAtomType,
      overrideFont: overrideFont,
      mode: mode,
    );
  }
}

// endregion
