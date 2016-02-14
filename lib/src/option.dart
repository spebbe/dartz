part of dartz;

abstract class Option<A> extends TraversableOps<Option, A> with MonadOps<Option, A>, MonadPlusOps<Option, A> {
  fold(ifNone(), ifSome(A a));
  Option map(f(A a)) => fold(() => none, (A a) => some(f(a)));
  Option flatMap(Option f(A a)) => fold(() => none, (A a) => f(a));
  Option<A> orElse(Option<A> other) => fold(() => other, (_) => this);
  A getOrElse(A dflt) => fold(() => dflt, (a) => a);
  @override String toString() => fold(() => 'None', (a) => 'Some($a)');

  @override Option pure(a) => some(a);
  @override Option bind(Option f(A a)) => flatMap(f);

  @override traverse(Applicative gApplicative, f(A a)) => fold(() => gApplicative.pure(none), (a) => gApplicative.map(f(a), some));

  @override Option<A> empty() => none;

  @override Option<A> plus(Option<A> o2) => orElse(o2);

  Either<dynamic, A> operator %(ifNone) => fold(() => left(ifNone), right);
  A operator |(A dflt) => fold(() => dflt, (a) => a);
}

class Some<A> extends Option<A> {
  final A _a;
  Some(this._a);
  @override fold(ifNone(), ifSome(A v)) => ifSome(_a);
  @override bool operator ==(other) => other is Some && other._a == _a;
}

class None<A> extends Option<A> {
  @override fold(ifNone(), ifSome(A v)) => ifNone();
  @override bool operator ==(other) => other is None;
}

final Option none = new None();
Option some(a) => new Some(a);
Option option(test, value) => test ? some(value) : none;

final MonadPlus<Option> OptionMP = new MonadPlusOpsMonad<Option>(some, () => none);
final Monad<Option> OptionM = OptionMP;
final ApplicativePlus<Option> OptionAP = OptionMP;
final Applicative<Option> OptionA = OptionM;
final Functor<Option> OptionF = OptionM;
final Traversable<Option> OptionTr = new TraversableOpsTraversable<Option>();
final Foldable<Option> OptionFo = OptionTr;

class OptionTMonad<M> extends Monad<M> {
  Monad _stackedM;
  OptionTMonad(this._stackedM);
  Monad underlying() => OptionM;

  @override M pure(a) => _stackedM.pure(some(a));
  @override M bind(M moa, M f(_)) => _stackedM.bind(moa, (Option o) => o.fold(() => _stackedM.pure(none), f));
}

Monad optionTMonad(Monad mmonad) => new OptionTMonad(mmonad);

class OptionMonoid<A> extends Monoid<Option<A>> {
  final Semigroup<A> _tSemigroup;

  OptionMonoid(this._tSemigroup);

  @override Option<A> zero() => none;

  @override Option<A> append(Option<A> oa1, Option<A> oa2) => oa1.fold(() => oa2, (a1) => oa2.fold(() => oa1, (a2) => some(_tSemigroup.append(a1, a2))));
}
