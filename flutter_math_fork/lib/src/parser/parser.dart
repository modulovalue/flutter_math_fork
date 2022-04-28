// The MIT License (MIT)
//
// Copyright (c) 2013-2019 Khan Academy and other contributors
// Copyright (c) 2020 znjameswu <znjameswu@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:collection';

import '../ast/ast.dart';
import '../ast/ast_impl.dart';
import '../ast/ast_plus.dart';
import '../ast/symbols.dart';
import '../utils/extensions.dart';
import '../utils/log.dart';
import 'colors.dart';
import 'functions.dart';
import 'macro_expander.dart';
import 'symbols.dart';

/// Parser for TeX equations
///
/// Convert TeX string to Flutter Math's AST
class TexParser {
  final TexParserSettings settings;

  TexParser({
    required final String content,
    required final this.settings,
  })  : this.leftrightDepth = 0,
        this.mode = TexMode.math,
        this.macroExpander = MacroExpander(
          content,
          settings,
          TexMode.math,
        );

  TexMode mode;
  int leftrightDepth;

  final MacroExpander macroExpander;
  Token? nextToken;

  /// Get parse result
  TexGreenEquationrowImpl parse() {
    if (!this.settings.globalGroup) {
      this.macroExpander.beginGroup();
    }
    if (this.settings.colorIsTextColor) {
      this.macroExpander.macros.set(
            '\\color',
            MacroDefinition.fromString(
              '\\textcolor',
            ),
          );
    }
    final parse = this.parseExpression(breakOnInfix: false);
    this.expect('EOF');
    if (!this.settings.globalGroup) {
      this.macroExpander.endGroup();
    }
    return greenNodesWrapWithEquationRow(
      parse,
    );
  }

  List<TexGreen> parseExpression({
    final bool breakOnInfix = false,
    final String? breakOnTokenText,
    final bool infixArgumentMode = false,
  }) {
    final body = <TexGreen>[];
    for (;;) {
      if (this.mode == TexMode.math) {
        this.consumeSpaces();
      }
      final lex = this.fetch();
      if (endOfExpression.contains(lex.text)) {
        break;
      }
      if (breakOnTokenText != null && lex.text == breakOnTokenText) {
        break;
      }
      // Detects a infix function
      final funcData = functions[lex.text];
      if (funcData != null && funcData.infix == true) {
        if (infixArgumentMode) {
          throw ParseException('only one infix operator per group', lex);
        }
        if (breakOnInfix) {
          break;
        }
        this.consume();
        _enterArgumentParsingMode(lex.text, funcData);
        try {
          // A new way to handle infix operations
          final atom = funcData.handler(
            this,
            FunctionContext(
              funcName: lex.text,
              breakOnTokenText: breakOnTokenText,
              token: lex,
              infixExistingArguments: List.of(body, growable: false),
            ),
          );
          body.clear();
          body.add(atom);
        } finally {
          _leaveArgumentParsingMode(lex.text);
        }
      } else {
        // Add a normal atom
        final atom = this.parseAtom(breakOnTokenText);
        if (atom == null) {
          break;
        }
        body.add(atom);
      }
    }

    return body;
    // We will NOT handle ligatures between '-' and "'", as neither did MathJax.
    // if (this.mode == Mode.text) {
    //   formLigatures(body);
    // }
    // We will not handle infix as well
    // return handleInfixNodes(body);
  }

  static const Set<String> breakTokens = {
    ']',
    '}',
    '\\endgroup',
    '\$',
    '\\)',
    '\\cr',
  };
  static const Set<String> endOfExpression = {
    '}',
    '\\endgroup',
    '\\end',
    '\\right',
    '&',
  };

  static const Map<String, String> endOfGroup = {
    '[': ']',
    '{': '}',
    '\\begingroup': '\\endgroup',
  };

  void expect(
    final String text, {
    final bool consume = true,
  }) {
    if (this.fetch().text != text) {
      throw ParseException('Expected \'$text\', got \'${this.fetch().text}\'', this.fetch());
    }
    if (consume) {
      this.consume();
    }
  }

  void consumeSpaces() {
    while (this.fetch().text == ' ') {
      this.consume();
    }
  }

