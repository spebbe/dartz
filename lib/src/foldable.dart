// ignore_for_file: unnecessary_new

part of dartz;

abstract class Foldable<F> {
  // def foldMap[A, B: Monoid](fa: Option[A], f: A => B): B
  B foldMap<A, B>(Monoid<B> bMonoid, covariant F fa, B f(A a));

  B foldRight<A, B>(F fa, B z, B f(A a, B previous)) => foldMap<A, Endo<B>>(endoMi(), fa, curry2(f))(z);

  B foldRightWithIndex<A, B>(F fa, B z, B f(int i, a, B previous)) => foldRight(fa, tuple2(z, length(fa)-1), (a, Tuple2<B, int> t) => tuple2(f(t.value2, a, t.value1), t.value2-1)).value1;

  B foldLeft<A, B>(F fa, B z, B f(B previous, A a)) => foldMap<A, Endo<B>>(dualEndoMi(), fa, curry2(flip(f)))(z);

  B foldLeftWithIndex<A, B>(F fa, B z, B f(B previous, int i, A a)) => foldLeft(fa, tuple2(z, 0), (Tuple2<B, int> t, A a) => tuple2(f(t.value1, t.value2, a), t.value2+1)).value1;

  Option<B> foldMapO<A, B>(Semigroup<B> si, F fa, B f(A a)) => foldMap(new OptionMonoid(si), fa, composeF(some, f));

  A concatenate<A>(Monoid<A> mi, F fa) => foldMap(mi, fa, id);

  Option<A> concatenateO<A>(Semigroup<A> si, F fa) => foldMapO(si, fa, id);

  int length(F fa) => foldLeft(fa, 0, (a, _) => a+1);

  bool any(F fa, bool f(a)) => foldMap(BoolOrMi, fa, f);

  bool all(F fa, bool f(a)) => foldMap(BoolAndMi, fa, f);

  Option<A> minimum<A>(Order<A> oa, F fa) => concatenateO(new MinSemigroup(oa), fa);

  Option<A> maximum<A>(Order<A> oa, F fa) => concatenateO(new MaxSemigroup(oa), fa);

  A intercalate<A>(Monoid<A> mi, F fa, A a) => foldRight<A, Option<A>>(fa, none(), (A ca, oa) => some(mi.append(ca, oa.fold(mi.zero, mi.appendC(a))))) | mi.zero();

  G collapse<A, G>(ApplicativePlus<G> ap, F fa) => foldLeft(fa, ap.empty(), (p, a) => ap.plus(p, ap.pure(a)));

  G foldLeftM<A, B, G>(Monad<G> m, F fa, B z, G f(B previous, A a)) => foldRight<A, Function1<B, G>>(fa, m.pure, (a, b) => (w) => m.bind(f(w, a), b))(z);

  G foldRightM<A, B, G>(Monad<G> m, F fa, B z, G f(A a, B previous)) => foldLeft<A, Function1<B, G>>(fa, m.pure, (b, a) => (w) => m.bind(f(a, w), b))(z);

  G foldMapM<A, B, G>(Monad<G> m, Monoid<B> bMonoid, F fa, G f(A a)) => foldMap(monoid(() => m.pure(bMonoid.zero()), cast(m.lift2(bMonoid.append))), fa, f);
}

abstract class FoldableOps<F, A> {
  B foldMap<B>(Monoid<B> bMonoid, B f(A a));

  B foldRight<B>(B z, B f(A a, B previous)) => foldMap<Endo<B>>(endoMi(), curry2(f))(z);

  B foldRightWithIndex<B>(B z, B f(int i, A a, B previous)) => foldRight<Tuple2<B, int>>(tuple2(z, length()-1), (a, t) => tuple2(f(t.value2, a, t.value1), t.value2-1)).value1;

  B foldLeft<B>(B z, B f(B previous, A a)) => foldMap<Endo<B>>(dualEndoMi(), curry2(flip(f)))(z);

  B foldLeftWithIndex<B>(B z, B f(B previous, int i, A a)) => foldLeft<Tuple2<B, int>>(tuple2(z, 0), (t, a) => tuple2(f(t.value1, t.value2, a), t.value2+1)).value1;

  Option<B> foldMapO<B>(Semigroup<B> si, B f(A a)) => foldMap(new OptionMonoid(si), composeF(some, f));

  A concatenate(Monoid<A> mi) => foldMap(mi, id);

  Option<A> concatenateO(Semigroup<A> si) => foldMapO(si, id);

  int length() => foldLeft(0, (a, b) => a+1);

  bool any(bool f(A a)) => foldMap(BoolOrMi, f);

  bool all(bool f(A a)) => foldMap(BoolAndMi, f);

  Option<A> minimum(Order<A> oa) => concatenateO(new MinSemigroup(oa));

  Option<A> maximum(Order<A> oa) => concatenateO(new MaxSemigroup(oa));

  A intercalate(Monoid<A> mi, A a) => foldRight(none<A>(), (A ca, Option<A> oa) => some(mi.append(ca, oa.fold(mi.zero, mi.appendC(a))))) | mi.zero();

}

class FoldableOpsFoldable<F extends FoldableOps> extends Foldable<F> {
  @override B foldMap<A, B>(Monoid<B> bMonoid, F fa, B f(A a)) => fa.foldMap(bMonoid, cast(f));
  @override B foldRight<A, B>(F fa, B z, B f(A a, B previous)) => fa.foldRight(z, cast(f));
  @override B foldLeft<A, B>(F fa, B z, B f(B previous, A a)) => fa.foldLeft(z, cast(f));
}
