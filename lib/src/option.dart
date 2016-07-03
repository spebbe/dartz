part of dartz;

abstract class Option<A> extends TraversableOps<Option, A> with MonadOps<Option, A>, MonadPlusOps<Option, A>, TraversableMonadOps<Option, A> {
  /*=B*/ fold/*<B, C extends B>*/(/*=B*/ ifNone(), /*=C*/ ifSome(A a));

  /*=B*/ cata/*<B, C extends B>*/(/*=B*/ ifNone(), /*=C*/ ifSome(A a)) => fold(ifNone, ifSome);
  Option<A> orElse(Option<A> other()) => fold(other, (_) => this);
  A getOrElse(A dflt()) => fold(dflt, (a) => a);
  Either<dynamic/*=B*/, A> toEither/*<B>*/(/*=B*/ ifNone()) => fold(() => left(ifNone()), (a) => right(a));
  Either<dynamic, A> operator %(ifNone) => toEither(() => ifNone);
  A operator |(A dflt) => getOrElse(() => dflt);

  @override Option/*<B>*/ pure/*<B>*/(/*=B*/ b) => some(b);
  Option/*<B>*/ map/*<B>*/(/*=B*/ f(A a)) => fold(none, (A a) => some(f(a)));
  @override Option/*<B>*/ bind/*<B>*/(Option/*<B>*/ f(A a)) => fold(none, f);

  @override /*=G*/ traverse/*<G>*/(Applicative/*<G>*/ gApplicative, /*=G*/ f(A a)) => fold(() => gApplicative.pure(none()), (a) => gApplicative.map(f(a), some));

  @override Option<A> empty() => none/*<A>*/();
  @override Option<A> plus(Option<A> o2) => orElse(() => o2);

  @override String toString() => fold(() => 'None', (a) => 'Some($a)');
}

class Some<A> extends Option<A> {
  final A _a;
  Some(this._a);
  @override /*=B*/ fold/*<B, C extends B>*/(/*=B*/ ifNone(), /*=C*/ ifSome(A a)) => ifSome(_a);
  @override bool operator ==(other) => other is Some && other._a == _a;
}

class None<A> extends Option<A> {
  @override /*=B*/ fold/*<B, C extends B>*/(/*=B*/ ifNone(), /*=C*/ ifSome(A a)) => ifNone();
  @override bool operator ==(other) => other is None;
}

final Option _none = new None();
Option/*<A>*/ none/*<A>*/() => _none as dynamic/*=None<A>*/;
Option/*<A>*/ some/*<A>*/(/*=A*/ a) => new Some/*<A>*/(a);
Option/*<A>*/ option/*<A>*/(bool test, /*=A*/ value) => test ? some(value) : none();

class OptionMonadPlus extends MonadPlusOpsMonadPlus<Option> {
  OptionMonadPlus() : super(some, none);

  @override Option/*<C>*/ map2/*<A, A2 extends A, B, B2 extends B, C>*/(Option/*<A2>*/ fa, Option/*<B2>*/ fb, Function2/*<A, B, C>*/ fun) =>
      fa.fold(none, (a) => fb.fold(none, (b) => some(fun(a, b))));

  @override Option/*<D>*/ map3/*<A, A2 extends A, B, B2 extends B, C, C2 extends C, D>*/(Option/*<A2>*/ fa, Option/*<B2>*/ fb, Option/*<C2>*/ fc, /*=D*/ fun(/*=A*/ a, /*=B*/ b, /*=C*/ c)) =>
      fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => some(fun(a, b, c)))));

  @override Option/*<E>*/ map4/*<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E>*/(Option/*<A2>*/ fa, Option/*<B2>*/ fb, Option/*<C2>*/ fc, Option/*<D2>*/ fd, /*=E*/ fun(/*=A*/ a, /*=B*/ b, /*=C*/ c, /*=D*/ d)) =>
      fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => some(fun(a, b, c, d))))));

  @override Option/*<F>*/ map5/*<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F>*/(Option/*<A2>*/ fa, Option/*<B2>*/ fb, Option/*<C2>*/ fc, Option/*<D2>*/ fd, Option/*<E2>*/ fe, /*=F*/ fun(/*=A*/ a, /*=B*/ b, /*=C*/ c, /*=D*/ d, /*=E*/ e)) =>
      fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => some(fun(a, b, c, d, e)))))));

  @override Option/*<G>*/ map6/*<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G>*/(Option/*<A2>*/ fa, Option/*<B2>*/ fb, Option/*<C2>*/ fc, Option/*<D2>*/ fd, Option/*<E2>*/ fe, Option/*<F2>*/ ff, /*=G*/ fun(/*=A*/ a, /*=B*/ b, /*=C*/ c, /*=D*/ d, /*=E*/ e, /*=F*/ f)) =>
      fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => some(fun(a, b, c, d, e, f))))))));

  Option/*<C>*/ mapM2/*<A, A2 extends A, B, B2 extends B, C>*/(Option/*<A2>*/ fa, Option/*<B2>*/ fb, Option/*<C>*/ f(/*=A*/ a, /*=B*/ b)) => fa.bind((a) => fb.bind((b) => f(a, b)));

}

final OptionMonadPlus OptionMP = new OptionMonadPlus();
MonadPlus<Option/*<A>*/> optionMP/*<A>*/() => OptionMP as dynamic/*=MonadPlus<Option<A>>*/;
final Traversable<Option> OptionTr = new TraversableOpsTraversable<Option>();

class OptionTMonad<M> extends Functor<M> with Applicative<M>, Monad<M> {
  Monad _stackedM;
  OptionTMonad(this._stackedM);
  Monad underlying() => OptionMP;

  @override M pure(a) => _stackedM.pure(some(a)) as dynamic/*=M*/;
  @override M bind(M moa, M f(_)) => _stackedM.bind(moa, (Option o) => o.fold(() => _stackedM.pure(none()), f)) as dynamic/*=M*/;
}

Monad optionTMonad(Monad mmonad) => new OptionTMonad(mmonad);

class OptionMonoid<A> extends Monoid<Option<A>> {
  final Semigroup<A> _tSemigroup;

  OptionMonoid(this._tSemigroup);

  @override Option<A> zero() => none/*<A>*/();

  @override Option<A> append(Option<A> oa1, Option<A> oa2) => oa1.fold(() => oa2, (a1) => oa2.fold(() => oa1, (a2) => some(_tSemigroup.append(a1, a2))));
}
Monoid<Option/*<A>*/> optionMi/*<A>*/(Semigroup/*<A>*/ si) => new OptionMonoid/*<A>*/(si);