  TexGreen? parseAtom(final String? breakOnTokenText) {
    final base =
        this.parseGroup('atom', optional: false, greediness: null, breakOnTokenText: breakOnTokenText);
    if (this.mode == TexMode.text) {
      return base;
    }
    final scriptsResult = parseScripts(
      allowLimits: base is TexGreenEquationrow && base.overrideType == TexAtomType.op,
    );
    if (!scriptsResult.empty) {
      if (scriptsResult.limits != true) {
        return TexGreenMultiscriptsImpl(
          base: greenNodeWrapWithEquationRowOrNull(base) ?? emptyEquationRowNode(),
          sub: scriptsResult.subscript,
          sup: scriptsResult.superscript,
        );
      } else {
        final TexGreen? res;
        if (scriptsResult.superscript != null) {
          res = TexGreenOverImpl(
            base: greenNodeWrapWithEquationRowOrNull(base) ?? emptyEquationRowNode(),
            above: scriptsResult.superscript!,
          );
        } else {
          res = base;
        }
        if (scriptsResult.subscript != null) {
          return TexGreenUnderImpl(
            base: greenNodeWrapWithEquationRowOrNull(res) ?? emptyEquationRowNode(),
            below: scriptsResult.subscript!,
          );
        } else {
          return res;
        }
      }
    } else {
      return base;
    }
  }

  /// The following functions are separated from parseAtoms in KaTeX
  /// This function will only be invoked in math mode
  ScriptsParsingResults parseScripts({
    final bool allowLimits = false,
  }) {
    TexGreenEquationrow? subscript;
    TexGreenEquationrow? superscript;
    bool? limits;
    loop:
    for (;;) {
      this.consumeSpaces();
      final lex = this.fetch();
      switch (lex.text) {
        case '\\limits':
        case '\\nolimits':
          if (!allowLimits) {
            throw ParseException('Limit controls must follow a math operator', lex);
          }
          limits = lex.text == '\\limits';
          this.consume();
          break;
        case '^':
          if (superscript != null) {
            throw ParseException('Double superscript', lex);
          } else {
            superscript = greenNodeWrapWithEquationRow(
              this._handleScript(),
            );
            break;
          }
        case '_':
          if (subscript != null) {
            throw ParseException('Double subscript', lex);
          } else {
            subscript = greenNodeWrapWithEquationRow(
              this._handleScript(),
            );
            break;
          }
        case "'":
          // ignore: invariant_booleans
          if (superscript != null) {
            throw ParseException(
              'Double superscript',
              lex,
            );
          } else {
            final primeCommand = texSymbolCommandConfigs[TexMode.math]!['\\prime']!;
            final superscriptList = <TexGreen>[
              TexGreenSymbolImpl(
                mode: mode,
                symbol: primeCommand.symbol,
                variantForm: primeCommand.variantForm,
                overrideAtomType: primeCommand.type,
                overrideFont: primeCommand.font,
              ),
            ];
            this.consume();
            while (this.fetch().text == "'") {
              superscriptList.add(
                TexGreenSymbolImpl(
                  mode: mode,
                  symbol: primeCommand.symbol,
                  variantForm: primeCommand.variantForm,
                  overrideAtomType: primeCommand.type,
                  overrideFont: primeCommand.font,
                ),
              );
              this.consume();
            }
            if (this.fetch().text == '^') {
              superscriptList.addAll(
                greenNodeExpandEquationRow(
                  this._handleScript(),
                ),
              );
            }
            superscript = greenNodesWrapWithEquationRow(
              superscriptList,
            );
            break;
          }
        default:
          break loop;
      }
    }
    return ScriptsParsingResults(
      subscript: subscript,
      superscript: superscript,
      limits: limits,
    );
  }

  TexGreen _handleScript() {
    final symbolToken = this.fetch();
    final symbol = symbolToken.text;
    this.consume();
    final group = this.parseGroup(
      symbol == '_' ? 'subscript' : 'superscript',
      optional: false,
      greediness: TexParser.supsubGreediness,
      consumeSpaces: true,
    );
    if (group == null) {
      throw ParseException("Expected group after '$symbol'", symbolToken);
    }
    return group;
  }

  static const supsubGreediness = 1;

  Token fetch() {
    final nextToken = this.nextToken;
    if (nextToken == null) {
      return this.nextToken = this.macroExpander.expandNextToken();
    }
    return nextToken;
  }

  void consume() {
    this.nextToken = null;
  }

