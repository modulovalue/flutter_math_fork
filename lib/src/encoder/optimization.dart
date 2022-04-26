import '../ast/ast.dart';

import 'matcher.dart';

class OptimizationEntry {
  final Matcher matcher;
  final void Function(TexGreen node) optimize;
  final int? _priority;

  const OptimizationEntry({
    required final this.matcher,
    required final this.optimize,
    final int? priority,
  }) : _priority = priority;

  int get priority => _priority ?? matcher.specificity;
}
