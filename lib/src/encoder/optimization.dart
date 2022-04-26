import '../ast/ast.dart';

import 'matcher.dart';

class OptimizationEntry {
  final Matcher matcher;
  final void Function(GreenNode node) optimize;

  final int? _priority;
  int get priority => _priority ?? matcher.specificity;

  const OptimizationEntry({
    required final this.matcher,
    required final this.optimize,
    final int? priority,
  }) : _priority = priority;
}
