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
      expect(isA<TexFrac>().match(target), true);
      expect(isA<TexEquationrow>().match(target), false);
      expect(
        isA(children: [
          isA<TexEquationrow>(),
          isA<TexEquationrow>(),
          isA<TexEquationrow>(),
        ]).match(target),
        false,
      );
      expect(
        isA(children: [
          isA<TexEquationrow>(),
          isNull,
        ]).match(target),
        false,
      );
      expect(isA(child: isA<TexEquationrow>()).match(target), false);
      expect(isA(firstChild: isA<TexFrac>()).match(target), false);
      expect(isA(lastChild: isA<TexFrac>()).match(target), false);
      expect(isA(anyChild: isA<TexFrac>()).match(target), false);
      expect(
        isA(
          everyChild: isA<TexEquationrow>(
            anyChild: isA<TexSymbol>(matchSelf: (final node) => node.symbol == '1'),
          ),
        ).match(target),
        false,
      );
      final completeMacher = isA<TexFrac>(
        matchSelf: (final node) => node.barSize == null,
        selfSpecificity: 1,
        children: [
          isA<TexEquationrow>(),
          isA<TexEquationrow>(),
        ],
        firstChild: isA<TexEquationrow>(),
        lastChild: isA<TexEquationrow>(),
        anyChild: isA<TexEquationrow>(),
        everyChild: isA<TexEquationrow>(),
      );
      expect(
        completeMacher.specificity,
        3 * isA<TexEquationrow>().specificity +
            isA<TexFrac>().specificity +
            1,
      );
      expect(completeMacher.match(target), true);
    });
  });
}
