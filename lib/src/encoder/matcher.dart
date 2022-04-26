import 'dart:math' as math;

import '../ast/ast.dart';

import '../utils/extensions.dart';

abstract class Matcher {
  int get specificity;

  bool match(
    final TexGreen? node,
  );

  Matcher or(
    final Matcher other,
  );
}

class OrMatcher implements Matcher {
  final Matcher matcher1;
  final Matcher matcher2;

  const OrMatcher(
    this.matcher1,
    this.matcher2,
  );

  @override
  bool match(
    final TexGreen? node,
  ) =>
      matcher1.match(node) || matcher2.match(node);

  @override
  int get specificity => math.min(matcher1.specificity, matcher2.specificity);

  @override
  Matcher or(
    final Matcher other,
  ) =>
      OrMatcher(this, other);
}

class NullMatcher implements Matcher {
  const NullMatcher();

  @override
  int get specificity => 100;

  @override
  bool match(
    final TexGreen? node,
  ) =>
      node == null;

  @override
  Matcher or(
    final Matcher other,
  ) =>
      OrMatcher(this, other);
}

const isNull = NullMatcher();

class NodeMatcher<T extends TexGreen> implements Matcher {
  final bool Function(T node)? matchSelf;
  final int selfSpecificity;
  final Matcher? child;
  final List<Matcher>? children;
  final Matcher? firstChild;
  final Matcher? lastChild;
  final Matcher? everyChild;
  final Matcher? anyChild;

  const NodeMatcher({
    final this.matchSelf,
    final this.selfSpecificity = 100,
    final this.child,
    final this.children,
    final this.firstChild,
    final this.lastChild,
    final this.everyChild,
    final this.anyChild,
  });

  @override
  Matcher or(
    final Matcher other,
  ) =>
      OrMatcher(this, other);

  @override
  int get specificity =>
      100 +
      (matchSelf != null ? selfSpecificity : 0) +
      [
        (child?.specificity ?? 0),
        (() {
          final c = children;
          if (c == null) {
            return 0;
          } else {
            return integerSum(
              c.map((final child) => child.specificity),
            );
          }
        }()),
        (lastChild?.specificity ?? 0),
        (everyChild?.specificity ?? 0) * 3,
        (anyChild?.specificity ?? 0),
      ].max;

  @override
  bool match(final TexGreen? node,) {
    if (node is! T) return false;
    if (matchSelf != null && matchSelf!(node) == false) return false;
    if (child != null) {
      if (node.childrenl.length != 1) return false;
      if (!child!.match(node.childrenl.first)) return false;
    }
    if (children != null) {
      if (children!.length != node.childrenl.length) return false;
      for (int index = 0; index < node.childrenl.length; index++) {
        if (!children![index].match(node.childrenl[index])) return false;
      }
    }
    if (firstChild != null) {
      if (node.childrenl.isEmpty) return false;
      if (!firstChild!.match(node.childrenl.first)) return false;
    }
    if (lastChild != null) {
      if (node.childrenl.isEmpty) return false;
      if (!lastChild!.match(node.childrenl.last)) return false;
    }
    if (everyChild != null && !node.childrenl.every(everyChild!.match)) {
      return false;
    }
    if (anyChild != null && !node.childrenl.any(anyChild!.match)) return false;
    return true;
  }
}

NodeMatcher<T> isA<T extends TexGreen>({
  final bool Function(T node)? matchSelf,
  final int selfSpecificity = 100,
  final Matcher? child,
  final List<Matcher>? children,
  final Matcher? firstChild,
  final Matcher? lastChild,
  final Matcher? everyChild,
  final Matcher? anyChild,
}) =>
    NodeMatcher<T>(
      matchSelf: matchSelf,
      selfSpecificity: selfSpecificity,
      child: child,
      children: children,
      firstChild: firstChild,
      lastChild: lastChild,
      everyChild: everyChild,
      anyChild: anyChild,
    );
