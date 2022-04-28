import 'package:flutter_math_fork/src/encoder/tex_encoder.dart';
import 'package:flutter_math_fork/src/parser/parser.dart';

String recodeTex(
  final String tex,
) =>
    nodeEncodeTeX(
      node: TexParser(
        content: tex,
        settings: const TexParserSettings(),
      ).parse(),
      conf: TexEncodeConf.mathParamConf,
    );
