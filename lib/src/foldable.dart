part of dartz;

abstract class Foldable<F> {
  // def foldMap[A, B: Monoid](fa: Option[A], f: A => B): B
  /*=B*/ foldMap/*<B>*/(Monoid/*<B>*/ bMonoid, F fa, /*=B*/ f(a));

  /*=B*/ foldRight/*<B>*/(F fa, /*=B*/ z, /*=B*/ f(a, /*=B*/ previous)) => foldMap/*<Endo<B>>*/(EndoMi, fa, curry2(f))(z);

  /*=B*/ foldLeft/*<B>*/(F fa, /*=B*/ z, /*=B*/ f(/*=B*/ previous, a)) => foldMap/*<Endo<B>>*/(DualEndoMi, fa, curry2(flip(f)))(z);

  Option/*<A>*/ foldMapO/*<A>*/(Semigroup/*<A>*/ si, F fa, /*=A*/ f(a)) => foldMap(new OptionMonoid/*<A>*/(si), fa, composeF(some, f));

  /*=A*/ concatenate/*<A>*/(Monoid/*<A>*/ mi, F fa) => foldMap(mi, fa, id);

  Option/*<A>*/ concatenateO/*<A>*/(Semigroup/*<A>*/ si, F fa) => foldMapO(si, fa, id);

  int length(F fa) => foldLeft(fa, 0, (a, _) => a+1);

  bool any(F fa, bool f(a)) => foldMap(BoolOrMi, fa, f);

  bool all(F fa, bool f(a)) => foldMap(BoolAndMi, fa, f);

  Option/*<A>*/ minimum/*<A>*/(Order/*<A>*/ oa, F fa) => concatenateO(new MinSemigroup(oa), fa);

  Option/*<A>*/ maximum/*<A>*/(Order/*<A>*/ oa, F fa) => concatenateO(new MaxSemigroup(oa), fa);

  /*=A*/ intercalate/*<A>*/(Monoid/*<A>*/ mi, F fa, /*=A*/ a) => foldRight/*<Option<A>>*/(fa, none(), (/*=A*/ ca, oa) => some(mi.append(ca, oa.fold(mi.zero, mi.appendC(a))))) | mi.zero();

  /*=G*/ collapse/*<G>*/(ApplicativePlus/*<G>*/ ap, F fa) => foldLeft(fa, ap.empty(), (p, a) => ap.plus(p, ap.pure(a)));

  /*=G*/ foldLeftM/*<G>*/(Monad/*<G>*/ m, F fa, z, /*=G*/ f(previous, a)) => foldRight/*<Function1<dynamic, G>>*/(fa, m.pure, (a, b) => (w) => m.bind(f(w, a), b))(z);

  /*=G*/ foldRightM/*<G>*/(Monad/*<G>*/ m, F fa, z, /*=G*/ f(a, previous)) => foldLeft/*<Function1<dynamic, G>>*/(fa, m.pure, (b, a) => (w) => m.bind(f(a, w), b))(z);
}

abstract class FoldableOps<F, A> {
  /*=B*/ foldMap/*<B>*/(Monoid/*<B>*/ bMonoid, /*=B*/ f(A a));

  /*=B*/ foldRight/*<B>*/(/*=B*/ z, /*=B*/ f(A a, /*=B*/ previous)) => foldMap/*<Endo<B>>*/(EndoMi, curry2(f))(z);

  /*=B*/ foldLeft/*<B>*/(/*=B*/ z, /*=B*/ f(/*=B*/ previous, A a)) => foldMap/*<Endo<B>>*/(DualEndoMi, curry2(flip(f)))(z);

  Option/*<B>*/ foldMapO/*<B>*/(Semigroup/*<B>*/ si, /*=B*/ f(A a)) => foldMap/*<Option<B>>*/(new OptionMonoid/*<B>*/(si), composeF(some, f));

  A concatenate(Monoid<A> mi) => foldMap(mi, id);

  Option<A> concatenateO(Semigroup<A> si) => foldMapO(si, id);

  int length() => foldLeft(0, (a, b) => a+1);

  bool any(bool f(A a)) => foldMap(BoolOrMi, f);

  bool all(bool f(A a)) => foldMap(BoolAndMi, f);

  Option<A> minimum(Order<A> oa) => concatenateO(new MinSemigroup<A>(oa));

  Option<A> maximum(Order<A> oa) => concatenateO(new MaxSemigroup<A>(oa));

  A intercalate(Monoid<A> mi, A a) => foldRight(none/*<A>*/(), (A ca, Option oa) => some(mi.append(ca, oa.fold(mi.zero, mi.appendC(a))))) | mi.zero();

  /*=G*/ collapse/*<G>*/(ApplicativePlus/*<G>*/ ap) => foldLeft(ap.empty(), (p, a) => ap.plus(p, ap.pure(a)));

  /*=G*/ foldLeftM/*<G>*/(Monad/*<G>*/ m, z, /*=G*/ f(previous, A a)) => foldRight/*<Function1<dynamic, G>>*/(m.pure, (A a, b) => (w) => m.bind(f(w, a), b))(z);

  /*=G*/ foldRightM/*<G>*/(Monad/*<G>*/ m, z, /*=G*/ f(A a, previous)) => foldLeft/*<Function1<dynamic, G>>*/(m.pure, (b, A a) => (w) => m.bind(f(a, w), b))(z);
}

class FoldableOpsFoldable<F extends FoldableOps> extends Foldable<F> {
  @override /*=B*/ foldMap/*<B>*/(Monoid/*<B>*/ bMonoid, F fa, /*=B*/ f(a)) => fa.foldMap(bMonoid, f);
  @override /*=B*/ foldRight/*<B>*/(F fa, /*=B*/ z, /*=B*/ f(a, /*=B*/ previous)) => fa.foldRight(z, f);
  @override /*=B*/ foldLeft/*<B>*/(F fa, /*=B*/ z, /*=B*/ f(/*=B*/ previous, a)) => fa.foldLeft(z, f);
}
