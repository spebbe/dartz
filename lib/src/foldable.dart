part of dartz;

abstract class Foldable<F> {
  // def foldMap[A, B: Monoid](fa: Option[A], f: A => B): B
  foldMap(Monoid bMonoid, F fa, f(a));

  foldRight(F fa, z, f(a, previous)) => foldMap(EndoMi, fa, curry2(f))(z);

  foldLeft(F fa, z, f(previous, a)) => foldMap(DualEndoMi, fa, curry2(flip(f)))(z);

  foldMapO(Semigroup si, F fa, f(a)) => foldMap(new OptionMonoid(si), fa, composeF(some, f));

  concatenate(Monoid mi, F fa) => foldMap(mi, fa, id);

  concatenateO(Semigroup si, F fa) => foldMapO(si, fa, id);
}

abstract class FoldableOps<F, A> {
  foldMap(Monoid bMonoid, f(A a));

  foldRight(z, f(A a, previous)) => foldMap(EndoMi, curry2(f))(z);

  foldLeft(z, f(previous, A a)) => foldMap(DualEndoMi, curry2(flip(f)))(z);

  foldMapO(Semigroup si, f(A a)) => foldMap(new OptionMonoid(si), composeF(some, f));

  concatenate(Monoid mi) => foldMap(mi, id);

  concatenateO(Semigroup si) => foldMapO(si, id);
}

class FoldableOpsFoldable<F extends FoldableOps> extends Foldable<F> {
  @override foldMap(Monoid bMonoid, F fa, f(a)) => fa.foldMap(bMonoid, f);
  @override foldRight(F fa, z, f(a, previous)) => fa.foldRight(z, f);
  @override foldLeft(F fa, z, f(previous, a)) => fa.foldLeft(z, f);
}
