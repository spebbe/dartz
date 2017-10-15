part of dartz;

abstract class Option<A> extends TraversableOps<Option, A> with FunctorOps<Option, A>, ApplicativeOps<Option, A>, ApplicativePlusOps<Option, A>, MonadOps<Option, A>, MonadPlusOps<Option, A>, TraversableMonadOps<Option, A>, TraversableMonadPlusOps<Option, A> {
  B fold<B>(B ifNone(), B ifSome(A a));

  B cata<B, B2 extends B>(B ifNone(), B2 ifSome(A a)) => fold(ifNone, ifSome);
  Option<A> orElse(Option<A> other()) => fold(other, (_) => this);
  A getOrElse(A dflt()) => fold(dflt, (a) => a);
  Either<B, A> toEither<B>(B ifNone()) => fold(() => left(ifNone()), (a) => right(a));
  Either<dynamic, A> operator %(ifNone) => toEither(() => ifNone);
  A operator |(A dflt) => getOrElse(() => dflt);

  @override Option<B> pure<B>(B b) => some(b);
  @override Option<B> map<B>(B f(A a)) => fold(none, (A a) => some(f(a)));
  @override Option<B> ap<B>(Option<Function1<A, B>> ff) => fold(none, (A a) => ff.fold(none, (Function1<A, B> f) => some(f(a))));
  @override Option<B> bind<B>(Option<B> f(A a)) => fold(none, f);
  @override Option<B> flatMap<B>(Option<B> f(A a)) => fold(none, f);
  @override Option<B> andThen<B>(Option<B> next) => fold(none, (_) => next);

  @override G traverse<G>(Applicative<G> gApplicative, G f(A a)) => fold(() => gApplicative.pure(none()), (a) => gApplicative.map(f(a), some));

  @override Option<A> empty() => none();
  @override Option<A> plus(Option<A> o2) => orElse(() => o2);

  @override String toString() => fold(() => 'None', (a) => 'Some($a)');

  // PURISTS BEWARE: side effecty stuff below -- proceed with caution!

  Iterable<A> toIterable() => fold(() => cast(_emptyIterable), (a) => new _SingletonIterable(a));
  Iterator<A> iterator() => toIterable().iterator;

  void forEach(void sideEffect(A a)) => fold(() => null, sideEffect);
}

class Some<A> extends Option<A> {
  final A _a;
  Some(this._a);
  @override B fold<B>(B ifNone(), B ifSome(A a)) => ifSome(_a);
  @override bool operator ==(other) => other is Some && other._a == _a;
  @override int get hashCode => _a.hashCode;
}

class None<A> extends Option<A> {
  @override B fold<B>(B ifNone(), B ifSome(A a)) => ifNone();
  @override bool operator ==(other) => other is None;
  @override int get hashCode => 0;
}

final Option _none = new None();
Option<A> none<A>() => cast(_none);
Option<A> some<A>(A a) => new Some(a);
Option<A> option<A>(bool test, A value) => test ? some(value) : none();
Option<A> optionOf<A>(A value) => value != null ? some(value) : none();

class OptionMonadPlus extends MonadPlusOpsMonadPlus<Option> {
  OptionMonadPlus() : super(some, none);

  @override Option<B> map<A, B>(Option<A> fa, B f(A a)) => fa.map(f);
  @override Option<B> ap<A, B>(Option<A> fa, Option<Function1<A, B>> ff) => fa.ap(ff);
  @override Option<B> bind<A, B>(Option<A> fa, Option<B> f(A a)) => fa.bind(f);

  @override Option<C> map2<A, A2 extends A, B, B2 extends B, C>(Option<A2> fa, Option<B2> fb, C fun(A a, B b)) =>
      fa.fold(none, (a) => fb.fold(none, (b) => some(fun(a, b))));

