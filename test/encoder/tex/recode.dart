import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_math_fork/src/encoder/tex/encoder.dart';
import 'package:flutter_math_fork/src/parser/tex/parser.dart';

String recodeTex(final String tex) => TexParser(tex, const TexParserSettings())
    .parse()
    .encodeTeX(conf: TexEncodeConf.mathParamConf);
