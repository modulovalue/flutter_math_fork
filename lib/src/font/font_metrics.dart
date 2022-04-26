import '../ast/size.dart';
import '../ast/types.dart';
import 'font_metrics_data.dart';
import 'unicode_scripts.dart';

// TODO store each measurement wrapped.
// TODO use phantom types for safer units.
class FontMetrics {
  double get cssEmPerMu => quad / 18;

  final double slant; // sigma1
  final double space; // sigma2
  final double stretch; // sigma3
  final double shrink; // sigma4
  final double xHeight; // sigma5
  final double quad; // sigma6
  final double extraSpace; // sigma7
  final double num1; // sigma8
  final double num2; // sigma9
  final double num3; // sigma10
  final double denom1; // sigma11
  final double denom2; // sigma12
  final double sup1; // sigma13
  final double sup2; // sigma14
  final double sup3; // sigma15
  final double sub1; // sigma16
  final double sub2; // sigma17
  final double supDrop; // sigma18
  final double subDrop; // sigma19
  final double delim1; // sigma20
  final double delim2; // sigma21
  final double axisHeight; // sigma22

  // These font metrics are extracted from TeX by using tftopl on cmex10.tfm;
  // they correspond to the font parameters of the extension fonts (family 3).
  // See the TeXbook, page 441. In AMSTeX, the extension fonts scale; to
  // match cmex7, we'd use cmex7.tfm values for script and scriptscript
  // values.
  final double defaultRuleThickness; // xi8; cmex7: 0.049
  final double bigOpSpacing1; // xi9
  final double bigOpSpacing2; // xi10
  final double bigOpSpacing3; // xi11
  final double bigOpSpacing4; // xi12; cmex7: 0.611
  final double bigOpSpacing5; // xi13; cmex7: 0.143

  // The \sqrt rule width is taken from the height of the surd character.
  // Since we use the same font at all sizes, this thickness doesn't scale.
  final double sqrtRuleThickness;

  // This value determines how large a pt is, for metrics which are defined
  // in terms of pts.
  // This value is also used in katex.less; if you change it make sure the
  // values match.
  final double ptPerEm;

  // The space between adjacent `|` columns in an array definition. From
  // `\showthe\doublerulesep` in LaTeX. Equals 2.0 / ptPerEm.
  final double doubleRuleSep;

  // The width of separator lines in {array} environments. From
  // `\showthe\arrayrulewidth` in LaTeX. Equals 0.4 / ptPerEm.
  final double arrayRuleWidth; // Two values from LaTeX source2e:
  final double fboxsep; // 3 pt / ptPerEm
  final double fboxrule; // 0.4 pt / ptPerEm

  const FontMetrics({
    required final this.slant,
    required final this.space,
    required final this.stretch,
    required final this.shrink,
    required final this.xHeight,
    required final this.quad,
    required final this.extraSpace,
    required final this.num1,
    required final this.num2,
    required final this.num3,
    required final this.denom1,
    required final this.denom2,
    required final this.sup1,
    required final this.sup2,
    required final this.sup3,
    required final this.sub1,
    required final this.sub2,
    required final this.supDrop,
    required final this.subDrop,
    required final this.delim1,
    required final this.delim2,
    required final this.axisHeight,
    required final this.defaultRuleThickness,
    required final this.bigOpSpacing1,
    required final this.bigOpSpacing2,
    required final this.bigOpSpacing3,
    required final this.bigOpSpacing4,
    required final this.bigOpSpacing5,
    required final this.sqrtRuleThickness,
    required final this.ptPerEm,
    required final this.doubleRuleSep,
    required final this.arrayRuleWidth,
    required final this.fboxsep,
    required final this.fboxrule,
  });

