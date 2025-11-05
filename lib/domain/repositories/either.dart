// Either type for error handling (functional programming pattern)
class Either<L, R> {
  final L? left;
  final R? right;
  final bool isLeft;

  Either._(this.left, this.right, this.isLeft);

  factory Either.left(L value) => Either._(value, null, true);
  factory Either.right(R value) => Either._(null, value, false);

  T fold<T>(T Function(L) leftFn, T Function(R) rightFn) {
    if (isLeft) {
      return leftFn(left as L);
    } else {
      return rightFn(right as R);
    }
  }
}
