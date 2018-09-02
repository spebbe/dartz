part of dartz;

abstract class Monad<F> implements Applicative<F> {
  F bind<A, B>(covariant F fa, covariant F f(A a));
  
  F join(F ffa) => bind(ffa, (F f) => f);

  @override F map<A, B>(covariant F fa, B f(A a)) => bind(fa, (A a) => pure(f(a)));
  @override F ap<A, B>(covariant F fa, covariant F ff) => bind(ff, (f(_)) => map(fa, f));
  
  //Monad<F> /** Monad<F<G<_>>> **/ composeM(Monad G, Traversable GT) => new ComposedMonad(this, G, GT);
}
/*
// Compose Monad<F<_>> with Monad<G<_>> and Traversable<G<_>>, yielding Monad<F<G<_>>>
class ComposedMonad<F, G> extends Functor<F> with Applicative<F>, Monad<F> {
  final Monad<F> _F;
  final Monad<G> _G;
  final Traversable<G> _GT;

  ComposedMonad(this._F, this._G, this._GT);

  @override F pure<A>(a) => _F.pure(_G.pure(a));

  @override F bind<A, B>(F fga, F f(_)) => _F.bind(fga, (G ga) => _F.map(_GT.traverse(_F, ga, f), _G.join));
}
*/
abstract class MonadOps<F, A> implements ApplicativeOps<F, A> {
  F bind<B>(covariant F f(A a));

  @override F map<B>(B f(A a));// => bind((a) => pure(f(a)));
  @override F ap<B>(F ff) => cast<MonadOps<F, Function1<A, B>>>(ff).bind((f) => map(f));
  F flatMap<B>(covariant F f(A a)) => bind(f);
  F andThen<B>(covariant F next) => bind((_) => next);
  F replace<B>(B replacement) => map((_) => replacement);
}

class MonadOpsMonad<F extends MonadOps> extends Functor<F> with Applicative<F>, Monad<F> {
  final Function1<dynamic, F> _pure;
  MonadOpsMonad(this._pure);
  @override F pure<A>(a) => _pure(a);
  @override F bind<A, B>(covariant F fa, covariant F f(_)) => cast(fa.bind(f));
  @override F ap<A, B>(F fa, F ff) => cast(fa.ap(ff));
  @override F map<A, B>(F fa, B f(A a)) => cast(fa.map(cast(f)));
}
