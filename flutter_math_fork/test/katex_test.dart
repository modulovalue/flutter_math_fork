void main() {}

// import 'package:unittest/unittest.dart';
//
// import 'package:katex/katex.dart';
//
// void main() {
//   unittestConfiguration.timeout = new Duration(seconds: 5);
//   SpanNode toBuild({String expression}) {
//     Parser parser = new Parser(expression: expression);
//     List<ParseNode> tree = parser.parse();
//     return buildTree(tree: tree);
//   }
//
//   List<SymbolNode> getBuilt({String expression}) {
//     SpanNode node = toBuild(expression: expression);
//     return node.children[0].children[2].children;
//   }
//
//   List<ParseNode> toParse({String expression}) {
//     Parser parser = new Parser(expression: expression);
//     return parser.parse();
//   }
//
//   setUp(() {
//     Katex katex = new Katex();
//   });
//   group('A parser', () {
//     test('should not fail on an empty string', () {
//       toParse(expression: '');
//     });
//     test('should ignore whitespace', () {
//       List<ParseNode> treeA = toParse(expression: 'xy');
//       List<ParseNode> treeB = toParse(expression: '    x    y    ');
//       expect(treeA[0].value, treeB[0].value);
//       expect(treeA[1].value, treeB[1].value);
//     });
//   });
//   group('An ord parser', () {
//     String expression = '1234|/@.\"`abcdefgzABCDEFGZ';
//     test('should not fail', () {
//       toParse(expression: expression);
//     });
//     test('should build a list of ords', () {
//       List<ParseNode> tree = toParse(expression: expression);
//       expect(tree, isNotNull);
//       expect(tree.length, isNonZero);
//       tree.forEach((parseNode) {
//         expect(parseNode.type, matches(new RegExp('ord')));
//       });
//     });
//     test('should parse the right number of ords', () {
//       List<ParseNode> tree = toParse(expression: expression);
//       expect(tree.length, expression.length);
//     });
//   });
//   group('A bin parser', () {
//     String expression = '+-*\\cdot\\pm\\div';
//     test('should not fail', () {
//       toParse(expression: expression);
//     });
//     test('should build a list of bins', () {
//       List<ParseNode> tree = toParse(expression: expression);
//       expect(tree, isNotNull);
//       expect(tree.length, isNonZero);
//       tree.forEach((parseNode) {
//         expect(parseNode.type, matches(new RegExp('bin')));
//       });
//     });
//   });
//   group('A rel parser', () {
//     String expression = '=<>\\leq\\geq\\neq\\nleq\\ngeq\\cong';
//     test('should not fail', () {
//       toParse(expression: expression);
//     });
//     test('should build a list of rels', () {
//       List<ParseNode> tree = toParse(expression: expression);
//       expect(tree, isNotNull);
//       expect(tree.length, isNonZero);
//       tree.forEach((parseNode) {
//         expect(parseNode.type, matches(new RegExp('rel')));
//       });
//     });
//   });
//   group('A punct parser', () {
//     String expression = ',;\\colon';
//     test('should not fail', () {
//       toParse(expression: expression);
//     });
//     test('should build a list of puncts', () {
//       List<ParseNode> tree = toParse(expression: expression);
//       expect(tree, isNotNull);
//       expect(tree.length, isNonZero);
//       tree.forEach((parseNode) {
//         expect(parseNode.type, matches(new RegExp('punct')));
//       });
//     });
//   });
//   group('An open parser', () {
//     String expression = '([';
//     test('should not fail', () {
//       toParse(expression: expression);
//     });
//     test('should build a list of opens', () {
//       List<ParseNode> tree = toParse(expression: expression);
//       expect(tree, isNotNull);
//       expect(tree.length, isNonZero);
//       tree.forEach((parseNode) {
//         expect(parseNode.type, matches(new RegExp('open')));
//       });
//     });
//   });
//   group('A close parser', () {
//     String expression = ')]?!';
//     test('should not fail', () {
//       toParse(expression: expression);
//     });
//     test('should build a list of closes', () {
//       List<ParseNode> tree = toParse(expression: expression);
//       expect(tree, isNotNull);
//       expect(tree.length, isNonZero);
//       tree.forEach((parseNode) {
//         expect(parseNode.type, matches(new RegExp('close')));
//       });
//     });
//   });
//   group('A \\KaTeX parser', () {
//     test('should not fail', () {
//       toParse(expression: '\\KaTeX');
//     });
//   });
//   group('A subscript and superscript parser', () {
//     test('should not fail on superscripts', () {
//       toParse(expression: 'x^2');
//     });
//     test('should not fail on subscripts', () {
//       toParse(expression: 'x_3');
//     });
//     test('should not fail on both subscripts and superscripts', () {
//       toParse(expression: 'x^2_3');
//       toParse(expression: 'x_2^3');
//     });
//     test('should not fail when there is no nucleus', () {
//       toParse(expression: '^3');
//       toParse(expression: '_2');
//       toParse(expression: '^3_2');
//       toParse(expression: '_2^3');
//     });
//     test('should produce supsubs for superscript', () {
//       ParseNode parseNode = toParse(expression: 'x^2')[0];
//       expect(parseNode.type, 'supsub');
//       expect(parseNode.value['base'], isNotNull);
//       expect(parseNode.value['sup'], isNotNull);
//       expect(parseNode.value['sub'], isNull);
//     });
//     test('should produce supsubs for subscript', () {
//       ParseNode parseNode = toParse(expression: 'x_3')[0];
//       expect(parseNode.type, 'supsub');
//       expect(parseNode.value['base'], isNotNull);
//       expect(parseNode.value['sub'], isNotNull);
//       expect(parseNode.value['sup'], isNull);
//     });
//     test('should produce supsubs for ^_', () {
//       ParseNode parseNode = toParse(expression: 'x^2_3')[0];
//       expect(parseNode.type, 'supsub');
//       expect(parseNode.value['base'], isNotNull);
//       expect(parseNode.value['sub'], isNotNull);
//       expect(parseNode.value['sup'], isNotNull);
//     });
//     test('should produce supsubs for _^', () {
//       ParseNode parseNode = toParse(expression: 'x_3^2')[0];
//       expect(parseNode.type, 'supsub');
//       expect(parseNode.value['base'], isNotNull);
//       expect(parseNode.value['sub'], isNotNull);
//       expect(parseNode.value['sup'], isNotNull);
//     });
//     test('should produce the same thing regardless of order', () {
//       List<ParseNode> treeA = toParse(expression: 'x^2_3');
//       List<ParseNode> treeB = toParse(expression: 'x_3^2');
//       expect(treeA[0].value['base'].value, treeB[0].value['base'].value);
//       expect(treeA[0].value['sub'].value, treeB[0].value['sub'].value);
//       expect(treeA[0].value['sup'].value, treeB[0].value['sup'].value);
//     });
//     test('should not parse double subscripts or superscripts', () {
//       expect(() => toParse(expression: 'x^x^x'), throwsA(new isInstanceOf<ParseError>()));
//       expect(() => toParse(expression: 'x_x_x'), throwsA(new isInstanceOf<ParseError>()));
//       expect(() => toParse(expression: 'x_x^x_x'), throwsA(new isInstanceOf<ParseError>()));
//       expect(() => toParse(expression: 'x_x^x^x'), throwsA(new isInstanceOf<ParseError>()));
//       expect(() => toParse(expression: 'x^x_x_x'), throwsA(new isInstanceOf<ParseError>()));
//       expect(() => toParse(expression: 'x^x_x^x'), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should work correctly with {}s', () {
//       toParse(expression: 'x^{2+3}');
//       toParse(expression: 'x_{3-2}');
//       toParse(expression: 'x^{2+3}_3');
//       toParse(expression: 'x^2_{3-2}');
//       toParse(expression: 'x^{2+3}_{3-2}');
//       toParse(expression: 'x_{3-2}^{2+3}');
//       toParse(expression: 'x_3^{2+3}');
//       toParse(expression: 'x_{3-2}^2');
//     });
//     test('should work with nested super/subscripts', () {
//       toParse(expression: 'x^{x^x}');
//       toParse(expression: 'x^{x_x}');
//       toParse(expression: 'x_{x^x}');
//       toParse(expression: 'x_{x_x}');
//     });
//   });
//   group('A subscript and superscript tree-builder', () {
//     test('should not fail when there is no nucleus', () {
//       toBuild(expression: '^3');
//       toBuild(expression: '_2');
//       toBuild(expression: '^3_2');
//       toBuild(expression: '_2^3');
//     });
//   });
//   group('A group parser', () {
//     test('should not fail', () {
//       toParse(expression: '{xy}');
//     });
//     test('should produce a single ord', () {
//       List<ParseNode> tree = toParse(expression: '{xy}');
//       expect(tree.length, 1);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('ord')));
//       expect(parseNode.value, isNotNull);
//     });
//   });
//   group('An implicit group parser', () {
//     test('should not fail', () {
//       toParse(expression: '\\Large x');
//       toParse(expression: 'abc {abc \\Large xyz} abc');
//     });
//     test('should produce a single object', () {
//       List<ParseNode> tree = toParse(expression: '\\Large abc');
//       expect(tree.length, 1);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('sizing')));
//       expect(parseNode.value, isNotNull);
//     });
//     test('should apply only after the function', () {
//       List<ParseNode> tree = toParse(expression: 'a \\Large abc');
//       expect(tree.length, 2);
//       ParseNode parseNode = tree[1];
//       expect(parseNode.type, matches(new RegExp('sizing')));
//       expect(parseNode.value['value'].length, 3);
//     });
//     test('should stop at the ends of groups', () {
//       List<ParseNode> tree = toParse(expression: 'a { b \\Large c } d');
//       ParseNode group = tree[1];
//       ParseNode sizing = group.value[1];
//       expect(sizing.type, matches(new RegExp('sizing')));
//       expect(sizing.value['value'].length, 1);
//     });
//   });
//   group('A function parser', () {
//     test('should parse no argument functions', () {
//       toParse(expression: '\\div');
//     });
//     test('should parse 1 argument functions', () {
//       toParse(expression: '\\blue x');
//     });
//     test('should parse 2 argument functions', () {
//       toParse(expression: '\\frac 1 2');
//     });
//     test('should not parse 1 argument functions with no arguments', () {
//       expect(() => toParse(expression: '\\blue'), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should not parse 2 argument functions with 0 or 1 arguments', () {
//       expect(() => toParse(expression: '\\frac'), throwsA(new isInstanceOf<ParseError>()));
//       expect(() => toParse(expression: '\\frac 1'), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should not parse a function with text right after test', () {
//       expect(() => toParse(expression: '\\redx'), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should parse a function with a number right after test', () {
//       toParse(expression: '\\frac12');
//     });
//     test('should parse some functions with text right after test', () {
//       toParse(expression: '\\;x');
//     });
//   });
//   group('A frac parser', () {
//     String expression = '\\frac{x}{y}';
//     String dfracExpression = '\\dfrac{x}{y}';
//     String tfracExpression = '\\tfrac{x}{y}';
//     test('should not fail', () {
//       toParse(expression: expression);
//     });
//     test('should produce a frac', () {
//       List<ParseNode> tree = toParse(expression: expression);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('frac')));
//       expect(parseNode.value['numer'], isNotNull);
//       expect(parseNode.value['denom'], isNotNull);
//     });
//     test('should also parse dfrac and tfrac', () {
//       toParse(expression: dfracExpression);
//       toParse(expression: tfracExpression);
//     });
//     test('should parse dfrac and tfrac as fracs', () {
//       List<ParseNode> treeA = toParse(expression: dfracExpression);
//       ParseNode parseNodeA = treeA[0];
//       expect(parseNodeA.type, matches(new RegExp('frac')));
//       expect(parseNodeA.value['numer'], isNotNull);
//       expect(parseNodeA.value['denom'], isNotNull);
//       List<ParseNode> treeB = toParse(expression: tfracExpression);
//       ParseNode parseNodeB = treeB[0];
//       expect(parseNodeB.type, matches(new RegExp('frac')));
//       expect(parseNodeB.value['numer'], isNotNull);
//       expect(parseNodeB.value['denom'], isNotNull);
//     });
//   });
//   group('An over parser', () {
//     String simpleOver = '1 \\over x';
//     String complexOver = '1+2i \\over 3+4i';
//     test('should not fail', () {
//       toParse(expression: simpleOver);
//       toParse(expression: complexOver);
//     });
//     test('should produce a frac', () {
//       List<ParseNode> treeA = toParse(expression: simpleOver);
//       ParseNode parseNodeA = treeA[0];
//       expect(parseNodeA.type, matches(new RegExp('frac')));
//       expect(parseNodeA.value['numer'], isNotNull);
//       expect(parseNodeA.value['denom'], isNotNull);
//       List<ParseNode> treeB = toParse(expression: complexOver);
//       ParseNode parseNodeB = treeB[0];
//       expect(parseNodeB.type, matches(new RegExp('frac')));
//       expect(parseNodeB.value['numer'], isNotNull);
//       expect(parseNodeB.value['denom'], isNotNull);
//     });
//     test('should create a numerator from the atoms before \\over', () {
//       List<ParseNode> tree = toParse(expression: complexOver);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.value['numer'].value.length, 4);
//     });
//     test('should create a demonimator from the atoms after \\over', () {
//       List<ParseNode> tree = toParse(expression: complexOver);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.value['denom'].value.length, 4);
//     });
//     test('should handle empty numerators', () {
//       String emptyNumerator = '\\over x';
//       List<ParseNode> tree = toParse(expression: emptyNumerator);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('frac')));
//       expect(parseNode.value['numer'], isNotNull);
//       expect(parseNode.value['denom'], isNotNull);
//     });
//     test('should handle empty denominators', () {
//       String emptyDenominator = '1 \\over';
//       List<ParseNode> tree = toParse(expression: emptyDenominator);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('frac')));
//       expect(parseNode.value['numer'], isNotNull);
//       expect(parseNode.value['denom'], isNotNull);
//     });
//     test('should handle \\displaystyle correctly', () {
//       String displaystyleExpression = '\\displaystyle 1 \\over 2';
//       List<ParseNode> tree = toParse(expression: displaystyleExpression);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('frac')));
//       expect(parseNode.value['numer'].value[0].type, matches(new RegExp('styling')));
//       expect(parseNode.value['denom'], isNotNull);
//     });
//     test('should handle nested factions', () {
//       String nestedOverExpression = '{1 \\over 2} \\over 3';
//       List<ParseNode> tree = toParse(expression: nestedOverExpression);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('frac')));
//       expect(parseNode.value['numer'].value[0].type, matches(new RegExp('frac')));
//       expect(parseNode.value['numer'].value[0].value['numer'].value[0].value, '1');
//       expect(parseNode.value['numer'].value[0].value['denom'].value[0].value, '2');
//       expect(parseNode.value['denom'], isNotNull);
//       expect(parseNode.value['denom'].value[0].value, '3');
//     });
//     test('should fail with multiple overs in the same group', () {
//       String badMultipleOvers = '1 \\over 2 + 3 \\over 4';
//       expect(() => toParse(expression: badMultipleOvers), throwsA(new isInstanceOf<ParseError>()));
//     });
//   });
//   group('A sizing parser', () {
//     String sizeExpression = '\\Huge{x}\\small{x}';
//     String nestedSizeExpression = '\\Huge{\\small{x}}';
//     test('should not fail', () {
//       toParse(expression: sizeExpression);
//     });
//     test('should produce a sizing node', () {
//       List<ParseNode> tree = toParse(expression: sizeExpression);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('sizing')));
//       expect(parseNode.value, isNotNull);
//     });
//   });
//   group('A text parser', () {
//     String textExpression = '\\text{a b}';
//     String noBraceTextExpression = '\\text x';
//     String nestedTextExpression = '\\text{a {b} \\blue{c} \\color{#fff}{x} \\llap{x}}';
//     String spaceTextExpression = '\\text{  a \\ }';
//     String leadingSpaceTextExpression = '\\text {moo}';
//     String badTextExpression = '\\text{a b%}';
//     String badFunctionExpression = '\\text{\\sqrt{x}}';
//     test('should not fail', () {
//       toParse(expression: textExpression);
//     });
//     test('should produce a text', () {
//       List<ParseNode> tree = toParse(expression: textExpression);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('text')));
//       expect(parseNode.value, isNotNull);
//     });
//     test('should produce textords instead of mathords', () {
//       List<ParseNode> tree = toParse(expression: textExpression);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.value['body'][0].type, matches(new RegExp('textord')));
//     });
//     test('should not parse bad text', () {
//       expect(() => toParse(expression: badTextExpression), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should not parse bad functions inside text', () {
//       expect(() => toParse(expression: badFunctionExpression), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should parse text wtesth no braces around test', () {
//       toParse(expression: noBraceTextExpression);
//     });
//     test('should parse nested expressions', () {
//       toParse(expression: nestedTextExpression);
//     });
//     test('should contract spaces', () {
//       List<ParseNode> tree = toParse(expression: spaceTextExpression);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.value['body'][0].type, matches(new RegExp('spacing')));
//       expect(parseNode.value['body'][1].type, matches(new RegExp('textord')));
//       expect(parseNode.value['body'][2].type, matches(new RegExp('spacing')));
//       expect(parseNode.value['body'][3].type, matches(new RegExp('spacing')));
//     });
//     test('should ignore a space before the text group', () {
//       List<ParseNode> tree = toParse(expression: leadingSpaceTextExpression);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.value['body'].length, 3);
//       expect(parseNode.value['body'].map((n) => n.value).join(''), 'moo');
//     });
//   });
//   group('A color parser', () {
//     String colorExpression = '\\blue{x}';
//     String customColorExpression = '\\color{#fA6}{x}';
//     String badCustomColorExpression = '\\color{bad-color}{x}';
//     test('should not fail', () {
//       toParse(expression: colorExpression);
//     });
//     test('should build a color node', () {
//       List<ParseNode> tree = toParse(expression: colorExpression);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('color')));
//       expect(parseNode.value['color'], isNotNull);
//       expect(parseNode.value['value'], isNotNull);
//     });
//     test('should parse a custom color', () {
//       toParse(expression: customColorExpression);
//     });
//     test('should correctly extract the custom color', () {
//       List<ParseNode> tree = toParse(expression: customColorExpression);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.value['color'], matches(new RegExp('#fA6')));
//     });
//     test('should not parse a bad custom color', () {
//       expect(() => toParse(expression: badCustomColorExpression), throwsA(new isInstanceOf<ParseError>()));
//     });
//   });
//   group('A tie parser', () {
//     String mathTie = 'a~b';
//     String textTie = '\\text{a~ b}';
//     test('should parse ties in math mode', () {
//       toParse(expression: mathTie);
//     });
//     test('should parse ties in text mode', () {
//       toParse(expression: textTie);
//     });
//     test('should produce spacing in math mode', () {
//       List<ParseNode> tree = toParse(expression: mathTie);
//       ParseNode parseNode = tree[1];
//       expect(parseNode.type, matches(new RegExp('spacing')));
//     });
//     test('should produce spacing in text mode', () {
//       List<ParseNode> tree = toParse(expression: textTie);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.value['body'][1].type, matches(new RegExp('spacing')));
//     });
//     test('should not contract with spaces in text mode', () {
//       List<ParseNode> tree = toParse(expression: textTie);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.value['body'][2].type, matches(new RegExp('spacing')));
//     });
//   });
//   group('A delimiter sizing parser', () {
//     String normalDelim = '\\bigl |';
//     String notDelim = '\\bigl x';
//     String bigDelim = '\\Biggr \\langle';
//     test('should parse normal delimiters', () {
//       toParse(expression: normalDelim);
//       toParse(expression: bigDelim);
//     });
//     test('should not parse not-delimiters', () {
//       expect(() => toParse(expression: notDelim), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should produce a delimsizing', () {
//       List<ParseNode> tree = toParse(expression: normalDelim);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('delimsizing')));
//     });
//     test('should produce the correct direction delimiter', () {
//       List<ParseNode> treeA = toParse(expression: normalDelim);
//       ParseNode parseNodeA = treeA[0];
//       expect(parseNodeA.value['delimType'], matches(new RegExp('open')));
//       List<ParseNode> treeB = toParse(expression: bigDelim);
//       ParseNode parseNodeB = treeB[0];
//       expect(parseNodeB.value['delimType'], matches(new RegExp('close')));
//     });
//     test('should parse the correct size delimiter', () {
//       List<ParseNode> treeA = toParse(expression: normalDelim);
//       ParseNode parseNodeA = treeA[0];
//       expect(parseNodeA.value['size'], 1);
//       List<ParseNode> treeB = toParse(expression: bigDelim);
//       ParseNode parseNodeB = treeB[0];
//       expect(parseNodeB.value['size'], 4);
//     });
//   });
//   group('An overline parser', () {
//     String overline = '\\overline{x}';
//     test('should not fail', () {
//       toParse(expression: overline);
//     });
//     test('should produce an overline', () {
//       List<ParseNode> tree = toParse(expression: overline);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('overline')));
//     });
//   });
//   group('A rule parser', () {
//     String emRule = '\\rule{1em}{2em}';
//     String exRule = '\\rule{1ex}{2em}';
//     String badUnitRule = '\\rule{1px}{2em}';
//     String noNumberRule = '\\rule{1em}{em}';
//     String incompleteRule = '\\rule{1em}';
//     String hardNumberRule = '\\rule{   01.24ex}{2.450   em   }';
//     test('should not fail', () {
//       toParse(expression: emRule);
//       toParse(expression: exRule);
//     });
//     test('should not parse invalid units', () {
//       expect(() => toParse(expression: badUnitRule), throwsA(new isInstanceOf<ParseError>()));
//       expect(() => toParse(expression: noNumberRule), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should not parse incomplete rules', () {
//       expect(() => toParse(expression: incompleteRule), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should produce a rule', () {
//       List<ParseNode> tree = toParse(expression: emRule);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('rule')));
//     });
//     test('should list the correct units', () {
//       List<ParseNode> treeA = toParse(expression: emRule);
//       ParseNode parseNodeA = treeA[0];
//       expect(parseNodeA.value['width']['unit'], matches(new RegExp('em')));
//       expect(parseNodeA.value['height']['unit'], matches(new RegExp('em')));
//       List<ParseNode> treeB = toParse(expression: exRule);
//       ParseNode parseNodeB = treeB[0];
//       expect(parseNodeB.value['width']['unit'], matches(new RegExp('ex')));
//       expect(parseNodeB.value['height']['unit'], matches(new RegExp('em')));
//     });
//     test('should parse the number correctly', () {
//       List<ParseNode> tree = toParse(expression: hardNumberRule);
//       ParseNode parseNode = tree[0];
//       expect(double.parse(parseNode.value['width']['number']), 1.24);
//       expect(double.parse(parseNode.value['height']['number']), 2.45);
//     });
//     test('should parse negative sizes', () {
//       List<ParseNode> tree = toParse(expression: '\\rule{-1em}{- 0.2em}');
//       ParseNode parseNode = tree[0];
//       expect(double.parse(parseNode.value['width']['number']), -1);
//       expect(double.parse(parseNode.value['height']['number']), -0.2);
//     });
//   });
//   group('A left/right parser', () {
//     String normalLeftRight = '\\left( \\dfrac{x}{y} \\right)';
//     String emptyRight = '\\left( \\dfrac{x}{y} \\right.';
//     test('should not fail', () {
//       toParse(expression: normalLeftRight);
//     });
//     test('should produce a leftright', () {
//       List<ParseNode> tree = toParse(expression: normalLeftRight);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('leftright')));
//       expect(parseNode.value['left']['value'], matches(new RegExp('\\(')));
//       expect(parseNode.value['right']['value'], matches(new RegExp('\\)')));
//     });
//     test('should error when test is mismatched', () {
//       String unmatchedLeft = '\\left( \\dfrac{x}{y}';
//       String unmatchedRight = '\\dfrac{x}{y} \\right)';
//       expect(() => toParse(expression: unmatchedLeft), throwsA(new isInstanceOf<ParseError>()));
//       expect(() => toParse(expression: unmatchedRight), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should error when braces are mismatched', () {
//       String unmatched = '{ \\left( \\dfrac{x}{y} } \\right)';
//       expect(() => toParse(expression: unmatched), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should error when non-delimiters are provided', () {
//       String nonDelimiter = r'\\left$ \\dfrac{x}{y} \\right)';
//       expect(() => toParse(expression: nonDelimiter), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should parse the empty "." delimiter', () {
//       toParse(expression: emptyRight);
//     });
//     test('should parse the "." delimiter with normal sizes', () {
//       String normalEmpty = '\\Bigl .';
//       toParse(expression: normalEmpty);
//     });
//   });
//   group('A sqrt parser', () {
//     String sqrt = '\\sqrt{x}';
//     String missingGroup = '\\sqrt';
//     test('should parse square roots', () {
//       toParse(expression: sqrt);
//     });
//     test('should error when there is no group', () {
//       expect(() => toParse(expression: missingGroup), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should produce sqrts', () {
//       List<ParseNode> tree = toParse(expression: sqrt);
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('sqrt')));
//     });
//   });
//   group('A TeX-compliant parser', () {
//     test('should work', () {
//       toParse(expression: '\\frac 2 3');
//     });
//     test('should fail if there are not enough arguments', () {
//       List<String> missingGroups = [
//         '\\frac{x}',
//         '\\color{#fff}',
//         '\\rule{1em}',
//         '\\llap',
//         '\\bigl',
//         '\\text'
//       ];
//       missingGroups.forEach((group) {
//         expect(() => toParse(expression: group), throwsA(new isInstanceOf<ParseError>()));
//       });
//     });
//     test('should fail when there are missing sup/subscripts', () {
//       expect(() => toParse(expression: 'x^'), throwsA(new isInstanceOf<ParseError>()));
//       expect(() => toParse(expression: 'x_'), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should fail when arguments require arguments', () {
//       List<String> badArguments = [
//         '\\frac \\frac x y z',
//         '\\frac x \\frac y z',
//         '\\frac \\sqrt x y',
//         '\\frac x \\sqrt y',
//         '\\frac \\llap x y',
//         '\\frac x \\llap y',
//         '\\llap \\llap x',
//         '\\sqrt \\llap x'
//       ];
//       badArguments.forEach((argument) {
//         expect(() => toParse(expression: argument), throwsA(new isInstanceOf<ParseError>()));
//       });
//     });
//     test('should work when the arguments have braces', () {
//       List<String> goodArguments = [
//         '\\frac {\\frac x y} z',
//         '\\frac x {\\frac y z}',
//         '\\frac {\\sqrt x} y',
//         '\\frac x {\\sqrt y}',
//         '\\frac {\\llap x} y',
//         '\\frac x {\\llap y}',
//         '\\llap {\\frac x y}',
//         '\\llap {\\llap x}',
//         '\\sqrt {\\llap x}'
//       ];
//       goodArguments.forEach((argument) {
//         toParse(expression: argument);
//       });
//     });
//     test('should fail when sup/subscripts require arguments', () {
//       List<String> badSupSubscripts = ['x^\\sqrt x', 'x^\\llap x', 'x_\\sqrt x', 'x_\\llap x'];
//       badSupSubscripts.forEach((supSubscript) {
//         expect(() => toParse(expression: supSubscript), throwsA(new isInstanceOf<ParseError>()));
//       });
//     });
//     test('should work when sup/subscripts arguments have braces', () {
//       List<String> goodSupSubscripts = ['x^{\\sqrt x}', 'x^{\\llap x}', 'x_{\\sqrt x}', 'x_{\\llap x}'];
//       goodSupSubscripts.forEach((supSubscript) {
//         toParse(expression: supSubscript);
//       });
//     });
//     test('should parse multiple primes correctly', () {
//       toParse(expression: "x''''");
//       toParse(expression: "x_2''");
//       toParse(expression: "x''_2");
//       toParse(expression: "x'_2'");
//     });
//     test('should fail when sup/subscripts are interspersed with arguments', () {
//       expect(() => toParse(expression: '\\sqrt^23'), throwsA(new isInstanceOf<ParseError>()));
//       expect(() => toParse(expression: '\\frac^234'), throwsA(new isInstanceOf<ParseError>()));
//       expect(() => toParse(expression: '\\frac2^34'), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should succeed when sup/subscripts come after whole functions', () {
//       toParse(expression: '\\sqrt2^3');
//       toParse(expression: '\\frac23^4');
//     });
//     test('should succeed with a sqrt around a text/frac', () {
//       toParse(expression: '\\sqrt \\frac x y');
//       toParse(expression: '\\sqrt \\text x');
//       toParse(expression: 'x^\\frac x y');
//       toParse(expression: 'x_\\text x');
//     });
//     test('should fail when arguments are \\left', () {
//       List<String> badLeftArguments = [
//         '\\frac \\left( x \\right) y',
//         '\\frac x \\left( y \\right)',
//         '\\llap \\left( x \\right)',
//         '\\sqrt \\left( x \\right)',
//         'x^\\left( x \\right)'
//       ];
//       badLeftArguments.forEach((argument) {
//         expect(() => toParse(expression: argument), throwsA(new isInstanceOf<ParseError>()));
//       });
//     });
//     test('should succeed when there are braces around the \\left/\\right', () {
//       List<String> goodLeftArguments = [
//         '\\frac {\\left( x \\right)} y',
//         '\\frac x {\\left( y \\right)}',
//         '\\llap {\\left( x \\right)}',
//         '\\sqrt {\\left( x \\right)}',
//         'x^{\\left( x \\right)}'
//       ];
//       goodLeftArguments.forEach((argument) {
//         toParse(expression: argument);
//       });
//     });
//   });
//   group('A style change parser', () {
//     test('should not fail', () {
//       toParse(expression: '\\displaystyle x');
//       toParse(expression: '\\textstyle x');
//       toParse(expression: '\\scriptstyle x');
//       toParse(expression: '\\scriptscriptstyle x');
//     });
//     test('should produce the correct style', () {
//       List<ParseNode> treeA = toParse(expression: '\\displaystyle x');
//       ParseNode parseNodeA = treeA[0];
//       expect(parseNodeA.value['style'], matches(new RegExp('display')));
//       List<ParseNode> treeB = toParse(expression: '\\scriptscriptstyle x');
//       ParseNode parseNodeB = treeB[0];
//       expect(parseNodeB.value['style'], matches(new RegExp('scriptscript')));
//     });
//     test('should only change the style within its group', () {
//       String text = 'a b { c d \\displaystyle e f } g h';
//       List<ParseNode> tree = toParse(expression: text);
//       ParseNode parseNode = tree[2];
//       ParseNode displayNode = parseNode.value[2];
//       expect(displayNode.type, matches(new RegExp('styling')));
//       List<ParseNode> displayBody = displayNode.value['value'];
//       expect(displayBody.length, 2);
//       expect(displayBody[0].value, matches(new RegExp('e')));
//     });
//   });
//   group('A bin builder', () {
//     test('should create mbins normally', () {
//       List<SymbolNode> symbols = getBuilt(expression: 'x + y');
//       expect(symbols[1].classes.contains('mbin'), isTrue);
//     });
//     test('should create ords when at the beginning of lists', () {
//       List<SymbolNode> symbols = getBuilt(expression: '+ x');
//       expect(symbols[0].classes.contains('mord'), isTrue);
//       expect(symbols[0].classes.contains('mbin'), isFalse);
//     });
//     test('should create ords after some other objects', () {
//       expect(getBuilt(expression: 'x + + 2')[2].classes.contains('mord'), isTrue);
//       expect(getBuilt(expression: '( + 2')[1].classes.contains('mord'), isTrue);
//       expect(getBuilt(expression: '= + 2')[1].classes.contains('mord'), isTrue);
//       expect(getBuilt(expression: '\\sin + 2')[1].classes.contains('mord'), isTrue);
//       expect(getBuilt(expression: ', + 2')[1].classes.contains('mord'), isTrue);
//     });
//     test('should correctly interact with color objects', () {
//       expect(getBuilt(expression: '\\blue{x}+y')[1].classes.contains('mbin'), isTrue);
//       expect(getBuilt(expression: '\\blue{x+}+y')[1].classes.contains('mord'), isTrue);
//     });
//   });
//   group('A markup generator', () {
//     test('marks trees up', () {
//       Katex katex = new Katex();
//       String markup = katex.renderToString('\\sigma^2');
//       expect(markup.indexOf('<span'), 0);
//       expect(markup.contains('\u03c3'), isTrue);
//       expect(markup.contains('margin-right'), isTrue);
//       expect(markup.contains('marginRight'), isFalse);
//     });
//   });
//   group('An accent parser', () {
//     test('should not fail', () {
//       toParse(expression: '\\vec{x}');
//       toParse(expression: '\\vec{x^2}');
//       toParse(expression: '\\vec{x}^2');
//       toParse(expression: '\\vec x');
//     });
//     test('should produce accents', () {
//       List<ParseNode> tree = toParse(expression: '\\vec x');
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('accent')));
//     });
//     test('should be grouped more tightly than supsubs', () {
//       List<ParseNode> tree = toParse(expression: '\\vec x^2');
//       ParseNode parseNode = tree[0];
//       expect(parseNode.type, matches(new RegExp('supsub')));
//     });
//     test('should not parse expanding accents', () {
//       expect(() => toParse(expression: '\\widehat{x}'), throwsA(new isInstanceOf<ParseError>()));
//     });
//   });
//   group('An accent builder', () {
//     test('should not fail', () {
//       toBuild(expression: '\\vec{x}');
//       toBuild(expression: '\\vec{x}^2');
//       toBuild(expression: '\\vec{x}_2');
//       toBuild(expression: '\\vec{x}_2^2');
//     });
//     test('should produce mords', () {
//       expect(getBuilt(expression: '\\vec x')[0].classes.contains('mord'), isTrue);
//       expect(getBuilt(expression: '\\vec +')[0].classes.contains('mord'), isTrue);
//       expect(getBuilt(expression: '\\vec +')[0].classes.contains('mbin'), isFalse);
//       expect(getBuilt(expression: '\\vec )^2')[0].classes.contains('mord'), isTrue);
//       expect(getBuilt(expression: '\\vec )^2')[0].classes.contains('mclose'), isFalse);
//     });
//   });
//   group('A parser error', () {
//     test('should report the position of an error', () {
//       try {
//         toParse(expression: '\\sqrt}');
//       } catch (e) {
//         expect(e.position, 5);
//       }
//     });
//   });
//   group('An optional argument parser', () {
//     test('should not fail', () {
//       toParse(expression: '\\frac[1]{2}{3}');
//       toParse(expression: '\\rule[0.2em]{1em}{1em}');
//     });
//     test('should fail on sqrts for now', () {
//       expect(() => toParse(expression: '\\sqrt[3]{2}'), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should work when the optional argument is missing', () {
//       toParse(expression: '\\sqrt{2}');
//       toParse(expression: '\\rule{1em}{2em}');
//     });
//     test('should fail when the optional argument is malformed', () {
//       expect(() => toParse(expression: '\\rule[1]{2em}{3em}'), throwsA(new isInstanceOf<ParseError>()));
//     });
//     test('should not work if the optional argument is not closed', () {
//       expect(() => toParse(expression: '\\sqrt['), throwsA(new isInstanceOf<ParseError>()));
//     });
//   });
// }

