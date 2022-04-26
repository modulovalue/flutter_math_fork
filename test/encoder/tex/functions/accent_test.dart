import 'package:flutter_math_fork/ast.dart';
import 'package:flutter_math_fork/src/encoder/tex_encoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('accent encoding test', () {
    test('general encoding math', () {
      final bar = AccentNode(
        base: EquationRowNode.empty(),
        label: '\u00AF',
        isStretchy: false,
        isShifty: true,
      );
      expect(
        nodeEncodeTeX(node: bar),
        '\\bar{}',
      );
      final widehat = AccentNode(
        base: EquationRowNode.empty(),
        label: '\u005e',
        isStretchy: true,
        isShifty: true,
      );
      expect(
        nodeEncodeTeX(node: widehat),
        '\\widehat{}',
      );
      final overline = AccentNode(
        base: EquationRowNode.empty(),
        label: '\u00AF',
        isStretchy: true,
        isShifty: false,
      );
      expect(
        nodeEncodeTeX(node: overline),
        '\\overline{}',
      );
    });

    test('general encoding text', () {
      final bar = AccentNode(
        base: EquationRowNode.empty(),
        label: '\u00AF',
        isStretchy: false,
        isShifty: true,
      );
      expect(
        nodeEncodeTeX(node: bar, conf: TexEncodeConf.textConf),
        '\\={}',
      );
    });
  });
}
