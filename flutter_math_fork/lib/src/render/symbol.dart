import 'package:flutter/widgets.dart';
import '../ast/ast.dart';

import '../ast/ast_impl.dart';
import '../ast/ast_plus.dart';
import '../ast/symbols.dart';
import '../parser/functions.dart';
import '../utils/unicode_literal.dart';
import '../widgets/tex.dart';
import 'layout.dart';

TexGreenBuildResult makeRlapCompositeSymbol(
  final String char1,
  final String char2,
  final TexAtomType type,
  final TexMode mode,
  final TexMathOptions options,
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
  return TexGreenBuildResultImpl(
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

TexGreenBuildResult makeCompactedCompositeSymbol(
  final String char1,
  final String char2,
  final TexMeasurement spacing,
  final TexAtomType type,
  final TexMode mode,
  final TexMathOptions options,
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
        offset: options.fontMetrics.axisHeight2.toLpUnder(options),
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
        offset: options.fontMetrics.axisHeight2.toLpUnder(options),
        child: res2.widget,
      );
    }
  }();
  return TexGreenBuildResultImpl(
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

TexGreenBuildResult makeDecoratedEqualSymbol(
  final String symbol,
  final TexAtomType type,
  final TexMode mode,
  final TexMathOptions options,
) {
  List<String> decoratorSymbols;
  TexFontOptions? decoratorFont;
  TexMathSize decoratorSize;
  switch (symbol) {
    // case '\u2258':
    //   break;
    case '\u2259':
      decoratorSymbols = ['\u2227']; // \wedge
      decoratorSize = TexMathSize.tiny;
      break;
    case '\u225A':
      decoratorSymbols = ['\u2228']; // \vee
      decoratorSize = TexMathSize.tiny;
      break;
    case '\u225B':
      decoratorSymbols = ['\u22c6']; // \star
      decoratorSize = TexMathSize.scriptsize;
      break;
    case '\u225D':
      decoratorSymbols = ['d', 'e', 'f'];
      decoratorSize = TexMathSize.tiny;
      decoratorFont = texMathFontOptions['\\mathrm']!;
      break;
    case '\u225E':
      decoratorSymbols = ['m'];
      decoratorSize = TexMathSize.tiny;
      decoratorFont = texMathFontOptions['\\mathrm']!;
      break;
    case '\u225F':
      decoratorSymbols = ['?'];
      decoratorSize = TexMathSize.tiny;
      break;
    default:
      throw ArgumentError.value(unicodeLiteral(symbol), 'symbol', 'Not a decorator character');
  }
  final decorator = TexGreenStyleImpl(
    children: decoratorSymbols
        .map(
          (final symbol) => TexGreenSymbolImpl(
            symbol: symbol,
            mode: mode,
          ),
        )
        .toList(
          growable: false,
        ),
    optionsDiff: TexOptionsDiffImpl(
      size: decoratorSize,
      mathFontOptions: decoratorFont,
    ),
  );
  final proxyNode = TexGreenOverImpl(
    base: greenNodeWrapWithEquationRow(
      TexGreenSymbolImpl(
        symbol: '=',
        mode: mode,
        overrideAtomType: type,
      ),
    ),
    above: greenNodeWrapWithEquationRow(
      decorator,
    ),
  );
  return texBuildWidget(
    node: TexRedImpl(
      greenValue: proxyNode,
      pos: 0,
    ),
    newOptions: options,
  );
}

TexGreenBuildResult makeBaseSymbol({
  required final String symbol,
  required final TexAtomType atomType,
  required final TexMode mode,
  required final TexMathOptions options,
  final bool variantForm = false,
  final TexFontOptions? overrideFont,
}) {
  // First lookup the render config table. We need the information
  var symbolRenderConfig = symbolRenderConfigs[symbol];
  if (symbolRenderConfig != null) {
    if (variantForm) {
      symbolRenderConfig = symbolRenderConfig.variantForm;
    }
    final renderConfig = () {
      if (mode == TexMode.math) {
        return symbolRenderConfig?.math ?? symbolRenderConfig?.text;
      } else {
        return symbolRenderConfig?.text ?? symbolRenderConfig?.math;
      }
    }();
    final char = renderConfig?.replaceChar ?? symbol;
    // Only mathord and textord will be affected by user-specified fonts
    // Also, surrogate pairs will ignore any user-specified font.
    if (atomType == TexAtomType.ord && symbol.codeUnitAt(0) != 0xD835) {
      final useMathFont = mode == TexMode.math || (mode == TexMode.text && options.mathFontOptions != null);
      var font = overrideFont ??
          (() {
            if (useMathFont) {
              return options.mathFontOptions;
            } else {
              return options.textFontOptions;
            }
          }());
      if (font != null) {
        var charMetrics = lookupChar(char, font, mode);
        // Some font (such as boldsymbol) has fallback options
        if (charMetrics == null) {
          for (final fallback in font.fallback) {
            charMetrics = lookupChar(char, fallback, mode);
            if (charMetrics != null) {
              font = fallback;
              break;
            }
          }
          font!;
        }
        if (charMetrics != null) {
          final italic = charMetrics.italic.toLpUnder(options);
          return TexGreenBuildResultImpl(
            options: options,
            italic: italic,
            skew: cssem(charMetrics.skew).toLpUnder(options),
            widget: makeChar(symbol, font, charMetrics, options, needItalic: mode == TexMode.math),
          );
        } else if (ligatures.containsKey(symbol) && font.fontFamily == 'Typewriter') {
          // Make a special case for ligatures under Typewriter font
          final expandedText = ligatures[symbol]!.split('');
          return TexGreenBuildResultImpl(
            options: options,
            widget: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: expandedText
                  .map((final e) => makeChar(e, font!, lookupChar(e, font, mode), options))
                  .toList(growable: false),
            ),
            italic: 0.0,
            skew: 0.0,
          );
        }
      }
    }
    // If the code reaches here, it means we failed to find any appliable
    // user-specified font. We will use default render configs.
    final defaultFont = renderConfig?.defaultFont ?? const TexFontOptionsImpl();
    final characterMetrics = texGetCharacterMetrics(
      character: renderConfig?.replaceChar ?? symbol,
      fontName: defaultFont.fontName,
      mode: TexMode.math,
    );
    final italic = () {
      final italic = characterMetrics?.italic;
      if (italic == null) {
        return 0.0;
      } else {
        return italic.toLpUnder(options);
      }
    }();
    // fontMetricsData[defaultFont.fontName][replaceChar.codeUnitAt(0)];
    return TexGreenBuildResultImpl(
      options: options,
      widget: makeChar(
        char,
        defaultFont,
        characterMetrics,
        options,
        needItalic: mode == TexMode.math,
      ),
      italic: italic,
      skew: () {
        final skew = characterMetrics?.skew;
        if (skew == null) {
          return 0.0;
        } else {
          return cssem(skew).toLpUnder(options);
        }
      }(),
    );
    // Check if it is a special symbol
  } else if (mode == TexMode.math && variantForm == false) {
    if (negatedOperatorSymbols.containsKey(symbol)) {
      final chars = negatedOperatorSymbols[symbol]!;
      return makeRlapCompositeSymbol(chars[0], chars[1], atomType, mode, options);
    } else if (compactedCompositeSymbols.containsKey(symbol)) {
      final chars = compactedCompositeSymbols[symbol]!;
      final spacing = compactedCompositeSymbolSpacings[symbol]!;
      // final type = compactedCompositeSymbolTypes[symbol];
      return makeCompactedCompositeSymbol(chars[0], chars[1], spacing, atomType, mode, options);
    } else if (decoratedEqualSymbols.contains(symbol)) {
      return makeDecoratedEqualSymbol(symbol, atomType, mode, options);
    }
  }
  return TexGreenBuildResultImpl(
    options: options,
    italic: 0.0,
    skew: 0.0,
    widget: makeChar(
      symbol,
      const TexFontOptionsImpl(),
      null,
      options,
      needItalic: mode == TexMode.math,
    ),
  );
}

