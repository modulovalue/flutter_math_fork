import 'package:flutter_math_fork/src/ast/ast_impl.dart';
import 'package:flutter_math_fork/src/encoder/tex_encoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StretchyOp encoding test', () {
    test('general encoding', () {
      final node1 = TexGreenStretchyopImpl(
        symbol: '\u2192',
        above: TexGreenEquationrowImpl(
          children: [],
        ),
        below: TexGreenEquationrowImpl(
          children: [],
        ),
      );
      expect(
        nodeEncodeTeX(
          node: node1,
        ),
        '\\xrightarrow{}',
      );
      final node2 = TexGreenStretchyopImpl(
        symbol: '\u2192',
        above: TexGreenEquationrowImpl(
          children: [
            TexGreenSymbolImpl(
              symbol: 'a',
            ),
          ],
        ),
        below: TexGreenEquationrowImpl(
          children: [],
        ),
      );
      expect(
        nodeEncodeTeX(node: node2),
        '\\xrightarrow[a]{}',
      );
    });
  });
}