// /// Example equations to test and showcase the renderer and parser.
// List<String> get equations => [
//   r'\text{Hello, World!}',
//   r'\mu =: \sqrt{x}',
//   r'\eta = 7^\frac{4}{2}',
//   r'\epsilon = \frac 2 {3 + 2}',
//   r'x_{initial} = \frac {20x} {\frac{15}{3}}',
//   // ignore: no_adjacent_strings_in_list
//   r'\colorbox{red}{bunt} \boxed{ '
//   r'\rm{\sf{\bf{'
//   r'\textcolor{red} s \textcolor{pink}  i \textcolor{purple}m '
//   r'\textcolor{blue}p \textcolor{cyan}  l \textcolor{teal}  e} '
//   r'\textcolor{lime}c \textcolor{yellow}l \textcolor{amber} u '
//   r'\textcolor{orange} b}}}',
//   r'\TeX',
//   r'\LaTeX',
//   r'\KaTeX',
//   r'\CaTeX',
//   'x_i=a^n',
//   r'\hat{y} = H y',
//   r'12^{\frac{\frac{2}{7}}{1}}',
//   r'\varepsilon = \frac{\frac{2}{1}}{3}',
//   r'\alpha\beta\gamma\delta',
//   // ignore: no_adjacent_strings_in_list
//   r'\colorbox{black}{\textcolor{white} {black} } \colorbox{white} '
//   r'{\textcolor{black} {white} }',
//   r'\alpha\ \beta\ \ \gamma\ \ \ \delta',
//   r'\epsilon = \frac{2}{3 + 2}',
//   r'\tt {type} \textcolor{teal}{\rm{\tt {writer} }}',
//   'l = a * t * e * x',
//   r'\rm\tt{sp   a c  i n\ \bf\it g}',
//   r'5 = 1 \cdot 5',
//   '{2 + 3}+{3             +4    }=12',
//   r'\backslash \leftarrow \uparrow \rightarrow  \$',
//   r'42\uparrow 99\Uparrow\ \  19\downarrow 1\Downarrow',
//   '5x =      25',
//   r'10\cdot10 = 100',
//   'a := 96',
// ];

// import 'dart:io';
//
// import 'package:path/path.dart' as p;
//
// const header = '''
// /// This file was automatically generated - do not edit manually.
// /// See `gen/macros.dart` instead.
//
// const macros = <String, String>{''';
//
// /// Writes the code for supported macros to a file called `macros.g.dart`.
// ///
// /// The directory is determined by the path specified as the first argument.
// Future<void> main(List<String> args) async {
//   final file = File(p.join(args.first, 'macros.g.dart'));
//
//   // This makes sure the code does not run for nothing.
//   if (file.existsSync()) file.deleteSync();
//   file.createSync();
//
//   // ignore: omit_local_variable_types
//   final List<String> lines = [...header.split('\\n')];
//   final Map<String, String> macros = {};
//
//   // This only supports rewrite macros, i.e. string to string mapping for now.
//   void defineMacro(
//       String name,
//       String rewrite,
//       ) {
//     assert(
//     name != null && rewrite != null && !macros.containsKey(name),
//     'Input `defineMacro($name, $rewrite)` is invalid.',
//     );
//
//     macros[name] = rewrite;
//   }
//
//   // These are inspired by https://github.com/KaTeX/KaTeX/blob/c2e5a289c0245b15a5a7a0cc3041b9026cf4eb8c/src/macros.js
//   // for now, however, it would in fact be nice if this could just be based
//   // on that, i.e. if the macros could be copied for the most part.
//   // This is not possible because KaTeX supports way more functionality than
//   // CaTeX does.
//   defineMacro("\\u00b7", "\\\\cdotp");
//   defineMacro("\\u27C2", "\\\\perp");
//   defineMacro("\\\\larr", "\\\\leftarrow");
//   defineMacro("\\\\lArr", "\\\\Leftarrow");
//   defineMacro("\\\\Larr", "\\\\Leftarrow");
//   defineMacro("\\\\lrarr", "\\\\leftrightarrow");
//   defineMacro("\\\\lrArr", "\\\\Leftrightarrow");
//   defineMacro("\\\\Lrarr", "\\\\Leftrightarrow");
//   defineMacro("\\\\infin", "\\\\infty");
//   defineMacro("\\\\harr", "\\\\leftrightarrow");
//   defineMacro("\\\\hArr", "\\\\Leftrightarrow");
//   defineMacro("\\\\Harr", "\\\\Leftrightarrow");
//   defineMacro("\\\\hearts", "\\\\heartsuit");
//
//   defineMacro("\\\\TeX", "\\\\rm{T\\\\kern{-.1667em}\\\\raisebox{-.5ex}{E}\\\\kern{-.125em}X}");
//   defineMacro(
//       "\\\\LaTeX",
//       "\\\\rm{L\\\\kern{-.36em}\\\\raisebox{.205em}{\\\\scriptstyle A} "
//           "\\\\kern{-.15em}\\\\TeX}");
//   defineMacro(
//       "\\\\KaTeX",
//       "\\\\rm{K\\\\kern{-.17em}\\\\raisebox{0.205em}{\\\\scriptstyle A} "
//           "\\\\kern{-.15em}\\\\TeX}");
//   defineMacro(
//       "\\\\CaTeX",
//       "\\\\rm{\\\\raisebox{-0.05em}C\\\\kern{-.12em}\\\\raisebox{0.2em}"
//           "{\\\\scriptstyle A}\\\\kern{-.15em}\\\\TeX}");
//
//   for (final entry in macros.entries) {
//     lines.add(" '${entry.key}': '${entry.value}',");
//   }
//   lines.add('};\n');
//
//   await file.writeAsString(lines.join('\n'));
// }

