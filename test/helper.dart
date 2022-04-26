import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_math_fork/src/parser/parser.dart';
import 'package:flutter_math_fork/src/widgets/tex.dart';
import 'package:flutter_test/flutter_test.dart';

void testTexToMatchGoldenFile(
  final String description,
  final String expression, {
  final String? location,
  final double scale = 1,
}) {
  testWidgets(description, (final WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = Size(500 * scale, 300 * scale);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Math.tex(
                  expression,
                  key: key,
                  options: MathOptions.deflt(
                    style: MathStyle.display,
                    fontSize: scale * MathOptions.defaultFontSize,
                  ),
                  onErrorFallback: (final _) => throw _,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (Platform.isWindows) {
      // Android-specific code
      await expectLater(find.byKey(key), matchesGoldenFile(location ?? 'golden/${description.hashCode}.png'));
    }
  });
}

void testTexToRender(
  final String description,
  final String expression, [
  final Future<void> Function(WidgetTester)? callback,
]) {
  testWidgets(description, (final WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Math.tex(
                  expression,
                  options: MathOptions.deflt(
                    fontSize: MathOptions.defaultFontSize,
                    style: MathStyle.display,
                  ),
                  onErrorFallback: (final _) => throw _,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (callback != null) {
      await callback(tester);
    }
  });
}

void testTexToRenderLike(
  final String description,
  final String expression1,
  final String expression2, [
  final TexParserSettings settings = strictSettings,
]) {
  testWidgets(description, (final WidgetTester tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Math.tex(
                  expression1,
                  key: key,
                  options: MathOptions.deflt(
                    fontSize: MathOptions.defaultFontSize,
                    style: MathStyle.display,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (Platform.isWindows) {
      // Android-specific code
      await expectLater(find.byKey(key),
          matchesGoldenFile('golden/temp/${(description + expression1 + expression2).hashCode}.png'));
    }

    final key2 = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Math.tex(
                  expression2,
                  key: key2,
                  options: MathOptions.deflt(
                    fontSize: MathOptions.defaultFontSize,
                    style: MathStyle.display,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (Platform.isWindows) {
      // Android-specific code
      await expectLater(find.byKey(key2),
          matchesGoldenFile('golden/temp/${(description + expression1 + expression2).hashCode}.png'));
    }
  });
}

const strictSettings = TexParserSettings(strict: Strict.error);
const nonstrictSettings = TexParserSettings(strict: Strict.ignore);

TexGreenEquationrow getParsed(
  final String expr, [
  final TexParserSettings settings = const TexParserSettings(),
]) =>
    TexParser(
      expr,
      settings,
    ).parse();

String prettyPrintJson(
  final Map<String, Object> a,
) =>
    const JsonEncoder.withIndent('| ').convert(a);

_ToParse toParse([
  final TexParserSettings settings = strictSettings,
]) =>
    _ToParse(settings);

class _ToParse extends Matcher {
  final TexParserSettings settings;

  _ToParse(this.settings);

  @override
  Description describe(final Description description) =>
      description.add('a TeX string can be parsed with default settings');

  @override
  Description describeMismatch(
    final dynamic item,
    final Description mismatchDescription,
    final Map<dynamic, dynamic> matchState,
    final bool verbose,
  ) {
    try {
      if (item is String) {
        TexParser(item, settings).parse();
        return super.describeMismatch(item, mismatchDescription, matchState, verbose);
      }
      return mismatchDescription.add('input is not a string');
    } on ParseException catch (e) {
      return mismatchDescription.add(e.message);
    } on Object catch (e) {
      return mismatchDescription.add(e.toString());
    }
  }

  @override
  bool matches(final dynamic item, final Map<dynamic, dynamic> matchState) {
    try {
      if (item is String) {
        // ignore: unused_local_variable
        final res = TexParser(item, const TexParserSettings()).parse();
        // print(prettyPrintJson(res.toJson()));
        return true;
      }
      return false;
    } on ParseException catch (_) {
      return false;
    }
  }
}

_ToNotParse toNotParse([
  final TexParserSettings settings = strictSettings,
]) =>
    _ToNotParse(settings);

class _ToNotParse extends Matcher {
  final TexParserSettings settings;

  _ToNotParse(this.settings);

  @override
  Description describe(final Description description) => description.add('a TeX string with parse errors');

  @override
  Description describeMismatch(
    final dynamic item,
    final Description mismatchDescription,
    final Map<dynamic, dynamic> matchState,
    final bool verbose,
  ) {
    try {
      if (item is String) {
        // ignore: unused_local_variable
        final res = TexParser(item, settings).parse();
        return super.describeMismatch(item, mismatchDescription, matchState, verbose);
        // return mismatchDescription.add(prettyPrintJson(res.toJson()));
      }
      return mismatchDescription.add('input is not a string');
    } on ParseException catch (_) {
      return super.describeMismatch(item, mismatchDescription, matchState, verbose);
    }
  }

  @override
  bool matches(
    final dynamic item,
    final Map<dynamic, dynamic> matchState,
  ) {
    try {
      if (item is String) {
        // ignore: unused_local_variable
        final res = TexParser(item, settings).parse();
        // print(prettyPrintJson(res.toJson()));
        return false;
      }
      return false;
    } on ParseException catch (_) {
      return true;
    }
  }
}

final toBuild = _ToBuild();

final toBuildStrict = _ToBuild(settings: strictSettings);

class _ToBuild extends Matcher {
  final MathOptions options;
  final TexParserSettings settings;

  _ToBuild({
    final MathOptions? options,
    final this.settings = nonstrictSettings,
  }) : this.options = options ?? MathOptions.displayOptions;

  @override
  Description describe(final Description description) =>
      description.add('a TeX string can be built into widgets');

  @override
  Description describeMismatch(
    final dynamic item,
    final Description mismatchDescription,
    final Map<dynamic, dynamic> matchState,
    final bool verbose,
  ) {
    try {
      if (item is String) {
        TexWidget(
          tex: TexRedRootImpl(
            greenValue: TexParser(
              item,
              settings,
            ).parse(),
          ),
          options: options,
        );
        return super.describeMismatch(item, mismatchDescription, matchState, verbose);
      }
      return mismatchDescription.add('input is not a string');
    } on ParseException catch (e) {
      return mismatchDescription.add(e.message);
    } on Object catch (e) {
      return mismatchDescription.add(e.toString());
    }
  }

  @override
  bool matches(
    final dynamic item,
    final Map<dynamic, dynamic> matchState,
  ) {
    try {
      if (item is String) {
        TexWidget(
          tex: TexRedRootImpl(
            greenValue: TexParser(
              item,
              settings,
            ).parse(),
          ),
          options: options,
        );
        return true;
      }
      return false;
    } on ParseException catch (_) {
      return false;
    }
  }
}