  static FontMetrics fromMap(
      final Map<String, double> map,
      ) {
    final _slant = map['slant'];
    final _space = map['space'];
    final _stretch = map['stretch'];
    final _shrink = map['shrink'];
    final _xHeight = map['xHeight'];
    final _quad = map['quad'];
    final _extraSpace = map['extraSpace'];
    final _num1 = map['num1'];
    final _num2 = map['num2'];
    final _num3 = map['num3'];
    final _denom1 = map['denom1'];
    final _denom2 = map['denom2'];
    final _sup1 = map['sup1'];
    final _sup2 = map['sup2'];
    final _sup3 = map['sup3'];
    final _sub1 = map['sub1'];
    final _sub2 = map['sub2'];
    final _supDrop = map['supDrop'];
    final _subDrop = map['subDrop'];
    final _delim1 = map['delim1'];
    final _delim2 = map['delim2'];
    final _axisHeight = map['axisHeight'];
    final _defaultRuleThickness = map['defaultRuleThickness'];
    final _bigOpSpacing1 = map['bigOpSpacing1'];
    final _bigOpSpacing2 = map['bigOpSpacing2'];
    final _bigOpSpacing3 = map['bigOpSpacing3'];
    final _bigOpSpacing4 = map['bigOpSpacing4'];
    final _bigOpSpacing5 = map['bigOpSpacing5'];
    final _sqrtRuleThickness = map['sqrtRuleThickness'];
    final _ptPerEm = map['ptPerEm'];
    final _doubleRuleSep = map['doubleRuleSep'];
    final _arrayRuleWidth = map['arrayRuleWidth'];
    final _fboxsep = map['fboxsep'];
    final _fboxrule = map['fboxrule'];
    if (_slant == null) throw Exception("Expected _slant to not be null");
    if (_space == null) throw Exception("Expected _space to not be null");
    if (_stretch == null) throw Exception("Expected _stretch to not be null");
    if (_shrink == null) throw Exception("Expected _shrink to not be null");
    if (_xHeight == null) throw Exception("Expected _xHeight to not be null");
    if (_quad == null) throw Exception("Expected _quad to not be null");
    if (_extraSpace == null) throw Exception("Expected _extraSpace to not be null");
    if (_num1 == null) throw Exception("Expected _num1 to not be null");
    if (_num2 == null) throw Exception("Expected _num2 to not be null");
    if (_num3 == null) throw Exception("Expected _num3 to not be null");
    if (_denom1 == null) throw Exception("Expected _denom1 to not be null");
    if (_denom2 == null) throw Exception("Expected _denom2 to not be null");
    if (_sup1 == null) throw Exception("Expected _sup1 to not be null");
    if (_sup2 == null) throw Exception("Expected _sup2 to not be null");
    if (_sup3 == null) throw Exception("Expected _sup3 to not be null");
    if (_sub1 == null) throw Exception("Expected _sub1 to not be null");
    if (_sub2 == null) throw Exception("Expected _sub2 to not be null");
    if (_supDrop == null) throw Exception("Expected _supDrop to not be null");
    if (_subDrop == null) throw Exception("Expected _subDrop to not be null");
    if (_delim1 == null) throw Exception("Expected _delim1 to not be null");
    if (_delim2 == null) throw Exception("Expected _delim2 to not be null");
    if (_axisHeight == null) throw Exception("Expected _axisHeight to not be null");
    if (_defaultRuleThickness == null) throw Exception("Expected _defaultRuleThickness to not be null");
    if (_bigOpSpacing1 == null) throw Exception("Expected _bigOpSpacing1 to not be null");
    if (_bigOpSpacing2 == null) throw Exception("Expected _bigOpSpacing2 to not be null");
    if (_bigOpSpacing3 == null) throw Exception("Expected _bigOpSpacing3 to not be null");
    if (_bigOpSpacing4 == null) throw Exception("Expected _bigOpSpacing4 to not be null");
    if (_bigOpSpacing5 == null) throw Exception("Expected _bigOpSpacing5 to not be null");
    if (_sqrtRuleThickness == null) throw Exception("Expected _sqrtRuleThickness to not be null");
    if (_ptPerEm == null) throw Exception("Expected _ptPerEm to not be null");
    if (_doubleRuleSep == null) throw Exception("Expected _doubleRuleSep to not be null");
    if (_arrayRuleWidth == null) throw Exception("Expected _arrayRuleWidth to not be null");
    if (_fboxsep == null) throw Exception("Expected _fboxsep to not be null");
    if (_fboxrule == null) throw Exception("Expected _fboxrule to not be null");
    return FontMetrics(
      slant: _slant,
      space: _space,
      stretch: _stretch,
      shrink: _shrink,
      xHeight: _xHeight,
      quad: _quad,
      extraSpace: _extraSpace,
      num1: _num1,
      num2: _num2,
      num3: _num3,
      denom1: _denom1,
      denom2: _denom2,
      sup1: _sup1,
      sup2: _sup2,
      sup3: _sup3,
      sub1: _sub1,
      sub2: _sub2,
      supDrop: _supDrop,
      subDrop: _subDrop,
      delim1: _delim1,
      delim2: _delim2,
      axisHeight: _axisHeight,
      defaultRuleThickness: _defaultRuleThickness,
      bigOpSpacing1: _bigOpSpacing1,
      bigOpSpacing2: _bigOpSpacing2,
      bigOpSpacing3: _bigOpSpacing3,
      bigOpSpacing4: _bigOpSpacing4,
      bigOpSpacing5: _bigOpSpacing5,
      sqrtRuleThickness: _sqrtRuleThickness,
      ptPerEm: _ptPerEm,
      doubleRuleSep: _doubleRuleSep,
      arrayRuleWidth: _arrayRuleWidth,
      fboxsep: _fboxsep,
      fboxrule: _fboxrule,
    );
  }
}

