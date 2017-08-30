part of dartz;

// Workaround for https://github.com/dart-lang/sdk/issues/29949
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

  // PURISTS BEWARE: side effecty stuff below -- proceed with caution!

  Iterable<R> toIterable() => fold((_) => cast(_emptyIterable), (r) => new _SingletonIterable(r));
  Iterator<R> iterator() => toIterable().iterator;

  void forEach(void sideEffect(R r)) => fold((_) => null, sideEffect);
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

  Either<L, C> mapM2<A, A2 extends A, B, B2 extends B, C>(Either<L, A2> fa, Either<L, B2> fb, Either<L, C> f(A a, B b)) => fa.bind((a) => fb.bind((b) => f(a, b)));

  @override Function1<Either<L, A>, Either<L, B>> lift<A, B>(B f(A a)) => ((Either<L, A> oa) => oa.map(f));
  @override Function2<Either<L, A>, Either<L, B>, Either<L, C>> lift2<A, B, C>(C f(A a, B b)) => (Either<L, A> fa, Either<L, B> fb) => map2(fa, fb, f);
  @override Function3<Either<L, A>, Either<L, B>, Either<L, C>, Either<L, D>> lift3<A, B, C, D>(D f(A a, B b, C c)) => (Either<L, A> fa, Either<L, B> fb, Either<L, C> fc) => map3(fa, fb, fc, f);
  @override Function4<Either<L, A>, Either<L, B>, Either<L, C>, Either<L, D>, Either<L, E>> lift4<A, B, C, D, E>(E f(A a, B b, C c, D d)) => (Either<L, A> fa, Either<L, B> fb, Either<L, C> fc, Either<L, D> fd) => map4(fa, fb, fc, fd, f);
  @override Function5<Either<L, A>, Either<L, B>, Either<L, C>, Either<L, D>, Either<L, E>, Either<L, F>> lift5<A, B, C, D, E, F>(F f(A a, B b, C c, D d, E e)) => (Either<L, A> fa, Either<L, B> fb, Either<L, C> fc, Either<L, D> fd, Either<L, E> fe) => map5(fa, fb, fc, fd, fe, f);
  @override Function6<Either<L, A>, Either<L, B>, Either<L, C>, Either<L, D>, Either<L, E>, Either<L, F>, Either<L, G>> lift6<A, B, C, D, E, F, G>(G f(A a, B b, C c, D d, E e, F f)) => (Either<L, A> fa, Either<L, B> fb, Either<L, C> fc, Either<L, D> fd, Either<L, E> fe, Either<L, F> ff) => map6(fa, fb, fc, fd, fe, ff, f);

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

