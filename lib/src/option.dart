part of dartz;

abstract class Option<A> implements TraversableMonadPlusOps<Option, A> {
  const Option();

  B fold<B>(B ifNone(), B ifSome(A a));

  B cata<B, B2 extends B>(B ifNone(), B2 ifSome(A a)) => fold(ifNone, ifSome);
  Option<A> orElse(Option<A> other()) => fold(other, (_) => this);
  A getOrElse(A dflt()) => fold(dflt, (a) => a);
  Either<B, A> toEither<B>(B ifNone()) => fold(() => left(ifNone()), (a) => right(a));
  Either<dynamic, A> operator %(ifNone) => toEither(() => ifNone);
  A operator |(A dflt) => getOrElse(() => dflt);

  @override Option<B> map<B>(B f(A a)) => fold(none, (A a) => some(f(a)));
  @override Option<B> ap<B>(Option<Function1<A, B>> ff) => fold(none, (A a) => ff.fold(none, (Function1<A, B> f) => some(f(a))));
  @override Option<B> bind<B>(Option<B> f(A a)) => fold(none, f);
  @override Option<B> flatMap<B>(Option<B> f(A a)) => fold(none, f);
  @override Option<B> andThen<B>(Option<B> next) => fold(none, (_) => next);



  IList<Option<B>> traverseIList<B>(IList<B> f(A a)) => fold(() => cons(none(), nil()), (a) => f(a).map(some));

  IVector<Option<B>> traverseIVector<B>(IVector<B> f(A a)) => fold(() => emptyVector<Option<B>>().appendElement(none()), (a) => f(a).map(some));

  Future<Option<B>> traverseFuture<B>(Future<B> f(A a)) => fold(() => new Future.microtask(none), (a) => f(a).then(some));

  State<S, Option<B>> traverseState<S, B>(State<S, B> f(A a)) => fold(() => new State((s) => tuple2(none(), s)), (a) => f(a).map(some));

  static IList<Option<A>> sequenceIList<A>(Option<IList<A>> ola) => ola.traverseIList(id);

  static IVector<Option<A>> sequenceIVector<A>(Option<IVector<A>> ova) => ova.traverseIVector(id);

  static Future<Option<A>> sequenceFuture<A>(Option<Future<A>> ofa) => ofa.traverseFuture(id);

  static State<S, Option<A>> sequenceState<S, A>(Option<State<S, A>> osa) => osa.traverseState(id);

  @override Option<A> plus(Option<A> o2) => orElse(() => o2);

  @override Option<A> filter(bool predicate(A a)) => fold(none, (a) => predicate(a) ? this : none());
  @override Option<A> where(bool predicate(A a)) => filter(predicate);

  bool isSome() => fold(() => false, (_) => true);

  bool isNone() => !isSome();

