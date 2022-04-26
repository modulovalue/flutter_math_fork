import 'dart:math';

import '../ast/ast.dart';
import '../ast/ast_plus.dart';
import '../utils/extensions.dart';

abstract class Matcher {
  int get specificity;

  bool match(
    final TexGreen? node,
  );
}

class OrMatcher implements Matcher {
  final Matcher matcher1;
  final Matcher matcher2;

  const OrMatcher(
    final this.matcher1,
    final this.matcher2,
  );

  @override
  bool match(
    final TexGreen? node,
  ) =>
      matcher1.match(node) || matcher2.match(node);

  @override
  int get specificity => min(matcher1.specificity, matcher2.specificity);
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
  bool match(
    final TexGreen? node,
  ) {
    if (node is! T) {
      return false;
    }
    if (matchSelf != null) {
      if (matchSelf!(node) == false) {
        return false;
      }
    }
    if (child != null) {
      if (node.childrenl.length != 1) {
        return false;
      } else if (!child!.match(node.childrenl.first)) {
        return false;
      }
    }
    if (children != null) {
      if (children!.length != node.childrenl.length) {
        return false;
      } else {
        for (int index = 0; index < node.childrenl.length; index++) {
          if (!children![index].match(node.childrenl[index])) {
            return false;
          }
        }
      }
    }
    if (firstChild != null) {
      if (node.childrenl.isEmpty) {
        return false;
      } else if (!firstChild!.match(node.childrenl.first)) {
        return false;
      }
    }
    if (lastChild != null) {
      if (node.childrenl.isEmpty) {
        return false;
      } else if (!lastChild!.match(node.childrenl.last)) {
        return false;
      }
    }
    if (everyChild != null && !node.childrenl.every(everyChild!.match)) {
      return false;
    } else if (anyChild != null && !node.childrenl.any(anyChild!.match)) {
      return false;
    }
    return true;
  }
}
