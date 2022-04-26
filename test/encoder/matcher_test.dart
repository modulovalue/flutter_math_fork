import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_math_fork/src/ast/ast.dart';
import 'package:flutter_math_fork/src/ast/ast_plus.dart';
import 'package:flutter_math_fork/src/encoder/matcher.dart';
import 'package:flutter_test/flutter_test.dart' hide isA, isNull;

void main() {
  group('Matcher test', () {
    test('null matcher', () {
      expect(isNull.match(null), true);
      expect(isNull.match(emptyEquationRowNode()), false);
    });
    test('node matcher', () {
      final target = TexParser('\\frac{123}{abc}', const TexParserSettings())
          .parse()
          .children
          .first;
      expect(isA<FracNode>().match(target), true);
      expect(isA<EquationRowNode>().match(target), false);
      expect(
        isA(children: [
          isA<EquationRowNode>(),
          isA<EquationRowNode>(),
          isA<EquationRowNode>(),
        ]).match(target),
        false,
      );
      expect(
        isA(children: [
          isA<EquationRowNode>(),
          isNull,
        ]).match(target),
        false,
      );
      expect(isA(child: isA<EquationRowNode>()).match(target), false);
      expect(isA(firstChild: isA<FracNode>()).match(target), false);
      expect(isA(lastChild: isA<FracNode>()).match(target), false);
      expect(isA(anyChild: isA<FracNode>()).match(target), false);
      expect(
        isA(
          everyChild: isA<EquationRowNode>(
            anyChild: isA<SymbolNode>(matchSelf: (final node) => node.symbol == '1'),
          ),
        ).match(target),
        false,
      );
      final completeMacher = isA<FracNode>(
        matchSelf: (final node) => node.barSize == null,
        selfSpecificity: 1,
        children: [
          isA<EquationRowNode>(),
          isA<EquationRowNode>(),
        ],
        firstChild: isA<EquationRowNode>(),
        lastChild: isA<EquationRowNode>(),
        anyChild: isA<EquationRowNode>(),
        everyChild: isA<EquationRowNode>(),
      );
      expect(
        completeMacher.specificity,
        3 * isA<EquationRowNode>().specificity +
            isA<FracNode>().specificity +
            1,
      );
      expect(completeMacher.match(target), true);
    });
  });
}
