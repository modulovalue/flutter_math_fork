import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../ast/ast.dart';
import '../ast/ast_plus.dart';
import '../ast/symbols.dart';
import '../font/font_metrics.dart';
import '../parser/font.dart';
import '../utils/unicode_literal.dart';
import '../widgets/tex.dart';
import 'layout.dart';

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

GreenBuildResult makeBaseSymbol({
  required final String symbol,
  required final AtomType atomType,
  required final Mode mode,
  required final MathOptions options,
  final bool variantForm = false,
  final FontOptions? overrideFont,
}) {
  // First lookup the render config table. We need the information
  var symbolRenderConfig = symbolRenderConfigs[symbol];
  if (symbolRenderConfig != null) {
    if (variantForm) {
      symbolRenderConfig = symbolRenderConfig.variantForm;
    }
    final renderConfig = mode == Mode.math
        ? (symbolRenderConfig?.math ?? symbolRenderConfig?.text)
        : (symbolRenderConfig?.text ?? symbolRenderConfig?.math);
    final char = renderConfig?.replaceChar ?? symbol;

    // Only mathord and textord will be affected by user-specified fonts
    // Also, surrogate pairs will ignore any user-specified font.
    if (atomType == AtomType.ord && symbol.codeUnitAt(0) != 0xD835) {
      final useMathFont = mode == Mode.math || (mode == Mode.text && options.mathFontOptions != null);
      var font = overrideFont ?? (useMathFont ? options.mathFontOptions : options.textFontOptions);

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
          return GreenBuildResult(
            options: options,
            italic: italic,
            skew: cssEmMeasurement(charMetrics.skew).toLpUnder(options),
            widget: makeChar(symbol, font, charMetrics, options, needItalic: mode == Mode.math),
          );
        } else if (ligatures.containsKey(symbol) && font.fontFamily == 'Typewriter') {
          // Make a special case for ligatures under Typewriter font
          final expandedText = ligatures[symbol]!.split('');
          return GreenBuildResult(
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
    final defaultFont = renderConfig?.defaultFont ?? const FontOptions();
    final characterMetrics = getCharacterMetrics(
      character: renderConfig?.replaceChar ?? symbol,
      fontName: defaultFont.fontName,
      mode: Mode.math,
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
    return GreenBuildResult(
      options: options,
      widget: makeChar(
        char,
        defaultFont,
        characterMetrics,
        options,
        needItalic: mode == Mode.math,
      ),
      italic: italic,
      skew: () {
        final skew = characterMetrics?.skew;
        if (skew == null) {
          return 0.0;
        } else {
          return cssEmMeasurement(skew).toLpUnder(options);
        }
      }(),
    );
    // Check if it is a special symbol
  } else if (mode == Mode.math && variantForm == false) {
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
  return GreenBuildResult(
    options: options,
    italic: 0.0,
    skew: 0.0,
    widget: makeChar(symbol, const FontOptions(), null, options, needItalic: mode == Mode.math),
  );
}

Widget makeChar(
  final String character,
  final FontOptions font,
  final CharacterMetrics? characterMetrics,
  final MathOptions options, {
  final bool needItalic = false,
}) {
  final charWidget = ResetDimension(
    height: () {
      final h = characterMetrics?.height;
      if (h == null) {
        return null;
      } else {
        return cssEmMeasurement(h).toLpUnder(options);
      }
    }(),
    depth: () {
      final d = characterMetrics?.depth;
      if (d == null) {
        return null;
      } else {
        return cssEmMeasurement(d).toLpUnder(options);
      }
    }(),
    child: RichText(
      text: TextSpan(
        text: character,
        style: TextStyle(
          fontFamily: 'packages/flutter_math_fork/KaTeX_${font.fontFamily}',
          fontWeight: font.fontWeight,
          fontStyle: font.fontShape,
          fontSize: cssEmMeasurement(1.0).toLpUnder(options),
          color: options.color,
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

CharacterMetrics? lookupChar(final String char, final FontOptions font, final Mode mode) =>
    getCharacterMetrics(
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

FontOptions mathdefault(
  final String value,
) {
  if (_numberDigitRegex.hasMatch(value[0]) || _mathitLetters.contains(value)) {
    return const FontOptions(
      fontFamily: 'Main',
      fontShape: FontStyle.italic,
    );
  } else {
    return const FontOptions(
      fontFamily: 'Math',
      fontShape: FontStyle.italic,
    );
  }
}