  /// [parseGroup] Return a row if encounters [] or {}. Returns single function
  /// node or a single symbol otherwise.
  ///
  ///
  /// If `optional` is false or absent, this parses an ordinary group,
  /// which is either a single nucleus (like "x") or an expression
  /// in braces (like "{x+y}") or an implicit group, a group that starts
  /// at the current position, and ends right before a higher explicit
  /// group ends, or at EOF.
  /// If `optional` is true, it parses either a bracket-delimited expression
  /// (like "[x+y]") or returns null to indicate the absence of a
  /// bracket-enclosed group.
  /// If `mode` is present, switches to that mode while parsing the group,
  /// and switches back after.
  TexGreen? parseGroup(
    final String name, {
    required final bool optional,
    final int? greediness,
    final String? breakOnTokenText,
    final TexMode? mode,
    final bool consumeSpaces = false,
  }) {
    // Save current mode and restore after completion
    final outerMode = this.mode;
    if (mode != null) {
      this.switchMode(mode);
    }
    // Consume spaces if requested, crucially *after* we switch modes,
    // so that the next non-space token is parsed in the correct mode.
    if (consumeSpaces == true) {
      this.consumeSpaces();
    }
    // Get first token
    final firstToken = this.fetch();
    final text = firstToken.text;
    TexGreen? result;
    // Try to parse an open brace or \begingroup
    if (optional ? text == '[' : text == '{' || text == '\\begingroup') {
      this.consume();
      final groupEnd = endOfGroup[text]!;
      // Start a new group namespace
      this.macroExpander.beginGroup();
      // If we get a brace, parse an expression
      final expression = this.parseExpression(breakOnInfix: false, breakOnTokenText: groupEnd);
      // final lastToken = this.fetch();
      // Check that we got a matching closing brace
      this.expect(groupEnd);
      this.macroExpander.endGroup();
      result = greenNodesWrapWithEquationRow(
        expression,
      );
    } else if (optional) {
      // Return nothing for an optional group
      result = null;
    } else {
      // If there exists a function with this name, parse the function.
      // Otherwise, just return a nucleus
      result = this.parseFunction(breakOnTokenText, name, greediness) ?? this._parseSymbol();
      if (result == null && text[0] == '\\' && !implicitCommands.contains(text)) {
        if (this.settings.throwOnError) {
          throw ParseException('Undefined control sequence: $text', firstToken);
        }
        result = this._formatUnsuppotedCmd(text);
        this.consume();
      }
    }
    if (mode != null) {
      this.switchMode(outerMode);
    }
    return result;
  }

  ///Parses an entire function, including its base and all of its arguments.

  TexGreen? parseFunction(
    final String? breakOnTokenText,
    final String? name,
    final int? greediness,
  ) {
    final token = this.fetch();
    final func = token.text;
    final funcData = functions[func];
    if (funcData == null) {
      return null;
    } else {
      this.consume();
      if (greediness != null &&
          // funcData.greediness != null &&
          funcData.greediness <= greediness) {
        throw ParseException(
          '''Got function '$func' with no arguments ${name != null ? ' as $name' : ''}''',
          token,
        );
      } else if (this.mode == TexMode.text && !funcData.allowedInText) {
        throw ParseException(
          '''Can't use function '$func' in text mode''',
          token,
        );
      } else if (this.mode == TexMode.math && funcData.allowedInMath == false) {
        throw ParseException(
          '''Can't use function '$func' in math mode''',
          token,
        );
      }
      // final funcArgs = parseArgument(func, funcData);
      final context = FunctionContext(
        funcName: func,
        token: token,
        breakOnTokenText: breakOnTokenText,
      );
      // if (funcData.handler != null) {
      _enterArgumentParsingMode(func, funcData);
      try {
        return funcData.handler(this, context);
      } finally {
        _leaveArgumentParsingMode(func);
      }
      // } else {
      //   throw ParseException('''No function handler for $name''');
      // }
      // return this.callFunction(func, token, breakOnTokenText);
    }
  }

  final argParsingContexts = Queue<ArgumentParsingContext>();

  ArgumentParsingContext get currArgParsingContext => argParsingContexts.last;

  void _enterArgumentParsingMode(
    final String name,
    final FunctionSpec funcData,
  ) {
    argParsingContexts.addLast(ArgumentParsingContext(funcName: name, funcData: funcData));
  }

  void _leaveArgumentParsingMode(
    final String name,
  ) {
    assert(currArgParsingContext.funcName == name, "");
    argParsingContexts.removeLast();
  }

  void _assertOptionalBeforeReturn(
    final dynamic value, {
    required final bool optional,
  }) {
    if (!optional && value == null) {
      throw ParseException(
        'Expected group after ${currArgParsingContext.funcName}',
        this.fetch(),
      );
    }
  }

