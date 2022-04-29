import '../parser/parser.dart';
import 'exception.dart';

abstract class EncodeResult<CONF extends EncodeConf> {
  String stringify(
    final CONF conf,
  );
}

class StaticEncodeResult implements EncodeResult {
  final String string;

  const StaticEncodeResult(
    final this.string,
  );

  @override
  String stringify(
    final EncodeConf conf,
  ) =>
      string;
}

class NonStrictEncodeResult implements EncodeResult {
  final String errorCode;
  final String errorMsg;
  final EncodeResult placeHolder;

  const NonStrictEncodeResult(
    final this.errorCode,
    final this.errorMsg, [
    final this.placeHolder = const StaticEncodeResult(''),
  ]);

  NonStrictEncodeResult.string(
    final this.errorCode,
    final this.errorMsg, [
    final String placeHolder = '',
  ]) : this.placeHolder = StaticEncodeResult(placeHolder);

  @override
  String stringify(
    final EncodeConf conf,
  ) {
    conf.reportNonstrict(errorCode, errorMsg);
    return placeHolder.stringify(conf);
  }
}

abstract class EncodeConf {
  final TexStrict strict;

  const EncodeConf({
    final this.strict = const TexStrictWarn(
      warn: print,
    ),
  });

  void reportNonstrict(
    final String errorCode,
    final String errorMsg, [
    final Token? token,
  ]) =>
      this.strict.match(
            ignore: (final a) {},
            warn: (final a) => a.warn(
              "Nonstrict Tex encoding and strict mode is set to 'warn': $errorMsg [$errorCode]",
            ),
            error: (final a) => throw EncoderException(
              "Nonstrict Tex encoding and strict mode is set to 'error': $errorMsg [$errorCode]",
              token,
            ),
          );
}
