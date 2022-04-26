import '../ast/ast.dart';
import 'functions.dart';
import 'parser.dart';

const Map<List<String>, FunctionSpec<GreenNode>> cursorEntries = {
  [
    '\\cursor',
  ]: FunctionSpec(
    numArgs: 1,
    handler: _cursorHandler,
  )
};

GreenNode _cursorHandler(
  final TexParser parser,
  final FunctionContext context,
) =>
    CursorNode();
