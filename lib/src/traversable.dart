part of dartz;

abstract class Traversable<F> extends Functor<F> with Foldable<F> {
  //def traverseImpl[G[_]:Applicative,A,B](fa: F[A])(f: A => G[B]): G[F[B]]
  /*=G*/ traverse/*<G>*/(Applicative/*<G>*/ gApplicative, F fa, /*=G*/ f(a));

  /*=G*/ traverse_/*<G>*/(Applicative/*<G>*/ gApplicative, F fa, /*=G*/ f(a)) => gApplicative.map(traverse/*<G>*/(gApplicative, fa, f), constF(unit));

  /*=G*/ sequence/*<G>*/(Applicative/*<G>*/ gApplicative, F fa) => traverse(gApplicative, fa, id);

  /*=G*/ sequence_/*<G>*/(Applicative/*<G>*/ gApplicative, F fa) => traverse_(gApplicative, fa, id);

  F mapWithIndex/*<B>*/(F fa, /*=B*/ f(int i, a)) =>
      traverse/*<StateT<Trampoline<F>, int, dynamic>>*/(tstateM/*<F, int>*/(), fa, (e) => tstateM/*<F, int>*/().get().bind((i) => tstateM/*<F, int>*/().put(i+1).replace(f(i, e)))).value(0).run();

  F zipWithIndex(F fa) => mapWithIndex(fa, tuple2);

  @override F map(F fa, f(a)) => traverse(IdM, fa, f) as F;

  // def foldMap[A, B](bMonoid: Monoid[B], fa: F[A], f: A => B): B
  @override /*=B*/ foldMap/*<B>*/(Monoid/*<B>*/ bMonoid, F fa, /*=B*/ f(a)) =>
      traverse(TStateM, fa, (a) => TStateM.modify((/*=B*/ previous) => bMonoid.append(previous, f(a)))).state(bMonoid.zero()).run() as dynamic/*=B*/;
}

abstract class TraversableOps<F, A> extends FunctorOps<F, A> with FoldableOps<F, A> {
  /*=G*/ traverse/*<G>*/(Applicative/*<G>*/ gApplicative, /*=G*/ f(A a));

  /*=G*/ traverse_/*<G>*/(Applicative/*<G>*/ gApplicative, /*=G*/ f(A a)) => gApplicative.map(traverse(gApplicative, f), constF(unit));

  /*=G*/ sequence/*<G>*/(Applicative/*<G>*/ gApplicative) => traverse/*<G>*/(gApplicative, id as Function1/*<A, G>*/);

  /*=G*/ sequence_/*<G>*/(Applicative/*<G>*/ gApplicative) => traverse_/*<G>*/(gApplicative, id as Function1/*<A, G>*/);

  F mapWithIndex/*<B>*/(/*=B*/ f(int i, a)) =>
      traverse/*<StateT<Trampoline<F>, int, dynamic>>*/(tstateM/*<F, int>*/(), (e) => tstateM/*<F, int>*/().get().bind((i) => tstateM/*<F, int>*/().put(i+1).replace(f(i, e)))).value(0).run();

  F zipWithIndex() => mapWithIndex(tuple2);

  @override F map/*<B>*/(/*=B*/ f(A a)) => traverse(IdM, f) as F;

  @override /*=B*/ foldMap/*<B>*/(Monoid/*<B>*/ bMonoid, /*=B*/ f(A a)) =>
      traverse(TStateM, (a) => TStateM.modify((/*=B*/ previous) => bMonoid.append(previous, f(a)))).state(bMonoid.zero()).run() as dynamic/*=B*/;
}

class TraversableOpsTraversable<F extends TraversableOps> extends Traversable<F> {
  @override /*=G*/ traverse/*<G>*/(Applicative/*<G>*/ gApplicative, F fa, /*=G*/ f(a)) => fa.traverse(gApplicative, f);
  @override /*=B*/ foldRight/*<B>*/(F fa, /*=B*/ z, /*=B*/ f(a, /*=B*/ previous)) => fa.foldRight(z, f);
  @override /*=B*/ foldMap/*<B>*/(Monoid/*<B>*/ bMonoid, F fa, /*=B*/ f(a)) => fa.foldMap(bMonoid, f);
  @override F map/*<B>*/(F fa, /*=B*/ f(a)) => fa.map/*<B>*/(f) as F;
  @override /*=G*/ sequence_/*<G>*/(Applicative/*<G>*/ gApplicative, F fa) => fa.sequence_(gApplicative);
  @override /*=G*/ sequence/*<G>*/(Applicative/*<G>*/ gApplicative, F fa) => fa.sequence(gApplicative);
  @override /*=G*/ traverse_/*<G>*/(Applicative/*<G>*/ gApplicative, F fa, /*=G*/ f(a)) => fa.traverse_(gApplicative, f);
  @override Option/*<A>*/ concatenateO/*<A>*/(Semigroup/*<A>*/ si, F fa) => fa.concatenateO(si) as Option/*<A>*/;
  @override /*=A*/ concatenate/*<A>*/(Monoid/*<A>*/ mi, F fa) => fa.concatenate(mi) as dynamic/*=A*/;
  @override Option/*<A>*/ foldMapO/*<A>*/(Semigroup/*<A>*/ si, F fa, /*=A*/ f(a)) => fa.foldMapO(si, f);
  @override /*=B*/ foldLeft/*<B>*/(F fa, /*=B*/ z, /*=B*/ f(/*=B*/ previous, a)) => fa.foldLeft(z, f);
}