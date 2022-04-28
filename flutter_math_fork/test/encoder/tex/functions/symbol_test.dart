import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_math_fork/src/encoder/tex_encoder.dart';
import 'package:flutter_math_fork/src/parser/parser.dart';
import 'package:flutter_test/flutter_test.dart';

String recodeTexSymbol(
  String tex, [
  final TexMode mode = TexMode.math,
]) {
  if (mode == TexMode.text) {
    // ignore: parameter_assignments
    tex = '\\text{' + tex + '}';
  }
  TexGreen node = TexParser(
    content: tex,
    settings: const TexParserSettings(),
  ).parse().children.first;
  while (node is TexGreenTNonleaf) {
    node = texNonleafChildren(nonleaf: node).first!;
  }
  assert(node is TexGreenSymbol, "");
  return nodeEncodeTeX(
    node: node,
    conf: () {
      if (mode == TexMode.math) {
        return TexEncodeConf.mathConf;
      } else {
        return TexEncodeConf.textConf;
      }
    }(),
  );
}

void main() {
  group('symbol encoding test', () {
    test('base math symbols', () {
      expect(recodeTexSymbol('a'), 'a');
      expect(recodeTexSymbol('0'), '0');
      expect(recodeTexSymbol('\\pm'), '\\pm');
    });
    test('base text symbols', () {
      expect(recodeTexSymbol('a', TexMode.text), 'a');
      expect(recodeTexSymbol('0', TexMode.text), '0');
      expect(recodeTexSymbol('\\dag', TexMode.text), '\\dag');
    });
    test('escaped math symbols', () {
      expect(recodeTexSymbol('\\{'), '\\{');
      expect(recodeTexSymbol('\\}'), '\\}');
      expect(recodeTexSymbol('\\&'), '\\&');
      expect(recodeTexSymbol('\\#'), '\\#');
      expect(recodeTexSymbol('\\_'), '\\_');
    });
  });
}