/// This file contains metrics regarding fonts and individual symbols. The sigma
/// and xi variables, as well as the metricMap map contain data extracted from
/// TeX, TeX font metrics, and the TTF files. These data are then exposed via
/// the `metrics` variable and the getCharacterMetrics function.

// In TeX, there are actually three sets of dimensions, one for each of
// textstyle (size index 5 and higher: >=9pt), scriptstyle (size index 3 and 4:
// 7-8pt), and scriptscriptstyle (size index 1 and 2: 5-6pt).  These are
// provided in the the arrays below, in that order.
//
// The font metrics are stored in fonts cmsy10, cmsy7, and cmsy5 respsectively.
// This was determined by running the following script:
//
//     latex -interaction=nonstopmode \
//     '\documentclass{article}\usepackage{amsmath}\begin{document}' \
//     '$a$ \expandafter\show\the\textfont2' \
//     '\expandafter\show\the\scriptfont2' \
//     '\expandafter\show\the\scriptscriptfont2' \
//     '\stop'
//
// The metrics themselves were retreived using the following commands:
//
//     tftopl cmsy10
//     tftopl cmsy7
//     tftopl cmsy5
//
// The output of each of these commands is quite lengthy.  The only part we
// care about is the FONTDIMEN section. Each value is measured in EMs.
const sigmasAndXis = {
  'slant': [0.250, 0.250, 0.250], // sigma1
  'space': [0.000, 0.000, 0.000], // sigma2
  'stretch': [0.000, 0.000, 0.000], // sigma3
  'shrink': [0.000, 0.000, 0.000], // sigma4
  'xHeight': [0.431, 0.431, 0.431], // sigma5
  'quad': [1.000, 1.171, 1.472], // sigma6
  'extraSpace': [0.000, 0.000, 0.000], // sigma7
  'num1': [0.677, 0.732, 0.925], // sigma8
  'num2': [0.394, 0.384, 0.387], // sigma9
  'num3': [0.444, 0.471, 0.504], // sigma10
  'denom1': [0.686, 0.752, 1.025], // sigma11
  'denom2': [0.345, 0.344, 0.532], // sigma12
  'sup1': [0.413, 0.503, 0.504], // sigma13
  'sup2': [0.363, 0.431, 0.404], // sigma14
  'sup3': [0.289, 0.286, 0.294], // sigma15
  'sub1': [0.150, 0.143, 0.200], // sigma16
  'sub2': [0.247, 0.286, 0.400], // sigma17
  'supDrop': [0.386, 0.353, 0.494], // sigma18
  'subDrop': [0.050, 0.071, 0.100], // sigma19
  'delim1': [2.390, 1.700, 1.980], // sigma20
  'delim2': [1.010, 1.157, 1.420], // sigma21
  'axisHeight': [0.250, 0.250, 0.250], // sigma22

  // These font metrics are extracted from TeX by using tftopl on cmex10.tfm;
  // they correspond to the font parameters of the extension fonts (family 3).
  // See the TeXbook, page 441. In AMSTeX, the extension fonts scale; to
  // match cmex7, we'd use cmex7.tfm values for script and scriptscript
  // values.
  'defaultRuleThickness': [0.04, 0.049, 0.049], // xi8; cmex7: 0.049
  'bigOpSpacing1': [0.111, 0.111, 0.111], // xi9
  'bigOpSpacing2': [0.166, 0.166, 0.166], // xi10
  'bigOpSpacing3': [0.2, 0.2, 0.2], // xi11
  'bigOpSpacing4': [0.6, 0.611, 0.611], // xi12; cmex7: 0.611
  'bigOpSpacing5': [0.1, 0.143, 0.143], // xi13; cmex7: 0.143

  // The \sqrt rule width is taken from the height of the surd character.
  // Since we use the same font at all sizes, this thickness doesn't scale.
  'sqrtRuleThickness': [0.04, 0.04, 0.04],

  // This value determines how large a pt is, for metrics which are defined
  // in terms of pts.
  // This value is also used in katex.less; if you change it make sure the
  // values match.
  'ptPerEm': [10.0, 10.0, 10.0],

  // The space between adjacent `|` columns in an array definition. From
  // `\showthe\doublerulesep` in LaTeX. Equals 2.0 / ptPerEm.
  'doubleRuleSep': [0.2, 0.2, 0.2],

  // The width of separator lines in {array} environments. From
  // `\showthe\arrayrulewidth` in LaTeX. Equals 0.4 / ptPerEm.
  'arrayRuleWidth': [0.04, 0.04, 0.04],

  // Two values from LaTeX source2e:
  'fboxsep': [0.3, 0.3, 0.3], //        3 pt / ptPerEm
  'fboxrule': [0.04, 0.04, 0.04], // 0.4 pt / ptPerEm
};

