import 'dart:math';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../ast/ast.dart';
import '../ast/ast_impl.dart';
import '../ast/ast_plus.dart';
import '../utils/extensions.dart';
import 'constants.dart';
import 'util.dart';

abstract class CustomLayoutDelegate<T> {
  const CustomLayoutDelegate();

  // childrenTable parameter is for a hack to render asynchronously for flutter_svg
  Size computeLayout(
    final BoxConstraints constraints,
    final Map<T, RenderBox> childrenTable, {
    final bool dry,
  });

  double getIntrinsicSize({
    required final Axis sizingDirection,
    required final bool max,
    required final double extent, // the extent in the direction that isn't the sizing direction
    required final double Function(
      RenderBox child,
      double extent,
    )
        childSize, // a method to find the size in the sizing direction);
    required final Map<T, RenderBox> childrenTable,
  });

  double? computeDistanceToActualBaseline(final TextBaseline baseline, final Map<T, RenderBox> childrenTable);

  void additionalPaint(final PaintingContext context, final Offset offset) {}
}

class CustomLayoutParentData<T> extends ContainerBoxParentData<RenderBox> {
  /// An object representing the identity of this child.
  T? id;

  @override
  String toString() => '${super.toString()}; id=$id';
}

class CustomLayoutId<T> extends ParentDataWidget<CustomLayoutParentData<T>> {
  /// Marks a child with a layout identifier.
  ///
  /// Both the child and the id arguments must not be null.
  CustomLayoutId({
    required final this.id,
    required final Widget child,
    final Key? key,
  })  : assert(id != null, ""),
        super(key: key ?? ValueKey<T>(id), child: child);

  final T id;

  @override
  void applyParentData(final RenderObject renderObject) {
    assert(renderObject.parentData is CustomLayoutParentData, "");
    final parentData = (renderObject.parentData as CustomLayoutParentData?)!;
    if (parentData.id != id) {
      parentData.id = id;
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>('id', id));
  }

  @override
  Type get debugTypicalAncestorWidgetClass => getTypeOf<CustomLayout<T>>();
}

class CustomLayout<T> extends MultiChildRenderObjectWidget {
  /// Creates a custom multi-child layout.
  ///
  /// The [delegate] argument must not be null.
  CustomLayout({
    required final this.delegate,
    required final List<Widget> children,
    final Key? key,
  }) : super(
          key: key,
          children: children,
        );

  /// The delegate that controls the layout of the children.
  final CustomLayoutDelegate<T> delegate;

  @override
  RenderCustomLayout<T> createRenderObject(final BuildContext context) =>
      RenderCustomLayout<T>(delegate: delegate);

  @override
  void updateRenderObject(
    final BuildContext context,
    final RenderCustomLayout<T> renderObject,
  ) {
    renderObject.delegate = delegate;
  }
}

class RenderCustomLayout<T> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, CustomLayoutParentData<T>>,
        RenderBoxContainerDefaultsMixin<RenderBox, CustomLayoutParentData<T>> {
  RenderCustomLayout({
    required final CustomLayoutDelegate<T> delegate,
    final List<RenderBox>? children,
  }) : _delegate = delegate {
    addAll(children);
  }

  @override
  void setupParentData(final RenderBox child) {
    if (child.parentData is! CustomLayoutParentData<T>) {
      child.parentData = CustomLayoutParentData<T>();
    }
  }

  /// The delegate that controls the layout of the children.
  CustomLayoutDelegate<T> get delegate => _delegate;
  CustomLayoutDelegate<T> _delegate;

  set delegate(final CustomLayoutDelegate<T> newDelegate) {
    if (_delegate != newDelegate) {
      markNeedsLayout();
    }
    _delegate = newDelegate;
  }

  Map<T, RenderBox> get childrenTable {
    final res = <T, RenderBox>{};
    var child = firstChild;
    while (child != null) {
      final childParentData = (child.parentData as CustomLayoutParentData<T>?)!;
      assert(() {
        if (childParentData.id == null) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('Every child of a RenderCustomLayout must have an ID '
                'in its parent data.'),
            child!.describeForError('The following child has no ID'),
          ]);
        }
        if (res.containsKey(childParentData.id)) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('Every child of a RenderCustomLayout must have a unique ID.'),
            child!.describeForError('The following child has a ID of ${childParentData.id}'),
            res[childParentData.id!]!.describeForError('While the following child has the same ID')
          ]);
        }
        return true;
      }(), "");
      res[childParentData.id!] = child;
      child = childParentData.nextSibling;
    }
    return res;
  }

  @override
  double computeMinIntrinsicWidth(final double height) => delegate.getIntrinsicSize(
      sizingDirection: Axis.horizontal,
      max: false,
      extent: height,
      childSize: (final RenderBox child, final double extent) => child.getMinIntrinsicWidth(extent),
      childrenTable: childrenTable);

  @override
  double computeMaxIntrinsicWidth(final double height) => delegate.getIntrinsicSize(
      sizingDirection: Axis.horizontal,
      max: true,
      extent: height,
      childSize: (final RenderBox child, final double extent) => child.getMaxIntrinsicWidth(extent),
      childrenTable: childrenTable);

  @override
  double computeMinIntrinsicHeight(final double width) => delegate.getIntrinsicSize(
      sizingDirection: Axis.vertical,
      max: false,
      extent: width,
      childSize: (final RenderBox child, final double extent) => child.getMinIntrinsicHeight(extent),
      childrenTable: childrenTable);

  @override
  double computeMaxIntrinsicHeight(final double width) => delegate.getIntrinsicSize(
      sizingDirection: Axis.vertical,
      max: true,
      extent: width,
      childSize: (final RenderBox child, final double extent) => child.getMaxIntrinsicHeight(extent),
      childrenTable: childrenTable);

  @override
  double? computeDistanceToActualBaseline(
    final TextBaseline baseline,
  ) =>
      delegate.computeDistanceToActualBaseline(baseline, childrenTable);

  @override
  void performLayout() {
    this.size = _computeLayout(constraints, dry: false);
  }

  @override
  Size computeDryLayout(
    final BoxConstraints constraints,
  ) =>
      _computeLayout(constraints);

  Size _computeLayout(
    final BoxConstraints constraints, {
    final bool dry = true,
  }) =>
      constraints.constrain(
        delegate.computeLayout(constraints, childrenTable, dry: dry),
      );

  @override
  void paint(
    final PaintingContext context,
    final Offset offset,
  ) {
    defaultPaint(context, offset);
    delegate.additionalPaint(context, offset);
  }

  @override
  bool hitTestChildren(
    final BoxHitTestResult result, {
    required final Offset position,
  }) =>
      defaultHitTestChildren(result, position: position);
}

class AxisConfiguration<T> {
  final double size;
  final Map<T, double> offsetTable;

  const AxisConfiguration({
    required final this.size,
    required final this.offsetTable,
  });
}

abstract class IntrinsicLayoutDelegate<T> extends CustomLayoutDelegate<T> {
  const IntrinsicLayoutDelegate();

  AxisConfiguration<T> performHorizontalIntrinsicLayout({
    required final Map<T, double> childrenWidths,
    final bool isComputingIntrinsics = false,
  });

  AxisConfiguration<T> performVerticalIntrinsicLayout({
    required final Map<T, double> childrenHeights,
    required final Map<T, double> childrenBaselines,
    final bool isComputingIntrinsics = false,
  });

  @override
  double getIntrinsicSize({
    required final Axis sizingDirection,
    required final bool max,
    required final double extent,
    required final double Function(RenderBox child, double extent) childSize,
    required final Map<T, RenderBox> childrenTable,
  }) {
    if (sizingDirection == Axis.horizontal) {
      return performHorizontalIntrinsicLayout(
        childrenWidths: childrenTable.map(
          (final key, final value) => MapEntry(
            key,
            childSize(
              value,
              double.infinity,
            ),
          ),
        ),
        isComputingIntrinsics: true,
      ).size;
    } else {
      final childrenHeights = childrenTable.map(
        (final key, final value) => MapEntry(
          key,
          childSize(
            value,
            double.infinity,
          ),
        ),
      );
      return performVerticalIntrinsicLayout(
        childrenHeights: childrenHeights,
        childrenBaselines: childrenHeights,
        isComputingIntrinsics: true,
      ).size;
    }
  }

  @override
  Size computeLayout(
    final BoxConstraints constraints,
    final Map<T, RenderBox> childrenTable, {
    final bool dry = true,
  }) {
    final sizeMap = <T, Size>{};
    for (final childEntry in childrenTable.entries) {
      sizeMap[childEntry.key] = renderBoxGetLayoutSize(
        childEntry.value,
        infiniteConstraint,
        dry: dry,
      );
    }
    final hconf = performHorizontalIntrinsicLayout(
      childrenWidths: sizeMap.map(
        (final key, final value) => MapEntry(
          key,
          value.width,
        ),
      ),
    );
    final vconf = performVerticalIntrinsicLayout(
      childrenHeights: sizeMap.map(
        (final key, final value) => MapEntry(
          key,
          value.height,
        ),
      ),
      childrenBaselines: childrenTable.map(
        (final key, final value) => MapEntry(
          key,
          () {
            if (dry) {
              return 0.0;
            } else {
              return value.getDistanceToBaseline(
                TextBaseline.alphabetic,
                onlyReal: true,
              )!;
            }
          }(),
        ),
      ),
    );
    if (!dry) {
      childrenTable.forEach(
        (final id, final child) => setRenderBoxOffset(
          child,
          Offset(
            hconf.offsetTable[id]!,
            vconf.offsetTable[id]!,
          ),
        ),
      );
    }
    return Size(
      hconf.size,
      vconf.size,
    );
  }
}

class EqnArrayParentData extends ContainerBoxParentData<RenderBox> {}

class EqnArray extends MultiChildRenderObjectWidget {
  final double ruleThickness;
  final double jotSize;
  final double arrayskip;
  final List<TexMatrixSeparatorStyle> hlines;
  final List<double> rowSpacings;

