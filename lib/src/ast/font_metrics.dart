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
