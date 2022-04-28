// ignore_for_file: comment_references

import 'package:flutter/material.dart' show GlobalKey, Widget;
import '../ast/ast.dart';
import '../utils/extensions.dart';
import 'ast.dart';
import 'ast_mixin.dart';
import 'ast_plus.dart';

class TexRedEquationrowImpl with TexRedChildrenMixin {
  @override
  final TexGreenEquationrowImpl greenValue;

  TexRedEquationrowImpl({
    required final this.greenValue,
  });

  @override
  int? get pos => null;

  @override
  TexRed factory(
    final TexGreen greenValue,
    final int pos,
  ) {
    return TexRedImpl(
      greenValue: greenValue,
      pos: pos,
    );
  }
}

class TexRedImpl with TexRedChildrenMixin {
  @override
  final TexGreen greenValue;
  @override
  final int pos;

  TexRedImpl({
    required final this.greenValue,
    required final this.pos,
  });

  @override
  TexRed factory(
    final TexGreen greenValue,
    final int pos,
  ) {
    return TexRedImpl(
      greenValue: greenValue,
      pos: pos,
    );
  }
}

// region nullable

class TexGreenMatrixImpl with TexGreenNullableCapturedMixin implements TexGreenMatrix {
  @override
  final double arrayStretch;
  @override
  final bool hskipBeforeAndAfter;
  @override
  final bool isSmall;
  @override
  final List<TexMatrixColumnAlign> columnAligns;
  @override
  final List<TexMatrixSeparatorStyle> vLines;
  @override
  final List<TexMeasurement> rowSpacings;
  @override
  final List<TexMatrixSeparatorStyle> hLines;
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
  late final cache = TexCache();

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  late final List<TexGreenEquationrow?> children = body
      .expand(
        (final row) => row,
      )
      .toList(
        growable: false,
      );

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
      rowSpacings: this.rowSpacings,
      hLines: this.hLines,
      body: body,
    );
  }

  @override
  Z matchNonleaf<Z>({
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nullable(this);

  @override
  Z matchNonleafNullable<Z>({
    required final Z Function(TexGreenMatrix) matrix,
    required final Z Function(TexGreenMultiscripts) multiscripts,
    required final Z Function(TexGreenNaryoperator) naryoperator,
    required final Z Function(TexGreenSqrt) sqrt,
    required final Z Function(TexGreenStretchyop) stretchyop,
  }) =>
      matrix(this);
}

class TexGreenMultiscriptsImpl with TexGreenNullableCapturedMixin implements TexGreenMultiscripts {
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
  late final cache = TexCache();

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  late final children = [base, sub, sup, presub, presup];

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
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nullable(this);

  @override
  Z matchNonleafNullable<Z>({
    required final Z Function(TexGreenMatrix) matrix,
    required final Z Function(TexGreenMultiscripts) multiscripts,
    required final Z Function(TexGreenNaryoperator) naryoperator,
    required final Z Function(TexGreenSqrt) sqrt,
    required final Z Function(TexGreenStretchyop) stretchyop,
  }) =>
      multiscripts(this);
}

class TexGreenNaryoperatorImpl with TexGreenNullableCapturedMixin implements TexGreenNaryoperator {
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
  late final cache = TexCache();

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  late final children = [lowerLimit, upperLimit, naryand];

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
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nullable(this);

  @override
  Z matchNonleafNullable<Z>({
    required final Z Function(TexGreenMatrix) matrix,
    required final Z Function(TexGreenMultiscripts) multiscripts,
    required final Z Function(TexGreenNaryoperator) naryoperator,
    required final Z Function(TexGreenSqrt) sqrt,
    required final Z Function(TexGreenStretchyop) stretchyop,
  }) =>
      naryoperator(this);
}

class TexGreenSqrtImpl with TexGreenNullableCapturedMixin implements TexGreenSqrt {
  @override
  final TexGreenEquationrow? index;
  @override
  final TexGreenEquationrow base;

  TexGreenSqrtImpl({
    required final this.index,
    required final this.base,
  });

  @override
  late final cache = TexCache();

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  late final children = [index, base];

  TexGreenSqrtImpl updateChildren(
    final List<TexGreenEquationrow?> newChildren,
  ) =>
      TexGreenSqrtImpl(
        index: newChildren[0],
        base: newChildren[1]!,
      );

  @override
  Z matchNonleaf<Z>({
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nullable(this);

  @override
  Z matchNonleafNullable<Z>({
    required final Z Function(TexGreenMatrix) matrix,
    required final Z Function(TexGreenMultiscripts) multiscripts,
    required final Z Function(TexGreenNaryoperator) naryoperator,
    required final Z Function(TexGreenSqrt) sqrt,
    required final Z Function(TexGreenStretchyop) stretchyop,
  }) =>
      sqrt(this);
}

class TexGreenStretchyopImpl with TexGreenNullableCapturedMixin implements TexGreenStretchyop {
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
  late final cache = TexCache();

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  late final children = [above, below];

  TexGreenStretchyopImpl updateChildren(
    final List<TexGreenEquationrow?> newChildren,
  ) =>
      TexGreenStretchyopImpl(
        above: newChildren[0],
        below: newChildren[1],
        symbol: symbol,
      );

  @override
  Z matchNonleaf<Z>({
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nullable(this);

  @override
  Z matchNonleafNullable<Z>({
    required final Z Function(TexGreenMatrix) matrix,
    required final Z Function(TexGreenMultiscripts) multiscripts,
    required final Z Function(TexGreenNaryoperator) naryoperator,
    required final Z Function(TexGreenSqrt) sqrt,
    required final Z Function(TexGreenStretchyop) stretchyop,
  }) =>
      stretchyop(this);
}

// endregion

// region nonnullable

class TexGreenEquationarrayImpl with TexGreenNonnullableCapturedMixin implements TexGreenEquationarray {
  @override
  final double arrayStretch;
  @override
  final bool addJot;
  @override
  final List<TexGreenEquationrow> body;
  @override
  final List<TexMatrixSeparatorStyle> hlines;
  @override
  final List<TexMeasurement> rowSpacings;

  TexGreenEquationarrayImpl({
    required final this.body,
    final this.addJot = false,
    final this.arrayStretch = 1.0,
    final List<TexMatrixSeparatorStyle>? hlines,
    final List<TexMeasurement>? rowSpacings,
  })  : hlines = (hlines ?? []).extendToByFill(body.length + 1, TexMatrixSeparatorStyle.none),
        rowSpacings = (rowSpacings ?? []).extendToByFill(body.length, zeroPt);

  @override
  late final cache = TexCache();

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  List<TexGreenEquationrow> get children => body;

  @override
  TexGreenEquationarrayImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) {
    return TexGreenEquationarrayImpl(
      arrayStretch: this.arrayStretch,
      addJot: this.addJot,
      body: newChildren,
      hlines: this.hlines,
      rowSpacings: this.rowSpacings,
    );
  }

  @override
  Z matchNonleaf<Z>({
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nonnullable(this);

  @override
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
  }) =>
      equationarray(this);
}

class TexGreenOverImpl with TexGreenNonnullableCapturedMixin implements TexGreenOver {
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
  late final cache = TexCache();

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  late final children = [base, above];

  @override
  TexGreenOverImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) {
    return TexGreenOverImpl(
      base: newChildren[0],
      above: newChildren[1],
      stackRel: this.stackRel,
    );
  }

  @override
  Z matchNonleaf<Z>({
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nonnullable(this);

  @override
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
  }) =>
      over(this);
}

class TexGreenUnderImpl with TexGreenNonnullableCapturedMixin implements TexGreenUnder {
  @override
  final TexGreenEquationrow base;
  @override
  final TexGreenEquationrow below;

  TexGreenUnderImpl({
    required final this.base,
    required final this.below,
  });

  @override
  late final cache = TexCache();

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  late final children = [base, below];

  @override
  TexGreenUnderImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      TexGreenUnderImpl(
        base: newChildren[0],
        below: newChildren[1],
      );

  @override
  Z matchNonleaf<Z>({
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nonnullable(this);

  @override
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
  }) =>
      under(this);
}

class TexGreenAccentImpl with TexGreenNonnullableCapturedMixin implements TexGreenAccent {
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
  late final cache = TexCache();

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  late final children = [base];

  @override
  TexGreenAccentImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      TexGreenAccentImpl(
        base: newChildren[0],
        label: this.label,
        isStretchy: this.isStretchy,
        isShifty: this.isShifty,
      );

  @override
  Z matchNonleaf<Z>({
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nonnullable(this);

  @override
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
  }) =>
      accent(this);
}

class TexGreenAccentunderImpl with TexGreenNonnullableCapturedMixin implements TexGreenAccentunder {
  @override
  final TexGreenEquationrow base;
  @override
  final String label;

  TexGreenAccentunderImpl({
    required final this.base,
    required final this.label,
  });

  @override
  late final cache = TexCache();

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  late final children = [
    base,
  ];

  @override
  TexGreenAccentunderImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      TexGreenAccentunderImpl(
        base: newChildren[0],
        label: label,
      );

  @override
  Z matchNonleaf<Z>({
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nonnullable(this);

  @override
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
  }) =>
      accentunder(this);
}

class TexGreenEnclosureImpl with TexGreenNonnullableCapturedMixin implements TexGreenEnclosure {
  @override
  final TexGreenEquationrow base;
  @override
  final bool hasBorder;
  @override
  final TexColor? bordercolor;
  @override
  final TexColor? backgroundcolor;
  @override
  final List<String> notation;
  @override
  final TexMeasurement? horizontalPadding;
  @override
  final TexMeasurement? verticalPadding;

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
  late final cache = TexCache();

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  late final children = [base];

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
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nonnullable(this);

  @override
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
  }) =>
      enclosure(this);
}

class TexGreenFracImpl with TexGreenNonnullableCapturedMixin implements TexGreenFrac {
  @override
  final TexGreenEquationrow numerator;
  @override
  final TexGreenEquationrow denominator;
  @override
  final TexMeasurement? barSize;
  @override
  final bool continued;

  TexGreenFracImpl({
    // this.options,
    required final this.numerator,
    required final this.denominator,
    final this.barSize,
    final this.continued = false,
  });

  @override
  late final cache = TexCache();

  @override
  late final children = [
    numerator,
    denominator,
  ];

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  TexGreenFracImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      TexGreenFracImpl(
        // options: options ?? this.options,
        numerator: newChildren[0],
        denominator: newChildren[1],
        barSize: barSize,
      );

  @override
  Z matchNonleaf<Z>({
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nonnullable(this);

  @override
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
  }) =>
      frac(this);
}

class TexGreenFunctionImpl with TexGreenNonnullableCapturedMixin implements TexGreenFunction {
  @override
  final TexGreenEquationrow functionName;
  @override
  final TexGreenEquationrow argument;

  TexGreenFunctionImpl({
    required final this.functionName,
    required final this.argument,
  });

  @override
  late final cache = TexCache();

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  late final children = [
    functionName,
    argument,
  ];

  @override
  TexGreenFunctionImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      TexGreenFunctionImpl(
        functionName: newChildren[0],
        argument: newChildren[2],
      );

  @override
  Z matchNonleaf<Z>({
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nonnullable(this);

  @override
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
  }) =>
      function(this);
}

class TexGreenLeftrightImpl with TexGreenNonnullableCapturedMixin implements TexGreenLeftright {
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
  late final cache = TexCache();

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  late final children = body;

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
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nonnullable(this);

  @override
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
  }) =>
      leftright(this);
}

class TexGreenRaiseboxImpl with TexGreenNonnullableCapturedMixin implements TexGreenRaisebox {
  @override
  final TexGreenEquationrow body;
  @override
  final TexMeasurement dy;

  TexGreenRaiseboxImpl({
    required final this.body,
    required final this.dy,
  });

  @override
  late final cache = TexCache();

  @override
  List<int> get childPositions => makeCommonChildPositions(this);

  @override
  late final children = [body];

  @override
  TexGreenRaiseboxImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      TexGreenRaiseboxImpl(
        body: newChildren[0],
        dy: dy,
      );

  @override
  Z matchNonleaf<Z>({
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nonnullable(this);

  @override
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
  }) =>
      raisebox(this);
}

// endregion

// region can contain any tex node.

class TexGreenStyleImpl with TexGreenNonleafMixin implements TexGreenStyle {
  @override
  final List<TexGreen> children;
  @override
  final TexOptionsDiff optionsDiff;

  TexGreenStyleImpl({
    required final this.children,
    required final this.optionsDiff,
  });

  @override
  late final cache = TexCache();

  @override
  TexGreenStyleImpl updateChildren(
    final List<TexGreen> newChildren,
  ) =>
      TexGreenStyleImpl(
        children: newChildren,
        optionsDiff: optionsDiff,
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
  Z matchNonleaf<Z>({
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nonnullable(this);

  @override
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
  }) =>
      style(this);
}

class TexGreenEquationrowImpl with TexGreenNonleafMixin implements TexGreenEquationrow {
  @override
  final TexAtomType? overrideType;
  @override
  final List<TexGreen> children;
  @override
  GlobalKey? key;

  TexGreenEquationrowImpl({
    required final this.children,
    final this.overrideType,
  });

  @override
  late final cache = TexCache();

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
  TexGreenEquationrowImpl updateChildren(
    final List<TexGreen> newChildren,
  ) =>
      TexGreenEquationrowImpl(
        overrideType: this.overrideType,
        children: newChildren,
      );

  @override
  TexTextRange range = const TexTextRangeImpl(
    start: 0,
    end: -1,
  );

  @override
  void updatePos(
    final int? pos,
  ) {
    range = texGetRange(this, pos);
  }

  @override
  Z matchNonleaf<Z>({
    required final Z Function(TexGreenNonleafNonnullable) nonnullable,
    required final Z Function(TexGreenNonleafNullable) nullable,
  }) =>
      nonnullable(this);

  @override
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
  }) =>
      equationrow(this);
}

// endregion

// region leafs

abstract class TexGreenTemporaryImpl with TexGreenLeafableMixin implements TexGreenTemporary {
  @override
  TexMode get mode => TexMode.math;

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

class TexGreenTemporaryCr extends TexGreenTemporaryImpl {
  final bool newLine;
  final bool newRow;
  final TexMeasurement? size;

  TexGreenTemporaryCr({
    required final this.newLine,
    required final this.newRow,
    final this.size,
  });
}

class TexGreenTemporaryLeftRightRight extends TexGreenTemporaryImpl {
  final String? delim;

  TexGreenTemporaryLeftRightRight({
    final this.delim,
  });
}

class TexGreenTemporaryMiddle extends TexGreenTemporaryImpl {
  final String? delim;

  TexGreenTemporaryMiddle({
    final this.delim,
  });
}

class TexGreenTemporaryEndEnvironment extends TexGreenTemporaryImpl {
  final String name;

  TexGreenTemporaryEndEnvironment({
    required final this.name,
  });
}

class TexGreenCursorImpl with TexGreenLeafableMixin implements TexGreenCursor {
  @override
  TexMode get mode => TexMode.text;

  @override
  late final TexCache cache = TexCache();

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
  final TexCache cache = TexCache();

  @override
  TexMode get mode => TexMode.math;

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
  final TexMeasurement height;
  @override
  final TexMeasurement width;
  @override
  final TexMeasurement? depth;
  @override
  final TexMeasurement? shift;
  @override
  final int? breakPenalty;
  @override
  final bool fill;
  @override
  final TexMode mode;
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
      : height = zeroPt,
        width = zeroPt,
        shift = zeroPt,
        depth = zeroPt,
        breakPenalty = null,
        fill = true,
        // background = null,
        mode = TexMode.math,
        alignerOrSpacer = true;

  @override
  final TexCache cache = TexCache();

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
  final TexAtomType? overrideAtomType;
  @override
  final TexFontOptions? overrideFont;
  @override
  final TexMode mode;

  TexGreenSymbolImpl({
    required final this.symbol,
    final this.variantForm = false,
    final this.overrideAtomType,
    final this.overrideFont,
    final this.mode = TexMode.math,
  }) : assert(symbol.isNotEmpty, "");

  @override
  final TexCache cache = TexCache();

  @override
  late final TexAtomType atomType = overrideAtomType ??
      getDefaultAtomTypeForSymbol(
        symbol,
        variantForm: variantForm,
        mode: mode,
      );

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

// region other

class TexMeasurementImpl implements TexMeasurement {
  @override
  final double value;
  final _TexUnit unit;

  @override
  bool isMu() => unit == _TexUnit.mu;

  @override
  bool isEm() => unit == _TexUnit.em;

  @override
  bool isEx() => unit == _TexUnit.ex;

  const TexMeasurementImpl({
    required final this.value,
    required final this.unit,
  });

  @override
  double? toPoint() {
    final conv = () {
      switch (unit) {
        case _TexUnit.pt:
          return 1.0;
        case _TexUnit.mm:
          return 7227 / 2540;
        case _TexUnit.cm:
          return 7227 / 254;
        case _TexUnit.inches:
          return 72.27;
        case _TexUnit.bp:
          return 803 / 800;
        case _TexUnit.pc:
          return 12.0;
        case _TexUnit.dd:
          return 1238 / 1157;
        case _TexUnit.cc:
          return 14856 / 1157;
        case _TexUnit.nd:
          return 685 / 642;
        case _TexUnit.nc:
          return 1370 / 107;
        case _TexUnit.sp:
          return 1 / 65536;
        // https://tex.stackexchange.com/a/41371
        case _TexUnit.px:
          return 803 / 800;
        case _TexUnit.ex:
          return null;
        case _TexUnit.em:
          return null;
        case _TexUnit.mu:
          return null;
        // https://api.flutter.dev/flutter/dart-ui/Window/devicePixelRatio.html
        // _Unit.lp: 72.27 / 96,
        case _TexUnit.lp:
          return 72.27 / 160; // This is more accurate
        // _Unit.lp: 72.27 / 200,
        case _TexUnit.cssEm:
          return null;
      }
    }();
    if (conv == null) {
      return null;
    } else {
      return value * conv;
    }
  }

  @override
  double toLpUnder(
    final TexMathOptions options,
  ) {
    if (unit == _TexUnit.lp) {
      return value;
    } else {
      final inPoint = toPoint();
      if (inPoint != null) {
        return value * inPoint / inches(1.0).toPoint()! * options.logicalPpi;
      } else {
        switch (unit) {
          case _TexUnit.cssEm:
            return value * options.fontSize * options.sizeMultiplier;
          case _TexUnit.mu:
            // `mu` units scale with scriptstyle/scriptscriptstyle.
            return value * options.fontSize * options.fontMetrics.cssEmPerMu * options.sizeMultiplier;
          case _TexUnit.ex:
            // `ex` and `em` always refer to the *textstyle* font
            // in the current size.
            return value *
                options.fontSize *
                options.fontMetrics.xHeight2.value *
                options.havingStyle(mathStyleAtLeastText(options.style)).sizeMultiplier;
          case _TexUnit.em:
            return value *
                options.fontSize *
                options.fontMetrics.quad *
                options.havingStyle(mathStyleAtLeastText(options.style)).sizeMultiplier;
          case _TexUnit.pt:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case _TexUnit.mm:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case _TexUnit.cm:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case _TexUnit.inches:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case _TexUnit.bp:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case _TexUnit.pc:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case _TexUnit.dd:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case _TexUnit.cc:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case _TexUnit.nd:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case _TexUnit.nc:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case _TexUnit.sp:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case _TexUnit.px:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
          case _TexUnit.lp:
            throw ArgumentError("Invalid unit: '${unit.toString()}'");
        }
      }
    }
  }

  @override
  double toCssEmUnder(
    final TexMathOptions options,
  ) {
    return toLpUnder(options) / options.fontSize;
  }

  @override
  String toString() => describe();

  @override
  String describe() {
    switch (unit) {
      case _TexUnit.pt:
        return value.toString() + 'pt';
      case _TexUnit.mm:
        return value.toString() + 'mm';
      case _TexUnit.cm:
        return value.toString() + 'cm';
      case _TexUnit.inches:
        return value.toString() + 'inches';
      case _TexUnit.bp:
        return value.toString() + 'bp';
      case _TexUnit.pc:
        return value.toString() + 'pc';
      case _TexUnit.dd:
        return value.toString() + 'dd';
      case _TexUnit.cc:
        return value.toString() + 'cc';
      case _TexUnit.nd:
        return value.toString() + 'nd';
      case _TexUnit.nc:
        return value.toString() + 'nc';
      case _TexUnit.sp:
        return value.toString() + 'sp';
      case _TexUnit.px:
        return value.toString() + 'px';
      case _TexUnit.ex:
        return value.toString() + 'ex';
      case _TexUnit.em:
        return value.toString() + 'em';
      case _TexUnit.mu:
        return value.toString() + 'mu';
      case _TexUnit.lp:
        return value.toString() + 'lp';
      case _TexUnit.cssEm:
        return value.toString() + 'cssEm';
    }
  }
}

enum _TexUnit {
  // https://en.wikibooks.org/wiki/LaTeX/Lengths and
  // https://tex.stackexchange.com/a/8263
  pt, // TeX point
  mm, // millimeter
  cm, // centimeter
  inches, // inch //Avoid name collision
  bp, // big (PostScript) points
  pc, // pica
  dd, // didot
  cc, // cicero (12 didot)
  nd, // new didot
  nc, // new cicero (12 new didot)
  sp, // scaled point (TeX's internal smallest unit)
  px, // \pdfpxdimen defaults to 1 bp in pdfTeX and LuaTeX
  ex, // The height of 'x'
  em, // The width of 'M', which is often the size of the font. ()
  mu,
  lp, // Flutter's logical pixel (96 lp per inch)
  cssEm, // Unit used for font metrics. Analogous to KaTeX's internal unit, but
  // always scale with options.
}

TexMeasurement pt(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.pt);

TexMeasurement mm(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.mm);

TexMeasurement cm(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.cm);

TexMeasurement inches(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.inches);

TexMeasurement bp(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.bp);

TexMeasurement pc(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.pc);

TexMeasurement dd(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.dd);

TexMeasurement cc(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.cc);

TexMeasurement nd(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.nd);

TexMeasurement nc(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.nc);

TexMeasurement sp(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.sp);

TexMeasurement px(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.px);

TexMeasurement ex(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.ex);

TexMeasurement em(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.em);

TexMeasurement mu(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.mu);

TexMeasurement lp(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.lp);

TexMeasurement cssem(final double value) => TexMeasurementImpl(value: value, unit: _TexUnit.cssEm);

class TexMathOptionsImpl implements TexMathOptions {
  @override
  final TexMathStyle style;
  @override
  final TexColor color;
  @override
  final TexMathSize size;
  @override
  final TexMathSize sizeUnderTextStyle;
  @override
  final TexFontOptions? textFontOptions;
  @override
  final TexFontOptions? mathFontOptions;
  @override
  late final double sizeMultiplier = mathSizeSizeMultiplier(
    this.size,
  );
  @override
  late final TexFontMetrics fontMetrics = texGetGlobalMetrics(
    size,
  );
  @override
  final double fontSize;
  @override
  final double logicalPpi;

  TexMathOptionsImpl._({
    required final this.fontSize,
    required final this.logicalPpi,
    required final this.style,
    final this.color = TexColorImpl.black,
    final this.sizeUnderTextStyle = TexMathSize.normalsize,
    final this.textFontOptions,
    final this.mathFontOptions,
  }) : size = mathSizeUnderStyle(
          sizeUnderTextStyle,
          style,
        );

  @override
  TexMathOptions havingStyle(
    final TexMathStyle style,
  ) {
    if (this.style == style) {
      return this;
    } else {
      return this.copyWith(
        style: style,
      );
    }
  }

  @override
  TexMathOptions havingCrampedStyle() {
    if (mathStyleIsCramped(this.style)) {
      return this;
    } else {
      return this.copyWith(
        style: mathStyleCramp(style),
      );
    }
  }

  @override
  TexMathOptions havingSize(
    final TexMathSize size,
  ) {
    if (this.size == size && this.sizeUnderTextStyle == size) {
      return this;
    }
    return this.copyWith(
      style: mathStyleAtLeastText(style),
      sizeUnderTextStyle: size,
    );
  }

  @override
  TexMathOptions havingStyleUnderBaseSize(TexMathStyle? style) {
    // ignore: parameter_assignments
    style = style ?? mathStyleAtLeastText(this.style);
    if (this.sizeUnderTextStyle == TexMathSize.normalsize && this.style == style) {
      return this;
    }
    return this.copyWith(
      style: style,
      sizeUnderTextStyle: TexMathSize.normalsize,
    );
  }

  @override
  TexMathOptions havingBaseSize() {
    if (this.sizeUnderTextStyle == TexMathSize.normalsize) return this;
    return this.copyWith(
      sizeUnderTextStyle: TexMathSize.normalsize,
    );
  }

  @override
  TexMathOptions withColor(
    final TexColor color,
  ) {
    if (this.color == color) return this;
    return this.copyWith(color: color);
  }

  @override
  TexMathOptions withTextFont(
    final TexPartialFontOptions font,
  ) =>
      this.copyWith(
        mathFontOptions: null,
        textFontOptions: (this.textFontOptions ?? const TexFontOptionsImpl()).mergeWith(font),
      );

  @override
  TexMathOptions withMathFont(
    final TexFontOptions font,
  ) {
    if (font == this.mathFontOptions) return this;
    return this.copyWith(mathFontOptions: font);
  }

  @override
  TexMathOptions copyWith({
    final TexMathStyle? style,
    final TexColor? color,
    final TexMathSize? sizeUnderTextStyle,
    final TexFontOptions? textFontOptions,
    final TexFontOptions? mathFontOptions,
  }) =>
      TexMathOptionsImpl._(
        fontSize: this.fontSize,
        logicalPpi: this.logicalPpi,
        style: style ?? this.style,
        color: color ?? this.color,
        sizeUnderTextStyle: sizeUnderTextStyle ?? this.sizeUnderTextStyle,
        textFontOptions: textFontOptions ?? this.textFontOptions,
        mathFontOptions: mathFontOptions ?? this.mathFontOptions,
        // maxSize: maxSize ?? this.maxSize,
        // minRuleThickness: minRuleThickness ?? this.minRuleThickness,
      );

