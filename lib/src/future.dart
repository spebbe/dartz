// ignore_for_file: unnecessary_new

part of dartz;

class FutureMonad extends Functor<Future>
    with Applicative<Future>, Monad<Future> {
  const FutureMonad() : super._();

  @override
  Future<A> pure<A>(A a) => Future.microtask(() => a);

  @override
  Future<B> map<A, B>(covariant Future<A> fa, B f(A a)) => fa.then(f);

  @override
  Future<B> bind<A, B>(
    covariant Future<A> fa,
    covariant Function1<A, Future<B>> f,
  ) =>
      fa.then(f);
}

const FutureMonad FutureM = FutureMonad();
Monad<Future<A>> futureM<A>() => cast(FutureM);
