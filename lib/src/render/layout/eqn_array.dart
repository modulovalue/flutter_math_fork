import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../../ast/ast_plus.dart';

import '../../utils/extensions.dart';
import '../constants.dart';
import '../utils/render_box_layout.dart';
import '../utils/render_box_offset.dart';
import 'line.dart';

class EqnArrayParentData extends ContainerBoxParentData<RenderBox> {}

class EqnArray extends MultiChildRenderObjectWidget {
  final double ruleThickness;
  final double jotSize;
  final double arrayskip;
  final List<MatrixSeparatorStyle> hlines;
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
    required final List<MatrixSeparatorStyle> hlines,
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

  List<MatrixSeparatorStyle> get hlines => _hlines;
  List<MatrixSeparatorStyle> _hlines;

  set hlines(final List<MatrixSeparatorStyle> value) {
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
      vPos += hlines[index] != MatrixSeparatorStyle.none ? ruleThickness : 0.0;
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
      if (hlines[i] != MatrixSeparatorStyle.none) {
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
