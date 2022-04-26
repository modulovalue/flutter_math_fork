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
          node: TexStyle(
            optionsDiff: const OptionsDiff(style: MathStyle.display),
            children: [TexSymbol(symbol: 'a')],
          ),
        ),
        '{\\displaystyle a}',
      );
    });
    test('size handling', () {
      expect(
        nodeEncodeTeX(
          node: TexStyle(
            optionsDiff: const OptionsDiff(size: MathSize.scriptsize),
            children: [TexSymbol(symbol: 'a')],
          ),
        ),
        '{\\scriptsize a}',
      );
    });
    test('font handling', () {
      expect(
        nodeEncodeTeX(
          node: TexStyle(
            optionsDiff: OptionsDiff(
              mathFontOptions: texMathFontOptions['\\mathbf'],
            ),
            children: [
              TexSymbol(
                symbol: 'a',
              ),
            ],
          ),
        ),
        '\\mathbf{a}',
      );
      expect(
        nodeEncodeTeX(
          node: TexStyle(
            optionsDiff: OptionsDiff(
              textFontOptions: texTextFontOptions['\\textbf'],
            ),
            children: [
              TexSymbol(
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
          node: TexStyle(
            optionsDiff: const OptionsDiff(
              color: Color.fromARGB(
                0,
                1,
                2,
                3,
              ),
            ),
            children: [
              TexSymbol(
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
          node: TexStyle(
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
              TexSymbol(
                symbol: 'a',
              ),
            ],
          ),
        ),
        '\\textcolor{#010203}{\\displaystyle \\scriptsize a}',
      );
      expect(
        nodeEncodeTeX(
          node: TexEquationrow(
            children: [
              TexSymbol(symbol: 'z'),
              TexStyle(
                optionsDiff: const OptionsDiff(
                  style: MathStyle.display,
                  size: MathSize.scriptsize,
                ),
                children: [TexSymbol(symbol: 'a')],
              ),
            ],
          ),
        ),
        '{z\\displaystyle \\scriptsize a}',
      );
    });
  });
}
