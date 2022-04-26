//ignore_for_file: constant_identifier_names

import 'options.dart';
import 'style.dart';

// This table gives the number of TeX pts in one of each *absolute* TeX unit.
// Thus, multiplying a length by this number converts the length from units
// into pts.  Dividing the result by ptPerEm gives the number of ems
// *assuming* a font size of ptPerEm (normal size, normal style).

enum Unit {
  // https://en.wikibooks.org/wiki/LaTeX/Lengths and
  // https://tex.stackexchange.com/a/8263
  pt, // TeX point
  mm, // millimeter
  cm, // centimeter
  inches, // inch //Avoid name collision
  bp, // big (PostScript) points
  pc, // pica
  dd, // didot
  cc, // cicero (12 didot)
  nd, // new didot
  nc, // new cicero (12 new didot)
  sp, // scaled point (TeX's internal smallest unit)
  px, // \pdfpxdimen defaults to 1 bp in pdfTeX and LuaTeX

  ex, // The height of 'x'
  em, // The width of 'M', which is often the size of the font. ()
  mu,
  lp, // Flutter's logical pixel (96 lp per inch)
  cssEm, // Unit used for font metrics. Analogous to KaTeX's internal unit, but
  // always scale with options.
}

extension UnitExt on Unit {
  static const _ptPerUnit = {
    Unit.pt: 1.0,
    Unit.mm: 7227 / 2540,
    Unit.cm: 7227 / 254,
    Unit.inches: 72.27,
    Unit.bp: 803 / 800,
    Unit.pc: 12.0,
    Unit.dd: 1238 / 1157,
    Unit.cc: 14856 / 1157,
    Unit.nd: 685 / 642,
    Unit.nc: 1370 / 107,
    Unit.sp: 1 / 65536,
    // https://tex.stackexchange.com/a/41371
    Unit.px: 803 / 800,

    Unit.ex: null,
    Unit.em: null,
    Unit.mu: null,
    // https://api.flutter.dev/flutter/dart-ui/Window/devicePixelRatio.html
    // Unit.lp: 72.27 / 96,
    Unit.lp: 72.27 / 160, // This is more accurate
    // Unit.lp: 72.27 / 200,
    Unit.cssEm: null,
  };

  double? get toPt => _ptPerUnit[this];

  String get name => const {
        Unit.pt: 'pt',
        Unit.mm: 'mm',
        Unit.cm: 'cm',
        Unit.inches: 'inches',
        Unit.bp: 'bp',
        Unit.pc: 'pc',
        Unit.dd: 'dd',
        Unit.cc: 'cc',
        Unit.nd: 'nd',
        Unit.nc: 'nc',
        Unit.sp: 'sp',
        Unit.px: 'px',
        Unit.ex: 'ex',
        Unit.em: 'em',
        Unit.mu: 'mu',
        Unit.lp: 'lp',
        Unit.cssEm: 'cssEm',
      }[this]!;

  static Unit? parse(final String unit) => unit.parseUnit();
}

extension UnitExtOnString on String {
  Unit? parseUnit() => const {
        'pt': Unit.pt,
        'mm': Unit.mm,
        'cm': Unit.cm,
        'inches': Unit.inches,
        'bp': Unit.bp,
        'pc': Unit.pc,
        'dd': Unit.dd,
        'cc': Unit.cc,
        'nd': Unit.nd,
        'nc': Unit.nc,
        'sp': Unit.sp,
        'px': Unit.px,
        'ex': Unit.ex,
        'em': Unit.em,
        'mu': Unit.mu,
        'lp': Unit.lp,
        'cssEm': Unit.cssEm,
      }[this];
}

class Measurement {
  final double value;
  final Unit unit;

  const Measurement({
    required final this.value,
    required final this.unit,
  });

