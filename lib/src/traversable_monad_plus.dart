// ignore_for_file: unnecessary_new

part of dartz;

abstract class TraversableMonadPlus<F> implements Traversable<F>, MonadPlus<F> {
  // TODO: Only requires ApplicativePlus, not MonadPlus
  Tuple2<F, F> partition<A>(F fa, bool f(A a)) =>
      foldRight(fa, tuple2(empty(), empty()), (A a, acc) => f(a)
          ? acc.map1((xs) => prependElement(xs, a))
          : acc.map2((xs) => prependElement(xs, a)));

  // TODO: Only requires Foldable and ApplicativePlus
  F reverse(F fa) => foldLeft(fa, empty(), prependElement);
}

abstract class TraversableMonadPlusOps<F, A> implements TraversableOps<F, A>, MonadPlusOps<F, A> {
  // TODO: Only requires ApplicativePlus, not MonadPlus
  Tuple2<F, F> partition(bool f(A a)) =>
      foldRight(tuple2(empty(), empty()), (A a, acc) => f(a)
          ? acc.map1((xs) => cast<TraversableMonadPlusOps<F, A>>(xs).prependElement(a))
          : acc.map2((xs) => cast<TraversableMonadPlusOps<F, A>>(xs).prependElement(a)));

  // TODO: Only requires Foldable and ApplicativePlus
  F reverse() => foldLeft(empty(), (r, e) => cast<TraversableMonadPlusOps<F, A>>(r).prependElement(e));
}
