import 'ast.dart';
import 'ast_plus.dart';

mixin TexRedChildrenMixin implements TexRed {
  TexRed factory(
    final TexGreen greenValue,
    final int pos,
  );

  @override
  late final List<TexRed?> children = greenValue.match(
    nonleaf: (final a) {
      final children = texNonleafChildren(
        nonleaf: a,
      );
      return List.generate(
        children.length,
        (final index) {
          if (children[index] != null) {
            return factory(
              children[index]!,
              (this.pos ?? -1) + (texChildPositions(a))[index],
            );
          } else {
            return null;
          }
        },
        growable: false,
      );
    },
    leaf: (final a) => List.empty(
      growable: false,
    ),
  );
}

mixin TexGreenNonleafMixin<SELF extends TexGreenNonleafMixin<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreen> {
  @override
  Z match<Z>({
    required final Z Function(TexGreenNonleafMixin<SELF> p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      nonleaf(this);
}

mixin TexGreenNullableCapturedMixin<SELF extends TexGreenNullableCapturedMixin<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow?> {
  @override
  Z match<Z>({
    required final Z Function(TexGreenNullableCapturedMixin<SELF> p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      nonleaf(this);
}

mixin TexGreenNonnullableCapturedMixin<SELF extends TexGreenNonnullableCapturedMixin<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreenEquationrow> {
  @override
  Z match<Z>({
    required final Z Function(TexGreenNonnullableCapturedMixin<SELF> p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      nonleaf(this);
}

mixin TexGreenLeafableMixin implements TexGreenLeaf {
  @override
  Z match<Z>({
    required final Z Function(TexGreenNonleaf p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      leaf(this);
}
