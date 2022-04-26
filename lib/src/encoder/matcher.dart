import 'dart:math' as math;

import '../ast/syntax_tree.dart';
import '../utils/iterable_extensions.dart';

abstract class Matcher {
  int get specificity;

  bool match(
    final GreenNode? node,
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
    final GreenNode? node,
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
    final GreenNode? node,
  ) =>
      node == null;

  @override
  Matcher or(
    final Matcher other,
  ) =>
      OrMatcher(this, other);
}

const isNull = NullMatcher();

class NodeMatcher<T extends GreenNode> implements Matcher {
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
        (children?.map((final child) => child.specificity).sum ?? 0),
        (lastChild?.specificity ?? 0),
        (everyChild?.specificity ?? 0) * 3,
        (anyChild?.specificity ?? 0),
      ].max;

  @override
  bool match(final GreenNode? node) {
    if (node is! T) return false;
    if (matchSelf != null && matchSelf!(node) == false) return false;
    if (child != null) {
      if (node.children.length != 1) return false;
      if (!child!.match(node.children.first)) return false;
    }
    if (children != null) {
      if (children!.length != node.children.length) return false;
      for (var index = 0; index < node.children.length; index++) {
        if (!children![index].match(node.children[index])) return false;
      }
    }
    if (firstChild != null) {
      if (node.children.isEmpty) return false;
      if (!firstChild!.match(node.children.first)) return false;
    }
    if (lastChild != null) {
      if (node.children.isEmpty) return false;
      if (!lastChild!.match(node.children.last)) return false;
    }
    if (everyChild != null && !node.children.every(everyChild!.match)) {
      return false;
    }
    if (anyChild != null && !node.children.any(anyChild!.match)) return false;

    return true;
  }
}

NodeMatcher<T> isA<T extends GreenNode>({
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
