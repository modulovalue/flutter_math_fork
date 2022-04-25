import '../widgets/exception.dart';

class EncoderException implements FlutterMathException {
  @override
  final String message;
  final dynamic token;

  const EncoderException(
    this.message, [
    final this.token,
  ]);

  @override
  String get messageWithType => 'Encoder Exception: $message';
}
