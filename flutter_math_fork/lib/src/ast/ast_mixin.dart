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

mixin TexGreenNonleafMixin implements TexGreenNonleaf {
  @override
  Z match<Z>({
    required final Z Function(TexGreenNonleafMixin p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      nonleaf(this);
}

mixin TexGreenNullableCapturedMixin implements TexGreenNonleaf {
  @override
  Z match<Z>({
    required final Z Function(TexGreenNullableCapturedMixin p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      nonleaf(this);
}

mixin TexGreenNonnullableCapturedMixin implements TexGreenNonleaf {
  @override
  Z match<Z>({
    required final Z Function(TexGreenNonnullableCapturedMixin p1) nonleaf,
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
