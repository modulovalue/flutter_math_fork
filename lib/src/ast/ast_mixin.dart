import 'ast.dart';

mixin TexRedChildrenMixin<GREEN extends TexGreen> implements TexRed {
  TexRed factory(
    final TexRedChildrenMixin redParent,
    final TexGreen greenValue,
    final int pos,
  );

  @override
  late final List<TexRed?> children = greenValue.match(
    nonleaf: (final a) => List.generate(
      a.children.length,
      (final index) {
        if (a.children[index] != null) {
          return factory(
            this,
            a.children[index]!,
            this.pos + a.childPositions[index],
          );
        } else {
          return null;
        }
      },
      growable: false,
    ),
    leaf: (final a) => List.empty(
      growable: false,
    ),
  );
}

mixin TexGreenNonleafMixin<SELF extends TexGreenNonleafMixin<SELF>>
    implements TexGreenTNonleaf<SELF, TexGreen> {
  @override
  late final cache = TexCacheGreen();

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
  late final cache = TexCacheGreen();

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
  late final cache = TexCacheGreen();

  @override
  Z match<Z>({
    required final Z Function(TexGreenNonnullableCapturedMixin<SELF> p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      nonleaf(this);
}

mixin TexGreenLeafableMixin implements TexGreenLeaf {
  @override
  late final cache = TexCacheGreen();

  @override
  Z match<Z>({
    required final Z Function(TexGreenNonleaf p1) nonleaf,
    required final Z Function(TexGreenLeaf p1) leaf,
  }) =>
      leaf(this);
}
