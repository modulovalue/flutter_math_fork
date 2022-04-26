import 'package:flutter_math_fork/ast.dart';
import 'package:flutter_math_fork/src/encoder/tex_encoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('accent encoding test', () {
    test('general encoding math', () {
      final bar = AccentUnderNode(
        base: EquationRowNode.empty(),
        label: '\u00AF',
      );
      expect(
        nodeEncodeTeX(node: bar),
        '\\underline{}',
      );
    });
  });
}
