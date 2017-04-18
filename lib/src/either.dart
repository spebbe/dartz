part of dartz;

// Workaround: Non-commented syntax triggers "illegal recursive type", while commented syntax yields correct types and behaviour...
abstract class Either<L, R> extends TraversableOps<Either/*<L, dynamic>*/, R> with FunctorOps<Either/*<L, dynamic>*/, R>, ApplicativeOps<Either/*<L, dynamic>*/, R>, MonadOps<Either/*<L, dynamic>*/, R>, TraversableMonadOps<Either/*<L, dynamic>*/, R> {
  B fold<B>(B ifLeft(L l), B ifRight(R r));

  Either<L, R> orElse(Either<L, R> other()) => fold((_) => other(), (_) => this);
  R getOrElse(R dflt()) => fold((_) => dflt(), id);
  R operator |(R dflt) => getOrElse(() => dflt);
  Either<L2, R> leftMap<L2>(L2 f(L l)) => fold((L l) => left(f(l)), right);
  Option<R> toOption() => fold((_) => none(), some);

  @override Either<L, R2> pure<R2>(R2 r2) => right(r2);
  @override Either<L, R2> map<R2>(R2 f(R r)) => fold(left, (R r) => right(f(r)));
  @override Either<L, R2> bind<R2>(Either<L, R2> f(R r)) => fold(left, f);
  @override Either<L, R2> flatMap<R2>(Either<L, R2> f(R r)) => fold(left, f);
  @override Either<L, R2> andThen<R2>(Either<L, R2> next) => fold(left, (_) => next);

  @override G traverse<G>(Applicative<G> gApplicative, G f(R r)) => fold((_) => gApplicative.pure(this), (R r) => gApplicative.map(f(r), right));

  @override String toString() => fold((l) => 'Left($l)', (r) => 'Right($r)');

  // PURISTS BEWARE: mutable Iterable/Iterator integrations below -- proceed with caution!

  Iterable<R> toIterable() => fold((_) => cast(_emptyIterable), (r) => new _SingletonIterable(r));
  Iterator<R> iterator() => toIterable().iterator;
}

class Left<L, R> extends Either<L, R> {
  final L _l;
  Left(this._l);
  @override B fold<B>(B ifLeft(L l), B ifRight(R r)) => ifLeft(_l);
  @override bool operator ==(other) => other is Left && other._l == _l;
  @override int get hashCode => _l.hashCode;
}

class Right<L, R> extends Either<L, R> {
  final R _r;
  Right(this._r);
  @override B fold<B>(B ifLeft(L l), B ifRight(R r)) => ifRight(_r);
  @override bool operator ==(other) => other is Right && other._r == _r;
  @override int get hashCode => _r.hashCode;
}


Either<L, R> left<L, R>(L l) => new Left(l);
Either<L, R> right<L, R>(R r) => new Right(r);
Either<dynamic, A> catching<A>(Function0<A> thunk) {
  try {
    return right(thunk());
  } catch(e) {
    return left(e);
  }
}

class EitherMonad<L> extends MonadOpsMonad<Either<L, dynamic>> {
  EitherMonad(): super(right);

  @override Either<L, C> map2<A, A2 extends A, B, B2 extends B, C>(Either<L, A2> fa, Either<L, B2> fb, C fun(A a, B b)) =>
      fa.fold(left, (a) => fb.fold(left, (b) => right(fun(a, b))));

  @override Either<L, D> map3<A, A2 extends A, B, B2 extends B, C, C2 extends C, D>(Either<L, A2> fa, Either<L, B2> fb, Either<L, C2> fc, D fun(A a, B b, C c)) =>
      fa.fold(left, (a) => fb.fold(left, (b) => fc.fold(left, (c) => right(fun(a, b, c)))));

  @override Either<L, E> map4<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E>(Either<L, A2> fa, Either<L, B2> fb, Either<L, C2> fc, Either<L, D2> fd, E fun(A a, B b, C c, D d)) =>
      fa.fold(left, (a) => fb.fold(left, (b) => fc.fold(left, (c) => fd.fold(left, (d) => right(fun(a, b, c, d))))));

  @override Either<L, F> map5<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F>(Either<L, A2> fa, Either<L, B2> fb, Either<L, C2> fc, Either<L, D2> fd, Either<L, E2> fe, F fun(A a, B b, C c, D d, E e)) =>
      fa.fold(left, (a) => fb.fold(left, (b) => fc.fold(left, (c) => fd.fold(left, (d) => fe.fold(left, (e) => right(fun(a, b, c, d, e)))))));

  @override Either<L, G> map6<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G>(Either<L, A2> fa, Either<L, B2> fb, Either<L, C2> fc, Either<L, D2> fd, Either<L, E2> fe, Either<L, F2> ff, G fun(A a, B b, C c, D d, E e, F f)) =>
      fa.fold(left, (a) => fb.fold(left, (b) => fc.fold(left, (c) => fd.fold(left, (d) => fe.fold(left, (e) => ff.fold(left, (f) => right(fun(a, b, c, d, e, f))))))));

}

final EitherMonad EitherM = new EitherMonad();
Monad<Either<L, R>> eitherM<L, R>() => cast(EitherM);
final Traversable<Either> EitherTr = new TraversableOpsTraversable<Either>();
Traversable<Either<L, R>> eitherTr<L, R>() => cast(EitherTr);

class EitherTMonad<M> extends Functor<M> with Applicative<M>, Monad<M> {
  Monad _stackedM;
  EitherTMonad(this._stackedM);
  Monad underlying() => EitherM;

  @override M pure<A>(A a) => cast(_stackedM.pure(right(a)));
  @override M bind<A, B>(M mea, M f(A a)) => cast(_stackedM.bind(mea, (Either e) => e.fold((l) => _stackedM.pure(left(l)), f)));
}

Monad eitherTMonad(Monad mmonad) => new EitherTMonad(mmonad);