final textFontMetrics = FontMetrics.fromMap(
  sigmasAndXis.map(
    (final key, final value) => MapEntry(key, value[0]),
  ),
);

final scriptFontMetrics = FontMetrics.fromMap(
  sigmasAndXis.map(
    (final key, final value) => MapEntry(key, value[1]),
  ),
);

final scriptscriptFontMetrics = FontMetrics.fromMap(
  sigmasAndXis.map(
    (final key, final value) => MapEntry(key, value[2]),
  ),
);

const extraCharacterMap = {
  // Latin-1
  'Å': 'A',
  'Ç': 'C',
  'Ð': 'D',
  'Þ': 'o',
  'å': 'a',
  'ç': 'c',
  'ð': 'd',
  'þ': 'o',

  // Cyrillic
  'А': 'A',
  'Б': 'B',
  'В': 'B',
  'Г': 'F',
  'Д': 'A',
  'Е': 'E',
  'Ж': 'K',
  'З': '3',
  'И': 'N',
  'Й': 'N',
  'К': 'K',
  'Л': 'N',
  'М': 'M',
  'Н': 'H',
  'О': 'O',
  'П': 'N',
  'Р': 'P',
  'С': 'C',
  'Т': 'T',
  'У': 'y',
  'Ф': 'O',
  'Х': 'X',
  'Ц': 'U',
  'Ч': 'h',
  'Ш': 'W',
  'Щ': 'W',
  'Ъ': 'B',
  'Ы': 'X',
  'Ь': 'B',
  'Э': '3',
  'Ю': 'X',
  'Я': 'R',
  'а': 'a',
  'б': 'b',
  'в': 'a',
  'г': 'r',
  'д': 'y',
  'е': 'e',
  'ж': 'm',
  'з': 'e',
  'и': 'n',
  'й': 'n',
  'к': 'n',
  'л': 'n',
  'м': 'm',
  'н': 'n',
  'о': 'o',
  'п': 'n',
  'р': 'p',
  'с': 'c',
  'т': 'o',
  'у': 'y',
  'ф': 'b',
  'х': 'x',
  'ц': 'n',
  'ч': 'n',
  'ш': 'w',
  'щ': 'w',
  'ъ': 'a',
  'ы': 'm',
  'ь': 'a',
  'э': 'e',
  'ю': 'm',
  'я': 'r',
};

class CharacterMetrics {
  final double depth;
  final double height;
  final double italic;
  final double skew;
  final double width;

  const CharacterMetrics(
    this.depth,
    this.height,
    this.italic,
    this.skew,
    this.width,
  );
}

const Map<String, Map<int, CharacterMetrics>> metricsMap = fontMetricsData;

CharacterMetrics? getCharacterMetrics(
    {required final String character, required final String fontName, required final Mode mode}) {
  final metricsMapFont = metricsMap[fontName];
  if (metricsMapFont == null) {
    throw Exception('Font metrics not found for font: $fontName.');
  }

  final ch = character.codeUnitAt(0);
  if (metricsMapFont.containsKey(ch)) {
    return metricsMapFont[ch];
  }

  final extraCh = extraCharacterMap[character[0]]?.codeUnitAt(0);
  if (extraCh != null) {
    return metricsMapFont[ch];
  }
  if (mode == Mode.text && supportedCodepoint(ch)) {
    // We don't typically have font metrics for Asian scripts.
    // But since we support them in text mode, we need to return
    // some sort of metrics.
    // So if the character is in a script we support but we
    // don't have metrics for it, just use the metrics for
    // the Latin capital letter M. This is close enough because
    // we (currently) only care about the height of the glpyh
    // not its width.
    return metricsMapFont[77]; // 77 is the charcode for 'M'
  }
  return null;
}

FontMetrics getGlobalMetrics(final MathSize size) {
  switch (size) {
    case MathSize.tiny:
    case MathSize.size2:
      return scriptscriptFontMetrics;
    case MathSize.scriptsize:
    case MathSize.footnotesize:
      return scriptFontMetrics;
    case MathSize.small:
    case MathSize.normalsize:
    case MathSize.large:
    case MathSize.Large:
    case MathSize.LARGE:
    case MathSize.huge:
    case MathSize.HUGE:
      return textFontMetrics;
  }
}
