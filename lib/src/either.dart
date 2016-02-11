part of dartz;

abstract class Either<L, R> extends TraversableOps<Either, R> with MonadOps<Either, R> {
  fold(ifLeft(L l), ifRight(R r));
  Either map(f(R r)) => fold((L l) => this, (R r) => right(f(r)));
  Either flatMap(Either f(R r)) => fold((L l) => this, (R r) => f(r));
  R getOrElse(R dflt) => fold((l) => dflt, (r) => r);
  Either leftMap(f(L l)) => fold((L l) => left(f(l)), (R r) => this);

  @override Either pure(a) => right(a);
  @override Either bind(Either f(R r)) => flatMap(f);

  @override traverse(Applicative gApplicative, f(R r)) => fold((L l) => gApplicative.pure(this), (R r) => gApplicative.map(f(r), right));

  @override String toString() => fold((l) => 'Left($l)', (r) => 'Right($r)');
}

class Left<L, R> extends Either<L, R> {
  final L _l;
  Left(this._l);
  @override fold(ifLeft(L l), ifRight(R r)) => ifLeft(_l);
  @override bool operator ==(other) => other is Left && other._l == _l;
}

class Right<L, R> extends Either<L, R> {
  final R _r;
  Right(this._r);
  @override fold(ifLeft(L l), ifRight(R r)) => ifRight(_r);
  @override bool operator ==(other) => other is Right && other._r == _r;
}


Either left(l) => new Left(l);
Either right(r) => new Right(r);

final Monad<Either> EitherM = new MonadOpsMonad<Either>(right);
final Applicative<Either> EitherA = EitherM;
final Functor<Either> EitherF = EitherM;

final Traversable<Either> EitherTr = new TraversableOpsTraversable<Either>();
final Foldable<Either> EitherFo = EitherTr;

class EitherTMonad<M> extends Monad<M> {
  Monad _stackedM;
  EitherTMonad(this._stackedM);
  Monad underlying() => EitherM;

  @override M pure(a) => _stackedM.pure(right(a));
  @override M bind(M mea, M f(_)) => _stackedM.bind(mea, (Either e) => e.fold((l) => _stackedM.pure(left(l)), f));
}

Monad eitherTMonad(Monad mmonad) => new EitherTMonad(mmonad);

