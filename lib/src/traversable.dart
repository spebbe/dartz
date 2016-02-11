part of dartz;

abstract class Traversable<F> extends Functor<F> with Foldable<F> {
  //def traverseImpl[G[_]:Applicative,A,B](fa: F[A])(f: A => G[B]): G[F[B]]
  traverse(Applicative gApplicative, F fa, f(a));

  traverse_(Applicative gApplicative, F fa, f(a)) => traverse(gApplicative, fa, f).map(constF(unit));

  sequence(Applicative gApplicative, F fa) => traverse(gApplicative, fa, id);

  sequence_(Applicative gApplicative, F fa) => traverse_(gApplicative, fa, id);

  @override F map(F fa, f(a)) => traverse(IdM, fa, f);

  // def foldMap[A, B](bMonoid: Monoid[B], fa: Option[A], f: A => B): B
  @override foldMap(Monoid bMonoid, F fa, f(a)) => traverse(StateM, fa, (a) => State.modify((previous) => bMonoid.append(previous, f(a)))).state(bMonoid.zero());
}

abstract class TraversableOps<F, A> extends FunctorOps<F, A> with FoldableOps<F, A> {
  traverse(Applicative gApplicative, f(A a));

  traverse_(Applicative gApplicative, f(A a)) => traverse(gApplicative, f).map(constF(unit));

  sequence(Applicative gApplicative) => traverse(gApplicative, id);

  sequence_(Applicative gApplicative) => traverse_(gApplicative, id);

  @override F map(f(A a)) => traverse(IdM, f);

  @override foldMap(Monoid bMonoid, f(A a)) => traverse(StateM, (a) => State.modify((previous) => bMonoid.append(previous, f(a)))).state(bMonoid.zero());
}

class TraversableOpsTraversable<F extends TraversableOps> extends Traversable<F> {
  @override traverse(Applicative gApplicative, F fa, f(a)) => fa.traverse(gApplicative, f);
  @override foldRight(F fa, z, f(a, previous)) => fa.foldRight(z, f);
  @override foldMap(Monoid bMonoid, F fa, f(a)) => fa.foldMap(bMonoid, f);
  @override F map(F fa, f(a)) => fa.map(f);
  @override sequence_(Applicative gApplicative, F fa) => fa.sequence_(gApplicative);
  @override sequence(Applicative gApplicative, F fa) => fa.sequence(gApplicative);
  @override traverse_(Applicative gApplicative, F fa, f(a)) => fa.traverse_(gApplicative, f);
  @override concatenateO(Semigroup si, F fa) => fa.concatenateO(si);
  @override concatenate(Monoid mi, F fa) => fa.concatenate(mi);
  @override foldMapO(Semigroup si, F fa, f(a)) => fa.foldMapO(si, f);
  @override foldLeft(F fa, z, f(previous, a)) => fa.foldLeft(z, f);
}