  double toLpUnder(final MathOptions options,) {
    if (unit == Unit.lp) return value;
    if (unit.toPt != null) {
      return value * unit.toPt! / Unit.inches.toPt! * options.logicalPpi;
    }
    switch (unit) {
      case Unit.cssEm:
        return value * options.fontSize * options.sizeMultiplier;
      // `mu` units scale with scriptstyle/scriptscriptstyle.
      case Unit.mu:
        return value * options.fontSize * options.fontMetrics.cssEmPerMu * options.sizeMultiplier;
      // `ex` and `em` always refer to the *textstyle* font
      // in the current size.
      case Unit.ex:
        return value *
            options.fontSize *
            options.fontMetrics.xHeight *
            options.havingStyle(options.style.atLeastText()).sizeMultiplier;
      case Unit.em:
        return value *
            options.fontSize *
            options.fontMetrics.quad *
            options.havingStyle(options.style.atLeastText()).sizeMultiplier;
      case Unit.pt:
        throw ArgumentError("Invalid unit: '${unit.toString()}'");
      case Unit.mm:
        throw ArgumentError("Invalid unit: '${unit.toString()}'");
      case Unit.cm:
        throw ArgumentError("Invalid unit: '${unit.toString()}'");
      case Unit.inches:
        throw ArgumentError("Invalid unit: '${unit.toString()}'");
      case Unit.bp:
        throw ArgumentError("Invalid unit: '${unit.toString()}'");
      case Unit.pc:
        throw ArgumentError("Invalid unit: '${unit.toString()}'");
      case Unit.dd:
        throw ArgumentError("Invalid unit: '${unit.toString()}'");
      case Unit.cc:
        throw ArgumentError("Invalid unit: '${unit.toString()}'");
      case Unit.nd:
        throw ArgumentError("Invalid unit: '${unit.toString()}'");
      case Unit.nc:
        throw ArgumentError("Invalid unit: '${unit.toString()}'");
      case Unit.sp:
        throw ArgumentError("Invalid unit: '${unit.toString()}'");
      case Unit.px:
        throw ArgumentError("Invalid unit: '${unit.toString()}'");
      case Unit.lp:
        throw ArgumentError("Invalid unit: '${unit.toString()}'");
    }
  }

  double toCssEmUnder(final MathOptions options,) => toLpUnder(options) / options.fontSize;

  @override
  String toString() => '$value${unit.name}';

  static const zero = Measurement(value: 0, unit: Unit.pt);
}

Measurement ptMeasurement(final double value) => Measurement(value: value, unit: Unit.pt);
Measurement mmMeasurement(final double value) => Measurement(value: value, unit: Unit.mm);
Measurement cmMeasurement(final double value) => Measurement(value: value, unit: Unit.cm);
Measurement inchesMeasurement(final double value) => Measurement(value: value, unit: Unit.inches);
Measurement bpMeasurement(final double value) => Measurement(value: value, unit: Unit.bp);
Measurement pcMeasurement(final double value) => Measurement(value: value, unit: Unit.pc);
Measurement ddMeasurement(final double value) => Measurement(value: value, unit: Unit.dd);
Measurement ccMeasurement(final double value) => Measurement(value: value, unit: Unit.cc);
Measurement ndMeasurement(final double value) => Measurement(value: value, unit: Unit.nd);
Measurement ncMeasurement(final double value) => Measurement(value: value, unit: Unit.nc);
Measurement spMeasurement(final double value) => Measurement(value: value, unit: Unit.sp);
Measurement pxMeasurement(final double value) => Measurement(value: value, unit: Unit.px);
Measurement exMeasurement(final double value) => Measurement(value: value, unit: Unit.ex);
Measurement emMeasurement(final double value) => Measurement(value: value, unit: Unit.em);
Measurement muMeasurement(final double value) => Measurement(value: value, unit: Unit.mu);
Measurement lpMeasurement(final double value) => Measurement(value: value, unit: Unit.lp);
Measurement cssEmMeasurement(final double value) => Measurement(value: value, unit: Unit.cssEm);

enum MathSize {
  tiny,
  size2,
  scriptsize,
  footnotesize,
  small,
  normalsize,
  large,
  Large,
  LARGE,
  huge,
  HUGE,
}

double mathSizeSizeMultiplier(
  final MathSize size,
) =>
    const [
      0.5,
      0.6,
      0.7,
      0.8,
      0.9,
      1.0,
      1.2,
      1.44,
      1.728,
      2.074,
      2.488,
    ][size.index];
