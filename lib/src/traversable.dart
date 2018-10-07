part of dartz;

abstract class Traversable<F> extends Functor<F> with Foldable<F> {
  //def traverseImpl[G[_]:Applicative,A,B](fa: F[A])(f: A => G[B]): G[F[B]]
  G traverse<G>(Applicative<G> gApplicative, F fa, G f(a));

  G traverse_<G>(Applicative<G> gApplicative, F fa, G f(a)) => gApplicative.map(traverse(gApplicative, fa, f), constF(unit));

  G sequence<G>(Applicative<G> gApplicative, F fa) => traverse(gApplicative, fa, cast(id));

  G sequence_<G>(Applicative<G> gApplicative, F fa) => traverse_(gApplicative, fa, cast(id));

  F mapWithIndex<B>(F fa, B f(int i, a)) {
    final M = stateM<int>();
    return cast(traverse<State<int, dynamic>>(M, fa, (e) => M.get().bind((i) => M.put(i + 1).map((_) => f(i, e)))).value(0));
  }

  F zipWithIndex(F fa) => mapWithIndex(fa, tuple2);

  @override F map<A, B>(covariant F fa, B f(A a)) => cast(traverse(IdM, fa, cast(f)));

  // def foldMap[A, B](bMonoid: Monoid[B], fa: F[A], f: A => B): B
  @override B foldMap<A, B>(Monoid<B> bMonoid, F fa, B f(A a)) =>
      cast(traverse(StateM, fa, (a) => StateM.modify(cast((previous) => bMonoid.append(cast(previous), f(cast(a)))))).state(bMonoid.zero()));
}

abstract class TraversableOps<F, A> extends FunctorOps<F, A> with FoldableOps<F, A> {
  G traverse<G>(Applicative<G> gApplicative, G f(A a));

  G traverse_<G>(Applicative<G> gApplicative, G f(A a)) => gApplicative.map(traverse(gApplicative, f), constF(unit));

  G sequence<G>(Applicative<G> gApplicative) => traverse<G>(gApplicative, cast(id));

  G sequence_<G>(Applicative<G> gApplicative) => traverse_<G>(gApplicative, cast(id));

  F mapWithIndex<B>(B f(int i, A a)) {
    final M = stateM<int>();
    return cast(traverse<State<int, dynamic>>(M, (e) => M.get().bind((i) => M.put(i + 1).map((_) => f(i, e)))).value(0));
  }

  F zipWithIndex() => mapWithIndex(tuple2);

  @override F map<B>(B f(A a)) => cast(traverse<Object>(IdM, f));

  @override B foldMap<B>(Monoid<B> bMonoid, B f(A a)) =>
      cast(traverse(StateM, (a) => StateM.modify(cast((previous) => bMonoid.append(cast(previous), f(a))))).state(bMonoid.zero()));
}

class TraversableOpsTraversable<F extends TraversableOps> extends Traversable<F> {
  @override G traverse<G>(Applicative<G> gApplicative, F fa, G f(a)) => fa.traverse(gApplicative, f);
  @override B foldRight<A, B>(F fa, B z, B f(A a, B previous)) => fa.foldRight(z, cast(f));
  @override B foldMap<A, B>(Monoid<B> bMonoid, F fa, B f(A a)) => fa.foldMap(bMonoid, cast(f));
  @override F map<A, B>(F fa, B f(A a)) => cast(fa.map<B>(cast(f)));
  @override G sequence_<G>(Applicative<G> gApplicative, F fa) => fa.sequence_(gApplicative);
  @override G sequence<G>(Applicative<G> gApplicative, F fa) => fa.sequence(gApplicative);
  @override G traverse_<G>(Applicative<G> gApplicative, F fa, G f(a)) => fa.traverse_(gApplicative, f);
  @override Option<A> concatenateO<A>(Semigroup<A> si, F fa) => cast(fa.concatenateO(si));
  @override A concatenate<A>(Monoid<A> mi, F fa) => cast(fa.concatenate(mi));
  @override Option<B> foldMapO<A, B>(Semigroup<B> si, F fa, B f(A a)) => fa.foldMapO(si, cast(f));
  @override B foldLeft<A, B>(F fa, B z, B f(B previous, A a)) => fa.foldLeft(z, cast(f));
}
