import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_math_fork/src/encoder/tex_encoder.dart';
import 'package:flutter_math_fork/src/parser/parser.dart';

String recodeTex(
  final String tex,
) =>
    nodeEncodeTeX(
      node: TexParser(
        tex,
        const TexParserSettings(),
      ).parse(),
      conf: TexEncodeConf.mathParamConf,
    );
