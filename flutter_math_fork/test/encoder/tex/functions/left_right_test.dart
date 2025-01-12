import 'package:flutter_math_fork/src/ast/ast_impl.dart';
import 'package:flutter_math_fork/src/encoder/tex_encoder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../recode.dart';

void main() {
  group('LeftRight encoding test', () {
    test('general encoding', () {
      final node1 = TexGreenLeftrightImpl(
        leftDelim: '(',
        rightDelim: '}',
        body: [
          TexGreenEquationrowImpl(
            children: [
              TexGreenSymbolImpl(
                symbol: 'a',
              ),
            ],
          ),
        ],
      );
      expect(
        nodeEncodeTeX(
          node: node1,
        ),
        '\\left(a\\right\\}',
      );
      const testStrings = [
        '\\left.a\\middle|b\\middle.c\\right)',
      ];
      for (final testString in testStrings) {
        expect(
          recodeTex(testString),
          testString,
        );
      }
    });
  });
}