  static final _parseColorRegex1 = RegExp(
    r'^#([a-f0-9])([a-f0-9])([a-f0-9])$',
    caseSensitive: false,
  );
  static final _parseColorRegex2 = RegExp(
    r'^#?([a-f0-9]{2})([a-f0-9]{2})([a-f0-9]{2})$',
    caseSensitive: false,
  );
  static final _parseColorRegex3 = RegExp(
    r'^([a-z]+)$',
    caseSensitive: false,
  );

  // static final _parseColorRegex =
  //     RegExp(r'^(#[a-f0-9]{3}|#?[a-f0-9]{6}|[a-z]+)$', caseSensitive: false);
  // static final _matchColorRegex =
  //     RegExp(r'[0-9a-f]{6}', caseSensitive: false);
  TexColor? parseArgColor({
    required final bool optional,
  }) {
    currArgParsingContext.newArgument(optional: optional);
    final i = currArgParsingContext.currArgNum;
    final consumeSpaces = (i > 0 && !optional) || (i == 0 && !optional && this.mode == TexMode.math);
    if (consumeSpaces) {
      this.consumeSpaces();
    }
    // final res = this.parseColorGroup(optional: optional);
    final res = this._parseStringGroup('color', optional: optional);
    if (res == null) {
      _assertOptionalBeforeReturn(null, optional: optional);
      return null;
    } else {
      final match3 = _parseColorRegex3.firstMatch(res.text);
      if (match3 != null) {
        final color = colorByName[match3[0]!.toLowerCase()];
        if (color != null) {
          return color;
        }
      }
      final match2 = _parseColorRegex2.firstMatch(res.text);
      if (match2 != null) {
        return TexColorImpl.fromARGB(
          0xff,
          int.parse(match2[1]!, radix: 16),
          int.parse(match2[2]!, radix: 16),
          int.parse(match2[3]!, radix: 16),
        );
      } else {
        final match1 = _parseColorRegex1.firstMatch(res.text);
        if (match1 != null) {
          return TexColorImpl.fromARGB(
            0xff,
            int.parse(match1[1]! * 2, radix: 16),
            int.parse(match1[2]! * 2, radix: 16),
            int.parse(match1[3]! * 2, radix: 16),
          );
        }
        throw ParseException("Invalid color: '${res.text}'");
      }
    }
  }

  static final _parseSizeRegex = RegExp(r'^[-+]? *(?:$|\d+|\d+\.\d*|\.\d*) *[a-z]{0,2} *$');
  static final _parseMeasurementRegex = RegExp(r'([-+]?) *(\d+(?:\.\d*)?|\.\d+) *([a-z]{2})');

  TexMeasurement? parseArgSize({
    required final bool optional,
  }) {
    currArgParsingContext.newArgument(optional: optional);
    final i = currArgParsingContext.currArgNum;
    final consumeSpaces = (i > 0 && !optional) || (i == 0 && !optional && this.mode == TexMode.math);
    if (consumeSpaces) {
      this.consumeSpaces();
    }
    // final res = this.parseSizeGroup(optional: optional);
    Token? res;
    if (!optional && this.fetch().text != '{') {
      res = _parseRegexGroup(_parseSizeRegex, 'size');
    } else {
      res = _parseStringGroup('size', optional: optional);
    }
    if (res == null) {
      _assertOptionalBeforeReturn(null, optional: optional);
      return null;
    } else if (!optional && res.text.isEmpty) {
      // res.text = '0pt';
      // This means default width for genfrac, and 0pt for above
      return null;
    } else {
      final match = _parseMeasurementRegex.firstMatch(res.text);
      if (match == null) {
        throw ParseException(
          "Invalid size: '${res.text}'",
          res,
        );
      } else {
        final unit = parseMeasurement(
          str: match[3]!,
          value: double.parse(match[1]! + match[2]!),
        );
        if (unit == null) {
          throw ParseException(
            "Invalid unit: '${match[3]}'",
            res,
          );
        } else {
          return unit;
        }
      }
    }
  }

  String parseArgUrl({required final bool optional}) {
    currArgParsingContext.newArgument(optional: optional);
    // final i = currArgParsingContext.currArgNum;
    // final consumeSpaces =
    //  (i > 0 && !optional) || (i == 0 && !optional && this.mode == Mode.math);
    // if (consumeSpaces) {
    //   this.consumeSpaces();
    // }
    // final res = this.parseUrlGroup(optional: optional);
    throw UnimplementedError();
  }

