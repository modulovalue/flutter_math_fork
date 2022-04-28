import 'dart:ui';

import 'package:flutter/material.dart';

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
  @override
  int get pos => -1;

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

class TexGreenMatrixImpl
    with TexGreenNullableCapturedMixin<TexGreenMatrixImpl>
    implements TexGreenMatrix<TexGreenMatrixImpl> {
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
      rowSpacings: this.rowSpacings,
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

class TexGreenMultiscriptsImpl
    with TexGreenNullableCapturedMixin<TexGreenMultiscriptsImpl>
    implements TexGreenMultiscripts<TexGreenMultiscriptsImpl> {
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

class TexGreenNaryoperatorImpl
    with TexGreenNullableCapturedMixin<TexGreenNaryoperatorImpl>
    implements TexGreenNaryoperator<TexGreenNaryoperatorImpl> {
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

class TexGreenSqrtImpl
    with TexGreenNullableCapturedMixin<TexGreenSqrtImpl>
    implements TexGreenSqrt<TexGreenSqrtImpl> {
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

class TexGreenStretchyopImpl
    with TexGreenNullableCapturedMixin<TexGreenStretchyopImpl>
    implements TexGreenStretchyop<TexGreenStretchyopImpl> {
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

class TexGreenEquationarrayImpl
    with TexGreenNonnullableCapturedMixin<TexGreenEquationarrayImpl>
    implements TexGreenEquationarray<TexGreenEquationarrayImpl> {
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
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

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

class TexGreenOverImpl
    with TexGreenNonnullableCapturedMixin<TexGreenOverImpl>
    implements TexGreenOver<TexGreenOverImpl> {
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
  ) {
    return TexGreenOverImpl(
      base: newChildren[0],
      above: newChildren[1],
      stackRel: this.stackRel,
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
      over(this);
}

class TexGreenUnderImpl
    with TexGreenNonnullableCapturedMixin<TexGreenUnderImpl>
    implements TexGreenUnder<TexGreenUnderImpl> {
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
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  TexGreenUnderImpl updateChildren(
    final List<TexGreenEquationrow> newChildren,
  ) =>
      TexGreenUnderImpl(base: newChildren[0], below: newChildren[1]);

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

class TexGreenAccentImpl
    with TexGreenNonnullableCapturedMixin<TexGreenAccentImpl>
    implements TexGreenAccent<TexGreenAccentImpl> {
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
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

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

class TexGreenAccentunderImpl
    with TexGreenNonnullableCapturedMixin<TexGreenAccentunderImpl>
    implements TexGreenAccentunder<TexGreenAccentunderImpl> {
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
      TexGreenAccentunderImpl(
        base: newChildren[0],
        label: label,
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

class TexGreenEnclosureImpl
    with TexGreenNonnullableCapturedMixin<TexGreenEnclosureImpl>
    implements TexGreenEnclosure<TexGreenEnclosureImpl> {
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

class TexGreenFracImpl
    with TexGreenNonnullableCapturedMixin<TexGreenFracImpl>
    implements TexGreenFrac<TexGreenFracImpl> {
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
  ) =>
      false;

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

class TexGreenFunctionImpl
    with TexGreenNonnullableCapturedMixin<TexGreenFunctionImpl>
    implements TexGreenFunction<TexGreenFunctionImpl> {
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
  ) =>
      false;

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

class TexGreenLeftrightImpl
    with TexGreenNonnullableCapturedMixin<TexGreenLeftrightImpl>
    implements TexGreenLeftright<TexGreenLeftrightImpl> {
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

class TexGreenRaiseboxImpl
    with TexGreenNonnullableCapturedMixin<TexGreenRaiseboxImpl>
    implements TexGreenRaisebox<TexGreenRaiseboxImpl> {
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
      TexGreenRaiseboxImpl(
        body: newChildren[0],
        dy: dy,
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

class TexGreenStyleImpl
    with TexGreenNonleafMixin<TexGreenStyleImpl>
    implements TexGreenStyle<TexGreenStyleImpl> {
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

class TexGreenEquationrowImpl
    with TexGreenNonleafMixin<TexGreenEquationrowImpl>
    implements TexGreenEquationrow<TexGreenEquationrowImpl> {
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
  List<MathOptions> computeChildOptions(
    final MathOptions options,
  ) =>
      List.filled(children.length, options, growable: false);

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      false;

  @override
  TexGreenEquationrowImpl updateChildren(
    final List<TexGreen> newChildren,
  ) =>
      TexGreenEquationrowImpl(
        overrideType: this.overrideType,
        children: newChildren,
      );

  @override
  AtomType get leftType => overrideType ?? AtomType.ord;

  @override
  AtomType get rightType => overrideType ?? AtomType.ord;

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
  AtomType get leftType => throw UnsupportedError('Temporary node $runtimeType encountered.',);

  @override
  AtomType get rightType => throw UnsupportedError('Temporary node $runtimeType encountered.',);

  @override
  bool shouldRebuildWidget(
    final MathOptions oldOptions,
    final MathOptions newOptions,
  ) =>
      throw UnsupportedError('Temporary node $runtimeType encountered.',);

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
