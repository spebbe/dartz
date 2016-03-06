part of dartz;

class FutureMonad extends Monad<Future> {
  @override Future pure(a) => new Future.value(a);
  @override Future map(Future fa, f(_)) => fa.then(f);
  @override Future bind(Future fa, Future f(_)) => fa.then(f);
}

final Monad<Future> FutureM = new FutureMonad();