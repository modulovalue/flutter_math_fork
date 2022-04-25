import 'dart:math' as math;

extension IntExt on int {
  int clampInt(final int lowerLimit, final int upperLimit) {
    assert(upperLimit >= lowerLimit);
    if (this < lowerLimit) return lowerLimit;
    if (this > upperLimit) return upperLimit;
    return this;
  }
}

@pragma('dart2js:tryInline')
@pragma('vm:prefer-inline')
T max3<T extends num>(final T a, final T b, final T c) => math.max(math.max(a, b), c);
