import '../ast/ast.dart';
import '../utils/extensions.dart';
import 'matcher.dart';

class OptimizationEntryCollection<T extends TexGreen> {
  final List<OptimizationEntry<T>> entries;

  const OptimizationEntryCollection({
    required final this.entries,
  });

  void apply(
    final T node,
  ) {
    final sorted = sortBy(
      entries,
    )<num>(
      (final entry) => -entry.matcher.specificity,
    );
    for (final entry in sorted) {
      if (entry.matcher.match(node)) {
        entry.optimize(node);
        break;
      }
    }
  }
}

class OptimizationEntry<T extends TexGreen> {
  final NodeMatcher<T> matcher;
  final void Function(T node) optimize;

  const OptimizationEntry({
    required final this.matcher,
    required final this.optimize,
  });
}