// import 'dart:io';
//
// import 'package:catex/src/lookup/modes.dart';
// import 'package:catex/src/lookup/symbols.dart';
// import 'package:path/path.dart' as p;
//
// final header = '''
// import 'package:catex/src/lookup/modes.dart';
// import 'package:catex/src/lookup/symbols.dart';
//
// /// This file was automatically generated - do not edit manually.
// /// See `gen/symbols.dart` instead.
//
// const symbols = <$CaTeXMode, Map<$String, $SymbolData>>{''';
//
// /// Writes the code for supported symbols to a file called `symbols.g.dart`.
// ///
// /// The directory is determined by the path specified as the first argument.
// Future<void> main(List<String> args) async {
//   final file = File(p.join(args.first, 'symbols.g.dart'));
//
//   // This makes sure the code does not run for nothing.
//   if (file.existsSync()) file.deleteSync();
//   file.createSync();
//
//   // ignore: omit_local_variable_types
//   final List<String> lines = [...header.split('\\n')],
//       mathSymbols = [],
//       textSymbols = [];
//
//   const math = 'math',
//       text = 'text',
//       main = 'main',
//       ams = 'ams',
//       accent = 'accent',
//       bin = 'bin',
//       close = 'close',
//       inner = 'inner',
//       mathord = 'mathord',
//       op = 'op',
//       open = 'open',
//       punct = 'punct',
//       rel = 'rel',
//       spacing = 'spacing',
//       textord = 'textord';
//
//   void defineSymbol(
//       String mode,
//       String font,
//       String group,
//       String unicode,
//       String name, [
//         // ignore: avoid_positional_boolean_parameters
//         bool createUnicodeEntry = false,
//       ]) {
//     assert(
//     mode?.isNotEmpty == true &&
//         font?.isNotEmpty == true &&
//         group?.isNotEmpty == true &&
//         (unicode == null || unicode?.isNotEmpty == true) &&
//         name?.isNotEmpty == true &&
//         createUnicodeEntry != null,
//     'Input `defineSymbol($mode, $font, $group, $unicode, $name)` is invalid.',
//     );
//
//     (mode == math ? mathSymbols : textSymbols)
//         .add("    ${name.contains("'") ? '"$name"' : "'$name'"}: "
//         "$SymbolData(${unicode != null ? "'$unicode'" : null}, "
//         '$SymbolFont.$font, $SymbolGroup.$group),');
//
//     if (unicode != null && createUnicodeEntry) {
//       (mode == math ? mathSymbols : textSymbols)
//           .add("    '$unicode': $SymbolData('$unicode', "
//           "$SymbolFont.$font, $SymbolGroup.$group),");
//     }
//   }
//
//   /// This is based on https://github.com/KaTeX/KaTeX/blob/c8c7c3954c4c3e2a3e0499a1fd52e9c66e286462/src/symbols.js.
//   defineSymbol(math, main, rel, "\\u2261", "\\\\equiv", true);
//   defineSymbol(math, main, rel, "\\u2260", "\\\\neq", true);
//   defineSymbol(math, main, rel, "\\u227a", "\\\\prec", true);
//   defineSymbol(math, main, rel, "\\u227b", "\\\\succ", true);
//   defineSymbol(math, main, rel, "\\u223c", "\\\\sim", true);
//   defineSymbol(math, main, rel, "\\u22a5", "\\\\perp");
//   defineSymbol(math, main, rel, "\\u2aaf", "\\\\preceq", true);
//   defineSymbol(math, main, rel, "\\u2ab0", "\\\\succeq", true);
//   defineSymbol(math, main, rel, "\\u2243", "\\\\simeq", true);
//   defineSymbol(math, main, rel, "\\u2223", "\\\\mid", true);
//   defineSymbol(math, main, rel, "\\u226a", "\\\\ll", true);
//   defineSymbol(math, main, rel, "\\u226b", "\\\\gg", true);
//   defineSymbol(math, main, rel, "\\u224d", "\\\\asymp", true);
//   defineSymbol(math, main, rel, "\\u2225", "\\\\parallel");
//   defineSymbol(math, main, rel, "\\u22c8", "\\\\bowtie", true);
//   defineSymbol(math, main, rel, "\\u2323", "\\\\smile", true);
//   defineSymbol(math, main, rel, "\\u2291", "\\\\sqsubseteq", true);
//   defineSymbol(math, main, rel, "\\u2292", "\\\\sqsupseteq", true);
//   defineSymbol(math, main, rel, "\\u2250", "\\\\doteq", true);
//   defineSymbol(math, main, rel, "\\u2322", "\\\\frown", true);
//   defineSymbol(math, main, rel, "\\u220b", "\\\\ni", true);
//   defineSymbol(math, main, rel, "\\u221d", "\\\\propto", true);
//   defineSymbol(math, main, rel, "\\u22a2", "\\\\vdash", true);
//   defineSymbol(math, main, rel, "\\u22a3", "\\\\dashv", true);
//   defineSymbol(math, main, rel, "\\u220b", "\\\\owns");
//   defineSymbol(math, main, punct, "\\u002e", "\\\\ldotp");
//   defineSymbol(math, main, punct, "\\u22c5", "\\\\cdotp");
//   defineSymbol(math, main, textord, "\\u0023", "\\\\#");
//   defineSymbol(text, main, textord, "\\u0023", "\\\\#");
//   defineSymbol(math, main, textord, "\\u0026", "\\\\&");
//   defineSymbol(text, main, textord, "\\u0026", "\\\\&");
//   defineSymbol(math, main, textord, "\\u2135", "\\\\aleph", true);
//   defineSymbol(math, main, textord, "\\u2200", "\\\\forall", true);
//   defineSymbol(math, main, textord, "\\u210f", "\\\\hbar", true);
//   defineSymbol(math, main, textord, "\\u2203", "\\\\exists", true);
//   defineSymbol(math, main, textord, "\\u2207", "\\\\nabla", true);
//   defineSymbol(math, main, textord, "\\u266d", "\\\\flat", true);
//   defineSymbol(math, main, textord, "\\u2113", "\\\\ell", true);
//   defineSymbol(math, main, textord, "\\u266e", "\\\\natural", true);
//   defineSymbol(math, main, textord, "\\u2663", "\\\\clubsuit", true);
//   defineSymbol(math, main, textord, "\\u2118", "\\\\wp", true);
//   defineSymbol(math, main, textord, "\\u266f", "\\\\sharp", true);
//   defineSymbol(math, main, textord, "\\u2662", "\\\\diamondsuit", true);
//   defineSymbol(math, main, textord, "\\u211c", "\\\\Re", true);
//   defineSymbol(math, main, textord, "\\u2661", "\\\\heartsuit", true);
//   defineSymbol(math, main, textord, "\\u2111", "\\\\Im", true);
//   defineSymbol(math, main, textord, "\\u2660", "\\\\spadesuit", true);
//   defineSymbol(text, main, textord, "\\u00a7", "\\\\S", true);
//   defineSymbol(text, main, textord, "\\u00b6", "\\\\P", true);
//   defineSymbol(math, main, textord, "\\u2020", "\\\\dag");
//   defineSymbol(text, main, textord, "\\u2020", "\\\\dag");
//   defineSymbol(text, main, textord, "\\u2020", "\\\\textdagger");
//   defineSymbol(math, main, textord, "\\u2021", "\\\\ddag");
//   defineSymbol(text, main, textord, "\\u2021", "\\\\ddag");
//   defineSymbol(text, main, textord, "\\u2021", "\\\\textdaggerdbl");
//   defineSymbol(math, main, close, "\\u23b1", "\\\\rmoustache", true);
//   defineSymbol(math, main, open, "\\u23b0", "\\\\lmoustache", true);
//   defineSymbol(math, main, close, "\\u27ef", "\\\\rgroup", true);
//   defineSymbol(math, main, open, "\\u27ee", "\\\\lgroup", true);
//   defineSymbol(math, main, bin, "\\u2213", "\\\\mp", true);
//   defineSymbol(math, main, bin, "\\u2296", "\\\\ominus", true);
//   defineSymbol(math, main, bin, "\\u228e", "\\\\uplus", true);
//   defineSymbol(math, main, bin, "\\u2293", "\\\\sqcap", true);
//   defineSymbol(math, main, bin, "\\u2217", "\\\\ast");
//   defineSymbol(math, main, bin, "\\u2294", "\\\\sqcup", true);
//   defineSymbol(math, main, bin, "\\u25ef", "\\\\bigcirc");
//   defineSymbol(math, main, bin, "\\u2219", "\\\\bullet");
//   defineSymbol(math, main, bin, "\\u2021", "\\\\ddagger");
//   defineSymbol(math, main, bin, "\\u2240", "\\\\wr", true);
//   defineSymbol(math, main, bin, "\\u2a3f", "\\\\amalg");
//   defineSymbol(math, main, bin, "\\u0026", "\\\\And"); // from amsmath
//   defineSymbol(math, main, rel, "\\u27f5", "\\\\longleftarrow", true);
//   defineSymbol(math, main, rel, "\\u21d0", "\\\\Leftarrow", true);
//   defineSymbol(math, main, rel, "\\u27f8", "\\\\Longleftarrow", true);
//   defineSymbol(math, main, rel, "\\u27f6", "\\\\longrightarrow", true);
//   defineSymbol(math, main, rel, "\\u21d2", "\\\\Rightarrow", true);
//   defineSymbol(math, main, rel, "\\u27f9", "\\\\Longrightarrow", true);
//   defineSymbol(math, main, rel, "\\u2194", "\\\\leftrightarrow", true);
//   defineSymbol(math, main, rel, "\\u27f7", "\\\\longleftrightarrow", true);
//   defineSymbol(math, main, rel, "\\u21d4", "\\\\Leftrightarrow", true);
//   defineSymbol(math, main, rel, "\\u27fa", "\\\\Longleftrightarrow", true);
//   defineSymbol(math, main, rel, "\\u21a6", "\\\\mapsto", true);
//   defineSymbol(math, main, rel, "\\u27fc", "\\\\longmapsto", true);
//   defineSymbol(math, main, rel, "\\u2197", "\\\\nearrow", true);
//   defineSymbol(math, main, rel, "\\u21a9", "\\\\hookleftarrow", true);
//   defineSymbol(math, main, rel, "\\u21aa", "\\\\hookrightarrow", true);
//   defineSymbol(math, main, rel, "\\u2198", "\\\\searrow", true);
//   defineSymbol(math, main, rel, "\\u21bc", "\\\\leftharpoonup", true);
//   defineSymbol(math, main, rel, "\\u21c0", "\\\\rightharpoonup", true);
//   defineSymbol(math, main, rel, "\\u2199", "\\\\swarrow", true);
//   defineSymbol(math, main, rel, "\\u21bd", "\\\\leftharpoondown", true);
//   defineSymbol(math, main, rel, "\\u21c1", "\\\\rightharpoondown", true);
//   defineSymbol(math, main, rel, "\\u2196", "\\\\nwarrow", true);
//   defineSymbol(math, main, rel, "\\u21cc", "\\\\rightleftharpoons", true);
//   defineSymbol(math, ams, rel, "\\u226e", "\\\\nless", true);
//   defineSymbol(math, ams, rel, "\\ue010", "\\\\@nleqslant");
//   defineSymbol(math, ams, rel, "\\ue011", "\\\\@nleqq");
//   defineSymbol(math, ams, rel, "\\u2a87", "\\\\lneq", true);
//   defineSymbol(math, ams, rel, "\\u2268", "\\\\lneqq", true);
//   defineSymbol(math, ams, rel, "\\ue00c", "\\\\@lvertneqq");
//   defineSymbol(math, ams, rel, "\\u22e6", "\\\\lnsim", true);
//   defineSymbol(math, ams, rel, "\\u2a89", "\\\\lnapprox", true);
//   defineSymbol(math, ams, rel, "\\u2280", "\\\\nprec", true);
//   defineSymbol(math, ams, rel, "\\u22e0", "\\\\npreceq", true);
//   defineSymbol(math, ams, rel, "\\u22e8", "\\\\precnsim", true);
//   defineSymbol(math, ams, rel, "\\u2ab9", "\\\\precnapprox", true);
//   defineSymbol(math, ams, rel, "\\u2241", "\\\\nsim", true);
//   defineSymbol(math, ams, rel, "\\ue006", "\\\\@nshortmid");
//   defineSymbol(math, ams, rel, "\\u2224", "\\\\nmid", true);
//   defineSymbol(math, ams, rel, "\\u22ac", "\\\\nvdash", true);
//   defineSymbol(math, ams, rel, "\\u22ad", "\\\\nvDash", true);
//   defineSymbol(math, ams, rel, "\\u22ea", "\\\\ntriangleleft");
//   defineSymbol(math, ams, rel, "\\u22ec", "\\\\ntrianglelefteq", true);
//   defineSymbol(math, ams, rel, "\\u228a", "\\\\subsetneq", true);
//   defineSymbol(math, ams, rel, "\\ue01a", "\\\\@varsubsetneq");
//   defineSymbol(math, ams, rel, "\\u2acb", "\\\\subsetneqq", true);
//   defineSymbol(math, ams, rel, "\\ue017", "\\\\@varsubsetneqq");
//   defineSymbol(math, ams, rel, "\\u226f", "\\\\ngtr", true);
//   defineSymbol(math, ams, rel, "\\ue00f", "\\\\@ngeqslant");
//   defineSymbol(math, ams, rel, "\\ue00e", "\\\\@ngeqq");
//   defineSymbol(math, ams, rel, "\\u2a88", "\\\\gneq", true);
//   defineSymbol(math, ams, rel, "\\u2269", "\\\\gneqq", true);
//   defineSymbol(math, ams, rel, "\\ue00d", "\\\\@gvertneqq");
//   defineSymbol(math, ams, rel, "\\u22e7", "\\\\gnsim", true);
//   defineSymbol(math, ams, rel, "\\u2a8a", "\\\\gnapprox", true);
//   defineSymbol(math, ams, rel, "\\u2281", "\\\\nsucc", true);
//   defineSymbol(math, ams, rel, "\\u22e1", "\\\\nsucceq", true);
//   defineSymbol(math, ams, rel, "\\u22e9", "\\\\succnsim", true);
//   defineSymbol(math, ams, rel, "\\u2aba", "\\\\succnapprox", true);
//   defineSymbol(math, ams, rel, "\\u2246", "\\\\ncong", true);
//   defineSymbol(math, ams, rel, "\\ue007", "\\\\@nshortparallel");
//   defineSymbol(math, ams, rel, "\\u2226", "\\\\nparallel", true);
//   defineSymbol(math, ams, rel, "\\u22af", "\\\\nVDash", true);
//   defineSymbol(math, ams, rel, "\\u22eb", "\\\\ntriangleright");
//   defineSymbol(math, ams, rel, "\\u22ed", "\\\\ntrianglerighteq", true);
//   defineSymbol(math, ams, rel, "\\ue018", "\\\\@nsupseteqq");
//   defineSymbol(math, ams, rel, "\\u228b", "\\\\supsetneq", true);
//   defineSymbol(math, ams, rel, "\\ue01b", "\\\\@varsupsetneq");
//   defineSymbol(math, ams, rel, "\\u2acc", "\\\\supsetneqq", true);
//   defineSymbol(math, ams, rel, "\\ue019", "\\\\@varsupsetneqq");
//   defineSymbol(math, ams, rel, "\\u22ae", "\\\\nVdash", true);
//   defineSymbol(math, ams, rel, "\\u2ab5", "\\\\precneqq", true);
//   defineSymbol(math, ams, rel, "\\u2ab6", "\\\\succneqq", true);
//   defineSymbol(math, ams, rel, "\\ue016", "\\\\@nsubseteqq");
//   defineSymbol(math, ams, bin, "\\u22b4", "\\\\unlhd");
//   defineSymbol(math, ams, bin, "\\u22b5", "\\\\unrhd");
//   defineSymbol(math, ams, rel, "\\u219a", "\\\\nleftarrow", true);
//   defineSymbol(math, ams, rel, "\\u219b", "\\\\nrightarrow", true);
//   defineSymbol(math, ams, rel, "\\u21cd", "\\\\nLeftarrow", true);
//   defineSymbol(math, ams, rel, "\\u21cf", "\\\\nRightarrow", true);
//   defineSymbol(math, ams, rel, "\\u21ae", "\\\\nleftrightarrow", true);
//   defineSymbol(math, ams, rel, "\\u21ce", "\\\\nLeftrightarrow", true);
//   defineSymbol(math, ams, rel, "\\u25b3", "\\\\vartriangle");
//   defineSymbol(math, ams, textord, "\\u210f", "\\\\hslash");
//   defineSymbol(math, ams, textord, "\\u25bd", "\\\\triangledown");
//   defineSymbol(math, ams, textord, "\\u25ca", "\\\\lozenge");
//   defineSymbol(math, ams, textord, "\\u24c8", "\\\\circledS");
//   defineSymbol(math, ams, textord, "\\u00ae", "\\\\circledR");
//   defineSymbol(text, ams, textord, "\\u00ae", "\\\\circledR");
//   defineSymbol(math, ams, textord, "\\u2221", "\\\\measuredangle", true);
//   defineSymbol(math, ams, textord, "\\u2204", "\\\\nexists");
//   defineSymbol(math, ams, textord, "\\u2127", "\\\\mho");
//   defineSymbol(math, ams, textord, "\\u2132", "\\\\Finv", true);
//   defineSymbol(math, ams, textord, "\\u2141", "\\\\Game", true);
//   defineSymbol(math, ams, textord, "\\u2035", "\\\\backprime");
//   defineSymbol(math, ams, textord, "\\u25b2", "\\\\blacktriangle");
//   defineSymbol(math, ams, textord, "\\u25bc", "\\\\blacktriangledown");
//   defineSymbol(math, ams, textord, "\\u25a0", "\\\\blacksquare");
//   defineSymbol(math, ams, textord, "\\u29eb", "\\\\blacklozenge");
//   defineSymbol(math, ams, textord, "\\u2605", "\\\\bigstar");
//   defineSymbol(math, ams, textord, "\\u2222", "\\\\sphericalangle", true);
//   defineSymbol(math, ams, textord, "\\u2201", "\\\\complement", true);
//   defineSymbol(math, ams, textord, "\\u00f0", "\\\\eth", true);
//   defineSymbol(text, main, textord, "\\u00f0", "\\u00f0");
//   defineSymbol(math, ams, textord, "\\u2571", "\\\\diagup");
//   defineSymbol(math, ams, textord, "\\u2572", "\\\\diagdown");
//   defineSymbol(math, ams, textord, "\\u25a1", "\\\\square");
//   defineSymbol(math, ams, textord, "\\u25a1", "\\\\Box");
//   defineSymbol(math, ams, textord, "\\u25ca", "\\\\Diamond");
//   defineSymbol(math, ams, textord, "\\u00a5", "\\\\yen", true);
//   defineSymbol(text, ams, textord, "\\u00a5", "\\\\yen", true);
//   defineSymbol(math, ams, textord, "\\u2713", "\\\\checkmark", true);
//   defineSymbol(text, ams, textord, "\\u2713", "\\\\checkmark");
//   defineSymbol(math, ams, textord, "\\u2136", "\\\\beth", true);
//   defineSymbol(math, ams, textord, "\\u2138", "\\\\daleth", true);
//   defineSymbol(math, ams, textord, "\\u2137", "\\\\gimel", true);
//   defineSymbol(math, ams, textord, "\\u03dd", "\\\\digamma", true);
//   defineSymbol(math, ams, textord, "\\u03f0", "\\\\varkappa");
//   defineSymbol(math, ams, open, "\\u250c", "\\\\@ulcorner", true);
//   defineSymbol(math, ams, close, "\\u2510", "\\\\@urcorner", true);
//   defineSymbol(math, ams, open, "\\u2514", "\\\\@llcorner", true);
//   defineSymbol(math, ams, close, "\\u2518", "\\\\@lrcorner", true);
//   defineSymbol(math, ams, rel, "\\u2266", "\\\\leqq", true);
//   defineSymbol(math, ams, rel, "\\u2a7d", "\\\\leqslant", true);
//   defineSymbol(math, ams, rel, "\\u2a95", "\\\\eqslantless", true);
//   defineSymbol(math, ams, rel, "\\u2272", "\\\\lesssim", true);
//   defineSymbol(math, ams, rel, "\\u2a85", "\\\\lessapprox", true);
//   defineSymbol(math, ams, rel, "\\u224a", "\\\\approxeq", true);
//   defineSymbol(math, ams, bin, "\\u22d6", "\\\\lessdot");
//   defineSymbol(math, ams, rel, "\\u22d8", "\\\\lll", true);
//   defineSymbol(math, ams, rel, "\\u2276", "\\\\lessgtr", true);
//   defineSymbol(math, ams, rel, "\\u22da", "\\\\lesseqgtr", true);
//   defineSymbol(math, ams, rel, "\\u2a8b", "\\\\lesseqqgtr", true);
//   defineSymbol(math, ams, rel, "\\u2251", "\\\\doteqdot");
//   defineSymbol(math, ams, rel, "\\u2253", "\\\\risingdotseq", true);
//   defineSymbol(math, ams, rel, "\\u2252", "\\\\fallingdotseq", true);
//   defineSymbol(math, ams, rel, "\\u223d", "\\\\backsim", true);
//   defineSymbol(math, ams, rel, "\\u22cd", "\\\\backsimeq", true);
//   defineSymbol(math, ams, rel, "\\u2ac5", "\\\\subseteqq", true);
//   defineSymbol(math, ams, rel, "\\u22d0", "\\\\Subset", true);
//   defineSymbol(math, ams, rel, "\\u228f", "\\\\sqsubset", true);
//   defineSymbol(math, ams, rel, "\\u227c", "\\\\preccurlyeq", true);
//   defineSymbol(math, ams, rel, "\\u22de", "\\\\curlyeqprec", true);
//   defineSymbol(math, ams, rel, "\\u227e", "\\\\precsim", true);
//   defineSymbol(math, ams, rel, "\\u2ab7", "\\\\precapprox", true);
//   defineSymbol(math, ams, rel, "\\u22b2", "\\\\vartriangleleft");
//   defineSymbol(math, ams, rel, "\\u22b4", "\\\\trianglelefteq");
//   defineSymbol(math, ams, rel, "\\u22a8", "\\\\vDash", true);
//   defineSymbol(math, ams, rel, "\\u22aa", "\\\\Vvdash", true);
//   defineSymbol(math, ams, rel, "\\u2323", "\\\\smallsmile");
//   defineSymbol(math, ams, rel, "\\u2322", "\\\\smallfrown");
//   defineSymbol(math, ams, rel, "\\u224f", "\\\\bumpeq", true);
//   defineSymbol(math, ams, rel, "\\u224e", "\\\\Bumpeq", true);
//   defineSymbol(math, ams, rel, "\\u2267", "\\\\geqq", true);
//   defineSymbol(math, ams, rel, "\\u2a7e", "\\\\geqslant", true);
//   defineSymbol(math, ams, rel, "\\u2a96", "\\\\eqslantgtr", true);
//   defineSymbol(math, ams, rel, "\\u2273", "\\\\gtrsim", true);
//   defineSymbol(math, ams, rel, "\\u2a86", "\\\\gtrapprox", true);
//   defineSymbol(math, ams, bin, "\\u22d7", "\\\\gtrdot");
//   defineSymbol(math, ams, rel, "\\u22d9", "\\\\ggg", true);
//   defineSymbol(math, ams, rel, "\\u2277", "\\\\gtrless", true);
//   defineSymbol(math, ams, rel, "\\u22db", "\\\\gtreqless", true);
//   defineSymbol(math, ams, rel, "\\u2a8c", "\\\\gtreqqless", true);
//   defineSymbol(math, ams, rel, "\\u2256", "\\\\eqcirc", true);
//   defineSymbol(math, ams, rel, "\\u2257", "\\\\circeq", true);
//   defineSymbol(math, ams, rel, "\\u225c", "\\\\triangleq", true);
//   defineSymbol(math, ams, rel, "\\u223c", "\\\\thicksim");
//   defineSymbol(math, ams, rel, "\\u2248", "\\\\thickapprox");
//   defineSymbol(math, ams, rel, "\\u2ac6", "\\\\supseteqq", true);
//   defineSymbol(math, ams, rel, "\\u22d1", "\\\\Supset", true);
//   defineSymbol(math, ams, rel, "\\u2290", "\\\\sqsupset", true);
//   defineSymbol(math, ams, rel, "\\u227d", "\\\\succcurlyeq", true);
//   defineSymbol(math, ams, rel, "\\u22df", "\\\\curlyeqsucc", true);
//   defineSymbol(math, ams, rel, "\\u227f", "\\\\succsim", true);
//   defineSymbol(math, ams, rel, "\\u2ab8", "\\\\succapprox", true);
//   defineSymbol(math, ams, rel, "\\u22b3", "\\\\vartriangleright");
//   defineSymbol(math, ams, rel, "\\u22b5", "\\\\trianglerighteq");
//   defineSymbol(math, ams, rel, "\\u22a9", "\\\\Vdash", true);
//   defineSymbol(math, ams, rel, "\\u2223", "\\\\shortmid");
//   defineSymbol(math, ams, rel, "\\u2225", "\\\\shortparallel");
//   defineSymbol(math, ams, rel, "\\u226c", "\\\\between", true);
//   defineSymbol(math, ams, rel, "\\u22d4", "\\\\pitchfork", true);
//   defineSymbol(math, ams, rel, "\\u221d", "\\\\varpropto");
//   defineSymbol(math, ams, rel, "\\u25c0", "\\\\blacktriangleleft");
//   defineSymbol(math, ams, rel, "\\u2234", "\\\\therefore", true);
//   defineSymbol(math, ams, rel, "\\u220d", "\\\\backepsilon");
//   defineSymbol(math, ams, rel, "\\u25b6", "\\\\blacktriangleright");
//   defineSymbol(math, ams, rel, "\\u2235", "\\\\because", true);
//   defineSymbol(math, ams, rel, "\\u22d8", "\\\\llless");
//   defineSymbol(math, ams, rel, "\\u22d9", "\\\\gggtr");
//   defineSymbol(math, ams, bin, "\\u22b2", "\\\\lhd");
//   defineSymbol(math, ams, bin, "\\u22b3", "\\\\rhd");
//   defineSymbol(math, ams, rel, "\\u2242", "\\\\eqsim", true);
//   defineSymbol(math, main, rel, "\\u22c8", "\\\\Join");
//   defineSymbol(math, ams, rel, "\\u2251", "\\\\Doteq", true);
//   defineSymbol(math, ams, bin, "\\u2214", "\\\\dotplus", true);
//   defineSymbol(math, ams, bin, "\\u2216", "\\\\smallsetminus");
//   defineSymbol(math, ams, bin, "\\u22d2", "\\\\Cap", true);
//   defineSymbol(math, ams, bin, "\\u22d3", "\\\\Cup", true);
//   defineSymbol(math, ams, bin, "\\u2a5e", "\\\\doublebarwedge", true);
//   defineSymbol(math, ams, bin, "\\u229f", "\\\\boxminus", true);
//   defineSymbol(math, ams, bin, "\\u229e", "\\\\boxplus", true);
//   defineSymbol(math, ams, bin, "\\u22c7", "\\\\divideontimes", true);
//   defineSymbol(math, ams, bin, "\\u22c9", "\\\\ltimes", true);
//   defineSymbol(math, ams, bin, "\\u22ca", "\\\\rtimes", true);
//   defineSymbol(math, ams, bin, "\\u22cb", "\\\\leftthreetimes", true);
//   defineSymbol(math, ams, bin, "\\u22cc", "\\\\rightthreetimes", true);
//   defineSymbol(math, ams, bin, "\\u22cf", "\\\\curlywedge", true);
//   defineSymbol(math, ams, bin, "\\u22ce", "\\\\curlyvee", true);
//   defineSymbol(math, ams, bin, "\\u229d", "\\\\circleddash", true);
//   defineSymbol(math, ams, bin, "\\u229b", "\\\\circledast", true);
//   defineSymbol(math, ams, bin, "\\u22c5", "\\\\centerdot");
//   defineSymbol(math, ams, bin, "\\u22ba", "\\\\intercal", true);
//   defineSymbol(math, ams, bin, "\\u22d2", "\\\\doublecap");
//   defineSymbol(math, ams, bin, "\\u22d3", "\\\\doublecup");
//   defineSymbol(math, ams, bin, "\\u22a0", "\\\\boxtimes", true);
//   defineSymbol(math, ams, rel, "\\u21e2", "\\\\dashrightarrow", true);
//   defineSymbol(math, ams, rel, "\\u21e0", "\\\\dashleftarrow", true);
//   defineSymbol(math, ams, rel, "\\u21c7", "\\\\leftleftarrows", true);
//   defineSymbol(math, ams, rel, "\\u21c6", "\\\\leftrightarrows", true);
//   defineSymbol(math, ams, rel, "\\u21da", "\\\\Lleftarrow", true);
//   defineSymbol(math, ams, rel, "\\u219e", "\\\\twoheadleftarrow", true);
//   defineSymbol(math, ams, rel, "\\u21a2", "\\\\leftarrowtail", true);
//   defineSymbol(math, ams, rel, "\\u21ab", "\\\\looparrowleft", true);
//   defineSymbol(math, ams, rel, "\\u21cb", "\\\\leftrightharpoons", true);
//   defineSymbol(math, ams, rel, "\\u21b6", "\\\\curvearrowleft", true);
//   defineSymbol(math, ams, rel, "\\u21ba", "\\\\circlearrowleft", true);
//   defineSymbol(math, ams, rel, "\\u21b0", "\\\\Lsh", true);
//   defineSymbol(math, ams, rel, "\\u21c8", "\\\\upuparrows", true);
//   defineSymbol(math, ams, rel, "\\u21bf", "\\\\upharpoonleft", true);
//   defineSymbol(math, ams, rel, "\\u21c3", "\\\\downharpoonleft", true);
//   defineSymbol(math, ams, rel, "\\u22b8", "\\\\multimap", true);
//   defineSymbol(math, ams, rel, "\\u21ad", "\\\\leftrightsquigarrow", true);
//   defineSymbol(math, ams, rel, "\\u21c9", "\\\\rightrightarrows", true);
//   defineSymbol(math, ams, rel, "\\u21c4", "\\\\rightleftarrows", true);
//   defineSymbol(math, ams, rel, "\\u21a0", "\\\\twoheadrightarrow", true);
//   defineSymbol(math, ams, rel, "\\u21a3", "\\\\rightarrowtail", true);
//   defineSymbol(math, ams, rel, "\\u21ac", "\\\\looparrowright", true);
//   defineSymbol(math, ams, rel, "\\u21b7", "\\\\curvearrowright", true);
//   defineSymbol(math, ams, rel, "\\u21bb", "\\\\circlearrowright", true);
//   defineSymbol(math, ams, rel, "\\u21b1", "\\\\Rsh", true);
//   defineSymbol(math, ams, rel, "\\u21ca", "\\\\downdownarrows", true);
//   defineSymbol(math, ams, rel, "\\u21be", "\\\\upharpoonright", true);
//   defineSymbol(math, ams, rel, "\\u21c2", "\\\\downharpoonright", true);
//   defineSymbol(math, ams, rel, "\\u21dd", "\\\\rightsquigarrow", true);
//   defineSymbol(math, ams, rel, "\\u21dd", "\\\\leadsto");
//   defineSymbol(math, ams, rel, "\\u21db", "\\\\Rrightarrow", true);
//   defineSymbol(math, ams, rel, "\\u21be", "\\\\restriction");
//   defineSymbol(math, main, textord, "\\u2018", "`");
//   defineSymbol(math, main, textord, "\\\$", "\\\\\\\$");
//   defineSymbol(text, main, textord, "\\\$", "\\\\\\\$");
//   defineSymbol(text, main, textord, "\\\$", "\\\\textdollar");
//   defineSymbol(math, main, textord, "%", "\\\\%");
//   defineSymbol(text, main, textord, "%", "\\\\%");
//   defineSymbol(math, main, textord, "_", "\\\\_");
//   defineSymbol(text, main, textord, "_", "\\\\_");
//   defineSymbol(text, main, textord, "_", "\\\\textunderscore");
//   defineSymbol(math, main, textord, "\\u2220", "\\\\angle", true);
//   defineSymbol(math, main, textord, "\\u221e", "\\\\infty", true);
//   defineSymbol(math, main, textord, "\\u2032", "\\\\prime");
//   defineSymbol(math, main, textord, "\\u25b3", "\\\\triangle");
//   defineSymbol(math, main, textord, "\\u0393", "\\\\Gamma", true);
//   defineSymbol(math, main, textord, "\\u0394", "\\\\Delta", true);
//   defineSymbol(math, main, textord, "\\u0398", "\\\\Theta", true);
//   defineSymbol(math, main, textord, "\\u039b", "\\\\Lambda", true);
//   defineSymbol(math, main, textord, "\\u039e", "\\\\Xi", true);
//   defineSymbol(math, main, textord, "\\u03a0", "\\\\Pi", true);
//   defineSymbol(math, main, textord, "\\u03a3", "\\\\Sigma", true);
//   defineSymbol(math, main, textord, "\\u03a5", "\\\\Upsilon", true);
//   defineSymbol(math, main, textord, "\\u03a6", "\\\\Phi", true);
//   defineSymbol(math, main, textord, "\\u03a8", "\\\\Psi", true);
//   defineSymbol(math, main, textord, "\\u03a9", "\\\\Omega", true);
//   defineSymbol(math, main, textord, "A", "\\u0391");
//   defineSymbol(math, main, textord, "B", "\\u0392");
//   defineSymbol(math, main, textord, "E", "\\u0395");
//   defineSymbol(math, main, textord, "Z", "\\u0396");
//   defineSymbol(math, main, textord, "H", "\\u0397");
//   defineSymbol(math, main, textord, "I", "\\u0399");
//   defineSymbol(math, main, textord, "K", "\\u039A");
//   defineSymbol(math, main, textord, "M", "\\u039C");
//   defineSymbol(math, main, textord, "N", "\\u039D");
//   defineSymbol(math, main, textord, "O", "\\u039F");
//   defineSymbol(math, main, textord, "P", "\\u03A1");
//   defineSymbol(math, main, textord, "T", "\\u03A4");
//   defineSymbol(math, main, textord, "X", "\\u03A7");
//   defineSymbol(math, main, textord, "\\u00ac", "\\\\neg", true);
//   defineSymbol(math, main, textord, "\\u00ac", "\\\\lnot");
//   defineSymbol(math, main, textord, "\\u22a4", "\\\\top");
//   defineSymbol(math, main, textord, "\\u22a5", "\\\\bot");
//   defineSymbol(math, main, textord, "\\u2205", "\\\\emptyset");
//   defineSymbol(math, ams, textord, "\\u2205", "\\\\varnothing");
//   defineSymbol(math, main, mathord, "\\u03b1", "\\\\alpha", true);
//   defineSymbol(math, main, mathord, "\\u03b2", "\\\\beta", true);
//   defineSymbol(math, main, mathord, "\\u03b3", "\\\\gamma", true);
//   defineSymbol(math, main, mathord, "\\u03b4", "\\\\delta", true);
//   defineSymbol(math, main, mathord, "\\u03f5", "\\\\epsilon", true);
//   defineSymbol(math, main, mathord, "\\u03b6", "\\\\zeta", true);
//   defineSymbol(math, main, mathord, "\\u03b7", "\\\\eta", true);
//   defineSymbol(math, main, mathord, "\\u03b8", "\\\\theta", true);
//   defineSymbol(math, main, mathord, "\\u03b9", "\\\\iota", true);
//   defineSymbol(math, main, mathord, "\\u03ba", "\\\\kappa", true);
//   defineSymbol(math, main, mathord, "\\u03bb", "\\\\lambda", true);
//   defineSymbol(math, main, mathord, "\\u03bc", "\\\\mu", true);
//   defineSymbol(math, main, mathord, "\\u03bd", "\\\\nu", true);
//   defineSymbol(math, main, mathord, "\\u03be", "\\\\xi", true);
//   defineSymbol(math, main, mathord, "\\u03bf", "\\\\omicron", true);
//   defineSymbol(math, main, mathord, "\\u03c0", "\\\\pi", true);
//   defineSymbol(math, main, mathord, "\\u03c1", "\\\\rho", true);
//   defineSymbol(math, main, mathord, "\\u03c3", "\\\\sigma", true);
//   defineSymbol(math, main, mathord, "\\u03c4", "\\\\tau", true);
//   defineSymbol(math, main, mathord, "\\u03c5", "\\\\upsilon", true);
//   defineSymbol(math, main, mathord, "\\u03d5", "\\\\phi", true);
//   defineSymbol(math, main, mathord, "\\u03c7", "\\\\chi", true);
//   defineSymbol(math, main, mathord, "\\u03c8", "\\\\psi", true);
//   defineSymbol(math, main, mathord, "\\u03c9", "\\\\omega", true);
//   defineSymbol(math, main, mathord, "\\u03b5", "\\\\varepsilon", true);
//   defineSymbol(math, main, mathord, "\\u03d1", "\\\\vartheta", true);
//   defineSymbol(math, main, mathord, "\\u03d6", "\\\\varpi", true);
//   defineSymbol(math, main, mathord, "\\u03f1", "\\\\varrho", true);
//   defineSymbol(math, main, mathord, "\\u03c2", "\\\\varsigma", true);
//   defineSymbol(math, main, mathord, "\\u03c6", "\\\\varphi", true);
//   defineSymbol(math, main, bin, "\\u2217", "*");
//   defineSymbol(math, main, bin, "+", "+");
//   defineSymbol(math, main, bin, "\\u2212", "-");
//   defineSymbol(math, main, bin, "\\u22c5", "\\\\cdot", true);
//   defineSymbol(math, main, bin, "\\u2218", "\\\\circ");
//   defineSymbol(math, main, bin, "\\u00f7", "\\\\div", true);
//   defineSymbol(math, main, bin, "\\u00b1", "\\\\pm", true);
//   defineSymbol(math, main, bin, "\\u00d7", "\\\\times", true);
//   defineSymbol(math, main, bin, "\\u2229", "\\\\cap", true);
//   defineSymbol(math, main, bin, "\\u222a", "\\\\cup", true);
//   defineSymbol(math, main, bin, "\\u2216", "\\\\setminus");
//   defineSymbol(math, main, bin, "\\u2227", "\\\\land");
//   defineSymbol(math, main, bin, "\\u2228", "\\\\lor");
//   defineSymbol(math, main, bin, "\\u2227", "\\\\wedge", true);
//   defineSymbol(math, main, bin, "\\u2228", "\\\\vee", true);
//   defineSymbol(math, main, textord, "\\u221a", "\\\\surd");
//   defineSymbol(math, main, open, "\\u27e8", "\\\\langle", true);
//   defineSymbol(math, main, open, "\\u2223", "\\\\lvert");
//   defineSymbol(math, main, open, "\\u2225", "\\\\lVert");
//   defineSymbol(math, main, close, "?", "?");
//   defineSymbol(math, main, close, "!", "!");
//   defineSymbol(math, main, close, "\\u27e9", "\\\\rangle", true);
//   defineSymbol(math, main, close, "\\u2223", "\\\\rvert");
//   defineSymbol(math, main, close, "\\u2225", "\\\\rVert");
//   defineSymbol(math, main, rel, "=", "=");
//   defineSymbol(math, main, rel, ":", ":");
//   defineSymbol(math, main, rel, "\\u2248", "\\\\approx", true);
//   defineSymbol(math, main, rel, "\\u2245", "\\\\cong", true);
//   defineSymbol(math, main, rel, "\\u2265", "\\\\ge");
//   defineSymbol(math, main, rel, "\\u2265", "\\\\geq", true);
//   defineSymbol(math, main, rel, "\\u2190", "\\\\gets");
//   defineSymbol(math, main, rel, ">", "\\\\gt", true);
//   defineSymbol(math, main, rel, "\\u2208", "\\\\in", true);
//   defineSymbol(math, main, rel, "\\u2209", "\\\\notin", true);
//   defineSymbol(math, main, rel, "\\ue020", "\\\\@not");
//   defineSymbol(math, main, rel, "\\u2282", "\\\\subset", true);
//   defineSymbol(math, main, rel, "\\u2283", "\\\\supset", true);
//   defineSymbol(math, main, rel, "\\u2284", "\\\\nsubset", true);
//   defineSymbol(math, main, rel, "\\u2286", "\\\\subseteq", true);
//   defineSymbol(math, main, rel, "\\u2287", "\\\\supseteq", true);
//   defineSymbol(math, ams, rel, "\\u2288", "\\\\nsubseteq", true);
//   defineSymbol(math, ams, rel, "\\u2289", "\\\\nsupseteq", true);
//   defineSymbol(math, main, rel, "\\u22a8", "\\\\models");
//   defineSymbol(math, main, rel, "\\u2190", "\\\\leftarrow", true);
//   defineSymbol(math, main, rel, "\\u2264", "\\\\le");
//   defineSymbol(math, main, rel, "\\u2264", "\\\\leq", true);
//   defineSymbol(math, main, rel, "<", "\\\\lt", true);
//   defineSymbol(math, main, rel, "\\u2192", "\\\\rightarrow", true);
//   defineSymbol(math, main, rel, "\\u2192", "\\\\to");
//   defineSymbol(math, ams, rel, "\\u2271", "\\\\ngeq", true);
//   defineSymbol(math, ams, rel, "\\u2270", "\\\\nleq", true);
//   defineSymbol(math, main, spacing, "\\u00a0", "\\\\ ");
//   defineSymbol(math, main, spacing, "\\u00a0", "~");
//   defineSymbol(math, main, spacing, "\\u00a0", "\\\\space");
//   defineSymbol(math, main, spacing, "\\u00a0", "\\\\nobreakspace");
//   defineSymbol(text, main, spacing, "\\u00a0", "\\\\ ");
//   defineSymbol(text, main, spacing, "\\u00a0", " ");
//   defineSymbol(text, main, spacing, "\\u00a0", "~");
//   defineSymbol(text, main, spacing, "\\u00a0", "\\\\space");
//   defineSymbol(text, main, spacing, "\\u00a0", "\\\\nobreakspace");
//   defineSymbol(math, main, spacing, null, "\\\\nobreak");
//   defineSymbol(math, main, spacing, null, "\\\\allowbreak");
//   defineSymbol(math, main, punct, ",", ",");
//   defineSymbol(math, main, punct, ";", ";");
//   defineSymbol(math, ams, bin, "\\u22bc", "\\\\barwedge", true);
//   defineSymbol(math, ams, bin, "\\u22bb", "\\\\veebar", true);
//   defineSymbol(math, main, bin, "\\u2299", "\\\\odot", true);
//   defineSymbol(math, main, bin, "\\u2295", "\\\\oplus", true);
//   defineSymbol(math, main, bin, "\\u2297", "\\\\otimes", true);
//   defineSymbol(math, main, textord, "\\u2202", "\\\\partial", true);
//   defineSymbol(math, main, bin, "\\u2298", "\\\\oslash", true);
//   defineSymbol(math, ams, bin, "\\u229a", "\\\\circledcirc", true);
//   defineSymbol(math, ams, bin, "\\u22a1", "\\\\boxdot", true);
//   defineSymbol(math, main, bin, "\\u25b3", "\\\\bigtriangleup");
//   defineSymbol(math, main, bin, "\\u25bd", "\\\\bigtriangledown");
//   defineSymbol(math, main, bin, "\\u2020", "\\\\dagger");
//   defineSymbol(math, main, bin, "\\u22c4", "\\\\diamond");
//   defineSymbol(math, main, bin, "\\u22c6", "\\\\star");
//   defineSymbol(math, main, bin, "\\u25c3", "\\\\triangleleft");
//   defineSymbol(math, main, bin, "\\u25b9", "\\\\triangleright");
//   defineSymbol(math, main, open, "{", "\\\\{");
//   defineSymbol(text, main, textord, "{", "\\\\{");
//   defineSymbol(text, main, textord, "{", "\\\\textbraceleft");
//   defineSymbol(math, main, close, "}", "\\\\}");
//   defineSymbol(text, main, textord, "}", "\\\\}");
//   defineSymbol(text, main, textord, "}", "\\\\textbraceright");
//   defineSymbol(math, main, open, "{", "\\\\lbrace");
//   defineSymbol(math, main, close, "}", "\\\\rbrace");
//   defineSymbol(math, main, open, "[", "\\\\lbrack", true);
//   defineSymbol(text, main, textord, "[", "\\\\lbrack", true);
//   defineSymbol(math, main, close, "]", "\\\\rbrack", true);
//   defineSymbol(text, main, textord, "]", "\\\\rbrack", true);
//   defineSymbol(math, main, open, "(", "\\\\lparen", true);
//   defineSymbol(math, main, close, ")", "\\\\rparen", true);
//   defineSymbol(text, main, textord, "<", "\\\\textless", true); // in T1 fontenc
//   defineSymbol(
//       text, main, textord, ">", "\\\\textgreater", true); // in T1 fontenc
//   defineSymbol(math, main, open, "\\u230a", "\\\\lfloor", true);
//   defineSymbol(math, main, close, "\\u230b", "\\\\rfloor", true);
//   defineSymbol(math, main, open, "\\u2308", "\\\\lceil", true);
//   defineSymbol(math, main, close, "\\u2309", "\\\\rceil", true);
//   defineSymbol(math, main, textord, "\\\\", "\\\\backslash");
//   defineSymbol(math, main, textord, "\\u2223", "|");
//   defineSymbol(math, main, textord, "\\u2223", "\\\\vert");
//   defineSymbol(text, main, textord, "|", "\\\\textbar", true); // in T1 fontenc
//   defineSymbol(math, main, textord, "\\u2225", "\\\\|");
//   defineSymbol(math, main, textord, "\\u2225", "\\\\Vert");
//   defineSymbol(text, main, textord, "\\u2225", "\\\\textbardbl");
//   defineSymbol(text, main, textord, "~", "\\\\textasciitilde");
//   defineSymbol(text, main, textord, "\\\\", "\\\\textbackslash");
//   defineSymbol(text, main, textord, "^", "\\\\textasciicircum");
//   defineSymbol(math, main, rel, "\\u2191", "\\\\uparrow", true);
//   defineSymbol(math, main, rel, "\\u21d1", "\\\\Uparrow", true);
//   defineSymbol(math, main, rel, "\\u2193", "\\\\downarrow", true);
//   defineSymbol(math, main, rel, "\\u21d3", "\\\\Downarrow", true);
//   defineSymbol(math, main, rel, "\\u2195", "\\\\updownarrow", true);
//   defineSymbol(math, main, rel, "\\u21d5", "\\\\Updownarrow", true);
//   defineSymbol(math, main, op, "\\u2210", "\\\\coprod");
//   defineSymbol(math, main, op, "\\u22c1", "\\\\bigvee");
//   defineSymbol(math, main, op, "\\u22c0", "\\\\bigwedge");
//   defineSymbol(math, main, op, "\\u2a04", "\\\\biguplus");
//   defineSymbol(math, main, op, "\\u22c2", "\\\\bigcap");
//   defineSymbol(math, main, op, "\\u22c3", "\\\\bigcup");
//   defineSymbol(math, main, op, "\\u222b", "\\\\int");
//   defineSymbol(math, main, op, "\\u222b", "\\\\intop");
//   defineSymbol(math, main, op, "\\u222c", "\\\\iint");
//   defineSymbol(math, main, op, "\\u222d", "\\\\iiint");
//   defineSymbol(math, main, op, "\\u220f", "\\\\prod");
//   defineSymbol(math, main, op, "\\u2211", "\\\\sum");
//   defineSymbol(math, main, op, "\\u2a02", "\\\\bigotimes");
//   defineSymbol(math, main, op, "\\u2a01", "\\\\bigoplus");
//   defineSymbol(math, main, op, "\\u2a00", "\\\\bigodot");
//   defineSymbol(math, main, op, "\\u222e", "\\\\oint");
//   defineSymbol(math, main, op, "\\u2a06", "\\\\bigsqcup");
//   defineSymbol(math, main, op, "\\u222b", "\\\\smallint");
//   defineSymbol(text, main, inner, "\\u2026", "\\\\textellipsis");
//   defineSymbol(math, main, inner, "\\u2026", "\\\\mathellipsis");
//   defineSymbol(text, main, inner, "\\u2026", "\\\\ldots", true);
//   defineSymbol(math, main, inner, "\\u2026", "\\\\ldots", true);
//   defineSymbol(math, main, inner, "\\u22ef", "\\\\@cdots", true);
//   defineSymbol(math, main, inner, "\\u22f1", "\\\\ddots", true);
//   defineSymbol(
//       math, main, textord, "\\u22ee", "\\\\varvdots"); // \\vdots is a macro
//   defineSymbol(math, main, accent, "\\u02ca", "\\\\acute");
//   defineSymbol(math, main, accent, "\\u02cb", "\\\\grave");
//   defineSymbol(math, main, accent, "\\u00a8", "\\\\ddot");
//   defineSymbol(math, main, accent, "\\u007e", "\\\\tilde");
//   defineSymbol(math, main, accent, "\\u02c9", "\\\\bar");
//   defineSymbol(math, main, accent, "\\u02d8", "\\\\breve");
//   defineSymbol(math, main, accent, "\\u02c7", "\\\\check");
//   defineSymbol(math, main, accent, "\\u005e", "\\\\hat");
//   defineSymbol(math, main, accent, "\\u20d7", "\\\\vec");
//   defineSymbol(math, main, accent, "\\u02d9", "\\\\dot");
//   defineSymbol(math, main, accent, "\\u02da", "\\\\mathring");
//   defineSymbol(math, main, mathord, "\\u0131", "\\\\imath", true);
//   defineSymbol(math, main, mathord, "\\u0237", "\\\\jmath", true);
//   defineSymbol(text, main, textord, "\\u0131", "\\\\i", true);
//   defineSymbol(text, main, textord, "\\u0237", "\\\\j", true);
//   defineSymbol(text, main, textord, "\\u00df", "\\\\ss", true);
//   defineSymbol(text, main, textord, "\\u00e6", "\\\\ae", true);
//   defineSymbol(text, main, textord, "\\u0153", "\\\\oe", true);
//   defineSymbol(text, main, textord, "\\u00f8", "\\\\o", true);
//   defineSymbol(text, main, textord, "\\u00c6", "\\\\AE", true);
//   defineSymbol(text, main, textord, "\\u0152", "\\\\OE", true);
//   defineSymbol(text, main, textord, "\\u00d8", "\\\\O", true);
//   defineSymbol(text, main, accent, "\\u02ca", "\\\\'"); // acute
//   defineSymbol(text, main, accent, "\\u02cb", "\\\\`"); // grave
//   defineSymbol(text, main, accent, "\\u02c6", "\\\\^"); // circumflex
//   defineSymbol(text, main, accent, "\\u02dc", "\\\\~"); // tilde
//   defineSymbol(text, main, accent, "\\u02c9", "\\\\="); // macron
//   defineSymbol(text, main, accent, "\\u02d8", "\\\\u"); // breve
//   defineSymbol(text, main, accent, "\\u02d9", "\\\\."); // dot above
//   defineSymbol(text, main, accent, "\\u02da", "\\\\r"); // ring above
//   defineSymbol(text, main, accent, "\\u02c7", "\\\\v"); // caron
//   defineSymbol(text, main, accent, "\\u00a8", '\\\\"'); // diaresis
//   defineSymbol(text, main, accent, "\\u02dd", "\\\\H"); // double acute
//   defineSymbol(
//       text, main, accent, "\\u25ef", "\\\\textcircled"); // \\bigcirc glyph
//   defineSymbol(text, main, textord, "\\u2013", "--", true);
//   defineSymbol(text, main, textord, "\\u2013", "\\\\textendash");
//   defineSymbol(text, main, textord, "\\u2014", "---", true);
//   defineSymbol(text, main, textord, "\\u2014", "\\\\textemdash");
//   defineSymbol(text, main, textord, "\\u2018", "`", true);
//   defineSymbol(text, main, textord, "\\u2018", "\\\\textquoteleft");
//   defineSymbol(text, main, textord, "\\u2019", "'", true);
//   defineSymbol(text, main, textord, "\\u2019", "\\\\textquoteright");
//   defineSymbol(text, main, textord, "\\u201c", "``", true);
//   defineSymbol(text, main, textord, "\\u201c", "\\\\textquotedblleft");
//   defineSymbol(text, main, textord, "\\u201d", "''", true);
//   defineSymbol(text, main, textord, "\\u201d", "\\\\textquotedblright");
//   defineSymbol(math, main, textord, "\\u00b0", "\\\\degree", true);
//   defineSymbol(text, main, textord, "\\u00b0", "\\\\degree");
//   defineSymbol(text, main, textord, "\\u00b0", "\\\\textdegree", true);
//   defineSymbol(math, main, mathord, "\\u00a3", "\\\\pounds");
//   defineSymbol(math, main, mathord, "\\u00a3", "\\\\mathsterling", true);
//   defineSymbol(text, main, mathord, "\\u00a3", "\\\\pounds");
//   defineSymbol(text, main, mathord, "\\u00a3", "\\\\textsterling", true);
//   defineSymbol(math, ams, textord, "\\u2720", "\\\\maltese");
//   defineSymbol(text, ams, textord, "\\u2720", "\\\\maltese");
//
//   lines.addAll([
//     '  ${CaTeXMode.text}: {',
//     ...textSymbols,
//     '  },',
//     '  ${CaTeXMode.math}: {',
//     ...mathSymbols,
//     '  },',
//     '};\n',
//   ]);
//
//   await file.writeAsString(lines.join('\n'));
// }
//
// // ignore_for_file: prefer_single_quotes