  TexGreen? parseArgNode({required final TexMode? mode, required final bool optional}) {
    currArgParsingContext.newArgument(optional: optional);
    final i = currArgParsingContext.currArgNum;
    final consumeSpaces = (i > 0 && !optional) || (i == 0 && !optional && this.mode == TexMode.math);
    // if (consumeSpaces) {
    //   this.consumeSpaces();
    // }
    final res = this.parseGroup(
      currArgParsingContext.name,
      optional: optional,
      greediness: currArgParsingContext.funcData.greediness,
      mode: mode,
      consumeSpaces: consumeSpaces,
    );
    _assertOptionalBeforeReturn(res, optional: optional);
    return res;
  }

  TexGreen parseArgHbox({required final bool optional}) {
    final res = parseArgNode(mode: TexMode.text, optional: optional);
    if (res is TexGreenEquationrow) {
      return TexGreenEquationrowImpl(
        children: [
          TexGreenStyleImpl(
            optionsDiff: const TexOptionsDiffImpl(
              style: TexMathStyle.text,
            ),
            children: res.children,
          )
        ],
      );
    } else {
      return TexGreenStyleImpl(
        optionsDiff: const TexOptionsDiffImpl(
          style: TexMathStyle.text,
        ),
        children: res?.childrenl.whereNotNull().toList(growable: false) ?? [],
      );
    }
  }

  String? parseArgRaw({required final bool optional}) {
    currArgParsingContext.newArgument(optional: optional);
    final i = currArgParsingContext.currArgNum;
    final consumeSpaces = (i > 0 && !optional) || (i == 0 && !optional && this.mode == TexMode.math);
    if (consumeSpaces) {
      this.consumeSpaces();
    }
    if (optional && this.fetch().text == '{') {
      return null;
    }
    final token = this._parseStringGroup('raw', optional: optional);
    if (token != null) {
      return token.text;
    } else {
      throw ParseException('Expected raw group', this.fetch());
    }
  }

  static final _parseStringGroupRegex = RegExp('''[^{}[\]]''');

  Token? _parseStringGroup(
    final String modeName, {
    required final bool optional,
    final bool raw = false,
  }) {
    final groupBegin = optional ? '[' : '{';
    final groupEnd = optional ? ']' : '}';
    final beginToken = this.fetch();
    if (beginToken.text != groupBegin) {
      if (optional) {
        return null;
      } else if (raw && beginToken.text != 'EOF' && _parseStringGroupRegex.hasMatch(beginToken.text)) {
        this.consume();
        return beginToken;
      }
    }
    final outerMode = this.mode;
    this.mode = TexMode.text;
    this.expect(groupBegin);

    var str = '';
    final firstToken = this.fetch();
    var nested = 0;
    var lastToken = firstToken;
    Token nextToken;
    while ((nextToken = this.fetch()).text != groupEnd || (raw && nested > 0)) {
      if (nextToken.text == 'EOF') {
        throw ParseException('Unexpected end of input in $modeName', Token.range(firstToken, lastToken, str));
      } else if (nextToken.text == groupBegin) {
        nested++;
      } else if (nextToken.text == groupEnd) {
        nested--;
      }
      lastToken = nextToken;
      // ignore: use_string_buffers
      str += lastToken.text;
      this.consume();
    }
    this.expect(groupEnd);
    this.mode = outerMode;
    return Token.range(firstToken, lastToken, str);
  }

  Token _parseRegexGroup(final RegExp regex, final String modeName) {
    final outerMode = this.mode;
    this.mode = TexMode.text;
    final firstToken = this.fetch();
    var lastToken = firstToken;
    var str = '';
    Token nextToken;
    while ((nextToken = this.fetch()).text != 'EOF' && regex.hasMatch(str + nextToken.text)) {
      lastToken = nextToken;
      // ignore: use_string_buffers
      str += lastToken.text;
      this.consume();
    }
    if (str.isEmpty) {
      throw ParseException("Invalid $modeName: '${firstToken.text}'", firstToken);
    }
    this.mode = outerMode;
    return Token.range(firstToken, lastToken, str);
  }

  static final _parseVerbRegex = RegExp(r'^\\verb[^a-zA-Z]');

