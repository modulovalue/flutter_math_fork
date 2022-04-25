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

  static FontMetrics? fromMap(final Map<String, double> map) {
    try {
      return FontMetrics(
        slant: map['slant']!,
        space: map['space']!,
        stretch: map['stretch']!,
        shrink: map['shrink']!,
        xHeight: map['xHeight']!,
        quad: map['quad']!,
        extraSpace: map['extraSpace']!,
        num1: map['num1']!,
        num2: map['num2']!,
        num3: map['num3']!,
        denom1: map['denom1']!,
        denom2: map['denom2']!,
        sup1: map['sup1']!,
        sup2: map['sup2']!,
        sup3: map['sup3']!,
        sub1: map['sub1']!,
        sub2: map['sub2']!,
        supDrop: map['supDrop']!,
        subDrop: map['subDrop']!,
        delim1: map['delim1']!,
        delim2: map['delim2']!,
        axisHeight: map['axisHeight']!,
        defaultRuleThickness: map['defaultRuleThickness']!,
        bigOpSpacing1: map['bigOpSpacing1']!,
        bigOpSpacing2: map['bigOpSpacing2']!,
        bigOpSpacing3: map['bigOpSpacing3']!,
        bigOpSpacing4: map['bigOpSpacing4']!,
        bigOpSpacing5: map['bigOpSpacing5']!,
        sqrtRuleThickness: map['sqrtRuleThickness']!,
        ptPerEm: map['ptPerEm']!,
        doubleRuleSep: map['doubleRuleSep']!,
        arrayRuleWidth: map['arrayRuleWidth']!,
        fboxsep: map['fboxsep']!,
        fboxrule: map['fboxrule']!,
      );
    } on Error {
      return null;
    }
  }
}
