import 'dart:ui';

import 'package:flutter_math_fork/src/ast/ast.dart';
import 'package:flutter_math_fork/src/ast/ast_plus.dart';
import 'package:flutter_math_fork/src/encoder/tex_encoder.dart';
import 'package:flutter_math_fork/src/parser/font.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('style encoding test', () {
    test('math style handling', () {
      expect(
        nodeEncodeTeX(
          node: TexGreenStyle(
            optionsDiff: const OptionsDiff(style: MathStyle.display),
            children: [TexGreenSymbol(symbol: 'a')],
          ),
        ),
        '{\\displaystyle a}',
      );
    });
    test('size handling', () {
      expect(
        nodeEncodeTeX(
          node: TexGreenStyle(
            optionsDiff: const OptionsDiff(size: MathSize.scriptsize),
            children: [TexGreenSymbol(symbol: 'a')],
          ),
        ),
        '{\\scriptsize a}',
      );
    });
    test('font handling', () {
      expect(
        nodeEncodeTeX(
          node: TexGreenStyle(
            optionsDiff: OptionsDiff(
              mathFontOptions: texMathFontOptions['\\mathbf'],
            ),
            children: [
              TexGreenSymbol(
                symbol: 'a',
              ),
            ],
          ),
        ),
        '\\mathbf{a}',
      );
      expect(
        nodeEncodeTeX(
          node: TexGreenStyle(
            optionsDiff: OptionsDiff(
              textFontOptions: texTextFontOptions['\\textbf'],
            ),
            children: [
              TexGreenSymbol(
                symbol: 'a',
                mode: Mode.text,
              ),
            ],
          ),
        ),
        '\\textbf{a}',
      );
    });
    test('color handling', () {
      expect(
        nodeEncodeTeX(
          node: TexGreenStyle(
            optionsDiff: const OptionsDiff(
              color: Color.fromARGB(
                0,
                1,
                2,
                3,
              ),
            ),
            children: [
              TexGreenSymbol(
                symbol: 'a',
              ),
            ],
          ),
        ),
        '\\textcolor{#010203}{a}',
      );
    });
    test('avoid extra brackets', () {
      expect(
        nodeEncodeTeX(
          node: TexGreenStyle(
            optionsDiff: const OptionsDiff(
              style: MathStyle.display,
              size: MathSize.scriptsize,
              color: Color.fromARGB(
                0,
                1,
                2,
                3,
              ),
            ),
            children: [
              TexGreenSymbol(
                symbol: 'a',
              ),
            ],
          ),
        ),
        '\\textcolor{#010203}{\\displaystyle \\scriptsize a}',
      );
      expect(
        nodeEncodeTeX(
          node: TexGreenEquationrow(
            children: [
              TexGreenSymbol(symbol: 'z'),
              TexGreenStyle(
                optionsDiff: const OptionsDiff(
                  style: MathStyle.display,
                  size: MathSize.scriptsize,
                ),
                children: [TexGreenSymbol(symbol: 'a')],
              ),
            ],
          ),
        ),
        '{z\\displaystyle \\scriptsize a}',
      );
    });
  });
}
