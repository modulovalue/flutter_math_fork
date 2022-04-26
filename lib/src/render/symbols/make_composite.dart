import 'package:flutter/widgets.dart';

import '../../ast/ast.dart';
import '../../ast/ast_plus.dart';
import '../../parser/font.dart';
import '../../utils/unicode_literal.dart';
import '../../widgets/tex.dart';
import '../layout/line.dart';
import '../layout/reset_dimension.dart';
import '../layout/shift_baseline.dart';
import 'make_symbol.dart';

GreenBuildResult makeRlapCompositeSymbol(
  final String char1,
  final String char2,
  final AtomType type,
  final Mode mode,
  final MathOptions options,
) {
  final res1 = makeBaseSymbol(
    symbol: char1,
    atomType: type,
    mode: mode,
    options: options,
  );
  final res2 = makeBaseSymbol(
    symbol: char2,
    atomType: type,
    mode: mode,
    options: options,
  );
  return GreenBuildResult(
    italic: res2.italic,
    options: options,
    widget: Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ResetDimension(
          width: 0,
          horizontalAlignment: CrossAxisAlignment.start,
          child: res1.widget,
        ),
        res2.widget,
      ],
    ),
  );
}

GreenBuildResult makeCompactedCompositeSymbol(
  final String char1,
  final String char2,
  final Measurement spacing,
  final AtomType type,
  final Mode mode,
  final MathOptions options,
) {
  final res1 = makeBaseSymbol(
    symbol: char1,
    atomType: type,
    mode: mode,
    options: options,
  );
  final res2 = makeBaseSymbol(
    symbol: char2,
    atomType: type,
    mode: mode,
    options: options,
  );
  final widget1 = () {
    if (char1 != ':') {
      return res1.widget;
    } else {
      return ShiftBaseline(
        relativePos: 0.5,
        offset: cssEmMeasurement(options.fontMetrics.axisHeight).toLpUnder(options),
        child: res1.widget,
      );
    }
  }();
  final widget2 = () {
    if (char2 != ':') {
      return res2.widget;
    } else {
      return ShiftBaseline(
        relativePos: 0.5,
        offset: cssEmMeasurement(options.fontMetrics.axisHeight).toLpUnder(options),
        child: res2.widget,
      );
    }
  }();
  return GreenBuildResult(
    italic: res2.italic,
    options: options,
    widget: Line(
      children: <Widget>[
        LineElement(
          child: widget1,
          trailingMargin: spacing.toLpUnder(options),
        ),
        widget2,
      ],
    ),
  );
}

GreenBuildResult makeDecoratedEqualSymbol(
  final String symbol,
  final AtomType type,
  final Mode mode,
  final MathOptions options,
) {
  List<String> decoratorSymbols;
  FontOptions? decoratorFont;
  MathSize decoratorSize;
  switch (symbol) {
    // case '\u2258':
    //   break;
    case '\u2259':
      decoratorSymbols = ['\u2227']; // \wedge
      decoratorSize = MathSize.tiny;
      break;
    case '\u225A':
      decoratorSymbols = ['\u2228']; // \vee
      decoratorSize = MathSize.tiny;
      break;
    case '\u225B':
      decoratorSymbols = ['\u22c6']; // \star
      decoratorSize = MathSize.scriptsize;
      break;
    case '\u225D':
      decoratorSymbols = ['d', 'e', 'f'];
      decoratorSize = MathSize.tiny;
      decoratorFont = texMathFontOptions['\\mathrm']!;
      break;
    case '\u225E':
      decoratorSymbols = ['m'];
      decoratorSize = MathSize.tiny;
      decoratorFont = texMathFontOptions['\\mathrm']!;
      break;
    case '\u225F':
      decoratorSymbols = ['?'];
      decoratorSize = MathSize.tiny;
      break;
    default:
      throw ArgumentError.value(unicodeLiteral(symbol), 'symbol', 'Not a decorator character');
  }
  final decorator = TexGreenStyle(
    children: decoratorSymbols
        .map(
          (final symbol) => TexGreenSymbol(
            symbol: symbol,
            mode: mode,
          ),
        )
        .toList(growable: false),
    optionsDiff: OptionsDiff(
      size: decoratorSize,
      mathFontOptions: decoratorFont,
    ),
  );
  final proxyNode = TexGreenOver(
    base: greenNodeWrapWithEquationRow(
      TexGreenSymbol(
        symbol: '=',
        mode: mode,
        overrideAtomType: type,
      ),
    ),
    above: greenNodeWrapWithEquationRow(
      decorator,
    ),
  );
  return TexWidget.buildWidget(
    node: TexRedImpl(
      redParent: null,
      greenValue: proxyNode,
      pos: 0,
    ),
    newOptions: options,
  );
}