  TexGreen? _parseSymbol() {
    final nucleus = this.fetch();
    var text = nucleus.text;
    if (_parseVerbRegex.hasMatch(text)) {
      this.consume();
      var arg = text.substring(5);
      final star = arg[0] == '*'; //?
      if (star) {
        arg = arg.substring(1);
      }
      // Lexer's tokenRegex is constructed to always have matching
      // first/last characters.
      if (arg.length < 2 || arg[0] != arg[arg.length - 1]) {
        throw ParseException('''\\verb assertion failed --
                    please report what input caused this bug''');
      }
      arg = arg.substring(1, arg.length - 1);
      return TexGreenEquationrowImpl(
        children: arg
            .split('')
            .map(
              (final char) => TexGreenSymbolImpl(
                symbol: char,
                overrideFont: const TexFontOptionsImpl(
                  fontFamily: 'Typewriter',
                ),
                mode: TexMode.text,
              ),
            )
            .toList(growable: false),
      );
    }
    // At this point, we should have a symbol, possibly with accents.
    // First expand any accented base symbol according to unicodeSymbols.
    if (unicodeSymbols.containsKey(text[0]) && !texSymbolCommandConfigs[this.mode]!.containsKey(text[0])) {
      if (this.mode == TexMode.math) {
        this.settings.reportNonstrict('unicodeTextInMathMode',
            'Accented Unicode text character "${text[0]}" used in math mode', nucleus);
      }
      // text = unicodeSymbols[text[0]] + text.substring(1);
    }
    // Strip off any combining characters
    final match = Lexer.combiningDiacriticalMarksEndRegex.firstMatch(text);
    var combiningMarks = '';
    if (match != null) {
      text = text.substring(0, match.start);
      for (var i = 0; i < match[0]!.length; i++) {
        final accent = match[0]![i];
        if (!unicodeAccentsParser.containsKey(accent)) {
          throw ParseException("Unknown accent ' $accent'", nucleus);
        }
        final command = unicodeAccentsParser[accent]![this.mode];
        if (command == null) {
          throw ParseException('Accent $accent unsupported in ${this.mode} mode', nucleus);
        }
      }
      combiningMarks = match[0]!;
    }
    // Recognize base symbol
    TexGreen symbol;
    final symbolCommandConfig = texSymbolCommandConfigs[this.mode]![text];
    if (symbolCommandConfig != null) {
      if (this.mode == TexMode.math && extraLatin.contains(text)) {
        this.settings.reportNonstrict('unicodeTextInMathMode',
            'Latin-1/Unicode text character "${text[0]}" used in math mode', nucleus);
      }
      // final loc = SourceLocation.range(nucleus);
      symbol = TexGreenSymbolImpl(
        mode: mode,
        symbol: symbolCommandConfig.symbol + combiningMarks,
        variantForm: symbolCommandConfig.variantForm,
        overrideAtomType: symbolCommandConfig.type,
        overrideFont: symbolCommandConfig.font,
      );
    } else if (text.isNotEmpty && text.codeUnitAt(0) >= 0x80) {
      if (!texSupportedCodepoint(text.codeUnitAt(0))) {
        this.settings.reportNonstrict(
            'unknownSymbol',
            'Unrecognized Unicode character "${text[0]}" '
                '(${text.codeUnitAt(0)})',
            nucleus);
      } else if (this.mode == TexMode.math) {
        this.settings.reportNonstrict(
            'unicodeTextInMathMode', 'Unicode text character "${text[0]} used in math mode"', nucleus);
      }
      symbol = TexGreenSymbolImpl(
        symbol: text + combiningMarks,
        overrideAtomType: TexAtomType.ord,
        mode: mode,
      );
    } else {
      return null;
    }
    this.consume();
    return symbol;
  }

  void switchMode(final TexMode newMode) {
    this.mode = newMode;
    this.macroExpander.mode = newMode;
  }

  TexGreen _formatUnsuppotedCmd(final String text) {
    //TODO
    throw UnimplementedError();
  }
}

class ArgumentParsingContext {
  final String funcName;
  int currArgNum;
  final FunctionSpec funcData;

  bool get optional => _optional;
  bool _optional;

  set optional(final bool value) {
    assert(_optional || !value, "");
    _optional = value;
  }

  String get name => 'argument to $funcName';

  ArgumentParsingContext({
    required final this.funcData,
    required final this.funcName,
    final this.currArgNum = -1,
    final bool optional = true,
  }) : _optional = optional;

  void newArgument({required final bool optional}) {
    currArgNum++;
    this.optional = optional;
  }
}

class ScriptsParsingResults {
  final TexGreenEquationrow? subscript;
  final TexGreenEquationrow? superscript;
  final bool? limits;

  const ScriptsParsingResults({
    required final this.subscript,
    required final this.superscript,
    final this.limits,
  });

  bool get empty => subscript == null && superscript == null;
}

