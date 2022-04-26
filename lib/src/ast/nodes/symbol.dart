import 'package:flutter/widgets.dart';

import '../../render/symbols/make_symbol.dart';
import '../options.dart';
import '../symbols/symbols.dart';
import '../symbols/symbols_composite.dart';
import '../symbols/symbols_extra.dart';
import '../symbols/symbols_unicode.dart';
import '../symbols/unicode_accents.dart';
import '../syntax_tree.dart';
import '../types.dart';
import 'accent.dart';

/// Node for an unbreakable symbol.
class SymbolNode extends LeafNode {
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
        final accent = unicodeAccents[ch];
        if (accent == null) {
          break;
        } else {
          res = AccentNode(
            base: res.wrapWithEquationRow(),
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
  var symbolRenderConfig = symbolRenderConfigs[symbol];
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

bool isCombiningMark(final String ch) {
  final code = ch.codeUnitAt(0);
  return code >= 0x0300 && code <= 0x036f;
}
