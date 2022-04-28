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
import 'functions.dart';
import 'macro_expander.dart';
import 'symbols.dart';

/// Parser for TeX equations
///
/// Convert TeX string to Flutter Math's AST
class TexParser {
  final TexParserSettings settings;
  final MacroExpander macroExpander;
  TexMode mode;
  int leftrightDepth;
  Token? nextToken;

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

  final void Function(String) warn;

  const TexParserSettings({
    final this.displayMode = false,
    final this.throwOnError = true,
    final this.macros = const {},
    final this.maxExpand = 1000,
    final Strict strict = Strict.warn,
    final this.strictFun,
    final this.warn = print,
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

// All supported CSS color names
// The following values are obtained from https://developer.mozilla.org/en-US/docs/Web/CSS/color_value
const colorByName = {
  'black': TexColorImpl(argb: 0xff000000),
  'silver': TexColorImpl(argb: 0xffc0c0c0),
  'gray': TexColorImpl(argb: 0xff808080),
  'white': TexColorImpl(argb: 0xffffffff),
  'maroon': TexColorImpl(argb: 0xff800000),
  'red': TexColorImpl(argb: 0xffff0000),
  'purple': TexColorImpl(argb: 0xff800080),
  'fuchsia': TexColorImpl(argb: 0xffff00ff),
  'green': TexColorImpl(argb: 0xff008000),
  'lime': TexColorImpl(argb: 0xff00ff00),
  'olive': TexColorImpl(argb: 0xff808000),
  'yellow': TexColorImpl(argb: 0xffffff00),
  'navy': TexColorImpl(argb: 0xff000080),
  'blue': TexColorImpl(argb: 0xff0000ff),
  'teal': TexColorImpl(argb: 0xff008080),
  'aqua': TexColorImpl(argb: 0xff00ffff),
  'orange': TexColorImpl(argb: 0xffffa500),
  'aliceblue': TexColorImpl(argb: 0xfff0f8ff),
  'antiquewhite': TexColorImpl(argb: 0xfffaebd7),
  'aquamarine': TexColorImpl(argb: 0xff7fffd4),
  'azure': TexColorImpl(argb: 0xfff0ffff),
  'beige': TexColorImpl(argb: 0xfff5f5dc),
  'bisque': TexColorImpl(argb: 0xffffe4c4),
  'blanchedalmond': TexColorImpl(argb: 0xffffebcd),
  'blueviolet': TexColorImpl(argb: 0xff8a2be2),
  'brown': TexColorImpl(argb: 0xffa52a2a),
  'burlywood': TexColorImpl(argb: 0xffdeb887),
  'cadetblue': TexColorImpl(argb: 0xff5f9ea0),
  'chartreuse': TexColorImpl(argb: 0xff7fff00),
  'chocolate': TexColorImpl(argb: 0xffd2691e),
  'coral': TexColorImpl(argb: 0xffff7f50),
  'cornflowerblue': TexColorImpl(argb: 0xff6495ed),
  'cornsilk': TexColorImpl(argb: 0xfffff8dc),
  'crimson': TexColorImpl(argb: 0xffdc143c),
  'cyan': TexColorImpl(argb: 0xff00ffff),
  'darkblue': TexColorImpl(argb: 0xff00008b),
  'darkcyan': TexColorImpl(argb: 0xff008b8b),
  'darkgoldenrod': TexColorImpl(argb: 0xffb8860b),
  'darkgray': TexColorImpl(argb: 0xffa9a9a9),
  'darkgreen': TexColorImpl(argb: 0xff006400),
  'darkgrey': TexColorImpl(argb: 0xffa9a9a9),
  'darkkhaki': TexColorImpl(argb: 0xffbdb76b),
  'darkmagenta': TexColorImpl(argb: 0xff8b008b),
  'darkolivegreen': TexColorImpl(argb: 0xff556b2f),
  'darkorange': TexColorImpl(argb: 0xffff8c00),
  'darkorchid': TexColorImpl(argb: 0xff9932cc),
  'darkred': TexColorImpl(argb: 0xff8b0000),
  'darksalmon': TexColorImpl(argb: 0xffe9967a),
  'darkseagreen': TexColorImpl(argb: 0xff8fbc8f),
  'darkslateblue': TexColorImpl(argb: 0xff483d8b),
  'darkslategray': TexColorImpl(argb: 0xff2f4f4f),
  'darkslategrey': TexColorImpl(argb: 0xff2f4f4f),
  'darkturquoise': TexColorImpl(argb: 0xff00ced1),
  'darkviolet': TexColorImpl(argb: 0xff9400d3),
  'deeppink': TexColorImpl(argb: 0xffff1493),
  'deepskyblue': TexColorImpl(argb: 0xff00bfff),
  'dimgray': TexColorImpl(argb: 0xff696969),
  'dimgrey': TexColorImpl(argb: 0xff696969),
  'dodgerblue': TexColorImpl(argb: 0xff1e90ff),
  'firebrick': TexColorImpl(argb: 0xffb22222),
  'floralwhite': TexColorImpl(argb: 0xfffffaf0),
  'forestgreen': TexColorImpl(argb: 0xff228b22),
  'gainsboro': TexColorImpl(argb: 0xffdcdcdc),
  'ghostwhite': TexColorImpl(argb: 0xfff8f8ff),
  'gold': TexColorImpl(argb: 0xffffd700),
  'goldenrod': TexColorImpl(argb: 0xffdaa520),
  'greenyellow': TexColorImpl(argb: 0xffadff2f),
  'grey': TexColorImpl(argb: 0xff808080),
  'honeydew': TexColorImpl(argb: 0xfff0fff0),
  'hotpink': TexColorImpl(argb: 0xffff69b4),
  'indianred': TexColorImpl(argb: 0xffcd5c5c),
  'indigo': TexColorImpl(argb: 0xff4b0082),
  'ivory': TexColorImpl(argb: 0xfffffff0),
  'khaki': TexColorImpl(argb: 0xfff0e68c),
  'lavender': TexColorImpl(argb: 0xffe6e6fa),
  'lavenderblush': TexColorImpl(argb: 0xfffff0f5),
  'lawngreen': TexColorImpl(argb: 0xff7cfc00),
  'lemonchiffon': TexColorImpl(argb: 0xfffffacd),
  'lightblue': TexColorImpl(argb: 0xffadd8e6),
  'lightcoral': TexColorImpl(argb: 0xfff08080),
  'lightcyan': TexColorImpl(argb: 0xffe0ffff),
  'lightgoldenrodyellow': TexColorImpl(argb: 0xfffafad2),
  'lightgray': TexColorImpl(argb: 0xffd3d3d3),
  'lightgreen': TexColorImpl(argb: 0xff90ee90),
  'lightgrey': TexColorImpl(argb: 0xffd3d3d3),
  'lightpink': TexColorImpl(argb: 0xffffb6c1),
  'lightsalmon': TexColorImpl(argb: 0xffffa07a),
  'lightseagreen': TexColorImpl(argb: 0xff20b2aa),
  'lightskyblue': TexColorImpl(argb: 0xff87cefa),
  'lightslategray': TexColorImpl(argb: 0xff778899),
  'lightslategrey': TexColorImpl(argb: 0xff778899),
  'lightsteelblue': TexColorImpl(argb: 0xffb0c4de),
  'lightyellow': TexColorImpl(argb: 0xffffffe0),
  'limegreen': TexColorImpl(argb: 0xff32cd32),
  'linen': TexColorImpl(argb: 0xfffaf0e6),
  'magenta (synonym of fuchsia)': TexColorImpl(argb: 0xffff00ff),
  'mediumaquamarine': TexColorImpl(argb: 0xff66cdaa),
  'mediumblue': TexColorImpl(argb: 0xff0000cd),
  'mediumorchid': TexColorImpl(argb: 0xffba55d3),
  'mediumpurple': TexColorImpl(argb: 0xff9370db),
  'mediumseagreen': TexColorImpl(argb: 0xff3cb371),
  'mediumslateblue': TexColorImpl(argb: 0xff7b68ee),
  'mediumspringgreen': TexColorImpl(argb: 0xff00fa9a),
  'mediumturquoise': TexColorImpl(argb: 0xff48d1cc),
  'mediumvioletred': TexColorImpl(argb: 0xffc71585),
  'midnightblue': TexColorImpl(argb: 0xff191970),
  'mintcream': TexColorImpl(argb: 0xfff5fffa),
  'mistyrose': TexColorImpl(argb: 0xffffe4e1),
  'moccasin': TexColorImpl(argb: 0xffffe4b5),
  'navajowhite': TexColorImpl(argb: 0xffffdead),
  'oldlace': TexColorImpl(argb: 0xfffdf5e6),
  'olivedrab': TexColorImpl(argb: 0xff6b8e23),
  'orangered': TexColorImpl(argb: 0xffff4500),
  'orchid': TexColorImpl(argb: 0xffda70d6),
  'palegoldenrod': TexColorImpl(argb: 0xffeee8aa),
  'palegreen': TexColorImpl(argb: 0xff98fb98),
  'paleturquoise': TexColorImpl(argb: 0xffafeeee),
  'palevioletred': TexColorImpl(argb: 0xffdb7093),
  'papayawhip': TexColorImpl(argb: 0xffffefd5),
  'peachpuff': TexColorImpl(argb: 0xffffdab9),
  'peru': TexColorImpl(argb: 0xffcd853f),
  'pink': TexColorImpl(argb: 0xffffc0cb),
  'plum': TexColorImpl(argb: 0xffdda0dd),
  'powderblue': TexColorImpl(argb: 0xffb0e0e6),
  'rosybrown': TexColorImpl(argb: 0xffbc8f8f),
  'royalblue': TexColorImpl(argb: 0xff4169e1),
  'saddlebrown': TexColorImpl(argb: 0xff8b4513),
  'salmon': TexColorImpl(argb: 0xfffa8072),
  'sandybrown': TexColorImpl(argb: 0xfff4a460),
  'seagreen': TexColorImpl(argb: 0xff2e8b57),
  'seashell': TexColorImpl(argb: 0xfffff5ee),
  'sienna': TexColorImpl(argb: 0xffa0522d),
  'skyblue': TexColorImpl(argb: 0xff87ceeb),
  'slateblue': TexColorImpl(argb: 0xff6a5acd),
  'slategray': TexColorImpl(argb: 0xff708090),
  'slategrey': TexColorImpl(argb: 0xff708090),
  'snow': TexColorImpl(argb: 0xfffffafa),
  'springgreen': TexColorImpl(argb: 0xff00ff7f),
  'steelblue': TexColorImpl(argb: 0xff4682b4),
  'tan': TexColorImpl(argb: 0xffd2b48c),
  'thistle': TexColorImpl(argb: 0xffd8bfd8),
  'tomato': TexColorImpl(argb: 0xffff6347),
  'turquoise': TexColorImpl(argb: 0xff40e0d0),
  'violet': TexColorImpl(argb: 0xffee82ee),
  'wheat': TexColorImpl(argb: 0xfff5deb3),
  'whitesmoke': TexColorImpl(argb: 0xfff5f5f5),
  'yellowgreen': TexColorImpl(argb: 0xff9acd32),
  'rebeccapurple': TexColorImpl(argb: 0xff663399),
  'transparent': TexColorImpl(argb: 0x00000000),
};

class EnvContext {
  final TexMode mode;
  final String envName;

  const EnvContext({
    required final this.mode,
    required final this.envName,
  });
}

class EnvSpec {
  final int numArgs;
  final int greediness;
  final bool allowedInText;
  final int numOptionalArgs;
  final TexGreen Function(TexParser parser, EnvContext context) handler;

  const EnvSpec({
    required final this.numArgs,
    required final this.handler,
    final this.greediness = 1,
    final this.allowedInText = false,
    final this.numOptionalArgs = 0,
  });
}

final Map<String, EnvSpec> _environments = {};

Map<String, EnvSpec> get environments {
  if (_environments.isEmpty) {
    _environmentsEntries.forEach((final key, final value) {
      for (final name in key) {
        _environments[name] = value;
      }
    });
  }
  return _environments;
}

final _environmentsEntries = {
  ...arrayEntries,
  ...eqnArrayEntries,
};

const arrayEntries = {
  [
    'array',
    'darray',
  ]: EnvSpec(
    numArgs: 1,
    handler: _arrayHandler,
  ),
  [
    'matrix',
    'pmatrix',
    'bmatrix',
    'Bmatrix',
    'vmatrix',
    'Vmatrix',
  ]: EnvSpec(
    numArgs: 0,
    handler: _matrixHandler,
  ),
  ['smallmatrix']: EnvSpec(numArgs: 0, handler: _smallMatrixHandler),
  ['subarray']: EnvSpec(numArgs: 1, handler: _subArrayHandler),
};

enum ColSeparationType {
  align,
  alignat,
  small,
}

List<TexMatrixSeparatorStyle> getHLines(final TexParser parser) {
  // Return an array. The array length = number of hlines.
  // Each element in the array tells if the line is dashed.
  final hlineInfo = <TexMatrixSeparatorStyle>[];
  parser.consumeSpaces();
  var next = parser.fetch().text;
  while (next == '\\hline' || next == '\\hdashline') {
    parser.consume();
    hlineInfo.add(next == '\\hdashline' ? TexMatrixSeparatorStyle.dashed : TexMatrixSeparatorStyle.solid);
    parser.consumeSpaces();
    next = parser.fetch().text;
  }
  return hlineInfo;
}

/// Parse the body of the environment, with rows delimited by \\ and
/// columns delimited by &, and create a nested list in row-major order
/// with one group per cell.  If given an optional argument style
/// ('text', 'display', etc.), then each cell is cast into that style.
TexGreenMatrix parseArray(
    final TexParser parser, {
      final bool hskipBeforeAndAfter = false,
      final List<TexMatrixSeparatorStyle> separators = const [],
      final List<TexMatrixColumnAlign> colAligns = const [],
      final TexMathStyle? style,
      final bool isSmall = false,
      double? arrayStretch,
    }) {
  // Parse body of array with \\ temporarily mapped to \cr
  parser.macroExpander.beginGroup();
  parser.macroExpander.macros.set('\\\\', MacroDefinition.fromString('\\cr'));
  // Get current arraystretch if it's not set by the environment
  if (arrayStretch == null) {
    final stretch = parser.macroExpander.expandMacroAsText('\\arraystretch');
    if (stretch == null) {
      // Default \arraystretch from lttab.dtx
      arrayStretch = 1.0;
    } else {
      // ignore: parameter_assignments
      arrayStretch = double.tryParse(stretch);
      if (arrayStretch == null || arrayStretch < 0) {
        throw ParseException('Invalid \\arraystretch: $stretch');
      }
    }
  }

  // Start group for first cell
  parser.macroExpander.beginGroup();

  var row = <TexGreenEquationrow>[];
  final body = [row];
  final rowGaps = <TexMeasurement>[];
  final hLinesBeforeRow = <TexMatrixSeparatorStyle>[];
  // Test for \hline at the top of the array.
  hLinesBeforeRow.add(getHLines(parser).lastOrNull ?? TexMatrixSeparatorStyle.none);
  for (;;) {
    // Parse each cell in its own group (namespace)
    final cellBody = parser.parseExpression(
      breakOnInfix: false,
      breakOnTokenText: '\\cr',
    );
    parser.macroExpander.endGroup();
    parser.macroExpander.beginGroup();
    final cell = style == null
        ? greenNodesWrapWithEquationRow(
      cellBody,
    )
        : greenNodeWrapWithEquationRow(
      TexGreenStyleImpl(
        children: cellBody,
        optionsDiff: TexOptionsDiffImpl(
          style: style,
        ),
      ),
    );
    row.add(cell);
    final next = parser.fetch().text;
    if (next == '&') {
      parser.consume();
    } else if (next == '\\end') {
      // Arrays terminate newlines with `\crcr` which consumes a `\cr` if
      // the last line is empty.
      // NOTE: Currently, `cell` is the last item added into `row`.
      if (row.length == 1 && cellBody.isEmpty) {
        body.removeLast();
      }
      if (hLinesBeforeRow.length < body.length + 1) {
        hLinesBeforeRow.add(TexMatrixSeparatorStyle.none);
      }
      break;
    } else if (next == '\\cr') {
      final cr = assertNodeType<TexGreenTemporaryCr>(parser.parseFunction(null, null, null));
      rowGaps.add(cr.size ?? zeroPt);
      // check for \hline(s) following the row separator
      hLinesBeforeRow.add(getHLines(parser).lastOrNull ?? TexMatrixSeparatorStyle.none);
      row = [];
      body.add(row);
    } else {
      throw ParseException('Expected & or \\\\ or \\cr or \\end', parser.nextToken);
    }
  }
  // End cell group
  parser.macroExpander.endGroup();
  // End array group defining \\
  parser.macroExpander.endGroup();
  return matrixNodeSanitizedInputs(
    body: body,
    vLines: separators,
    columnAligns: colAligns,
    rowSpacings: rowGaps,
    arrayStretch: arrayStretch,
    hLines: hLinesBeforeRow,
    hskipBeforeAndAfter: hskipBeforeAndAfter,
    isSmall: isSmall,
  );
}

/// Decides on a style for cells in an array according to whether the given
/// environment name starts with the letter 'd'.
TexMathStyle _dCellStyle(
    final String envName,
    ) {
  if (envName.substring(0, 1) == 'd') {
    return TexMathStyle.display;
  } else {
    return TexMathStyle.text;
  }
}

// const _alignMap = {
//   'c': 'center',
//   'l': 'left',
//   'r': 'right',
// };

// class ColumnConf {
//   final List<String> separators;
//   final List<_AlignSpec> aligns;
//   // final bool hskipBeforeAndAfter;
//   // final double arrayStretch;
//   ColumnConf({
//     required this.separators,
//     required this.aligns,
//     // this.hskipBeforeAndAfter = false,
//     // this.arrayStretch = 1,
//   });
// }

TexGreen _arrayHandler(
    final TexParser parser,
    final EnvContext context,
    ) {
  final symArg = parser.parseArgNode(mode: null, optional: false);
  final colalign = symArg is TexGreenSymbol ? [symArg] : assertNodeType<TexGreenEquationrow>(symArg).children;
  final separators = <TexMatrixSeparatorStyle>[];
  final aligns = <TexMatrixColumnAlign>[];
  bool alignSpecified = true;
  bool lastIsSeparator = false;
  for (final nde in colalign) {
    final node = assertNodeType<TexGreenSymbol>(nde);
    final ca = node.symbol;
    switch (ca) {
    //ignore_for_file: switch_case_completes_normally
      case 'l':
      case 'c':
      case 'r':
        aligns.add(const {
          'l': TexMatrixColumnAlign.left,
          'c': TexMatrixColumnAlign.center,
          'r': TexMatrixColumnAlign.right,
        }[ca]!);
        if (alignSpecified) {
          separators.add(TexMatrixSeparatorStyle.none);
        }
        alignSpecified = true;
        lastIsSeparator = false;
        break;
      case '|':
      case ':':
        if (alignSpecified) {
          separators.add(const {
            '|': TexMatrixSeparatorStyle.solid,
            ':': TexMatrixSeparatorStyle.dashed,
          }[ca]!);
          // aligns.add(MatrixColumnAlign.center);
        }
        alignSpecified = false;
        lastIsSeparator = true;
        break;
      default:
        throw ParseException('Unknown column alignment: $ca');
    }
  }
  if (!lastIsSeparator) {
    separators.add(TexMatrixSeparatorStyle.none);
  }
  return parseArray(
    parser,
    separators: separators,
    colAligns: aligns,
    hskipBeforeAndAfter: true,
    style: _dCellStyle(context.envName),
  );
}

TexGreen _matrixHandler(
    final TexParser parser,
    final EnvContext context,
    ) {
  final delimiters = const {
    'matrix': null,
    'pmatrix': ['(', ')'],
    'bmatrix': ['[', ']'],
    'Bmatrix': ['{', '}'],
    'vmatrix': ['|', '|'],
    'Vmatrix': ['\u2223', '\u2223'],
  }[context.envName];
  final res = parseArray(
    parser,
    hskipBeforeAndAfter: false,
    style: _dCellStyle(context.envName),
  );
  if (delimiters == null) {
    return res;
  } else {
    return TexGreenLeftrightImpl(
      leftDelim: delimiters[0],
      rightDelim: delimiters[1],
      body: [
        greenNodesWrapWithEquationRow(
          [
            res,
          ],
        )
      ],
    );
  }
}

TexGreen _smallMatrixHandler(
    final TexParser parser,
    final EnvContext context,
    ) =>
    parseArray(
      parser,
      arrayStretch: 0.5,
      style: TexMathStyle.script,
      isSmall: true,
    );

TexGreen _subArrayHandler(
    final TexParser parser,
    final EnvContext context,
    ) {
  // Parsing of {subarray} is similar to {array}
  final symArg = parser.parseArgNode(mode: null, optional: false);
  final colalign = symArg is TexGreenSymbol ? [symArg] : assertNodeType<TexGreenEquationrow>(symArg).children;
  // final separators = <MatrixSeparatorStyle>[];
  final aligns = <TexMatrixColumnAlign>[];
  for (final nde in colalign) {
    final node = assertNodeType<TexGreenSymbol>(nde);
    final ca = node.symbol;
    if (ca == 'l' || ca == 'c') {
      aligns.add(ca == 'l' ? TexMatrixColumnAlign.left : TexMatrixColumnAlign.center);
    } else {
      throw ParseException('Unknown column alignment: $ca');
    }
  }
  if (aligns.length > 1) {
    throw ParseException('{subarray} can contain only one column');
  }
  final res = parseArray(
    parser,
    colAligns: aligns,
    hskipBeforeAndAfter: false,
    arrayStretch: 0.5,
    style: TexMathStyle.script,
  );
  if (res.body[0].length > 1) {
    throw ParseException('{subarray} can contain only one column');
  }
  return res;
}

const eqnArrayEntries = {
  [
    'cases',
    'dcases',
    'rcases',
    'drcases',
  ]: EnvSpec(
    numArgs: 0,
    handler: _casesHandler,
  ),
  ['aligned']: EnvSpec(
    numArgs: 0,
    handler: _alignedHandler,
  ),
  // ['gathered']: EnvSpec(numArgs: 0, handler: _gatheredHandler),
  ['alignedat']: EnvSpec(numArgs: 1, handler: _alignedAtHandler),
};

TexGreen _casesHandler(
    final TexParser parser,
    final EnvContext context,
    ) {
  final body = parseEqnArray(
    parser,
    concatRow: (final cells) {
      final children = [
        TexGreenSpaceImpl.alignerOrSpacer(),
        if (cells.isNotEmpty) ...cells[0].children,
        if (cells.length > 1) TexGreenSpaceImpl.alignerOrSpacer(),
        if (cells.length > 1)
          TexGreenSpaceImpl(
            height: zeroPt,
            width: em(1.0),
            mode: TexMode.math,
          ),
      ];
      for (var i = 1; i < cells.length; i++) {
        children.add(TexGreenSpaceImpl.alignerOrSpacer());
        children.addAll(cells[i].children);
        children.add(TexGreenSpaceImpl.alignerOrSpacer());
      }
      if (context.envName == 'dcases' || context.envName == 'drcases') {
        return TexGreenEquationrowImpl(
          children: [
            TexGreenStyleImpl(
              optionsDiff: const TexOptionsDiffImpl(
                style: TexMathStyle.display,
              ),
              children: children,
            )
          ],
        );
      } else {
        return TexGreenEquationrowImpl(
          children: children,
        );
      }
    },
  );
  if (context.envName == 'rcases' || context.envName == 'drcases') {
    return TexGreenLeftrightImpl(
      leftDelim: null,
      rightDelim: '}',
      body: [
        greenNodeWrapWithEquationRow(
          body,
        ),
      ],
    );
  } else {
    return TexGreenLeftrightImpl(
      leftDelim: '{',
      rightDelim: null,
      body: [
        greenNodeWrapWithEquationRow(
          body,
        ),
      ],
    );
  }
}

TexGreen _alignedHandler(
    final TexParser parser,
    final EnvContext context,
    ) =>
    parseEqnArray(
      parser,
      addJot: true,
      concatRow: (final cells) {
        final expanded = cells
            .expand(
              (final cell) => [
            ...cell.children,
            TexGreenSpaceImpl.alignerOrSpacer(),
          ],
        )
            .toList(
          growable: true,
        );
        return TexGreenEquationrowImpl(
          children: expanded,
        );
      },
    );

// GreenNode _gatheredHandler(TexParser parser, EnvContext context) {}

TexGreen _alignedAtHandler(
    final TexParser parser,
    final EnvContext context,
    ) {
  final arg = parser.parseArgNode(mode: null, optional: false);
  final numNode = assertNodeType<TexGreenEquationrow>(arg);
  final string = numNode.children.map((final e) => assertNodeType<TexGreenSymbol>(e).symbol).join('');
  final cols = int.tryParse(string);
  if (cols == null) {
    throw ParseException('Invalid argument for environment: alignedat');
  } else {
    return parseEqnArray(
      parser,
      addJot: true,
      concatRow: (final cells) {
        if (cells.length > 2 * cols) {
          throw ParseException('Too many math in a row: '
              'expected ${2 * cols}, but got ${cells.length}');
        }
        final expanded = cells
            .expand(
              (final cell) => [
            ...cell.children,
            TexGreenSpaceImpl.alignerOrSpacer(),
          ],
        )
            .toList(growable: true);
        return TexGreenEquationrowImpl(
          children: expanded,
        );
      },
    );
  }
}

TexGreenEquationarray parseEqnArray(
    final TexParser parser, {
      required final TexGreenEquationrow Function(List<TexGreenEquationrow> cells) concatRow,
      final bool addJot = false,
    }) {
  // Parse body of array with \\ temporarily mapped to \cr
  parser.macroExpander.beginGroup();
  parser.macroExpander.macros.set('\\\\', MacroDefinition.fromString('\\cr'));
  // Get current arraystretch if it's not set by the environment
  double? arrayStretch = 1.0;
  // if (arrayStretch == null) {
  final stretch = parser.macroExpander.expandMacroAsText('\\arraystretch');
  if (stretch == null) {
    // Default \arraystretch from lttab.dtx
    arrayStretch = 1.0;
  } else {
    arrayStretch = double.tryParse(stretch);
    if (arrayStretch == null || arrayStretch < 0) {
      throw ParseException('Invalid \\arraystretch: $stretch');
    }
  }
  // }
  // Start group for first cell
  parser.macroExpander.beginGroup();
  var row = <TexGreenEquationrow>[];
  final body = [row];
  final rowGaps = <TexMeasurement>[];
  final hLinesBeforeRow = <TexMatrixSeparatorStyle>[];
  // Test for \hline at the top of the array.
  hLinesBeforeRow.add(getHLines(parser).lastOrNull ?? TexMatrixSeparatorStyle.none);
  for (;;) {
    // Parse each cell in its own group (namespace)
    final cellBody = parser.parseExpression(
      breakOnInfix: false,
      breakOnTokenText: '\\cr',
    );
    parser.macroExpander.endGroup();
    parser.macroExpander.beginGroup();
    final cell = greenNodesWrapWithEquationRow(
      cellBody,
    );
    row.add(cell);
    final next = parser.fetch().text;
    if (next == '&') {
      parser.consume();
    } else if (next == '\\end') {
      // Arrays terminate newlines with `\crcr` which consumes a `\cr` if
      // the last line is empty.
      // NOTE: Currently, `cell` is the last item added into `row`.
      if (row.length == 1 && cell is TexGreenStyle && cell.children.isEmpty) {
        body.removeLast();
      }
      if (hLinesBeforeRow.length < body.length + 1) {
        hLinesBeforeRow.add(TexMatrixSeparatorStyle.none);
      }
      break;
    } else if (next == '\\cr') {
      final cr = assertNodeType<TexGreenTemporaryCr>(parser.parseFunction(null, null, null));
      rowGaps.add(cr.size ?? zeroPt);
      // check for \hline(s) following the row separator
      hLinesBeforeRow.add(getHLines(parser).lastOrNull ?? TexMatrixSeparatorStyle.none);
      row = [];
      body.add(row);
    } else {
      throw ParseException('Expected & or \\\\ or \\cr or \\end', parser.nextToken);
    }
  }
  // End cell group
  parser.macroExpander.endGroup();
  // End array group defining \\
  parser.macroExpander.endGroup();
  final rows = body.map<TexGreenEquationrow>(concatRow).toList();
  return TexGreenEquationarrayImpl(
    arrayStretch: arrayStretch,
    hlines: hLinesBeforeRow,
    rowSpacings: rowGaps,
    addJot: addJot,
    body: rows,
  );
}
