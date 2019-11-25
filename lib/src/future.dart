// ignore_for_file: unnecessary_new

part of dartz;

class FutureMonad extends Functor<Future> with Applicative<Future>, Monad<Future> {
  @override Future<A> pure<A>(A a) => new Future.microtask(() => a);
  @override Future<B> map<A, B>(Future<A> fa, B f(A a)) => fa.then(f);
  @override Future<B> bind<A, B>(Future<A> fa, Function1<A, Future<B>> f) => fa.then(f);
}

final FutureMonad FutureM = new FutureMonad();
Monad<Future<A>> futureM<A>() => cast(FutureM);
