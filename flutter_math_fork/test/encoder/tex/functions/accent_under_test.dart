import 'package:flutter_math_fork/src/ast/ast_impl.dart';
import 'package:flutter_math_fork/src/ast/ast_plus.dart';
import 'package:flutter_math_fork/src/encoder/tex_encoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('accent encoding test', () {
    test('general encoding math', () {
      final bar = TexGreenAccentunderImpl(
        base: emptyEquationRowNode(),
        label: '\u00AF',
      );
      expect(
        nodeEncodeTeX(node: bar),
        '\\underline{}',
      );
    });
  });
}