  static Option<C> map2<A, A2 extends A, B, B2 extends B, C>(Option<A2> fa, Option<B2> fb, C fun(A a, B b)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => some(fun(a, b))));

  static Option<D> map3<A, A2 extends A, B, B2 extends B, C, C2 extends C, D>(Option<A2> fa, Option<B2> fb, Option<C2> fc, D fun(A a, B b, C c)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => some(fun(a, b, c)))));

  static Option<E> map4<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, E fun(A a, B b, C c, D d)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => some(fun(a, b, c, d))))));

  static Option<F> map5<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, F fun(A a, B b, C c, D d, E e)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => some(fun(a, b, c, d, e)))))));

  static Option<G> map6<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, G fun(A a, B b, C c, D d, E e, F f)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => some(fun(a, b, c, d, e, f))))))));

  static Option<C> mapM2<A, A2 extends A, B, B2 extends B, C>(Option<A2> fa, Option<B2> fb, Option<C> f(A a, B b)) => fa.bind((a) => fb.bind((b) => f(a, b)));

  static Function1<Option<A>, Option<B>> lift<A, B>(B f(A a)) => ((Option<A> oa) => oa.map(f));
  static Function2<Option<A>, Option<B>, Option<C>> lift2<A, B, C>(C f(A a, B b)) => (Option<A> fa, Option<B> fb) => map2(fa, fb, f);
  static Function3<Option<A>, Option<B>, Option<C>, Option<D>> lift3<A, B, C, D>(D f(A a, B b, C c)) => (Option<A> fa, Option<B> fb, Option<C> fc) => map3(fa, fb, fc, f);
  static Function4<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>> lift4<A, B, C, D, E>(E f(A a, B b, C c, D d)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd) => map4(fa, fb, fc, fd, f);
  static Function5<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>> lift5<A, B, C, D, E, F>(F f(A a, B b, C c, D d, E e)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe) => map5(fa, fb, fc, fd, fe, f);
  static Function6<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>> lift6<A, B, C, D, E, F, G>(G f(A a, B b, C c, D d, E e, F f)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff) => map6(fa, fb, fc, fd, fe, ff, f);

  @override String toString() => fold(() => 'None', (a) => 'Some($a)');

  // PURISTS BEWARE: side effecty stuff below -- proceed with caution!

  Iterable<A> toIterable() => fold(() => const Iterable.empty(), (a) => new _SingletonIterable(a));
  Iterator<A> iterator() => toIterable().iterator;

  void forEach(void sideEffect(A a)) => fold(() => null, sideEffect);

  @override bool all(bool f(A a)) => map(f)|true;

  @override bool any(bool f(A a)) => map(f)|false;

  @override Option<A> appendElement(A a) => orElse(() => some(a));

  @override A concatenate(Monoid<A> mi) => getOrElse(mi.zero);

  @override Option<A> concatenateO(Semigroup<A> si) => this;

  @override B foldLeft<B>(B z, B f(B previous, A a)) => fold(() => z, (a) => f(z, a));

  @override B foldLeftWithIndex<B>(B z, B f(B previous, int i, A a)) => fold(() => z, (a) => f(z, 0, a));

  @override B foldMap<B>(Monoid<B> bMonoid, B f(A a)) => fold(bMonoid.zero, f);

  @override Option<B> foldMapO<B>(Semigroup<B> si, B f(A a)) => map(f);

  @override B foldRight<B>(B z, B f(A a, B previous)) => fold(() => z, (a) => f(a, z));

  @override B foldRightWithIndex<B>(B z, B f(int i, A a, B previous))=> fold(() => z, (a) => f(0, a, z));

  @override A intercalate(Monoid<A> mi, A a) => fold(mi.zero, id);

  @override int length() => fold(() => 0, (_) => 1);

  @override Option<B> mapWithIndex<B>(B f(int i, A a)) => map((a) => f(0, a));

  @override Option<A> maximum(Order<A> oa) => this;

  @override Option<A> minimum(Order<A> oa) => this;

  Tuple2<Option<A>, Option<A>> partition(bool f(A a)) => map(f)|false ? tuple2(this, none()) : tuple2(none(), this);

  @override Option<A> prependElement(A a) => some(a).orElse(() => this);

  @override Option<B> replace<B>(B replacement) => map((_) => replacement);

  Option<A> reverse() => this;

  @override Option<Tuple2<B, A>> strengthL<B>(B b) => map((a) => tuple2(b, a));

  @override Option<Tuple2<A, B>> strengthR<B>(B b) => map((a) => tuple2(a, b));

  @override Option<Tuple2<int, A>> zipWithIndex() => map((a) => tuple2(0, a));
}

class Some<A> extends Option<A> {
  final A _a;
  const Some(this._a);
  A get value => _a;
  @override B fold<B>(B ifNone(), B ifSome(A a)) => ifSome(_a);
  @override bool operator ==(other) => other is Some && other._a == _a;
  @override int get hashCode => _a.hashCode;
}

class None<A> extends Option<A> {
  const None();
  @override B fold<B>(B ifNone(), B ifSome(A a)) => ifNone();
  @override bool operator ==(other) => other is None;
  @override int get hashCode => 0;
}

Option<A> none<A>() => new None();
Option<A> some<A>(A a) => new Some(a);
Option<A> option<A>(bool test, A value) => test ? some(value) : none();
Option<A> optionOf<A>(A value) => value != null ? some(value) : none();

class OptionMonadPlus extends MonadPlus<Option> with Monad<Option>, ApplicativePlus<Option>, Applicative<Option>, Functor<Option>, PlusEmpty<Option>, Plus<Option> {
  @override Option<B> map<A, B>(Option<A> fa, B f(A a)) => fa.map(f);
  @override Option<B> ap<A, B>(Option<A> fa, Option<Function1<A, B>> ff) => fa.ap(ff);
  @override Option<B> bind<A, B>(Option<A> fa, Option<B> f(A a)) => fa.bind(f);
  @override Option<A> empty<A>() => none();
  @override Option<A> plus<A>(Option<A> f1, Option<A> f2) => f1.plus(f2);
  @override Option<A> pure<A>(A a) => some(a);
}

class OptionTraversable extends Traversable<Option> {
  @override B foldMap<A, B>(Monoid<B> bMonoid, Option<A> fa, B f(A a)) => fa.foldMap(bMonoid, f);
  @override Option map<A, B>(Option<A> fa, B f(A a)) => fa.map(f);
}

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