  @override
  TexMathOptions merge(
    final TexOptionsDiff partialOptions,
  ) {
    TexMathOptions res = this;
    if (partialOptions.size != null) {
      res = res.havingSize(partialOptions.size!);
    }
    if (partialOptions.style != null) {
      res = res.havingStyle(partialOptions.style!);
    }
    if (partialOptions.color != null) {
      res = res.withColor(partialOptions.color!);
    }
    // if (partialOptions.phantom == true) {
    //   res = res.withPhantom();
    // }
    if (partialOptions.textFontOptions != null) {
      res = res.withTextFont(partialOptions.textFontOptions!);
    }
    if (partialOptions.mathFontOptions != null) {
      res = res.withMathFont(partialOptions.mathFontOptions!);
    }
    return res;
  }
}

/// Default factory for [TexMathOptions].
///
/// If [fontSize] is null, then [TexMathOptions.defaultFontSize] will be used.
///
/// If [logicalPpi] is null, then it will scale with [fontSize]. The default
/// value for [TexMathOptions.defaultFontSize] is
/// [TexMathOptions.defaultLogicalPpi].
TexMathOptions defaultTexMathOptions({
  final TexMathStyle style = TexMathStyle.display,
  final TexColor color = TexColorImpl.black,
  final TexMathSize sizeUnderTextStyle = TexMathSize.normalsize,
  final TexFontOptions? textFontOptions,
  final TexFontOptions? mathFontOptions,
  final double? fontSize,
  final double? logicalPpi,
}) {
  final effectiveFontSize = fontSize ??
      (() {
        if (logicalPpi == null) {
          return _texDefaultPtPerEm / lp(1.0).toPoint()!;
        } else {
          return texDefaultFontSizeFor(logicalPpi: logicalPpi);
        }
      }());
  final effectiveLogicalPPI = logicalPpi ??
      texDefaultLogicalPpiFor(
        fontSize: effectiveFontSize,
      );
  return TexMathOptionsImpl._(
    fontSize: effectiveFontSize,
    logicalPpi: effectiveLogicalPPI,
    style: style,
    color: color,
    sizeUnderTextStyle: sizeUnderTextStyle,
    mathFontOptions: mathFontOptions,
    textFontOptions: textFontOptions,
  );
}

/// Default options for displayed equations
final texDisplayOptions = TexMathOptionsImpl._(
  fontSize: texDefaultFontSize,
  logicalPpi: texDefaultLogicalPpi,
  style: TexMathStyle.display,
);

/// Default options for in-line equations
final texTextOptions = TexMathOptionsImpl._(
  fontSize: texDefaultFontSize,
  logicalPpi: texDefaultLogicalPpi,
  style: TexMathStyle.text,
);

const _texDefaultLpPerPt = 72.27 / 160;

const _texDefaultPtPerEm = 10;

/// Default value for [logicalPpi] is 160.
///
/// The value 160 comes from the definition of an Android dp.
///
/// Though Flutter provies a reference value for its logical pixel of
/// [38 lp/cm](https://api.flutter.dev/flutter/dart-ui/Window/devicePixelRatio.html).
/// However this value is simply too off from the scale so we use 160 lp/in.
const texDefaultLogicalPpi = 72.27 / _texDefaultLpPerPt;

/// Default logical pixel count for 1 em is 1600/72.27.
///
/// By default 1 em = 10 pt. 1 inch = 72.27 pt.
///
/// See also [TexMathOptions.defaultLogicalPpi].
const texDefaultFontSize = _texDefaultPtPerEm / _texDefaultLpPerPt;

/// Default value for [logicalPpi] when [fontSize] has been set.
double texDefaultLogicalPpiFor({
  required final double fontSize,
}) =>
    fontSize * inches(1.0).toPoint()! / _texDefaultPtPerEm;

/// Default value for [fontSize] when [logicalPpi] has been set.
double texDefaultFontSizeFor({
  required final double logicalPpi,
}) =>
    _texDefaultPtPerEm / inches(1.0).toPoint()! * logicalPpi;

/// Options for font selection.
class TexFontOptionsImpl implements TexFontOptions {
  @override
  final String fontFamily;
  @override
  final TexFontWeight fontWeight;
  @override
  final TexFontStyle fontShape;
  @override
  final List<TexFontOptions> fallback;

  const TexFontOptionsImpl({
    final this.fontFamily = 'Main',
    final this.fontWeight = TexFontWeight.w400,
    final this.fontShape = TexFontStyle.normal,
    final this.fallback = const [],
  });

  @override
  String get fontName =>
      fontFamily +
      '-' +
      () {
        if (fontWeight == TexFontWeight.w700) {
          switch (fontShape) {
            case TexFontStyle.normal:
              return "Bold";
            case TexFontStyle.italic:
              return "BoldItalic";
          }
        } else {
          switch (fontShape) {
            case TexFontStyle.normal:
              return "Regular";
            case TexFontStyle.italic:
              return "Italic";
          }
        }
      }();

  @override
  TexFontOptions copyWith({
    final String? fontFamily,
    final TexFontWeight? fontWeight,
    final TexFontStyle? fontShape,
    final List<TexFontOptions>? fallback,
  }) =>
      TexFontOptionsImpl(
        fontFamily: fontFamily ?? this.fontFamily,
        fontWeight: fontWeight ?? this.fontWeight,
        fontShape: fontShape ?? this.fontShape,
        fallback: fallback ?? this.fallback,
      );

  @override
  TexFontOptions mergeWith(
    final TexPartialFontOptions? value,
  ) {
    if (value == null) {
      return this;
    } else {
      return copyWith(
        fontFamily: value.fontFamily,
        fontWeight: value.fontWeight,
        fontShape: value.fontShape,
      );
    }
  }

  @override
  bool operator ==(
    final Object o,
  ) {
    if (identical(this, o)) return true;
    return o is TexFontOptions &&
        o.fontFamily == fontFamily &&
        o.fontWeight == fontWeight &&
        o.fontShape == fontShape &&
        _listEquals(o.fallback, fallback);
  }

  static bool _listEquals<T>(
    final List<T>? a,
    final List<T>? b,
  ) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(fontFamily.hashCode, fontWeight.hashCode, fontShape.hashCode);
}

TexFontMetrics texFontMetricsFromMap(
  final Map<String, double> map,
) {
  final _slant = map['slant'];
  final _space = map['space'];
  final _stretch = map['stretch'];
  final _shrink = map['shrink'];
  final _xHeight = map['xHeight'];
  final _quad = map['quad'];
  final _extraSpace = map['extraSpace'];
  final _num1 = map['num1'];
  final _num2 = map['num2'];
  final _num3 = map['num3'];
  final _denom1 = map['denom1'];
  final _denom2 = map['denom2'];
  final _sup1 = map['sup1'];
  final _sup2 = map['sup2'];
  final _sup3 = map['sup3'];
  final _sub1 = map['sub1'];
  final _sub2 = map['sub2'];
  final _supDrop = map['supDrop'];
  final _subDrop = map['subDrop'];
  final _delim1 = map['delim1'];
  final _delim2 = map['delim2'];
  final _axisHeight = map['axisHeight'];
  final _defaultRuleThickness = map['defaultRuleThickness'];
  final _bigOpSpacing1 = map['bigOpSpacing1'];
  final _bigOpSpacing2 = map['bigOpSpacing2'];
  final _bigOpSpacing3 = map['bigOpSpacing3'];
  final _bigOpSpacing4 = map['bigOpSpacing4'];
  final _bigOpSpacing5 = map['bigOpSpacing5'];
  final _sqrtRuleThickness = map['sqrtRuleThickness'];
  final _ptPerEm = map['ptPerEm'];
  final _doubleRuleSep = map['doubleRuleSep'];
  final _arrayRuleWidth = map['arrayRuleWidth'];
  final _fboxsep = map['fboxsep'];
  final _fboxrule = map['fboxrule'];
  if (_slant == null) throw Exception("Expected _slant to not be null");
  if (_space == null) throw Exception("Expected _space to not be null");
  if (_stretch == null) throw Exception("Expected _stretch to not be null");
  if (_shrink == null) throw Exception("Expected _shrink to not be null");
  if (_xHeight == null) throw Exception("Expected _xHeight to not be null");
  if (_quad == null) throw Exception("Expected _quad to not be null");
  if (_extraSpace == null) throw Exception("Expected _extraSpace to not be null");
  if (_num1 == null) throw Exception("Expected _num1 to not be null");
  if (_num2 == null) throw Exception("Expected _num2 to not be null");
  if (_num3 == null) throw Exception("Expected _num3 to not be null");
  if (_denom1 == null) throw Exception("Expected _denom1 to not be null");
  if (_denom2 == null) throw Exception("Expected _denom2 to not be null");
  if (_sup1 == null) throw Exception("Expected _sup1 to not be null");
  if (_sup2 == null) throw Exception("Expected _sup2 to not be null");
  if (_sup3 == null) throw Exception("Expected _sup3 to not be null");
  if (_sub1 == null) throw Exception("Expected _sub1 to not be null");
  if (_sub2 == null) throw Exception("Expected _sub2 to not be null");
  if (_supDrop == null) throw Exception("Expected _supDrop to not be null");
  if (_subDrop == null) throw Exception("Expected _subDrop to not be null");
  if (_delim1 == null) throw Exception("Expected _delim1 to not be null");
  if (_delim2 == null) throw Exception("Expected _delim2 to not be null");
  if (_axisHeight == null) throw Exception("Expected _axisHeight to not be null");
  if (_defaultRuleThickness == null) throw Exception("Expected _defaultRuleThickness to not be null");
  if (_bigOpSpacing1 == null) throw Exception("Expected _bigOpSpacing1 to not be null");
  if (_bigOpSpacing2 == null) throw Exception("Expected _bigOpSpacing2 to not be null");
  if (_bigOpSpacing3 == null) throw Exception("Expected _bigOpSpacing3 to not be null");
  if (_bigOpSpacing4 == null) throw Exception("Expected _bigOpSpacing4 to not be null");
  if (_bigOpSpacing5 == null) throw Exception("Expected _bigOpSpacing5 to not be null");
  if (_sqrtRuleThickness == null) throw Exception("Expected _sqrtRuleThickness to not be null");
  if (_ptPerEm == null) throw Exception("Expected _ptPerEm to not be null");
  if (_doubleRuleSep == null) throw Exception("Expected _doubleRuleSep to not be null");
  if (_arrayRuleWidth == null) throw Exception("Expected _arrayRuleWidth to not be null");
  if (_fboxsep == null) throw Exception("Expected _fboxsep to not be null");
  if (_fboxrule == null) throw Exception("Expected _fboxrule to not be null");
  return TexFontMetricsImpl(
    slant: _slant,
    space: _space,
    stretch: _stretch,
    shrink: _shrink,
    xHeight2: cssem(_xHeight),
    quad: _quad,
    extraSpace: _extraSpace,
    num1: _num1,
    num2: _num2,
    num3: _num3,
    denom1: _denom1,
    denom2: _denom2,
    sup1: _sup1,
    sup2: _sup2,
    sup3: _sup3,
    sub1: _sub1,
    sub2: _sub2,
    supDrop: _supDrop,
    subDrop: _subDrop,
    delim1: _delim1,
    delim2: _delim2,
    axisHeight2: cssem(_axisHeight),
    defaultRuleThickness: _defaultRuleThickness,
    bigOpSpacing1: _bigOpSpacing1,
    bigOpSpacing2: _bigOpSpacing2,
    bigOpSpacing3: _bigOpSpacing3,
    bigOpSpacing4: _bigOpSpacing4,
    bigOpSpacing5: _bigOpSpacing5,
    sqrtRuleThickness: _sqrtRuleThickness,
    ptPerEm: _ptPerEm,
    doubleRuleSep: _doubleRuleSep,
    arrayRuleWidth: _arrayRuleWidth,
    fboxsep: _fboxsep,
    fboxrule: _fboxrule,
  );
}

class TexFontMetricsImpl implements TexFontMetrics {
  @override
  double get cssEmPerMu => quad / 18;

  /// sigma1
  @override
  final double slant;

  /// sigma2
  @override
  final double space;

  /// sigma3
  @override
  final double stretch;

  /// sigma4
  @override
  final double shrink;

  /// sigma5
  @override
  final TexMeasurement xHeight2;

  /// sigma6
  @override
  final double quad;

  /// sigma7
  @override
  final double extraSpace;

  /// sigma8
  @override
  final double num1;

  /// sigma9
  @override
  final double num2;

  /// sigma10
  @override
  final double num3;

  /// sigma11
  @override
  final double denom1;

  /// sigma12
  @override
  final double denom2;

  /// sigma13
  @override
  final double sup1;

  /// sigma14
  @override
  final double sup2;

  /// sigma15
  @override
  final double sup3;

  /// sigma16
  @override
  final double sub1;

  /// sigma17
  @override
  final double sub2;

  /// sigma18
  @override
  final double supDrop;

  /// sigma19
  @override
  final double subDrop;

  /// sigma20
  @override
  final double delim1;

  /// sigma21
  @override
  final double delim2;

  /// sigma22
  @override
  final TexMeasurement axisHeight2;

  // These font metrics are extracted from TeX by using tftopl on cmex10.tfm;
  // they correspond to the font parameters of the extension fonts (family 3).
  // See the TeXbook, page 441. In AMSTeX, the extension fonts scale; to
  // match cmex7, we'd use cmex7.tfm values for script and scriptscript
  // values.

  /// xi8; cmex7: 0.049
  @override
  final double defaultRuleThickness;

  /// xi9
  @override
  final double bigOpSpacing1;

  /// xi10
  @override
  final double bigOpSpacing2;

  /// xi11
  @override
  final double bigOpSpacing3;

  /// xi12; cmex7: 0.611
  @override
  final double bigOpSpacing4;

  /// xi13; cmex7: 0.143
  @override
  final double bigOpSpacing5;

  /// The \sqrt rule width is taken from the height of the surd character.
  /// Since we use the same font at all sizes, this thickness doesn't scale.
  @override
  final double sqrtRuleThickness;

  /// This value determines how large a pt is, for metrics which are defined
  /// in terms of pts.
  /// This value is also used in katex.less; if you change it make sure the
  /// values match.
  @override
  final double ptPerEm;

  /// The space between adjacent `|` columns in an array definition. From
  /// `\showthe\doublerulesep` in LaTeX. Equals 2.0 / ptPerEm.
  @override
  final double doubleRuleSep;

  /// The width of separator lines in {array} environments. From
  /// `\showthe\arrayrulewidth` in LaTeX. Equals 0.4 / ptPerEm.
  @override
  final double arrayRuleWidth;

  // Two values from LaTeX source2e:

  /// 3 pt / ptPerEm
  @override
  final double fboxsep;

  /// 0.4 pt / ptPerEm
  @override
  final double fboxrule;

  const TexFontMetricsImpl({
    required final this.slant,
    required final this.space,
    required final this.stretch,
    required final this.shrink,
    required final this.xHeight2,
    required final this.quad,
    required final this.extraSpace,
    required final this.num1,
    required final this.num2,
    required final this.num3,
    required final this.denom1,
    required final this.denom2,
    required final this.sup1,
    required final this.sup2,
    required final this.sup3,
    required final this.sub1,
    required final this.sub2,
    required final this.supDrop,
    required final this.subDrop,
    required final this.delim1,
    required final this.delim2,
    required final this.axisHeight2,
    required final this.defaultRuleThickness,
    required final this.bigOpSpacing1,
    required final this.bigOpSpacing2,
    required final this.bigOpSpacing3,
    required final this.bigOpSpacing4,
    required final this.bigOpSpacing5,
    required final this.sqrtRuleThickness,
    required final this.ptPerEm,
    required final this.doubleRuleSep,
    required final this.arrayRuleWidth,
    required final this.fboxsep,
    required final this.fboxrule,
  });
}

class TexGreenBuildResultImpl implements TexGreenBuildResult {
  @override
  final Widget widget;
  @override
  final TexMathOptions options;
  @override
  final double italic;
  @override
  final double skew;
  @override
  final List<TexGreenBuildResult>? results;

  const TexGreenBuildResultImpl({
    required final this.widget,
    required final this.options,
    final this.italic = 0.0,
    final this.skew = 0.0,
    final this.results,
  });
}

class TexOptionsDiffImpl implements TexOptionsDiff {
  @override
  final TexMathStyle? style;
  @override
  final TexMathSize? size;
  @override
  final TexColor? color;
  @override
  final TexPartialFontOptions? textFontOptions;
  @override
  final TexFontOptions? mathFontOptions;

  const TexOptionsDiffImpl({
    final this.style,
    final this.color,
    final this.size,
    final this.textFontOptions,
    final this.mathFontOptions,
  });

  @override
  bool get isEmpty =>
      style == null && color == null && size == null && textFontOptions == null && mathFontOptions == null;

  @override
  TexOptionsDiff removeStyle() {
    if (style == null) {
      return this;
    } else {
      return TexOptionsDiffImpl(
        color: this.color,
        size: this.size,
        textFontOptions: this.textFontOptions,
        mathFontOptions: this.mathFontOptions,
      );
    }
  }

  @override
  TexOptionsDiff removeMathFont() {
    if (mathFontOptions == null) {
      return this;
    } else {
      return TexOptionsDiffImpl(
        color: this.color,
        size: this.size,
        style: this.style,
        textFontOptions: this.textFontOptions,
      );
    }
  }
}

class TexPartialFontOptionsImpl implements TexPartialFontOptions {
  @override
  final String? fontFamily;
  @override
  final TexFontWeight? fontWeight;
  @override
  final TexFontStyle? fontShape;

  const TexPartialFontOptionsImpl({
    final this.fontFamily,
    final this.fontWeight,
    final this.fontShape,
  });

  @override
  bool operator ==(
    final Object o,
  ) {
    if (identical(this, o)) return true;
    return o is TexPartialFontOptions &&
        o.fontFamily == fontFamily &&
        o.fontWeight == fontWeight &&
        o.fontShape == fontShape;
  }

  @override
  int get hashCode => Object.hash(fontFamily.hashCode, fontWeight.hashCode, fontShape.hashCode);
}

class TexTextRangeImpl implements TexTextRange {
  @override
  final int start;
  @override
  final int end;

  const TexTextRangeImpl({
    required final this.start,
    required final this.end,
  });
}

class TexColorImpl implements TexColor {
  @override
  final int argb;

  static const TexColor black = TexColorImpl(
    argb: 0xFF000000,
  );

  const TexColorImpl({
    required final this.argb,
  });

  const TexColorImpl.fromARGB(
    final int a,
    final int r,
    final int g,
    final int b,
  ) : argb = (((a & 0xff) << 24) | ((r & 0xff) << 16) | ((g & 0xff) << 8) | ((b & 0xff) << 0)) & 0xFFFFFFFF;

  @override
  bool operator ==(
    final Object other,
  ) =>
      identical(this, other) ||
      other is TexColorImpl && runtimeType == other.runtimeType && argb == other.argb;

  @override
  int get hashCode => argb.hashCode;
}

/// This contains metrics regarding fonts and individual symbols. The sigma
/// and xi variables, as well as the metricMap map contain data extracted from
/// TeX, TeX font metrics, and the TTF files. These data are then exposed via
/// the `metrics` variable and the getCharacterMetrics function.

// In TeX, there are actually three sets of dimensions, one for each of
// textstyle (size index 5 and higher: >=9pt), scriptstyle (size index 3 and 4:
// 7-8pt), and scriptscriptstyle (size index 1 and 2: 5-6pt).  These are
// provided in the the arrays below, in that order.
//
// The font metrics are stored in fonts cmsy10, cmsy7, and cmsy5 respsectively.
// This was determined by running the following script:
//
//     latex -interaction=nonstopmode \
//     '\documentclass{article}\usepackage{amsmath}\begin{document}' \
//     '$a$ \expandafter\show\the\textfont2' \
//     '\expandafter\show\the\scriptfont2' \
//     '\expandafter\show\the\scriptscriptfont2' \
//     '\stop'
//
// The metrics themselves were retreived using the following commands:
//
//     tftopl cmsy10
//     tftopl cmsy7
//     tftopl cmsy5
//
// The output of each of these commands is quite lengthy.  The only part we
// care about is the FONTDIMEN section. Each value is measured in EMs.
const texSigmasAndXis = {
  'slant': [0.250, 0.250, 0.250], // sigma1
  'space': [0.000, 0.000, 0.000], // sigma2
  'stretch': [0.000, 0.000, 0.000], // sigma3
  'shrink': [0.000, 0.000, 0.000], // sigma4
  'xHeight': [0.431, 0.431, 0.431], // sigma5
  'quad': [1.000, 1.171, 1.472], // sigma6
  'extraSpace': [0.000, 0.000, 0.000], // sigma7
  'num1': [0.677, 0.732, 0.925], // sigma8
  'num2': [0.394, 0.384, 0.387], // sigma9
  'num3': [0.444, 0.471, 0.504], // sigma10
  'denom1': [0.686, 0.752, 1.025], // sigma11
  'denom2': [0.345, 0.344, 0.532], // sigma12
  'sup1': [0.413, 0.503, 0.504], // sigma13
  'sup2': [0.363, 0.431, 0.404], // sigma14
  'sup3': [0.289, 0.286, 0.294], // sigma15
  'sub1': [0.150, 0.143, 0.200], // sigma16
  'sub2': [0.247, 0.286, 0.400], // sigma17
  'supDrop': [0.386, 0.353, 0.494], // sigma18
  'subDrop': [0.050, 0.071, 0.100], // sigma19
  'delim1': [2.390, 1.700, 1.980], // sigma20
  'delim2': [1.010, 1.157, 1.420], // sigma21
  'axisHeight': [0.250, 0.250, 0.250], // sigma22

  // These font metrics are extracted from TeX by using tftopl on cmex10.tfm;
  // they correspond to the font parameters of the extension fonts (family 3).
  // See the TeXbook, page 441. In AMSTeX, the extension fonts scale; to
  // match cmex7, we'd use cmex7.tfm values for script and scriptscript
  // values.
  'defaultRuleThickness': [0.04, 0.049, 0.049], // xi8; cmex7: 0.049
  'bigOpSpacing1': [0.111, 0.111, 0.111], // xi9
  'bigOpSpacing2': [0.166, 0.166, 0.166], // xi10
  'bigOpSpacing3': [0.2, 0.2, 0.2], // xi11
  'bigOpSpacing4': [0.6, 0.611, 0.611], // xi12; cmex7: 0.611
  'bigOpSpacing5': [0.1, 0.143, 0.143], // xi13; cmex7: 0.143

  // The \sqrt rule width is taken from the height of the surd character.
  // Since we use the same font at all sizes, this thickness doesn't scale.
  'sqrtRuleThickness': [0.04, 0.04, 0.04],

  // This value determines how large a pt is, for metrics which are defined
  // in terms of pts.
  // This value is also used in katex.less; if you change it make sure the
  // values match.
  'ptPerEm': [10.0, 10.0, 10.0],

  // The space between adjacent `|` columns in an array definition. From
  // `\showthe\doublerulesep` in LaTeX. Equals 2.0 / ptPerEm.
  'doubleRuleSep': [0.2, 0.2, 0.2],

  // The width of separator lines in {array} environments. From
  // `\showthe\arrayrulewidth` in LaTeX. Equals 0.4 / ptPerEm.
  'arrayRuleWidth': [0.04, 0.04, 0.04],

  // Two values from LaTeX source2e:
  'fboxsep': [0.3, 0.3, 0.3], //        3 pt / ptPerEm
  'fboxrule': [0.04, 0.04, 0.04], // 0.4 pt / ptPerEm
};

final texTextFontMetrics = texFontMetricsFromMap(
  texSigmasAndXis.map(
    (final key, final value) => MapEntry(key, value[0]),
  ),
);

final texScriptFontMetrics = texFontMetricsFromMap(
  texSigmasAndXis.map(
    (final key, final value) => MapEntry(key, value[1]),
  ),
);

final texScriptscriptFontMetrics = texFontMetricsFromMap(
  texSigmasAndXis.map(
    (final key, final value) => MapEntry(key, value[2]),
  ),
);

const texExtraCharacterMap = {
  // Latin-1
  'Å': 'A',
  'Ç': 'C',
  'Ð': 'D',
  'Þ': 'o',
  'å': 'a',
  'ç': 'c',
  'ð': 'd',
  'þ': 'o',

  // Cyrillic
  'А': 'A',
  'Б': 'B',
  'В': 'B',
  'Г': 'F',
  'Д': 'A',
  'Е': 'E',
  'Ж': 'K',
  'З': '3',
  'И': 'N',
  'Й': 'N',
  'К': 'K',
  'Л': 'N',
  'М': 'M',
  'Н': 'H',
  'О': 'O',
  'П': 'N',
  'Р': 'P',
  'С': 'C',
  'Т': 'T',
  'У': 'y',
  'Ф': 'O',
  'Х': 'X',
  'Ц': 'U',
  'Ч': 'h',
  'Ш': 'W',
  'Щ': 'W',
  'Ъ': 'B',
  'Ы': 'X',
  'Ь': 'B',
  'Э': '3',
  'Ю': 'X',
  'Я': 'R',
  'а': 'a',
  'б': 'b',
  'в': 'a',
  'г': 'r',
  'д': 'y',
  'е': 'e',
  'ж': 'm',
  'з': 'e',
  'и': 'n',
  'й': 'n',
  'к': 'n',
  'л': 'n',
  'м': 'm',
  'н': 'n',
  'о': 'o',
  'п': 'n',
  'р': 'p',
  'с': 'c',
  'т': 'o',
  'у': 'y',
  'ф': 'b',
  'х': 'x',
  'ц': 'n',
  'ч': 'n',
  'ш': 'w',
  'щ': 'w',
  'ъ': 'a',
  'ы': 'm',
  'ь': 'a',
  'э': 'e',
  'ю': 'm',
  'я': 'r',
};

class TexCharacterMetrics {
  final double depth;
  final double height;
  final TexMeasurement italic;
  final double skew;
  final double width;

