import 'package:flutter/cupertino.dart';
import '../ast/ast.dart';
import '../ast/ast_plus.dart';

class TexWidget extends StatelessWidget {
  final TexRoslyn tex;
  final MathOptions options;

  const TexWidget({
    required final this.tex,
    required final this.options,
  });

  @override
  Widget build(
    final BuildContext context,
  ) {
    final red = tex.redRoot;
    final result = red.buildWidget(options);
    return result.widget;
  }
}