Widget makeChar(
  final String character,
  final TexFontOptions font,
  final TexCharacterMetrics? characterMetrics,
  final TexMathOptions options, {
  final bool needItalic = false,
}) {
  final charWidget = ResetDimension(
    height: () {
      final h = characterMetrics?.height;
      if (h == null) {
        return null;
      } else {
        return cssem(h).toLpUnder(options);
      }
    }(),
    depth: () {
      final d = characterMetrics?.depth;
      if (d == null) {
        return null;
      } else {
        return cssem(d).toLpUnder(options);
      }
    }(),
    child: RichText(
      text: TextSpan(
        text: character,
        style: TextStyle(
          fontFamily: 'packages/flutter_math_fork/KaTeX_${font.fontFamily}',
          fontWeight: texFontWeightToFlutterFontWeight(
            font.fontWeight,
          ),
          fontStyle: texFontStyleToFlutterFontStyle(
            font.fontShape,
          ),
          fontSize: cssem(1.0).toLpUnder(options),
          color: Color(options.color.argb),
        ),
      ),
      softWrap: false,
      overflow: TextOverflow.visible,
    ),
  );
  if (needItalic) {
    final italic = () {
      final i = characterMetrics?.italic;
      if (i == null) {
        return 0.0;
      } else {
        return i.toLpUnder(options);
      }
    }();
    return Padding(
      padding: EdgeInsets.only(
        right: italic,
      ),
      child: charWidget,
    );
  }
  return charWidget;
}