  TexCharacterMetrics(
    final this.depth,
    final this.height,
    final double italicraw,
    final this.skew,
    final this.width,
  ) : this.italic = cssem(italicraw);
}

final Map<String, Map<int, TexCharacterMetrics>> texMetricsMap = texFontMetricsData;

TexCharacterMetrics? texGetCharacterMetrics({
  required final String character,
  required final String fontName,
  required final TexMode mode,
}) {
  final metricsMapFont = texMetricsMap[fontName];
  if (metricsMapFont == null) {
    throw Exception('Font metrics not found for font: $fontName.');
  }
  final ch = character.codeUnitAt(0);
  if (metricsMapFont.containsKey(ch)) {
    return metricsMapFont[ch];
  }
  final extraCh = texExtraCharacterMap[character[0]]?.codeUnitAt(0);
  if (extraCh != null) {
    return metricsMapFont[ch];
  }
  if (mode == TexMode.text && texSupportedCodepoint(ch)) {
    // We don't typically have font metrics for Asian scripts.
    // But since we support them in text mode, we need to return
    // some sort of metrics.
    // So if the character is in a script we support but we
    // don't have metrics for it, just use the metrics for
    // the Latin capital letter M. This is close enough because
    // we (currently) only care about the height of the glpyh
    // not its width.
    return metricsMapFont[77]; // 77 is the charcode for 'M'
  }
  return null;
}

TexFontMetrics texGetGlobalMetrics(
  final TexMathSize size,
) {
  switch (size) {
    case TexMathSize.tiny:
    case TexMathSize.size2:
      return texScriptscriptFontMetrics;
    case TexMathSize.scriptsize:
    case TexMathSize.footnotesize:
      return texScriptFontMetrics;
    case TexMathSize.small:
    case TexMathSize.normalsize:
    case TexMathSize.large:
    case TexMathSize.Large:
    case TexMathSize.LARGE:
    case TexMathSize.huge:
    case TexMathSize.HUGE:
      return texTextFontMetrics;
  }
}

// Replace \[([-0-9e.]*), ([-0-9e.]*), ([-0-9e.]*), ([-0-9e.]*), ([-0-9e.]*)\]
// with CharacterMetrics($1, $2, $3, $4, $5)

Map<String, Map<int, TexCharacterMetrics>> texFontMetricsData = {
  "AMS-Regular": {
    65: TexCharacterMetrics(0, 0.68889, 0, 0, 0.72222),
    66: TexCharacterMetrics(0, 0.68889, 0, 0, 0.66667),
    67: TexCharacterMetrics(0, 0.68889, 0, 0, 0.72222),
    68: TexCharacterMetrics(0, 0.68889, 0, 0, 0.72222),
    69: TexCharacterMetrics(0, 0.68889, 0, 0, 0.66667),
    70: TexCharacterMetrics(0, 0.68889, 0, 0, 0.61111),
    71: TexCharacterMetrics(0, 0.68889, 0, 0, 0.77778),
    72: TexCharacterMetrics(0, 0.68889, 0, 0, 0.77778),
    73: TexCharacterMetrics(0, 0.68889, 0, 0, 0.38889),
    74: TexCharacterMetrics(0.16667, 0.68889, 0, 0, 0.5),
    75: TexCharacterMetrics(0, 0.68889, 0, 0, 0.77778),
    76: TexCharacterMetrics(0, 0.68889, 0, 0, 0.66667),
    77: TexCharacterMetrics(0, 0.68889, 0, 0, 0.94445),
    78: TexCharacterMetrics(0, 0.68889, 0, 0, 0.72222),
    79: TexCharacterMetrics(0.16667, 0.68889, 0, 0, 0.77778),
    80: TexCharacterMetrics(0, 0.68889, 0, 0, 0.61111),
    81: TexCharacterMetrics(0.16667, 0.68889, 0, 0, 0.77778),
    82: TexCharacterMetrics(0, 0.68889, 0, 0, 0.72222),
    83: TexCharacterMetrics(0, 0.68889, 0, 0, 0.55556),
    84: TexCharacterMetrics(0, 0.68889, 0, 0, 0.66667),
    85: TexCharacterMetrics(0, 0.68889, 0, 0, 0.72222),
    86: TexCharacterMetrics(0, 0.68889, 0, 0, 0.72222),
    87: TexCharacterMetrics(0, 0.68889, 0, 0, 1.0),
    88: TexCharacterMetrics(0, 0.68889, 0, 0, 0.72222),
    89: TexCharacterMetrics(0, 0.68889, 0, 0, 0.72222),
    90: TexCharacterMetrics(0, 0.68889, 0, 0, 0.66667),
    107: TexCharacterMetrics(0, 0.68889, 0, 0, 0.55556),
    165: TexCharacterMetrics(0, 0.675, 0.025, 0, 0.75),
    174: TexCharacterMetrics(0.15559, 0.69224, 0, 0, 0.94666),
    240: TexCharacterMetrics(0, 0.68889, 0, 0, 0.55556),
    295: TexCharacterMetrics(0, 0.68889, 0, 0, 0.54028),
    710: TexCharacterMetrics(0, 0.825, 0, 0, 2.33334),
    732: TexCharacterMetrics(0, 0.9, 0, 0, 2.33334),
    770: TexCharacterMetrics(0, 0.825, 0, 0, 2.33334),
    771: TexCharacterMetrics(0, 0.9, 0, 0, 2.33334),
    989: TexCharacterMetrics(0.08167, 0.58167, 0, 0, 0.77778),
    1008: TexCharacterMetrics(0, 0.43056, 0.04028, 0, 0.66667),
    8245: TexCharacterMetrics(0, 0.54986, 0, 0, 0.275),
    8463: TexCharacterMetrics(0, 0.68889, 0, 0, 0.54028),
    8487: TexCharacterMetrics(0, 0.68889, 0, 0, 0.72222),
    8498: TexCharacterMetrics(0, 0.68889, 0, 0, 0.55556),
    8502: TexCharacterMetrics(0, 0.68889, 0, 0, 0.66667),
    8503: TexCharacterMetrics(0, 0.68889, 0, 0, 0.44445),
    8504: TexCharacterMetrics(0, 0.68889, 0, 0, 0.66667),
    8513: TexCharacterMetrics(0, 0.68889, 0, 0, 0.63889),
    8592: TexCharacterMetrics(-0.03598, 0.46402, 0, 0, 0.5),
    8594: TexCharacterMetrics(-0.03598, 0.46402, 0, 0, 0.5),
    8602: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8603: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8606: TexCharacterMetrics(0.01354, 0.52239, 0, 0, 1.0),
    8608: TexCharacterMetrics(0.01354, 0.52239, 0, 0, 1.0),
    8610: TexCharacterMetrics(0.01354, 0.52239, 0, 0, 1.11111),
    8611: TexCharacterMetrics(0.01354, 0.52239, 0, 0, 1.11111),
    8619: TexCharacterMetrics(0, 0.54986, 0, 0, 1.0),
    8620: TexCharacterMetrics(0, 0.54986, 0, 0, 1.0),
    8621: TexCharacterMetrics(-0.13313, 0.37788, 0, 0, 1.38889),
    8622: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8624: TexCharacterMetrics(0, 0.69224, 0, 0, 0.5),
    8625: TexCharacterMetrics(0, 0.69224, 0, 0, 0.5),
    8630: TexCharacterMetrics(0, 0.43056, 0, 0, 1.0),
    8631: TexCharacterMetrics(0, 0.43056, 0, 0, 1.0),
    8634: TexCharacterMetrics(0.08198, 0.58198, 0, 0, 0.77778),
    8635: TexCharacterMetrics(0.08198, 0.58198, 0, 0, 0.77778),
    8638: TexCharacterMetrics(0.19444, 0.69224, 0, 0, 0.41667),
    8639: TexCharacterMetrics(0.19444, 0.69224, 0, 0, 0.41667),
    8642: TexCharacterMetrics(0.19444, 0.69224, 0, 0, 0.41667),
    8643: TexCharacterMetrics(0.19444, 0.69224, 0, 0, 0.41667),
    8644: TexCharacterMetrics(0.1808, 0.675, 0, 0, 1.0),
    8646: TexCharacterMetrics(0.1808, 0.675, 0, 0, 1.0),
    8647: TexCharacterMetrics(0.1808, 0.675, 0, 0, 1.0),
    8648: TexCharacterMetrics(0.19444, 0.69224, 0, 0, 0.83334),
    8649: TexCharacterMetrics(0.1808, 0.675, 0, 0, 1.0),
    8650: TexCharacterMetrics(0.19444, 0.69224, 0, 0, 0.83334),
    8651: TexCharacterMetrics(0.01354, 0.52239, 0, 0, 1.0),
    8652: TexCharacterMetrics(0.01354, 0.52239, 0, 0, 1.0),
    8653: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8654: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8655: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8666: TexCharacterMetrics(0.13667, 0.63667, 0, 0, 1.0),
    8667: TexCharacterMetrics(0.13667, 0.63667, 0, 0, 1.0),
    8669: TexCharacterMetrics(-0.13313, 0.37788, 0, 0, 1.0),
    8672: TexCharacterMetrics(-0.064, 0.437, 0, 0, 1.334),
    8674: TexCharacterMetrics(-0.064, 0.437, 0, 0, 1.334),
    8705: TexCharacterMetrics(0, 0.825, 0, 0, 0.5),
    8708: TexCharacterMetrics(0, 0.68889, 0, 0, 0.55556),
    8709: TexCharacterMetrics(0.08167, 0.58167, 0, 0, 0.77778),
    8717: TexCharacterMetrics(0, 0.43056, 0, 0, 0.42917),
    8722: TexCharacterMetrics(-0.03598, 0.46402, 0, 0, 0.5),
    8724: TexCharacterMetrics(0.08198, 0.69224, 0, 0, 0.77778),
    8726: TexCharacterMetrics(0.08167, 0.58167, 0, 0, 0.77778),
    8733: TexCharacterMetrics(0, 0.69224, 0, 0, 0.77778),
    8736: TexCharacterMetrics(0, 0.69224, 0, 0, 0.72222),
    8737: TexCharacterMetrics(0, 0.69224, 0, 0, 0.72222),
    8738: TexCharacterMetrics(0.03517, 0.52239, 0, 0, 0.72222),
    8739: TexCharacterMetrics(0.08167, 0.58167, 0, 0, 0.22222),
    8740: TexCharacterMetrics(0.25142, 0.74111, 0, 0, 0.27778),
    8741: TexCharacterMetrics(0.08167, 0.58167, 0, 0, 0.38889),
    8742: TexCharacterMetrics(0.25142, 0.74111, 0, 0, 0.5),
    8756: TexCharacterMetrics(0, 0.69224, 0, 0, 0.66667),
    8757: TexCharacterMetrics(0, 0.69224, 0, 0, 0.66667),
    8764: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 0.77778),
    8765: TexCharacterMetrics(-0.13313, 0.37788, 0, 0, 0.77778),
    8769: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 0.77778),
    8770: TexCharacterMetrics(-0.03625, 0.46375, 0, 0, 0.77778),
    8774: TexCharacterMetrics(0.30274, 0.79383, 0, 0, 0.77778),
    8776: TexCharacterMetrics(-0.01688, 0.48312, 0, 0, 0.77778),
    8778: TexCharacterMetrics(0.08167, 0.58167, 0, 0, 0.77778),
    8782: TexCharacterMetrics(0.06062, 0.54986, 0, 0, 0.77778),
    8783: TexCharacterMetrics(0.06062, 0.54986, 0, 0, 0.77778),
    8785: TexCharacterMetrics(0.08198, 0.58198, 0, 0, 0.77778),
    8786: TexCharacterMetrics(0.08198, 0.58198, 0, 0, 0.77778),
    8787: TexCharacterMetrics(0.08198, 0.58198, 0, 0, 0.77778),
    8790: TexCharacterMetrics(0, 0.69224, 0, 0, 0.77778),
    8791: TexCharacterMetrics(0.22958, 0.72958, 0, 0, 0.77778),
    8796: TexCharacterMetrics(0.08198, 0.91667, 0, 0, 0.77778),
    8806: TexCharacterMetrics(0.25583, 0.75583, 0, 0, 0.77778),
    8807: TexCharacterMetrics(0.25583, 0.75583, 0, 0, 0.77778),
    8808: TexCharacterMetrics(0.25142, 0.75726, 0, 0, 0.77778),
    8809: TexCharacterMetrics(0.25142, 0.75726, 0, 0, 0.77778),
    8812: TexCharacterMetrics(0.25583, 0.75583, 0, 0, 0.5),
    8814: TexCharacterMetrics(0.20576, 0.70576, 0, 0, 0.77778),
    8815: TexCharacterMetrics(0.20576, 0.70576, 0, 0, 0.77778),
    8816: TexCharacterMetrics(0.30274, 0.79383, 0, 0, 0.77778),
    8817: TexCharacterMetrics(0.30274, 0.79383, 0, 0, 0.77778),
    8818: TexCharacterMetrics(0.22958, 0.72958, 0, 0, 0.77778),
    8819: TexCharacterMetrics(0.22958, 0.72958, 0, 0, 0.77778),
    8822: TexCharacterMetrics(0.1808, 0.675, 0, 0, 0.77778),
    8823: TexCharacterMetrics(0.1808, 0.675, 0, 0, 0.77778),
    8828: TexCharacterMetrics(0.13667, 0.63667, 0, 0, 0.77778),
    8829: TexCharacterMetrics(0.13667, 0.63667, 0, 0, 0.77778),
    8830: TexCharacterMetrics(0.22958, 0.72958, 0, 0, 0.77778),
    8831: TexCharacterMetrics(0.22958, 0.72958, 0, 0, 0.77778),
    8832: TexCharacterMetrics(0.20576, 0.70576, 0, 0, 0.77778),
    8833: TexCharacterMetrics(0.20576, 0.70576, 0, 0, 0.77778),
    8840: TexCharacterMetrics(0.30274, 0.79383, 0, 0, 0.77778),
    8841: TexCharacterMetrics(0.30274, 0.79383, 0, 0, 0.77778),
    8842: TexCharacterMetrics(0.13597, 0.63597, 0, 0, 0.77778),
    8843: TexCharacterMetrics(0.13597, 0.63597, 0, 0, 0.77778),
    8847: TexCharacterMetrics(0.03517, 0.54986, 0, 0, 0.77778),
    8848: TexCharacterMetrics(0.03517, 0.54986, 0, 0, 0.77778),
    8858: TexCharacterMetrics(0.08198, 0.58198, 0, 0, 0.77778),
    8859: TexCharacterMetrics(0.08198, 0.58198, 0, 0, 0.77778),
    8861: TexCharacterMetrics(0.08198, 0.58198, 0, 0, 0.77778),
    8862: TexCharacterMetrics(0, 0.675, 0, 0, 0.77778),
    8863: TexCharacterMetrics(0, 0.675, 0, 0, 0.77778),
    8864: TexCharacterMetrics(0, 0.675, 0, 0, 0.77778),
    8865: TexCharacterMetrics(0, 0.675, 0, 0, 0.77778),
    8872: TexCharacterMetrics(0, 0.69224, 0, 0, 0.61111),
    8873: TexCharacterMetrics(0, 0.69224, 0, 0, 0.72222),
    8874: TexCharacterMetrics(0, 0.69224, 0, 0, 0.88889),
    8876: TexCharacterMetrics(0, 0.68889, 0, 0, 0.61111),
    8877: TexCharacterMetrics(0, 0.68889, 0, 0, 0.61111),
    8878: TexCharacterMetrics(0, 0.68889, 0, 0, 0.72222),
    8879: TexCharacterMetrics(0, 0.68889, 0, 0, 0.72222),
    8882: TexCharacterMetrics(0.03517, 0.54986, 0, 0, 0.77778),
    8883: TexCharacterMetrics(0.03517, 0.54986, 0, 0, 0.77778),
    8884: TexCharacterMetrics(0.13667, 0.63667, 0, 0, 0.77778),
    8885: TexCharacterMetrics(0.13667, 0.63667, 0, 0, 0.77778),
    8888: TexCharacterMetrics(0, 0.54986, 0, 0, 1.11111),
    8890: TexCharacterMetrics(0.19444, 0.43056, 0, 0, 0.55556),
    8891: TexCharacterMetrics(0.19444, 0.69224, 0, 0, 0.61111),
    8892: TexCharacterMetrics(0.19444, 0.69224, 0, 0, 0.61111),
    8901: TexCharacterMetrics(0, 0.54986, 0, 0, 0.27778),
    8903: TexCharacterMetrics(0.08167, 0.58167, 0, 0, 0.77778),
    8905: TexCharacterMetrics(0.08167, 0.58167, 0, 0, 0.77778),
    8906: TexCharacterMetrics(0.08167, 0.58167, 0, 0, 0.77778),
    8907: TexCharacterMetrics(0, 0.69224, 0, 0, 0.77778),
    8908: TexCharacterMetrics(0, 0.69224, 0, 0, 0.77778),
    8909: TexCharacterMetrics(-0.03598, 0.46402, 0, 0, 0.77778),
    8910: TexCharacterMetrics(0, 0.54986, 0, 0, 0.76042),
    8911: TexCharacterMetrics(0, 0.54986, 0, 0, 0.76042),
    8912: TexCharacterMetrics(0.03517, 0.54986, 0, 0, 0.77778),
    8913: TexCharacterMetrics(0.03517, 0.54986, 0, 0, 0.77778),
    8914: TexCharacterMetrics(0, 0.54986, 0, 0, 0.66667),
    8915: TexCharacterMetrics(0, 0.54986, 0, 0, 0.66667),
    8916: TexCharacterMetrics(0, 0.69224, 0, 0, 0.66667),
    8918: TexCharacterMetrics(0.0391, 0.5391, 0, 0, 0.77778),
    8919: TexCharacterMetrics(0.0391, 0.5391, 0, 0, 0.77778),
    8920: TexCharacterMetrics(0.03517, 0.54986, 0, 0, 1.33334),
    8921: TexCharacterMetrics(0.03517, 0.54986, 0, 0, 1.33334),
    8922: TexCharacterMetrics(0.38569, 0.88569, 0, 0, 0.77778),
    8923: TexCharacterMetrics(0.38569, 0.88569, 0, 0, 0.77778),
    8926: TexCharacterMetrics(0.13667, 0.63667, 0, 0, 0.77778),
    8927: TexCharacterMetrics(0.13667, 0.63667, 0, 0, 0.77778),
    8928: TexCharacterMetrics(0.30274, 0.79383, 0, 0, 0.77778),
    8929: TexCharacterMetrics(0.30274, 0.79383, 0, 0, 0.77778),
    8934: TexCharacterMetrics(0.23222, 0.74111, 0, 0, 0.77778),
    8935: TexCharacterMetrics(0.23222, 0.74111, 0, 0, 0.77778),
    8936: TexCharacterMetrics(0.23222, 0.74111, 0, 0, 0.77778),
    8937: TexCharacterMetrics(0.23222, 0.74111, 0, 0, 0.77778),
    8938: TexCharacterMetrics(0.20576, 0.70576, 0, 0, 0.77778),
    8939: TexCharacterMetrics(0.20576, 0.70576, 0, 0, 0.77778),
    8940: TexCharacterMetrics(0.30274, 0.79383, 0, 0, 0.77778),
    8941: TexCharacterMetrics(0.30274, 0.79383, 0, 0, 0.77778),
    8994: TexCharacterMetrics(0.19444, 0.69224, 0, 0, 0.77778),
    8995: TexCharacterMetrics(0.19444, 0.69224, 0, 0, 0.77778),
    9416: TexCharacterMetrics(0.15559, 0.69224, 0, 0, 0.90222),
    9484: TexCharacterMetrics(0, 0.69224, 0, 0, 0.5),
    9488: TexCharacterMetrics(0, 0.69224, 0, 0, 0.5),
    9492: TexCharacterMetrics(0, 0.37788, 0, 0, 0.5),
    9496: TexCharacterMetrics(0, 0.37788, 0, 0, 0.5),
    9585: TexCharacterMetrics(0.19444, 0.68889, 0, 0, 0.88889),
    9586: TexCharacterMetrics(0.19444, 0.74111, 0, 0, 0.88889),
    9632: TexCharacterMetrics(0, 0.675, 0, 0, 0.77778),
    9633: TexCharacterMetrics(0, 0.675, 0, 0, 0.77778),
    9650: TexCharacterMetrics(0, 0.54986, 0, 0, 0.72222),
    9651: TexCharacterMetrics(0, 0.54986, 0, 0, 0.72222),
    9654: TexCharacterMetrics(0.03517, 0.54986, 0, 0, 0.77778),
    9660: TexCharacterMetrics(0, 0.54986, 0, 0, 0.72222),
    9661: TexCharacterMetrics(0, 0.54986, 0, 0, 0.72222),
    9664: TexCharacterMetrics(0.03517, 0.54986, 0, 0, 0.77778),
    9674: TexCharacterMetrics(0.11111, 0.69224, 0, 0, 0.66667),
    9733: TexCharacterMetrics(0.19444, 0.69224, 0, 0, 0.94445),
    10003: TexCharacterMetrics(0, 0.69224, 0, 0, 0.83334),
    10016: TexCharacterMetrics(0, 0.69224, 0, 0, 0.83334),
    10731: TexCharacterMetrics(0.11111, 0.69224, 0, 0, 0.66667),
    10846: TexCharacterMetrics(0.19444, 0.75583, 0, 0, 0.61111),
    10877: TexCharacterMetrics(0.13667, 0.63667, 0, 0, 0.77778),
    10878: TexCharacterMetrics(0.13667, 0.63667, 0, 0, 0.77778),
    10885: TexCharacterMetrics(0.25583, 0.75583, 0, 0, 0.77778),
    10886: TexCharacterMetrics(0.25583, 0.75583, 0, 0, 0.77778),
    10887: TexCharacterMetrics(0.13597, 0.63597, 0, 0, 0.77778),
    10888: TexCharacterMetrics(0.13597, 0.63597, 0, 0, 0.77778),
    10889: TexCharacterMetrics(0.26167, 0.75726, 0, 0, 0.77778),
    10890: TexCharacterMetrics(0.26167, 0.75726, 0, 0, 0.77778),
    10891: TexCharacterMetrics(0.48256, 0.98256, 0, 0, 0.77778),
    10892: TexCharacterMetrics(0.48256, 0.98256, 0, 0, 0.77778),
    10901: TexCharacterMetrics(0.13667, 0.63667, 0, 0, 0.77778),
    10902: TexCharacterMetrics(0.13667, 0.63667, 0, 0, 0.77778),
    10933: TexCharacterMetrics(0.25142, 0.75726, 0, 0, 0.77778),
    10934: TexCharacterMetrics(0.25142, 0.75726, 0, 0, 0.77778),
    10935: TexCharacterMetrics(0.26167, 0.75726, 0, 0, 0.77778),
    10936: TexCharacterMetrics(0.26167, 0.75726, 0, 0, 0.77778),
    10937: TexCharacterMetrics(0.26167, 0.75726, 0, 0, 0.77778),
    10938: TexCharacterMetrics(0.26167, 0.75726, 0, 0, 0.77778),
    10949: TexCharacterMetrics(0.25583, 0.75583, 0, 0, 0.77778),
    10950: TexCharacterMetrics(0.25583, 0.75583, 0, 0, 0.77778),
    10955: TexCharacterMetrics(0.28481, 0.79383, 0, 0, 0.77778),
    10956: TexCharacterMetrics(0.28481, 0.79383, 0, 0, 0.77778),
    57350: TexCharacterMetrics(0.08167, 0.58167, 0, 0, 0.22222),
    57351: TexCharacterMetrics(0.08167, 0.58167, 0, 0, 0.38889),
    57352: TexCharacterMetrics(0.08167, 0.58167, 0, 0, 0.77778),
    57353: TexCharacterMetrics(0, 0.43056, 0.04028, 0, 0.66667),
    57356: TexCharacterMetrics(0.25142, 0.75726, 0, 0, 0.77778),
    57357: TexCharacterMetrics(0.25142, 0.75726, 0, 0, 0.77778),
    57358: TexCharacterMetrics(0.41951, 0.91951, 0, 0, 0.77778),
    57359: TexCharacterMetrics(0.30274, 0.79383, 0, 0, 0.77778),
    57360: TexCharacterMetrics(0.30274, 0.79383, 0, 0, 0.77778),
    57361: TexCharacterMetrics(0.41951, 0.91951, 0, 0, 0.77778),
    57366: TexCharacterMetrics(0.25142, 0.75726, 0, 0, 0.77778),
    57367: TexCharacterMetrics(0.25142, 0.75726, 0, 0, 0.77778),
    57368: TexCharacterMetrics(0.25142, 0.75726, 0, 0, 0.77778),
    57369: TexCharacterMetrics(0.25142, 0.75726, 0, 0, 0.77778),
    57370: TexCharacterMetrics(0.13597, 0.63597, 0, 0, 0.77778),
    57371: TexCharacterMetrics(0.13597, 0.63597, 0, 0, 0.77778),
  },
  "Caligraphic-Regular": {
    48: TexCharacterMetrics(0, 0.43056, 0, 0, 0.5),
    49: TexCharacterMetrics(0, 0.43056, 0, 0, 0.5),
    50: TexCharacterMetrics(0, 0.43056, 0, 0, 0.5),
    51: TexCharacterMetrics(0.19444, 0.43056, 0, 0, 0.5),
    52: TexCharacterMetrics(0.19444, 0.43056, 0, 0, 0.5),
    53: TexCharacterMetrics(0.19444, 0.43056, 0, 0, 0.5),
    54: TexCharacterMetrics(0, 0.64444, 0, 0, 0.5),
    55: TexCharacterMetrics(0.19444, 0.43056, 0, 0, 0.5),
    56: TexCharacterMetrics(0, 0.64444, 0, 0, 0.5),
    57: TexCharacterMetrics(0.19444, 0.43056, 0, 0, 0.5),
    65: TexCharacterMetrics(0, 0.68333, 0, 0.19445, 0.79847),
    66: TexCharacterMetrics(0, 0.68333, 0.03041, 0.13889, 0.65681),
    67: TexCharacterMetrics(0, 0.68333, 0.05834, 0.13889, 0.52653),
    68: TexCharacterMetrics(0, 0.68333, 0.02778, 0.08334, 0.77139),
    69: TexCharacterMetrics(0, 0.68333, 0.08944, 0.11111, 0.52778),
    70: TexCharacterMetrics(0, 0.68333, 0.09931, 0.11111, 0.71875),
    71: TexCharacterMetrics(0.09722, 0.68333, 0.0593, 0.11111, 0.59487),
    72: TexCharacterMetrics(0, 0.68333, 0.00965, 0.11111, 0.84452),
    73: TexCharacterMetrics(0, 0.68333, 0.07382, 0, 0.54452),
    74: TexCharacterMetrics(0.09722, 0.68333, 0.18472, 0.16667, 0.67778),
    75: TexCharacterMetrics(0, 0.68333, 0.01445, 0.05556, 0.76195),
    76: TexCharacterMetrics(0, 0.68333, 0, 0.13889, 0.68972),
    77: TexCharacterMetrics(0, 0.68333, 0, 0.13889, 1.2009),
    78: TexCharacterMetrics(0, 0.68333, 0.14736, 0.08334, 0.82049),
    79: TexCharacterMetrics(0, 0.68333, 0.02778, 0.11111, 0.79611),
    80: TexCharacterMetrics(0, 0.68333, 0.08222, 0.08334, 0.69556),
    81: TexCharacterMetrics(0.09722, 0.68333, 0, 0.11111, 0.81667),
    82: TexCharacterMetrics(0, 0.68333, 0, 0.08334, 0.8475),
    83: TexCharacterMetrics(0, 0.68333, 0.075, 0.13889, 0.60556),
    84: TexCharacterMetrics(0, 0.68333, 0.25417, 0, 0.54464),
    85: TexCharacterMetrics(0, 0.68333, 0.09931, 0.08334, 0.62583),
    86: TexCharacterMetrics(0, 0.68333, 0.08222, 0, 0.61278),
    87: TexCharacterMetrics(0, 0.68333, 0.08222, 0.08334, 0.98778),
    88: TexCharacterMetrics(0, 0.68333, 0.14643, 0.13889, 0.7133),
    89: TexCharacterMetrics(0.09722, 0.68333, 0.08222, 0.08334, 0.66834),
    90: TexCharacterMetrics(0, 0.68333, 0.07944, 0.13889, 0.72473),
  },
  "Fraktur-Regular": {
    33: TexCharacterMetrics(0, 0.69141, 0, 0, 0.29574),
    34: TexCharacterMetrics(0, 0.69141, 0, 0, 0.21471),
    38: TexCharacterMetrics(0, 0.69141, 0, 0, 0.73786),
    39: TexCharacterMetrics(0, 0.69141, 0, 0, 0.21201),
    40: TexCharacterMetrics(0.24982, 0.74947, 0, 0, 0.38865),
    41: TexCharacterMetrics(0.24982, 0.74947, 0, 0, 0.38865),
    42: TexCharacterMetrics(0, 0.62119, 0, 0, 0.27764),
    43: TexCharacterMetrics(0.08319, 0.58283, 0, 0, 0.75623),
    44: TexCharacterMetrics(0, 0.10803, 0, 0, 0.27764),
    45: TexCharacterMetrics(0.08319, 0.58283, 0, 0, 0.75623),
    46: TexCharacterMetrics(0, 0.10803, 0, 0, 0.27764),
    47: TexCharacterMetrics(0.24982, 0.74947, 0, 0, 0.50181),
    48: TexCharacterMetrics(0, 0.47534, 0, 0, 0.50181),
    49: TexCharacterMetrics(0, 0.47534, 0, 0, 0.50181),
    50: TexCharacterMetrics(0, 0.47534, 0, 0, 0.50181),
    51: TexCharacterMetrics(0.18906, 0.47534, 0, 0, 0.50181),
    52: TexCharacterMetrics(0.18906, 0.47534, 0, 0, 0.50181),
    53: TexCharacterMetrics(0.18906, 0.47534, 0, 0, 0.50181),
    54: TexCharacterMetrics(0, 0.69141, 0, 0, 0.50181),
    55: TexCharacterMetrics(0.18906, 0.47534, 0, 0, 0.50181),
    56: TexCharacterMetrics(0, 0.69141, 0, 0, 0.50181),
    57: TexCharacterMetrics(0.18906, 0.47534, 0, 0, 0.50181),
    58: TexCharacterMetrics(0, 0.47534, 0, 0, 0.21606),
    59: TexCharacterMetrics(0.12604, 0.47534, 0, 0, 0.21606),
    61: TexCharacterMetrics(-0.13099, 0.36866, 0, 0, 0.75623),
    63: TexCharacterMetrics(0, 0.69141, 0, 0, 0.36245),
    65: TexCharacterMetrics(0, 0.69141, 0, 0, 0.7176),
    66: TexCharacterMetrics(0, 0.69141, 0, 0, 0.88397),
    67: TexCharacterMetrics(0, 0.69141, 0, 0, 0.61254),
    68: TexCharacterMetrics(0, 0.69141, 0, 0, 0.83158),
    69: TexCharacterMetrics(0, 0.69141, 0, 0, 0.66278),
    70: TexCharacterMetrics(0.12604, 0.69141, 0, 0, 0.61119),
    71: TexCharacterMetrics(0, 0.69141, 0, 0, 0.78539),
    72: TexCharacterMetrics(0.06302, 0.69141, 0, 0, 0.7203),
    73: TexCharacterMetrics(0, 0.69141, 0, 0, 0.55448),
    74: TexCharacterMetrics(0.12604, 0.69141, 0, 0, 0.55231),
    75: TexCharacterMetrics(0, 0.69141, 0, 0, 0.66845),
    76: TexCharacterMetrics(0, 0.69141, 0, 0, 0.66602),
    77: TexCharacterMetrics(0, 0.69141, 0, 0, 1.04953),
    78: TexCharacterMetrics(0, 0.69141, 0, 0, 0.83212),
    79: TexCharacterMetrics(0, 0.69141, 0, 0, 0.82699),
    80: TexCharacterMetrics(0.18906, 0.69141, 0, 0, 0.82753),
    81: TexCharacterMetrics(0.03781, 0.69141, 0, 0, 0.82699),
    82: TexCharacterMetrics(0, 0.69141, 0, 0, 0.82807),
    83: TexCharacterMetrics(0, 0.69141, 0, 0, 0.82861),
    84: TexCharacterMetrics(0, 0.69141, 0, 0, 0.66899),
    85: TexCharacterMetrics(0, 0.69141, 0, 0, 0.64576),
    86: TexCharacterMetrics(0, 0.69141, 0, 0, 0.83131),
    87: TexCharacterMetrics(0, 0.69141, 0, 0, 1.04602),
    88: TexCharacterMetrics(0, 0.69141, 0, 0, 0.71922),
    89: TexCharacterMetrics(0.18906, 0.69141, 0, 0, 0.83293),
    90: TexCharacterMetrics(0.12604, 0.69141, 0, 0, 0.60201),
    91: TexCharacterMetrics(0.24982, 0.74947, 0, 0, 0.27764),
    93: TexCharacterMetrics(0.24982, 0.74947, 0, 0, 0.27764),
    94: TexCharacterMetrics(0, 0.69141, 0, 0, 0.49965),
    97: TexCharacterMetrics(0, 0.47534, 0, 0, 0.50046),
    98: TexCharacterMetrics(0, 0.69141, 0, 0, 0.51315),
    99: TexCharacterMetrics(0, 0.47534, 0, 0, 0.38946),
    100: TexCharacterMetrics(0, 0.62119, 0, 0, 0.49857),
    101: TexCharacterMetrics(0, 0.47534, 0, 0, 0.40053),
    102: TexCharacterMetrics(0.18906, 0.69141, 0, 0, 0.32626),
    103: TexCharacterMetrics(0.18906, 0.47534, 0, 0, 0.5037),
    104: TexCharacterMetrics(0.18906, 0.69141, 0, 0, 0.52126),
    105: TexCharacterMetrics(0, 0.69141, 0, 0, 0.27899),
    106: TexCharacterMetrics(0, 0.69141, 0, 0, 0.28088),
    107: TexCharacterMetrics(0, 0.69141, 0, 0, 0.38946),
    108: TexCharacterMetrics(0, 0.69141, 0, 0, 0.27953),
    109: TexCharacterMetrics(0, 0.47534, 0, 0, 0.76676),
    110: TexCharacterMetrics(0, 0.47534, 0, 0, 0.52666),
    111: TexCharacterMetrics(0, 0.47534, 0, 0, 0.48885),
    112: TexCharacterMetrics(0.18906, 0.52396, 0, 0, 0.50046),
    113: TexCharacterMetrics(0.18906, 0.47534, 0, 0, 0.48912),
    114: TexCharacterMetrics(0, 0.47534, 0, 0, 0.38919),
    115: TexCharacterMetrics(0, 0.47534, 0, 0, 0.44266),
    116: TexCharacterMetrics(0, 0.62119, 0, 0, 0.33301),
    117: TexCharacterMetrics(0, 0.47534, 0, 0, 0.5172),
    118: TexCharacterMetrics(0, 0.52396, 0, 0, 0.5118),
    119: TexCharacterMetrics(0, 0.52396, 0, 0, 0.77351),
    120: TexCharacterMetrics(0.18906, 0.47534, 0, 0, 0.38865),
    121: TexCharacterMetrics(0.18906, 0.47534, 0, 0, 0.49884),
    122: TexCharacterMetrics(0.18906, 0.47534, 0, 0, 0.39054),
    8216: TexCharacterMetrics(0, 0.69141, 0, 0, 0.21471),
    8217: TexCharacterMetrics(0, 0.69141, 0, 0, 0.21471),
    58112: TexCharacterMetrics(0, 0.62119, 0, 0, 0.49749),
    58113: TexCharacterMetrics(0, 0.62119, 0, 0, 0.4983),
    58114: TexCharacterMetrics(0.18906, 0.69141, 0, 0, 0.33328),
    58115: TexCharacterMetrics(0.18906, 0.69141, 0, 0, 0.32923),
    58116: TexCharacterMetrics(0.18906, 0.47534, 0, 0, 0.50343),
    58117: TexCharacterMetrics(0, 0.69141, 0, 0, 0.33301),
    58118: TexCharacterMetrics(0, 0.62119, 0, 0, 0.33409),
    58119: TexCharacterMetrics(0, 0.47534, 0, 0, 0.50073),
  },
  "Main-Bold": {
    33: TexCharacterMetrics(0, 0.69444, 0, 0, 0.35),
    34: TexCharacterMetrics(0, 0.69444, 0, 0, 0.60278),
    35: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.95833),
    36: TexCharacterMetrics(0.05556, 0.75, 0, 0, 0.575),
    37: TexCharacterMetrics(0.05556, 0.75, 0, 0, 0.95833),
    38: TexCharacterMetrics(0, 0.69444, 0, 0, 0.89444),
    39: TexCharacterMetrics(0, 0.69444, 0, 0, 0.31944),
    40: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.44722),
    41: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.44722),
    42: TexCharacterMetrics(0, 0.75, 0, 0, 0.575),
    43: TexCharacterMetrics(0.13333, 0.63333, 0, 0, 0.89444),
    44: TexCharacterMetrics(0.19444, 0.15556, 0, 0, 0.31944),
    45: TexCharacterMetrics(0, 0.44444, 0, 0, 0.38333),
    46: TexCharacterMetrics(0, 0.15556, 0, 0, 0.31944),
    47: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.575),
    48: TexCharacterMetrics(0, 0.64444, 0, 0, 0.575),
    49: TexCharacterMetrics(0, 0.64444, 0, 0, 0.575),
    50: TexCharacterMetrics(0, 0.64444, 0, 0, 0.575),
    51: TexCharacterMetrics(0, 0.64444, 0, 0, 0.575),
    52: TexCharacterMetrics(0, 0.64444, 0, 0, 0.575),
    53: TexCharacterMetrics(0, 0.64444, 0, 0, 0.575),
    54: TexCharacterMetrics(0, 0.64444, 0, 0, 0.575),
    55: TexCharacterMetrics(0, 0.64444, 0, 0, 0.575),
    56: TexCharacterMetrics(0, 0.64444, 0, 0, 0.575),
    57: TexCharacterMetrics(0, 0.64444, 0, 0, 0.575),
    58: TexCharacterMetrics(0, 0.44444, 0, 0, 0.31944),
    59: TexCharacterMetrics(0.19444, 0.44444, 0, 0, 0.31944),
    60: TexCharacterMetrics(0.08556, 0.58556, 0, 0, 0.89444),
    61: TexCharacterMetrics(-0.10889, 0.39111, 0, 0, 0.89444),
    62: TexCharacterMetrics(0.08556, 0.58556, 0, 0, 0.89444),
    63: TexCharacterMetrics(0, 0.69444, 0, 0, 0.54305),
    64: TexCharacterMetrics(0, 0.69444, 0, 0, 0.89444),
    65: TexCharacterMetrics(0, 0.68611, 0, 0, 0.86944),
    66: TexCharacterMetrics(0, 0.68611, 0, 0, 0.81805),
    67: TexCharacterMetrics(0, 0.68611, 0, 0, 0.83055),
    68: TexCharacterMetrics(0, 0.68611, 0, 0, 0.88194),
    69: TexCharacterMetrics(0, 0.68611, 0, 0, 0.75555),
    70: TexCharacterMetrics(0, 0.68611, 0, 0, 0.72361),
    71: TexCharacterMetrics(0, 0.68611, 0, 0, 0.90416),
    72: TexCharacterMetrics(0, 0.68611, 0, 0, 0.9),
    73: TexCharacterMetrics(0, 0.68611, 0, 0, 0.43611),
    74: TexCharacterMetrics(0, 0.68611, 0, 0, 0.59444),
    75: TexCharacterMetrics(0, 0.68611, 0, 0, 0.90138),
    76: TexCharacterMetrics(0, 0.68611, 0, 0, 0.69166),
    77: TexCharacterMetrics(0, 0.68611, 0, 0, 1.09166),
    78: TexCharacterMetrics(0, 0.68611, 0, 0, 0.9),
    79: TexCharacterMetrics(0, 0.68611, 0, 0, 0.86388),
    80: TexCharacterMetrics(0, 0.68611, 0, 0, 0.78611),
    81: TexCharacterMetrics(0.19444, 0.68611, 0, 0, 0.86388),
    82: TexCharacterMetrics(0, 0.68611, 0, 0, 0.8625),
    83: TexCharacterMetrics(0, 0.68611, 0, 0, 0.63889),
    84: TexCharacterMetrics(0, 0.68611, 0, 0, 0.8),
    85: TexCharacterMetrics(0, 0.68611, 0, 0, 0.88472),
    86: TexCharacterMetrics(0, 0.68611, 0.01597, 0, 0.86944),
    87: TexCharacterMetrics(0, 0.68611, 0.01597, 0, 1.18888),
    88: TexCharacterMetrics(0, 0.68611, 0, 0, 0.86944),
    89: TexCharacterMetrics(0, 0.68611, 0.02875, 0, 0.86944),
    90: TexCharacterMetrics(0, 0.68611, 0, 0, 0.70277),
    91: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.31944),
    92: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.575),
    93: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.31944),
    94: TexCharacterMetrics(0, 0.69444, 0, 0, 0.575),
    95: TexCharacterMetrics(0.31, 0.13444, 0.03194, 0, 0.575),
    97: TexCharacterMetrics(0, 0.44444, 0, 0, 0.55902),
    98: TexCharacterMetrics(0, 0.69444, 0, 0, 0.63889),
    99: TexCharacterMetrics(0, 0.44444, 0, 0, 0.51111),
    100: TexCharacterMetrics(0, 0.69444, 0, 0, 0.63889),
    101: TexCharacterMetrics(0, 0.44444, 0, 0, 0.52708),
    102: TexCharacterMetrics(0, 0.69444, 0.10903, 0, 0.35139),
    103: TexCharacterMetrics(0.19444, 0.44444, 0.01597, 0, 0.575),
    104: TexCharacterMetrics(0, 0.69444, 0, 0, 0.63889),
    105: TexCharacterMetrics(0, 0.69444, 0, 0, 0.31944),
    106: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.35139),
    107: TexCharacterMetrics(0, 0.69444, 0, 0, 0.60694),
    108: TexCharacterMetrics(0, 0.69444, 0, 0, 0.31944),
    109: TexCharacterMetrics(0, 0.44444, 0, 0, 0.95833),
    110: TexCharacterMetrics(0, 0.44444, 0, 0, 0.63889),
    111: TexCharacterMetrics(0, 0.44444, 0, 0, 0.575),
    112: TexCharacterMetrics(0.19444, 0.44444, 0, 0, 0.63889),
    113: TexCharacterMetrics(0.19444, 0.44444, 0, 0, 0.60694),
    114: TexCharacterMetrics(0, 0.44444, 0, 0, 0.47361),
    115: TexCharacterMetrics(0, 0.44444, 0, 0, 0.45361),
    116: TexCharacterMetrics(0, 0.63492, 0, 0, 0.44722),
    117: TexCharacterMetrics(0, 0.44444, 0, 0, 0.63889),
    118: TexCharacterMetrics(0, 0.44444, 0.01597, 0, 0.60694),
    119: TexCharacterMetrics(0, 0.44444, 0.01597, 0, 0.83055),
    120: TexCharacterMetrics(0, 0.44444, 0, 0, 0.60694),
    121: TexCharacterMetrics(0.19444, 0.44444, 0.01597, 0, 0.60694),
    122: TexCharacterMetrics(0, 0.44444, 0, 0, 0.51111),
    123: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.575),
    124: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.31944),
    125: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.575),
    126: TexCharacterMetrics(0.35, 0.34444, 0, 0, 0.575),
    168: TexCharacterMetrics(0, 0.69444, 0, 0, 0.575),
    172: TexCharacterMetrics(0, 0.44444, 0, 0, 0.76666),
    176: TexCharacterMetrics(0, 0.69444, 0, 0, 0.86944),
    177: TexCharacterMetrics(0.13333, 0.63333, 0, 0, 0.89444),
    184: TexCharacterMetrics(0.17014, 0, 0, 0, 0.51111),
    198: TexCharacterMetrics(0, 0.68611, 0, 0, 1.04166),
    215: TexCharacterMetrics(0.13333, 0.63333, 0, 0, 0.89444),
    216: TexCharacterMetrics(0.04861, 0.73472, 0, 0, 0.89444),
    223: TexCharacterMetrics(0, 0.69444, 0, 0, 0.59722),
    230: TexCharacterMetrics(0, 0.44444, 0, 0, 0.83055),
    247: TexCharacterMetrics(0.13333, 0.63333, 0, 0, 0.89444),
    248: TexCharacterMetrics(0.09722, 0.54167, 0, 0, 0.575),
    305: TexCharacterMetrics(0, 0.44444, 0, 0, 0.31944),
    338: TexCharacterMetrics(0, 0.68611, 0, 0, 1.16944),
    339: TexCharacterMetrics(0, 0.44444, 0, 0, 0.89444),
    567: TexCharacterMetrics(0.19444, 0.44444, 0, 0, 0.35139),
    710: TexCharacterMetrics(0, 0.69444, 0, 0, 0.575),
    711: TexCharacterMetrics(0, 0.63194, 0, 0, 0.575),
    713: TexCharacterMetrics(0, 0.59611, 0, 0, 0.575),
    714: TexCharacterMetrics(0, 0.69444, 0, 0, 0.575),
    715: TexCharacterMetrics(0, 0.69444, 0, 0, 0.575),
    728: TexCharacterMetrics(0, 0.69444, 0, 0, 0.575),
    729: TexCharacterMetrics(0, 0.69444, 0, 0, 0.31944),
    730: TexCharacterMetrics(0, 0.69444, 0, 0, 0.86944),
    732: TexCharacterMetrics(0, 0.69444, 0, 0, 0.575),
    733: TexCharacterMetrics(0, 0.69444, 0, 0, 0.575),
    915: TexCharacterMetrics(0, 0.68611, 0, 0, 0.69166),
    916: TexCharacterMetrics(0, 0.68611, 0, 0, 0.95833),
    920: TexCharacterMetrics(0, 0.68611, 0, 0, 0.89444),
    923: TexCharacterMetrics(0, 0.68611, 0, 0, 0.80555),
    926: TexCharacterMetrics(0, 0.68611, 0, 0, 0.76666),
    928: TexCharacterMetrics(0, 0.68611, 0, 0, 0.9),
    931: TexCharacterMetrics(0, 0.68611, 0, 0, 0.83055),
    933: TexCharacterMetrics(0, 0.68611, 0, 0, 0.89444),
    934: TexCharacterMetrics(0, 0.68611, 0, 0, 0.83055),
    936: TexCharacterMetrics(0, 0.68611, 0, 0, 0.89444),
    937: TexCharacterMetrics(0, 0.68611, 0, 0, 0.83055),
    8211: TexCharacterMetrics(0, 0.44444, 0.03194, 0, 0.575),
    8212: TexCharacterMetrics(0, 0.44444, 0.03194, 0, 1.14999),
    8216: TexCharacterMetrics(0, 0.69444, 0, 0, 0.31944),
    8217: TexCharacterMetrics(0, 0.69444, 0, 0, 0.31944),
    8220: TexCharacterMetrics(0, 0.69444, 0, 0, 0.60278),
    8221: TexCharacterMetrics(0, 0.69444, 0, 0, 0.60278),
    8224: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.51111),
    8225: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.51111),
    8242: TexCharacterMetrics(0, 0.55556, 0, 0, 0.34444),
    8407: TexCharacterMetrics(0, 0.72444, 0.15486, 0, 0.575),
    8463: TexCharacterMetrics(0, 0.69444, 0, 0, 0.66759),
    8465: TexCharacterMetrics(0, 0.69444, 0, 0, 0.83055),
    8467: TexCharacterMetrics(0, 0.69444, 0, 0, 0.47361),
    8472: TexCharacterMetrics(0.19444, 0.44444, 0, 0, 0.74027),
    8476: TexCharacterMetrics(0, 0.69444, 0, 0, 0.83055),
    8501: TexCharacterMetrics(0, 0.69444, 0, 0, 0.70277),
    8592: TexCharacterMetrics(-0.10889, 0.39111, 0, 0, 1.14999),
    8593: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.575),
    8594: TexCharacterMetrics(-0.10889, 0.39111, 0, 0, 1.14999),
    8595: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.575),
    8596: TexCharacterMetrics(-0.10889, 0.39111, 0, 0, 1.14999),
    8597: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.575),
    8598: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 1.14999),
    8599: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 1.14999),
    8600: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 1.14999),
    8601: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 1.14999),
    8636: TexCharacterMetrics(-0.10889, 0.39111, 0, 0, 1.14999),
    8637: TexCharacterMetrics(-0.10889, 0.39111, 0, 0, 1.14999),
    8640: TexCharacterMetrics(-0.10889, 0.39111, 0, 0, 1.14999),
    8641: TexCharacterMetrics(-0.10889, 0.39111, 0, 0, 1.14999),
    8656: TexCharacterMetrics(-0.10889, 0.39111, 0, 0, 1.14999),
    8657: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.70277),
    8658: TexCharacterMetrics(-0.10889, 0.39111, 0, 0, 1.14999),
    8659: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.70277),
    8660: TexCharacterMetrics(-0.10889, 0.39111, 0, 0, 1.14999),
    8661: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.70277),
    8704: TexCharacterMetrics(0, 0.69444, 0, 0, 0.63889),
    8706: TexCharacterMetrics(0, 0.69444, 0.06389, 0, 0.62847),
    8707: TexCharacterMetrics(0, 0.69444, 0, 0, 0.63889),
    8709: TexCharacterMetrics(0.05556, 0.75, 0, 0, 0.575),
    8711: TexCharacterMetrics(0, 0.68611, 0, 0, 0.95833),
    8712: TexCharacterMetrics(0.08556, 0.58556, 0, 0, 0.76666),
    8715: TexCharacterMetrics(0.08556, 0.58556, 0, 0, 0.76666),
    8722: TexCharacterMetrics(0.13333, 0.63333, 0, 0, 0.89444),
    8723: TexCharacterMetrics(0.13333, 0.63333, 0, 0, 0.89444),
    8725: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.575),
    8726: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.575),
    8727: TexCharacterMetrics(-0.02778, 0.47222, 0, 0, 0.575),
    8728: TexCharacterMetrics(-0.02639, 0.47361, 0, 0, 0.575),
    8729: TexCharacterMetrics(-0.02639, 0.47361, 0, 0, 0.575),
    8730: TexCharacterMetrics(0.18, 0.82, 0, 0, 0.95833),
    8733: TexCharacterMetrics(0, 0.44444, 0, 0, 0.89444),
    8734: TexCharacterMetrics(0, 0.44444, 0, 0, 1.14999),
    8736: TexCharacterMetrics(0, 0.69224, 0, 0, 0.72222),
    8739: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.31944),
    8741: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.575),
    8743: TexCharacterMetrics(0, 0.55556, 0, 0, 0.76666),
    8744: TexCharacterMetrics(0, 0.55556, 0, 0, 0.76666),
    8745: TexCharacterMetrics(0, 0.55556, 0, 0, 0.76666),
    8746: TexCharacterMetrics(0, 0.55556, 0, 0, 0.76666),
    8747: TexCharacterMetrics(0.19444, 0.69444, 0.12778, 0, 0.56875),
    8764: TexCharacterMetrics(-0.10889, 0.39111, 0, 0, 0.89444),
    8768: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.31944),
    8771: TexCharacterMetrics(0.00222, 0.50222, 0, 0, 0.89444),
    8776: TexCharacterMetrics(0.02444, 0.52444, 0, 0, 0.89444),
    8781: TexCharacterMetrics(0.00222, 0.50222, 0, 0, 0.89444),
    8801: TexCharacterMetrics(0.00222, 0.50222, 0, 0, 0.89444),
    8804: TexCharacterMetrics(0.19667, 0.69667, 0, 0, 0.89444),
    8805: TexCharacterMetrics(0.19667, 0.69667, 0, 0, 0.89444),
    8810: TexCharacterMetrics(0.08556, 0.58556, 0, 0, 1.14999),
    8811: TexCharacterMetrics(0.08556, 0.58556, 0, 0, 1.14999),
    8826: TexCharacterMetrics(0.08556, 0.58556, 0, 0, 0.89444),
    8827: TexCharacterMetrics(0.08556, 0.58556, 0, 0, 0.89444),
    8834: TexCharacterMetrics(0.08556, 0.58556, 0, 0, 0.89444),
    8835: TexCharacterMetrics(0.08556, 0.58556, 0, 0, 0.89444),
    8838: TexCharacterMetrics(0.19667, 0.69667, 0, 0, 0.89444),
    8839: TexCharacterMetrics(0.19667, 0.69667, 0, 0, 0.89444),
    8846: TexCharacterMetrics(0, 0.55556, 0, 0, 0.76666),
    8849: TexCharacterMetrics(0.19667, 0.69667, 0, 0, 0.89444),
    8850: TexCharacterMetrics(0.19667, 0.69667, 0, 0, 0.89444),
    8851: TexCharacterMetrics(0, 0.55556, 0, 0, 0.76666),
    8852: TexCharacterMetrics(0, 0.55556, 0, 0, 0.76666),
    8853: TexCharacterMetrics(0.13333, 0.63333, 0, 0, 0.89444),
    8854: TexCharacterMetrics(0.13333, 0.63333, 0, 0, 0.89444),
    8855: TexCharacterMetrics(0.13333, 0.63333, 0, 0, 0.89444),
    8856: TexCharacterMetrics(0.13333, 0.63333, 0, 0, 0.89444),
    8857: TexCharacterMetrics(0.13333, 0.63333, 0, 0, 0.89444),
    8866: TexCharacterMetrics(0, 0.69444, 0, 0, 0.70277),
    8867: TexCharacterMetrics(0, 0.69444, 0, 0, 0.70277),
    8868: TexCharacterMetrics(0, 0.69444, 0, 0, 0.89444),
    8869: TexCharacterMetrics(0, 0.69444, 0, 0, 0.89444),
    8900: TexCharacterMetrics(-0.02639, 0.47361, 0, 0, 0.575),
    8901: TexCharacterMetrics(-0.02639, 0.47361, 0, 0, 0.31944),
    8902: TexCharacterMetrics(-0.02778, 0.47222, 0, 0, 0.575),
    8968: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.51111),
    8969: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.51111),
    8970: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.51111),
    8971: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.51111),
    8994: TexCharacterMetrics(-0.13889, 0.36111, 0, 0, 1.14999),
    8995: TexCharacterMetrics(-0.13889, 0.36111, 0, 0, 1.14999),
    9651: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 1.02222),
    9657: TexCharacterMetrics(-0.02778, 0.47222, 0, 0, 0.575),
    9661: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 1.02222),
    9667: TexCharacterMetrics(-0.02778, 0.47222, 0, 0, 0.575),
    9711: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 1.14999),
    9824: TexCharacterMetrics(0.12963, 0.69444, 0, 0, 0.89444),
    9825: TexCharacterMetrics(0.12963, 0.69444, 0, 0, 0.89444),
    9826: TexCharacterMetrics(0.12963, 0.69444, 0, 0, 0.89444),
    9827: TexCharacterMetrics(0.12963, 0.69444, 0, 0, 0.89444),
    9837: TexCharacterMetrics(0, 0.75, 0, 0, 0.44722),
    9838: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.44722),
    9839: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.44722),
    10216: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.44722),
    10217: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.44722),
    10815: TexCharacterMetrics(0, 0.68611, 0, 0, 0.9),
    10927: TexCharacterMetrics(0.19667, 0.69667, 0, 0, 0.89444),
    10928: TexCharacterMetrics(0.19667, 0.69667, 0, 0, 0.89444),
    57376: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0),
  },
  "Main-BoldItalic": {
    33: TexCharacterMetrics(0, 0.69444, 0.11417, 0, 0.38611),
    34: TexCharacterMetrics(0, 0.69444, 0.07939, 0, 0.62055),
    35: TexCharacterMetrics(0.19444, 0.69444, 0.06833, 0, 0.94444),
    37: TexCharacterMetrics(0.05556, 0.75, 0.12861, 0, 0.94444),
    38: TexCharacterMetrics(0, 0.69444, 0.08528, 0, 0.88555),
    39: TexCharacterMetrics(0, 0.69444, 0.12945, 0, 0.35555),
    40: TexCharacterMetrics(0.25, 0.75, 0.15806, 0, 0.47333),
    41: TexCharacterMetrics(0.25, 0.75, 0.03306, 0, 0.47333),
    42: TexCharacterMetrics(0, 0.75, 0.14333, 0, 0.59111),
    43: TexCharacterMetrics(0.10333, 0.60333, 0.03306, 0, 0.88555),
    44: TexCharacterMetrics(0.19444, 0.14722, 0, 0, 0.35555),
    45: TexCharacterMetrics(0, 0.44444, 0.02611, 0, 0.41444),
    46: TexCharacterMetrics(0, 0.14722, 0, 0, 0.35555),
    47: TexCharacterMetrics(0.25, 0.75, 0.15806, 0, 0.59111),
    48: TexCharacterMetrics(0, 0.64444, 0.13167, 0, 0.59111),
    49: TexCharacterMetrics(0, 0.64444, 0.13167, 0, 0.59111),
    50: TexCharacterMetrics(0, 0.64444, 0.13167, 0, 0.59111),
    51: TexCharacterMetrics(0, 0.64444, 0.13167, 0, 0.59111),
    52: TexCharacterMetrics(0.19444, 0.64444, 0.13167, 0, 0.59111),
    53: TexCharacterMetrics(0, 0.64444, 0.13167, 0, 0.59111),
    54: TexCharacterMetrics(0, 0.64444, 0.13167, 0, 0.59111),
    55: TexCharacterMetrics(0.19444, 0.64444, 0.13167, 0, 0.59111),
    56: TexCharacterMetrics(0, 0.64444, 0.13167, 0, 0.59111),
    57: TexCharacterMetrics(0, 0.64444, 0.13167, 0, 0.59111),
    58: TexCharacterMetrics(0, 0.44444, 0.06695, 0, 0.35555),
    59: TexCharacterMetrics(0.19444, 0.44444, 0.06695, 0, 0.35555),
    61: TexCharacterMetrics(-0.10889, 0.39111, 0.06833, 0, 0.88555),
    63: TexCharacterMetrics(0, 0.69444, 0.11472, 0, 0.59111),
    64: TexCharacterMetrics(0, 0.69444, 0.09208, 0, 0.88555),
    65: TexCharacterMetrics(0, 0.68611, 0, 0, 0.86555),
    66: TexCharacterMetrics(0, 0.68611, 0.0992, 0, 0.81666),
    67: TexCharacterMetrics(0, 0.68611, 0.14208, 0, 0.82666),
    68: TexCharacterMetrics(0, 0.68611, 0.09062, 0, 0.87555),
    69: TexCharacterMetrics(0, 0.68611, 0.11431, 0, 0.75666),
    70: TexCharacterMetrics(0, 0.68611, 0.12903, 0, 0.72722),
    71: TexCharacterMetrics(0, 0.68611, 0.07347, 0, 0.89527),
    72: TexCharacterMetrics(0, 0.68611, 0.17208, 0, 0.8961),
    73: TexCharacterMetrics(0, 0.68611, 0.15681, 0, 0.47166),
    74: TexCharacterMetrics(0, 0.68611, 0.145, 0, 0.61055),
    75: TexCharacterMetrics(0, 0.68611, 0.14208, 0, 0.89499),
    76: TexCharacterMetrics(0, 0.68611, 0, 0, 0.69777),
    77: TexCharacterMetrics(0, 0.68611, 0.17208, 0, 1.07277),
    78: TexCharacterMetrics(0, 0.68611, 0.17208, 0, 0.8961),
    79: TexCharacterMetrics(0, 0.68611, 0.09062, 0, 0.85499),
    80: TexCharacterMetrics(0, 0.68611, 0.0992, 0, 0.78721),
    81: TexCharacterMetrics(0.19444, 0.68611, 0.09062, 0, 0.85499),
    82: TexCharacterMetrics(0, 0.68611, 0.02559, 0, 0.85944),
    83: TexCharacterMetrics(0, 0.68611, 0.11264, 0, 0.64999),
    84: TexCharacterMetrics(0, 0.68611, 0.12903, 0, 0.7961),
    85: TexCharacterMetrics(0, 0.68611, 0.17208, 0, 0.88083),
    86: TexCharacterMetrics(0, 0.68611, 0.18625, 0, 0.86555),
    87: TexCharacterMetrics(0, 0.68611, 0.18625, 0, 1.15999),
    88: TexCharacterMetrics(0, 0.68611, 0.15681, 0, 0.86555),
    89: TexCharacterMetrics(0, 0.68611, 0.19803, 0, 0.86555),
    90: TexCharacterMetrics(0, 0.68611, 0.14208, 0, 0.70888),
    91: TexCharacterMetrics(0.25, 0.75, 0.1875, 0, 0.35611),
    93: TexCharacterMetrics(0.25, 0.75, 0.09972, 0, 0.35611),
    94: TexCharacterMetrics(0, 0.69444, 0.06709, 0, 0.59111),
    95: TexCharacterMetrics(0.31, 0.13444, 0.09811, 0, 0.59111),
    97: TexCharacterMetrics(0, 0.44444, 0.09426, 0, 0.59111),
    98: TexCharacterMetrics(0, 0.69444, 0.07861, 0, 0.53222),
    99: TexCharacterMetrics(0, 0.44444, 0.05222, 0, 0.53222),
    100: TexCharacterMetrics(0, 0.69444, 0.10861, 0, 0.59111),
    101: TexCharacterMetrics(0, 0.44444, 0.085, 0, 0.53222),
    102: TexCharacterMetrics(0.19444, 0.69444, 0.21778, 0, 0.4),
    103: TexCharacterMetrics(0.19444, 0.44444, 0.105, 0, 0.53222),
    104: TexCharacterMetrics(0, 0.69444, 0.09426, 0, 0.59111),
    105: TexCharacterMetrics(0, 0.69326, 0.11387, 0, 0.35555),
    106: TexCharacterMetrics(0.19444, 0.69326, 0.1672, 0, 0.35555),
    107: TexCharacterMetrics(0, 0.69444, 0.11111, 0, 0.53222),
    108: TexCharacterMetrics(0, 0.69444, 0.10861, 0, 0.29666),
    109: TexCharacterMetrics(0, 0.44444, 0.09426, 0, 0.94444),
    110: TexCharacterMetrics(0, 0.44444, 0.09426, 0, 0.64999),
    111: TexCharacterMetrics(0, 0.44444, 0.07861, 0, 0.59111),
    112: TexCharacterMetrics(0.19444, 0.44444, 0.07861, 0, 0.59111),
    113: TexCharacterMetrics(0.19444, 0.44444, 0.105, 0, 0.53222),
    114: TexCharacterMetrics(0, 0.44444, 0.11111, 0, 0.50167),
    115: TexCharacterMetrics(0, 0.44444, 0.08167, 0, 0.48694),
    116: TexCharacterMetrics(0, 0.63492, 0.09639, 0, 0.385),
    117: TexCharacterMetrics(0, 0.44444, 0.09426, 0, 0.62055),
    118: TexCharacterMetrics(0, 0.44444, 0.11111, 0, 0.53222),
    119: TexCharacterMetrics(0, 0.44444, 0.11111, 0, 0.76777),
    120: TexCharacterMetrics(0, 0.44444, 0.12583, 0, 0.56055),
    121: TexCharacterMetrics(0.19444, 0.44444, 0.105, 0, 0.56166),
    122: TexCharacterMetrics(0, 0.44444, 0.13889, 0, 0.49055),
    126: TexCharacterMetrics(0.35, 0.34444, 0.11472, 0, 0.59111),
    163: TexCharacterMetrics(0, 0.69444, 0, 0, 0.86853),
    168: TexCharacterMetrics(0, 0.69444, 0.11473, 0, 0.59111),
    176: TexCharacterMetrics(0, 0.69444, 0, 0, 0.94888),
    184: TexCharacterMetrics(0.17014, 0, 0, 0, 0.53222),
    198: TexCharacterMetrics(0, 0.68611, 0.11431, 0, 1.02277),
    216: TexCharacterMetrics(0.04861, 0.73472, 0.09062, 0, 0.88555),
    223: TexCharacterMetrics(0.19444, 0.69444, 0.09736, 0, 0.665),
    230: TexCharacterMetrics(0, 0.44444, 0.085, 0, 0.82666),
    248: TexCharacterMetrics(0.09722, 0.54167, 0.09458, 0, 0.59111),
    305: TexCharacterMetrics(0, 0.44444, 0.09426, 0, 0.35555),
    338: TexCharacterMetrics(0, 0.68611, 0.11431, 0, 1.14054),
    339: TexCharacterMetrics(0, 0.44444, 0.085, 0, 0.82666),
    567: TexCharacterMetrics(0.19444, 0.44444, 0.04611, 0, 0.385),
    710: TexCharacterMetrics(0, 0.69444, 0.06709, 0, 0.59111),
    711: TexCharacterMetrics(0, 0.63194, 0.08271, 0, 0.59111),
    713: TexCharacterMetrics(0, 0.59444, 0.10444, 0, 0.59111),
    714: TexCharacterMetrics(0, 0.69444, 0.08528, 0, 0.59111),
    715: TexCharacterMetrics(0, 0.69444, 0, 0, 0.59111),
    728: TexCharacterMetrics(0, 0.69444, 0.10333, 0, 0.59111),
    729: TexCharacterMetrics(0, 0.69444, 0.12945, 0, 0.35555),
    730: TexCharacterMetrics(0, 0.69444, 0, 0, 0.94888),
    732: TexCharacterMetrics(0, 0.69444, 0.11472, 0, 0.59111),
    733: TexCharacterMetrics(0, 0.69444, 0.11472, 0, 0.59111),
    915: TexCharacterMetrics(0, 0.68611, 0.12903, 0, 0.69777),
    916: TexCharacterMetrics(0, 0.68611, 0, 0, 0.94444),
    920: TexCharacterMetrics(0, 0.68611, 0.09062, 0, 0.88555),
    923: TexCharacterMetrics(0, 0.68611, 0, 0, 0.80666),
    926: TexCharacterMetrics(0, 0.68611, 0.15092, 0, 0.76777),
    928: TexCharacterMetrics(0, 0.68611, 0.17208, 0, 0.8961),
    931: TexCharacterMetrics(0, 0.68611, 0.11431, 0, 0.82666),
    933: TexCharacterMetrics(0, 0.68611, 0.10778, 0, 0.88555),
    934: TexCharacterMetrics(0, 0.68611, 0.05632, 0, 0.82666),
    936: TexCharacterMetrics(0, 0.68611, 0.10778, 0, 0.88555),
    937: TexCharacterMetrics(0, 0.68611, 0.0992, 0, 0.82666),
    8211: TexCharacterMetrics(0, 0.44444, 0.09811, 0, 0.59111),
    8212: TexCharacterMetrics(0, 0.44444, 0.09811, 0, 1.18221),
    8216: TexCharacterMetrics(0, 0.69444, 0.12945, 0, 0.35555),
    8217: TexCharacterMetrics(0, 0.69444, 0.12945, 0, 0.35555),
    8220: TexCharacterMetrics(0, 0.69444, 0.16772, 0, 0.62055),
    8221: TexCharacterMetrics(0, 0.69444, 0.07939, 0, 0.62055),
  },
  "Main-Italic": {
    33: TexCharacterMetrics(0, 0.69444, 0.12417, 0, 0.30667),
    34: TexCharacterMetrics(0, 0.69444, 0.06961, 0, 0.51444),
    35: TexCharacterMetrics(0.19444, 0.69444, 0.06616, 0, 0.81777),
    37: TexCharacterMetrics(0.05556, 0.75, 0.13639, 0, 0.81777),
    38: TexCharacterMetrics(0, 0.69444, 0.09694, 0, 0.76666),
    39: TexCharacterMetrics(0, 0.69444, 0.12417, 0, 0.30667),
    40: TexCharacterMetrics(0.25, 0.75, 0.16194, 0, 0.40889),
    41: TexCharacterMetrics(0.25, 0.75, 0.03694, 0, 0.40889),
    42: TexCharacterMetrics(0, 0.75, 0.14917, 0, 0.51111),
    43: TexCharacterMetrics(0.05667, 0.56167, 0.03694, 0, 0.76666),
    44: TexCharacterMetrics(0.19444, 0.10556, 0, 0, 0.30667),
    45: TexCharacterMetrics(0, 0.43056, 0.02826, 0, 0.35778),
    46: TexCharacterMetrics(0, 0.10556, 0, 0, 0.30667),
    47: TexCharacterMetrics(0.25, 0.75, 0.16194, 0, 0.51111),
    48: TexCharacterMetrics(0, 0.64444, 0.13556, 0, 0.51111),
    49: TexCharacterMetrics(0, 0.64444, 0.13556, 0, 0.51111),
    50: TexCharacterMetrics(0, 0.64444, 0.13556, 0, 0.51111),
    51: TexCharacterMetrics(0, 0.64444, 0.13556, 0, 0.51111),
    52: TexCharacterMetrics(0.19444, 0.64444, 0.13556, 0, 0.51111),
    53: TexCharacterMetrics(0, 0.64444, 0.13556, 0, 0.51111),
    54: TexCharacterMetrics(0, 0.64444, 0.13556, 0, 0.51111),
    55: TexCharacterMetrics(0.19444, 0.64444, 0.13556, 0, 0.51111),
    56: TexCharacterMetrics(0, 0.64444, 0.13556, 0, 0.51111),
    57: TexCharacterMetrics(0, 0.64444, 0.13556, 0, 0.51111),
    58: TexCharacterMetrics(0, 0.43056, 0.0582, 0, 0.30667),
    59: TexCharacterMetrics(0.19444, 0.43056, 0.0582, 0, 0.30667),
    61: TexCharacterMetrics(-0.13313, 0.36687, 0.06616, 0, 0.76666),
    63: TexCharacterMetrics(0, 0.69444, 0.1225, 0, 0.51111),
    64: TexCharacterMetrics(0, 0.69444, 0.09597, 0, 0.76666),
    65: TexCharacterMetrics(0, 0.68333, 0, 0, 0.74333),
    66: TexCharacterMetrics(0, 0.68333, 0.10257, 0, 0.70389),
    67: TexCharacterMetrics(0, 0.68333, 0.14528, 0, 0.71555),
    68: TexCharacterMetrics(0, 0.68333, 0.09403, 0, 0.755),
    69: TexCharacterMetrics(0, 0.68333, 0.12028, 0, 0.67833),
    70: TexCharacterMetrics(0, 0.68333, 0.13305, 0, 0.65277),
    71: TexCharacterMetrics(0, 0.68333, 0.08722, 0, 0.77361),
    72: TexCharacterMetrics(0, 0.68333, 0.16389, 0, 0.74333),
    73: TexCharacterMetrics(0, 0.68333, 0.15806, 0, 0.38555),
    74: TexCharacterMetrics(0, 0.68333, 0.14028, 0, 0.525),
    75: TexCharacterMetrics(0, 0.68333, 0.14528, 0, 0.76888),
    76: TexCharacterMetrics(0, 0.68333, 0, 0, 0.62722),
    77: TexCharacterMetrics(0, 0.68333, 0.16389, 0, 0.89666),
    78: TexCharacterMetrics(0, 0.68333, 0.16389, 0, 0.74333),
    79: TexCharacterMetrics(0, 0.68333, 0.09403, 0, 0.76666),
    80: TexCharacterMetrics(0, 0.68333, 0.10257, 0, 0.67833),
    81: TexCharacterMetrics(0.19444, 0.68333, 0.09403, 0, 0.76666),
    82: TexCharacterMetrics(0, 0.68333, 0.03868, 0, 0.72944),
    83: TexCharacterMetrics(0, 0.68333, 0.11972, 0, 0.56222),
    84: TexCharacterMetrics(0, 0.68333, 0.13305, 0, 0.71555),
    85: TexCharacterMetrics(0, 0.68333, 0.16389, 0, 0.74333),
    86: TexCharacterMetrics(0, 0.68333, 0.18361, 0, 0.74333),
    87: TexCharacterMetrics(0, 0.68333, 0.18361, 0, 0.99888),
    88: TexCharacterMetrics(0, 0.68333, 0.15806, 0, 0.74333),
    89: TexCharacterMetrics(0, 0.68333, 0.19383, 0, 0.74333),
    90: TexCharacterMetrics(0, 0.68333, 0.14528, 0, 0.61333),
    91: TexCharacterMetrics(0.25, 0.75, 0.1875, 0, 0.30667),
    93: TexCharacterMetrics(0.25, 0.75, 0.10528, 0, 0.30667),
    94: TexCharacterMetrics(0, 0.69444, 0.06646, 0, 0.51111),
    95: TexCharacterMetrics(0.31, 0.12056, 0.09208, 0, 0.51111),
    97: TexCharacterMetrics(0, 0.43056, 0.07671, 0, 0.51111),
    98: TexCharacterMetrics(0, 0.69444, 0.06312, 0, 0.46),
    99: TexCharacterMetrics(0, 0.43056, 0.05653, 0, 0.46),
    100: TexCharacterMetrics(0, 0.69444, 0.10333, 0, 0.51111),
    101: TexCharacterMetrics(0, 0.43056, 0.07514, 0, 0.46),
    102: TexCharacterMetrics(0.19444, 0.69444, 0.21194, 0, 0.30667),
    103: TexCharacterMetrics(0.19444, 0.43056, 0.08847, 0, 0.46),
    104: TexCharacterMetrics(0, 0.69444, 0.07671, 0, 0.51111),
    105: TexCharacterMetrics(0, 0.65536, 0.1019, 0, 0.30667),
    106: TexCharacterMetrics(0.19444, 0.65536, 0.14467, 0, 0.30667),
    107: TexCharacterMetrics(0, 0.69444, 0.10764, 0, 0.46),
    108: TexCharacterMetrics(0, 0.69444, 0.10333, 0, 0.25555),
    109: TexCharacterMetrics(0, 0.43056, 0.07671, 0, 0.81777),
    110: TexCharacterMetrics(0, 0.43056, 0.07671, 0, 0.56222),
    111: TexCharacterMetrics(0, 0.43056, 0.06312, 0, 0.51111),
    112: TexCharacterMetrics(0.19444, 0.43056, 0.06312, 0, 0.51111),
    113: TexCharacterMetrics(0.19444, 0.43056, 0.08847, 0, 0.46),
    114: TexCharacterMetrics(0, 0.43056, 0.10764, 0, 0.42166),
    115: TexCharacterMetrics(0, 0.43056, 0.08208, 0, 0.40889),
    116: TexCharacterMetrics(0, 0.61508, 0.09486, 0, 0.33222),
    117: TexCharacterMetrics(0, 0.43056, 0.07671, 0, 0.53666),
    118: TexCharacterMetrics(0, 0.43056, 0.10764, 0, 0.46),
    119: TexCharacterMetrics(0, 0.43056, 0.10764, 0, 0.66444),
    120: TexCharacterMetrics(0, 0.43056, 0.12042, 0, 0.46389),
    121: TexCharacterMetrics(0.19444, 0.43056, 0.08847, 0, 0.48555),
    122: TexCharacterMetrics(0, 0.43056, 0.12292, 0, 0.40889),
    126: TexCharacterMetrics(0.35, 0.31786, 0.11585, 0, 0.51111),
    163: TexCharacterMetrics(0, 0.69444, 0, 0, 0.76909),
    168: TexCharacterMetrics(0, 0.66786, 0.10474, 0, 0.51111),
    176: TexCharacterMetrics(0, 0.69444, 0, 0, 0.83129),
    184: TexCharacterMetrics(0.17014, 0, 0, 0, 0.46),
    198: TexCharacterMetrics(0, 0.68333, 0.12028, 0, 0.88277),
    216: TexCharacterMetrics(0.04861, 0.73194, 0.09403, 0, 0.76666),
    223: TexCharacterMetrics(0.19444, 0.69444, 0.10514, 0, 0.53666),
    230: TexCharacterMetrics(0, 0.43056, 0.07514, 0, 0.71555),
    248: TexCharacterMetrics(0.09722, 0.52778, 0.09194, 0, 0.51111),
    305: TexCharacterMetrics(0, 0.43056, 0, 0.02778, 0.32246),
    338: TexCharacterMetrics(0, 0.68333, 0.12028, 0, 0.98499),
    339: TexCharacterMetrics(0, 0.43056, 0.07514, 0, 0.71555),
    567: TexCharacterMetrics(0.19444, 0.43056, 0, 0.08334, 0.38403),
    710: TexCharacterMetrics(0, 0.69444, 0.06646, 0, 0.51111),
    711: TexCharacterMetrics(0, 0.62847, 0.08295, 0, 0.51111),
    713: TexCharacterMetrics(0, 0.56167, 0.10333, 0, 0.51111),
    714: TexCharacterMetrics(0, 0.69444, 0.09694, 0, 0.51111),
    715: TexCharacterMetrics(0, 0.69444, 0, 0, 0.51111),
    728: TexCharacterMetrics(0, 0.69444, 0.10806, 0, 0.51111),
    729: TexCharacterMetrics(0, 0.66786, 0.11752, 0, 0.30667),
    730: TexCharacterMetrics(0, 0.69444, 0, 0, 0.83129),
    732: TexCharacterMetrics(0, 0.66786, 0.11585, 0, 0.51111),
    733: TexCharacterMetrics(0, 0.69444, 0.1225, 0, 0.51111),
    915: TexCharacterMetrics(0, 0.68333, 0.13305, 0, 0.62722),
    916: TexCharacterMetrics(0, 0.68333, 0, 0, 0.81777),
    920: TexCharacterMetrics(0, 0.68333, 0.09403, 0, 0.76666),
    923: TexCharacterMetrics(0, 0.68333, 0, 0, 0.69222),
    926: TexCharacterMetrics(0, 0.68333, 0.15294, 0, 0.66444),
    928: TexCharacterMetrics(0, 0.68333, 0.16389, 0, 0.74333),
    931: TexCharacterMetrics(0, 0.68333, 0.12028, 0, 0.71555),
    933: TexCharacterMetrics(0, 0.68333, 0.11111, 0, 0.76666),
    934: TexCharacterMetrics(0, 0.68333, 0.05986, 0, 0.71555),
    936: TexCharacterMetrics(0, 0.68333, 0.11111, 0, 0.76666),
    937: TexCharacterMetrics(0, 0.68333, 0.10257, 0, 0.71555),
    8211: TexCharacterMetrics(0, 0.43056, 0.09208, 0, 0.51111),
    8212: TexCharacterMetrics(0, 0.43056, 0.09208, 0, 1.02222),
    8216: TexCharacterMetrics(0, 0.69444, 0.12417, 0, 0.30667),
    8217: TexCharacterMetrics(0, 0.69444, 0.12417, 0, 0.30667),
    8220: TexCharacterMetrics(0, 0.69444, 0.1685, 0, 0.51444),
    8221: TexCharacterMetrics(0, 0.69444, 0.06961, 0, 0.51444),
    8463: TexCharacterMetrics(0, 0.68889, 0, 0, 0.54028),
  },
  "Main-Regular": {
    32: TexCharacterMetrics(0, 0, 0, 0, 0.25),
    33: TexCharacterMetrics(0, 0.69444, 0, 0, 0.27778),
    34: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    35: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.83334),
    36: TexCharacterMetrics(0.05556, 0.75, 0, 0, 0.5),
    37: TexCharacterMetrics(0.05556, 0.75, 0, 0, 0.83334),
    38: TexCharacterMetrics(0, 0.69444, 0, 0, 0.77778),
    39: TexCharacterMetrics(0, 0.69444, 0, 0, 0.27778),
    40: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.38889),
    41: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.38889),
    42: TexCharacterMetrics(0, 0.75, 0, 0, 0.5),
    43: TexCharacterMetrics(0.08333, 0.58333, 0, 0, 0.77778),
    44: TexCharacterMetrics(0.19444, 0.10556, 0, 0, 0.27778),
    45: TexCharacterMetrics(0, 0.43056, 0, 0, 0.33333),
    46: TexCharacterMetrics(0, 0.10556, 0, 0, 0.27778),
    47: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.5),
    48: TexCharacterMetrics(0, 0.64444, 0, 0, 0.5),
    49: TexCharacterMetrics(0, 0.64444, 0, 0, 0.5),
    50: TexCharacterMetrics(0, 0.64444, 0, 0, 0.5),
    51: TexCharacterMetrics(0, 0.64444, 0, 0, 0.5),
    52: TexCharacterMetrics(0, 0.64444, 0, 0, 0.5),
    53: TexCharacterMetrics(0, 0.64444, 0, 0, 0.5),
    54: TexCharacterMetrics(0, 0.64444, 0, 0, 0.5),
    55: TexCharacterMetrics(0, 0.64444, 0, 0, 0.5),
    56: TexCharacterMetrics(0, 0.64444, 0, 0, 0.5),
    57: TexCharacterMetrics(0, 0.64444, 0, 0, 0.5),
    58: TexCharacterMetrics(0, 0.43056, 0, 0, 0.27778),
    59: TexCharacterMetrics(0.19444, 0.43056, 0, 0, 0.27778),
    60: TexCharacterMetrics(0.0391, 0.5391, 0, 0, 0.77778),
    61: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 0.77778),
    62: TexCharacterMetrics(0.0391, 0.5391, 0, 0, 0.77778),
    63: TexCharacterMetrics(0, 0.69444, 0, 0, 0.47222),
    64: TexCharacterMetrics(0, 0.69444, 0, 0, 0.77778),
    65: TexCharacterMetrics(0, 0.68333, 0, 0, 0.75),
    66: TexCharacterMetrics(0, 0.68333, 0, 0, 0.70834),
    67: TexCharacterMetrics(0, 0.68333, 0, 0, 0.72222),
    68: TexCharacterMetrics(0, 0.68333, 0, 0, 0.76389),
    69: TexCharacterMetrics(0, 0.68333, 0, 0, 0.68056),
    70: TexCharacterMetrics(0, 0.68333, 0, 0, 0.65278),
    71: TexCharacterMetrics(0, 0.68333, 0, 0, 0.78472),
    72: TexCharacterMetrics(0, 0.68333, 0, 0, 0.75),
    73: TexCharacterMetrics(0, 0.68333, 0, 0, 0.36111),
    74: TexCharacterMetrics(0, 0.68333, 0, 0, 0.51389),
    75: TexCharacterMetrics(0, 0.68333, 0, 0, 0.77778),
    76: TexCharacterMetrics(0, 0.68333, 0, 0, 0.625),
    77: TexCharacterMetrics(0, 0.68333, 0, 0, 0.91667),
    78: TexCharacterMetrics(0, 0.68333, 0, 0, 0.75),
    79: TexCharacterMetrics(0, 0.68333, 0, 0, 0.77778),
    80: TexCharacterMetrics(0, 0.68333, 0, 0, 0.68056),
    81: TexCharacterMetrics(0.19444, 0.68333, 0, 0, 0.77778),
    82: TexCharacterMetrics(0, 0.68333, 0, 0, 0.73611),
    83: TexCharacterMetrics(0, 0.68333, 0, 0, 0.55556),
    84: TexCharacterMetrics(0, 0.68333, 0, 0, 0.72222),
    85: TexCharacterMetrics(0, 0.68333, 0, 0, 0.75),
    86: TexCharacterMetrics(0, 0.68333, 0.01389, 0, 0.75),
    87: TexCharacterMetrics(0, 0.68333, 0.01389, 0, 1.02778),
    88: TexCharacterMetrics(0, 0.68333, 0, 0, 0.75),
    89: TexCharacterMetrics(0, 0.68333, 0.025, 0, 0.75),
    90: TexCharacterMetrics(0, 0.68333, 0, 0, 0.61111),
    91: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.27778),
    92: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.5),
    93: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.27778),
    94: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    95: TexCharacterMetrics(0.31, 0.12056, 0.02778, 0, 0.5),
    97: TexCharacterMetrics(0, 0.43056, 0, 0, 0.5),
    98: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55556),
    99: TexCharacterMetrics(0, 0.43056, 0, 0, 0.44445),
    100: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55556),
    101: TexCharacterMetrics(0, 0.43056, 0, 0, 0.44445),
    102: TexCharacterMetrics(0, 0.69444, 0.07778, 0, 0.30556),
    103: TexCharacterMetrics(0.19444, 0.43056, 0.01389, 0, 0.5),
    104: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55556),
    105: TexCharacterMetrics(0, 0.66786, 0, 0, 0.27778),
    106: TexCharacterMetrics(0.19444, 0.66786, 0, 0, 0.30556),
    107: TexCharacterMetrics(0, 0.69444, 0, 0, 0.52778),
    108: TexCharacterMetrics(0, 0.69444, 0, 0, 0.27778),
    109: TexCharacterMetrics(0, 0.43056, 0, 0, 0.83334),
    110: TexCharacterMetrics(0, 0.43056, 0, 0, 0.55556),
    111: TexCharacterMetrics(0, 0.43056, 0, 0, 0.5),
    112: TexCharacterMetrics(0.19444, 0.43056, 0, 0, 0.55556),
    113: TexCharacterMetrics(0.19444, 0.43056, 0, 0, 0.52778),
    114: TexCharacterMetrics(0, 0.43056, 0, 0, 0.39167),
    115: TexCharacterMetrics(0, 0.43056, 0, 0, 0.39445),
    116: TexCharacterMetrics(0, 0.61508, 0, 0, 0.38889),
    117: TexCharacterMetrics(0, 0.43056, 0, 0, 0.55556),
    118: TexCharacterMetrics(0, 0.43056, 0.01389, 0, 0.52778),
    119: TexCharacterMetrics(0, 0.43056, 0.01389, 0, 0.72222),
    120: TexCharacterMetrics(0, 0.43056, 0, 0, 0.52778),
    121: TexCharacterMetrics(0.19444, 0.43056, 0.01389, 0, 0.52778),
    122: TexCharacterMetrics(0, 0.43056, 0, 0, 0.44445),
    123: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.5),
    124: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.27778),
    125: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.5),
    126: TexCharacterMetrics(0.35, 0.31786, 0, 0, 0.5),
    160: TexCharacterMetrics(0, 0, 0, 0, 0.25),
    167: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.44445),
    168: TexCharacterMetrics(0, 0.66786, 0, 0, 0.5),
    172: TexCharacterMetrics(0, 0.43056, 0, 0, 0.66667),
    176: TexCharacterMetrics(0, 0.69444, 0, 0, 0.75),
    177: TexCharacterMetrics(0.08333, 0.58333, 0, 0, 0.77778),
    182: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.61111),
    184: TexCharacterMetrics(0.17014, 0, 0, 0, 0.44445),
    198: TexCharacterMetrics(0, 0.68333, 0, 0, 0.90278),
    215: TexCharacterMetrics(0.08333, 0.58333, 0, 0, 0.77778),
    216: TexCharacterMetrics(0.04861, 0.73194, 0, 0, 0.77778),
    223: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    230: TexCharacterMetrics(0, 0.43056, 0, 0, 0.72222),
    247: TexCharacterMetrics(0.08333, 0.58333, 0, 0, 0.77778),
    248: TexCharacterMetrics(0.09722, 0.52778, 0, 0, 0.5),
    305: TexCharacterMetrics(0, 0.43056, 0, 0, 0.27778),
    338: TexCharacterMetrics(0, 0.68333, 0, 0, 1.01389),
    339: TexCharacterMetrics(0, 0.43056, 0, 0, 0.77778),
    567: TexCharacterMetrics(0.19444, 0.43056, 0, 0, 0.30556),
    710: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    711: TexCharacterMetrics(0, 0.62847, 0, 0, 0.5),
    713: TexCharacterMetrics(0, 0.56778, 0, 0, 0.5),
    714: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    715: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    728: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    729: TexCharacterMetrics(0, 0.66786, 0, 0, 0.27778),
    730: TexCharacterMetrics(0, 0.69444, 0, 0, 0.75),
    732: TexCharacterMetrics(0, 0.66786, 0, 0, 0.5),
    733: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    915: TexCharacterMetrics(0, 0.68333, 0, 0, 0.625),
    916: TexCharacterMetrics(0, 0.68333, 0, 0, 0.83334),
    920: TexCharacterMetrics(0, 0.68333, 0, 0, 0.77778),
    923: TexCharacterMetrics(0, 0.68333, 0, 0, 0.69445),
    926: TexCharacterMetrics(0, 0.68333, 0, 0, 0.66667),
    928: TexCharacterMetrics(0, 0.68333, 0, 0, 0.75),
    931: TexCharacterMetrics(0, 0.68333, 0, 0, 0.72222),
    933: TexCharacterMetrics(0, 0.68333, 0, 0, 0.77778),
    934: TexCharacterMetrics(0, 0.68333, 0, 0, 0.72222),
    936: TexCharacterMetrics(0, 0.68333, 0, 0, 0.77778),
    937: TexCharacterMetrics(0, 0.68333, 0, 0, 0.72222),
    8211: TexCharacterMetrics(0, 0.43056, 0.02778, 0, 0.5),
    8212: TexCharacterMetrics(0, 0.43056, 0.02778, 0, 1.0),
    8216: TexCharacterMetrics(0, 0.69444, 0, 0, 0.27778),
    8217: TexCharacterMetrics(0, 0.69444, 0, 0, 0.27778),
    8220: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    8221: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    8224: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.44445),
    8225: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.44445),
    8230: TexCharacterMetrics(0, 0.12, 0, 0, 1.172),
    8242: TexCharacterMetrics(0, 0.55556, 0, 0, 0.275),
    8407: TexCharacterMetrics(0, 0.71444, 0.15382, 0, 0.5),
    8463: TexCharacterMetrics(0, 0.68889, 0, 0, 0.54028),
    8465: TexCharacterMetrics(0, 0.69444, 0, 0, 0.72222),
    8467: TexCharacterMetrics(0, 0.69444, 0, 0.11111, 0.41667),
    8472: TexCharacterMetrics(0.19444, 0.43056, 0, 0.11111, 0.63646),
    8476: TexCharacterMetrics(0, 0.69444, 0, 0, 0.72222),
    8501: TexCharacterMetrics(0, 0.69444, 0, 0, 0.61111),
    8592: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8593: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.5),
    8594: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8595: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.5),
    8596: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8597: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.5),
    8598: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 1.0),
    8599: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 1.0),
    8600: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 1.0),
    8601: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 1.0),
    8614: TexCharacterMetrics(0.011, 0.511, 0, 0, 1.0),
    8617: TexCharacterMetrics(0.011, 0.511, 0, 0, 1.126),
    8618: TexCharacterMetrics(0.011, 0.511, 0, 0, 1.126),
    8636: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8637: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8640: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8641: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8652: TexCharacterMetrics(0.011, 0.671, 0, 0, 1.0),
    8656: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8657: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.61111),
    8658: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8659: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.61111),
    8660: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 1.0),
    8661: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.61111),
    8704: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55556),
    8706: TexCharacterMetrics(0, 0.69444, 0.05556, 0.08334, 0.5309),
    8707: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55556),
    8709: TexCharacterMetrics(0.05556, 0.75, 0, 0, 0.5),
    8711: TexCharacterMetrics(0, 0.68333, 0, 0, 0.83334),
    8712: TexCharacterMetrics(0.0391, 0.5391, 0, 0, 0.66667),
    8715: TexCharacterMetrics(0.0391, 0.5391, 0, 0, 0.66667),
    8722: TexCharacterMetrics(0.08333, 0.58333, 0, 0, 0.77778),
    8723: TexCharacterMetrics(0.08333, 0.58333, 0, 0, 0.77778),
    8725: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.5),
    8726: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.5),
    8727: TexCharacterMetrics(-0.03472, 0.46528, 0, 0, 0.5),
    8728: TexCharacterMetrics(-0.05555, 0.44445, 0, 0, 0.5),
    8729: TexCharacterMetrics(-0.05555, 0.44445, 0, 0, 0.5),
    8730: TexCharacterMetrics(0.2, 0.8, 0, 0, 0.83334),
    8733: TexCharacterMetrics(0, 0.43056, 0, 0, 0.77778),
    8734: TexCharacterMetrics(0, 0.43056, 0, 0, 1.0),
    8736: TexCharacterMetrics(0, 0.69224, 0, 0, 0.72222),
    8739: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.27778),
    8741: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.5),
    8743: TexCharacterMetrics(0, 0.55556, 0, 0, 0.66667),
    8744: TexCharacterMetrics(0, 0.55556, 0, 0, 0.66667),
    8745: TexCharacterMetrics(0, 0.55556, 0, 0, 0.66667),
    8746: TexCharacterMetrics(0, 0.55556, 0, 0, 0.66667),
    8747: TexCharacterMetrics(0.19444, 0.69444, 0.11111, 0, 0.41667),
    8764: TexCharacterMetrics(-0.13313, 0.36687, 0, 0, 0.77778),
    8768: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.27778),
    8771: TexCharacterMetrics(-0.03625, 0.46375, 0, 0, 0.77778),
    8773: TexCharacterMetrics(-0.022, 0.589, 0, 0, 1.0),
    8776: TexCharacterMetrics(-0.01688, 0.48312, 0, 0, 0.77778),
    8781: TexCharacterMetrics(-0.03625, 0.46375, 0, 0, 0.77778),
    8784: TexCharacterMetrics(-0.133, 0.67, 0, 0, 0.778),
    8801: TexCharacterMetrics(-0.03625, 0.46375, 0, 0, 0.77778),
    8804: TexCharacterMetrics(0.13597, 0.63597, 0, 0, 0.77778),
    8805: TexCharacterMetrics(0.13597, 0.63597, 0, 0, 0.77778),
    8810: TexCharacterMetrics(0.0391, 0.5391, 0, 0, 1.0),
    8811: TexCharacterMetrics(0.0391, 0.5391, 0, 0, 1.0),
    8826: TexCharacterMetrics(0.0391, 0.5391, 0, 0, 0.77778),
    8827: TexCharacterMetrics(0.0391, 0.5391, 0, 0, 0.77778),
    8834: TexCharacterMetrics(0.0391, 0.5391, 0, 0, 0.77778),
    8835: TexCharacterMetrics(0.0391, 0.5391, 0, 0, 0.77778),
    8838: TexCharacterMetrics(0.13597, 0.63597, 0, 0, 0.77778),
    8839: TexCharacterMetrics(0.13597, 0.63597, 0, 0, 0.77778),
    8846: TexCharacterMetrics(0, 0.55556, 0, 0, 0.66667),
    8849: TexCharacterMetrics(0.13597, 0.63597, 0, 0, 0.77778),
    8850: TexCharacterMetrics(0.13597, 0.63597, 0, 0, 0.77778),
    8851: TexCharacterMetrics(0, 0.55556, 0, 0, 0.66667),
    8852: TexCharacterMetrics(0, 0.55556, 0, 0, 0.66667),
    8853: TexCharacterMetrics(0.08333, 0.58333, 0, 0, 0.77778),
    8854: TexCharacterMetrics(0.08333, 0.58333, 0, 0, 0.77778),
    8855: TexCharacterMetrics(0.08333, 0.58333, 0, 0, 0.77778),
    8856: TexCharacterMetrics(0.08333, 0.58333, 0, 0, 0.77778),
    8857: TexCharacterMetrics(0.08333, 0.58333, 0, 0, 0.77778),
    8866: TexCharacterMetrics(0, 0.69444, 0, 0, 0.61111),
    8867: TexCharacterMetrics(0, 0.69444, 0, 0, 0.61111),
    8868: TexCharacterMetrics(0, 0.69444, 0, 0, 0.77778),
    8869: TexCharacterMetrics(0, 0.69444, 0, 0, 0.77778),
    8872: TexCharacterMetrics(0.249, 0.75, 0, 0, 0.867),
    8900: TexCharacterMetrics(-0.05555, 0.44445, 0, 0, 0.5),
    8901: TexCharacterMetrics(-0.05555, 0.44445, 0, 0, 0.27778),
    8902: TexCharacterMetrics(-0.03472, 0.46528, 0, 0, 0.5),
    8904: TexCharacterMetrics(0.005, 0.505, 0, 0, 0.9),
    8942: TexCharacterMetrics(0.03, 0.9, 0, 0, 0.278),
    8943: TexCharacterMetrics(-0.19, 0.31, 0, 0, 1.172),
    8945: TexCharacterMetrics(-0.1, 0.82, 0, 0, 1.282),
    8968: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.44445),
    8969: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.44445),
    8970: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.44445),
    8971: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.44445),
    8994: TexCharacterMetrics(-0.14236, 0.35764, 0, 0, 1.0),
    8995: TexCharacterMetrics(-0.14236, 0.35764, 0, 0, 1.0),
    9136: TexCharacterMetrics(0.244, 0.744, 0, 0, 0.412),
    9137: TexCharacterMetrics(0.244, 0.744, 0, 0, 0.412),
    9651: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.88889),
    9657: TexCharacterMetrics(-0.03472, 0.46528, 0, 0, 0.5),
    9661: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.88889),
    9667: TexCharacterMetrics(-0.03472, 0.46528, 0, 0, 0.5),
    9711: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 1.0),
    9824: TexCharacterMetrics(0.12963, 0.69444, 0, 0, 0.77778),
    9825: TexCharacterMetrics(0.12963, 0.69444, 0, 0, 0.77778),
    9826: TexCharacterMetrics(0.12963, 0.69444, 0, 0, 0.77778),
    9827: TexCharacterMetrics(0.12963, 0.69444, 0, 0, 0.77778),
    9837: TexCharacterMetrics(0, 0.75, 0, 0, 0.38889),
    9838: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.38889),
    9839: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.38889),
    10216: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.38889),
    10217: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.38889),
    10222: TexCharacterMetrics(0.244, 0.744, 0, 0, 0.412),
    10223: TexCharacterMetrics(0.244, 0.744, 0, 0, 0.412),
    10229: TexCharacterMetrics(0.011, 0.511, 0, 0, 1.609),
    10230: TexCharacterMetrics(0.011, 0.511, 0, 0, 1.638),
    10231: TexCharacterMetrics(0.011, 0.511, 0, 0, 1.859),
    10232: TexCharacterMetrics(0.024, 0.525, 0, 0, 1.609),
    10233: TexCharacterMetrics(0.024, 0.525, 0, 0, 1.638),
    10234: TexCharacterMetrics(0.024, 0.525, 0, 0, 1.858),
    10236: TexCharacterMetrics(0.011, 0.511, 0, 0, 1.638),
    10815: TexCharacterMetrics(0, 0.68333, 0, 0, 0.75),
    10927: TexCharacterMetrics(0.13597, 0.63597, 0, 0, 0.77778),
    10928: TexCharacterMetrics(0.13597, 0.63597, 0, 0, 0.77778),
    57376: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0),
  },
  "Math-BoldItalic": {
    65: TexCharacterMetrics(0, 0.68611, 0, 0, 0.86944),
    66: TexCharacterMetrics(0, 0.68611, 0.04835, 0, 0.8664),
    67: TexCharacterMetrics(0, 0.68611, 0.06979, 0, 0.81694),
    68: TexCharacterMetrics(0, 0.68611, 0.03194, 0, 0.93812),
    69: TexCharacterMetrics(0, 0.68611, 0.05451, 0, 0.81007),
    70: TexCharacterMetrics(0, 0.68611, 0.15972, 0, 0.68889),
    71: TexCharacterMetrics(0, 0.68611, 0, 0, 0.88673),
    72: TexCharacterMetrics(0, 0.68611, 0.08229, 0, 0.98229),
    73: TexCharacterMetrics(0, 0.68611, 0.07778, 0, 0.51111),
    74: TexCharacterMetrics(0, 0.68611, 0.10069, 0, 0.63125),
    75: TexCharacterMetrics(0, 0.68611, 0.06979, 0, 0.97118),
    76: TexCharacterMetrics(0, 0.68611, 0, 0, 0.75555),
    77: TexCharacterMetrics(0, 0.68611, 0.11424, 0, 1.14201),
    78: TexCharacterMetrics(0, 0.68611, 0.11424, 0, 0.95034),
    79: TexCharacterMetrics(0, 0.68611, 0.03194, 0, 0.83666),
    80: TexCharacterMetrics(0, 0.68611, 0.15972, 0, 0.72309),
    81: TexCharacterMetrics(0.19444, 0.68611, 0, 0, 0.86861),
    82: TexCharacterMetrics(0, 0.68611, 0.00421, 0, 0.87235),
    83: TexCharacterMetrics(0, 0.68611, 0.05382, 0, 0.69271),
    84: TexCharacterMetrics(0, 0.68611, 0.15972, 0, 0.63663),
    85: TexCharacterMetrics(0, 0.68611, 0.11424, 0, 0.80027),
    86: TexCharacterMetrics(0, 0.68611, 0.25555, 0, 0.67778),
    87: TexCharacterMetrics(0, 0.68611, 0.15972, 0, 1.09305),
    88: TexCharacterMetrics(0, 0.68611, 0.07778, 0, 0.94722),
    89: TexCharacterMetrics(0, 0.68611, 0.25555, 0, 0.67458),
    90: TexCharacterMetrics(0, 0.68611, 0.06979, 0, 0.77257),
    97: TexCharacterMetrics(0, 0.44444, 0, 0, 0.63287),
    98: TexCharacterMetrics(0, 0.69444, 0, 0, 0.52083),
    99: TexCharacterMetrics(0, 0.44444, 0, 0, 0.51342),
    100: TexCharacterMetrics(0, 0.69444, 0, 0, 0.60972),
    101: TexCharacterMetrics(0, 0.44444, 0, 0, 0.55361),
    102: TexCharacterMetrics(0.19444, 0.69444, 0.11042, 0, 0.56806),
    103: TexCharacterMetrics(0.19444, 0.44444, 0.03704, 0, 0.5449),
    104: TexCharacterMetrics(0, 0.69444, 0, 0, 0.66759),
    105: TexCharacterMetrics(0, 0.69326, 0, 0, 0.4048),
    106: TexCharacterMetrics(0.19444, 0.69326, 0.0622, 0, 0.47083),
    107: TexCharacterMetrics(0, 0.69444, 0.01852, 0, 0.6037),
    108: TexCharacterMetrics(0, 0.69444, 0.0088, 0, 0.34815),
    109: TexCharacterMetrics(0, 0.44444, 0, 0, 1.0324),
    110: TexCharacterMetrics(0, 0.44444, 0, 0, 0.71296),
    111: TexCharacterMetrics(0, 0.44444, 0, 0, 0.58472),
    112: TexCharacterMetrics(0.19444, 0.44444, 0, 0, 0.60092),
    113: TexCharacterMetrics(0.19444, 0.44444, 0.03704, 0, 0.54213),
    114: TexCharacterMetrics(0, 0.44444, 0.03194, 0, 0.5287),
    115: TexCharacterMetrics(0, 0.44444, 0, 0, 0.53125),
    116: TexCharacterMetrics(0, 0.63492, 0, 0, 0.41528),
    117: TexCharacterMetrics(0, 0.44444, 0, 0, 0.68102),
    118: TexCharacterMetrics(0, 0.44444, 0.03704, 0, 0.56666),
    119: TexCharacterMetrics(0, 0.44444, 0.02778, 0, 0.83148),
    120: TexCharacterMetrics(0, 0.44444, 0, 0, 0.65903),
    121: TexCharacterMetrics(0.19444, 0.44444, 0.03704, 0, 0.59028),
    122: TexCharacterMetrics(0, 0.44444, 0.04213, 0, 0.55509),
    915: TexCharacterMetrics(0, 0.68611, 0.15972, 0, 0.65694),
    916: TexCharacterMetrics(0, 0.68611, 0, 0, 0.95833),
    920: TexCharacterMetrics(0, 0.68611, 0.03194, 0, 0.86722),
    923: TexCharacterMetrics(0, 0.68611, 0, 0, 0.80555),
    926: TexCharacterMetrics(0, 0.68611, 0.07458, 0, 0.84125),
    928: TexCharacterMetrics(0, 0.68611, 0.08229, 0, 0.98229),
    931: TexCharacterMetrics(0, 0.68611, 0.05451, 0, 0.88507),
    933: TexCharacterMetrics(0, 0.68611, 0.15972, 0, 0.67083),
    934: TexCharacterMetrics(0, 0.68611, 0, 0, 0.76666),
    936: TexCharacterMetrics(0, 0.68611, 0.11653, 0, 0.71402),
    937: TexCharacterMetrics(0, 0.68611, 0.04835, 0, 0.8789),
    945: TexCharacterMetrics(0, 0.44444, 0, 0, 0.76064),
    946: TexCharacterMetrics(0.19444, 0.69444, 0.03403, 0, 0.65972),
    947: TexCharacterMetrics(0.19444, 0.44444, 0.06389, 0, 0.59003),
    948: TexCharacterMetrics(0, 0.69444, 0.03819, 0, 0.52222),
    949: TexCharacterMetrics(0, 0.44444, 0, 0, 0.52882),
    950: TexCharacterMetrics(0.19444, 0.69444, 0.06215, 0, 0.50833),
    951: TexCharacterMetrics(0.19444, 0.44444, 0.03704, 0, 0.6),
    952: TexCharacterMetrics(0, 0.69444, 0.03194, 0, 0.5618),
    953: TexCharacterMetrics(0, 0.44444, 0, 0, 0.41204),
    954: TexCharacterMetrics(0, 0.44444, 0, 0, 0.66759),
    955: TexCharacterMetrics(0, 0.69444, 0, 0, 0.67083),
    956: TexCharacterMetrics(0.19444, 0.44444, 0, 0, 0.70787),
    957: TexCharacterMetrics(0, 0.44444, 0.06898, 0, 0.57685),
    958: TexCharacterMetrics(0.19444, 0.69444, 0.03021, 0, 0.50833),
    959: TexCharacterMetrics(0, 0.44444, 0, 0, 0.58472),
    960: TexCharacterMetrics(0, 0.44444, 0.03704, 0, 0.68241),
    961: TexCharacterMetrics(0.19444, 0.44444, 0, 0, 0.6118),
    962: TexCharacterMetrics(0.09722, 0.44444, 0.07917, 0, 0.42361),
    963: TexCharacterMetrics(0, 0.44444, 0.03704, 0, 0.68588),
    964: TexCharacterMetrics(0, 0.44444, 0.13472, 0, 0.52083),
    965: TexCharacterMetrics(0, 0.44444, 0.03704, 0, 0.63055),
    966: TexCharacterMetrics(0.19444, 0.44444, 0, 0, 0.74722),
    967: TexCharacterMetrics(0.19444, 0.44444, 0, 0, 0.71805),
    968: TexCharacterMetrics(0.19444, 0.69444, 0.03704, 0, 0.75833),
    969: TexCharacterMetrics(0, 0.44444, 0.03704, 0, 0.71782),
    977: TexCharacterMetrics(0, 0.69444, 0, 0, 0.69155),
    981: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.7125),
    982: TexCharacterMetrics(0, 0.44444, 0.03194, 0, 0.975),
    1009: TexCharacterMetrics(0.19444, 0.44444, 0, 0, 0.6118),
    1013: TexCharacterMetrics(0, 0.44444, 0, 0, 0.48333),
  },
  "Math-Italic": {
    65: TexCharacterMetrics(0, 0.68333, 0, 0.13889, 0.75),
    66: TexCharacterMetrics(0, 0.68333, 0.05017, 0.08334, 0.75851),
    67: TexCharacterMetrics(0, 0.68333, 0.07153, 0.08334, 0.71472),
    68: TexCharacterMetrics(0, 0.68333, 0.02778, 0.05556, 0.82792),
    69: TexCharacterMetrics(0, 0.68333, 0.05764, 0.08334, 0.7382),
    70: TexCharacterMetrics(0, 0.68333, 0.13889, 0.08334, 0.64306),
    71: TexCharacterMetrics(0, 0.68333, 0, 0.08334, 0.78625),
    72: TexCharacterMetrics(0, 0.68333, 0.08125, 0.05556, 0.83125),
    73: TexCharacterMetrics(0, 0.68333, 0.07847, 0.11111, 0.43958),
    74: TexCharacterMetrics(0, 0.68333, 0.09618, 0.16667, 0.55451),
    75: TexCharacterMetrics(0, 0.68333, 0.07153, 0.05556, 0.84931),
    76: TexCharacterMetrics(0, 0.68333, 0, 0.02778, 0.68056),
    77: TexCharacterMetrics(0, 0.68333, 0.10903, 0.08334, 0.97014),
    78: TexCharacterMetrics(0, 0.68333, 0.10903, 0.08334, 0.80347),
    79: TexCharacterMetrics(0, 0.68333, 0.02778, 0.08334, 0.76278),
    80: TexCharacterMetrics(0, 0.68333, 0.13889, 0.08334, 0.64201),
    81: TexCharacterMetrics(0.19444, 0.68333, 0, 0.08334, 0.79056),
    82: TexCharacterMetrics(0, 0.68333, 0.00773, 0.08334, 0.75929),
    83: TexCharacterMetrics(0, 0.68333, 0.05764, 0.08334, 0.6132),
    84: TexCharacterMetrics(0, 0.68333, 0.13889, 0.08334, 0.58438),
    85: TexCharacterMetrics(0, 0.68333, 0.10903, 0.02778, 0.68278),
    86: TexCharacterMetrics(0, 0.68333, 0.22222, 0, 0.58333),
    87: TexCharacterMetrics(0, 0.68333, 0.13889, 0, 0.94445),
    88: TexCharacterMetrics(0, 0.68333, 0.07847, 0.08334, 0.82847),
    89: TexCharacterMetrics(0, 0.68333, 0.22222, 0, 0.58056),
    90: TexCharacterMetrics(0, 0.68333, 0.07153, 0.08334, 0.68264),
    97: TexCharacterMetrics(0, 0.43056, 0, 0, 0.52859),
    98: TexCharacterMetrics(0, 0.69444, 0, 0, 0.42917),
    99: TexCharacterMetrics(0, 0.43056, 0, 0.05556, 0.43276),
    100: TexCharacterMetrics(0, 0.69444, 0, 0.16667, 0.52049),
    101: TexCharacterMetrics(0, 0.43056, 0, 0.05556, 0.46563),
    102: TexCharacterMetrics(0.19444, 0.69444, 0.10764, 0.16667, 0.48959),
    103: TexCharacterMetrics(0.19444, 0.43056, 0.03588, 0.02778, 0.47697),
    104: TexCharacterMetrics(0, 0.69444, 0, 0, 0.57616),
    105: TexCharacterMetrics(0, 0.65952, 0, 0, 0.34451),
    106: TexCharacterMetrics(0.19444, 0.65952, 0.05724, 0, 0.41181),
    107: TexCharacterMetrics(0, 0.69444, 0.03148, 0, 0.5206),
    108: TexCharacterMetrics(0, 0.69444, 0.01968, 0.08334, 0.29838),
    109: TexCharacterMetrics(0, 0.43056, 0, 0, 0.87801),
    110: TexCharacterMetrics(0, 0.43056, 0, 0, 0.60023),
    111: TexCharacterMetrics(0, 0.43056, 0, 0.05556, 0.48472),
    112: TexCharacterMetrics(0.19444, 0.43056, 0, 0.08334, 0.50313),
    113: TexCharacterMetrics(0.19444, 0.43056, 0.03588, 0.08334, 0.44641),
    114: TexCharacterMetrics(0, 0.43056, 0.02778, 0.05556, 0.45116),
    115: TexCharacterMetrics(0, 0.43056, 0, 0.05556, 0.46875),
    116: TexCharacterMetrics(0, 0.61508, 0, 0.08334, 0.36111),
    117: TexCharacterMetrics(0, 0.43056, 0, 0.02778, 0.57246),
    118: TexCharacterMetrics(0, 0.43056, 0.03588, 0.02778, 0.48472),
    119: TexCharacterMetrics(0, 0.43056, 0.02691, 0.08334, 0.71592),
    120: TexCharacterMetrics(0, 0.43056, 0, 0.02778, 0.57153),
    121: TexCharacterMetrics(0.19444, 0.43056, 0.03588, 0.05556, 0.49028),
    122: TexCharacterMetrics(0, 0.43056, 0.04398, 0.05556, 0.46505),
    915: TexCharacterMetrics(0, 0.68333, 0.13889, 0.08334, 0.61528),
    916: TexCharacterMetrics(0, 0.68333, 0, 0.16667, 0.83334),
    920: TexCharacterMetrics(0, 0.68333, 0.02778, 0.08334, 0.76278),
    923: TexCharacterMetrics(0, 0.68333, 0, 0.16667, 0.69445),
    926: TexCharacterMetrics(0, 0.68333, 0.07569, 0.08334, 0.74236),
    928: TexCharacterMetrics(0, 0.68333, 0.08125, 0.05556, 0.83125),
    931: TexCharacterMetrics(0, 0.68333, 0.05764, 0.08334, 0.77986),
    933: TexCharacterMetrics(0, 0.68333, 0.13889, 0.05556, 0.58333),
    934: TexCharacterMetrics(0, 0.68333, 0, 0.08334, 0.66667),
    936: TexCharacterMetrics(0, 0.68333, 0.11, 0.05556, 0.61222),
    937: TexCharacterMetrics(0, 0.68333, 0.05017, 0.08334, 0.7724),
    945: TexCharacterMetrics(0, 0.43056, 0.0037, 0.02778, 0.6397),
    946: TexCharacterMetrics(0.19444, 0.69444, 0.05278, 0.08334, 0.56563),
    947: TexCharacterMetrics(0.19444, 0.43056, 0.05556, 0, 0.51773),
    948: TexCharacterMetrics(0, 0.69444, 0.03785, 0.05556, 0.44444),
    949: TexCharacterMetrics(0, 0.43056, 0, 0.08334, 0.46632),
    950: TexCharacterMetrics(0.19444, 0.69444, 0.07378, 0.08334, 0.4375),
    951: TexCharacterMetrics(0.19444, 0.43056, 0.03588, 0.05556, 0.49653),
    952: TexCharacterMetrics(0, 0.69444, 0.02778, 0.08334, 0.46944),
    953: TexCharacterMetrics(0, 0.43056, 0, 0.05556, 0.35394),
    954: TexCharacterMetrics(0, 0.43056, 0, 0, 0.57616),
    955: TexCharacterMetrics(0, 0.69444, 0, 0, 0.58334),
    956: TexCharacterMetrics(0.19444, 0.43056, 0, 0.02778, 0.60255),
    957: TexCharacterMetrics(0, 0.43056, 0.06366, 0.02778, 0.49398),
    958: TexCharacterMetrics(0.19444, 0.69444, 0.04601, 0.11111, 0.4375),
    959: TexCharacterMetrics(0, 0.43056, 0, 0.05556, 0.48472),
    960: TexCharacterMetrics(0, 0.43056, 0.03588, 0, 0.57003),
    961: TexCharacterMetrics(0.19444, 0.43056, 0, 0.08334, 0.51702),
    962: TexCharacterMetrics(0.09722, 0.43056, 0.07986, 0.08334, 0.36285),
    963: TexCharacterMetrics(0, 0.43056, 0.03588, 0, 0.57141),
    964: TexCharacterMetrics(0, 0.43056, 0.1132, 0.02778, 0.43715),
    965: TexCharacterMetrics(0, 0.43056, 0.03588, 0.02778, 0.54028),
    966: TexCharacterMetrics(0.19444, 0.43056, 0, 0.08334, 0.65417),
    967: TexCharacterMetrics(0.19444, 0.43056, 0, 0.05556, 0.62569),
    968: TexCharacterMetrics(0.19444, 0.69444, 0.03588, 0.11111, 0.65139),
    969: TexCharacterMetrics(0, 0.43056, 0.03588, 0, 0.62245),
    977: TexCharacterMetrics(0, 0.69444, 0, 0.08334, 0.59144),
    981: TexCharacterMetrics(0.19444, 0.69444, 0, 0.08334, 0.59583),
    982: TexCharacterMetrics(0, 0.43056, 0.02778, 0, 0.82813),
    1009: TexCharacterMetrics(0.19444, 0.43056, 0, 0.08334, 0.51702),
    1013: TexCharacterMetrics(0, 0.43056, 0, 0.05556, 0.4059),
  },
  "SansSerif-Bold": {
    33: TexCharacterMetrics(0, 0.69444, 0, 0, 0.36667),
    34: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55834),
    35: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.91667),
    36: TexCharacterMetrics(0.05556, 0.75, 0, 0, 0.55),
    37: TexCharacterMetrics(0.05556, 0.75, 0, 0, 1.02912),
    38: TexCharacterMetrics(0, 0.69444, 0, 0, 0.83056),
    39: TexCharacterMetrics(0, 0.69444, 0, 0, 0.30556),
    40: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.42778),
    41: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.42778),
    42: TexCharacterMetrics(0, 0.75, 0, 0, 0.55),
    43: TexCharacterMetrics(0.11667, 0.61667, 0, 0, 0.85556),
    44: TexCharacterMetrics(0.10556, 0.13056, 0, 0, 0.30556),
    45: TexCharacterMetrics(0, 0.45833, 0, 0, 0.36667),
    46: TexCharacterMetrics(0, 0.13056, 0, 0, 0.30556),
    47: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.55),
    48: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    49: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    50: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    51: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    52: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    53: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    54: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    55: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    56: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    57: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    58: TexCharacterMetrics(0, 0.45833, 0, 0, 0.30556),
    59: TexCharacterMetrics(0.10556, 0.45833, 0, 0, 0.30556),
    61: TexCharacterMetrics(-0.09375, 0.40625, 0, 0, 0.85556),
    63: TexCharacterMetrics(0, 0.69444, 0, 0, 0.51945),
    64: TexCharacterMetrics(0, 0.69444, 0, 0, 0.73334),
    65: TexCharacterMetrics(0, 0.69444, 0, 0, 0.73334),
    66: TexCharacterMetrics(0, 0.69444, 0, 0, 0.73334),
    67: TexCharacterMetrics(0, 0.69444, 0, 0, 0.70278),
    68: TexCharacterMetrics(0, 0.69444, 0, 0, 0.79445),
    69: TexCharacterMetrics(0, 0.69444, 0, 0, 0.64167),
    70: TexCharacterMetrics(0, 0.69444, 0, 0, 0.61111),
    71: TexCharacterMetrics(0, 0.69444, 0, 0, 0.73334),
    72: TexCharacterMetrics(0, 0.69444, 0, 0, 0.79445),
    73: TexCharacterMetrics(0, 0.69444, 0, 0, 0.33056),
    74: TexCharacterMetrics(0, 0.69444, 0, 0, 0.51945),
    75: TexCharacterMetrics(0, 0.69444, 0, 0, 0.76389),
    76: TexCharacterMetrics(0, 0.69444, 0, 0, 0.58056),
    77: TexCharacterMetrics(0, 0.69444, 0, 0, 0.97778),
    78: TexCharacterMetrics(0, 0.69444, 0, 0, 0.79445),
    79: TexCharacterMetrics(0, 0.69444, 0, 0, 0.79445),
    80: TexCharacterMetrics(0, 0.69444, 0, 0, 0.70278),
    81: TexCharacterMetrics(0.10556, 0.69444, 0, 0, 0.79445),
    82: TexCharacterMetrics(0, 0.69444, 0, 0, 0.70278),
    83: TexCharacterMetrics(0, 0.69444, 0, 0, 0.61111),
    84: TexCharacterMetrics(0, 0.69444, 0, 0, 0.73334),
    85: TexCharacterMetrics(0, 0.69444, 0, 0, 0.76389),
    86: TexCharacterMetrics(0, 0.69444, 0.01528, 0, 0.73334),
    87: TexCharacterMetrics(0, 0.69444, 0.01528, 0, 1.03889),
    88: TexCharacterMetrics(0, 0.69444, 0, 0, 0.73334),
    89: TexCharacterMetrics(0, 0.69444, 0.0275, 0, 0.73334),
    90: TexCharacterMetrics(0, 0.69444, 0, 0, 0.67223),
    91: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.34306),
    93: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.34306),
    94: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    95: TexCharacterMetrics(0.35, 0.10833, 0.03056, 0, 0.55),
    97: TexCharacterMetrics(0, 0.45833, 0, 0, 0.525),
    98: TexCharacterMetrics(0, 0.69444, 0, 0, 0.56111),
    99: TexCharacterMetrics(0, 0.45833, 0, 0, 0.48889),
    100: TexCharacterMetrics(0, 0.69444, 0, 0, 0.56111),
    101: TexCharacterMetrics(0, 0.45833, 0, 0, 0.51111),
    102: TexCharacterMetrics(0, 0.69444, 0.07639, 0, 0.33611),
    103: TexCharacterMetrics(0.19444, 0.45833, 0.01528, 0, 0.55),
    104: TexCharacterMetrics(0, 0.69444, 0, 0, 0.56111),
    105: TexCharacterMetrics(0, 0.69444, 0, 0, 0.25556),
    106: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.28611),
    107: TexCharacterMetrics(0, 0.69444, 0, 0, 0.53056),
    108: TexCharacterMetrics(0, 0.69444, 0, 0, 0.25556),
    109: TexCharacterMetrics(0, 0.45833, 0, 0, 0.86667),
    110: TexCharacterMetrics(0, 0.45833, 0, 0, 0.56111),
    111: TexCharacterMetrics(0, 0.45833, 0, 0, 0.55),
    112: TexCharacterMetrics(0.19444, 0.45833, 0, 0, 0.56111),
    113: TexCharacterMetrics(0.19444, 0.45833, 0, 0, 0.56111),
    114: TexCharacterMetrics(0, 0.45833, 0.01528, 0, 0.37222),
    115: TexCharacterMetrics(0, 0.45833, 0, 0, 0.42167),
    116: TexCharacterMetrics(0, 0.58929, 0, 0, 0.40417),
    117: TexCharacterMetrics(0, 0.45833, 0, 0, 0.56111),
    118: TexCharacterMetrics(0, 0.45833, 0.01528, 0, 0.5),
    119: TexCharacterMetrics(0, 0.45833, 0.01528, 0, 0.74445),
    120: TexCharacterMetrics(0, 0.45833, 0, 0, 0.5),
    121: TexCharacterMetrics(0.19444, 0.45833, 0.01528, 0, 0.5),
    122: TexCharacterMetrics(0, 0.45833, 0, 0, 0.47639),
    126: TexCharacterMetrics(0.35, 0.34444, 0, 0, 0.55),
    168: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    176: TexCharacterMetrics(0, 0.69444, 0, 0, 0.73334),
    180: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    184: TexCharacterMetrics(0.17014, 0, 0, 0, 0.48889),
    305: TexCharacterMetrics(0, 0.45833, 0, 0, 0.25556),
    567: TexCharacterMetrics(0.19444, 0.45833, 0, 0, 0.28611),
    710: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    711: TexCharacterMetrics(0, 0.63542, 0, 0, 0.55),
    713: TexCharacterMetrics(0, 0.63778, 0, 0, 0.55),
    728: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    729: TexCharacterMetrics(0, 0.69444, 0, 0, 0.30556),
    730: TexCharacterMetrics(0, 0.69444, 0, 0, 0.73334),
    732: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    733: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55),
    915: TexCharacterMetrics(0, 0.69444, 0, 0, 0.58056),
    916: TexCharacterMetrics(0, 0.69444, 0, 0, 0.91667),
    920: TexCharacterMetrics(0, 0.69444, 0, 0, 0.85556),
    923: TexCharacterMetrics(0, 0.69444, 0, 0, 0.67223),
    926: TexCharacterMetrics(0, 0.69444, 0, 0, 0.73334),
    928: TexCharacterMetrics(0, 0.69444, 0, 0, 0.79445),
    931: TexCharacterMetrics(0, 0.69444, 0, 0, 0.79445),
    933: TexCharacterMetrics(0, 0.69444, 0, 0, 0.85556),
    934: TexCharacterMetrics(0, 0.69444, 0, 0, 0.79445),
    936: TexCharacterMetrics(0, 0.69444, 0, 0, 0.85556),
    937: TexCharacterMetrics(0, 0.69444, 0, 0, 0.79445),
    8211: TexCharacterMetrics(0, 0.45833, 0.03056, 0, 0.55),
    8212: TexCharacterMetrics(0, 0.45833, 0.03056, 0, 1.10001),
    8216: TexCharacterMetrics(0, 0.69444, 0, 0, 0.30556),
    8217: TexCharacterMetrics(0, 0.69444, 0, 0, 0.30556),
    8220: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55834),
    8221: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55834),
  },
  "SansSerif-Italic": {
    33: TexCharacterMetrics(0, 0.69444, 0.05733, 0, 0.31945),
    34: TexCharacterMetrics(0, 0.69444, 0.00316, 0, 0.5),
    35: TexCharacterMetrics(0.19444, 0.69444, 0.05087, 0, 0.83334),
    36: TexCharacterMetrics(0.05556, 0.75, 0.11156, 0, 0.5),
    37: TexCharacterMetrics(0.05556, 0.75, 0.03126, 0, 0.83334),
    38: TexCharacterMetrics(0, 0.69444, 0.03058, 0, 0.75834),
    39: TexCharacterMetrics(0, 0.69444, 0.07816, 0, 0.27778),
    40: TexCharacterMetrics(0.25, 0.75, 0.13164, 0, 0.38889),
    41: TexCharacterMetrics(0.25, 0.75, 0.02536, 0, 0.38889),
    42: TexCharacterMetrics(0, 0.75, 0.11775, 0, 0.5),
    43: TexCharacterMetrics(0.08333, 0.58333, 0.02536, 0, 0.77778),
    44: TexCharacterMetrics(0.125, 0.08333, 0, 0, 0.27778),
    45: TexCharacterMetrics(0, 0.44444, 0.01946, 0, 0.33333),
    46: TexCharacterMetrics(0, 0.08333, 0, 0, 0.27778),
    47: TexCharacterMetrics(0.25, 0.75, 0.13164, 0, 0.5),
    48: TexCharacterMetrics(0, 0.65556, 0.11156, 0, 0.5),
    49: TexCharacterMetrics(0, 0.65556, 0.11156, 0, 0.5),
    50: TexCharacterMetrics(0, 0.65556, 0.11156, 0, 0.5),
    51: TexCharacterMetrics(0, 0.65556, 0.11156, 0, 0.5),
    52: TexCharacterMetrics(0, 0.65556, 0.11156, 0, 0.5),
    53: TexCharacterMetrics(0, 0.65556, 0.11156, 0, 0.5),
    54: TexCharacterMetrics(0, 0.65556, 0.11156, 0, 0.5),
    55: TexCharacterMetrics(0, 0.65556, 0.11156, 0, 0.5),
    56: TexCharacterMetrics(0, 0.65556, 0.11156, 0, 0.5),
    57: TexCharacterMetrics(0, 0.65556, 0.11156, 0, 0.5),
    58: TexCharacterMetrics(0, 0.44444, 0.02502, 0, 0.27778),
    59: TexCharacterMetrics(0.125, 0.44444, 0.02502, 0, 0.27778),
    61: TexCharacterMetrics(-0.13, 0.37, 0.05087, 0, 0.77778),
    63: TexCharacterMetrics(0, 0.69444, 0.11809, 0, 0.47222),
    64: TexCharacterMetrics(0, 0.69444, 0.07555, 0, 0.66667),
    65: TexCharacterMetrics(0, 0.69444, 0, 0, 0.66667),
    66: TexCharacterMetrics(0, 0.69444, 0.08293, 0, 0.66667),
    67: TexCharacterMetrics(0, 0.69444, 0.11983, 0, 0.63889),
    68: TexCharacterMetrics(0, 0.69444, 0.07555, 0, 0.72223),
    69: TexCharacterMetrics(0, 0.69444, 0.11983, 0, 0.59722),
    70: TexCharacterMetrics(0, 0.69444, 0.13372, 0, 0.56945),
    71: TexCharacterMetrics(0, 0.69444, 0.11983, 0, 0.66667),
    72: TexCharacterMetrics(0, 0.69444, 0.08094, 0, 0.70834),
    73: TexCharacterMetrics(0, 0.69444, 0.13372, 0, 0.27778),
    74: TexCharacterMetrics(0, 0.69444, 0.08094, 0, 0.47222),
    75: TexCharacterMetrics(0, 0.69444, 0.11983, 0, 0.69445),
    76: TexCharacterMetrics(0, 0.69444, 0, 0, 0.54167),
    77: TexCharacterMetrics(0, 0.69444, 0.08094, 0, 0.875),
    78: TexCharacterMetrics(0, 0.69444, 0.08094, 0, 0.70834),
    79: TexCharacterMetrics(0, 0.69444, 0.07555, 0, 0.73611),
    80: TexCharacterMetrics(0, 0.69444, 0.08293, 0, 0.63889),
    81: TexCharacterMetrics(0.125, 0.69444, 0.07555, 0, 0.73611),
    82: TexCharacterMetrics(0, 0.69444, 0.08293, 0, 0.64584),
    83: TexCharacterMetrics(0, 0.69444, 0.09205, 0, 0.55556),
    84: TexCharacterMetrics(0, 0.69444, 0.13372, 0, 0.68056),
    85: TexCharacterMetrics(0, 0.69444, 0.08094, 0, 0.6875),
    86: TexCharacterMetrics(0, 0.69444, 0.1615, 0, 0.66667),
    87: TexCharacterMetrics(0, 0.69444, 0.1615, 0, 0.94445),
    88: TexCharacterMetrics(0, 0.69444, 0.13372, 0, 0.66667),
    89: TexCharacterMetrics(0, 0.69444, 0.17261, 0, 0.66667),
    90: TexCharacterMetrics(0, 0.69444, 0.11983, 0, 0.61111),
    91: TexCharacterMetrics(0.25, 0.75, 0.15942, 0, 0.28889),
    93: TexCharacterMetrics(0.25, 0.75, 0.08719, 0, 0.28889),
    94: TexCharacterMetrics(0, 0.69444, 0.0799, 0, 0.5),
    95: TexCharacterMetrics(0.35, 0.09444, 0.08616, 0, 0.5),
    97: TexCharacterMetrics(0, 0.44444, 0.00981, 0, 0.48056),
    98: TexCharacterMetrics(0, 0.69444, 0.03057, 0, 0.51667),
    99: TexCharacterMetrics(0, 0.44444, 0.08336, 0, 0.44445),
    100: TexCharacterMetrics(0, 0.69444, 0.09483, 0, 0.51667),
    101: TexCharacterMetrics(0, 0.44444, 0.06778, 0, 0.44445),
    102: TexCharacterMetrics(0, 0.69444, 0.21705, 0, 0.30556),
    103: TexCharacterMetrics(0.19444, 0.44444, 0.10836, 0, 0.5),
    104: TexCharacterMetrics(0, 0.69444, 0.01778, 0, 0.51667),
    105: TexCharacterMetrics(0, 0.67937, 0.09718, 0, 0.23889),
    106: TexCharacterMetrics(0.19444, 0.67937, 0.09162, 0, 0.26667),
    107: TexCharacterMetrics(0, 0.69444, 0.08336, 0, 0.48889),
    108: TexCharacterMetrics(0, 0.69444, 0.09483, 0, 0.23889),
    109: TexCharacterMetrics(0, 0.44444, 0.01778, 0, 0.79445),
    110: TexCharacterMetrics(0, 0.44444, 0.01778, 0, 0.51667),
    111: TexCharacterMetrics(0, 0.44444, 0.06613, 0, 0.5),
    112: TexCharacterMetrics(0.19444, 0.44444, 0.0389, 0, 0.51667),
    113: TexCharacterMetrics(0.19444, 0.44444, 0.04169, 0, 0.51667),
    114: TexCharacterMetrics(0, 0.44444, 0.10836, 0, 0.34167),
    115: TexCharacterMetrics(0, 0.44444, 0.0778, 0, 0.38333),
    116: TexCharacterMetrics(0, 0.57143, 0.07225, 0, 0.36111),
    117: TexCharacterMetrics(0, 0.44444, 0.04169, 0, 0.51667),
    118: TexCharacterMetrics(0, 0.44444, 0.10836, 0, 0.46111),
    119: TexCharacterMetrics(0, 0.44444, 0.10836, 0, 0.68334),
    120: TexCharacterMetrics(0, 0.44444, 0.09169, 0, 0.46111),
    121: TexCharacterMetrics(0.19444, 0.44444, 0.10836, 0, 0.46111),
    122: TexCharacterMetrics(0, 0.44444, 0.08752, 0, 0.43472),
    126: TexCharacterMetrics(0.35, 0.32659, 0.08826, 0, 0.5),
    168: TexCharacterMetrics(0, 0.67937, 0.06385, 0, 0.5),
    176: TexCharacterMetrics(0, 0.69444, 0, 0, 0.73752),
    184: TexCharacterMetrics(0.17014, 0, 0, 0, 0.44445),
    305: TexCharacterMetrics(0, 0.44444, 0.04169, 0, 0.23889),
    567: TexCharacterMetrics(0.19444, 0.44444, 0.04169, 0, 0.26667),
    710: TexCharacterMetrics(0, 0.69444, 0.0799, 0, 0.5),
    711: TexCharacterMetrics(0, 0.63194, 0.08432, 0, 0.5),
    713: TexCharacterMetrics(0, 0.60889, 0.08776, 0, 0.5),
    714: TexCharacterMetrics(0, 0.69444, 0.09205, 0, 0.5),
    715: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    728: TexCharacterMetrics(0, 0.69444, 0.09483, 0, 0.5),
    729: TexCharacterMetrics(0, 0.67937, 0.07774, 0, 0.27778),
    730: TexCharacterMetrics(0, 0.69444, 0, 0, 0.73752),
    732: TexCharacterMetrics(0, 0.67659, 0.08826, 0, 0.5),
    733: TexCharacterMetrics(0, 0.69444, 0.09205, 0, 0.5),
    915: TexCharacterMetrics(0, 0.69444, 0.13372, 0, 0.54167),
    916: TexCharacterMetrics(0, 0.69444, 0, 0, 0.83334),
    920: TexCharacterMetrics(0, 0.69444, 0.07555, 0, 0.77778),
    923: TexCharacterMetrics(0, 0.69444, 0, 0, 0.61111),
    926: TexCharacterMetrics(0, 0.69444, 0.12816, 0, 0.66667),
    928: TexCharacterMetrics(0, 0.69444, 0.08094, 0, 0.70834),
    931: TexCharacterMetrics(0, 0.69444, 0.11983, 0, 0.72222),
    933: TexCharacterMetrics(0, 0.69444, 0.09031, 0, 0.77778),
    934: TexCharacterMetrics(0, 0.69444, 0.04603, 0, 0.72222),
    936: TexCharacterMetrics(0, 0.69444, 0.09031, 0, 0.77778),
    937: TexCharacterMetrics(0, 0.69444, 0.08293, 0, 0.72222),
    8211: TexCharacterMetrics(0, 0.44444, 0.08616, 0, 0.5),
    8212: TexCharacterMetrics(0, 0.44444, 0.08616, 0, 1.0),
    8216: TexCharacterMetrics(0, 0.69444, 0.07816, 0, 0.27778),
    8217: TexCharacterMetrics(0, 0.69444, 0.07816, 0, 0.27778),
    8220: TexCharacterMetrics(0, 0.69444, 0.14205, 0, 0.5),
    8221: TexCharacterMetrics(0, 0.69444, 0.00316, 0, 0.5),
  },
  "SansSerif-Regular": {
    33: TexCharacterMetrics(0, 0.69444, 0, 0, 0.31945),
    34: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    35: TexCharacterMetrics(0.19444, 0.69444, 0, 0, 0.83334),
    36: TexCharacterMetrics(0.05556, 0.75, 0, 0, 0.5),
    37: TexCharacterMetrics(0.05556, 0.75, 0, 0, 0.83334),
    38: TexCharacterMetrics(0, 0.69444, 0, 0, 0.75834),
    39: TexCharacterMetrics(0, 0.69444, 0, 0, 0.27778),
    40: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.38889),
    41: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.38889),
    42: TexCharacterMetrics(0, 0.75, 0, 0, 0.5),
    43: TexCharacterMetrics(0.08333, 0.58333, 0, 0, 0.77778),
    44: TexCharacterMetrics(0.125, 0.08333, 0, 0, 0.27778),
    45: TexCharacterMetrics(0, 0.44444, 0, 0, 0.33333),
    46: TexCharacterMetrics(0, 0.08333, 0, 0, 0.27778),
    47: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.5),
    48: TexCharacterMetrics(0, 0.65556, 0, 0, 0.5),
    49: TexCharacterMetrics(0, 0.65556, 0, 0, 0.5),
    50: TexCharacterMetrics(0, 0.65556, 0, 0, 0.5),
    51: TexCharacterMetrics(0, 0.65556, 0, 0, 0.5),
    52: TexCharacterMetrics(0, 0.65556, 0, 0, 0.5),
    53: TexCharacterMetrics(0, 0.65556, 0, 0, 0.5),
    54: TexCharacterMetrics(0, 0.65556, 0, 0, 0.5),
    55: TexCharacterMetrics(0, 0.65556, 0, 0, 0.5),
    56: TexCharacterMetrics(0, 0.65556, 0, 0, 0.5),
    57: TexCharacterMetrics(0, 0.65556, 0, 0, 0.5),
    58: TexCharacterMetrics(0, 0.44444, 0, 0, 0.27778),
    59: TexCharacterMetrics(0.125, 0.44444, 0, 0, 0.27778),
    61: TexCharacterMetrics(-0.13, 0.37, 0, 0, 0.77778),
    63: TexCharacterMetrics(0, 0.69444, 0, 0, 0.47222),
    64: TexCharacterMetrics(0, 0.69444, 0, 0, 0.66667),
    65: TexCharacterMetrics(0, 0.69444, 0, 0, 0.66667),
    66: TexCharacterMetrics(0, 0.69444, 0, 0, 0.66667),
    67: TexCharacterMetrics(0, 0.69444, 0, 0, 0.63889),
    68: TexCharacterMetrics(0, 0.69444, 0, 0, 0.72223),
    69: TexCharacterMetrics(0, 0.69444, 0, 0, 0.59722),
    70: TexCharacterMetrics(0, 0.69444, 0, 0, 0.56945),
    71: TexCharacterMetrics(0, 0.69444, 0, 0, 0.66667),
    72: TexCharacterMetrics(0, 0.69444, 0, 0, 0.70834),
    73: TexCharacterMetrics(0, 0.69444, 0, 0, 0.27778),
    74: TexCharacterMetrics(0, 0.69444, 0, 0, 0.47222),
    75: TexCharacterMetrics(0, 0.69444, 0, 0, 0.69445),
    76: TexCharacterMetrics(0, 0.69444, 0, 0, 0.54167),
    77: TexCharacterMetrics(0, 0.69444, 0, 0, 0.875),
    78: TexCharacterMetrics(0, 0.69444, 0, 0, 0.70834),
    79: TexCharacterMetrics(0, 0.69444, 0, 0, 0.73611),
    80: TexCharacterMetrics(0, 0.69444, 0, 0, 0.63889),
    81: TexCharacterMetrics(0.125, 0.69444, 0, 0, 0.73611),
    82: TexCharacterMetrics(0, 0.69444, 0, 0, 0.64584),
    83: TexCharacterMetrics(0, 0.69444, 0, 0, 0.55556),
    84: TexCharacterMetrics(0, 0.69444, 0, 0, 0.68056),
    85: TexCharacterMetrics(0, 0.69444, 0, 0, 0.6875),
    86: TexCharacterMetrics(0, 0.69444, 0.01389, 0, 0.66667),
    87: TexCharacterMetrics(0, 0.69444, 0.01389, 0, 0.94445),
    88: TexCharacterMetrics(0, 0.69444, 0, 0, 0.66667),
    89: TexCharacterMetrics(0, 0.69444, 0.025, 0, 0.66667),
    90: TexCharacterMetrics(0, 0.69444, 0, 0, 0.61111),
    91: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.28889),
    93: TexCharacterMetrics(0.25, 0.75, 0, 0, 0.28889),
    94: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    95: TexCharacterMetrics(0.35, 0.09444, 0.02778, 0, 0.5),
    97: TexCharacterMetrics(0, 0.44444, 0, 0, 0.48056),
    98: TexCharacterMetrics(0, 0.69444, 0, 0, 0.51667),
    99: TexCharacterMetrics(0, 0.44444, 0, 0, 0.44445),
    100: TexCharacterMetrics(0, 0.69444, 0, 0, 0.51667),
    101: TexCharacterMetrics(0, 0.44444, 0, 0, 0.44445),
    102: TexCharacterMetrics(0, 0.69444, 0.06944, 0, 0.30556),
    103: TexCharacterMetrics(0.19444, 0.44444, 0.01389, 0, 0.5),
    104: TexCharacterMetrics(0, 0.69444, 0, 0, 0.51667),
    105: TexCharacterMetrics(0, 0.67937, 0, 0, 0.23889),
    106: TexCharacterMetrics(0.19444, 0.67937, 0, 0, 0.26667),
    107: TexCharacterMetrics(0, 0.69444, 0, 0, 0.48889),
    108: TexCharacterMetrics(0, 0.69444, 0, 0, 0.23889),
    109: TexCharacterMetrics(0, 0.44444, 0, 0, 0.79445),
    110: TexCharacterMetrics(0, 0.44444, 0, 0, 0.51667),
    111: TexCharacterMetrics(0, 0.44444, 0, 0, 0.5),
    112: TexCharacterMetrics(0.19444, 0.44444, 0, 0, 0.51667),
    113: TexCharacterMetrics(0.19444, 0.44444, 0, 0, 0.51667),
    114: TexCharacterMetrics(0, 0.44444, 0.01389, 0, 0.34167),
    115: TexCharacterMetrics(0, 0.44444, 0, 0, 0.38333),
    116: TexCharacterMetrics(0, 0.57143, 0, 0, 0.36111),
    117: TexCharacterMetrics(0, 0.44444, 0, 0, 0.51667),
    118: TexCharacterMetrics(0, 0.44444, 0.01389, 0, 0.46111),
    119: TexCharacterMetrics(0, 0.44444, 0.01389, 0, 0.68334),
    120: TexCharacterMetrics(0, 0.44444, 0, 0, 0.46111),
    121: TexCharacterMetrics(0.19444, 0.44444, 0.01389, 0, 0.46111),
    122: TexCharacterMetrics(0, 0.44444, 0, 0, 0.43472),
    126: TexCharacterMetrics(0.35, 0.32659, 0, 0, 0.5),
    168: TexCharacterMetrics(0, 0.67937, 0, 0, 0.5),
    176: TexCharacterMetrics(0, 0.69444, 0, 0, 0.66667),
    184: TexCharacterMetrics(0.17014, 0, 0, 0, 0.44445),
    305: TexCharacterMetrics(0, 0.44444, 0, 0, 0.23889),
    567: TexCharacterMetrics(0.19444, 0.44444, 0, 0, 0.26667),
    710: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    711: TexCharacterMetrics(0, 0.63194, 0, 0, 0.5),
    713: TexCharacterMetrics(0, 0.60889, 0, 0, 0.5),
    714: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    715: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    728: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    729: TexCharacterMetrics(0, 0.67937, 0, 0, 0.27778),
    730: TexCharacterMetrics(0, 0.69444, 0, 0, 0.66667),
    732: TexCharacterMetrics(0, 0.67659, 0, 0, 0.5),
    733: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    915: TexCharacterMetrics(0, 0.69444, 0, 0, 0.54167),
    916: TexCharacterMetrics(0, 0.69444, 0, 0, 0.83334),
    920: TexCharacterMetrics(0, 0.69444, 0, 0, 0.77778),
    923: TexCharacterMetrics(0, 0.69444, 0, 0, 0.61111),
    926: TexCharacterMetrics(0, 0.69444, 0, 0, 0.66667),
    928: TexCharacterMetrics(0, 0.69444, 0, 0, 0.70834),
    931: TexCharacterMetrics(0, 0.69444, 0, 0, 0.72222),
    933: TexCharacterMetrics(0, 0.69444, 0, 0, 0.77778),
    934: TexCharacterMetrics(0, 0.69444, 0, 0, 0.72222),
    936: TexCharacterMetrics(0, 0.69444, 0, 0, 0.77778),
    937: TexCharacterMetrics(0, 0.69444, 0, 0, 0.72222),
    8211: TexCharacterMetrics(0, 0.44444, 0.02778, 0, 0.5),
    8212: TexCharacterMetrics(0, 0.44444, 0.02778, 0, 1.0),
    8216: TexCharacterMetrics(0, 0.69444, 0, 0, 0.27778),
    8217: TexCharacterMetrics(0, 0.69444, 0, 0, 0.27778),
    8220: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
    8221: TexCharacterMetrics(0, 0.69444, 0, 0, 0.5),
  },
  "Script-Regular": {
    65: TexCharacterMetrics(0, 0.7, 0.22925, 0, 0.80253),
    66: TexCharacterMetrics(0, 0.7, 0.04087, 0, 0.90757),
    67: TexCharacterMetrics(0, 0.7, 0.1689, 0, 0.66619),
    68: TexCharacterMetrics(0, 0.7, 0.09371, 0, 0.77443),
    69: TexCharacterMetrics(0, 0.7, 0.18583, 0, 0.56162),
    70: TexCharacterMetrics(0, 0.7, 0.13634, 0, 0.89544),
    71: TexCharacterMetrics(0, 0.7, 0.17322, 0, 0.60961),
    72: TexCharacterMetrics(0, 0.7, 0.29694, 0, 0.96919),
    73: TexCharacterMetrics(0, 0.7, 0.19189, 0, 0.80907),
    74: TexCharacterMetrics(0.27778, 0.7, 0.19189, 0, 1.05159),
    75: TexCharacterMetrics(0, 0.7, 0.31259, 0, 0.91364),
    76: TexCharacterMetrics(0, 0.7, 0.19189, 0, 0.87373),
    77: TexCharacterMetrics(0, 0.7, 0.15981, 0, 1.08031),
    78: TexCharacterMetrics(0, 0.7, 0.3525, 0, 0.9015),
    79: TexCharacterMetrics(0, 0.7, 0.08078, 0, 0.73787),
    80: TexCharacterMetrics(0, 0.7, 0.08078, 0, 1.01262),
    81: TexCharacterMetrics(0, 0.7, 0.03305, 0, 0.88282),
    82: TexCharacterMetrics(0, 0.7, 0.06259, 0, 0.85),
    83: TexCharacterMetrics(0, 0.7, 0.19189, 0, 0.86767),
    84: TexCharacterMetrics(0, 0.7, 0.29087, 0, 0.74697),
    85: TexCharacterMetrics(0, 0.7, 0.25815, 0, 0.79996),
    86: TexCharacterMetrics(0, 0.7, 0.27523, 0, 0.62204),
    87: TexCharacterMetrics(0, 0.7, 0.27523, 0, 0.80532),
    88: TexCharacterMetrics(0, 0.7, 0.26006, 0, 0.94445),
    89: TexCharacterMetrics(0, 0.7, 0.2939, 0, 0.70961),
    90: TexCharacterMetrics(0, 0.7, 0.24037, 0, 0.8212),
  },
  "Size1-Regular": {
    40: TexCharacterMetrics(0.35001, 0.85, 0, 0, 0.45834),
    41: TexCharacterMetrics(0.35001, 0.85, 0, 0, 0.45834),
    47: TexCharacterMetrics(0.35001, 0.85, 0, 0, 0.57778),
    91: TexCharacterMetrics(0.35001, 0.85, 0, 0, 0.41667),
    92: TexCharacterMetrics(0.35001, 0.85, 0, 0, 0.57778),
    93: TexCharacterMetrics(0.35001, 0.85, 0, 0, 0.41667),
    123: TexCharacterMetrics(0.35001, 0.85, 0, 0, 0.58334),
    125: TexCharacterMetrics(0.35001, 0.85, 0, 0, 0.58334),
    710: TexCharacterMetrics(0, 0.72222, 0, 0, 0.55556),
    732: TexCharacterMetrics(0, 0.72222, 0, 0, 0.55556),
    770: TexCharacterMetrics(0, 0.72222, 0, 0, 0.55556),
    771: TexCharacterMetrics(0, 0.72222, 0, 0, 0.55556),
    8214: TexCharacterMetrics(-0.00099, 0.601, 0, 0, 0.77778),
    8593: TexCharacterMetrics(1e-05, 0.6, 0, 0, 0.66667),
    8595: TexCharacterMetrics(1e-05, 0.6, 0, 0, 0.66667),
    8657: TexCharacterMetrics(1e-05, 0.6, 0, 0, 0.77778),
    8659: TexCharacterMetrics(1e-05, 0.6, 0, 0, 0.77778),
    8719: TexCharacterMetrics(0.25001, 0.75, 0, 0, 0.94445),
    8720: TexCharacterMetrics(0.25001, 0.75, 0, 0, 0.94445),
    8721: TexCharacterMetrics(0.25001, 0.75, 0, 0, 1.05556),
    8730: TexCharacterMetrics(0.35001, 0.85, 0, 0, 1.0),
    8739: TexCharacterMetrics(-0.00599, 0.606, 0, 0, 0.33333),
    8741: TexCharacterMetrics(-0.00599, 0.606, 0, 0, 0.55556),
    8747: TexCharacterMetrics(0.30612, 0.805, 0.19445, 0, 0.47222),
    8748: TexCharacterMetrics(0.306, 0.805, 0.19445, 0, 0.47222),
    8749: TexCharacterMetrics(0.306, 0.805, 0.19445, 0, 0.47222),
    8750: TexCharacterMetrics(0.30612, 0.805, 0.19445, 0, 0.47222),
    8896: TexCharacterMetrics(0.25001, 0.75, 0, 0, 0.83334),
    8897: TexCharacterMetrics(0.25001, 0.75, 0, 0, 0.83334),
    8898: TexCharacterMetrics(0.25001, 0.75, 0, 0, 0.83334),
    8899: TexCharacterMetrics(0.25001, 0.75, 0, 0, 0.83334),
    8968: TexCharacterMetrics(0.35001, 0.85, 0, 0, 0.47222),
    8969: TexCharacterMetrics(0.35001, 0.85, 0, 0, 0.47222),
    8970: TexCharacterMetrics(0.35001, 0.85, 0, 0, 0.47222),
    8971: TexCharacterMetrics(0.35001, 0.85, 0, 0, 0.47222),
    9168: TexCharacterMetrics(-0.00099, 0.601, 0, 0, 0.66667),
    10216: TexCharacterMetrics(0.35001, 0.85, 0, 0, 0.47222),
    10217: TexCharacterMetrics(0.35001, 0.85, 0, 0, 0.47222),
    10752: TexCharacterMetrics(0.25001, 0.75, 0, 0, 1.11111),
    10753: TexCharacterMetrics(0.25001, 0.75, 0, 0, 1.11111),
    10754: TexCharacterMetrics(0.25001, 0.75, 0, 0, 1.11111),
    10756: TexCharacterMetrics(0.25001, 0.75, 0, 0, 0.83334),
    10758: TexCharacterMetrics(0.25001, 0.75, 0, 0, 0.83334),
  },
  "Size2-Regular": {
    40: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.59722),
    41: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.59722),
    47: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.81111),
    91: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.47222),
    92: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.81111),
    93: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.47222),
    123: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.66667),
    125: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.66667),
    710: TexCharacterMetrics(0, 0.75, 0, 0, 1.0),
    732: TexCharacterMetrics(0, 0.75, 0, 0, 1.0),
    770: TexCharacterMetrics(0, 0.75, 0, 0, 1.0),
    771: TexCharacterMetrics(0, 0.75, 0, 0, 1.0),
    8719: TexCharacterMetrics(0.55001, 1.05, 0, 0, 1.27778),
    8720: TexCharacterMetrics(0.55001, 1.05, 0, 0, 1.27778),
    8721: TexCharacterMetrics(0.55001, 1.05, 0, 0, 1.44445),
    8730: TexCharacterMetrics(0.65002, 1.15, 0, 0, 1.0),
    8747: TexCharacterMetrics(0.86225, 1.36, 0.44445, 0, 0.55556),
    8748: TexCharacterMetrics(0.862, 1.36, 0.44445, 0, 0.55556),
    8749: TexCharacterMetrics(0.862, 1.36, 0.44445, 0, 0.55556),
    8750: TexCharacterMetrics(0.86225, 1.36, 0.44445, 0, 0.55556),
    8896: TexCharacterMetrics(0.55001, 1.05, 0, 0, 1.11111),
    8897: TexCharacterMetrics(0.55001, 1.05, 0, 0, 1.11111),
    8898: TexCharacterMetrics(0.55001, 1.05, 0, 0, 1.11111),
    8899: TexCharacterMetrics(0.55001, 1.05, 0, 0, 1.11111),
    8968: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.52778),
    8969: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.52778),
    8970: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.52778),
    8971: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.52778),
    10216: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.61111),
    10217: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.61111),
    10752: TexCharacterMetrics(0.55001, 1.05, 0, 0, 1.51112),
    10753: TexCharacterMetrics(0.55001, 1.05, 0, 0, 1.51112),
    10754: TexCharacterMetrics(0.55001, 1.05, 0, 0, 1.51112),
    10756: TexCharacterMetrics(0.55001, 1.05, 0, 0, 1.11111),
    10758: TexCharacterMetrics(0.55001, 1.05, 0, 0, 1.11111),
  },
  "Size3-Regular": {
    40: TexCharacterMetrics(0.95003, 1.45, 0, 0, 0.73611),
    41: TexCharacterMetrics(0.95003, 1.45, 0, 0, 0.73611),
    47: TexCharacterMetrics(0.95003, 1.45, 0, 0, 1.04445),
    91: TexCharacterMetrics(0.95003, 1.45, 0, 0, 0.52778),
    92: TexCharacterMetrics(0.95003, 1.45, 0, 0, 1.04445),
    93: TexCharacterMetrics(0.95003, 1.45, 0, 0, 0.52778),
    123: TexCharacterMetrics(0.95003, 1.45, 0, 0, 0.75),
    125: TexCharacterMetrics(0.95003, 1.45, 0, 0, 0.75),
    710: TexCharacterMetrics(0, 0.75, 0, 0, 1.44445),
    732: TexCharacterMetrics(0, 0.75, 0, 0, 1.44445),
    770: TexCharacterMetrics(0, 0.75, 0, 0, 1.44445),
    771: TexCharacterMetrics(0, 0.75, 0, 0, 1.44445),
    8730: TexCharacterMetrics(0.95003, 1.45, 0, 0, 1.0),
    8968: TexCharacterMetrics(0.95003, 1.45, 0, 0, 0.58334),
    8969: TexCharacterMetrics(0.95003, 1.45, 0, 0, 0.58334),
    8970: TexCharacterMetrics(0.95003, 1.45, 0, 0, 0.58334),
    8971: TexCharacterMetrics(0.95003, 1.45, 0, 0, 0.58334),
    10216: TexCharacterMetrics(0.95003, 1.45, 0, 0, 0.75),
    10217: TexCharacterMetrics(0.95003, 1.45, 0, 0, 0.75),
  },
  "Size4-Regular": {
    40: TexCharacterMetrics(1.25003, 1.75, 0, 0, 0.79167),
    41: TexCharacterMetrics(1.25003, 1.75, 0, 0, 0.79167),
    47: TexCharacterMetrics(1.25003, 1.75, 0, 0, 1.27778),
    91: TexCharacterMetrics(1.25003, 1.75, 0, 0, 0.58334),
    92: TexCharacterMetrics(1.25003, 1.75, 0, 0, 1.27778),
    93: TexCharacterMetrics(1.25003, 1.75, 0, 0, 0.58334),
    123: TexCharacterMetrics(1.25003, 1.75, 0, 0, 0.80556),
    125: TexCharacterMetrics(1.25003, 1.75, 0, 0, 0.80556),
    710: TexCharacterMetrics(0, 0.825, 0, 0, 1.8889),
    732: TexCharacterMetrics(0, 0.825, 0, 0, 1.8889),
    770: TexCharacterMetrics(0, 0.825, 0, 0, 1.8889),
    771: TexCharacterMetrics(0, 0.825, 0, 0, 1.8889),
    8730: TexCharacterMetrics(1.25003, 1.75, 0, 0, 1.0),
    8968: TexCharacterMetrics(1.25003, 1.75, 0, 0, 0.63889),
    8969: TexCharacterMetrics(1.25003, 1.75, 0, 0, 0.63889),
    8970: TexCharacterMetrics(1.25003, 1.75, 0, 0, 0.63889),
    8971: TexCharacterMetrics(1.25003, 1.75, 0, 0, 0.63889),
    9115: TexCharacterMetrics(0.64502, 1.155, 0, 0, 0.875),
    9116: TexCharacterMetrics(1e-05, 0.6, 0, 0, 0.875),
    9117: TexCharacterMetrics(0.64502, 1.155, 0, 0, 0.875),
    9118: TexCharacterMetrics(0.64502, 1.155, 0, 0, 0.875),
    9119: TexCharacterMetrics(1e-05, 0.6, 0, 0, 0.875),
    9120: TexCharacterMetrics(0.64502, 1.155, 0, 0, 0.875),
    9121: TexCharacterMetrics(0.64502, 1.155, 0, 0, 0.66667),
    9122: TexCharacterMetrics(-0.00099, 0.601, 0, 0, 0.66667),
    9123: TexCharacterMetrics(0.64502, 1.155, 0, 0, 0.66667),
    9124: TexCharacterMetrics(0.64502, 1.155, 0, 0, 0.66667),
    9125: TexCharacterMetrics(-0.00099, 0.601, 0, 0, 0.66667),
    9126: TexCharacterMetrics(0.64502, 1.155, 0, 0, 0.66667),
    9127: TexCharacterMetrics(1e-05, 0.9, 0, 0, 0.88889),
    9128: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.88889),
    9129: TexCharacterMetrics(0.90001, 0, 0, 0, 0.88889),
    9130: TexCharacterMetrics(0, 0.3, 0, 0, 0.88889),
    9131: TexCharacterMetrics(1e-05, 0.9, 0, 0, 0.88889),
    9132: TexCharacterMetrics(0.65002, 1.15, 0, 0, 0.88889),
    9133: TexCharacterMetrics(0.90001, 0, 0, 0, 0.88889),
    9143: TexCharacterMetrics(0.88502, 0.915, 0, 0, 1.05556),
    10216: TexCharacterMetrics(1.25003, 1.75, 0, 0, 0.80556),
    10217: TexCharacterMetrics(1.25003, 1.75, 0, 0, 0.80556),
    57344: TexCharacterMetrics(-0.00499, 0.605, 0, 0, 1.05556),
    57345: TexCharacterMetrics(-0.00499, 0.605, 0, 0, 1.05556),
    57680: TexCharacterMetrics(0, 0.12, 0, 0, 0.45),
    57681: TexCharacterMetrics(0, 0.12, 0, 0, 0.45),
    57682: TexCharacterMetrics(0, 0.12, 0, 0, 0.45),
    57683: TexCharacterMetrics(0, 0.12, 0, 0, 0.45),
  },
  "Typewriter-Regular": {
    32: TexCharacterMetrics(0, 0, 0, 0, 0.525),
    33: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    34: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    35: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    36: TexCharacterMetrics(0.08333, 0.69444, 0, 0, 0.525),
    37: TexCharacterMetrics(0.08333, 0.69444, 0, 0, 0.525),
    38: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    39: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    40: TexCharacterMetrics(0.08333, 0.69444, 0, 0, 0.525),
    41: TexCharacterMetrics(0.08333, 0.69444, 0, 0, 0.525),
    42: TexCharacterMetrics(0, 0.52083, 0, 0, 0.525),
    43: TexCharacterMetrics(-0.08056, 0.53055, 0, 0, 0.525),
    44: TexCharacterMetrics(0.13889, 0.125, 0, 0, 0.525),
    45: TexCharacterMetrics(-0.08056, 0.53055, 0, 0, 0.525),
    46: TexCharacterMetrics(0, 0.125, 0, 0, 0.525),
    47: TexCharacterMetrics(0.08333, 0.69444, 0, 0, 0.525),
    48: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    49: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    50: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    51: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    52: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    53: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    54: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    55: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    56: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    57: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    58: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    59: TexCharacterMetrics(0.13889, 0.43056, 0, 0, 0.525),
    60: TexCharacterMetrics(-0.05556, 0.55556, 0, 0, 0.525),
    61: TexCharacterMetrics(-0.19549, 0.41562, 0, 0, 0.525),
    62: TexCharacterMetrics(-0.05556, 0.55556, 0, 0, 0.525),
    63: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    64: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    65: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    66: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    67: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    68: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    69: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    70: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    71: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    72: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    73: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    74: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    75: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    76: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    77: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    78: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    79: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    80: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    81: TexCharacterMetrics(0.13889, 0.61111, 0, 0, 0.525),
    82: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    83: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    84: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    85: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    86: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    87: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    88: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    89: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    90: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    91: TexCharacterMetrics(0.08333, 0.69444, 0, 0, 0.525),
    92: TexCharacterMetrics(0.08333, 0.69444, 0, 0, 0.525),
    93: TexCharacterMetrics(0.08333, 0.69444, 0, 0, 0.525),
    94: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    95: TexCharacterMetrics(0.09514, 0, 0, 0, 0.525),
    96: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    97: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    98: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    99: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    100: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    101: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    102: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    103: TexCharacterMetrics(0.22222, 0.43056, 0, 0, 0.525),
    104: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    105: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    106: TexCharacterMetrics(0.22222, 0.61111, 0, 0, 0.525),
    107: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    108: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    109: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    110: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    111: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    112: TexCharacterMetrics(0.22222, 0.43056, 0, 0, 0.525),
    113: TexCharacterMetrics(0.22222, 0.43056, 0, 0, 0.525),
    114: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    115: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    116: TexCharacterMetrics(0, 0.55358, 0, 0, 0.525),
    117: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    118: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    119: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    120: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    121: TexCharacterMetrics(0.22222, 0.43056, 0, 0, 0.525),
    122: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    123: TexCharacterMetrics(0.08333, 0.69444, 0, 0, 0.525),
    124: TexCharacterMetrics(0.08333, 0.69444, 0, 0, 0.525),
    125: TexCharacterMetrics(0.08333, 0.69444, 0, 0, 0.525),
    126: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    127: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    160: TexCharacterMetrics(0, 0, 0, 0, 0.525),
    176: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    184: TexCharacterMetrics(0.19445, 0, 0, 0, 0.525),
    305: TexCharacterMetrics(0, 0.43056, 0, 0, 0.525),
    567: TexCharacterMetrics(0.22222, 0.43056, 0, 0, 0.525),
    711: TexCharacterMetrics(0, 0.56597, 0, 0, 0.525),
    713: TexCharacterMetrics(0, 0.56555, 0, 0, 0.525),
    714: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    715: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    728: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    730: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    770: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    771: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    776: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    915: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    916: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    920: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    923: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    926: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    928: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    931: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    933: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    934: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    936: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    937: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    8216: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    8217: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    8242: TexCharacterMetrics(0, 0.61111, 0, 0, 0.525),
    9251: TexCharacterMetrics(0.11111, 0.21944, 0, 0, 0.525),
  },
};