//function,supported,frequency
//\frac,true,10743
//\cdot,true,8080
//\begin,false,4836
//\end,false,4836
//{align},false,0
//{aligned},false,0
//{array},false,0
//{matrix},false,0
//\left,false,2941
//\right,false,2939
//\textcolor,true,2929
//\Rightarrow,true,2547
//\vec,true,2047
//\sqrt,true,1402
//\approx,true,1336
//\color,false,1142
//\pi,true,922
//\alpha,true,789
//\prime,true,732
//\times,true,718
//\quad,false,715
//\rightarrow,true,702
//\enspace,false,622
//\text,true,580
//\circ,true,521
//\textrm,false,504
//\lambda,true,482
//\Leftrightarrow,true,480
//\in,true,450
//\sin,false,438
//\int,true,437
//\operatorname,false,431
//\dfrac,false,353
//\bar,false,315
//\cos,false,308
//\mu,true,296
//\vert,false,289
//\mathbb,false,277
//\big,false,270
//\mathbf,false,248
//\leq,true,245
//\textit,true,245
//\bigr,false,245
//\bigl,false,245
//\overset,false,213
//\pm,true,208
//\sigma,true,195
//\overrightarrow,false,179
//\infty,true,173
//\binom,false,171
//\rightleftharpoons,true,161
//\mathrm,false,152
//\ln,false,143
//\forall,false,143
//\beta,true,140
//\Omega,true,140
//\sum,false,128
//\geq,true,125
//\gamma,true,116
//\overline,false,115
//\Delta,true,114
//\omega,true,110
//\hat,trueish,103
//\varepsilon,true,101
//\textbf,true,93
//\lim,false,92
//\neq,false,91
//\cap,false,89
//\exists,false,85
//\xrightarrow,false,82
//\euro,false,81
//\underset,false,72
//\P,true,71
//\mid,true,70
//\Phi,true,69
//\ddot,false,63
//\limits,false,58
//\epsilon,true,57
//\v,false,56
//\delta,true,55
//\R,false,52
//\to,true,49
//\textup,true,46
//\underrightarrow,false,45
//\arctan,false,45
//\ss,false,43
//\newline,false,43
//\longrightarrow,false,42
//\neg,false,40
//\underline,false,40
//\backslash,true,38
//\tan,false,38
//\wedge,false,36
//\log,false,33
//\leftrightarrow,true,31
//\stackrel,false,29
//\min,false,27
//\varphi,true,27
//\arcsin,false,26
//\bold,false,23
//\div,true,20
//\sim,true,19
//\star,false,18
//\max,false,18
//\setminus,true,17
//\subseteq,false,16
//\qquad,false,13
//\Biggl,false,13
//\vee,false,13
//\N,false,12
//\C,false,11
//\rm,true,11
//\eta,true,10
//\arccos,false,10
//\degree,true,10
//\dots,false,9
//\ne,false,9
//\triangle,true,8
//\tau,true,8
//\small,false,8
//\cdots,false,7
//\partial,true,7
//\rfloor,false,7
//\tilde,false,7
//\lfloor,false,7
//\le,true,7
//\theta,true,6
//\displaystyle,true,6
//\notin,false,6
//\rho,true,6
//\phi,true,6
//\footnotesize,false,5
//\rceil,false,5
//\not,false,5
//\S,false,5
//\lceil,false,4
//\xLeftrightarrow,false,4
//\infin,true,4
//\bullet,true,4
//\overleftarrow,false,4
//\nexists,true,4
//\Theta,true,4
//\Big,false,4
//\mit,false,4
//\rangle,false,3
//\leftarrow,true,3
//\emptyset,false,3
//\dot,false,3
//\bmod,false,3
//\lg,false,3
//\Longrightarrow,true,3
//\uparrow,true,3
//\subset,false,3
//\ldots,true,3
//\Leftarrow,true,3
//\langle,false,3
//\rvert,false,2
//\varnothing,true,2
//\boxed,true,2
//\cup,false,2
//\succeq,false,2
//\prod,false,2
//\H,false,2
//\r,false,2
//\leftrightharpoons,true,2
//\thickapprox,true,2
//\bf,true,2
//\Z,false,2
//\ge,false,2
//\Q,false,2
//\bm,false,2
//\dotsc,false,2
//\mathcal,false,2
//\lvert,false,2
//\scriptsize,false,2
//\gt,true,1
//\tfrac,false,1
//\lbrace,false,1
//\bigcap,false,1
//\zeta,true,1
//\Longleftrightarrow,false,1
//\sqsubseteq,false,1
//\nsubseteq,false,1
//\imath,false,1
//\supseteq,false,1
//\supset,false,1
//\xrightleftharpoons,false,1
//\Re,false,1
//\nless,false,1
//\longleftrightarrow,false,1
//\downarrow,false,1
//\boldsymbol,false,1
//\exist,false,1
//\rightharpoonup,false,1
//\Bigl,false,1
//\Bigr,false,1
//\leftharpoondown,false,1
//\scriptstyle,true,1
//\u,false,1
//\!,false,0
//#,false,0
//\#,false,0
//%,false,0
//\%,false,0
//&,false,0
//\&,false,0
//',false,0
//\',false,0
//(,false,0
//),false,0
//\(…\),false,0
//\,false,0
//"\""",false,0
//\$,false,0
//"\,",false,0
//\.,false,0
//\:,false,0
//\;,false,0
//_,false,0
//\_,false,0
//\`,false,0
//<,false,0
//\=,false,0
//>,false,0
//\>,false,0
//[,false,0
//],false,0
//{,false,0
//},false,0
//\{,false,0
//\},false,0
//&#124;,false,0
//\&#124;,false,0
//~,false,0
//\~,false,0
//\|$\begin{matrix} a & b\ c & d\end{matrix}$,false,0
//^,false,0
//\^,false,0
//\AA,false,0
//\aa,false,0
//\above,false,0
//\abovewithdelims,false,0
//\acute,false,0
//\AE,false,0
//\ae,false,0
//\alef,false,0
//\alefsym,false,0
//\aleph,false,0
//{alignat},false,0
//{alignedat},false,0
//\allowbreak,false,0
//\Alpha,false,0
//\amalg,false,0
//\And,false,0
//\and,false,0
//\ang,false,0
//\angl,false,0
//\angle,false,0
//\approxeq,false,0
//\arcctg,false,0
//\arctg,false,0
//\arg,false,0
//\argmax,false,0
//\argmin,false,0
//\array,false,0
//\arraystretch,false,0
//\Arrowvert,false,0
//\arrowvert,false,0
//\ast,false,0
//\asymp,false,0
//\atop,false,0
//\atopwithdelims,false,0
//\backepsilon,false,0
//\backprime,false,0
//\backsim,false,0
//\backsimeq,false,0
//\barwedge,false,0
//\Bbb,false,0
//\Bbbk,false,0
//\bbox,false,0
//\bcancel,false,0
//\because,false,0
//\begingroup,false,0
//\Beta,false,0
//\beth,false,0
//\between,false,0
//\bfseries,false,0
//\bigcirc,false,0
//\bigcup,false,0
//\bigg,false,0
//\Bigg,false,0
//\biggl,false,0
//\biggm,false,0
//\Biggm,false,0
//\biggr,false,0
//\Biggr,false,0
//\bigm,false,0
//\Bigm,false,0
//\bigodot,false,0
//\bigominus,false,0
//\bigoplus,false,0
//\bigoslash,false,0
//\bigotimes,false,0
//\bigsqcap,false,0
//\bigsqcup,false,0
//\bigstar,false,0
//\bigtriangledown,false,0
//\bigtriangleup,false,0
//\biguplus,false,0
//\bigvee,false,0
//\bigwedge,false,0
//\blacklozenge,false,0
//\blacksquare,false,0
//\blacktriangle,false,0
//\blacktriangledown,false,0
//\blacktriangleleft,false,0
//\blacktriangleright,false,0
//{Bmatrix},false,0
//{bmatrix},false,0
//\bot,false,0
//\bowtie,false,0
//\Box,false,0
//\boxdot,false,0
//\boxminus,false,0
//\boxplus,false,0
//\boxtimes,false,0
//\Bra,false,0
//\bra,false,0
//\braket,false,0
//\brace,false,0
//\bracevert,false,0
//\brack,false,0
//\breve,false,0
//\buildrel,false,0
//\bull,false,0
//\Bumpeq,false,0
//\bumpeq,false,0
//\cal,true,0
//\cancel,true,0
//\cancelto,false,0
//\Cap,false,0
//{cases},false,0
//\cases,false,0
//{CD},false,0
//\cdotp,false,0
//\ce,false,0
//\cee,false,0
//\centerdot,false,0
//\cf,false,0
//\cfrac,false,0
//\check,false,0
//\ch,false,0
//\checkmark,false,0
//\Chi,false,0
//\chi,false,0
//\choose,false,0
//\circeq,false,0
//\circlearrowleft,false,0
//\circlearrowright,false,0
//\circledast,false,0
//\circledcirc,false,0
//\circleddash,false,0
//\circledR,false,0
//\circledS,false,0
//\class,false,0
//\cline,false,0
//\clubs,false,0
//\clubsuit,false,0
//\cnums,false,0
//\colon,false,0
//\Colonapprox,false,0
//\colonapprox,false,0
//\Coloneq,false,0
//\coloneq,false,0
//\Coloneqq,false,0
//\coloneqq,false,0
//\Colonsim,false,0
//\colonsim,false,0
//\colorbox,false,0
//\complement,false,0
//\Complex,false,0
//\cong,false,0
//\Coppa,false,0
//\coppa,false,0
//\coprod,false,0
//\copyright,false,0
//\cosec,false,0
//\cosh,false,0
//\cot,false,0
//\cotg,false,0
//\coth,false,0
//\cr,false,0
//\csc,false,0
//\cssId,false,0
//\ctg,false,0
//\cth,false,0
//\Cup,false,0
//\curlyeqprec,false,0
//\curlyeqsucc,false,0
//\curlyvee,false,0
//\curlywedge,false,0
//\curvearrowleft,false,0
//\curvearrowright,false,0
//\dag,false,0
//\Dagger,false,0
//\dagger,false,0
//\daleth,false,0
//\Darr,false,0
//\dArr,false,0
//\darr,false,0
//{darray},false,0
//\dashleftarrow,false,0
//\dashrightarrow,false,0
//\dashv,false,0
//\dbinom,false,0
//\dblcolon,false,0
//{dcases},false,0
//\ddag,false,0
//\ddagger,false,0
//\ddddot,false,0
//\dddot,false,0
//\ddots,false,0
//\DeclareMathOperator,false,0
//\def,false,0
//\definecolor,false,0
//\deg,false,0
//\det,false,0
//\Digamma,false,0
//\digamma,false,0
//\diagdown,false,0
//\diagup,false,0
//\Diamond,false,0
//\diamond,false,0
//\diamonds,false,0
//\diamondsuit,false,0
//\dim,false,0
//\displaylines,false,0
//\divideontimes,false,0
//\Doteq,false,0
//\doteq,false,0
//\doteqdot,false,0
//\dotplus,false,0
//\dotsb,false,0
//\dotsi,false,0
//\dotsm,false,0
//\dotso,false,0
//\doublebarwedge,false,0
//\doublecap,false,0
//\doublecup,false,0
//\Downarrow,false,0
//\downdownarrows,false,0
//\downharpoonleft,false,0
//\downharpoonright,false,0
//{drcases},false,0
//\edef,false,0
//\ell,false,0
//\else,false,0
//\em,false,0
//\emph,false,0
//\empty,false,0
//\enclose,false,0
//\endgroup,false,0
//\Epsilon,false,0
//\eqalign,false,0
//\eqalignno,false,0
//\eqcirc,false,0
//\Eqcolon,false,0
//\eqcolon,false,0
//{equation},false,0
//{eqnarray},false,0
//\Eqqcolon,false,0
//\eqqcolon,false,0
//\eqref,false,0
//\eqsim,false,0
//\eqslantgtr,false,0
//\eqslantless,false,0
//\equiv,false,0
//\Eta,false,0
//\eth,false,0
//\exp,false,0
//\expandafter,false,0
//\fallingdotseq,false,0
//\fbox,false,0
//\fcolorbox,false,0
//\fi,false,0
//\Finv,false,0
//\flat,false,0
//\frak,false,0
//\frown,false,0
//\futurelet,false,0
//\Game,false,0
//\Gamma,false,0
//{gather},false,0
//{gathered},false,0
//\gcd,false,0
//\gdef,false,0
//\geneuro,false,0
//\geneuronarrow,false,0
//\geneurowide,false,0
//\genfrac,false,0
//\geqq,false,0
//\geqslant,false,0
//\gets,false,0
//\gg,false,0
//\ggg,false,0
//\gggtr,false,0
//\gimel,false,0
//\global,false,0
//\gnapprox,false,0
//\gneq,false,0
//\gneqq,false,0
//\gnsim,false,0
//\grave,false,0
//\gtrdot,false,0
//\gtrapprox,false,0
//\gtreqless,false,0
//\gtreqqless,false,0
//\gtrless,false,0
//\gtrsim,false,0
//\gvertneqq,false,0
//\Harr,false,0
//\hArr,false,0
//\harr,false,0
//\hbar,false,0
//\hbox,false,0
//\hdashline,false,0
//\hearts,false,0
//\heartsuit,true,0
//\hfil,false,0
//\hfill,false,0
//\hline,false,0
//\hom,false,0
//\hookleftarrow,false,0
//\hookrightarrow,false,0
//\hphantom,false,0
//\href,false,0
//\hskip,false,0
//\hslash,false,0
//\hspace,false,0
//\htmlClass,false,0
//\htmlData,false,0
//\htmlId,false,0
//\htmlStyle,false,0
//\huge,false,0
//\Huge,false,0
//\i,false,0
//\idotsint,false,0
//\iddots,false,0
//\if,false,0
//\iff,false,0
//\ifmode,false,0
//\ifx,false,0
//\iiiint,false,0
//\iiint,false,0
//\iint,false,0
//\Im,false,0
//\image,false,0
//\impliedby,false,0
//\implies,false,0
//\includegraphics,false,0
//\inf,false,0
//\injlim,false,0
//\intercal,false,0
//\intop,false,0
//\Iota,false,0
//\iota,false,0
//\isin,false,0
//\it,true,0
//\itshape,false,0
//\j,false,0
//\jmath,false,0
//\Join,false,0
//\Kappa,false,0
//\kappa,false,0
//\KaTeX,true,0
//\CaTeX,true,0
//\ker,false,0
//\kern,true,0
//\Ket,false,0
//\ket,false,0
//\Koppa,false,0
//\koppa,false,0
//\L,false,0
//\l,false,0
//\Lambda,false,0
//\label,false,0
//\land,false,0
//\lang,false,0
//\Larr,false,0
//\lArr,false,0
//\larr,false,0
//\large,false,0
//\Large,false,0
//\LARGE,false,0
//\LaTeX,true,0
//\lBrace,false,0
//\lbrack,false,0
//\ldotp,false,0
//\leadsto,false,0
//\LeftArrow,false,0
//\leftarrowtail,false,0
//\leftharpoonup,false,0
//\leftleftarrows,false,0
//\leftrightarrows,false,0
//\leftrightsquigarrow,false,0
//\leftroot,false,0
//\leftthreetimes,false,0
//\leqalignno,false,0
//\leqq,false,0
//\leqslant,false,0
//\lessapprox,false,0
//\lessdot,false,0
//\lesseqgtr,false,0
//\lesseqqgtr,false,0
//\lessgtr,false,0
//\lesssim,false,0
//\let,false,0
//\lgroup,false,0
//\lhd,false,0
//\liminf,false,0
//\limsup,false,0
//\ll,false,0
//\llap,false,0
//\llbracket,false,0
//\llcorner,false,0
//\Lleftarrow,false,0
//\lll,false,0
//\llless,false,0
//\lmoustache,false,0
//\lnapprox,false,0
//\lneq,false,0
//\lneqq,false,0
//\lnot,false,0
//\lnsim,false,0
//\long,false,0
//\Longleftarrow,false,0
//\longleftarrow,false,0
//\longmapsto,false,0
//\looparrowleft,false,0
//\looparrowright,false,0
//\lor,false,0
//\lower,false,0
//\lozenge,false,0
//\lparen,false,0
//\Lrarr,false,0
//\lrArr,false,0
//\lrarr,false,0
//\lrcorner,false,0
//\lq,false,0
//\Lsh,false,0
//\lt,false,0
//\ltimes,false,0
//\lVert,false,0
//\lvertneqq,false,0
//\maltese,false,0
//\mapsto,false,0
//\mathbin,false,0
//\mathchoice,false,0
//\mathclap,false,0
//\mathclose,false,0
//\mathellipsis,false,0
//\mathfrak,false,0
//\mathinner,false,0
//\mathit,false,0
//\mathllap,false,0
//\mathnormal,false,0
//\mathop,false,0
//\mathopen,false,0
//\mathord,false,0
//\mathpunct,false,0
//\mathrel,false,0
//\mathrlap,false,0
//\mathring,false,0
//\mathscr,false,0
//\mathsf,false,0
//\mathsterling,false,0
//\mathstrut,false,0
//\mathtip,false,0
//\mathtt,false,0
//\matrix,false,0
//\mbox,false,0
//\md,false,0
//\mdseries,false,0
//\measuredangle,false,0
//\medspace,false,0
//\mho,false,0
//\middle,false,0
//\mkern,false,0
//\mmlToken,false,0
//\mod,false,0
//\models,false,0
//\moveleft,false,0
//\moveright,false,0
//\mp,false,0
//\mskip,false,0
//\mspace,false,0
//\Mu,false,0
//\multicolumn,false,0
//{multiline},false,0
//\multimap,false,0
//\nabla,false,0
//\natnums,false,0
//\natural,false,0
//\negmedspace,false,0
//\ncong,false,0
//\nearrow,false,0
//\negthickspace,false,0
//\negthinspace,false,0
//\newcommand,false,0
//\newenvironment,false,0
//\Newextarrow,false,0
//\ngeq,false,0
//\ngeqq,false,0
//\ngeqslant,false,0
//\ngtr,false,0
//\ni,false,0
//\nleftarrow,false,0
//\nLeftarrow,false,0
//\nLeftrightarrow,false,0
//\nleftrightarrow,false,0
//\nleq,false,0
//\nleqq,false,0
//\nleqslant,false,0
//\nmid,false,0
//\nobreak,false,0
//\nobreakspace,false,0
//\noexpand,false,0
//\nolimits,false,0
//\normalfont,false,0
//\normalsize,false,0
//\notag,false,0
//\notni,false,0
//\nparallel,false,0
//\nprec,false,0
//\npreceq,false,0
//\nRightarrow,false,0
//\nrightarrow,false,0
//\nshortmid,false,0
//\nshortparallel,false,0
//\nsim,false,0
//\nsubseteqq,false,0
//\nsucc,false,0
//\nsucceq,false,0
//\nsupseteq,false,0
//\nsupseteqq,false,0
//\ntriangleleft,false,0
//\ntrianglelefteq,false,0
//\ntriangleright,false,0
//\ntrianglerighteq,false,0
//\Nu,false,0
//\nu,false,0
//\nVDash,false,0
//\nVdash,false,0
//\nvDash,false,0
//\nvdash,false,0
//\nwarrow,false,0
//\O,false,0
//\o,false,0
//\odot,false,0
//\OE,false,0
//\oe,false,0
//\officialeuro,false,0
//\oiiint,false,0
//\oiint,false,0
//\oint,false,0
//\oldstyle,false,0
//\Omicron,false,0
//\omicron,false,0
//\ominus,false,0
//\oplus,false,0
//\or,false,0
//\oslash,false,0
//\otimes,false,0
//\over,false,0
//\overbrace,false,0
//\overbracket,false,0
//\overgroup,false,0
//\overleftharpoon,false,0
//\overleftrightarrow,false,0
//\overlinesegment,false,0
//\overparen,false,0
//\Overrightarrow,false,0
//\overrightharpoon,false,0
//\overwithdelims,false,0
//\owns,false,0
//\pagecolor,false,0
//\parallel,false,0
//\part,false,0
//\perp,true,0
//\phantom,false,0
//\phase,false,0
//\Pi,false,0
//{picture},false,0
//\pitchfork,false,0
//\plim,false,0
//\plusmn,false,0
//\pmatrix,false,0
//{pmatrix},false,0
//\pmb,false,0
//\pmod,false,0
//\pod,false,0
//\pounds,false,0
//\Pr,false,0
//\prec,false,0
//\precapprox,false,0
//\preccurlyeq,false,0
//\preceq,false,0
//\precnapprox,false,0
//\precneqq,false,0
//\precnsim,false,0
//\precsim,false,0
//\projlim,false,0
//\propto,false,0
//\providecommand,false,0
//\psi,false,0
//\Psi,false,0
//\pu,false,0
//\raise,false,0
//\raisebox,true,0
//\rang,false,0
//\Rarr,false,0
//\rArr,false,0
//\rarr,false,0
//\rBrace,false,0
//\rbrace,false,0
//\rbrack,false,0
//{rcases},false,0
//\real,false,0
//\Reals,false,0
//\reals,false,0
//\ref,false,0
//\relax,false,0
//\renewcommand,false,0
//\renewenvironment,false,0
//\require,false,0
//\restriction,false,0
//\rgroup,false,0
//\rhd,false,0
//\Rho,false,0
//\rightarrowtail,false,0
//\rightharpoondown,false,0
//\rightleftarrows,false,0
//\rightrightarrows,false,0
//\rightsquigarrow,false,0
//\rightthreetimes,false,0
//\risingdotseq,false,0
//\rlap,false,0
//\rmoustache,false,0
//\root,false,0
//\rotatebox,false,0
//\rparen,false,0
//\rq,false,0
//\rrbracket,false,0
//\Rrightarrow,false,0
//\Rsh,false,0
//\rtimes,false,0
//\Rule,false,0
//\rule,false,0
//\rVert,false,0
//\Sampi,false,0
//\sampi,false,0
//\sc,false,0
//\scalebox,false,0
//\scr,false,0
//\scriptscriptstyle,true,0
//\sdot,false,0
//\searrow,false,0
//\sec,false,0
//\sect,false,0
//\setlength,false,0
//\sf,true,0
//\sharp,false,0
//\shortmid,false,0
//\shortparallel,false,0
//\shoveleft,false,0
//\shoveright,false,0
//\sideset,false,0
//\Sigma,false,0
//\simeq,false,0
//\sinh,false,0
//\sixptsize,false,0
//\sh,false,0
//\skew,false,0
//\skip,false,0
//\sl,false,0
//\smallfrown,false,0
//\smallint,false,0
//{smallmatrix},false,0
//\smallsetminus,false,0
//\smallsmile,false,0
//\smash,false,0
//\smile,false,0
//\smiley,false,0
//\sout,false,0
//\Space,false,0
//\space,false,0
//\spades,false,0
//\spadesuit,false,0
//\sphericalangle,false,0
//{split},false,0
//\sqcap,false,0
//\sqcup,false,0
//\square,false,0
//\sqsubset,false,0
//\sqsupset,false,0
//\sqsupseteq,false,0
//\Stigma,false,0
//\stigma,false,0
//\strut,false,0
//\style,false,0
//\sub,false,0
//{subarray},false,0
//\sube,false,0
//\Subset,false,0
//\subseteqq,false,0
//\subsetneq,false,0
//\subsetneqq,false,0
//\substack,false,0
//\succ,false,0
//\succapprox,false,0
//\succcurlyeq,false,0
//\succnapprox,false,0
//\succneqq,false,0
//\succnsim,false,0
//\succsim,false,0
//\sup,false,0
//\supe,false,0
//\Supset,false,0
//\supseteqq,false,0
//\supsetneq,false,0
//\supsetneqq,false,0
//\surd,false,0
//\swarrow,false,0
//\tag,false,0
//\tag,false,0
//\tanh,false,0
//\Tau,false,0
//\tbinom,false,0
//\TeX,true,0
//\textasciitilde,false,0
//\textasciicircum,false,0
//\textbackslash,false,0
//\textbar,false,0
//\textbardbl,false,0
//\textbraceleft,false,0
//\textbraceright,false,0
//\textcircled,false,0
//\textdagger,false,0
//\textdaggerdbl,false,0
//\textdegree,false,0
//\textdollar,false,0
//\textellipsis,false,0
//\textemdash,false,0
//\textendash,false,0
//\textgreater,false,0
//\textless,false,0
//\textmd,true,0
//\textnormal,true,0
//\textquotedblleft,false,0
//\textquotedblright,false,0
//\textquoteleft,false,0
//\textquoteright,false,0
//\textregistered,false,0
//\textsc,false,0
//\textsf,true,0
//\textsl,false,0
//\textsterling,false,0
//\textstyle,true,0
//\texttip,false,0
//\texttt,true,0
//\textunderscore,false,0
//\textvisiblespace,false,0
//\tg,false,0
//\th,false,0
//\therefore,false,0
//\thetasym,false,0
//\thicksim,false,0
//\thickspace,false,0
//\thinspace,false,0
//\Tiny,false,0
//\tiny,false,0
//\toggle,false,0
//\top,false,0
//\triangledown,false,0
//\triangleleft,false,0
//\trianglelefteq,false,0
//\triangleq,false,0
//\triangleright,false,0
//\trianglerighteq,false,0
//\tt,true,0
//\twoheadleftarrow,false,0
//\twoheadrightarrow,false,0
//\Uarr,false,0
//\uArr,false,0
//\uarr,false,0
//\ulcorner,false,0
//\underbrace,false,0
//\underbracket,false,0
//\undergroup,false,0
//\underleftarrow,false,0
//\underleftrightarrow,false,0
//\underlinesegment,false,0
//\underparen,false,0
//\unicode,false,0
//\unlhd,false,0
//\unrhd,false,0
//\up,false,0
//\Uparrow,false,0
//\Updownarrow,false,0
//\updownarrow,false,0
//\upharpoonleft,false,0
//\upharpoonright,false,0
//\uplus,false,0
//\uproot,false,0
//\upshape,false,0
//\Upsilon,false,0
//\upsilon,false,0
//\upuparrows,false,0
//\urcorner,false,0
//\url,false,0
//\utilde,false,0
//\varcoppa,false,0
//\varDelta,false,0
//\varGamma,false,0
//\varinjlim,false,0
//\varkappa,false,0
//\varLambda,false,0
//\varliminf,false,0
//\varlimsup,false,0
//\varOmega,false,0
//\varPhi,false,0
//\varPi,false,0
//\varpi,false,0
//\varprojlim,false,0
//\varpropto,false,0
//\varPsi,false,0
//\varPsi,false,0
//\varrho,false,0
//\varSigma,false,0
//\varsigma,false,0
//\varstigma,false,0
//\varsubsetneq,false,0
//\varsubsetneqq,false,0
//\varsupsetneq,false,0
//\varsupsetneqq,false,0
//\varTheta,false,0
//\vartheta,false,0
//\vartriangle,false,0
//\vartriangleleft,false,0
//\vartriangleright,false,0
//\varUpsilon,false,0
//\varXi,false,0
//\vcentcolon,false,0
//\vcenter,false,0
//\Vdash,false,0
//\vDash,false,0
//\vdash,false,0
//\vdots,false,0
//\veebar,false,0
//\verb,false,0
//\Vert,false,0
//\vfil,false,0
//\vfill,false,0
//\vline,false,0
//{Vmatrix},false,0
//{vmatrix},false,0
//\vphantom,false,0
//\Vvdash,false,0
//\weierp,false,0
//\widecheck,false,0
//\widehat,false,0
//\wideparen,false,0
//\widetilde,false,0
//\wp,false,0
//\wr,false,0
//\xcancel,false,0
//\xdef,false,0
//\Xi,false,0
//\xi,false,0
//\xhookleftarrow,false,0
//\xhookrightarrow,false,0
//\xLeftarrow,false,0
//\xleftarrow,false,0
//\xleftharpoondown,false,0
//\xleftharpoonup,false,0
//\xleftrightarrow,false,0
//\xleftrightharpoons,false,0
//\xlongequal,false,0
//\xmapsto,false,0
//\xRightarrow,false,0
//\xrightharpoondown,false,0
//\xrightharpoonup,false,0
//\xtofrom,false,0
//\xtwoheadleftarrow,false,0
//\xtwoheadrightarrow,false,0
//\yen,true,0
//\Zeta,true,0
// // TODO(adamjcook): Add library description.
// library katex.font_metrics;
//
// num sigma1 = 0.025;
// num sigma2 = 0;
// num sigma3 = 0;
// num sigma4 = 0;
// num sigma5 = 0.431;
// num sigma6 = 1;
// num sigma7 = 0;
// num sigma8 = 0.677;
// num sigma9 = 0.394;
// num sigma10 = 0.444;
// num sigma11 = 0.686;
// num sigma12 = 0.345;
// num sigma13 = 0.413;
// num sigma14 = 0.363;
// num sigma15 = 0.289;
// num sigma16 = 0.150;
// num sigma17 = 0.247;
// num sigma18 = 0.386;
// num sigma19 = 0.050;
// num sigma20 = 2.390;
// num sigma21 = 0.101;
// num sigma22 = 0.250;
// num xi1 = 0;
// num xi2 = 0;
// num xi3 = 0;
// num xi4 = 0;
// num xi5 = .431;
// num xi6 = 1;
// num xi7 = 0;
// num xi8 = .04;
// num xi9 = .111;
// num xi10 = .166;
// num xi11 = .2;
// num xi12 = .6;
// num xi13 = .1;
// num ptPerEm = 10.0;
// Map<String, num> metrics = {
//   'xHeight': sigma5,
//   'quad': sigma6,
//   'num1': sigma8,
//   'num2': sigma9,
//   'num3': sigma10,
//   'denom1': sigma11,
//   'denom2': sigma12,
//   'sup1': sigma13,
//   'sup2': sigma14,
//   'sup3': sigma15,
//   'sub1': sigma16,
//   'sub2': sigma17,
//   'supDrop': sigma18,
//   'subDrop': sigma19,
//   'delim1': sigma20,
//   'delim2': sigma21,
//   'axisHeight': sigma22,
//   'defaultRuleThickness': xi8,
//   'bigOpSpacing1': xi9,
//   'bigOpSpacing2': xi10,
//   'bigOpSpacing3': xi11,
//   'bigOpSpacing4': xi12,
//   'bigOpSpacing5': xi13,
//   'ptPerEm': ptPerEm
// };
// Map<String, Map<String, Map<String, num>>> metricMap = {
//   "AMS-Regular": {
//     "10003": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "10016": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "1008": {"depth": 0.0, "height": 0.43056, "italic": 0.04028, "skew": 0.0},
//     "107": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "10731": {"depth": 0.11111, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "10846": {"depth": 0.19444, "height": 0.75583, "italic": 0.0, "skew": 0.0},
//     "10877": {"depth": 0.13667, "height": 0.63667, "italic": 0.0, "skew": 0.0},
//     "10878": {"depth": 0.13667, "height": 0.63667, "italic": 0.0, "skew": 0.0},
//     "10885": {"depth": 0.25583, "height": 0.75583, "italic": 0.0, "skew": 0.0},
//     "10886": {"depth": 0.25583, "height": 0.75583, "italic": 0.0, "skew": 0.0},
//     "10887": {"depth": 0.13597, "height": 0.63597, "italic": 0.0, "skew": 0.0},
//     "10888": {"depth": 0.13597, "height": 0.63597, "italic": 0.0, "skew": 0.0},
//     "10889": {"depth": 0.26167, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "10890": {"depth": 0.26167, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "10891": {"depth": 0.48256, "height": 0.98256, "italic": 0.0, "skew": 0.0},
//     "10892": {"depth": 0.48256, "height": 0.98256, "italic": 0.0, "skew": 0.0},
//     "10901": {"depth": 0.13667, "height": 0.63667, "italic": 0.0, "skew": 0.0},
//     "10902": {"depth": 0.13667, "height": 0.63667, "italic": 0.0, "skew": 0.0},
//     "10933": {"depth": 0.25142, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "10934": {"depth": 0.25142, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "10935": {"depth": 0.26167, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "10936": {"depth": 0.26167, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "10937": {"depth": 0.26167, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "10938": {"depth": 0.26167, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "10949": {"depth": 0.25583, "height": 0.75583, "italic": 0.0, "skew": 0.0},
//     "10950": {"depth": 0.25583, "height": 0.75583, "italic": 0.0, "skew": 0.0},
//     "10955": {"depth": 0.28481, "height": 0.79383, "italic": 0.0, "skew": 0.0},
//     "10956": {"depth": 0.28481, "height": 0.79383, "italic": 0.0, "skew": 0.0},
//     "165": {"depth": 0.0, "height": 0.675, "italic": 0.025, "skew": 0.0},
//     "174": {"depth": 0.15559, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "240": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "295": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "57350": {"depth": 0.08167, "height": 0.58167, "italic": 0.0, "skew": 0.0},
//     "57351": {"depth": 0.08167, "height": 0.58167, "italic": 0.0, "skew": 0.0},
//     "57352": {"depth": 0.08167, "height": 0.58167, "italic": 0.0, "skew": 0.0},
//     "57353": {"depth": 0.0, "height": 0.43056, "italic": 0.04028, "skew": 0.0},
//     "57356": {"depth": 0.25142, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "57357": {"depth": 0.25142, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "57358": {"depth": 0.41951, "height": 0.91951, "italic": 0.0, "skew": 0.0},
//     "57359": {"depth": 0.30274, "height": 0.79383, "italic": 0.0, "skew": 0.0},
//     "57360": {"depth": 0.30274, "height": 0.79383, "italic": 0.0, "skew": 0.0},
//     "57361": {"depth": 0.41951, "height": 0.91951, "italic": 0.0, "skew": 0.0},
//     "57366": {"depth": 0.25142, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "57367": {"depth": 0.25142, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "57368": {"depth": 0.25142, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "57369": {"depth": 0.25142, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "57370": {"depth": 0.13597, "height": 0.63597, "italic": 0.0, "skew": 0.0},
//     "57371": {"depth": 0.13597, "height": 0.63597, "italic": 0.0, "skew": 0.0},
//     "65": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "66": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "67": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "68": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "69": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "70": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "71": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "710": {"depth": 0.0, "height": 0.825, "italic": 0.0, "skew": 0.0},
//     "72": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "73": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "732": {"depth": 0.0, "height": 0.9, "italic": 0.0, "skew": 0.0},
//     "74": {"depth": 0.16667, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "75": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "76": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "77": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "770": {"depth": 0.0, "height": 0.825, "italic": 0.0, "skew": 0.0},
//     "771": {"depth": 0.0, "height": 0.9, "italic": 0.0, "skew": 0.0},
//     "78": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "79": {"depth": 0.16667, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "80": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "81": {"depth": 0.16667, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "82": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8245": {"depth": 0.0, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "83": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "84": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8463": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8487": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8498": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "85": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8502": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8503": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8504": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8513": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8592": {"depth": -0.03598, "height": 0.46402, "italic": 0.0, "skew": 0.0},
//     "8594": {"depth": -0.03598, "height": 0.46402, "italic": 0.0, "skew": 0.0},
//     "86": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8602": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8603": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8606": {"depth": 0.01354, "height": 0.52239, "italic": 0.0, "skew": 0.0},
//     "8608": {"depth": 0.01354, "height": 0.52239, "italic": 0.0, "skew": 0.0},
//     "8610": {"depth": 0.01354, "height": 0.52239, "italic": 0.0, "skew": 0.0},
//     "8611": {"depth": 0.01354, "height": 0.52239, "italic": 0.0, "skew": 0.0},
//     "8619": {"depth": 0.0, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8620": {"depth": 0.0, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8621": {"depth": -0.13313, "height": 0.37788, "italic": 0.0, "skew": 0.0},
//     "8622": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8624": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8625": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8630": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "8631": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "8634": {"depth": 0.08198, "height": 0.58198, "italic": 0.0, "skew": 0.0},
//     "8635": {"depth": 0.08198, "height": 0.58198, "italic": 0.0, "skew": 0.0},
//     "8638": {"depth": 0.19444, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8639": {"depth": 0.19444, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8642": {"depth": 0.19444, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8643": {"depth": 0.19444, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8644": {"depth": 0.1808, "height": 0.675, "italic": 0.0, "skew": 0.0},
//     "8646": {"depth": 0.1808, "height": 0.675, "italic": 0.0, "skew": 0.0},
//     "8647": {"depth": 0.1808, "height": 0.675, "italic": 0.0, "skew": 0.0},
//     "8648": {"depth": 0.19444, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8649": {"depth": 0.1808, "height": 0.675, "italic": 0.0, "skew": 0.0},
//     "8650": {"depth": 0.19444, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8651": {"depth": 0.01354, "height": 0.52239, "italic": 0.0, "skew": 0.0},
//     "8652": {"depth": 0.01354, "height": 0.52239, "italic": 0.0, "skew": 0.0},
//     "8653": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8654": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8655": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8666": {"depth": 0.13667, "height": 0.63667, "italic": 0.0, "skew": 0.0},
//     "8667": {"depth": 0.13667, "height": 0.63667, "italic": 0.0, "skew": 0.0},
//     "8669": {"depth": -0.13313, "height": 0.37788, "italic": 0.0, "skew": 0.0},
//     "87": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8705": {"depth": 0.0, "height": 0.825, "italic": 0.0, "skew": 0.0},
//     "8708": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8709": {"depth": 0.08167, "height": 0.58167, "italic": 0.0, "skew": 0.0},
//     "8717": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "8722": {"depth": -0.03598, "height": 0.46402, "italic": 0.0, "skew": 0.0},
//     "8724": {"depth": 0.08198, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8726": {"depth": 0.08167, "height": 0.58167, "italic": 0.0, "skew": 0.0},
//     "8733": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8736": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8737": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8738": {"depth": 0.03517, "height": 0.52239, "italic": 0.0, "skew": 0.0},
//     "8739": {"depth": 0.08167, "height": 0.58167, "italic": 0.0, "skew": 0.0},
//     "8740": {"depth": 0.25142, "height": 0.74111, "italic": 0.0, "skew": 0.0},
//     "8741": {"depth": 0.08167, "height": 0.58167, "italic": 0.0, "skew": 0.0},
//     "8742": {"depth": 0.25142, "height": 0.74111, "italic": 0.0, "skew": 0.0},
//     "8756": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8757": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8764": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8765": {"depth": -0.13313, "height": 0.37788, "italic": 0.0, "skew": 0.0},
//     "8769": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8770": {"depth": -0.03625, "height": 0.46375, "italic": 0.0, "skew": 0.0},
//     "8774": {"depth": 0.30274, "height": 0.79383, "italic": 0.0, "skew": 0.0},
//     "8776": {"depth": -0.01688, "height": 0.48312, "italic": 0.0, "skew": 0.0},
//     "8778": {"depth": 0.08167, "height": 0.58167, "italic": 0.0, "skew": 0.0},
//     "8782": {"depth": 0.06062, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8783": {"depth": 0.06062, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8785": {"depth": 0.08198, "height": 0.58198, "italic": 0.0, "skew": 0.0},
//     "8786": {"depth": 0.08198, "height": 0.58198, "italic": 0.0, "skew": 0.0},
//     "8787": {"depth": 0.08198, "height": 0.58198, "italic": 0.0, "skew": 0.0},
//     "8790": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8791": {"depth": 0.22958, "height": 0.72958, "italic": 0.0, "skew": 0.0},
//     "8796": {"depth": 0.08198, "height": 0.91667, "italic": 0.0, "skew": 0.0},
//     "88": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8806": {"depth": 0.25583, "height": 0.75583, "italic": 0.0, "skew": 0.0},
//     "8807": {"depth": 0.25583, "height": 0.75583, "italic": 0.0, "skew": 0.0},
//     "8808": {"depth": 0.25142, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "8809": {"depth": 0.25142, "height": 0.75726, "italic": 0.0, "skew": 0.0},
//     "8812": {"depth": 0.25583, "height": 0.75583, "italic": 0.0, "skew": 0.0},
//     "8814": {"depth": 0.20576, "height": 0.70576, "italic": 0.0, "skew": 0.0},
//     "8815": {"depth": 0.20576, "height": 0.70576, "italic": 0.0, "skew": 0.0},
//     "8816": {"depth": 0.30274, "height": 0.79383, "italic": 0.0, "skew": 0.0},
//     "8817": {"depth": 0.30274, "height": 0.79383, "italic": 0.0, "skew": 0.0},
//     "8818": {"depth": 0.22958, "height": 0.72958, "italic": 0.0, "skew": 0.0},
//     "8819": {"depth": 0.22958, "height": 0.72958, "italic": 0.0, "skew": 0.0},
//     "8822": {"depth": 0.1808, "height": 0.675, "italic": 0.0, "skew": 0.0},
//     "8823": {"depth": 0.1808, "height": 0.675, "italic": 0.0, "skew": 0.0},
//     "8828": {"depth": 0.13667, "height": 0.63667, "italic": 0.0, "skew": 0.0},
//     "8829": {"depth": 0.13667, "height": 0.63667, "italic": 0.0, "skew": 0.0},
//     "8830": {"depth": 0.22958, "height": 0.72958, "italic": 0.0, "skew": 0.0},
//     "8831": {"depth": 0.22958, "height": 0.72958, "italic": 0.0, "skew": 0.0},
//     "8832": {"depth": 0.20576, "height": 0.70576, "italic": 0.0, "skew": 0.0},
//     "8833": {"depth": 0.20576, "height": 0.70576, "italic": 0.0, "skew": 0.0},
//     "8840": {"depth": 0.30274, "height": 0.79383, "italic": 0.0, "skew": 0.0},
//     "8841": {"depth": 0.30274, "height": 0.79383, "italic": 0.0, "skew": 0.0},
//     "8842": {"depth": 0.13597, "height": 0.63597, "italic": 0.0, "skew": 0.0},
//     "8843": {"depth": 0.13597, "height": 0.63597, "italic": 0.0, "skew": 0.0},
//     "8847": {"depth": 0.03517, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8848": {"depth": 0.03517, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8858": {"depth": 0.08198, "height": 0.58198, "italic": 0.0, "skew": 0.0},
//     "8859": {"depth": 0.08198, "height": 0.58198, "italic": 0.0, "skew": 0.0},
//     "8861": {"depth": 0.08198, "height": 0.58198, "italic": 0.0, "skew": 0.0},
//     "8862": {"depth": 0.0, "height": 0.675, "italic": 0.0, "skew": 0.0},
//     "8863": {"depth": 0.0, "height": 0.675, "italic": 0.0, "skew": 0.0},
//     "8864": {"depth": 0.0, "height": 0.675, "italic": 0.0, "skew": 0.0},
//     "8865": {"depth": 0.0, "height": 0.675, "italic": 0.0, "skew": 0.0},
//     "8872": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8873": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8874": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8876": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8877": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8878": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8879": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8882": {"depth": 0.03517, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8883": {"depth": 0.03517, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8884": {"depth": 0.13667, "height": 0.63667, "italic": 0.0, "skew": 0.0},
//     "8885": {"depth": 0.13667, "height": 0.63667, "italic": 0.0, "skew": 0.0},
//     "8888": {"depth": 0.0, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8890": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "8891": {"depth": 0.19444, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8892": {"depth": 0.19444, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "89": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8901": {"depth": 0.0, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8903": {"depth": 0.08167, "height": 0.58167, "italic": 0.0, "skew": 0.0},
//     "8905": {"depth": 0.08167, "height": 0.58167, "italic": 0.0, "skew": 0.0},
//     "8906": {"depth": 0.08167, "height": 0.58167, "italic": 0.0, "skew": 0.0},
//     "8907": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8908": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8909": {"depth": -0.03598, "height": 0.46402, "italic": 0.0, "skew": 0.0},
//     "8910": {"depth": 0.0, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8911": {"depth": 0.0, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8912": {"depth": 0.03517, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8913": {"depth": 0.03517, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8914": {"depth": 0.0, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8915": {"depth": 0.0, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8916": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8918": {"depth": 0.0391, "height": 0.5391, "italic": 0.0, "skew": 0.0},
//     "8919": {"depth": 0.0391, "height": 0.5391, "italic": 0.0, "skew": 0.0},
//     "8920": {"depth": 0.03517, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8921": {"depth": 0.03517, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "8922": {"depth": 0.38569, "height": 0.88569, "italic": 0.0, "skew": 0.0},
//     "8923": {"depth": 0.38569, "height": 0.88569, "italic": 0.0, "skew": 0.0},
//     "8926": {"depth": 0.13667, "height": 0.63667, "italic": 0.0, "skew": 0.0},
//     "8927": {"depth": 0.13667, "height": 0.63667, "italic": 0.0, "skew": 0.0},
//     "8928": {"depth": 0.30274, "height": 0.79383, "italic": 0.0, "skew": 0.0},
//     "8929": {"depth": 0.30274, "height": 0.79383, "italic": 0.0, "skew": 0.0},
//     "8934": {"depth": 0.23222, "height": 0.74111, "italic": 0.0, "skew": 0.0},
//     "8935": {"depth": 0.23222, "height": 0.74111, "italic": 0.0, "skew": 0.0},
//     "8936": {"depth": 0.23222, "height": 0.74111, "italic": 0.0, "skew": 0.0},
//     "8937": {"depth": 0.23222, "height": 0.74111, "italic": 0.0, "skew": 0.0},
//     "8938": {"depth": 0.20576, "height": 0.70576, "italic": 0.0, "skew": 0.0},
//     "8939": {"depth": 0.20576, "height": 0.70576, "italic": 0.0, "skew": 0.0},
//     "8940": {"depth": 0.30274, "height": 0.79383, "italic": 0.0, "skew": 0.0},
//     "8941": {"depth": 0.30274, "height": 0.79383, "italic": 0.0, "skew": 0.0},
//     "8994": {"depth": 0.19444, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8995": {"depth": 0.19444, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "90": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "9416": {"depth": 0.15559, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "9484": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "9488": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "9492": {"depth": 0.0, "height": 0.37788, "italic": 0.0, "skew": 0.0},
//     "9496": {"depth": 0.0, "height": 0.37788, "italic": 0.0, "skew": 0.0},
//     "9585": {"depth": 0.19444, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "9586": {"depth": 0.19444, "height": 0.74111, "italic": 0.0, "skew": 0.0},
//     "9632": {"depth": 0.0, "height": 0.675, "italic": 0.0, "skew": 0.0},
//     "9633": {"depth": 0.0, "height": 0.675, "italic": 0.0, "skew": 0.0},
//     "9650": {"depth": 0.0, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "9651": {"depth": 0.0, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "9654": {"depth": 0.03517, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "9660": {"depth": 0.0, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "9661": {"depth": 0.0, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "9664": {"depth": 0.03517, "height": 0.54986, "italic": 0.0, "skew": 0.0},
//     "9674": {"depth": 0.11111, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "9733": {"depth": 0.19444, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "989": {"depth": 0.08167, "height": 0.58167, "italic": 0.0, "skew": 0.0}
//   },
//   "Main-Bold": {
//     "100": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "101": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "102": {"depth": 0.0, "height": 0.69444, "italic": 0.10903, "skew": 0.0},
//     "10216": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "10217": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "103": {"depth": 0.19444, "height": 0.44444, "italic": 0.01597, "skew": 0.0},
//     "104": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "105": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "106": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "107": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "108": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "10815": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "109": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "10927": {"depth": 0.19667, "height": 0.69667, "italic": 0.0, "skew": 0.0},
//     "10928": {"depth": 0.19667, "height": 0.69667, "italic": 0.0, "skew": 0.0},
//     "110": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "111": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "112": {"depth": 0.19444, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "113": {"depth": 0.19444, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "114": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "115": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "116": {"depth": 0.0, "height": 0.63492, "italic": 0.0, "skew": 0.0},
//     "117": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "118": {"depth": 0.0, "height": 0.44444, "italic": 0.01597, "skew": 0.0},
//     "119": {"depth": 0.0, "height": 0.44444, "italic": 0.01597, "skew": 0.0},
//     "120": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "121": {"depth": 0.19444, "height": 0.44444, "italic": 0.01597, "skew": 0.0},
//     "122": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "123": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "124": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "125": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "126": {"depth": 0.35, "height": 0.34444, "italic": 0.0, "skew": 0.0},
//     "168": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "172": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "175": {"depth": 0.0, "height": 0.59611, "italic": 0.0, "skew": 0.0},
//     "176": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "177": {"depth": 0.13333, "height": 0.63333, "italic": 0.0, "skew": 0.0},
//     "180": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "215": {"depth": 0.13333, "height": 0.63333, "italic": 0.0, "skew": 0.0},
//     "247": {"depth": 0.13333, "height": 0.63333, "italic": 0.0, "skew": 0.0},
//     "305": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "33": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "34": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "35": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "36": {"depth": 0.05556, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "37": {"depth": 0.05556, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "38": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "39": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "40": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "41": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "42": {"depth": 0.0, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "43": {"depth": 0.13333, "height": 0.63333, "italic": 0.0, "skew": 0.0},
//     "44": {"depth": 0.19444, "height": 0.15556, "italic": 0.0, "skew": 0.0},
//     "45": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "46": {"depth": 0.0, "height": 0.15556, "italic": 0.0, "skew": 0.0},
//     "47": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "48": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "49": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "50": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "51": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "52": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "53": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "54": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "55": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "56": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "567": {"depth": 0.19444, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "57": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "58": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "59": {"depth": 0.19444, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "60": {"depth": 0.08556, "height": 0.58556, "italic": 0.0, "skew": 0.0},
//     "61": {"depth": -0.10889, "height": 0.39111, "italic": 0.0, "skew": 0.0},
//     "62": {"depth": 0.08556, "height": 0.58556, "italic": 0.0, "skew": 0.0},
//     "63": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "64": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "65": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "66": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "67": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "68": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "69": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "70": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "71": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "710": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "711": {"depth": 0.0, "height": 0.63194, "italic": 0.0, "skew": 0.0},
//     "713": {"depth": 0.0, "height": 0.59611, "italic": 0.0, "skew": 0.0},
//     "714": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "715": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "72": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "728": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "729": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "73": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "730": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "732": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "74": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "75": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "76": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "768": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "769": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "77": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "770": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "771": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "772": {"depth": 0.0, "height": 0.59611, "italic": 0.0, "skew": 0.0},
//     "774": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "775": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "776": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "778": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "779": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "78": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "780": {"depth": 0.0, "height": 0.63194, "italic": 0.0, "skew": 0.0},
//     "79": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "80": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "81": {"depth": 0.19444, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "82": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "8211": {"depth": 0.0, "height": 0.44444, "italic": 0.03194, "skew": 0.0},
//     "8212": {"depth": 0.0, "height": 0.44444, "italic": 0.03194, "skew": 0.0},
//     "8216": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8217": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8220": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8221": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8224": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8225": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "824": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8242": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "83": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "84": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "8407": {"depth": 0.0, "height": 0.72444, "italic": 0.15486, "skew": 0.0},
//     "8463": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8465": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8467": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8472": {"depth": 0.19444, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "8476": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "85": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "8501": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8592": {"depth": -0.10889, "height": 0.39111, "italic": 0.0, "skew": 0.0},
//     "8593": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8594": {"depth": -0.10889, "height": 0.39111, "italic": 0.0, "skew": 0.0},
//     "8595": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8596": {"depth": -0.10889, "height": 0.39111, "italic": 0.0, "skew": 0.0},
//     "8597": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8598": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8599": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "86": {"depth": 0.0, "height": 0.68611, "italic": 0.01597, "skew": 0.0},
//     "8600": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8601": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8636": {"depth": -0.10889, "height": 0.39111, "italic": 0.0, "skew": 0.0},
//     "8637": {"depth": -0.10889, "height": 0.39111, "italic": 0.0, "skew": 0.0},
//     "8640": {"depth": -0.10889, "height": 0.39111, "italic": 0.0, "skew": 0.0},
//     "8641": {"depth": -0.10889, "height": 0.39111, "italic": 0.0, "skew": 0.0},
//     "8656": {"depth": -0.10889, "height": 0.39111, "italic": 0.0, "skew": 0.0},
//     "8657": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8658": {"depth": -0.10889, "height": 0.39111, "italic": 0.0, "skew": 0.0},
//     "8659": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8660": {"depth": -0.10889, "height": 0.39111, "italic": 0.0, "skew": 0.0},
//     "8661": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "87": {"depth": 0.0, "height": 0.68611, "italic": 0.01597, "skew": 0.0},
//     "8704": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8706": {"depth": 0.0, "height": 0.69444, "italic": 0.06389, "skew": 0.0},
//     "8707": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8709": {"depth": 0.05556, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8711": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "8712": {"depth": 0.08556, "height": 0.58556, "italic": 0.0, "skew": 0.0},
//     "8715": {"depth": 0.08556, "height": 0.58556, "italic": 0.0, "skew": 0.0},
//     "8722": {"depth": 0.13333, "height": 0.63333, "italic": 0.0, "skew": 0.0},
//     "8723": {"depth": 0.13333, "height": 0.63333, "italic": 0.0, "skew": 0.0},
//     "8725": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8726": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8727": {"depth": -0.02778, "height": 0.47222, "italic": 0.0, "skew": 0.0},
//     "8728": {"depth": -0.02639, "height": 0.47361, "italic": 0.0, "skew": 0.0},
//     "8729": {"depth": -0.02639, "height": 0.47361, "italic": 0.0, "skew": 0.0},
//     "8730": {"depth": 0.18, "height": 0.82, "italic": 0.0, "skew": 0.0},
//     "8733": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "8734": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "8736": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8739": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8741": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8743": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "8744": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "8745": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "8746": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "8747": {"depth": 0.19444, "height": 0.69444, "italic": 0.12778, "skew": 0.0},
//     "8764": {"depth": -0.10889, "height": 0.39111, "italic": 0.0, "skew": 0.0},
//     "8768": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8771": {"depth": 0.00222, "height": 0.50222, "italic": 0.0, "skew": 0.0},
//     "8776": {"depth": 0.02444, "height": 0.52444, "italic": 0.0, "skew": 0.0},
//     "8781": {"depth": 0.00222, "height": 0.50222, "italic": 0.0, "skew": 0.0},
//     "88": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "8801": {"depth": 0.00222, "height": 0.50222, "italic": 0.0, "skew": 0.0},
//     "8804": {"depth": 0.19667, "height": 0.69667, "italic": 0.0, "skew": 0.0},
//     "8805": {"depth": 0.19667, "height": 0.69667, "italic": 0.0, "skew": 0.0},
//     "8810": {"depth": 0.08556, "height": 0.58556, "italic": 0.0, "skew": 0.0},
//     "8811": {"depth": 0.08556, "height": 0.58556, "italic": 0.0, "skew": 0.0},
//     "8826": {"depth": 0.08556, "height": 0.58556, "italic": 0.0, "skew": 0.0},
//     "8827": {"depth": 0.08556, "height": 0.58556, "italic": 0.0, "skew": 0.0},
//     "8834": {"depth": 0.08556, "height": 0.58556, "italic": 0.0, "skew": 0.0},
//     "8835": {"depth": 0.08556, "height": 0.58556, "italic": 0.0, "skew": 0.0},
//     "8838": {"depth": 0.19667, "height": 0.69667, "italic": 0.0, "skew": 0.0},
//     "8839": {"depth": 0.19667, "height": 0.69667, "italic": 0.0, "skew": 0.0},
//     "8846": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "8849": {"depth": 0.19667, "height": 0.69667, "italic": 0.0, "skew": 0.0},
//     "8850": {"depth": 0.19667, "height": 0.69667, "italic": 0.0, "skew": 0.0},
//     "8851": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "8852": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "8853": {"depth": 0.13333, "height": 0.63333, "italic": 0.0, "skew": 0.0},
//     "8854": {"depth": 0.13333, "height": 0.63333, "italic": 0.0, "skew": 0.0},
//     "8855": {"depth": 0.13333, "height": 0.63333, "italic": 0.0, "skew": 0.0},
//     "8856": {"depth": 0.13333, "height": 0.63333, "italic": 0.0, "skew": 0.0},
//     "8857": {"depth": 0.13333, "height": 0.63333, "italic": 0.0, "skew": 0.0},
//     "8866": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8867": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8868": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8869": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "89": {"depth": 0.0, "height": 0.68611, "italic": 0.02875, "skew": 0.0},
//     "8900": {"depth": -0.02639, "height": 0.47361, "italic": 0.0, "skew": 0.0},
//     "8901": {"depth": -0.02639, "height": 0.47361, "italic": 0.0, "skew": 0.0},
//     "8902": {"depth": -0.02778, "height": 0.47222, "italic": 0.0, "skew": 0.0},
//     "8968": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8969": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8970": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8971": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8994": {"depth": -0.13889, "height": 0.36111, "italic": 0.0, "skew": 0.0},
//     "8995": {"depth": -0.13889, "height": 0.36111, "italic": 0.0, "skew": 0.0},
//     "90": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "91": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "915": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "916": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "92": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "920": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "923": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "926": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "928": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "93": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "931": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "933": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "934": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "936": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "937": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "94": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "95": {"depth": 0.31, "height": 0.13444, "italic": 0.03194, "skew": 0.0},
//     "96": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9651": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9657": {"depth": -0.02778, "height": 0.47222, "italic": 0.0, "skew": 0.0},
//     "9661": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9667": {"depth": -0.02778, "height": 0.47222, "italic": 0.0, "skew": 0.0},
//     "97": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "9711": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "98": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9824": {"depth": 0.12963, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9825": {"depth": 0.12963, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9826": {"depth": 0.12963, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9827": {"depth": 0.12963, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9837": {"depth": 0.0, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "9838": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9839": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "99": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0}
//   },
//   "Main-Italic": {
//     "100": {"depth": 0.0, "height": 0.69444, "italic": 0.10333, "skew": 0.0},
//     "101": {"depth": 0.0, "height": 0.43056, "italic": 0.07514, "skew": 0.0},
//     "102": {"depth": 0.19444, "height": 0.69444, "italic": 0.21194, "skew": 0.0},
//     "103": {"depth": 0.19444, "height": 0.43056, "italic": 0.08847, "skew": 0.0},
//     "104": {"depth": 0.0, "height": 0.69444, "italic": 0.07671, "skew": 0.0},
//     "105": {"depth": 0.0, "height": 0.65536, "italic": 0.1019, "skew": 0.0},
//     "106": {"depth": 0.19444, "height": 0.65536, "italic": 0.14467, "skew": 0.0},
//     "107": {"depth": 0.0, "height": 0.69444, "italic": 0.10764, "skew": 0.0},
//     "108": {"depth": 0.0, "height": 0.69444, "italic": 0.10333, "skew": 0.0},
//     "109": {"depth": 0.0, "height": 0.43056, "italic": 0.07671, "skew": 0.0},
//     "110": {"depth": 0.0, "height": 0.43056, "italic": 0.07671, "skew": 0.0},
//     "111": {"depth": 0.0, "height": 0.43056, "italic": 0.06312, "skew": 0.0},
//     "112": {"depth": 0.19444, "height": 0.43056, "italic": 0.06312, "skew": 0.0},
//     "113": {"depth": 0.19444, "height": 0.43056, "italic": 0.08847, "skew": 0.0},
//     "114": {"depth": 0.0, "height": 0.43056, "italic": 0.10764, "skew": 0.0},
//     "115": {"depth": 0.0, "height": 0.43056, "italic": 0.08208, "skew": 0.0},
//     "116": {"depth": 0.0, "height": 0.61508, "italic": 0.09486, "skew": 0.0},
//     "117": {"depth": 0.0, "height": 0.43056, "italic": 0.07671, "skew": 0.0},
//     "118": {"depth": 0.0, "height": 0.43056, "italic": 0.10764, "skew": 0.0},
//     "119": {"depth": 0.0, "height": 0.43056, "italic": 0.10764, "skew": 0.0},
//     "120": {"depth": 0.0, "height": 0.43056, "italic": 0.12042, "skew": 0.0},
//     "121": {"depth": 0.19444, "height": 0.43056, "italic": 0.08847, "skew": 0.0},
//     "122": {"depth": 0.0, "height": 0.43056, "italic": 0.12292, "skew": 0.0},
//     "126": {"depth": 0.35, "height": 0.31786, "italic": 0.11585, "skew": 0.0},
//     "163": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "305": {"depth": 0.0, "height": 0.43056, "italic": 0.07671, "skew": 0.0},
//     "33": {"depth": 0.0, "height": 0.69444, "italic": 0.12417, "skew": 0.0},
//     "34": {"depth": 0.0, "height": 0.69444, "italic": 0.06961, "skew": 0.0},
//     "35": {"depth": 0.19444, "height": 0.69444, "italic": 0.06616, "skew": 0.0},
//     "37": {"depth": 0.05556, "height": 0.75, "italic": 0.13639, "skew": 0.0},
//     "38": {"depth": 0.0, "height": 0.69444, "italic": 0.09694, "skew": 0.0},
//     "39": {"depth": 0.0, "height": 0.69444, "italic": 0.12417, "skew": 0.0},
//     "40": {"depth": 0.25, "height": 0.75, "italic": 0.16194, "skew": 0.0},
//     "41": {"depth": 0.25, "height": 0.75, "italic": 0.03694, "skew": 0.0},
//     "42": {"depth": 0.0, "height": 0.75, "italic": 0.14917, "skew": 0.0},
//     "43": {"depth": 0.05667, "height": 0.56167, "italic": 0.03694, "skew": 0.0},
//     "44": {"depth": 0.19444, "height": 0.10556, "italic": 0.0, "skew": 0.0},
//     "45": {"depth": 0.0, "height": 0.43056, "italic": 0.02826, "skew": 0.0},
//     "46": {"depth": 0.0, "height": 0.10556, "italic": 0.0, "skew": 0.0},
//     "47": {"depth": 0.25, "height": 0.75, "italic": 0.16194, "skew": 0.0},
//     "48": {"depth": 0.0, "height": 0.64444, "italic": 0.13556, "skew": 0.0},
//     "49": {"depth": 0.0, "height": 0.64444, "italic": 0.13556, "skew": 0.0},
//     "50": {"depth": 0.0, "height": 0.64444, "italic": 0.13556, "skew": 0.0},
//     "51": {"depth": 0.0, "height": 0.64444, "italic": 0.13556, "skew": 0.0},
//     "52": {"depth": 0.19444, "height": 0.64444, "italic": 0.13556, "skew": 0.0},
//     "53": {"depth": 0.0, "height": 0.64444, "italic": 0.13556, "skew": 0.0},
//     "54": {"depth": 0.0, "height": 0.64444, "italic": 0.13556, "skew": 0.0},
//     "55": {"depth": 0.19444, "height": 0.64444, "italic": 0.13556, "skew": 0.0},
//     "56": {"depth": 0.0, "height": 0.64444, "italic": 0.13556, "skew": 0.0},
//     "567": {"depth": 0.19444, "height": 0.43056, "italic": 0.03736, "skew": 0.0},
//     "57": {"depth": 0.0, "height": 0.64444, "italic": 0.13556, "skew": 0.0},
//     "58": {"depth": 0.0, "height": 0.43056, "italic": 0.0582, "skew": 0.0},
//     "59": {"depth": 0.19444, "height": 0.43056, "italic": 0.0582, "skew": 0.0},
//     "61": {"depth": -0.13313, "height": 0.36687, "italic": 0.06616, "skew": 0.0},
//     "63": {"depth": 0.0, "height": 0.69444, "italic": 0.1225, "skew": 0.0},
//     "64": {"depth": 0.0, "height": 0.69444, "italic": 0.09597, "skew": 0.0},
//     "65": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "66": {"depth": 0.0, "height": 0.68333, "italic": 0.10257, "skew": 0.0},
//     "67": {"depth": 0.0, "height": 0.68333, "italic": 0.14528, "skew": 0.0},
//     "68": {"depth": 0.0, "height": 0.68333, "italic": 0.09403, "skew": 0.0},
//     "69": {"depth": 0.0, "height": 0.68333, "italic": 0.12028, "skew": 0.0},
//     "70": {"depth": 0.0, "height": 0.68333, "italic": 0.13305, "skew": 0.0},
//     "71": {"depth": 0.0, "height": 0.68333, "italic": 0.08722, "skew": 0.0},
//     "72": {"depth": 0.0, "height": 0.68333, "italic": 0.16389, "skew": 0.0},
//     "73": {"depth": 0.0, "height": 0.68333, "italic": 0.15806, "skew": 0.0},
//     "74": {"depth": 0.0, "height": 0.68333, "italic": 0.14028, "skew": 0.0},
//     "75": {"depth": 0.0, "height": 0.68333, "italic": 0.14528, "skew": 0.0},
//     "76": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "768": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "769": {"depth": 0.0, "height": 0.69444, "italic": 0.09694, "skew": 0.0},
//     "77": {"depth": 0.0, "height": 0.68333, "italic": 0.16389, "skew": 0.0},
//     "770": {"depth": 0.0, "height": 0.69444, "italic": 0.06646, "skew": 0.0},
//     "771": {"depth": 0.0, "height": 0.66786, "italic": 0.11585, "skew": 0.0},
//     "772": {"depth": 0.0, "height": 0.56167, "italic": 0.10333, "skew": 0.0},
//     "774": {"depth": 0.0, "height": 0.69444, "italic": 0.10806, "skew": 0.0},
//     "775": {"depth": 0.0, "height": 0.66786, "italic": 0.11752, "skew": 0.0},
//     "776": {"depth": 0.0, "height": 0.66786, "italic": 0.10474, "skew": 0.0},
//     "778": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "779": {"depth": 0.0, "height": 0.69444, "italic": 0.1225, "skew": 0.0},
//     "78": {"depth": 0.0, "height": 0.68333, "italic": 0.16389, "skew": 0.0},
//     "780": {"depth": 0.0, "height": 0.62847, "italic": 0.08295, "skew": 0.0},
//     "79": {"depth": 0.0, "height": 0.68333, "italic": 0.09403, "skew": 0.0},
//     "80": {"depth": 0.0, "height": 0.68333, "italic": 0.10257, "skew": 0.0},
//     "81": {"depth": 0.19444, "height": 0.68333, "italic": 0.09403, "skew": 0.0},
//     "82": {"depth": 0.0, "height": 0.68333, "italic": 0.03868, "skew": 0.0},
//     "8211": {"depth": 0.0, "height": 0.43056, "italic": 0.09208, "skew": 0.0},
//     "8212": {"depth": 0.0, "height": 0.43056, "italic": 0.09208, "skew": 0.0},
//     "8216": {"depth": 0.0, "height": 0.69444, "italic": 0.12417, "skew": 0.0},
//     "8217": {"depth": 0.0, "height": 0.69444, "italic": 0.12417, "skew": 0.0},
//     "8220": {"depth": 0.0, "height": 0.69444, "italic": 0.1685, "skew": 0.0},
//     "8221": {"depth": 0.0, "height": 0.69444, "italic": 0.06961, "skew": 0.0},
//     "83": {"depth": 0.0, "height": 0.68333, "italic": 0.11972, "skew": 0.0},
//     "84": {"depth": 0.0, "height": 0.68333, "italic": 0.13305, "skew": 0.0},
//     "8463": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "85": {"depth": 0.0, "height": 0.68333, "italic": 0.16389, "skew": 0.0},
//     "86": {"depth": 0.0, "height": 0.68333, "italic": 0.18361, "skew": 0.0},
//     "87": {"depth": 0.0, "height": 0.68333, "italic": 0.18361, "skew": 0.0},
//     "88": {"depth": 0.0, "height": 0.68333, "italic": 0.15806, "skew": 0.0},
//     "89": {"depth": 0.0, "height": 0.68333, "italic": 0.19383, "skew": 0.0},
//     "90": {"depth": 0.0, "height": 0.68333, "italic": 0.14528, "skew": 0.0},
//     "91": {"depth": 0.25, "height": 0.75, "italic": 0.1875, "skew": 0.0},
//     "915": {"depth": 0.0, "height": 0.68333, "italic": 0.13305, "skew": 0.0},
//     "916": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "920": {"depth": 0.0, "height": 0.68333, "italic": 0.09403, "skew": 0.0},
//     "923": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "926": {"depth": 0.0, "height": 0.68333, "italic": 0.15294, "skew": 0.0},
//     "928": {"depth": 0.0, "height": 0.68333, "italic": 0.16389, "skew": 0.0},
//     "93": {"depth": 0.25, "height": 0.75, "italic": 0.10528, "skew": 0.0},
//     "931": {"depth": 0.0, "height": 0.68333, "italic": 0.12028, "skew": 0.0},
//     "933": {"depth": 0.0, "height": 0.68333, "italic": 0.11111, "skew": 0.0},
//     "934": {"depth": 0.0, "height": 0.68333, "italic": 0.05986, "skew": 0.0},
//     "936": {"depth": 0.0, "height": 0.68333, "italic": 0.11111, "skew": 0.0},
//     "937": {"depth": 0.0, "height": 0.68333, "italic": 0.10257, "skew": 0.0},
//     "94": {"depth": 0.0, "height": 0.69444, "italic": 0.06646, "skew": 0.0},
//     "95": {"depth": 0.31, "height": 0.12056, "italic": 0.09208, "skew": 0.0},
//     "97": {"depth": 0.0, "height": 0.43056, "italic": 0.07671, "skew": 0.0},
//     "98": {"depth": 0.0, "height": 0.69444, "italic": 0.06312, "skew": 0.0},
//     "99": {"depth": 0.0, "height": 0.43056, "italic": 0.05653, "skew": 0.0}
//   },
//   "Main-Regular": {
//     "32": {"depth": -0.0, "height": 0.0, "italic": 0, "skew": 0},
//     "160": {"depth": -0.0, "height": 0.0, "italic": 0, "skew": 0},
//     "8230": {"depth": -0.0, "height": 0.12, "italic": 0, "skew": 0},
//     "8773": {"depth": -0.022, "height": 0.589, "italic": 0, "skew": 0},
//     "8800": {"depth": 0.215, "height": 0.716, "italic": 0, "skew": 0},
//     "8942": {"depth": 0.03, "height": 0.9, "italic": 0, "skew": 0},
//     "8943": {"depth": -0.19, "height": 0.31, "italic": 0, "skew": 0},
//     "8945": {"depth": -0.1, "height": 0.82, "italic": 0, "skew": 0},
//     "100": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "101": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "102": {"depth": 0.0, "height": 0.69444, "italic": 0.07778, "skew": 0.0},
//     "10216": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "10217": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "103": {"depth": 0.19444, "height": 0.43056, "italic": 0.01389, "skew": 0.0},
//     "104": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "105": {"depth": 0.0, "height": 0.66786, "italic": 0.0, "skew": 0.0},
//     "106": {"depth": 0.19444, "height": 0.66786, "italic": 0.0, "skew": 0.0},
//     "107": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "108": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "10815": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "109": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "10927": {"depth": 0.13597, "height": 0.63597, "italic": 0.0, "skew": 0.0},
//     "10928": {"depth": 0.13597, "height": 0.63597, "italic": 0.0, "skew": 0.0},
//     "110": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "111": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "112": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "113": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "114": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "115": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "116": {"depth": 0.0, "height": 0.61508, "italic": 0.0, "skew": 0.0},
//     "117": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "118": {"depth": 0.0, "height": 0.43056, "italic": 0.01389, "skew": 0.0},
//     "119": {"depth": 0.0, "height": 0.43056, "italic": 0.01389, "skew": 0.0},
//     "120": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "121": {"depth": 0.19444, "height": 0.43056, "italic": 0.01389, "skew": 0.0},
//     "122": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "123": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "124": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "125": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "126": {"depth": 0.35, "height": 0.31786, "italic": 0.0, "skew": 0.0},
//     "168": {"depth": 0.0, "height": 0.66786, "italic": 0.0, "skew": 0.0},
//     "172": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "175": {"depth": 0.0, "height": 0.56778, "italic": 0.0, "skew": 0.0},
//     "176": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "177": {"depth": 0.08333, "height": 0.58333, "italic": 0.0, "skew": 0.0},
//     "180": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "215": {"depth": 0.08333, "height": 0.58333, "italic": 0.0, "skew": 0.0},
//     "247": {"depth": 0.08333, "height": 0.58333, "italic": 0.0, "skew": 0.0},
//     "305": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.02778},
//     "33": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "34": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "35": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "36": {"depth": 0.05556, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "37": {"depth": 0.05556, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "38": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "39": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "40": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "41": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "42": {"depth": 0.0, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "43": {"depth": 0.08333, "height": 0.58333, "italic": 0.0, "skew": 0.0},
//     "44": {"depth": 0.19444, "height": 0.10556, "italic": 0.0, "skew": 0.0},
//     "45": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "46": {"depth": 0.0, "height": 0.10556, "italic": 0.0, "skew": 0.0},
//     "47": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "48": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "49": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "50": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "51": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "52": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "53": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "54": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "55": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "56": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "567": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.08334},
//     "57": {"depth": 0.0, "height": 0.64444, "italic": 0.0, "skew": 0.0},
//     "58": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "59": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "60": {"depth": 0.0391, "height": 0.5391, "italic": 0.0, "skew": 0.0},
//     "61": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "62": {"depth": 0.0391, "height": 0.5391, "italic": 0.0, "skew": 0.0},
//     "63": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "64": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "65": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "66": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "67": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "68": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "69": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "70": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "71": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "710": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "711": {"depth": 0.0, "height": 0.62847, "italic": 0.0, "skew": 0.0},
//     "713": {"depth": 0.0, "height": 0.56778, "italic": 0.0, "skew": 0.0},
//     "714": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "715": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "72": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "728": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "729": {"depth": 0.0, "height": 0.66786, "italic": 0.0, "skew": 0.0},
//     "73": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "730": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "732": {"depth": 0.0, "height": 0.66786, "italic": 0.0, "skew": 0.0},
//     "74": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "75": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "76": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "768": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "769": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "77": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "770": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "771": {"depth": 0.0, "height": 0.66786, "italic": 0.0, "skew": 0.0},
//     "772": {"depth": 0.0, "height": 0.56778, "italic": 0.0, "skew": 0.0},
//     "774": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "775": {"depth": 0.0, "height": 0.66786, "italic": 0.0, "skew": 0.0},
//     "776": {"depth": 0.0, "height": 0.66786, "italic": 0.0, "skew": 0.0},
//     "778": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "779": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "78": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "780": {"depth": 0.0, "height": 0.62847, "italic": 0.0, "skew": 0.0},
//     "79": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "80": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "81": {"depth": 0.19444, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "82": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "8211": {"depth": 0.0, "height": 0.43056, "italic": 0.02778, "skew": 0.0},
//     "8212": {"depth": 0.0, "height": 0.43056, "italic": 0.02778, "skew": 0.0},
//     "8216": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8217": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8220": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8221": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8224": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8225": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "824": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8242": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "83": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "84": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "8407": {"depth": 0.0, "height": 0.71444, "italic": 0.15382, "skew": 0.0},
//     "8463": {"depth": 0.0, "height": 0.68889, "italic": 0.0, "skew": 0.0},
//     "8465": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8467": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.11111},
//     "8472": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.11111},
//     "8476": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "85": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "8501": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8592": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8593": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8594": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8595": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8596": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8597": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8598": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8599": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "86": {"depth": 0.0, "height": 0.68333, "italic": 0.01389, "skew": 0.0},
//     "8600": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8601": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8636": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8637": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8640": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8641": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8656": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8657": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8658": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8659": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8660": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8661": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "87": {"depth": 0.0, "height": 0.68333, "italic": 0.01389, "skew": 0.0},
//     "8704": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8706": {"depth": 0.0, "height": 0.69444, "italic": 0.05556, "skew": 0.08334},
//     "8707": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8709": {"depth": 0.05556, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8711": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "8712": {"depth": 0.0391, "height": 0.5391, "italic": 0.0, "skew": 0.0},
//     "8715": {"depth": 0.0391, "height": 0.5391, "italic": 0.0, "skew": 0.0},
//     "8722": {"depth": 0.08333, "height": 0.58333, "italic": 0.0, "skew": 0.0},
//     "8723": {"depth": 0.08333, "height": 0.58333, "italic": 0.0, "skew": 0.0},
//     "8725": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8726": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8727": {"depth": -0.03472, "height": 0.46528, "italic": 0.0, "skew": 0.0},
//     "8728": {"depth": -0.05555, "height": 0.44445, "italic": 0.0, "skew": 0.0},
//     "8729": {"depth": -0.05555, "height": 0.44445, "italic": 0.0, "skew": 0.0},
//     "8730": {"depth": 0.2, "height": 0.8, "italic": 0.0, "skew": 0.0},
//     "8733": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "8734": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "8736": {"depth": 0.0, "height": 0.69224, "italic": 0.0, "skew": 0.0},
//     "8739": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8741": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8743": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "8744": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "8745": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "8746": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "8747": {"depth": 0.19444, "height": 0.69444, "italic": 0.11111, "skew": 0.0},
//     "8764": {"depth": -0.13313, "height": 0.36687, "italic": 0.0, "skew": 0.0},
//     "8768": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8771": {"depth": -0.03625, "height": 0.46375, "italic": 0.0, "skew": 0.0},
//     "8776": {"depth": -0.01688, "height": 0.48312, "italic": 0.0, "skew": 0.0},
//     "8781": {"depth": -0.03625, "height": 0.46375, "italic": 0.0, "skew": 0.0},
//     "88": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "8801": {"depth": -0.03625, "height": 0.46375, "italic": 0.0, "skew": 0.0},
//     "8804": {"depth": 0.13597, "height": 0.63597, "italic": 0.0, "skew": 0.0},
//     "8805": {"depth": 0.13597, "height": 0.63597, "italic": 0.0, "skew": 0.0},
//     "8810": {"depth": 0.0391, "height": 0.5391, "italic": 0.0, "skew": 0.0},
//     "8811": {"depth": 0.0391, "height": 0.5391, "italic": 0.0, "skew": 0.0},
//     "8826": {"depth": 0.0391, "height": 0.5391, "italic": 0.0, "skew": 0.0},
//     "8827": {"depth": 0.0391, "height": 0.5391, "italic": 0.0, "skew": 0.0},
//     "8834": {"depth": 0.0391, "height": 0.5391, "italic": 0.0, "skew": 0.0},
//     "8835": {"depth": 0.0391, "height": 0.5391, "italic": 0.0, "skew": 0.0},
//     "8838": {"depth": 0.13597, "height": 0.63597, "italic": 0.0, "skew": 0.0},
//     "8839": {"depth": 0.13597, "height": 0.63597, "italic": 0.0, "skew": 0.0},
//     "8846": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "8849": {"depth": 0.13597, "height": 0.63597, "italic": 0.0, "skew": 0.0},
//     "8850": {"depth": 0.13597, "height": 0.63597, "italic": 0.0, "skew": 0.0},
//     "8851": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "8852": {"depth": 0.0, "height": 0.55556, "italic": 0.0, "skew": 0.0},
//     "8853": {"depth": 0.08333, "height": 0.58333, "italic": 0.0, "skew": 0.0},
//     "8854": {"depth": 0.08333, "height": 0.58333, "italic": 0.0, "skew": 0.0},
//     "8855": {"depth": 0.08333, "height": 0.58333, "italic": 0.0, "skew": 0.0},
//     "8856": {"depth": 0.08333, "height": 0.58333, "italic": 0.0, "skew": 0.0},
//     "8857": {"depth": 0.08333, "height": 0.58333, "italic": 0.0, "skew": 0.0},
//     "8866": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8867": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8868": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "8869": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "89": {"depth": 0.0, "height": 0.68333, "italic": 0.025, "skew": 0.0},
//     "8900": {"depth": -0.05555, "height": 0.44445, "italic": 0.0, "skew": 0.0},
//     "8901": {"depth": -0.05555, "height": 0.44445, "italic": 0.0, "skew": 0.0},
//     "8902": {"depth": -0.03472, "height": 0.46528, "italic": 0.0, "skew": 0.0},
//     "8968": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8969": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8970": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8971": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8994": {"depth": -0.14236, "height": 0.35764, "italic": 0.0, "skew": 0.0},
//     "8995": {"depth": -0.14236, "height": 0.35764, "italic": 0.0, "skew": 0.0},
//     "90": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "91": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "915": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "916": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "92": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "920": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "923": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "926": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "928": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "93": {"depth": 0.25, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "931": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "933": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "934": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "936": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "937": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.0},
//     "94": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "95": {"depth": 0.31, "height": 0.12056, "italic": 0.02778, "skew": 0.0},
//     "96": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9651": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9657": {"depth": -0.03472, "height": 0.46528, "italic": 0.0, "skew": 0.0},
//     "9661": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9667": {"depth": -0.03472, "height": 0.46528, "italic": 0.0, "skew": 0.0},
//     "97": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "9711": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "98": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9824": {"depth": 0.12963, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9825": {"depth": 0.12963, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9826": {"depth": 0.12963, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9827": {"depth": 0.12963, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9837": {"depth": 0.0, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "9838": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "9839": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "99": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0}
//   },
//   "Math-BoldItalic": {
//     "100": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "1009": {"depth": 0.19444, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "101": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "1013": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "102": {"depth": 0.19444, "height": 0.69444, "italic": 0.11042, "skew": 0.0},
//     "103": {"depth": 0.19444, "height": 0.44444, "italic": 0.03704, "skew": 0.0},
//     "104": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "105": {"depth": 0.0, "height": 0.69326, "italic": 0.0, "skew": 0.0},
//     "106": {"depth": 0.19444, "height": 0.69326, "italic": 0.0622, "skew": 0.0},
//     "107": {"depth": 0.0, "height": 0.69444, "italic": 0.01852, "skew": 0.0},
//     "108": {"depth": 0.0, "height": 0.69444, "italic": 0.0088, "skew": 0.0},
//     "109": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "110": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "111": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "112": {"depth": 0.19444, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "113": {"depth": 0.19444, "height": 0.44444, "italic": 0.03704, "skew": 0.0},
//     "114": {"depth": 0.0, "height": 0.44444, "italic": 0.03194, "skew": 0.0},
//     "115": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "116": {"depth": 0.0, "height": 0.63492, "italic": 0.0, "skew": 0.0},
//     "117": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "118": {"depth": 0.0, "height": 0.44444, "italic": 0.03704, "skew": 0.0},
//     "119": {"depth": 0.0, "height": 0.44444, "italic": 0.02778, "skew": 0.0},
//     "120": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "121": {"depth": 0.19444, "height": 0.44444, "italic": 0.03704, "skew": 0.0},
//     "122": {"depth": 0.0, "height": 0.44444, "italic": 0.04213, "skew": 0.0},
//     "47": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "65": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "66": {"depth": 0.0, "height": 0.68611, "italic": 0.04835, "skew": 0.0},
//     "67": {"depth": 0.0, "height": 0.68611, "italic": 0.06979, "skew": 0.0},
//     "68": {"depth": 0.0, "height": 0.68611, "italic": 0.03194, "skew": 0.0},
//     "69": {"depth": 0.0, "height": 0.68611, "italic": 0.05451, "skew": 0.0},
//     "70": {"depth": 0.0, "height": 0.68611, "italic": 0.15972, "skew": 0.0},
//     "71": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "72": {"depth": 0.0, "height": 0.68611, "italic": 0.08229, "skew": 0.0},
//     "73": {"depth": 0.0, "height": 0.68611, "italic": 0.07778, "skew": 0.0},
//     "74": {"depth": 0.0, "height": 0.68611, "italic": 0.10069, "skew": 0.0},
//     "75": {"depth": 0.0, "height": 0.68611, "italic": 0.06979, "skew": 0.0},
//     "76": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "77": {"depth": 0.0, "height": 0.68611, "italic": 0.11424, "skew": 0.0},
//     "78": {"depth": 0.0, "height": 0.68611, "italic": 0.11424, "skew": 0.0},
//     "79": {"depth": 0.0, "height": 0.68611, "italic": 0.03194, "skew": 0.0},
//     "80": {"depth": 0.0, "height": 0.68611, "italic": 0.15972, "skew": 0.0},
//     "81": {"depth": 0.19444, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "82": {"depth": 0.0, "height": 0.68611, "italic": 0.00421, "skew": 0.0},
//     "83": {"depth": 0.0, "height": 0.68611, "italic": 0.05382, "skew": 0.0},
//     "84": {"depth": 0.0, "height": 0.68611, "italic": 0.15972, "skew": 0.0},
//     "85": {"depth": 0.0, "height": 0.68611, "italic": 0.11424, "skew": 0.0},
//     "86": {"depth": 0.0, "height": 0.68611, "italic": 0.25555, "skew": 0.0},
//     "87": {"depth": 0.0, "height": 0.68611, "italic": 0.15972, "skew": 0.0},
//     "88": {"depth": 0.0, "height": 0.68611, "italic": 0.07778, "skew": 0.0},
//     "89": {"depth": 0.0, "height": 0.68611, "italic": 0.25555, "skew": 0.0},
//     "90": {"depth": 0.0, "height": 0.68611, "italic": 0.06979, "skew": 0.0},
//     "915": {"depth": 0.0, "height": 0.68611, "italic": 0.15972, "skew": 0.0},
//     "916": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "920": {"depth": 0.0, "height": 0.68611, "italic": 0.03194, "skew": 0.0},
//     "923": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "926": {"depth": 0.0, "height": 0.68611, "italic": 0.07458, "skew": 0.0},
//     "928": {"depth": 0.0, "height": 0.68611, "italic": 0.08229, "skew": 0.0},
//     "931": {"depth": 0.0, "height": 0.68611, "italic": 0.05451, "skew": 0.0},
//     "933": {"depth": 0.0, "height": 0.68611, "italic": 0.15972, "skew": 0.0},
//     "934": {"depth": 0.0, "height": 0.68611, "italic": 0.0, "skew": 0.0},
//     "936": {"depth": 0.0, "height": 0.68611, "italic": 0.11653, "skew": 0.0},
//     "937": {"depth": 0.0, "height": 0.68611, "italic": 0.04835, "skew": 0.0},
//     "945": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "946": {"depth": 0.19444, "height": 0.69444, "italic": 0.03403, "skew": 0.0},
//     "947": {"depth": 0.19444, "height": 0.44444, "italic": 0.06389, "skew": 0.0},
//     "948": {"depth": 0.0, "height": 0.69444, "italic": 0.03819, "skew": 0.0},
//     "949": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "950": {"depth": 0.19444, "height": 0.69444, "italic": 0.06215, "skew": 0.0},
//     "951": {"depth": 0.19444, "height": 0.44444, "italic": 0.03704, "skew": 0.0},
//     "952": {"depth": 0.0, "height": 0.69444, "italic": 0.03194, "skew": 0.0},
//     "953": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "954": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "955": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "956": {"depth": 0.19444, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "957": {"depth": 0.0, "height": 0.44444, "italic": 0.06898, "skew": 0.0},
//     "958": {"depth": 0.19444, "height": 0.69444, "italic": 0.03021, "skew": 0.0},
//     "959": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "960": {"depth": 0.0, "height": 0.44444, "italic": 0.03704, "skew": 0.0},
//     "961": {"depth": 0.19444, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "962": {"depth": 0.09722, "height": 0.44444, "italic": 0.07917, "skew": 0.0},
//     "963": {"depth": 0.0, "height": 0.44444, "italic": 0.03704, "skew": 0.0},
//     "964": {"depth": 0.0, "height": 0.44444, "italic": 0.13472, "skew": 0.0},
//     "965": {"depth": 0.0, "height": 0.44444, "italic": 0.03704, "skew": 0.0},
//     "966": {"depth": 0.19444, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "967": {"depth": 0.19444, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "968": {"depth": 0.19444, "height": 0.69444, "italic": 0.03704, "skew": 0.0},
//     "969": {"depth": 0.0, "height": 0.44444, "italic": 0.03704, "skew": 0.0},
//     "97": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0},
//     "977": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "98": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "981": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "982": {"depth": 0.0, "height": 0.44444, "italic": 0.03194, "skew": 0.0},
//     "99": {"depth": 0.0, "height": 0.44444, "italic": 0.0, "skew": 0.0}
//   },
//   "Math-Italic": {
//     "100": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.16667},
//     "1009": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.08334},
//     "101": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.05556},
//     "1013": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.05556},
//     "102": {"depth": 0.19444, "height": 0.69444, "italic": 0.10764, "skew": 0.16667},
//     "103": {"depth": 0.19444, "height": 0.43056, "italic": 0.03588, "skew": 0.02778},
//     "104": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "105": {"depth": 0.0, "height": 0.65952, "italic": 0.0, "skew": 0.0},
//     "106": {"depth": 0.19444, "height": 0.65952, "italic": 0.05724, "skew": 0.0},
//     "107": {"depth": 0.0, "height": 0.69444, "italic": 0.03148, "skew": 0.0},
//     "108": {"depth": 0.0, "height": 0.69444, "italic": 0.01968, "skew": 0.08334},
//     "109": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "110": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "111": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.05556},
//     "112": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.08334},
//     "113": {"depth": 0.19444, "height": 0.43056, "italic": 0.03588, "skew": 0.08334},
//     "114": {"depth": 0.0, "height": 0.43056, "italic": 0.02778, "skew": 0.05556},
//     "115": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.05556},
//     "116": {"depth": 0.0, "height": 0.61508, "italic": 0.0, "skew": 0.08334},
//     "117": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.02778},
//     "118": {"depth": 0.0, "height": 0.43056, "italic": 0.03588, "skew": 0.02778},
//     "119": {"depth": 0.0, "height": 0.43056, "italic": 0.02691, "skew": 0.08334},
//     "120": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.02778},
//     "121": {"depth": 0.19444, "height": 0.43056, "italic": 0.03588, "skew": 0.05556},
//     "122": {"depth": 0.0, "height": 0.43056, "italic": 0.04398, "skew": 0.05556},
//     "47": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "65": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.13889},
//     "66": {"depth": 0.0, "height": 0.68333, "italic": 0.05017, "skew": 0.08334},
//     "67": {"depth": 0.0, "height": 0.68333, "italic": 0.07153, "skew": 0.08334},
//     "68": {"depth": 0.0, "height": 0.68333, "italic": 0.02778, "skew": 0.05556},
//     "69": {"depth": 0.0, "height": 0.68333, "italic": 0.05764, "skew": 0.08334},
//     "70": {"depth": 0.0, "height": 0.68333, "italic": 0.13889, "skew": 0.08334},
//     "71": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.08334},
//     "72": {"depth": 0.0, "height": 0.68333, "italic": 0.08125, "skew": 0.05556},
//     "73": {"depth": 0.0, "height": 0.68333, "italic": 0.07847, "skew": 0.11111},
//     "74": {"depth": 0.0, "height": 0.68333, "italic": 0.09618, "skew": 0.16667},
//     "75": {"depth": 0.0, "height": 0.68333, "italic": 0.07153, "skew": 0.05556},
//     "76": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.02778},
//     "77": {"depth": 0.0, "height": 0.68333, "italic": 0.10903, "skew": 0.08334},
//     "78": {"depth": 0.0, "height": 0.68333, "italic": 0.10903, "skew": 0.08334},
//     "79": {"depth": 0.0, "height": 0.68333, "italic": 0.02778, "skew": 0.08334},
//     "80": {"depth": 0.0, "height": 0.68333, "italic": 0.13889, "skew": 0.08334},
//     "81": {"depth": 0.19444, "height": 0.68333, "italic": 0.0, "skew": 0.08334},
//     "82": {"depth": 0.0, "height": 0.68333, "italic": 0.00773, "skew": 0.08334},
//     "83": {"depth": 0.0, "height": 0.68333, "italic": 0.05764, "skew": 0.08334},
//     "84": {"depth": 0.0, "height": 0.68333, "italic": 0.13889, "skew": 0.08334},
//     "85": {"depth": 0.0, "height": 0.68333, "italic": 0.10903, "skew": 0.02778},
//     "86": {"depth": 0.0, "height": 0.68333, "italic": 0.22222, "skew": 0.0},
//     "87": {"depth": 0.0, "height": 0.68333, "italic": 0.13889, "skew": 0.0},
//     "88": {"depth": 0.0, "height": 0.68333, "italic": 0.07847, "skew": 0.08334},
//     "89": {"depth": 0.0, "height": 0.68333, "italic": 0.22222, "skew": 0.0},
//     "90": {"depth": 0.0, "height": 0.68333, "italic": 0.07153, "skew": 0.08334},
//     "915": {"depth": 0.0, "height": 0.68333, "italic": 0.13889, "skew": 0.08334},
//     "916": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.16667},
//     "920": {"depth": 0.0, "height": 0.68333, "italic": 0.02778, "skew": 0.08334},
//     "923": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.16667},
//     "926": {"depth": 0.0, "height": 0.68333, "italic": 0.07569, "skew": 0.08334},
//     "928": {"depth": 0.0, "height": 0.68333, "italic": 0.08125, "skew": 0.05556},
//     "931": {"depth": 0.0, "height": 0.68333, "italic": 0.05764, "skew": 0.08334},
//     "933": {"depth": 0.0, "height": 0.68333, "italic": 0.13889, "skew": 0.05556},
//     "934": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.08334},
//     "936": {"depth": 0.0, "height": 0.68333, "italic": 0.11, "skew": 0.05556},
//     "937": {"depth": 0.0, "height": 0.68333, "italic": 0.05017, "skew": 0.08334},
//     "945": {"depth": 0.0, "height": 0.43056, "italic": 0.0037, "skew": 0.02778},
//     "946": {"depth": 0.19444, "height": 0.69444, "italic": 0.05278, "skew": 0.08334},
//     "947": {"depth": 0.19444, "height": 0.43056, "italic": 0.05556, "skew": 0.0},
//     "948": {"depth": 0.0, "height": 0.69444, "italic": 0.03785, "skew": 0.05556},
//     "949": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.08334},
//     "950": {"depth": 0.19444, "height": 0.69444, "italic": 0.07378, "skew": 0.08334},
//     "951": {"depth": 0.19444, "height": 0.43056, "italic": 0.03588, "skew": 0.05556},
//     "952": {"depth": 0.0, "height": 0.69444, "italic": 0.02778, "skew": 0.08334},
//     "953": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.05556},
//     "954": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "955": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "956": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.02778},
//     "957": {"depth": 0.0, "height": 0.43056, "italic": 0.06366, "skew": 0.02778},
//     "958": {"depth": 0.19444, "height": 0.69444, "italic": 0.04601, "skew": 0.11111},
//     "959": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.05556},
//     "960": {"depth": 0.0, "height": 0.43056, "italic": 0.03588, "skew": 0.0},
//     "961": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.08334},
//     "962": {"depth": 0.09722, "height": 0.43056, "italic": 0.07986, "skew": 0.08334},
//     "963": {"depth": 0.0, "height": 0.43056, "italic": 0.03588, "skew": 0.0},
//     "964": {"depth": 0.0, "height": 0.43056, "italic": 0.1132, "skew": 0.02778},
//     "965": {"depth": 0.0, "height": 0.43056, "italic": 0.03588, "skew": 0.02778},
//     "966": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.08334},
//     "967": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.05556},
//     "968": {"depth": 0.19444, "height": 0.69444, "italic": 0.03588, "skew": 0.11111},
//     "969": {"depth": 0.0, "height": 0.43056, "italic": 0.03588, "skew": 0.0},
//     "97": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "977": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.08334},
//     "98": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "981": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.08334},
//     "982": {"depth": 0.0, "height": 0.43056, "italic": 0.02778, "skew": 0.0},
//     "99": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.05556}
//   },
//   "Math-Regular": {
//     "100": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.16667},
//     "1009": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.08334},
//     "101": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.05556},
//     "1013": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.05556},
//     "102": {"depth": 0.19444, "height": 0.69444, "italic": 0.10764, "skew": 0.16667},
//     "103": {"depth": 0.19444, "height": 0.43056, "italic": 0.03588, "skew": 0.02778},
//     "104": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "105": {"depth": 0.0, "height": 0.65952, "italic": 0.0, "skew": 0.0},
//     "106": {"depth": 0.19444, "height": 0.65952, "italic": 0.05724, "skew": 0.0},
//     "107": {"depth": 0.0, "height": 0.69444, "italic": 0.03148, "skew": 0.0},
//     "108": {"depth": 0.0, "height": 0.69444, "italic": 0.01968, "skew": 0.08334},
//     "109": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "110": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "111": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.05556},
//     "112": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.08334},
//     "113": {"depth": 0.19444, "height": 0.43056, "italic": 0.03588, "skew": 0.08334},
//     "114": {"depth": 0.0, "height": 0.43056, "italic": 0.02778, "skew": 0.05556},
//     "115": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.05556},
//     "116": {"depth": 0.0, "height": 0.61508, "italic": 0.0, "skew": 0.08334},
//     "117": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.02778},
//     "118": {"depth": 0.0, "height": 0.43056, "italic": 0.03588, "skew": 0.02778},
//     "119": {"depth": 0.0, "height": 0.43056, "italic": 0.02691, "skew": 0.08334},
//     "120": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.02778},
//     "121": {"depth": 0.19444, "height": 0.43056, "italic": 0.03588, "skew": 0.05556},
//     "122": {"depth": 0.0, "height": 0.43056, "italic": 0.04398, "skew": 0.05556},
//     "65": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.13889},
//     "66": {"depth": 0.0, "height": 0.68333, "italic": 0.05017, "skew": 0.08334},
//     "67": {"depth": 0.0, "height": 0.68333, "italic": 0.07153, "skew": 0.08334},
//     "68": {"depth": 0.0, "height": 0.68333, "italic": 0.02778, "skew": 0.05556},
//     "69": {"depth": 0.0, "height": 0.68333, "italic": 0.05764, "skew": 0.08334},
//     "70": {"depth": 0.0, "height": 0.68333, "italic": 0.13889, "skew": 0.08334},
//     "71": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.08334},
//     "72": {"depth": 0.0, "height": 0.68333, "italic": 0.08125, "skew": 0.05556},
//     "73": {"depth": 0.0, "height": 0.68333, "italic": 0.07847, "skew": 0.11111},
//     "74": {"depth": 0.0, "height": 0.68333, "italic": 0.09618, "skew": 0.16667},
//     "75": {"depth": 0.0, "height": 0.68333, "italic": 0.07153, "skew": 0.05556},
//     "76": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.02778},
//     "77": {"depth": 0.0, "height": 0.68333, "italic": 0.10903, "skew": 0.08334},
//     "78": {"depth": 0.0, "height": 0.68333, "italic": 0.10903, "skew": 0.08334},
//     "79": {"depth": 0.0, "height": 0.68333, "italic": 0.02778, "skew": 0.08334},
//     "80": {"depth": 0.0, "height": 0.68333, "italic": 0.13889, "skew": 0.08334},
//     "81": {"depth": 0.19444, "height": 0.68333, "italic": 0.0, "skew": 0.08334},
//     "82": {"depth": 0.0, "height": 0.68333, "italic": 0.00773, "skew": 0.08334},
//     "83": {"depth": 0.0, "height": 0.68333, "italic": 0.05764, "skew": 0.08334},
//     "84": {"depth": 0.0, "height": 0.68333, "italic": 0.13889, "skew": 0.08334},
//     "85": {"depth": 0.0, "height": 0.68333, "italic": 0.10903, "skew": 0.02778},
//     "86": {"depth": 0.0, "height": 0.68333, "italic": 0.22222, "skew": 0.0},
//     "87": {"depth": 0.0, "height": 0.68333, "italic": 0.13889, "skew": 0.0},
//     "88": {"depth": 0.0, "height": 0.68333, "italic": 0.07847, "skew": 0.08334},
//     "89": {"depth": 0.0, "height": 0.68333, "italic": 0.22222, "skew": 0.0},
//     "90": {"depth": 0.0, "height": 0.68333, "italic": 0.07153, "skew": 0.08334},
//     "915": {"depth": 0.0, "height": 0.68333, "italic": 0.13889, "skew": 0.08334},
//     "916": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.16667},
//     "920": {"depth": 0.0, "height": 0.68333, "italic": 0.02778, "skew": 0.08334},
//     "923": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.16667},
//     "926": {"depth": 0.0, "height": 0.68333, "italic": 0.07569, "skew": 0.08334},
//     "928": {"depth": 0.0, "height": 0.68333, "italic": 0.08125, "skew": 0.05556},
//     "931": {"depth": 0.0, "height": 0.68333, "italic": 0.05764, "skew": 0.08334},
//     "933": {"depth": 0.0, "height": 0.68333, "italic": 0.13889, "skew": 0.05556},
//     "934": {"depth": 0.0, "height": 0.68333, "italic": 0.0, "skew": 0.08334},
//     "936": {"depth": 0.0, "height": 0.68333, "italic": 0.11, "skew": 0.05556},
//     "937": {"depth": 0.0, "height": 0.68333, "italic": 0.05017, "skew": 0.08334},
//     "945": {"depth": 0.0, "height": 0.43056, "italic": 0.0037, "skew": 0.02778},
//     "946": {"depth": 0.19444, "height": 0.69444, "italic": 0.05278, "skew": 0.08334},
//     "947": {"depth": 0.19444, "height": 0.43056, "italic": 0.05556, "skew": 0.0},
//     "948": {"depth": 0.0, "height": 0.69444, "italic": 0.03785, "skew": 0.05556},
//     "949": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.08334},
//     "950": {"depth": 0.19444, "height": 0.69444, "italic": 0.07378, "skew": 0.08334},
//     "951": {"depth": 0.19444, "height": 0.43056, "italic": 0.03588, "skew": 0.05556},
//     "952": {"depth": 0.0, "height": 0.69444, "italic": 0.02778, "skew": 0.08334},
//     "953": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.05556},
//     "954": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "955": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "956": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.02778},
//     "957": {"depth": 0.0, "height": 0.43056, "italic": 0.06366, "skew": 0.02778},
//     "958": {"depth": 0.19444, "height": 0.69444, "italic": 0.04601, "skew": 0.11111},
//     "959": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.05556},
//     "960": {"depth": 0.0, "height": 0.43056, "italic": 0.03588, "skew": 0.0},
//     "961": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.08334},
//     "962": {"depth": 0.09722, "height": 0.43056, "italic": 0.07986, "skew": 0.08334},
//     "963": {"depth": 0.0, "height": 0.43056, "italic": 0.03588, "skew": 0.0},
//     "964": {"depth": 0.0, "height": 0.43056, "italic": 0.1132, "skew": 0.02778},
//     "965": {"depth": 0.0, "height": 0.43056, "italic": 0.03588, "skew": 0.02778},
//     "966": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.08334},
//     "967": {"depth": 0.19444, "height": 0.43056, "italic": 0.0, "skew": 0.05556},
//     "968": {"depth": 0.19444, "height": 0.69444, "italic": 0.03588, "skew": 0.11111},
//     "969": {"depth": 0.0, "height": 0.43056, "italic": 0.03588, "skew": 0.0},
//     "97": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.0},
//     "977": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.08334},
//     "98": {"depth": 0.0, "height": 0.69444, "italic": 0.0, "skew": 0.0},
//     "981": {"depth": 0.19444, "height": 0.69444, "italic": 0.0, "skew": 0.08334},
//     "982": {"depth": 0.0, "height": 0.43056, "italic": 0.02778, "skew": 0.0},
//     "99": {"depth": 0.0, "height": 0.43056, "italic": 0.0, "skew": 0.05556}
//   },
//   "Size1-Regular": {
//     "8748": {"depth": 0.306, "height": 0.805, "italic": 0.19445, "skew": 0.0},
//     "8749": {"depth": 0.306, "height": 0.805, "italic": 0.19445, "skew": 0.0},
//     "10216": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0},
//     "10217": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0},
//     "10752": {"depth": 0.25001, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "10753": {"depth": 0.25001, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "10754": {"depth": 0.25001, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "10756": {"depth": 0.25001, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "10758": {"depth": 0.25001, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "123": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0},
//     "125": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0},
//     "40": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0},
//     "41": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0},
//     "47": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0},
//     "710": {"depth": 0.0, "height": 0.72222, "italic": 0.0, "skew": 0.0},
//     "732": {"depth": 0.0, "height": 0.72222, "italic": 0.0, "skew": 0.0},
//     "770": {"depth": 0.0, "height": 0.72222, "italic": 0.0, "skew": 0.0},
//     "771": {"depth": 0.0, "height": 0.72222, "italic": 0.0, "skew": 0.0},
//     "8214": {"depth": -0.00099, "height": 0.601, "italic": 0.0, "skew": 0.0},
//     "8593": {"depth": 1e-05, "height": 0.6, "italic": 0.0, "skew": 0.0},
//     "8595": {"depth": 1e-05, "height": 0.6, "italic": 0.0, "skew": 0.0},
//     "8657": {"depth": 1e-05, "height": 0.6, "italic": 0.0, "skew": 0.0},
//     "8659": {"depth": 1e-05, "height": 0.6, "italic": 0.0, "skew": 0.0},
//     "8719": {"depth": 0.25001, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8720": {"depth": 0.25001, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8721": {"depth": 0.25001, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8730": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0},
//     "8739": {"depth": -0.00599, "height": 0.606, "italic": 0.0, "skew": 0.0},
//     "8741": {"depth": -0.00599, "height": 0.606, "italic": 0.0, "skew": 0.0},
//     "8747": {"depth": 0.30612, "height": 0.805, "italic": 0.19445, "skew": 0.0},
//     "8750": {"depth": 0.30612, "height": 0.805, "italic": 0.19445, "skew": 0.0},
//     "8896": {"depth": 0.25001, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8897": {"depth": 0.25001, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8898": {"depth": 0.25001, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8899": {"depth": 0.25001, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8968": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0},
//     "8969": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0},
//     "8970": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0},
//     "8971": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0},
//     "91": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0},
//     "9168": {"depth": -0.00099, "height": 0.601, "italic": 0.0, "skew": 0.0},
//     "92": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0},
//     "93": {"depth": 0.35001, "height": 0.85, "italic": 0.0, "skew": 0.0}
//   },
//   "Size2-Regular": {
//     "8748": {"depth": 0.862, "height": 1.36, "italic": 0.44445, "skew": 0.0},
//     "8749": {"depth": 0.862, "height": 1.36, "italic": 0.44445, "skew": 0.0},
//     "10216": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "10217": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "10752": {"depth": 0.55001, "height": 1.05, "italic": 0.0, "skew": 0.0},
//     "10753": {"depth": 0.55001, "height": 1.05, "italic": 0.0, "skew": 0.0},
//     "10754": {"depth": 0.55001, "height": 1.05, "italic": 0.0, "skew": 0.0},
//     "10756": {"depth": 0.55001, "height": 1.05, "italic": 0.0, "skew": 0.0},
//     "10758": {"depth": 0.55001, "height": 1.05, "italic": 0.0, "skew": 0.0},
//     "123": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "125": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "40": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "41": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "47": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "710": {"depth": 0.0, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "732": {"depth": 0.0, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "770": {"depth": 0.0, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "771": {"depth": 0.0, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8719": {"depth": 0.55001, "height": 1.05, "italic": 0.0, "skew": 0.0},
//     "8720": {"depth": 0.55001, "height": 1.05, "italic": 0.0, "skew": 0.0},
//     "8721": {"depth": 0.55001, "height": 1.05, "italic": 0.0, "skew": 0.0},
//     "8730": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "8747": {"depth": 0.86225, "height": 1.36, "italic": 0.44445, "skew": 0.0},
//     "8750": {"depth": 0.86225, "height": 1.36, "italic": 0.44445, "skew": 0.0},
//     "8896": {"depth": 0.55001, "height": 1.05, "italic": 0.0, "skew": 0.0},
//     "8897": {"depth": 0.55001, "height": 1.05, "italic": 0.0, "skew": 0.0},
//     "8898": {"depth": 0.55001, "height": 1.05, "italic": 0.0, "skew": 0.0},
//     "8899": {"depth": 0.55001, "height": 1.05, "italic": 0.0, "skew": 0.0},
//     "8968": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "8969": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "8970": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "8971": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "91": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "92": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "93": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0}
//   },
//   "Size3-Regular": {
//     "10216": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0},
//     "10217": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0},
//     "123": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0},
//     "125": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0},
//     "40": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0},
//     "41": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0},
//     "47": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0},
//     "710": {"depth": 0.0, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "732": {"depth": 0.0, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "770": {"depth": 0.0, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "771": {"depth": 0.0, "height": 0.75, "italic": 0.0, "skew": 0.0},
//     "8730": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0},
//     "8968": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0},
//     "8969": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0},
//     "8970": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0},
//     "8971": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0},
//     "91": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0},
//     "92": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0},
//     "93": {"depth": 0.95003, "height": 1.45, "italic": 0.0, "skew": 0.0}
//   },
//   "Size4-Regular": {
//     "10216": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0},
//     "10217": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0},
//     "123": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0},
//     "125": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0},
//     "40": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0},
//     "41": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0},
//     "47": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0},
//     "57344": {"depth": -0.00499, "height": 0.605, "italic": 0.0, "skew": 0.0},
//     "57345": {"depth": -0.00499, "height": 0.605, "italic": 0.0, "skew": 0.0},
//     "57680": {"depth": 0.0, "height": 0.12, "italic": 0.0, "skew": 0.0},
//     "57681": {"depth": 0.0, "height": 0.12, "italic": 0.0, "skew": 0.0},
//     "57682": {"depth": 0.0, "height": 0.12, "italic": 0.0, "skew": 0.0},
//     "57683": {"depth": 0.0, "height": 0.12, "italic": 0.0, "skew": 0.0},
//     "710": {"depth": 0.0, "height": 0.825, "italic": 0.0, "skew": 0.0},
//     "732": {"depth": 0.0, "height": 0.825, "italic": 0.0, "skew": 0.0},
//     "770": {"depth": 0.0, "height": 0.825, "italic": 0.0, "skew": 0.0},
//     "771": {"depth": 0.0, "height": 0.825, "italic": 0.0, "skew": 0.0},
//     "8730": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0},
//     "8968": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0},
//     "8969": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0},
//     "8970": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0},
//     "8971": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0},
//     "91": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0},
//     "9115": {"depth": 0.64502, "height": 1.155, "italic": 0.0, "skew": 0.0},
//     "9116": {"depth": 1e-05, "height": 0.6, "italic": 0.0, "skew": 0.0},
//     "9117": {"depth": 0.64502, "height": 1.155, "italic": 0.0, "skew": 0.0},
//     "9118": {"depth": 0.64502, "height": 1.155, "italic": 0.0, "skew": 0.0},
//     "9119": {"depth": 1e-05, "height": 0.6, "italic": 0.0, "skew": 0.0},
//     "9120": {"depth": 0.64502, "height": 1.155, "italic": 0.0, "skew": 0.0},
//     "9121": {"depth": 0.64502, "height": 1.155, "italic": 0.0, "skew": 0.0},
//     "9122": {"depth": -0.00099, "height": 0.601, "italic": 0.0, "skew": 0.0},
//     "9123": {"depth": 0.64502, "height": 1.155, "italic": 0.0, "skew": 0.0},
//     "9124": {"depth": 0.64502, "height": 1.155, "italic": 0.0, "skew": 0.0},
//     "9125": {"depth": -0.00099, "height": 0.601, "italic": 0.0, "skew": 0.0},
//     "9126": {"depth": 0.64502, "height": 1.155, "italic": 0.0, "skew": 0.0},
//     "9127": {"depth": 1e-05, "height": 0.9, "italic": 0.0, "skew": 0.0},
//     "9128": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "9129": {"depth": 0.90001, "height": 0.0, "italic": 0.0, "skew": 0.0},
//     "9130": {"depth": 0.0, "height": 0.3, "italic": 0.0, "skew": 0.0},
//     "9131": {"depth": 1e-05, "height": 0.9, "italic": 0.0, "skew": 0.0},
//     "9132": {"depth": 0.65002, "height": 1.15, "italic": 0.0, "skew": 0.0},
//     "9133": {"depth": 0.90001, "height": 0.0, "italic": 0.0, "skew": 0.0},
//     "9143": {"depth": 0.88502, "height": 0.915, "italic": 0.0, "skew": 0.0},
//     "92": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0},
//     "93": {"depth": 1.25003, "height": 1.75, "italic": 0.0, "skew": 0.0}
//   }
// };
// /**
//  * Convience function for looking up information in the
//  * metricMap table.
//  */
// Map<String, num> getCharacterMetrics({String character, String style}) {
//   return metricMap[style][character.codeUnitAt(0).toString()];
// }

