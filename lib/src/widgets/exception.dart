/// Base class for exceptions.
abstract class FlutterMathException implements Exception {
  String get message;

  String get messageWithType;
}

/// Exceptions occurred during build.
class BuildException implements FlutterMathException {
  @override
  final String message;
  final StackTrace? trace;

  const BuildException(
    final this.message, {
    final this.trace,
  });

  @override
  String get messageWithType => 'Build Exception: $message';
}
