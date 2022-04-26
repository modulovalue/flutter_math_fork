import 'dart:math' as math;

extension NumIterableExtension<T extends num> on Iterable<T> {
  T? get minOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      var value = iterator.current;
      while (iterator.moveNext()) {
        final newValue = iterator.current;
        if (value.compareTo(newValue) > 0) {
          value = newValue;
        }
      }
      return value;
    }
    return null;
  }

  /// A minimal element of the iterable.
  ///
  /// The iterable must not be empty.
  T get min {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      var value = iterator.current;
      while (iterator.moveNext()) {
        final newValue = iterator.current;
        if (value.compareTo(newValue) > 0) {
          value = newValue;
        }
      }
      return value;
    }
    throw StateError('No element');
  }

  /// A maximal element of the iterable, or `null` if the iterable is empty.
  T? get maxOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      var value = iterator.current;
      while (iterator.moveNext()) {
        final newValue = iterator.current;
        if (value.compareTo(newValue) < 0) {
          value = newValue;
        }
      }
      return value;
    }
    return null;
  }

  /// A maximal element of the iterable.
  ///
  /// The iterable must not be empty.
  T get max {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      var value = iterator.current;
      while (iterator.moveNext()) {
        final newValue = iterator.current;
        if (value.compareTo(newValue) < 0) {
          value = newValue;
        }
      }
      return value;
    }
    throw StateError('No element');
  }
}

extension ListExtension<T> on List<T> {
  List<T> extendToByFill(final int desiredLength, final T fill) => this.length >= desiredLength
      ? this
      : List.generate(
          desiredLength,
          (final index) => index < this.length ? this[index] : fill,
          growable: false,
        );
}

extension NumListSearchExt<T extends num> on List<T> {
  /// Utility method to help determine node selection.
  ///
  /// If [value] matches one of the element, return the element index.
  /// If [value] is between two elements, return the midpoint.
  /// If [value] is out of the list's bounds, return [-0.5] or
  /// [List.length - 0.5].
  ///
  /// Should only be used on non-empty, monotonically increasing lists.
  double slotFor(final T value) {
    // if (value < this[0]) return -1;
    var left = -1;
    var right = this.length;
    for (var i = 0; i < this.length; i++) {
      final element = this[i];
      if (element < value) {
        left = i;
      } else if (element == value) {
        return i.toDouble();
      } else if (element > value) {
        right = i;
        break;
      }
    }
    return (left + right) / 2;
    // return this.length.toDouble();
  }
}

/// Extensions that apply to iterables with a nullable element type.
extension IterableNullableExtension<T extends Object> on Iterable<T?> {
  /// The non-`null` elements of this `Iterable`.
  ///
  /// Returns an iterable which emits all the non-`null` elements
  /// of this iterable, in their original iteration order.
  ///
  /// For an `Iterable<X?>`, this method is equivalent to `.whereType<X>()`.
  Iterable<T> whereNotNull() sync* {
    for (final element in this) {
      if (element != null) yield element;
    }
  }
}

extension IterableExtension<T> on Iterable<T> {
  /// The first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(
    final bool Function(T element) test,
  ) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }

  /// The last element, or `null` if the iterable is empty.
  T? get lastOrNull {
    if (isEmpty) {
      return null;
    } else {
      return last;
    }
  }

  /// The first element, or `null` if the iterable is empty.
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}

extension ListExtensions<E> on List<E> {
  /// Maps each element and its index to a new value.
  Iterable<R> mapIndexed<R>(
    final R Function(int index, E element) convert,
  ) sync* {
    for (int index = 0; index < length; index++) {
      yield convert(
        index,
        this[index],
      );
    }
  }

  void sortBy<R extends Comparable<R>>(
    final R Function(E) fn,
  ) =>
      sort(
        (final a, final b) => fn(a).compareTo(
          fn(b),
        ),
      );
}

extension IterableIntegerExtension on Iterable<int> {
  /// The sum of the elements.
  ///
  /// The sum is zero if the iterable is empty.
  int get sum {
    int result = 0;
    for (final value in this) {
      result += value;
    }
    return result;
  }
}

extension IterableDoubleExtension on Iterable<double> {
  /// The sum of the elements.
  ///
  /// The sum is zero if the iterable is empty.
  double get sum {
    double result = 0.0;
    for (final value in this) {
      result += value;
    }
    return result;
  }
}

extension IntExt on int {
  int clampInt(final int lowerLimit, final int upperLimit) {
    assert(upperLimit >= lowerLimit, "");
    if (this < lowerLimit) return lowerLimit;
    if (this > upperLimit) return upperLimit;
    return this;
  }
}

@pragma('dart2js:tryInline')
@pragma('vm:prefer-inline')
T max3<T extends num>(final T a, final T b, final T c) => math.max(math.max(a, b), c);