// // TODO(adamjcook): Add library description.
// library katex.symbols;
//
// import 'tex_symbol.dart';
//
// Map<String, Map<String, TexSymbol>> symbols = {
//   'math': {
//     '`': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2018'
//     ),
//     '\\\$': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: r'$'
//     ),
//     '\\%': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '%'
//     ),
//     '\\_': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '_'
//     ),
//     '\\angle': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2220'
//     ),
//     '\\infty': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u221e'
//     ),
//     '\\prime': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2032'
//     ),
//     '\\triangle': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u25b3'
//     ),
//     '\\Gamma': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u0393'
//     ),
//     '\\Delta': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u0394'
//     ),
//     '\\Theta': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u0398'
//     ),
//     '\\Lambda': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u039b'
//     ),
//     '\\Xi': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u039e'
//     ),
//     '\\Pi': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u03a0'
//     ),
//     '\\Sigma': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u03a3'
//     ),
//     '\\Upsilon': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u03a5'
//     ),
//     '\\Phi': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u03a6'
//     ),
//     '\\Psi': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u03a8'
//     ),
//     '\\Omega': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u03a9'
//     ),
//     '\\neg': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u00ac'
//     ),
//     '\\lnot': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u00ac'
//     ),
//     '\\top': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u22a4'
//     ),
//     '\\bot': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u22a5'
//     ),
//     '\\emptyset': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2205'
//     ),
//     '\\varnothing': new TexSymbol(
//         font: 'ams',
//         group: 'textord',
//         replace: '\u2205'
//     ),
//     '\\alpha': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03b1'
//     ),
//     '\\beta': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03b2'
//     ),
//     '\\gamma': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03b3'
//     ),
//     '\\delta': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03b4'
//     ),
//     '\\epsilon': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03f5'
//     ),
//     '\\zeta': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03b6'
//     ),
//     '\\eta': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03b7'
//     ),
//     '\\theta': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03b8'
//     ),
//     '\\iota': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03b9'
//     ),
//     '\\kappa': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03ba'
//     ),
//     '\\lambda': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03bb'
//     ),
//     '\\mu': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03bc'
//     ),
//     '\\nu': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03bd'
//     ),
//     '\\xi': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03be'
//     ),
//     '\\omicron': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: 'o'
//     ),
//     '\\pi': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03c0'
//     ),
//     '\\rho': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03c1'
//     ),
//     '\\sigma': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03c3'
//     ),
//     '\\tau': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03c4'
//     ),
//     '\\upsilon': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03c5'
//     ),
//     '\\phi': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03d5'
//     ),
//     '\\chi': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03c7'
//     ),
//     '\\psi': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03c8'
//     ),
//     '\\omega': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03c9'
//     ),
//     '\\varepsilon': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03b5'
//     ),
//     '\\vartheta': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03d1'
//     ),
//     '\\varpi': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03d6'
//     ),
//     '\\varrho': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03f1'
//     ),
//     '\\varsigma': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03c2'
//     ),
//     '\\varphi': new TexSymbol(
//         font: 'main',
//         group: 'mathord',
//         replace: '\u03c6'
//     ),
//     '*': new TexSymbol(
//         font: 'main',
//         group: 'bin',
//         replace: '\u2217'
//     ),
//     '+': new TexSymbol(
//         font: 'main',
//         group: 'bin'
//     ),
//     '-': new TexSymbol(
//         font: 'main',
//         group: 'bin',
//         replace: '\u2212'
//     ),
//     '\\cdot': new TexSymbol(
//         font: 'main',
//         group: 'bin',
//         replace: '\u22c5'
//     ),
//     '\\circ': new TexSymbol(
//         font: 'main',
//         group: 'bin',
//         replace: '\u2218'
//     ),
//     '\\div': new TexSymbol(
//         font: 'main',
//         group: 'bin',
//         replace: '\u00f7'
//     ),
//     '\\pm': new TexSymbol(
//         font: 'main',
//         group: 'bin',
//         replace: '\u00b1'
//     ),
//     '\\times': new TexSymbol(
//         font: 'main',
//         group: 'bin',
//         replace: '\u00d7'
//     ),
//     '\\cap': new TexSymbol(
//         font: 'main',
//         group: 'bin',
//         replace: '\u2229'
//     ),
//     '\\cup': new TexSymbol(
//         font: 'main',
//         group: 'bin',
//         replace: '\u222a'
//     ),
//     '\\setminus': new TexSymbol(
//         font: 'main',
//         group: 'bin',
//         replace: '\u2216'
//     ),
//     '\\land': new TexSymbol(
//         font: 'main',
//         group: 'bin',
//         replace: '\u2227'
//     ),
//     '\\lor': new TexSymbol(
//         font: 'main',
//         group: 'bin',
//         replace: '\u2228'
//     ),
//     '\\wedge': new TexSymbol(
//         font: 'main',
//         group: 'bin',
//         replace: '\u2227'
//     ),
//     '\\vee': new TexSymbol(
//         font: 'main',
//         group: 'bin',
//         replace: '\u2228'
//     ),
//     '\\surd': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u221a'
//     ),
//     '(': new TexSymbol(
//         font: 'main',
//         group: 'open'
//     ),
//     '[': new TexSymbol(
//         font: 'main',
//         group: 'open'
//     ),
//     '\\langle': new TexSymbol(
//         font: 'main',
//         group: 'open',
//         replace: '\u27e8'
//     ),
//     '\\lvert': new TexSymbol(
//         font: 'main',
//         group: 'open',
//         replace: '\u2223'
//     ),
//     ')': new TexSymbol(
//         font: 'main',
//         group: 'close'
//     ),
//     ']': new TexSymbol(
//         font: 'main',
//         group: 'close'
//     ),
//     '?': new TexSymbol(
//         font: 'main',
//         group: 'close'
//     ),
//     '!': new TexSymbol(
//         font: 'main',
//         group: 'close'
//     ),
//     '\\rangle': new TexSymbol(
//         font: 'main',
//         group: 'close',
//         replace: '\u27e9'
//     ),
//     '\\rvert': new TexSymbol(
//         font: 'main',
//         group: 'close',
//         replace: '\u2223'
//     ),
//     '=': new TexSymbol(
//         font: 'main',
//         group: 'rel'
//     ),
//     '<': new TexSymbol(
//         font: 'main',
//         group: 'rel'
//     ),
//     '>': new TexSymbol(
//         font: 'main',
//         group: 'rel'
//     ),
//     ':': new TexSymbol(
//         font: 'main',
//         group: 'rel'
//     ),
//     '\\approx': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2248'
//     ),
//     '\\cong': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2245'
//     ),
//     '\\ge': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2265'
//     ),
//     '\\geq': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2265'
//     ),
//     '\\gets': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2190'
//     ),
//     '\\in': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2208'
//     ),
//     '\\notin': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2209'
//     ),
//     '\\subset': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2282'
//     ),
//     '\\supset': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2283'
//     ),
//     '\\subseteq': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2286'
//     ),
//     '\\supseteq': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2287'
//     ),
//     '\\nsubseteq': new TexSymbol(
//         font: 'ams',
//         group: 'rel',
//         replace: '\u2288'
//     ),
//     '\\nsupseteq': new TexSymbol(
//         font: 'ams',
//         group: 'rel',
//         replace: '\u2289'
//     ),
//     '\\models': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u22a8'
//     ),
//     '\\leftarrow': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2190'
//     ),
//     '\\le': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2264'
//     ),
//     '\\leq': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2264'
//     ),
//     '\\ne': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2260'
//     ),
//     '\\neq': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2260'
//     ),
//     '\\rightarrow': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2192'
//     ),
//     '\\to': new TexSymbol(
//         font: 'main',
//         group: 'rel',
//         replace: '\u2192'
//     ),
//     '\\ngeq': new TexSymbol(
//         font: 'ams',
//         group: 'rel',
//         replace: '\u2271'
//     ),
//     '\\nleq': new TexSymbol(
//         font: 'ams',
//         group: 'rel',
//         replace: '\u2270'
//     ),
//     '\\!': new TexSymbol(
//         font: 'main',
//         group: 'spacing'
//     ),
//     '\\ ': new TexSymbol(
//         font: 'main',
//         group: 'spacing',
//         replace: '\u00a0'
//     ),
//     '~': new TexSymbol(
//         font: 'main',
//         group: 'spacing',
//         replace: '\u00a0'
//     ),
//     '\\,': new TexSymbol(
//         font: 'main',
//         group: 'spacing'
//     ),
//     '\\:': new TexSymbol(
//         font: 'main',
//         group: 'spacing'
//     ),
//     '\\;': new TexSymbol(
//         font: 'main',
//         group: 'spacing'
//     ),
//     '\\enspace': new TexSymbol(
//         font: 'main',
//         group: 'spacing'
//     ),
//     '\\qquad': new TexSymbol(
//         font: 'main',
//         group: 'spacing'
//     ),
//     '\\quad': new TexSymbol(
//         font: 'main',
//         group: 'spacing'
//     ),
//     '\\space': new TexSymbol(
//         font: 'main',
//         group: 'spacing',
//         replace: '\u00a0'
//     ),
//     ',': new TexSymbol(
//         font: 'main',
//         group: 'punct'
//     ),
//     ';': new TexSymbol(
//         font: 'main',
//         group: 'punct'
//     ),
//     '\\colon': new TexSymbol(
//         font: 'main',
//         group: 'punct',
//         replace: ':'
//     ),
//     '\\barwedge': new TexSymbol(
//         font: 'ams',
//         group: 'textord',
//         replace: '\u22bc'
//     ),
//     '\\veebar': new TexSymbol(
//         font: 'ams',
//         group: 'textord',
//         replace: '\u22bb'
//     ),
//     '\\odot': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2299'
//     ),
//     '\\oplus': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2295'
//     ),
//     '\\otimes': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2297'
//     ),
//     '\\partial': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2202'
//     ),
//     '\\oslash': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2298'
//     ),
//     '\\circledcirc': new TexSymbol(
//         font: 'ams',
//         group: 'textord',
//         replace: '\u229a'
//     ),
//     '\\boxdot': new TexSymbol(
//         font: 'ams',
//         group: 'textord',
//         replace: '\u22a1'
//     ),
//     '\\bigtriangleup': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u25b3'
//     ),
//     '\\bigtriangledown': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u25bd'
//     ),
//     '\\dagger': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2020'
//     ),
//     '\\diamond': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u22c4'
//     ),
//     '\\star': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u22c6'
//     ),
//     '\\triangleleft': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u25c3'
//     ),
//     '\\triangleright': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u25b9'
//     ),
//     '\\{': new TexSymbol(
//         font: 'main',
//         group: 'open',
//         replace: '{'
//     ),
//     '\\}': new TexSymbol(
//         font: 'main',
//         group: 'close',
//         replace: ')'
//     ),
//     '\\lbrace': new TexSymbol(
//         font: 'main',
//         group: 'open',
//         replace: '{'
//     ),
//     '\\rbrace': new TexSymbol(
//         font: 'main',
//         group: 'close',
//         replace: '}'
//     ),
//     '\\lbrack': new TexSymbol(
//         font: 'main',
//         group: 'open',
//         replace: '['
//     ),
//     '\\rbrack': new TexSymbol(
//         font: 'main',
//         group: 'close',
//         replace: ']'
//     ),
//     '\\lfloor': new TexSymbol(
//         font: 'main',
//         group: 'open',
//         replace: '\u230a'
//     ),
//     '\\rfloor': new TexSymbol(
//         font: 'main',
//         group: 'close',
//         replace: '\u230b'
//     ),
//     '\\lceil': new TexSymbol(
//         font: 'main',
//         group: 'open',
//         replace: '\u2308'
//     ),
//     '\\rceil': new TexSymbol(
//         font: 'main',
//         group: 'close',
//         replace: '\u2309'
//     ),
//     '\\backslash': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\\'
//     ),
//     '|': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2223'
//     ),
//     '\\vert': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2223'
//     ),
//     '\\|': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2225'
//     ),
//     '\\Vert': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2225'
//     ),
//     '\\uparrow': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2191'
//     ),
//     '\\Uparrow': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u21d1'
//     ),
//     '\\downarrow': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2193'
//     ),
//     '\\Downarrow': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u21d3'
//     ),
//     '\\updownarrow': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u2195'
//     ),
//     '\\Updownarrow': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u21d5'
//     ),
//     '\\coprod': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u2210'
//     ),
//     '\\bigvee': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u22c1'
//     ),
//     '\\bigwedge': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u22c0'
//     ),
//     '\\biguplus': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u2a04'
//     ),
//     '\\bigcap': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u22c2'
//     ),
//     '\\bigcup': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u22c3'
//     ),
//     '\\int': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u222b'
//     ),
//     '\\intop': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u222b'
//     ),
//     '\\iint': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u222c'
//     ),
//     '\\iiint': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u222d'
//     ),
//     '\\prod': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u220f'
//     ),
//     '\\sum': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u2211'
//     ),
//     '\\bigotimes': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u2a02'
//     ),
//     '\\bigoplus': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u2a01'
//     ),
//     '\\bigodot': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u2a00'
//     ),
//     '\\oint': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u222e'
//     ),
//     '\\bigsqcup': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u2a06'
//     ),
//     '\\smallint': new TexSymbol(
//         font: 'math',
//         group: 'op',
//         replace: '\u222b'
//     ),
//     '\\ldots': new TexSymbol(
//         font: 'main',
//         group: 'punct',
//         replace: '\u2026'
//     ),
//     '\\cdots': new TexSymbol(
//         font: 'main',
//         group: 'inner',
//         replace: '\u22ef'
//     ),
//     '\\ddots': new TexSymbol(
//         font: 'main',
//         group: 'inner',
//         replace: '\u22f1'
//     ),
//     '\\vdots': new TexSymbol(
//         font: 'main',
//         group: 'textord',
//         replace: '\u22ee'
//     ),
//     '\\acute': new TexSymbol(
//         font: 'main',
//         group: 'accent',
//         replace: '\u00b4'
//     ),
//     '\\grave': new TexSymbol(
//         font: 'main',
//         group: 'accent',
//         replace: '\u0060'
//     ),
//     '\\ddot': new TexSymbol(
//         font: 'main',
//         group: 'accent',
//         replace: '\u00a8'
//     ),
//     '\\tilde': new TexSymbol(
//         font: 'main',
//         group: 'accent',
//         replace: '\u007e'
//     ),
//     '\\bar': new TexSymbol(
//         font: 'main',
//         group: 'accent',
//         replace: '\u00af'
//     ),
//     '\\breve': new TexSymbol(
//         font: 'main',
//         group: 'accent',
//         replace: '\u02d8'
//     ),
//     '\\check': new TexSymbol(
//         font: 'main',
//         group: 'accent',
//         replace: '\u02c7'
//     ),
//     '\\hat': new TexSymbol(
//         font: 'main',
//         group: 'accent',
//         replace: '\u005e'
//     ),
//     '\\vec': new TexSymbol(
//         font: 'main',
//         group: 'accent',
//         replace: '\u20d7'
//     ),
//     '\\dot': new TexSymbol(
//         font: 'main',
//         group: 'accent',
//         replace: '\u02d9'
//     )
//   },
//   'text': {
//     '\\ ': new TexSymbol(
//         font: 'main',
//         group: 'spacing',
//         replace: '\u00a0'
//     ),
//     ' ': new TexSymbol(
//         font: 'main',
//         group: 'spacing',
//         replace: '\u00a0'
//     ),
//     '~': new TexSymbol(
//         font: 'main',
//         group: 'spacing',
//         replace: '\u00a0'
//     )
//   }
// };
//
// void initSymbols() {
//   List<String> mathTextSymbols = "0123456789/@.\"".split('');
//   List<String> textSymbols = "0123456789`!@*()-=+[]'\";:?/.,".split('');
//   List<String> letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".split('');
//   mathTextSymbols.forEach((character) {
//     symbols[ 'math' ][ character ] = new TexSymbol(font: 'main',
//         group: 'textord');
//   });
//   textSymbols.forEach((character) {
//     symbols[ 'text' ][ character ] = new TexSymbol(font: 'main',
//         group: 'textord');
//   });
//   letters.forEach((character) {
//     symbols[ 'math' ][ character ] = new TexSymbol(font: 'main',
//         group: 'mathord');
//     symbols[ 'text' ][ character ] = new TexSymbol(font: 'main',
//         group: 'textord');
//   });
// }
