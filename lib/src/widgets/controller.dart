import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../ast/ast.dart';
import '../utils/text_extension.dart';

class MathController extends ChangeNotifier {
  MathController({
    required final SyntaxTree ast,
    final TextSelection selection = const TextSelection.collapsed(
      offset: -1,
    ),
  })  : _ast = ast,
        _selection = selection;

  SyntaxTree _ast;

  SyntaxTree get ast => _ast;

  set ast(
    final SyntaxTree value,
  ) {
    if (_ast != value) {
      _ast = value;
      _selection = const TextSelection.collapsed(offset: -1);
      notifyListeners();
    }
  }

  TextSelection get selection => _selection;
  TextSelection _selection;

  set selection(
    final TextSelection value,
  ) {
    if (_selection != value) {
      _selection = sanitizeSelection(ast, value);
      notifyListeners();
    }
  }

  TextSelection sanitizeSelection(
    final SyntaxTree ast,
    final TextSelection selection,
  ) {
    if (selection.end <= 0) {
      return selection;
    } else {
      return textSelectionConstrainedBy(
        selection,
        ast.root.range,
      );
    }
  }

  List<GreenNode> get selectedNodes => ast.findSelectedNodes(selection.start, selection.end);
}