  @override Option<D> map3<A, A2 extends A, B, B2 extends B, C, C2 extends C, D>(Option<A2> fa, Option<B2> fb, Option<C2> fc, D fun(A a, B b, C c)) =>
      fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => some(fun(a, b, c)))));

  @override Option<E> map4<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, E fun(A a, B b, C c, D d)) =>
      fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => some(fun(a, b, c, d))))));

  @override Option<F> map5<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, F fun(A a, B b, C c, D d, E e)) =>
      fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => some(fun(a, b, c, d, e)))))));

  @override Option<G> map6<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, G fun(A a, B b, C c, D d, E e, F f)) =>
      fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => some(fun(a, b, c, d, e, f))))))));

  Option<C> mapM2<A, A2 extends A, B, B2 extends B, C>(Option<A2> fa, Option<B2> fb, Option<C> f(A a, B b)) => fa.bind((a) => fb.bind((b) => f(a, b)));

  @override Function1<Option<A>, Option<B>> lift<A, B>(B f(A a)) => ((Option<A> oa) => oa.map(f));
  @override Function2<Option<A>, Option<B>, Option<C>> lift2<A, B, C>(C f(A a, B b)) => (Option<A> fa, Option<B> fb) => map2(fa, fb, f);
  @override Function3<Option<A>, Option<B>, Option<C>, Option<D>> lift3<A, B, C, D>(D f(A a, B b, C c)) => (Option<A> fa, Option<B> fb, Option<C> fc) => map3(fa, fb, fc, f);
  @override Function4<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>> lift4<A, B, C, D, E>(E f(A a, B b, C c, D d)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd) => map4(fa, fb, fc, fd, f);
  @override Function5<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>> lift5<A, B, C, D, E, F>(F f(A a, B b, C c, D d, E e)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe) => map5(fa, fb, fc, fd, fe, f);
  @override Function6<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>> lift6<A, B, C, D, E, F, G>(G f(A a, B b, C c, D d, E e, F f)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff) => map6(fa, fb, fc, fd, fe, ff, f);

}

final OptionMonadPlus OptionMP = new OptionMonadPlus();
MonadPlus<Option<A>> optionMP<A>() => cast(OptionMP);
final Traversable<Option> OptionTr = new TraversableOpsTraversable<Option>();
Traversable<Option<A>> optionTr<A>() => cast(OptionTr);

class OptionTMonad<M> extends Functor<M> with Applicative<M>, Monad<M> {
  Monad _stackedM;
  OptionTMonad(this._stackedM);
  Monad underlying() => OptionMP;

  @override M pure<A>(A a) => cast(_stackedM.pure(some(a)));
  @override M bind<A, B>(M moa, M f(A a)) => cast(_stackedM.bind(moa, (Option o) => o.fold(() => _stackedM.pure(none()), cast(f))));
}

Monad optionTMonad(Monad mmonad) => new OptionTMonad(mmonad);

class OptionMonoid<A> extends Monoid<Option<A>> {
  final Semigroup<A> _tSemigroup;

  OptionMonoid(this._tSemigroup);

  @override Option<A> zero() => none();

  @override Option<A> append(Option<A> oa1, Option<A> oa2) => oa1.fold(() => oa2, (a1) => oa2.fold(() => oa1, (a2) => some(_tSemigroup.append(a1, a2))));
}
Monoid<Option<A>> optionMi<A>(Semigroup<A> si) => new OptionMonoid(si);

class _SingletonIterable<A> extends Iterable<A> {
  final A _singleton;
  _SingletonIterable(this._singleton);
  @override Iterator<A> get iterator => new _SingletonIterator(_singleton);
}

class _SingletonIterator<A> extends Iterator<A> {
  final A _singleton;
  int _moves = 0;
  _SingletonIterator(this._singleton);
  @override A get current => _moves == 1 ? _singleton : null;
  @override bool moveNext() => ++_moves == 1;
}

final _emptyIterable = new Iterable<dynamic>.empty();