import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_math_fork/src/encoder/matcher.dart';
import 'package:flutter_math_fork/src/parser/parser.dart';
import 'package:flutter_test/flutter_test.dart' hide isA, isNull;

void main() {
  group('Matcher test', () {
    test('null matcher', () {
      expect(isNull.match(null), true);
      expect(isNull.match(emptyEquationRowNode()), false);
    });
    test('node matcher', () {
      final target = TexParser(content :'\\frac{123}{abc}', settings: const TexParserSettings(),).parse().children.first;
      expect(const NodeMatcher<TexGreenFrac>().match(target), true);
      expect(const NodeMatcher<TexGreenEquationrow>().match(target), false);
      expect(
        const NodeMatcher(
          children: [
            NodeMatcher<TexGreenEquationrow>(),
            NodeMatcher<TexGreenEquationrow>(),
            NodeMatcher<TexGreenEquationrow>(),
          ],
        ).match(target),
        false,
      );
      expect(
        const NodeMatcher(
          children: [
            NodeMatcher<TexGreenEquationrow>(),
            isNull,
          ],
        ).match(target),
        false,
      );
      expect(const NodeMatcher(child: NodeMatcher<TexGreenEquationrow>()).match(target), false);
      expect(const NodeMatcher(firstChild: NodeMatcher<TexGreenFrac>()).match(target), false);
      expect(const NodeMatcher(lastChild: NodeMatcher<TexGreenFrac>()).match(target), false);
      expect(const NodeMatcher(anyChild: NodeMatcher<TexGreenFrac>()).match(target), false);
      expect(
        NodeMatcher(
          everyChild: NodeMatcher<TexGreenEquationrow>(
            anyChild: NodeMatcher<TexGreenSymbol>(matchSelf: (final node) => node.symbol == '1',),
          ),
        ).match(target),
        false,
      );
      final completeMacher = NodeMatcher<TexGreenFrac>(
        matchSelf: (final node) => node.barSize == null,
        selfSpecificity: 1,
        children: [
          const NodeMatcher<TexGreenEquationrow>(),
          const NodeMatcher<TexGreenEquationrow>(),
        ],
        firstChild: const NodeMatcher<TexGreenEquationrow>(),
        lastChild: const NodeMatcher<TexGreenEquationrow>(),
        anyChild: const NodeMatcher<TexGreenEquationrow>(),
        everyChild: const NodeMatcher<TexGreenEquationrow>(),
      );
      expect(
        completeMacher.specificity,
        3 * const NodeMatcher<TexGreenEquationrow>().specificity + const NodeMatcher<TexGreenFrac>().specificity + 1,
      );
      expect(completeMacher.match(target), true);
    });
  });
}