T assertNodeType<T extends TexGreen?>(
  final TexGreen? node,
) {
  if (node is T) {
    return node;
  } else {
    throw ParseException('Expected node of type $T, but got node of type ${node.runtimeType}');
  }
}

class ParseException implements FlutterMathException {
  /// Nullable
  int? position;
  @override
  String message;

  @override
  String get messageWithType => 'Parser Error: $message';

  /// Nullable
  Token? token;

  ParseException(
    String message, [
    final this.token,
  ]) : message = '$message' {
    final loc = token?.loc;
    if (loc != null && loc.start <= loc.end) {
      final input = loc.lexer.input;

      final start = loc.start;
      this.position = start;
      final end = loc.end;
      if (start == input.length) {
        message = '$message at end of input: ';
      } else {
        message = '$message at position ${start + 1}: ';
      }

      final underlined =
          input.substring(start, end).replaceAllMapped(RegExp(r'[^]'), (final match) => '${match[0]}\u0332');
      if (start > 15) {
        message = '$message…${input.substring(start - 15, start)}$underlined';
      } else {
        message = '$message${input.substring(0, start)}$underlined';
      }
      if (end + 15 < input.length) {
        message = '$message${input.substring(end, end + 15)}…';
      } else {
        message = '$message${input.substring(end)}';
      }
    }
  }
}

/// Base class for exceptions.
abstract class FlutterMathException implements Exception {
  String get message;

  String get messageWithType;
}

class Token {
  String text;
  SourceLocation? loc;
  bool noexpand = false;
  bool treatAsRelax = false;

  Token(
    final this.text, [
    final this.loc,
  ]);

  static Token range(
    final Token startToken,
    final Token endToken,
    final String text,
  ) =>
      Token(
        text,
        SourceLocation.range(
          startToken,
          endToken,
        ),
      );
}

class SourceLocation {
  final LexerInterface lexer;
  final int start;
  final int end;

  const SourceLocation(
    this.lexer,
    this.start,
    this.end,
  );

  static SourceLocation? range(
    final Token first, [
    final Token? second,
  ]) {
    if (second == null) {
      return first.loc;
    } else if (first.loc == null || second.loc == null || first.loc!.lexer != second.loc!.lexer) {
      return null;
    } else {
      return SourceLocation(first.loc!.lexer, first.loc!.start, second.loc!.end);
    }
  }
}

/// Strict level for [TexParser]
enum Strict {
  /// Ignore non-strict behaviors
  ignore,

  /// Warn on non-strict behaviors
  warn,

  /// Throw on non-strict behaviors
  error,

  /// Non-strict behaviors will be reported to [TexParserSettings.strictFun] and
  /// processed according to the return value
  function,
}

/// Settings for [TexParser]
class TexParserSettings {
  final bool displayMode; // TODO
  final bool throwOnError; // TODO

  /// Extra macros
  final Map<String, MacroDefinition> macros;

  /// Max expand depth for macro expansions. Default 1000
  final int maxExpand;

  /// Strict level for parsing. Default [Strict.warn]
  final Strict strict;

  /// Functions to decide how to handle non-strict behaviors. Must set
  /// [TexParserSettings.strict] to [Strict.function]
  final Strict Function(String, String, Token?)? strictFun;

  final bool globalGroup; // TODO

  /// Behavior of `\color` command
  ///
  /// See https://katex.org/docs/options.html
  final bool colorIsTextColor;

  const TexParserSettings({
    final this.displayMode = false,
    final this.throwOnError = true,
    final this.macros = const {},
    final this.maxExpand = 1000,
    final Strict strict = Strict.warn,
    final this.strictFun,
    final this.globalGroup = false,
    final this.colorIsTextColor = false,
  }) : this.strict = strictFun == null ? strict : Strict.function
  //: assert(strict != Strict.function || strictFun != null) // This line causes analyzer error
  ;

  void reportNonstrict(
    final String errorCode,
    final String errorMsg, [
    final Token? token,
  ]) {
    final strict = () {
      if (this.strict != Strict.function) {
        return this.strict;
      } else {
        return strictFun?.call(errorCode, errorMsg, token) ?? Strict.warn;
      }
    }();
    switch (strict) {
      case Strict.ignore:
        return;
      case Strict.error:
        throw ParseException(
            "LaTeX-incompatible input and strict mode is set to 'error': "
            '$errorMsg [$errorCode]',
            token);
      case Strict.warn:
        warn("LaTeX-incompatible input and strict mode is set to 'warn': "
            '$errorMsg [$errorCode]');
        break;
      case Strict.function:
        warn('LaTeX-incompatible input and strict mode is set to '
            "unrecognized '$strict': $errorMsg [$errorCode]");
        break;
    }
  }

