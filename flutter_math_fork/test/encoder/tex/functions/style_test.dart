import 'package:flutter_math_fork/src/ast/ast.dart';
import 'package:flutter_math_fork/src/ast/ast_impl.dart';
import 'package:flutter_math_fork/src/encoder/tex_encoder.dart';
import 'package:flutter_math_fork/src/parser/functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('style encoding test', () {
    test('math style handling', () {
      expect(
        nodeEncodeTeX(
          node: TexGreenStyleImpl(
            optionsDiff: const TexOptionsDiffImpl(
              style: TexMathStyle.display,
            ),
            children: [
              TexGreenSymbolImpl(
                symbol: 'a',
              ),
            ],
          ),
        ),
        '{\\displaystyle a}',
      );
    });
    test('size handling', () {
      expect(
        nodeEncodeTeX(
          node: TexGreenStyleImpl(
            optionsDiff: const TexOptionsDiffImpl(
              size: TexMathSize.scriptsize,
            ),
            children: [
              TexGreenSymbolImpl(
                symbol: 'a',
              ),
            ],
          ),
        ),
        '{\\scriptsize a}',
      );
    });
    test('font handling', () {
      expect(
        nodeEncodeTeX(
          node: TexGreenStyleImpl(
            optionsDiff: TexOptionsDiffImpl(
              mathFontOptions: texMathFontOptions['\\mathbf'],
            ),
            children: [
              TexGreenSymbolImpl(
                symbol: 'a',
              ),
            ],
          ),
        ),
        '\\mathbf{a}',
      );
      expect(
        nodeEncodeTeX(
          node: TexGreenStyleImpl(
            optionsDiff: TexOptionsDiffImpl(
              textFontOptions: texTextFontOptions['\\textbf'],
            ),
            children: [
              TexGreenSymbolImpl(
                symbol: 'a',
                mode: TexMode.text,
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
          node: TexGreenStyleImpl(
            optionsDiff: const TexOptionsDiffImpl(
              color: TexColorImpl.fromARGB(
                0,
                1,
                2,
                3,
              ),
            ),
            children: [
              TexGreenSymbolImpl(
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
          node: TexGreenStyleImpl(
            optionsDiff: const TexOptionsDiffImpl(
              style: TexMathStyle.display,
              size: TexMathSize.scriptsize,
              color: TexColorImpl.fromARGB(
                0,
                1,
                2,
                3,
              ),
            ),
            children: [
              TexGreenSymbolImpl(
                symbol: 'a',
              ),
            ],
          ),
        ),
        '\\textcolor{#010203}{\\displaystyle \\scriptsize a}',
      );
      expect(
        nodeEncodeTeX(
          node: TexGreenEquationrowImpl(
            children: [
              TexGreenSymbolImpl(
                symbol: 'z',
              ),
              TexGreenStyleImpl(
                optionsDiff: const TexOptionsDiffImpl(
                  style: TexMathStyle.display,
                  size: TexMathSize.scriptsize,
                ),
                children: [
                  TexGreenSymbolImpl(
                    symbol: 'a',
                  ),
                ],
              ),
            ],
          ),
        ),
        '{z\\displaystyle \\scriptsize a}',
      );
    });
  });
}