  EqnArray({
    required final this.ruleThickness,
    required final this.jotSize,
    required final this.arrayskip,
    required final this.hlines,
    required final this.rowSpacings,
    required final List<Widget> children,
    final Key? key,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(final BuildContext context) => RenderEqnArray(
        ruleThickness: ruleThickness,
        jotSize: jotSize,
        arrayskip: arrayskip,
        hlines: hlines,
        rowSpacings: rowSpacings,
      );
}

class RenderEqnArray extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, EqnArrayParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, EqnArrayParentData>,
        DebugOverflowIndicatorMixin {
  RenderEqnArray({
    required final double ruleThickness,
    required final double jotSize,
    required final double arrayskip,
    required final List<TexMatrixSeparatorStyle> hlines,
    required final List<double> rowSpacings,
    final List<RenderBox>? children,
  })  : _ruleThickness = ruleThickness,
        _jotSize = jotSize,
        _arrayskip = arrayskip,
        _hlines = hlines,
        _rowSpacings = rowSpacings {
    addAll(children);
  }

  double get ruleThickness => _ruleThickness;
  double _ruleThickness;

  set ruleThickness(final double value) {
    if (_ruleThickness != value) {
      _ruleThickness = value;
      markNeedsLayout();
    }
  }

  double get jotSize => _jotSize;
  double _jotSize;

  set jotSize(final double value) {
    if (_jotSize != value) {
      _jotSize = value;
      markNeedsLayout();
    }
  }

  double get arrayskip => _arrayskip;
  double _arrayskip;

  set arrayskip(final double value) {
    if (_arrayskip != value) {
      _arrayskip = value;
      markNeedsLayout();
    }
  }

  List<TexMatrixSeparatorStyle> get hlines => _hlines;
  List<TexMatrixSeparatorStyle> _hlines;

  set hlines(final List<TexMatrixSeparatorStyle> value) {
    if (_hlines != value) {
      _hlines = value;
      markNeedsLayout();
    }
  }

  List<double> get rowSpacings => _rowSpacings;
  List<double> _rowSpacings;

  set rowSpacings(final List<double> value) {
    if (_rowSpacings != value) {
      _rowSpacings = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(final RenderObject child) {
    if (child.parentData is! EqnArrayParentData) {
      child.parentData = EqnArrayParentData();
    }
  }

  List<double> hlinePos = [];

  double width = 0.0;

  @override
  Size computeDryLayout(final BoxConstraints constraints) => _computeLayout(constraints);

  @override
  void performLayout() {
    size = _computeLayout(constraints, dry: false);
  }

  Size _computeLayout(
    final BoxConstraints constraints, {
    final bool dry = true,
  }) {
    final nonAligningSizes = <Size>[];
    // First pass, calculate width for each column.
    RenderBox? child = firstChild;
    double width = 0.0;
    final colWidths = <double>[];
    final sizeMap = <RenderBox, Size>{};
    while (child != null) {
      Size childSize = Size.zero;
      if (child is RenderLine) {
        child.alignColWidth = null;
        childSize = renderBoxGetLayoutSize(
          child,
          infiniteConstraint,
          dry: dry,
        );
        final childColWidth = child.alignColWidth;
        if (childColWidth != null) {
          for (var i = 0; i < childColWidth.length; i++) {
            if (i >= colWidths.length) {
              colWidths.add(childColWidth[i]);
            } else {
              colWidths[i] = max(
                colWidths[i],
                childColWidth[i],
              );
            }
          }
        } else {
          nonAligningSizes.add(childSize);
        }
      } else {
        childSize = renderBoxGetLayoutSize(
          child,
          infiniteConstraint,
          dry: dry,
        );
        colWidths[0] = max(
          colWidths[0],
          childSize.width,
        );
      }
      sizeMap[child] = childSize;
      child = (child.parentData as EqnArrayParentData?)!.nextSibling;
    }
    final nonAligningChildrenWidth = nonAligningSizes.map((final size) => size.width).maxOrNull ?? 0.0;
    final aligningChildrenWidth = doubleSum(colWidths);
    width = max(nonAligningChildrenWidth, aligningChildrenWidth);
    // Second pass, re-layout each RenderLine using column width constraint
    var index = 0;
    var vPos = 0.0;
    if (!dry) {
      hlinePos.add(vPos);
    }
    index++;
    child = firstChild;
    while (child != null) {
      final childParentData = (child.parentData as EqnArrayParentData?)!;
      var hPos = 0.0;
      final childSize = sizeMap[child] ?? Size.zero;
      if (child is RenderLine && child.alignColWidth != null) {
        child.alignColWidth = colWidths;
        // Hack: We use a different constraint to trigger another layout or
        // else it would be bypassed
        child.layout(BoxConstraints(maxWidth: aligningChildrenWidth), parentUsesSize: true);
        hPos = (width - aligningChildrenWidth) / 2 + colWidths[0] - child.alignColWidth![0];
      } else {
        hPos = (width - childSize.width) / 2;
      }
      final layoutHeight = dry ? 0 : renderBoxLayoutHeight(child);
      final layoutDepth = dry ? childSize.height : renderBoxLayoutDepth(child);
      vPos += max(layoutHeight, 0.7 * arrayskip);
      if (!dry) {
        childParentData.offset = Offset(
          hPos,
          vPos - renderBoxLayoutHeight(child),
        );
      }
      vPos += max(layoutDepth, 0.3 * arrayskip) + jotSize + rowSpacings[index - 1];
      if (!dry) {
        hlinePos.add(vPos);
      }
      vPos += hlines[index] != TexMatrixSeparatorStyle.none ? ruleThickness : 0.0;
      index++;
      child = childParentData.nextSibling;
    }
    if (!dry) {
      this.width = width;
    }
    return Size(width, vPos);
  }

  @override
  bool hitTestChildren(final BoxHitTestResult result, {required final Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(final PaintingContext context, final Offset offset) {
    defaultPaint(context, offset);
    for (var i = 0; i < hlines.length; i++) {
      if (hlines[i] != TexMatrixSeparatorStyle.none) {
        context.canvas.drawLine(
          Offset(0, hlinePos[i] + ruleThickness / 2),
          Offset(width, hlinePos[i] + ruleThickness / 2),
          Paint()..strokeWidth = ruleThickness,
        );
      }
      // TODO dashed line
    }
  }
}

class LayoutBuilderPreserveBaseline extends ConstrainedLayoutBuilder<BoxConstraints> {
  /// Creates a widget that defers its building until layout.
  ///
  /// The [builder] argument must not be null.
  const LayoutBuilderPreserveBaseline({
    required final LayoutWidgetBuilder builder,
    final Key? key,
  }) : super(
          key: key,
          builder: builder,
        );

  @override
  LayoutWidgetBuilder get builder => super.builder;

  @override
  _RenderLayoutBuilderPreserveBaseline createRenderObject(final BuildContext context) =>
      _RenderLayoutBuilderPreserveBaseline();
}

class _RenderLayoutBuilderPreserveBaseline extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>, RenderConstrainedLayoutBuilder<BoxConstraints, RenderBox> {
  @override
  double? computeDistanceToActualBaseline(final TextBaseline baseline) =>
      child?.getDistanceToActualBaseline(baseline);

  @override
  double computeMinIntrinsicWidth(final double height) {
    assert(_debugThrowIfNotCheckingIntrinsics(), "");
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(final double height) {
    assert(_debugThrowIfNotCheckingIntrinsics(), "");
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(final double width) {
    assert(_debugThrowIfNotCheckingIntrinsics(), "");
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(final double width) {
    assert(_debugThrowIfNotCheckingIntrinsics(), "");
    return 0.0;
  }

  @override
  Size computeDryLayout(final BoxConstraints constraints) => child?.getDryLayout(constraints) ?? Size.zero;

  @override
  void performLayout() {
    final constraints = this.constraints;
    // layoutAndBuildChild(); // Flutter >=1.17.0 <1.18.0
    rebuildIfNecessary(); // Flutter >=1.18.0
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child!.size);
    } else {
      size = constraints.biggest;
    }
  }

  @override
  bool hitTestChildren(final BoxHitTestResult result, {required final Offset position}) =>
      child?.hitTest(result, position: position) ?? false;

  @override
  void paint(final PaintingContext context, final Offset offset) {
    if (child != null) context.paintChild(child!, offset);
  }

  bool _debugThrowIfNotCheckingIntrinsics() {
    assert(() {
      if (!RenderObject.debugCheckingIntrinsics) {
        throw FlutterError('LayoutBuilder does not support returning intrinsic dimensions.\n'
            'Calculating the intrinsic dimensions would require '
            'running the layout '
            'callback speculatively, which might mutate the live '
            'render object tree.');
      }
      return true;
    }(), "");

    return true;
  }
}

class LineParentData extends ContainerBoxParentData<RenderBox> {
  // The first canBreakBefore has no effect
  bool canBreakBefore = false;

  BoxConstraints Function(double height, double depth)? customCrossSize;

  double trailingMargin = 0.0;

  bool alignerOrSpacer = false;

  @override
  String toString() =>
      '${super.toString()}; canBreakBefore = $canBreakBefore; customSize = ${customCrossSize != null}; trailingMargin = $trailingMargin; alignerOrSpacer = $alignerOrSpacer';
}

class LineElement extends ParentDataWidget<LineParentData> {
  final bool canBreakBefore;
  final BoxConstraints Function(double height, double depth)? customCrossSize;
  final double trailingMargin;
  final bool alignerOrSpacer;

  const LineElement({
    required final Widget child,
    final Key? key,
    final this.canBreakBefore = false,
    final this.customCrossSize,
    final this.trailingMargin = 0.0,
    final this.alignerOrSpacer = false,
  }) : super(
          key: key,
          child: child,
        );

  @override
  void applyParentData(final RenderObject renderObject) {
    assert(renderObject.parentData is LineParentData, "");
    final parentData = (renderObject.parentData as LineParentData?)!;
    var needsLayout = false;

    if (parentData.canBreakBefore != canBreakBefore) {
      parentData.canBreakBefore = canBreakBefore;
      needsLayout = true;
    }

    if (parentData.customCrossSize != customCrossSize) {
      parentData.customCrossSize = customCrossSize;
      needsLayout = true;
    }

    if (parentData.trailingMargin != trailingMargin) {
      parentData.trailingMargin = trailingMargin;
      needsLayout = true;
    }

    if (parentData.alignerOrSpacer != alignerOrSpacer) {
      parentData.alignerOrSpacer = alignerOrSpacer;
      needsLayout = true;
    }

    if (needsLayout) {
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('canBreakBefore', value: canBreakBefore, ifTrue: 'allow breaking before'));
    properties.add(FlagProperty('customSize', value: customCrossSize != null, ifTrue: 'using relative size'));
    properties.add(DoubleProperty('trailingMargin', trailingMargin));
    properties.add(FlagProperty('alignerOrSpacer', value: alignerOrSpacer, ifTrue: 'is a alignment symbol'));
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Line;
}

/// Line provides abilities for line breaks, delim-sizing and background color indicator.
class Line extends MultiChildRenderObjectWidget {
  Line({
    final Key? key,
    final this.crossAxisAlignment = CrossAxisAlignment.baseline,
    final this.minDepth = 0.0,
    final this.minHeight = 0.0,
    final this.textBaseline = TextBaseline.alphabetic,
    final this.textDirection,
    final List<Widget> children = const [],
  }) : super(
          key: key,
          children: children,
        );

  final CrossAxisAlignment crossAxisAlignment;

  final double minDepth;

  final double minHeight;

  final TextBaseline textBaseline;

  final TextDirection? textDirection;

  bool get _needTextDirection => true;

  @protected
  TextDirection? getEffectiveTextDirection(final BuildContext context) =>
      textDirection ?? (_needTextDirection ? Directionality.of(context) : null);

  @override
  RenderLine createRenderObject(final BuildContext context) => RenderLine(
        crossAxisAlignment: crossAxisAlignment,
        minDepth: minDepth,
        minHeight: minHeight,
        textBaseline: textBaseline,
        textDirection: getEffectiveTextDirection(context),
      );

  @override
  void updateRenderObject(final BuildContext context, final RenderLine renderObject) => renderObject
    ..crossAxisAlignment = crossAxisAlignment
    ..minDepth = minDepth
    ..minHeight = minHeight
    ..textBaseline = textBaseline
    ..textDirection = getEffectiveTextDirection(context);

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<TextBaseline>('textBaseline', textBaseline, defaultValue: null));
    properties.add(EnumProperty<CrossAxisAlignment>('crossAxisAlignment', crossAxisAlignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
  }
}

// RenderLine
class RenderLine extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, LineParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, LineParentData>,
        DebugOverflowIndicatorMixin {
  RenderLine({
    final List<RenderBox>? children,
    final CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.baseline,
    final double minDepth = 0,
    final double minHeight = 0,
    final TextBaseline textBaseline = TextBaseline.alphabetic,
    final TextDirection? textDirection = TextDirection.ltr,
  })  : _crossAxisAlignment = crossAxisAlignment,
        _minDepth = minDepth,
        _minHeight = minHeight,
        _textBaseline = textBaseline,
        _textDirection = textDirection {
    addAll(children);
  }

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment;

  set crossAxisAlignment(final CrossAxisAlignment value) {
    if (_crossAxisAlignment != value) {
      _crossAxisAlignment = value;
      markNeedsLayout();
    }
  }

  double get minDepth => _minDepth;
  double _minDepth;

  set minDepth(final double value) {
    if (_minDepth != value) {
      _minDepth = value;
      markNeedsLayout();
    }
  }

  double get minHeight => _minHeight;
  double _minHeight;

  set minHeight(final double value) {
    if (_minHeight != value) {
      _minHeight = value;
      markNeedsLayout();
    }
  }

  TextBaseline get textBaseline => _textBaseline;
  TextBaseline _textBaseline;

  set textBaseline(final TextBaseline value) {
    if (_textBaseline != value) {
      _textBaseline = value;
      markNeedsLayout();
    }
  }

  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;

  set textDirection(final TextDirection? value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  bool get _debugHasNecessaryDirections {
    assert(
      textDirection != null,
      'Horizontal $runtimeType has a null textDirection, so the alignment cannot be resolved.',
    );
    return true;
  }

  double? _overflow;

  bool get _hasOverflow => _overflow! > precisionErrorTolerance;

  @override
  void setupParentData(final RenderBox child) {
    if (child.parentData is! LineParentData) {
      child.parentData = LineParentData();
    }
  }

  double _getIntrinsicSize({
    required final Axis sizingDirection,
    // the extent in the direction that isn't the sizing direction
    required final double extent,
    // a method to find the size in the sizing direction
    required final double Function(RenderBox child, double extent) childSize,
  }) {
    if (sizingDirection == Axis.horizontal) {
      // INTRINSIC MAIN SIZE
      // Intrinsic main size is the smallest size the flex container can take
      // while maintaining the min/max-content contributions of its flex items.
      double inflexibleSpace = 0.0;
      RenderBox? child = firstChild;
      while (child != null) {
        inflexibleSpace += childSize(child, extent);
        final childParentData = (child.parentData as LineParentData?)!;
        child = childParentData.nextSibling;
      }
      return inflexibleSpace;
    } else {
      // INTRINSIC CROSS SIZE
      // Intrinsic cross size is the max of the intrinsic cross sizes of the
      // children, after the flexible children are fit into the available space,
      // with the children sized using their max intrinsic dimensions.
      double maxCrossSize = 0.0;
      RenderBox? child = firstChild;
      while (child != null) {
        final childMainSize = child.getMaxIntrinsicWidth(double.infinity);
        final crossSize = childSize(child, childMainSize);
        maxCrossSize = math.max(maxCrossSize, crossSize);
        final childParentData = (child.parentData as LineParentData?)!;
        child = childParentData.nextSibling;
      }
      return maxCrossSize;
    }
  }

  @override
  double computeMinIntrinsicWidth(final double height) => _getIntrinsicSize(
        sizingDirection: Axis.horizontal,
        extent: height,
        childSize: (
          final RenderBox child,
          final double extent,
        ) =>
            child.getMinIntrinsicWidth(extent),
      );

  @override
  double computeMaxIntrinsicWidth(final double height) => _getIntrinsicSize(
        sizingDirection: Axis.horizontal,
        extent: height,
        childSize: (
          final RenderBox child,
          final double extent,
        ) =>
            child.getMaxIntrinsicWidth(extent),
      );

  @override
  double computeMinIntrinsicHeight(final double width) => _getIntrinsicSize(
        sizingDirection: Axis.vertical,
        extent: width,
        childSize: (
          final RenderBox child,
          final double extent,
        ) =>
            child.getMinIntrinsicHeight(extent),
      );

  @override
  double computeMaxIntrinsicHeight(final double width) => _getIntrinsicSize(
        sizingDirection: Axis.vertical,
        extent: width,
        childSize: (
          final RenderBox child,
          final double extent,
        ) =>
            child.getMaxIntrinsicHeight(extent),
      );

  double maxHeightAboveBaseline = 0.0;

  double maxHeightAboveEndBaseline = 0.0;

  @override
  double computeDistanceToActualBaseline(
    final TextBaseline baseline,
  ) {
    assert(!debugNeedsLayout, "");
    return maxHeightAboveBaseline;
  }

  @protected
  late List<double> caretOffsets;

  List<double>? alignColWidth;

  @override
  Size computeDryLayout(
    final BoxConstraints constraints,
  ) =>
      _computeLayout(constraints);

  @override
  void performLayout() {
    size = _computeLayout(constraints, dry: false);
  }

  Size _computeLayout(
    final BoxConstraints constraints, {
    final bool dry = true,
  }) {
    assert(_debugHasNecessaryDirections, "");
    // First pass, layout fixed-sized children to calculate height and depth
    double maxHeightAboveBaseline = 0.0;
    double maxDepthBelowBaseline = 0.0;
    var child = firstChild;
    final relativeChildren = <RenderBox>[];
    final alignerAndSpacers = <RenderBox>[];
    final sizeMap = <RenderBox, Size>{};
    while (child != null) {
      final childParentData = (child.parentData as LineParentData?)!;
      if (childParentData.customCrossSize != null) {
        relativeChildren.add(child);
      } else if (childParentData.alignerOrSpacer) {
        alignerAndSpacers.add(child);
      } else {
        final childSize = renderBoxGetLayoutSize(
          child,
          infiniteConstraint,
          dry: dry,
        );
        sizeMap[child] = childSize;
        final distance = dry ? 0.0 : child.getDistanceToBaseline(textBaseline)!;
        maxHeightAboveBaseline = math.max(maxHeightAboveBaseline, distance);
        maxDepthBelowBaseline = math.max(maxDepthBelowBaseline, childSize.height - distance);
      }
      assert(child.parentData == childParentData, "");
      child = childParentData.nextSibling;
    }
    // Second pass, layout custom-sized children
    for (final child in relativeChildren) {
      final childParentData = (child.parentData as LineParentData?)!;
      assert(childParentData.customCrossSize != null, "");
      final childConstraints = childParentData.customCrossSize!(
        maxHeightAboveBaseline,
        maxDepthBelowBaseline,
      );
      final childSize = renderBoxGetLayoutSize(
        child,
        childConstraints,
        dry: dry,
      );
      sizeMap[child] = childSize;
      final distance = dry ? 0.0 : child.getDistanceToBaseline(textBaseline)!;
      maxHeightAboveBaseline = math.max(maxHeightAboveBaseline, distance);
      maxDepthBelowBaseline = math.max(maxDepthBelowBaseline, childSize.height - distance);
    }
    // Apply mininmum size constraint
    maxHeightAboveBaseline = math.max(maxHeightAboveBaseline, minHeight);
    maxDepthBelowBaseline = math.max(maxDepthBelowBaseline, minDepth);
    // Third pass. Calculate column width separate by aligners and spacers.
    //
    // Also determine offset for each children in the meantime, as if there are
    // no aligning instructions. If there are indeed none, this will be the
    // final pass.
    child = firstChild;
    double mainPos = 0.0;
    double lastColPosition = mainPos;
    final colWidths = <double>[];
    final caretOffsets = [mainPos];
    // ignore: invariant_booleans
    while (child != null) {
      final childParentData = (child.parentData as LineParentData?)!;
      var childSize = sizeMap[child] ?? Size.zero;
      if (childParentData.alignerOrSpacer) {
        const childConstraints = BoxConstraints.tightFor(width: 0.0);
        childSize = renderBoxGetLayoutSize(
          child,
          childConstraints,
          dry: dry,
        );
        colWidths.add(mainPos - lastColPosition);
        lastColPosition = mainPos;
      }
      if (!dry) {
        childParentData.offset = Offset(
          mainPos,
          maxHeightAboveBaseline - renderBoxLayoutHeight(child),
        );
      }
      mainPos += childSize.width + childParentData.trailingMargin;
      caretOffsets.add(mainPos);
      child = childParentData.nextSibling;
    }
    colWidths.add(mainPos - lastColPosition);
    Size size = constraints.constrain(
      Size(mainPos, maxHeightAboveBaseline + maxDepthBelowBaseline),
    );
    if (!dry) {
      this.caretOffsets = caretOffsets;
      this._overflow = mainPos - size.width;
      this.maxHeightAboveBaseline = maxHeightAboveBaseline;
    } else {
      return size;
    }
    // If we have no aligners or spacers, no need to do the fourth pass.
    if (alignerAndSpacers.isEmpty) {
      return size;
    } else {
      // If we are have no aligning instructions, no need to do the fourth pass.
      if (this.alignColWidth == null) {
        // Report column width
        this.alignColWidth = colWidths;
        return size;
      }
      // If the code reaches here, means we have aligners/spacers and the
      // aligning instructions.
      //
      // First report first column width.
      final alignColWidth = List.of(this.alignColWidth!, growable: false)..[0] = colWidths.first;
      this.alignColWidth = alignColWidth;
      // We will determine the width of the spacers using aligning instructions
      ///
      ///       Aligner     Spacer      Aligner
      ///         |           |           |
      ///       x | f o o b a |         r | z z z
      ///         |           |-------|   |
      ///     y y | f         | o o b a r |
      ///         |   |-------|           |
      /// Index:  0           1           2
      /// Col: 0        1           2
      ///
      var aligner = true;
      var index = 0;
      for (final alignerOrSpacer in alignerAndSpacers) {
        if (aligner) {
          alignerOrSpacer.layout(
            const BoxConstraints.tightFor(width: 0.0),
            parentUsesSize: true,
          );
        } else {
          alignerOrSpacer.layout(
            BoxConstraints.tightFor(
              width: alignColWidth[index] +
                  (index + 1 < alignColWidth.length - 1 ? alignColWidth[index + 1] : 0) -
                  colWidths[index] -
                  (index + 1 < colWidths.length - 1 ? colWidths[index + 1] : 0),
            ),
            parentUsesSize: true,
          );
        }
        aligner = !aligner;
        index++;
      }
      // Fourth pass, determine position for each children
      child = firstChild;
      mainPos = 0.0;
      this.caretOffsets
        ..clear()
        ..add(mainPos);
      while (child != null) {
        final childParentData = (child.parentData as LineParentData?)!;
        childParentData.offset = Offset(mainPos, maxHeightAboveBaseline - renderBoxLayoutHeight(child));
        mainPos += child.size.width + childParentData.trailingMargin;
        this.caretOffsets.add(mainPos);
        child = childParentData.nextSibling;
      }
      size = constraints.constrain(Size(mainPos, maxHeightAboveBaseline + maxDepthBelowBaseline));
      this._overflow = mainPos - size.width;
      return size;
    }
  }

  @override
  bool hitTestChildren(
    final BoxHitTestResult result, {
    required final Offset position,
  }) =>
      defaultHitTestChildren(result, position: position);

  // List<Rect> get rects {
  //   final constraints = this.constraints;
  //   if (constraints is BreakableBoxConstraints) {
  //     var i = 0;
  //     var crossPos = 0.0;
  //     final res = <Rect>[];
  //     for (final size in size.lineSizes) {
  //       final mainPos = i == 0
  //           ? 0.0
  //           : constraints.maxWidthFirstLine - constraints.maxWidthBodyLines;
  //       res.add(Rect.fromLTWH(mainPos, crossPos, size.width, size.height));
  //       crossPos += size.height;
  //       i++;
  //     }
  //     return res;
  //   } else {
  //     return [Rect.fromLTWH(0, 0, size.width, size.height)];
  //   }
  // }

  @override
  void paint(
    final PaintingContext context,
    final Offset offset,
  ) {
    if (!_hasOverflow) {
      defaultPaint(context, offset);
    } else {
      if (!size.isEmpty) {
        context.pushClipRect(needsCompositing, offset, Offset.zero & size, defaultPaint);
        assert(() {
          // Only set this if it's null to save work. It gets reset to null if the
          // _direction changes.
          final debugOverflowHints = <DiagnosticsNode>[
            ErrorDescription(
              'The edge of the $runtimeType that is overflowing has been marked '
              'in the rendering with a yellow and black striped pattern. This is '
              'usually caused by the contents being too big for the $runtimeType.',
            ),
            ErrorHint(
              'Consider applying a flex factor (e.g. using an Expanded widget) to '
              'force the children of the $runtimeType to fit within the available '
              'space instead of being sized to their natural size.',
            ),
            ErrorHint(
              'This is considered an error condition because it indicates that there '
              'is content that cannot be seen. If the content is legitimately bigger '
              'than the available space, consider clipping it with a ClipRect widget '
              'before putting it in the flex, or using a scrollable container rather '
              'than a Flex, like a ListView.',
            ),
          ];
          // Simulate a child rect that overflows by the right amount. This child
          // rect is never used for drawing, just for determining the overflow
          // location and amount.
          Rect overflowChildRect;
          overflowChildRect = Rect.fromLTWH(0.0, 0.0, size.width + _overflow!, 0.0);
          paintOverflowIndicator(
            context,
            offset,
            Offset.zero & size,
            overflowChildRect,
            overflowHints: debugOverflowHints,
          );
          return true;
        }(), "");
      }
    }
  }

  @override
  Rect? describeApproximatePaintClip(
    final RenderObject child,
  ) {
    if (_hasOverflow) {
      return Offset.zero & size;
    } else {
      return null;
    }
  }

  @override
  String toStringShort() {
    String header = super.toStringShort();
    if (_overflow != null && _hasOverflow) header += ' OVERFLOWING';
    return header;
  }

  @override
  void debugFillProperties(
    final DiagnosticPropertiesBuilder properties,
  ) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<CrossAxisAlignment>('crossAxisAlignment', crossAxisAlignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
    properties.add(EnumProperty<TextBaseline>('textBaseline', textBaseline, defaultValue: null));
    // properties.add(DoubleProperty('baselineOffset', baselineOffset));
  }
}

class EditableLine extends MultiChildRenderObjectWidget {
  EditableLine({
    required final this.cursorColor,
    required final this.node,
    required final this.preferredLineHeight,
    final this.crossAxisAlignment = CrossAxisAlignment.baseline,
    final this.cursorBlinkOpacityController,
    final this.cursorOffset,
    final this.cursorOpacityAnimates = false,
    final this.cursorRadius,
    final this.cursorWidth = 1.0,
    final this.cursorHeight,
    final this.devicePixelRatio = 1.0,
    final this.hintingColor,
    final this.minDepth = 0.0,
    final this.minHeight = 0.0,
    final this.paintCursorAboveText = false,
    final this.selection = const TextSelection.collapsed(offset: -1),
    final this.selectionColor,
    final this.showCursor = false,
    final this.startHandleLayerLink,
    final this.endHandleLayerLink,
    final this.textBaseline = TextBaseline.alphabetic,
    final this.textDirection,
    final List<Widget> children = const [],
    final Key? key,
  }) : super(key: key, children: children);

  final CrossAxisAlignment crossAxisAlignment;

  final AnimationController? cursorBlinkOpacityController;

  final Color cursorColor;

  final Offset? cursorOffset;

  final bool cursorOpacityAnimates;

  final Radius? cursorRadius;

  final double cursorWidth;

  final double? cursorHeight;

  final double devicePixelRatio;

  final Color? hintingColor;

  final double minDepth;

  final double minHeight;

  final TexGreenEquationrow node;

  final bool paintCursorAboveText;

  final double preferredLineHeight;

  final TextSelection selection;

  final Color? selectionColor;

  final bool showCursor;

  final LayerLink? startHandleLayerLink;

  final LayerLink? endHandleLayerLink;

  final TextBaseline textBaseline;

  final TextDirection? textDirection;

  bool get _needTextDirection => true;

  @protected
  TextDirection? getEffectiveTextDirection(final BuildContext context) =>
      textDirection ?? (_needTextDirection ? Directionality.of(context) : null);

  @override
  RenderEditableLine createRenderObject(final BuildContext context) => RenderEditableLine(
        crossAxisAlignment: crossAxisAlignment,
        cursorBlinkOpacityController: cursorBlinkOpacityController,
        cursorColor: cursorColor,
        cursorOffset: cursorOffset,
        cursorRadius: cursorRadius,
        cursorWidth: cursorWidth,
        cursorHeight: cursorHeight,
        devicePixelRatio: devicePixelRatio,
        hintingColor: hintingColor,
        minDepth: minDepth,
        minHeight: minHeight,
        node: node,
        paintCursorAboveText: paintCursorAboveText,
        preferredLineHeight: preferredLineHeight,
        selection: selection,
        selectionColor: selectionColor,
        showCursor: showCursor,
        startHandleLayerLink: startHandleLayerLink,
        endHandleLayerLink: endHandleLayerLink,
        textBaseline: textBaseline,
        textDirection: getEffectiveTextDirection(context),
      );

  @override
  void updateRenderObject(final BuildContext context, final RenderEditableLine renderObject) => renderObject
    ..crossAxisAlignment = crossAxisAlignment
    ..cursorBlinkOpacityController = cursorBlinkOpacityController
    ..cursorColor = cursorColor
    ..cursorOffset = cursorOffset
    ..cursorRadius = cursorRadius
    ..cursorWidth = cursorWidth
    ..cursorHeight = cursorHeight
    ..devicePixelRatio = devicePixelRatio
    ..hintingColor = hintingColor
    ..minDepth = minDepth
    ..minHeight = minHeight
    ..node = node
    ..paintCursorAboveText = paintCursorAboveText
    ..preferredLineHeight = preferredLineHeight
    ..selection = selection
    ..selectionColor = selectionColor
    ..showCursor = showCursor
    ..startHandleLayerLink = startHandleLayerLink
    ..endHandleLayerLink = endHandleLayerLink
    ..textBaseline = textBaseline
    ..textDirection = getEffectiveTextDirection(context);

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<TextBaseline>('textBaseline', textBaseline, defaultValue: null));
    properties.add(EnumProperty<CrossAxisAlignment>('crossAxisAlignment', crossAxisAlignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
  }
}

class RenderEditableLine extends RenderLine {
  RenderEditableLine({
    required final this.node,
    required final this.preferredLineHeight,
    required final Color cursorColor,
    final List<RenderBox>? children,
    final CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.baseline,
    final AnimationController? cursorBlinkOpacityController,
    final Offset? cursorOffset,
    final Radius? cursorRadius,
    final double cursorWidth = 1.0,
    final double? cursorHeight,
    final double devicePixelRatio = 1.0,
    final Color? hintingColor,
    final double minDepth = 0,
    final double minHeight = 0,
    final bool paintCursorAboveText = false,
    final TextSelection selection = const TextSelection.collapsed(offset: -1),
    final Color? selectionColor,
    final bool showCursor = false,
    final LayerLink? startHandleLayerLink,
    final LayerLink? endHandleLayerLink,
    final TextBaseline textBaseline = TextBaseline.alphabetic,
    final TextDirection? textDirection = TextDirection.ltr,
  })  :
        // assert(!showCursor || cursorColor != null),
        _cursorBlinkOpacityController = cursorBlinkOpacityController,
        _cursorColor = cursorColor,
        _cursorOffset = cursorOffset,
        _cursorRadius = cursorRadius,
        _cursorWidth = cursorWidth,
        _cursorHeight = cursorHeight,
        _devicePixelRatio = devicePixelRatio,
        _hintingColor = hintingColor,
        _paintCursorAboveText = paintCursorAboveText,
        _selection = selection,
        _selectionColor = selectionColor,
        _showCursor = showCursor,
        _startHandleLayerLink = startHandleLayerLink,
        _endHandleLayerLink = endHandleLayerLink,
        super(
          children: children,
          crossAxisAlignment: crossAxisAlignment,
          minDepth: minDepth,
          minHeight: minHeight,
          textBaseline: textBaseline,
          textDirection: textDirection,
        );

  AnimationController? get cursorBlinkOpacityController => _cursorBlinkOpacityController;
  AnimationController? _cursorBlinkOpacityController;

  set cursorBlinkOpacityController(final AnimationController? value) {
    if (_cursorBlinkOpacityController != value) {
      _cursorBlinkOpacityController?.removeListener(onCursorOpacityChanged);
      _cursorBlinkOpacityController = value;
      _cursorBlinkOpacityController?.addListener(onCursorOpacityChanged);
      markNeedsPaint();
    }
  }

  void onCursorOpacityChanged() {
    if (showCursor && selection.isCollapsed && isSelectionInRange) {
      markNeedsPaint();
    }
  }

  /// The color to use when painting the cursor.
  Color get cursorColor => _cursorColor;
  Color _cursorColor;

  set cursorColor(final Color value) {
    if (_cursorColor != value) {
      _cursorColor = value;
      markNeedsPaint();
    }
  }

  /// {@macro flutter.rendering.editable.cursorOffset}
  Offset? get cursorOffset => _cursorOffset;
  Offset? _cursorOffset;

  set cursorOffset(final Offset? value) {
    if (_cursorOffset != value) {
      _cursorOffset = value;
      markNeedsPaint();
    }
  }

  /// How rounded the corners of the cursor should be.
  ///
  /// A null value is the same as [Radius.zero].
  Radius? get cursorRadius => _cursorRadius;
  Radius? _cursorRadius;

  set cursorRadius(final Radius? value) {
    if (_cursorRadius != value) {
      _cursorRadius = value;
      markNeedsPaint();
    }
  }

  double get cursorWidth => _cursorWidth;
  double _cursorWidth;

  set cursorWidth(final double value) {
    if (_cursorWidth != value) {
      _cursorWidth = value;
      markNeedsPaint();
    }
  }

  /// How tall the cursor will be.
  ///
  /// This can be null, in which case the getter will actually return
  /// [preferredLineHeight].
  ///
  /// Setting this to itself fixes the value to the current
  /// [preferredLineHeight]. Setting
  /// this to null returns the behaviour of deferring to [preferredLineHeight].
  double get cursorHeight => _cursorHeight ?? preferredLineHeight;
  double? _cursorHeight;

  set cursorHeight(final double? value) {
    if (_cursorHeight != value) {
      _cursorHeight = value;
      markNeedsPaint();
    }
  }

  double get devicePixelRatio => _devicePixelRatio;
  double _devicePixelRatio;

  set devicePixelRatio(final double value) {
    if (_devicePixelRatio != value) {
      _devicePixelRatio = value;
      markNeedsPaint();
    }
  }

  Color? get hintingColor => _hintingColor;
  Color? _hintingColor;

  set hintingColor(final Color? value) {
    if (_hintingColor != value) {
      _hintingColor = value;
      markNeedsPaint();
    }
  }

  TexGreenEquationrow node;

  /// {@template flutter.rendering.editable.paintCursorOnTop}
  bool get paintCursorAboveText => _paintCursorAboveText;
  bool _paintCursorAboveText;

  set paintCursorAboveText(final bool value) {
    if (_paintCursorAboveText != value) {
      _paintCursorAboveText = value;
      markNeedsPaint();
    }
  }

  double preferredLineHeight;

  TextSelection get selection => _selection;
  TextSelection _selection;

  set selection(final TextSelection value) {
    if (_selection != value) {
      _selection = value;
      markNeedsPaint();
    }
  }

  /// The color to use when painting the selection.
  Color? get selectionColor => _selectionColor;
  Color? _selectionColor;

  set selectionColor(final Color? value) {
    if (_selectionColor != value) {
      _selectionColor = value;
      markNeedsPaint();
    }
  }

  /// Whether to paint the cursor.
  bool get showCursor => _showCursor;
  bool _showCursor;

  set showCursor(final bool value) {
    if (_showCursor != value) {
      _showCursor = value;
      markNeedsPaint();
    }
  }

  LayerLink? get startHandleLayerLink => _startHandleLayerLink;
  LayerLink? _startHandleLayerLink;

  set startHandleLayerLink(final LayerLink? value) {
    if (_startHandleLayerLink != value) {
      _startHandleLayerLink = value;
      markNeedsPaint();
    }
  }

  LayerLink? get endHandleLayerLink => _endHandleLayerLink;
  LayerLink? _endHandleLayerLink;

  set endHandleLayerLink(final LayerLink? value) {
    if (_endHandleLayerLink != value) {
      _endHandleLayerLink = value;
      markNeedsPaint();
    }
  }

  bool get isSelectionInRange => _selection.end >= 0 && _selection.start <= childCount;

  int getCaretIndexForPoint(final Offset globalOffset) {
    final localOffset = globalToLocal(globalOffset);
    var minDist = double.infinity;
    var minPosition = 0;
    for (var i = 0; i < caretOffsets.length; i++) {
      final dist = (caretOffsets[i] - localOffset.dx).abs();
      if (dist <= minDist) {
        minDist = dist;
        minPosition = i;
      }
    }
    return minPosition;
  }

  // Will always attempt to get the nearest left caret
  int getNearestLeftCaretIndexForPoint(final Offset globalOffset) {
    final localOffset = globalToLocal(globalOffset);
    var index = 0;
    while (index < caretOffsets.length && caretOffsets[index] <= localOffset.dx) {
      index++;
    }
    return math.max(0, index - 1);
  }

  Offset getEndpointForCaretIndex(
    final int index,
  ) {
    final dx = caretOffsets[clampInteger(
      index,
      0,
      caretOffsets.length - 1,
    )];
    final dy = size.height;
    return localToGlobal(Offset(dx, dy));
  }

  @override
  bool hitTestSelf(final Offset position) => true;

  @override
  void paint(
    final PaintingContext context,
    final Offset offset,
  ) {
    // Only paint selection/hinting if the part of the selection is in range
    if (isSelectionInRange) {
      final startOffset = caretOffsets[math.max(0, selection.start)];
      final endOffset = caretOffsets[math.min(childCount, selection.end)];
      if (_selection.isCollapsed) {
        if (_hintingColor != null) {
          // Paint hinting background if selection is collapsed
          context.canvas.drawRect(
            offset & size,
            Paint()
              ..style = PaintingStyle.fill
              ..color = _hintingColor!,
          );
        }
      } else if (_selectionColor != null) {
        // Paint selection if not collapsed
        context.canvas.drawRect(
          Rect.fromLTRB(startOffset, 0, endOffset, size.height).shift(offset),
          Paint()
            ..style = PaintingStyle.fill
            ..color = _selectionColor!,
        );
      }

      // Whatever which case, we need to mark the layer link.
      if (startHandleLayerLink != null) {
        context.pushLayer(
          LeaderLayer(
            link: startHandleLayerLink!,
            offset: Offset(startOffset, size.height) + offset,
          ),
          emptyPaintFunction,
          Offset.zero,
        );
      }
      if (endHandleLayerLink != null) {
        context.pushLayer(
          LeaderLayer(
            link: endHandleLayerLink!,
            offset: Offset(endOffset, size.height) + offset,
          ),
          emptyPaintFunction,
          Offset.zero,
        );
      }
    }

    if (_paintCursorAboveText) {
      super.paint(context, offset);
    }

    if (showCursor && _selection.isCollapsed && isSelectionInRange) {
      final cursorOffset = caretOffsets[selection.baseOffset];
      _paintCaret(context.canvas, Offset(cursorOffset, size.height) + offset);
    }

    if (!_paintCursorAboveText) {
      super.paint(context, offset);
    }

    return;
  }

  // static const _kCaretHeightOffset = 2.0;

  void _paintCaret(final Canvas canvas, final Offset baselineOffset) {
    final paint = Paint()..color = _cursorColor.withOpacity(_cursorBlinkOpacityController?.value ?? 0);

    Rect _caretPrototype;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        _caretPrototype = Rect.fromLTWH(
          0.0,
          0.0,
          _cursorWidth,
          cursorHeight + 2,
        );
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _caretPrototype = Rect.fromLTWH(
          0.0,
          0.0, // _kCaretHeightOffset,
          _cursorWidth,
          cursorHeight, // - 2.0 * _kCaretHeightOffset,
        );
        break;
    }

    var caretRect =
        _caretPrototype.shift(baselineOffset).shift(Offset(0, -0.9 * cursorHeight)); // 0.9 is eyeballed

    if (_cursorOffset != null) {
      caretRect = caretRect.shift(_cursorOffset!);
    }

    // final double caretHeight =
    //     _textPainter.getFullHeightForCaret(textPosition, _caretPrototype);
    // if (caretHeight != null) {
    //   switch (defaultTargetPlatform) {
    //     case TargetPlatform.iOS:
    //     case TargetPlatform.macOS:
    //       final heightDiff = caretHeight - caretRect.height;
    //       // Center the caret vertically along the text.
    //       caretRect = Rect.fromLTWH(
    //         caretRect.left,
    //         caretRect.top + heightDiff / 2,
    //         caretRect.width,
    //         caretRect.height,
    //       );
    //       break;
    //     case TargetPlatform.android:
    //     case TargetPlatform.fuchsia:
    //     case TargetPlatform.linux:
    //     case TargetPlatform.windows:
    //       // Override the height to take the full height of the glyph at the TextPosition
    //       // when not on iOS. iOS has special handling that creates a taller caret.
    //       caretRect = Rect.fromLTWH(
    //         caretRect.left,
    //         caretRect.top - _kCaretHeightOffset,
    //         caretRect.width,
    //         caretHeight,
    //       );
    //       break;
    //   }
    // }

    caretRect = caretRect.shift(_getPixelPerfectCursorOffset(caretRect));

    if (_cursorRadius == null) {
      canvas.drawRect(caretRect, paint);
    } else {
      final caretRRect = RRect.fromRectAndRadius(caretRect, _cursorRadius!);
      canvas.drawRRect(caretRRect, paint);
    }
  }

  /// Computes the offset to apply to the given [caretRect] so it perfectly
  /// snaps to physical pixels.
  Offset _getPixelPerfectCursorOffset(final Rect caretRect) {
    final caretPosition = localToGlobal(caretRect.topLeft);
    final pixelMultiple = 1.0 / _devicePixelRatio;
    final pixelPerfectOffsetX = caretPosition.dx.isFinite
        ? (caretPosition.dx / pixelMultiple).round() * pixelMultiple - caretPosition.dx
        : 0.0;
    final pixelPerfectOffsetY = caretPosition.dy.isFinite
        ? (caretPosition.dy / pixelMultiple).round() * pixelMultiple - caretPosition.dy
        : 0.0;
    return Offset(pixelPerfectOffsetX, pixelPerfectOffsetY);
  }
}

void emptyPaintFunction(final PaintingContext context, final Offset offset) {}

class MinDimension extends SingleChildRenderObjectWidget {
  final double minHeight;
  final double minDepth;
  final double topPadding;
  final double bottomPadding;

  const MinDimension({
    required final Widget child,
    final this.minHeight = 0,
    final this.minDepth = 0,
    final this.topPadding = 0,
    final this.bottomPadding = 0,
    final Key? key,
  }) : super(
          key: key,
          child: child,
        );

  @override
  RenderMinDimension createRenderObject(
    final BuildContext context,
  ) =>
      RenderMinDimension(
        minHeight: minHeight,
        minDepth: minDepth,
        topPadding: topPadding,
        bottomPadding: bottomPadding,
      );

  @override
  void updateRenderObject(
    final BuildContext context,
    final RenderMinDimension renderObject,
  ) =>
      renderObject
        ..minHeight = minHeight
        ..minDepth = minDepth
        ..topPadding = topPadding
        ..bottomPadding = bottomPadding;
}

class RenderMinDimension extends RenderShiftedBox {
  RenderMinDimension({
    final RenderBox? child,
    final double minHeight = 0,
    final double minDepth = 0,
    final double topPadding = 0,
    final double bottomPadding = 0,
  })  : _minHeight = minHeight,
        _minDepth = minDepth,
        _topPadding = topPadding,
        _bottomPadding = bottomPadding,
        super(child);

  double get minHeight => _minHeight;
  double _minHeight;

  set minHeight(
    final double value,
  ) {
    if (_minHeight != value) {
      _minHeight = value;
      markNeedsLayout();
    }
  }

  double get minDepth => _minDepth;
  double _minDepth;

  set minDepth(
    final double value,
  ) {
    if (_minDepth != value) {
      _minDepth = value;
      markNeedsLayout();
    }
  }

  double get topPadding => _topPadding;
  double _topPadding;

  set topPadding(
    final double value,
  ) {
    if (_topPadding != value) {
      _topPadding = value;
      markNeedsLayout();
    }
  }

  double get bottomPadding => _bottomPadding;
  double _bottomPadding;

  set bottomPadding(
    final double value,
  ) {
    if (_bottomPadding != value) {
      _bottomPadding = value;
      markNeedsLayout();
    }
  }

  @override
  double computeMinIntrinsicHeight(
    final double width,
  ) =>
      max(
        minHeight + minDepth,
        super.computeMinIntrinsicHeight(width) + topPadding + bottomPadding,
      );

  @override
  double computeMaxIntrinsicHeight(
    final double width,
  ) =>
      max(
        minHeight + minDepth,
        super.computeMaxIntrinsicHeight(width) + topPadding + bottomPadding,
      );

  double distanceToBaseline = 0.0;

  @override
  double computeDistanceToActualBaseline(
    final TextBaseline baseline,
  ) =>
      distanceToBaseline;

  @override
  Size computeDryLayout(
    final BoxConstraints constraints,
  ) =>
      _computeLayout(constraints);

  @override
  void performLayout() {
    size = _computeLayout(constraints, dry: false);
  }

  Size _computeLayout(
    final BoxConstraints constraints, {
    final bool dry = true,
  }) {
    final child = this.child!;
    final childSize = renderBoxGetLayoutSize(
      child,
      constraints,
      dry: dry,
    );
    final childHeight = () {
      if (dry) {
        return 0;
      } else {
        return child.getDistanceToBaseline(
          TextBaseline.alphabetic,
        )!;
      }
    }();
    final childDepth = childSize.height - childHeight;
    final width = childSize.width;
    final height = max(
      minHeight,
      childHeight + topPadding,
    );
    final depth = max(
      minDepth,
      childDepth + bottomPadding,
    );
    if (!dry) {
      setRenderBoxOffset(
        child,
        Offset(
          0,
          height - childHeight,
        ),
      );
      distanceToBaseline = height;
    }
    return constraints.constrain(
      Size(
        width,
        height + depth,
      ),
    );
  }
}

/// This should be the perfect use case for [CustomMultiChildLayout] and
/// [MultiChildLayoutDelegate]. However, they don't support baseline
/// functionalities. So we have to start from [MultiChildRenderObjectWidget].
///
/// This should also be a great showcase for [LayoutId], but the generic
/// parameter prevents us to use or extend from [LayoutId].
///
/// This should also be a great showcase for [MultiChildLayoutParentData],
/// but the lack of generic ([Object] type) is undesirable.

enum _ScriptPos {
  base,
  sub,
  sup,
  presub,
  presup,
}

class Multiscripts extends StatelessWidget {
  const Multiscripts({
    required final this.isBaseCharacterBox,
    required final this.baseResult,
    final Key? key,
    final this.alignPostscripts = false,
    final this.subResult,
    final this.supResult,
    final this.presubResult,
    final this.presupResult,
  }) : super(
          key: key,
        );

  final bool alignPostscripts;
  final bool isBaseCharacterBox;

  final TexGreenBuildResult baseResult;
  final TexGreenBuildResult? subResult;
  final TexGreenBuildResult? supResult;
  final TexGreenBuildResult? presubResult;
  final TexGreenBuildResult? presupResult;

  @override
  Widget build(final BuildContext context) => CustomLayout(
        delegate: MultiscriptsLayoutDelegate(
          alignPostscripts: alignPostscripts,
          italic: baseResult.italic,
          isBaseCharacterBox: isBaseCharacterBox,
          baseOptions: baseResult.options,
          subOptions: subResult?.options,
          supOptions: supResult?.options,
          presubOptions: presubResult?.options,
          presupOptions: presupResult?.options,
        ),
        children: <Widget>[
          CustomLayoutId(
            id: _ScriptPos.base,
            child: baseResult.widget,
          ),
          if (subResult != null)
            CustomLayoutId(
              id: _ScriptPos.sub,
              child: subResult!.widget,
            ),
          if (supResult != null)
            CustomLayoutId(
              id: _ScriptPos.sup,
              child: supResult!.widget,
            ),
          if (presubResult != null)
            CustomLayoutId(
              id: _ScriptPos.presub,
              child: presubResult!.widget,
            ),
          if (presupResult != null)
            CustomLayoutId(
              id: _ScriptPos.presup,
              child: presupResult!.widget,
            ),
        ],
      );
}

// Superscript and subscripts are handled in the TeXbook on page
// 445-446, rules 18(a-f).
class MultiscriptsLayoutDelegate extends IntrinsicLayoutDelegate<_ScriptPos> {
  final bool alignPostscripts;
  final double italic;

  final bool isBaseCharacterBox;
  final TexMathOptions baseOptions;
  final TexMathOptions? subOptions;
  final TexMathOptions? supOptions;
  final TexMathOptions? presubOptions;
  final TexMathOptions? presupOptions;

  MultiscriptsLayoutDelegate({
    required final this.alignPostscripts,
    required final this.italic,
    required final this.isBaseCharacterBox,
    required final this.baseOptions,
    required final this.subOptions,
    required final this.supOptions,
    required final this.presubOptions,
    required final this.presupOptions,
  });

  double baselineDistance = 0.0;

  @override
  double computeDistanceToActualBaseline(
          final TextBaseline baseline, final Map<_ScriptPos, RenderBox> childrenTable) =>
      baselineDistance;

  // // This will trigger Flutter assertion error
  // nPlus(
  //   childrenTable[_ScriptPos.base].offset.dy,
  //   childrenTable[_ScriptPos.base]
  //       .getDistanceToBaseline(baseline, onlyReal: true),
  // );

  @override
  AxisConfiguration<_ScriptPos> performHorizontalIntrinsicLayout({
    required final Map<_ScriptPos, double> childrenWidths,
    final bool isComputingIntrinsics = false,
  }) {
    final baseSize = childrenWidths[_ScriptPos.base]!;
    final subSize = childrenWidths[_ScriptPos.sub];
    final supSize = childrenWidths[_ScriptPos.sup];
    final presubSize = childrenWidths[_ScriptPos.presub];
    final presupSize = childrenWidths[_ScriptPos.presup];
    final scriptSpace = pt(0.5).toLpUnder(baseOptions);
    final extendedSubSize = subSize != null ? subSize + scriptSpace : 0.0;
    final extendedSupSize = supSize != null ? supSize + scriptSpace : 0.0;
    final extendedPresubSize = presubSize != null ? presubSize + scriptSpace : 0.0;
    final extendedPresupSize = presupSize != null ? presupSize + scriptSpace : 0.0;
    final postscriptWidth = max(
      extendedSupSize,
      -(alignPostscripts ? 0.0 : italic) + extendedSubSize,
    );
    final prescriptWidth = max(extendedPresubSize, extendedPresupSize);
    final fullSize = postscriptWidth + prescriptWidth + baseSize;
    return AxisConfiguration(
      size: fullSize,
      offsetTable: {
        _ScriptPos.base: prescriptWidth,
        _ScriptPos.sub: prescriptWidth + baseSize - (alignPostscripts ? 0.0 : italic),
        _ScriptPos.sup: prescriptWidth + baseSize,
        if (presubSize != null) _ScriptPos.presub: prescriptWidth - presubSize,
        if (presupSize != null) _ScriptPos.presup: prescriptWidth - presupSize,
      },
    );
  }

  @override
  AxisConfiguration<_ScriptPos> performVerticalIntrinsicLayout({
    required final Map<_ScriptPos, double> childrenHeights,
    required final Map<_ScriptPos, double> childrenBaselines,
    final bool isComputingIntrinsics = false,
  }) {
    final baseSize = childrenHeights[_ScriptPos.base]!;
    final subSize = childrenHeights[_ScriptPos.sub];
    final supSize = childrenHeights[_ScriptPos.sup];
    final presubSize = childrenHeights[_ScriptPos.presub];
    final presupSize = childrenHeights[_ScriptPos.presup];
    final baseHeight = childrenBaselines[_ScriptPos.base]!;
    final subHeight = childrenBaselines[_ScriptPos.sub];
    final supHeight = childrenBaselines[_ScriptPos.sup];
    final presubHeight = childrenBaselines[_ScriptPos.presub];
    final presupHeight = childrenBaselines[_ScriptPos.presup];
    final postscriptRes = calculateUV(
      base: _ScriptUvConf(baseSize, baseHeight, baseOptions),
      sub: subSize != null ? _ScriptUvConf(subSize, subHeight!, subOptions!) : null,
      sup: supSize != null ? _ScriptUvConf(supSize, supHeight!, supOptions!) : null,
      isBaseCharacterBox: isBaseCharacterBox,
    );
    final prescriptRes = calculateUV(
      base: _ScriptUvConf(baseSize, baseHeight, baseOptions),
      sub: presubSize != null ? _ScriptUvConf(presubSize, presubHeight!, presubOptions!) : null,
      sup: presupSize != null ? _ScriptUvConf(presupSize, presupHeight!, presupOptions!) : null,
      isBaseCharacterBox: isBaseCharacterBox,
    );
    final subShift = postscriptRes.v;
    final supShift = postscriptRes.u;
    final presubShift = prescriptRes.v;
    final presupShift = prescriptRes.u;
    // Rule 18f
    final height = [
      baseHeight,
      if (subHeight != null) subHeight - subShift,
      if (supHeight != null) supHeight + supShift,
      if (presubHeight != null) presubHeight - presubShift,
      if (presupHeight != null) presupHeight + presupShift,
    ].max;
    final depth = [
      baseSize - baseHeight,
      if (subHeight != null) subSize! - subHeight + subShift,
      if (supHeight != null) supSize! - supHeight - supShift,
      if (presubHeight != null) presubSize! - presubHeight + presubShift,
      if (presupHeight != null) presupSize! - presupHeight - presupShift,
    ].max;
    if (!isComputingIntrinsics) {
      baselineDistance = height;
    }
    return AxisConfiguration(
      size: height + depth,
      offsetTable: {
        _ScriptPos.base: height - baseHeight,
        if (subHeight != null) _ScriptPos.sub: height + subShift - subHeight,
        if (supHeight != null) _ScriptPos.sup: height - supShift - supHeight,
        if (presubHeight != null) _ScriptPos.presub: height + presubShift - presubHeight,
        if (presupHeight != null) _ScriptPos.presup: height - presupShift - presupHeight,
      },
    );
  }
}

class _ScriptUvConf {
  final double fullHeight;
  final double baseline;
  final TexMathOptions options;

  const _ScriptUvConf(
    this.fullHeight,
    this.baseline,
    this.options,
  );
}

class UVCalculationResult {
  final double u;
  final double v;

  const UVCalculationResult({
    required final this.u,
    required final this.v,
  });
}

UVCalculationResult calculateUV({
  required final _ScriptUvConf base,
  required final bool isBaseCharacterBox,
  final _ScriptUvConf? sub,
  final _ScriptUvConf? sup,
}) {
  final metrics = base.options.fontMetrics;
  final baseOptions = base.options;
  // TexBook Rule 18a
  final h = base.baseline;
  final d = base.fullHeight - h;
  var u = 0.0;
  var v = 0.0;
  if (sub != null) {
    final r = cssem(sub.options.fontMetrics.subDrop).toLpUnder(sub.options);
    v = isBaseCharacterBox ? 0 : d + r;
  }
  if (sup != null) {
    final q = cssem(sup.options.fontMetrics.supDrop).toLpUnder(sup.options);
    if (isBaseCharacterBox) {
      u = 0;
    } else {
      u = h - q;
    }
  }
  if (sup == null && sub != null) {
    // Rule 18b
    final hx = sub.baseline;
    v = max(
      v,
      max(
        cssem(metrics.sub1).toLpUnder(baseOptions),
        hx - 0.8 * metrics.xHeight2.toLpUnder(baseOptions),
      ),
    );
  } else if (sup != null) {
    // Rule 18c
    final dx = sup.fullHeight - sup.baseline;
    final p = cssem(baseOptions.style == TexMathStyle.display
            ? metrics.sup1
            : (mathStyleIsCramped(baseOptions.style) ? metrics.sup3 : metrics.sup2))
        .toLpUnder(baseOptions);
    u = max(
      u,
      max(
        p,
        dx + 0.25 * metrics.xHeight2.toLpUnder(baseOptions),
      ),
    );
    // Rule 18d
    if (sub != null) {
      v = max(v, cssem(metrics.sub2).toLpUnder(baseOptions));
      // Rule 18e
      final theta = cssem(metrics.defaultRuleThickness).toLpUnder(baseOptions);
      final hy = sub.baseline;
      if ((u - dx) - (hy - v) < 4 * theta) {
        v = 4 * theta - u + dx + hy;
        final psi = 0.8 * metrics.xHeight2.toLpUnder(baseOptions) - (u - dx);
        if (psi > 0) {
          u += psi;
          v -= psi;
        }
      }
    }
  }
  return UVCalculationResult(
    u: u,
    v: v,
  );
}

class RemoveBaseline extends SingleChildRenderObjectWidget {
  const RemoveBaseline({
    required final Widget child,
    final Key? key,
  }) : super(
          key: key,
          child: child,
        );

  @override
  RenderRemoveBaseline createRenderObject(final BuildContext context) => RenderRemoveBaseline();
}

class RenderRemoveBaseline extends RenderProxyBox {
  RenderRemoveBaseline({final RenderBox? child}) : super(child);

  @override
  // ignore: avoid_returning_null
  double? computeDistanceToActualBaseline(final TextBaseline baseline) => null;
}

class ResetDimension extends SingleChildRenderObjectWidget {
  final double? height;
  final double? depth;
  final double? width;
  final CrossAxisAlignment horizontalAlignment;

  const ResetDimension({
    required final Widget child,
    final this.height,
    final this.depth,
    final this.width,
    final this.horizontalAlignment = CrossAxisAlignment.center,
    final Key? key,
  }) : super(key: key, child: child);

  @override
  RenderResetDimension createRenderObject(final BuildContext context) => RenderResetDimension(
        layoutHeight: height,
        layoutWidth: width,
        layoutDepth: depth,
        horizontalAlignment: horizontalAlignment,
      );

  @override
  void updateRenderObject(final BuildContext context, final RenderResetDimension renderObject) => renderObject
    ..layoutHeight = height
    ..layoutDepth = depth
    ..layoutWidth = width
    ..horizontalAlignment = horizontalAlignment;
}

class RenderResetDimension extends RenderShiftedBox {
  RenderResetDimension({
    final RenderBox? child,
    final double? layoutHeight,
    final double? layoutDepth,
    final double? layoutWidth,
    final CrossAxisAlignment horizontalAlignment = CrossAxisAlignment.center,
  })  : _layoutHeight = layoutHeight,
        _layoutDepth = layoutDepth,
        _layoutWidth = layoutWidth,
        _horizontalAlignment = horizontalAlignment,
        super(child);

  double? get layoutHeight => _layoutHeight;
  double? _layoutHeight;

  set layoutHeight(final double? value) {
    if (_layoutHeight != value) {
      _layoutHeight = value;
      markNeedsLayout();
    }
  }

  double? get layoutDepth => _layoutDepth;
  double? _layoutDepth;

  set layoutDepth(final double? value) {
    if (_layoutDepth != value) {
      _layoutDepth = value;
      markNeedsLayout();
    }
  }

  double? get layoutWidth => _layoutWidth;
  double? _layoutWidth;

  set layoutWidth(final double? value) {
    if (_layoutWidth != value) {
      _layoutWidth = value;
      markNeedsLayout();
    }
  }

  CrossAxisAlignment get horizontalAlignment => _horizontalAlignment;
  CrossAxisAlignment _horizontalAlignment;

  set horizontalAlignment(final CrossAxisAlignment value) {
    if (_horizontalAlignment != value) {
      _horizontalAlignment = value;
      markNeedsLayout();
    }
  }

  @override
  double computeMinIntrinsicWidth(final double height) =>
      layoutWidth ?? super.computeMinIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(final double height) =>
      layoutWidth ?? super.computeMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(final double width) {
    if (layoutHeight == null && layoutDepth == null) {
      return super.computeMinIntrinsicHeight(width);
    }
    if (layoutHeight != null && layoutDepth != null) {
      return layoutHeight! + layoutDepth!;
    }
    return 0;
  }

  @override
  double computeMaxIntrinsicHeight(final double width) {
    if (layoutHeight == null && layoutDepth == null) {
      return super.computeMaxIntrinsicHeight(width);
    }
    if (layoutHeight != null && layoutDepth != null) {
      return layoutHeight! + layoutDepth!;
    }
    return 0;
  }

  @override
  double? computeDistanceToActualBaseline(final TextBaseline baseline) =>
      layoutHeight ?? super.computeDistanceToActualBaseline(baseline);

  @override
  Size computeDryLayout(
    final BoxConstraints constraints,
  ) =>
      _computeLayout(constraints);

  @override
  void performLayout() {
    size = _computeLayout(
      constraints,
      dry: false,
    );
  }

  Size _computeLayout(
    final BoxConstraints constraints, {
    final bool dry = true,
  }) {
    final child = this.child!;
    final childSize = renderBoxGetLayoutSize(child, constraints, dry: dry);
    final childHeight = dry ? 0.0 : child.getDistanceToBaseline(TextBaseline.alphabetic)!;
    final childDepth = childSize.height - childHeight;
    final childWidth = childSize.width;
    final height = layoutHeight ?? childHeight;
    final depth = layoutDepth ?? childDepth;
    final width = layoutWidth ?? childWidth;
    double dx = 0.0;
    switch (horizontalAlignment) {
      case CrossAxisAlignment.start:
      case CrossAxisAlignment.stretch:
      case CrossAxisAlignment.baseline:
        break;
      case CrossAxisAlignment.end:
        dx = width - childWidth;
        break;
      case CrossAxisAlignment.center:
        dx = (width - childWidth) / 2;
        break;
    }
    if (!dry) {
      setRenderBoxOffset(
        child,
        Offset(dx, height - childHeight),
      );
    }
    return Size(
      width,
      height + depth,
    );
  }
}

class ResetBaseline extends SingleChildRenderObjectWidget {
  final double height;

  const ResetBaseline({
    required final this.height,
    required final Widget child,
    final Key? key,
  }) : super(
          key: key,
          child: child,
        );

  @override
  RenderResetBaseline createRenderObject(final BuildContext context) => RenderResetBaseline(height: height);

  @override
  void updateRenderObject(final BuildContext context, final RenderResetBaseline renderObject) =>
      renderObject..height = height;
}

class RenderResetBaseline extends RenderProxyBox {
  RenderResetBaseline({required final double height, final RenderBox? child})
      : _height = height,
        super(child);

  double get height => _height;
  double _height;

  set height(final double value) {
    if (_height != value) {
      _height = value;
      markNeedsLayout();
    }
  }

  @override
  double computeDistanceToActualBaseline(final TextBaseline baseline) => height;
}

class ShiftBaseline extends SingleChildRenderObjectWidget {
  const ShiftBaseline({
    required final Widget child,
    final this.relativePos,
    final this.offset = 0,
    final Key? key,
  }) : super(key: key, child: child);

  final double? relativePos;

  final double offset;

  @override
  RenderShiftBaseline createRenderObject(final BuildContext context) =>
      RenderShiftBaseline(relativePos: relativePos, offset: offset);

  @override
  void updateRenderObject(final BuildContext context, final RenderShiftBaseline renderObject) {
    renderObject
      ..relativePos = relativePos
      ..offset = offset;
  }
}

class RenderShiftBaseline extends RenderProxyBox {
  RenderShiftBaseline({
    final RenderBox? child,
    final double? relativePos,
    final double offset = 0,
  })  : _relativePos = relativePos,
        _offset = offset,
        super(child);

  double? get relativePos => _relativePos;
  double? _relativePos;

  set relativePos(final double? value) {
    if (_relativePos != value) {
      _relativePos = value;
      markNeedsLayout();
    }
  }

  double get offset => _offset;
  double _offset;

  set offset(final double value) {
    if (_offset != value) {
      _offset = value;
      markNeedsLayout();
    }
  }

  var _height = 0.0;

  @override
  Size computeDryLayout(final BoxConstraints constraints) => child?.getDryLayout(constraints) ?? Size.zero;

  @override
  double? computeDistanceToActualBaseline(final TextBaseline baseline) {
    if (relativePos != null) {
      return relativePos! * _height + offset;
    }
    if (child != null) {
      // assert(!debugNeedsLayout);
      final childBaselineDistance = child!.getDistanceToActualBaseline(baseline) ?? _height;
      //ignore: avoid_returning_null
      // if (childBaselineDistance == null) return null;
      return childBaselineDistance + offset;
    } else {
      return super.computeDistanceToActualBaseline(baseline);
    }
  }

  @override
  void performLayout() {
    super.performLayout();
    // We have to hack like this to know the height of this object!!!
    _height = size.height;
  }
}
//ignore_for_file: lines_longer_than_80_chars

class VListParentData extends ContainerBoxParentData<RenderBox> {
  BoxConstraints Function(double width)? customCrossSize;

  double trailingMargin = 0.0;

  double hShift = 0.0;

  @override
  String toString() =>
      '${super.toString()}; customCrossSize=${customCrossSize != null}; trailingMargin=$trailingMargin; horizontalShift=$hShift';
}

class VListElement extends ParentDataWidget<VListParentData> {
  final BoxConstraints Function(double width)? customCrossSize;

  final double trailingMargin;

  final double hShift;

  const VListElement({
    required final Widget child,
    final Key? key,
    final this.customCrossSize,
    final this.trailingMargin = 0.0,
    final this.hShift = 0.0,
  }) : super(
          key: key,
          child: child,
        );

  @override
  void applyParentData(
    final RenderObject renderObject,
  ) {
    assert(renderObject.parentData is VListParentData, "");
    final parentData = (renderObject.parentData as VListParentData?)!;
    var needsLayout = false;
    if (parentData.customCrossSize != customCrossSize) {
      parentData.customCrossSize = customCrossSize;
      needsLayout = true;
    }
    if (parentData.trailingMargin != trailingMargin) {
      parentData.trailingMargin = trailingMargin;
      needsLayout = true;
    }
    if (parentData.hShift != hShift) {
      parentData.hShift = hShift;
      needsLayout = true;
    }
    if (needsLayout) {
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(
    final DiagnosticPropertiesBuilder properties,
  ) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('customSize', value: customCrossSize != null, ifTrue: 'using relative size'));
    properties.add(DoubleProperty('trailingMargin', trailingMargin));
    properties.add(DoubleProperty('horizontalShift', hShift));
  }

  @override
  Type get debugTypicalAncestorWidgetClass => VList;
}

/// Vertical List exposes layout width to children, allows arbitrary horizontal
/// shift, and passes baseline information to parent.
///
/// Should be used in combination with [VListElement] and [LayoutBuilder]
///
/// The children are grouped into fixed ([VListElement.customCrossSize] == null
/// ) and custom-sized ([VListElement.customCrossSize] != null).
///
/// Each child is positioned as follows:
///
/// - On the vertical axis, [VList] will stack all children with spacings
/// specified by [VListElement.trailingMargin] (can be negative, 0 if not
/// specified).
/// - On the horizontal axis, [VList] will first position the child according
/// to [crossAxisAlignment], then apply a shift specified by
/// [VListElement.hShift].
///
/// The layout process is as follows:
///
/// - Layout all fixed children with [crossAxisAlignment]
/// - Apply [VListElement.hShift].
/// - Calculate width and height to contain all fixed children, including
/// negative overflow. Use this width to generate constraints for all
/// custom-sized children.
/// - Layout all children with [crossAxisAlignment]
/// - Apply [VListElement.hShift].
/// - Calculate width and height to contain all children. x = 0 will be aligned
/// to the leftmost of children.
///
/// In implementation it is a two-pass layout process and even more efficient
/// than Flutter's Column.
class VList extends MultiChildRenderObjectWidget {
  VList({
    final Key? key,
    final this.textBaseline = TextBaseline.alphabetic,
    final this.baselineReferenceWidgetIndex = 0,
    final this.crossAxisAlignment = CrossAxisAlignment.center,
    final this.textDirection,
    final List<Widget> children = const [],
  }) : super(
          key: key,
          children: children,
        );
  final TextBaseline textBaseline;
  final int baselineReferenceWidgetIndex;

  // final double baselineOffset;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;

  bool get _needTextDirection =>
      crossAxisAlignment == CrossAxisAlignment.start || crossAxisAlignment == CrossAxisAlignment.end;

  @protected
  TextDirection? getEffectiveTextDirection(
    final BuildContext context,
  ) =>
      textDirection ?? (_needTextDirection ? Directionality.of(context) : null);

  @override
  RenderRelativeWidthColumn createRenderObject(
    final BuildContext context,
  ) =>
      RenderRelativeWidthColumn(
        textBaseline: textBaseline,
        baselineReferenceWidgetIndex: baselineReferenceWidgetIndex,
        // baselineOffset: baselineOffset,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: getEffectiveTextDirection(context),
      );

  @override
  void updateRenderObject(
    final BuildContext context,
    final RenderRelativeWidthColumn renderObject,
  ) {
    renderObject
      ..textBaseline = textBaseline
      ..baselineReferenceWidgetIndex = baselineReferenceWidgetIndex
      // ..baselineOffset = baselineOffset
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = getEffectiveTextDirection(context);
  }

  @override
  void debugFillProperties(
    final DiagnosticPropertiesBuilder properties,
  ) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<TextBaseline>('textBaseline', textBaseline, defaultValue: null));
    properties.add(IntProperty('baselineReferenceWidgetNum', baselineReferenceWidgetIndex, defaultValue: 0));
    // properties
    // .add(DoubleProperty('baselineOffset', baselineOffset, defaultValue: 0));
    properties.add(EnumProperty<CrossAxisAlignment>('crossAxisAlignment', crossAxisAlignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
  }
}

class RenderRelativeWidthColumn extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, VListParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, VListParentData>,
        DebugOverflowIndicatorMixin {
  RenderRelativeWidthColumn({
    final List<RenderBox>? children,
    final TextBaseline textBaseline = TextBaseline.alphabetic,
    final int baselineReferenceWidgetIndex = 0,
    final CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    final TextDirection? textDirection = TextDirection.ltr,
  })  : _textBaseline = textBaseline,
        _baselineReferenceWidgetIndex = baselineReferenceWidgetIndex,
        _crossAxisAlignment = crossAxisAlignment,
        _textDirection = textDirection {
    addAll(children);
  }

  TextBaseline get textBaseline => _textBaseline;
  TextBaseline _textBaseline;

  set textBaseline(final TextBaseline value) {
    if (_textBaseline != value) {
      _textBaseline = value;
      markNeedsLayout();
    }
  }

  int get baselineReferenceWidgetIndex => _baselineReferenceWidgetIndex;
  int _baselineReferenceWidgetIndex;

  set baselineReferenceWidgetIndex(final int value) {
    if (_baselineReferenceWidgetIndex != value) {
      _baselineReferenceWidgetIndex = value;
      markNeedsLayout();
    }
  }

  // double get baselineOffset => _baselineOffset;
  // double _baselineOffset;
  // set baselineOffset(double value) {
  //   if (_baselineOffset != value) {
  //     _baselineOffset = value;
  //     markNeedsLayout();
  //   }
  // }

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment;

  set crossAxisAlignment(final CrossAxisAlignment value) {
    if (_crossAxisAlignment != value) {
      _crossAxisAlignment = value;
      markNeedsLayout();
    }
  }

  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;

  set textDirection(final TextDirection? value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  bool get _debugHasNecessaryDirections {
    if (crossAxisAlignment == CrossAxisAlignment.start || crossAxisAlignment == CrossAxisAlignment.end) {
      assert(textDirection != null,
          'Vertical $runtimeType with $crossAxisAlignment has a null textDirection, so the alignment cannot be resolved.');
    }
    return true;
  }

  double? _overflow;

  bool get _hasOverflow => _overflow! > precisionErrorTolerance;

  @override
  void setupParentData(
    final RenderBox child,
  ) {
    if (child.parentData is! VListParentData) {
      child.parentData = VListParentData();
    }
  }

  double _getIntrinsicSize({
    required final Axis sizingDirection,
    required final double extent, // the extent in the direction that isn't the sizing direction
    required final double Function(
      RenderBox child,
      double extent,
    )
        childSize, // a method to find the size in the sizing direction
  }) {
    if (sizingDirection == Axis.vertical) {
      // INTRINSIC MAIN SIZE
      // Intrinsic main size is the smallest size the flex container can take
      // while maintaining the min/max-content contributions of its flex items.
      double inflexibleSpace = 0.0;
      RenderBox? child = firstChild;
      while (child != null) {
        inflexibleSpace += childSize(child, extent);
        final childParentData = (child.parentData as VListParentData?)!;
        child = childParentData.nextSibling;
      }
      return inflexibleSpace;
    } else {
      // INTRINSIC CROSS SIZE
      // Intrinsic cross size is the max of the intrinsic cross sizes of the
      // children, after the flexible children are fit into the available space,
      // with the children sized using their max intrinsic dimensions.
      double maxCrossSize = 0.0;
      RenderBox? child = firstChild;
      while (child != null) {
        final childMainSize = child.getMaxIntrinsicHeight(double.infinity);
        final crossSize = childSize(child, childMainSize);
        maxCrossSize = max(maxCrossSize, crossSize);
        final childParentData = (child.parentData as VListParentData?)!;
        child = childParentData.nextSibling;
      }
      return maxCrossSize;
    }
  }

  @override
  double computeMinIntrinsicWidth(
    final double height,
  ) =>
      _getIntrinsicSize(
        sizingDirection: Axis.horizontal,
        extent: height,
        childSize: (
          final RenderBox child,
          final double extent,
        ) =>
            child.getMinIntrinsicWidth(extent),
      );

  @override
  double computeMaxIntrinsicWidth(
    final double height,
  ) =>
      _getIntrinsicSize(
        sizingDirection: Axis.horizontal,
        extent: height,
        childSize: (
          final RenderBox child,
          final double extent,
        ) =>
            child.getMaxIntrinsicWidth(extent),
      );

  @override
  double computeMinIntrinsicHeight(
    final double width,
  ) =>
      _getIntrinsicSize(
        sizingDirection: Axis.vertical,
        extent: width,
        childSize: (
          final RenderBox child,
          final double extent,
        ) =>
            child.getMinIntrinsicHeight(extent),
      );

  @override
  double computeMaxIntrinsicHeight(
    final double width,
  ) =>
      _getIntrinsicSize(
        sizingDirection: Axis.vertical,
        extent: width,
        childSize: (
          final RenderBox child,
          final double extent,
        ) =>
            child.getMaxIntrinsicHeight(extent),
      );

  double? distanceToBaseline;

  @override
  double? computeDistanceToActualBaseline(
    final TextBaseline baseline,
  ) {
    assert(!debugNeedsLayout, "");
    return distanceToBaseline;
  }

  double getRightMost(
    final CrossAxisAlignment crossAxisAlignment,
    final double width,
  ) {
    switch (crossAxisAlignment) {
      case CrossAxisAlignment.center:
        return width / 2;
      case CrossAxisAlignment.end:
        return 0;
      case CrossAxisAlignment.start:
        return width;
      case CrossAxisAlignment.baseline:
        return width;
      case CrossAxisAlignment.stretch: // TODO
        return width;
    }
  }

  @override
  Size computeDryLayout(
    final BoxConstraints constraints,
  ) =>
      _computeLayout(constraints);

  @override
  void performLayout() {
    size = _computeLayout(constraints, dry: false);
  }

  Size _computeLayout(
    final BoxConstraints constraints, {
    final bool dry = true,
  }) {
    if (!dry) {
      distanceToBaseline = null;
      assert(_debugHasNecessaryDirections, "");
    }
    // First we lay out all fix-sized children
    double rightMost = 0.0;
    double allocatedSize = 0.0; // Sum of the sizes of the non-flexible children.
    double leftMost = 0.0;
    RenderBox? child = firstChild;
    final relativeChildren = <RenderBox>[];
    while (child != null) {
      final childParentData = (child.parentData as VListParentData?)!;
      if (childParentData.customCrossSize != null) {
        relativeChildren.add(child);
      } else {
        final innerConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
        final childSize = renderBoxGetLayoutSize(
          child,
          innerConstraints,
          dry: dry,
        );
        final width = childSize.width;
        final right = getRightMost(crossAxisAlignment, width);
        leftMost = min(leftMost, right - width);
        rightMost = max(rightMost, right);
        allocatedSize += childSize.height + childParentData.trailingMargin;
      }
      assert(child.parentData == childParentData, "");
      child = childParentData.nextSibling;
    }
    final fixedChildrenCrossSize = rightMost - leftMost;
    // Then we lay out custom sized children
    for (final child in relativeChildren) {
      final childParentData = (child.parentData as VListParentData?)!;
      assert(childParentData.customCrossSize != null, "");
      final childConstraints = childParentData.customCrossSize!(fixedChildrenCrossSize);
      final childSize = renderBoxGetLayoutSize(
        child,
        childConstraints,
        dry: dry,
      );
      final width = childSize.width;
      final right = getRightMost(crossAxisAlignment, width);
      leftMost = min(leftMost, right - width);
      rightMost = max(rightMost, right);
      allocatedSize += childSize.height + childParentData.trailingMargin;
    }
    // Calculate size
    final size = constraints.constrain(Size(rightMost - leftMost, allocatedSize));
    if (dry) {
      // We can return the size at this point when doing the dry layout.
      return size;
    }
    final actualSize = size.height;
    final crossSize = size.width;
    final actualSizeDelta = actualSize - allocatedSize;
    _overflow = max(0.0, -actualSizeDelta);
    // Position elements
    int index = 0;
    double childMainPosition = 0.0;
    child = firstChild;
    while (child != null) {
      final childParentData = (child.parentData as VListParentData?)!;
      var childCrossPosition = 0.0;
      switch (crossAxisAlignment) {
        case CrossAxisAlignment.start:
          childCrossPosition = textDirection == TextDirection.ltr
              ? childParentData.hShift - leftMost
              : rightMost - child.size.width + crossSize;
          break;
        case CrossAxisAlignment.end:
          childCrossPosition = textDirection == TextDirection.rtl
              ? childParentData.hShift - leftMost
              : rightMost - child.size.width + crossSize;
          break;
        case CrossAxisAlignment.center:
          childCrossPosition = -child.size.width / 2 - leftMost;
          break;
        case CrossAxisAlignment.stretch:
        case CrossAxisAlignment.baseline:
          childCrossPosition = 0.0;
          break;
      }
      childCrossPosition += childParentData.hShift;
      childParentData.offset = Offset(childCrossPosition, childMainPosition);
      if (index == baselineReferenceWidgetIndex) {
        distanceToBaseline = childMainPosition + child.getDistanceToBaseline(textBaseline)!;
      }
      childMainPosition += child.size.height + childParentData.trailingMargin;
      child = childParentData.nextSibling;
      index++;
    }
    return size;
  }

  @override
  bool hitTestChildren(
    final BoxHitTestResult result, {
    required final Offset position,
  }) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(
    final PaintingContext context,
    final Offset offset,
  ) {
    if (!_hasOverflow) {
      defaultPaint(context, offset);
      return;
    } else {
      if (size.isEmpty) return;
      context.pushClipRect(needsCompositing, offset, Offset.zero & size, defaultPaint);
      assert(() {
        // Only set this if it's null to save work. It gets reset to null if the
        // _direction changes.
        final debugOverflowHints = <DiagnosticsNode>[
          ErrorDescription(
            'The edge of the $runtimeType that is overflowing has been marked '
            'in the rendering with a yellow and black striped pattern. This is '
            'usually caused by the contents being too big for the $runtimeType.',
          ),
          ErrorHint(
            'Consider applying a flex factor (e.g. using an Expanded widget) to '
            'force the children of the $runtimeType to fit within the available '
            'space instead of being sized to their natural size.',
          ),
          ErrorHint(
            'This is considered an error condition because it indicates that there '
            'is content that cannot be seen. If the content is legitimately bigger '
            'than the available space, consider clipping it with a ClipRect widget '
            'before putting it in the flex, or using a scrollable container rather '
            'than a Flex, like a ListView.',
          ),
        ];
        // Simulate a child rect that overflows by the right amount. This child
        // rect is never used for drawing, just for determining the overflow
        // location and amount.
        Rect overflowChildRect;
        overflowChildRect = Rect.fromLTWH(0.0, 0.0, 0.0, size.height + _overflow!);
        paintOverflowIndicator(context, offset, Offset.zero & size, overflowChildRect,
            overflowHints: debugOverflowHints);
        return true;
      }(), "");
    }
  }

  @override
  Rect? describeApproximatePaintClip(
    final RenderObject child,
  ) =>
      _hasOverflow ? Offset.zero & size : null;

  @override
  String toStringShort() {
    var header = super.toStringShort();
    if (_overflow is double && _hasOverflow) header += ' OVERFLOWING';
    return header;
  }

  @override
  void debugFillProperties(
    final DiagnosticPropertiesBuilder properties,
  ) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<CrossAxisAlignment>('crossAxisAlignment', crossAxisAlignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
    properties.add(EnumProperty<TextBaseline>('textBaseline', textBaseline, defaultValue: null));
    properties.add(IntProperty('baselineReferenceWidgetIndex', baselineReferenceWidgetIndex));
  }
}
