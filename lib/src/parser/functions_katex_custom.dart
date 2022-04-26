import '../ast/ast.dart';
import 'functions.dart';
import 'parser.dart';

const Map<List<String>, FunctionSpec<TexGreen>> cursorEntries = {
  [
    '\\cursor',
  ]: FunctionSpec(
    numArgs: 1,
    handler: _cursorHandler,
  )
};

TexGreen _cursorHandler(
  final TexParser parser,
  final FunctionContext context,
) =>
    TexGreenCursor();