TexCharacterMetrics? lookupChar(final String char, final TexFontOptions font, final TexMode mode) =>
    texGetCharacterMetrics(
      character: char,
      fontName: font.fontName,
      mode: mode,
    );

final _numberDigitRegex = RegExp('[0-9]');

final _mathitLetters = {
  // "\\imath",
  'ı', // dotless i
  // "\\jmath",
  'ȷ', // dotless j
  // "\\pounds", "\\mathsterling", "\\textsterling",
  '£', // pounds symbol
};

TexFontOptions mathdefault(
  final String value,
) {
  if (_numberDigitRegex.hasMatch(value[0]) || _mathitLetters.contains(value)) {
    return const TexFontOptionsImpl(
      fontFamily: 'Main',
      fontShape: TexFontStyle.italic,
    );
  } else {
    return const TexFontOptionsImpl(
      fontFamily: 'Math',
      fontShape: TexFontStyle.italic,
    );
  }
}

FontWeight texFontWeightToFlutterFontWeight(
  final TexFontWeight w,
) {
  switch (w) {
    case TexFontWeight.w100:
      return FontWeight.w100;
    case TexFontWeight.w200:
      return FontWeight.w200;
    case TexFontWeight.w300:
      return FontWeight.w300;
    case TexFontWeight.w400:
      return FontWeight.w400;
    case TexFontWeight.w500:
      return FontWeight.w500;
    case TexFontWeight.w600:
      return FontWeight.w600;
    case TexFontWeight.w700:
      return FontWeight.w700;
    case TexFontWeight.w800:
      return FontWeight.w800;
    case TexFontWeight.w900:
      return FontWeight.w900;
  }
}

TexFontWeight flutterFontWeightToTexFontWeight(
  final FontWeight f,
) {
  // ignore: exhaustive_cases
  switch (f) {
    case FontWeight.w100:
      return TexFontWeight.w100;
    case FontWeight.w200:
      return TexFontWeight.w200;
    case FontWeight.w300:
      return TexFontWeight.w300;
    case FontWeight.w400:
      return TexFontWeight.w400;
    case FontWeight.w500:
      return TexFontWeight.w500;
    case FontWeight.w600:
      return TexFontWeight.w600;
    case FontWeight.w700:
      return TexFontWeight.w700;
    case FontWeight.w800:
      return TexFontWeight.w800;
    case FontWeight.w900:
      return TexFontWeight.w900;
  }
  throw Exception("Unknown flutter font weight.");
}

FontStyle texFontStyleToFlutterFontStyle(
  final TexFontStyle style,
) {
  switch (style) {
    case TexFontStyle.normal:
      return FontStyle.normal;
    case TexFontStyle.italic:
      return FontStyle.italic;
  }
}

TexFontStyle flutterFontStyleToTexFontStyle(
  final FontStyle style,
) {
  switch (style) {
    case FontStyle.normal:
      return TexFontStyle.normal;
    case FontStyle.italic:
      return TexFontStyle.italic;
  }
}
