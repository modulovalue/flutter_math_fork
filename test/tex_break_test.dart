import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_math_fork/src/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helper.dart';
import 'load_fonts.dart';

void main() {
  setUpAll(loadKaTeXFonts);
  group('TeX style line breaking', () {
    test('breaks without crashing', () {
      expect(getBreak('abc').parts.length, 1);
      expect(getBreak('abc').penalties.length, 1);
      expect(getBreak('a+c').parts.length, 2);
      expect(getBreak('a+c').penalties.length, 2);
    });
    group('only breaks at selected points', () {
      test("a", () {
        final sut = getBreak(r'a+b');
        expect(
          sut.parts.map((final a) => a.children.map((final a) => (a as TexGreenSymbol).symbol).join()).toList(),
          ['a+', 'b'],
        );
      });
      test("b", () {
        final sut = getBreak(r'a>b');
        expect(
          sut.parts.map((final a) => a.children.map((final a) => (a as TexGreenSymbol).symbol).join()).toList(),
          ['a>', 'b'],
        );
      });
      test("b", () {
        final sut = getBreak(r'a>+b');
        expect(
          sut.parts.map((final a) => a.children.map((final a) => (a as TexGreenSymbol).symbol).join()).toList(),
          ['a>', '+', 'b'],
        );
      });
      test("b", () {
        final sut = getBreak(r'a!>b');
        expect(
          sut.parts.map((final a) => a.children.map((final a) => (a as TexGreenSymbol).symbol).join()).toList(),
          ['a!>', 'b'],
        );
      });
      test(
        "b",
        () {
          // Need to change after future encoder improvement
          final sut = getBreak(r'a\allowbreak >\nobreak +b');
          expect(
            sut.parts
                .map(
                  (final a) => a.children.map(
                    (final a) {
                      if (a is TexGreenSymbol) {
                        return a.symbol;
                      } else if (a is TexGreenSpace) {
                        return " ";
                      } else {
                        throw Exception("Invalid State.");
                      }
                    },
                  ).join(),
                )
                .toList(),
            [r'a\allowbreak', r'>\nobreak +', 'b'],
          );
        },
        skip: "Skipping these for now until good fixtures can be generated.",
      );
    });
    test('does not break inside nested nodes', () {
      expect(getBreak(r'a{1+2>3\allowbreak (4)}c').parts.length, 1);
    });
    group('produces correct penalty values', () {
      test(
        "a",
        () {
          final sut = getBreak(r'a\allowbreak >+b');
          expect(
            sut.parts
                .map(
                  (final a) => a.children.map(
                    (final a) {
                      if (a is TexGreenSymbol) {
                        return a.symbol;
                      } else if (a is TexGreenSpace) {
                        return " ";
                      } else {
                        throw Exception("Invalid State.");
                      }
                    },
                  ).join(),
                )
                .toList(),
            [r'a\allowbreak', '>', '+', 'b'],
          );
          // TODO
          // [0, 500, 700, 10000],
        },
        skip: "Skipping these for now until good fixtures can be generated.",
      );
      test("b", () {
        expect(
          equationRowNodeTexBreak(
            tree: getParsed(r'a+b>+\nobreak c'),
            relPenalty: 999,
            binOpPenalty: 9,
            enforceNoBreak: false,
          ).penalties,
          [9, 999, 10000, 10000],
        );
      });
    });
    test(
      'preserves styles',
      () {
        final sut = getBreak(r'\mathit{a+b}>c');
        expect(
          sut.parts
              .map(
                (final a) => a.children.map(
                  (final a) {
                    if (a is TexGreenSymbol) {
                      return a.symbol;
                    } else if (a is TexGreenStyle) {
                      return "";
                    } else {
                      throw Exception("Invalid State.");
                    }
                  },
                ).join(),
              )
              .toList(),
          [r'\mathit{a+}', r'\mathit{b}>', r'c'],
        );
      },
      skip: "Skipping these for now until good fixtures can be generated.",
    );
    testWidgets('api works', (final tester) async {
      final widget = Math.tex(r'a+b>c');
      final breakRes = widget.texBreak();
      expect(breakRes.parts.length, 3);
      await tester.pumpWidget(MaterialApp(home: Wrap(children: breakRes.parts)));
    });
  });
}

BreakResult<TexGreenEquationrow> getBreak(
  final String input,
) =>
    equationRowNodeTexBreak(
      tree: getParsed(
        input,
      ),
    );
