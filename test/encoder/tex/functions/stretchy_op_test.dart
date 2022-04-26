import 'package:flutter_math_fork/src/ast/ast.dart';
import 'package:flutter_math_fork/src/encoder/tex_encoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StretchyOp encoding test', () {
    test('general encoding', () {
      final node1 = TexStretchyop(
        symbol: '\u2192',
        above: TexEquationrow(
          children: [],
        ),
        below: TexEquationrow(
          children: [],
        ),
      );
      expect(
        nodeEncodeTeX(
          node: node1,
        ),
        '\\xrightarrow{}',
      );
      final node2 = TexStretchyop(
        symbol: '\u2192',
        above: TexEquationrow(
          children: [
            TexSymbol(
              symbol: 'a',
            ),
          ],
        ),
        below: TexEquationrow(
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
