import '../../ast.dart';

/// Line breaking results using standard TeX-style line breaking.
///
/// This function will return a list of `SyntaxTree` along with a list
/// of line breaking penalties.
///
/// {@macro flutter_math_fork.widgets.math.tex_break}
BreakResult<SyntaxTree> syntaxTreeTexBreak({
  required final SyntaxTree tree,
  final int relPenalty = 500,
  final int binOpPenalty = 700,
  final bool enforceNoBreak = true,
}) {
  final eqRowBreakResult = equationRowNodeTexBreak(
    tree: tree.greenRoot,
    relPenalty: relPenalty,
    binOpPenalty: binOpPenalty,
    enforceNoBreak: true,
  );
  return BreakResult(
    parts: eqRowBreakResult.parts.map((final part) => SyntaxTree(greenRoot: part)).toList(growable: false),
    penalties: eqRowBreakResult.penalties,
  );
}

/// Line breaking results using standard TeX-style line breaking.
///
/// This function will return a list of `EquationRowNode` along with a list
/// of line breaking penalties.
///
/// {@macro flutter_math_fork.widgets.math.tex_break}
BreakResult<EquationRowNode> equationRowNodeTexBreak({
  required final EquationRowNode tree,
  final int relPenalty = 500,
  final int binOpPenalty = 700,
  final bool enforceNoBreak = true,
}) {
  final breakIndices = <int>[];
  final penalties = <int>[];
  for (int i = 0; i < tree.flattenedChildList.length; i++) {
    final child = tree.flattenedChildList[i];
    // Peek ahead to see if the next child is a no-break
    if (i < tree.flattenedChildList.length - 1) {
      final nextChild = tree.flattenedChildList[i + 1];
      if (nextChild is SpaceNode && nextChild.breakPenalty != null && nextChild.breakPenalty! >= 10000) {
        if (!enforceNoBreak) {
          // The break point should be moved to the next child, which is a \nobreak.
          continue;
        } else {
          // In enforced mode, we should cancel the break point all together.
          i++;
          continue;
        }
      }
    }
    if (child.rightType == AtomType.bin) {
      breakIndices.add(i);
      penalties.add(binOpPenalty);
    } else if (child.rightType == AtomType.rel) {
      breakIndices.add(i);
      penalties.add(relPenalty);
    } else if (child is SpaceNode && child.breakPenalty != null) {
      breakIndices.add(i);
      penalties.add(child.breakPenalty!);
    }
  }
  final res = <EquationRowNode>[];
  int pos = 1;
  for (var i = 0; i < breakIndices.length; i++) {
    final breakEnd = tree.caretPositions[breakIndices[i] + 1];
    res.add(
      greenNodeWrapWithEquationRow(
        tree.clipChildrenBetween(
          pos,
          breakEnd,
        ),
      ),
    );
    pos = breakEnd;
  }
  if (pos != tree.caretPositions.last) {
    res.add(
      greenNodeWrapWithEquationRow(
        tree.clipChildrenBetween(
          pos,
          tree.caretPositions.last,
        ),
      ),
    );
    penalties.add(10000);
  }
  return BreakResult<EquationRowNode>(
    parts: res,
    penalties: penalties,
  );
}

class BreakResult<T> {
  final List<T> parts;
  final List<int> penalties;

  const BreakResult({
    required final this.parts,
    required final this.penalties,
  });
}
