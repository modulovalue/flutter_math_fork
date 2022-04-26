import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../render/layout/custom_layout.dart';
import '../../render/layout/shift_baseline.dart';
import '../../utils/iterable_extensions.dart';
import '../../utils/num_extension.dart';
import '../options.dart';
import '../size.dart';
import '../style.dart';
import '../syntax_tree.dart';

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
class MatrixNode extends SlotableNode<EquationRowNode?> {
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

  // TODO rename to .sanitizeInputs
  /// Factory constructor for [MatrixNode] that will sanitize inputs.
  factory MatrixNode({
    required final List<List<EquationRowNode?>> body,
    final double arrayStretch = 1.0,
    final bool hskipBeforeAndAfter = false,
    final bool isSmall = false,
    final List<MatrixColumnAlign> columnAligns = const [],
    final List<MatrixSeparatorStyle> vLines = const [],
    final List<Measurement> rowSpacings = const [],
    final List<MatrixSeparatorStyle> hLines = const [],
  }) {
    final cols = max3(
      body.map((final row) => row.length).maxOrNull ?? 0,
      columnAligns.length,
      vLines.length - 1,
    );
    final sanitizedColumnAligns = columnAligns.extendToByFill(cols, MatrixColumnAlign.center);
    final sanitizedVLines = vLines.extendToByFill(cols + 1, MatrixSeparatorStyle.none);
    final rows = max3(
      body.length,
      rowSpacings.length,
      hLines.length - 1,
    );
    final sanitizedBody = body
        .map((final row) => row.extendToByFill(cols, null))
        .toList(growable: false)
        .extendToByFill(rows, List.filled(cols, null));
    final sanitizedRowSpacing = rowSpacings.extendToByFill(rows, Measurement.zero);
    final sanitizedHLines = hLines.extendToByFill(rows + 1, MatrixSeparatorStyle.none);
    return MatrixNode._(
      rows: rows,
      cols: cols,
      arrayStretch: arrayStretch,
      hskipBeforeAndAfter: hskipBeforeAndAfter,
      isSmall: isSmall,
      columnAligns: sanitizedColumnAligns,
      vLines: sanitizedVLines,
      rowSpacings: sanitizedRowSpacing,
      hLines: sanitizedHLines,
      body: sanitizedBody,
    );
  }

  MatrixNode._({
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
        offset: options.fontMetrics.axisHeight.cssEm.toLpUnder(options),
        child: CustomLayout<int>(
          delegate: MatrixLayoutDelegate(
            rows: rows,
            cols: cols,
            ruleThickness: options.fontMetrics.defaultRuleThickness.cssEm.toLpUnder(options),
            arrayskip: arrayStretch * 12.0.pt.toLpUnder(options),
            rowSpacings: rowSpacings.map((final e) => e.toLpUnder(options)).toList(growable: false),
            hLines: hLines,
            hskipBeforeAndAfter: hskipBeforeAndAfter,
            arraycolsep: isSmall
                ? (5 / 18).cssEm.toLpUnder(options.havingStyle(MathStyle.script))
                : 5.0.pt.toLpUnder(options),
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
  List<MathOptions> computeChildOptions(final MathOptions options) =>
      List.filled(rows * cols, options, growable: false);

  @override
  List<EquationRowNode?> computeChildren() => body.expand((final row) => row).toList(growable: false);

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  bool shouldRebuildWidget(final MathOptions oldOptions, final MathOptions newOptions) => false;

  @override
  MatrixNode updateChildren(final List<EquationRowNode> newChildren) {
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
      MatrixNode(
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
    final childWidths =
        List.generate(cols * rows, (final index) => childrenWidths[index] ?? 0.0, growable: false);

    // Calculate width for each column
    final colWidths = List.filled(cols, 0.0, growable: false);
    for (var i = 0; i < cols; i++) {
      for (var j = 0; j < rows; j++) {
        colWidths[i] = math.max(
          colWidths[i],
          childWidths[j * cols + i],
        );
      }
    }

    // Layout each column
    final colPos = List.filled(cols, 0.0, growable: false);
    final vLinePos = List.filled(cols + 1, 0.0, growable: false);

    var pos = 0.0;
    vLinePos[0] = pos;
    pos += (vLines[0] != MatrixSeparatorStyle.none) ? ruleThickness : 0.0;
    pos += hskipBeforeAndAfter ? arraycolsep : 0.0;

    for (var i = 0; i < cols - 1; i++) {
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
    final childPos = List.generate(rows * cols, (final index) {
      final col = index % cols;
      switch (columnAligns[col]) {
        case MatrixColumnAlign.left:
          return colPos[col];
        case MatrixColumnAlign.right:
          return colPos[col] + colWidths[col] - childWidths[index];
        case MatrixColumnAlign.center:
          return colPos[col] + (colWidths[col] - childWidths[index]) / 2;
      }
    }, growable: false);

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
    final childDepth = List.generate(cols * rows, (final index) {
      final height = childrenBaselines[index];
      return height != null ? childrenHeights[index]! - height : 0.0;
    }, growable: false);

    // Calculate height and depth for each row
    // Minimum height and depth are 0.7 * arrayskip and 0.3 * arrayskip
    final rowHeights = List.filled(rows, 0.7 * arrayskip, growable: false);
    final rowDepth = List.filled(rows, 0.3 * arrayskip, growable: false);
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < cols; j++) {
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
    var pos = 0.0;
    final rowBaselinePos = List.filled(rows, 0.0, growable: false);
    final hLinePos = List.filled(rows + 1, 0.0, growable: false);

    for (var i = 0; i < rows; i++) {
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
    final childPos = List.generate(rows * cols, (final index) {
      final row = index ~/ cols;
      return rowBaselinePos[row] - childHeights[index];
    }, growable: false);

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
  void additionalPaint(final PaintingContext context, final Offset offset) {
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
              paint);
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
                paint);
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
                paint);
          }
          break;
        case MatrixSeparatorStyle.none:
          continue;
      }
    }
  }
}
