import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_math_fork/ast.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_math_fork/src/ast/tex_break.dart';
import 'package:flutter_math_fork/tex.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helper.dart';
import 'load_fonts.dart';

BreakResult<EquationRowNode> getBreak(final String input) => getParsed(input).texBreak();

void main() {
  setUpAll(loadKaTeXFonts);

  group('TeX style line breaking', () {
    test('breaks without crashing', () {
      expect(getBreak('abc').parts.length, 1);
      expect(getBreak('abc').penalties.length, 1);
      expect(getBreak('a+c').parts.length, 2);
      expect(getBreak('a+c').penalties.length, 2);
    });

    test('only breaks at selected points', () {
      expect(r'a+b', toBreakLike(['a+', 'b']));
      expect(r'a>b', toBreakLike(['a>', 'b']));
      expect(r'a>+b', toBreakLike(['a>', '+', 'b']));
      expect(r'a!>b', toBreakLike(['a!>', 'b']));
      expect(
        r'a\allowbreak >\nobreak +b',
        toBreakLike([r'a\allowbreak', r'>\nobreak +', 'b']),
      ); // Need to change after future encoder improvement
    });

    test('does not break inside nested nodes', () {
      expect(getBreak(r'a{1+2>3\allowbreak (4)}c').parts.length, 1);
    });

    test('produces correct penalty values', () {
      expect(
        r'a\allowbreak >+b',
        toBreakLike(
          [r'a\allowbreak', '>', '+', 'b'],
          [0, 500, 700, 10000],
        ),
      );

      expect(
        getParsed(r'a+b>+\nobreak c')
            .texBreak(relPenalty: 999, binOpPenalty: 9, enforceNoBreak: false)
            .penalties,
        [9, 999, 10000, 10000],
      );
    });

    test('preserves styles', () {
      expect(
        r'\mathit{a+b}>c',
        toBreakLike([r'\mathit{a+}', r'\mathit{b}>', r'c']),
      );
    });

    testWidgets('api works', (final tester) async {
      final widget = Math.tex(r'a+b>c');
      final breakRes = widget.texBreak();
      expect(breakRes.parts.length, 3);
      await tester.pumpWidget(MaterialApp(home: Wrap(children: breakRes.parts)));
    });
  });
}

const _jsonEncoder = JsonEncoder.withIndent('  ');

class _ToBreakLike extends Matcher {
  final List<EquationRowNode> target;
  final List<int>? targetPenalties;

  _ToBreakLike(final List<String> target, this.targetPenalties)
      : target = target.map(getParsed).toList(growable: false);

  @override
  Description describe(final Description description) =>
      description.add('Tex-style line breaking results should match target: $target');

  @override
  Description describeMismatch(
    final dynamic item,
    final Description mismatchDescription,
    final Map<dynamic, dynamic> matchState,
    final bool verbose,
  ) {
    if (item is String) {
      final breakRes = getBreak(item);

      return mismatchDescription.add('${breakRes.parts.map((final e) => e.encodeTeX()).toList()} '
          'with penalties of ${breakRes.penalties}');
    }
    return super.describeMismatch(item, mismatchDescription, matchState, verbose);
  }

  @override
  bool matches(
    final dynamic item,
    final Map<dynamic, dynamic> matchState,
  ) {
    if (item is String) {
      final breakRes = getBreak(item);
      if (breakRes.parts.length != target.length) {
        return false;
      }
      for (var i = 0; i < target.length; i++) {
        if (_jsonEncoder.convert(breakRes.parts[i].toJson()) != _jsonEncoder.convert(target[i])) {
          return false;
        }
        if (targetPenalties != null && targetPenalties![i] != breakRes.penalties[i]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }
}

_ToBreakLike toBreakLike(final List<String> target, [final List<int>? penalties]) =>
    _ToBreakLike(target, penalties);
