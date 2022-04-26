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
      expect(isA<TexGreenFrac>().match(target), true);
      expect(isA<TexGreenEquationrow>().match(target), false);
      expect(
        isA(children: [
          isA<TexGreenEquationrow>(),
          isA<TexGreenEquationrow>(),
          isA<TexGreenEquationrow>(),
        ]).match(target),
        false,
      );
      expect(
        isA(children: [
          isA<TexGreenEquationrow>(),
          isNull,
        ]).match(target),
        false,
      );
      expect(isA(child: isA<TexGreenEquationrow>()).match(target), false);
      expect(isA(firstChild: isA<TexGreenFrac>()).match(target), false);
      expect(isA(lastChild: isA<TexGreenFrac>()).match(target), false);
      expect(isA(anyChild: isA<TexGreenFrac>()).match(target), false);
      expect(
        isA(
          everyChild: isA<TexGreenEquationrow>(
            anyChild: isA<TexGreenSymbol>(matchSelf: (final node) => node.symbol == '1'),
          ),
        ).match(target),
        false,
      );
      final completeMacher = isA<TexGreenFrac>(
        matchSelf: (final node) => node.barSize == null,
        selfSpecificity: 1,
        children: [
          isA<TexGreenEquationrow>(),
          isA<TexGreenEquationrow>(),
        ],
        firstChild: isA<TexGreenEquationrow>(),
        lastChild: isA<TexGreenEquationrow>(),
        anyChild: isA<TexGreenEquationrow>(),
        everyChild: isA<TexGreenEquationrow>(),
      );
      expect(
        completeMacher.specificity,
        3 * isA<TexGreenEquationrow>().specificity +
            isA<TexGreenFrac>().specificity +
            1,
      );
      expect(completeMacher.match(target), true);
    });
  });
}