class TexScript {
  final String name;
  final List<List<int>> blocks;

  const TexScript({
    required final this.name,
    required final this.blocks,
  });
}

const Map<String, List<List<int>>> texScriptData = {
  // Latin characters beyond the Latin-1 characters we have metrics for.
  // Needed for Czech, Hungarian and Turkish text, for example.
  'latin': [
    [0x0100, 0x024f], // Latin Extended-A and Latin Extended-B
    [0x0300, 0x036f], // Combining Diacritical marks
  ],

  // The Cyrillic script used by Russian and related languages.
  // A Cyrillic subset used to be supported as explicitly defined
  // symbols in symbols.js
  'cyrillic': [
    [0x0400, 0x04ff]
  ],

  // The Brahmic scripts of South and Southeast Asia
  // Devanagari (0900–097F)
  // Bengali (0980–09FF)
  // Gurmukhi (0A00–0A7F)
  // Gujarati (0A80–0AFF)
  // Oriya (0B00–0B7F)
  // Tamil (0B80–0BFF)
  // Telugu (0C00–0C7F)
  // Kannada (0C80–0CFF)
  // Malayalam (0D00–0D7F)
  // Sinhala (0D80–0DFF)
  // Thai (0E00–0E7F)
  // Lao (0E80–0EFF)
  // Tibetan (0F00–0FFF)
  // Myanmar (1000–109F)
  'brahmic': [
    [0x0900, 0x109F]
  ],

  'georgian': [
    [0x10A0, 0x10ff]
  ],

  // Chinese and Japanese.
  // The "k" in cjk is for Korean, but we've separated Korean out
  'cjk': [
    [0x3000, 0x30FF], // CJK symbols and punctuation, Hiragana, Katakana
    [0x4E00, 0x9FAF], // CJK ideograms
    [0xFF00, 0xFF60], // Fullwidth punctuation
    // TODO: add halfwidth Katakana and Romanji glyphs
  ],

  // Korean
  'hangul': [
    [0xAC00, 0xD7AF]
  ],
};

final texAllBlocks = texScriptData.entries
    .expand(
      (final entry) => entry.value,
    )
    .toList(growable: false);

bool texSupportedCodepoint(
  final int codepoint,
) =>
    texAllBlocks.any((final block) => codepoint >= block[0] && codepoint <= block[1]);

// endregion
