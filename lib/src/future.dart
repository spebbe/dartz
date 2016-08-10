part of dartz;

class FutureMonad extends Functor<Future> with Applicative<Future>, Monad<Future> {
  @override Future/*<A>*/ pure/*<A>*/(/*=A*/ a) => new Future.value(a);
  @override Future/*<B>*/ map/*<A, B>*/(Future/*<A>*/ fa, /*=B*/ f(/*=A*/ a)) => fa.then(f);
  @override Future/*<B>*/ bind/*<A, B>*/(Future/*<A>*/ fa, Future/*<B>*/ f(/*=A*/ a)) => fa.then(f);
}

final FutureMonad FutureM = new FutureMonad();
