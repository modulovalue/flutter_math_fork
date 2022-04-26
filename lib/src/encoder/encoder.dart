import '../ast/ast.dart';

import '../parser/settings.dart';
import '../utils/log.dart';
import 'exception.dart';

abstract class EncodeResult<CONF extends EncodeConf> {
  String stringify(
    final CONF conf,
  );
}

class StaticEncodeResult implements EncodeResult {
  const StaticEncodeResult(
    final this.string,
  );

  final String string;

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

typedef EncoderFun<T extends GreenNode> = EncodeResult Function(
  T node,
);

typedef StrictFun = Strict Function(
  String errorCode,
  String errorMsg, [
  dynamic token,
]);

abstract class EncodeConf {
  final Strict strict;
  final StrictFun? strictFun;

  const EncodeConf({
    final this.strict = Strict.warn,
    final this.strictFun,
  });

  void reportNonstrict(
    final String errorCode,
    final String errorMsg, [
    final dynamic token,
  ]) {
    final strict = this.strict != Strict.function
        ? this.strict
        : (strictFun?.call(errorCode, errorMsg, token) ?? Strict.warn);
    switch (strict) {
      case Strict.ignore:
        return;
      case Strict.error:
        throw EncoderException(
            "Nonstrict Tex encoding and strict mode is set to 'error': "
            '$errorMsg [$errorCode]',
            token);
      case Strict.warn:
        warn("Nonstrict Tex encoding and strict mode is set to 'warn': "
            '$errorMsg [$errorCode]');
        break;
      case Strict.function:
        warn('Nonstrict Tex encoding and strict mode is set to '
            "unrecognized '$strict': $errorMsg [$errorCode]");
    }
  }
}