  bool useStrictBehavior(final String errorCode, final String errorMsg, [final Token? token]) {
    var strict = this.strict;
    if (strict == Strict.function) {
      try {
        strict = strictFun!(errorCode, errorMsg, token);
      } on Object {
        strict = Strict.error;
      }
    }
    switch (strict) {
      case Strict.ignore:
        return false;
      case Strict.error:
        return true;
      case Strict.warn:
        warn("LaTeX-incompatible input and strict mode is set to 'warn': "
            '$errorMsg [$errorCode]');
        return false;
      case Strict.function:
        warn('LaTeX-incompatible input and strict mode is set to '
            "unrecognized '$strict': $errorMsg [$errorCode]");
        return false;
    }
  }
}

abstract class LexerInterface {
  String get input;
}

class Lexer implements LexerInterface {
  static const spaceRegexString = '[ \r\n\t]';
  static const controlWordRegexString = '\\\\[a-zA-Z@]+';
  static const controlSymbolRegexString = '\\\\[^\uD800-\uDFFF]';
  static const controlWordWhitespaceRegexString = '$controlWordRegexString$spaceRegexString*';
  static final controlWordWhitespaceRegex = RegExp('^($controlWordRegexString)$spaceRegexString*\$');
  static const combiningDiacriticalMarkString = '[\u0300-\u036f]';
  static final combiningDiacriticalMarksEndRegex = RegExp('$combiningDiacriticalMarkString+\$');
  static const tokenRegexString = '($spaceRegexString+)|' // white space
      '([!-\\[\\]-\u2027\u202A-\uD7FF\uF900-\uFFFF]' // single codepoint
      '$combiningDiacriticalMarkString*' // ...plus accents
      '|[\uD800-\uDBFF][\uDC00-\uDFFF]' // surrogate pair
      '$combiningDiacriticalMarkString*' // ...plus accents
      '|\\\\verb\\*([^]).*?\\3' // \verb*
      '|\\\\verb([^*a-zA-Z]).*?\\4' // \verb unstarred
      '|\\\\operatorname\\*' // \operatorname*
      '|$controlWordWhitespaceRegexString' // \macroName + spaces
      '|$controlSymbolRegexString)'; // \\, \', etc.

  static final tokenRegex = RegExp(
    tokenRegexString,
    multiLine: true,
  );

  Lexer(
    final this.input,
    final this.settings,
  ) : it = tokenRegex.allMatches(input).iterator;

  @override
  final String input;
  final TexParserSettings settings;
  final Map<String, int> catCodes = {'%': 14};
  int pos = 0;

  // final Iterable<RegExpMatch> matches;
  final Iterator<RegExpMatch> it;

  Token lex() {
    if (this.pos == input.length) {
      return Token('EOF', SourceLocation(this, pos, pos));
    } else {
      final hasMatch = it.moveNext();
      if (!hasMatch) {
        throw ParseException(
            'Unexpected character: \'${input[pos]}\'', Token(input[pos], SourceLocation(this, pos, pos + 1)));
      }

      final match = it.current;
      if (match.start != pos) {
        throw ParseException(
            'Unexpected character: \'${input[pos]}\'', Token(input[pos], SourceLocation(this, pos, pos + 1)));
      }
      pos = match.end;
      String text = match[2] ?? ' ';
      if (text == '%') {
        // comment character
        final nlIndex = input.indexOf('\n', it.current.end);
        if (nlIndex == -1) {
          pos = input.length;
          while (it.moveNext()) {
            pos = it.current.end;
          }
          this.settings.reportNonstrict(
              'commentAtEnd',
              '% comment has no terminating newline; LaTeX would '
                  'fail because of commenting the end of math mode (e.g. \$)');
        } else {
          while (it.current.end < nlIndex + 1) {
            final canMoveNext = it.moveNext();
            if (canMoveNext) {
              pos = it.current.end;
            } else {
              break;
            }
          }
        }
        return this.lex();
      }
      final controlMatch = controlWordWhitespaceRegex.firstMatch(text);
      if (controlMatch != null) {
        text = controlMatch.group(1)!;
      }
      return Token(
        text,
        SourceLocation(
          this,
          match.start,
          match.end,
        ),
      );
    }
  }
}
