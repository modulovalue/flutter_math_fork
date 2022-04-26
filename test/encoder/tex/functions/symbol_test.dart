import 'package:flutter_math_fork/ast.dart';
import 'package:flutter_math_fork/src/ast/ast.dart';
import 'package:flutter_math_fork/src/ast/types.dart';
import 'package:flutter_math_fork/src/encoder/tex_encoder.dart';
import 'package:flutter_math_fork/src/parser/parser.dart';
import 'package:flutter_math_fork/src/parser/settings.dart';
import 'package:flutter_test/flutter_test.dart';

String recodeTexSymbol(
  String tex, [
  final Mode mode = Mode.math,
]) {
  if (mode == Mode.text) {
    // ignore: parameter_assignments
    tex = '\\text{$tex}';
  }
  var node = TexParser(tex, const TexParserSettings()).parse().children.first;
  while (node is ParentableNode) {
    node = node.children.first!;
  }
  assert(node is SymbolNode, "");
  return node.encodeTeX(
    conf: mode == Mode.math ? TexEncodeConf.mathConf : TexEncodeConf.textConf,
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
      expect(recodeTexSymbol('a', Mode.text), 'a');
      expect(recodeTexSymbol('0', Mode.text), '0');
      expect(recodeTexSymbol('\\dag', Mode.text), '\\dag');
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
