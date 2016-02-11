part of dartz;

abstract class Monad<F> extends Applicative<F> {
  F bind(F fa, F f(_));
  
  F join(F ffa) => bind(ffa, id);

  @override F map(F fa, f(_)) => bind(fa, (a) => pure(f(a)));
  @override F ap(F fa, F ff) => bind(ff, (f) => map(fa, f));
  
  Monad<F> /* Monad<F<G<_>>> */ composeM(Monad G, Traversable GT) => new ComposedMonad(this, G, GT);
}

// Compose Monad<F<_>> with Monad<G<_>> and Traversable<G<_>>, yielding Monad<F<G<_>>>
class ComposedMonad<F, G> extends Monad<F> {
  final Monad<F> _F;
  final Monad<G> _G;
  final Traversable<G> _GT;

  ComposedMonad(this._F, this._G, this._GT);

  @override F pure(a) => _F.pure(_G.pure(a));

  @override F bind(F fga, F f(_)) => _F.bind(fga, (ga) => _F.map(_GT.traverse(_F, ga, f), _G.join));
}

abstract class MonadOps<F, A> implements ApplicativeOps<F, A> {
  F pure(a);
  F bind(F f(A a));

  @override F map(f(A a)) => bind((a) => pure(f(a)));
  @override F ap(F ff) => (ff as MonadOps<F, dynamic>).bind((f) => map(f));
  F flatMap(F f(A a)) => bind(f);
  F andThen(F next) => bind((_) => next);
  F operator >>(F next) => andThen(next);
  F operator >=(F f(A a)) => bind(f);
  F operator <<(F next) => bind((a) => (next as MonadOps).map((_) => a));
  F replace(replacement) => map((_) => replacement);
  F join() => bind(id);
  F flatten() => join();
}

class MonadOpsMonad<F extends MonadOps> extends Monad<F> {
  final Function _pure;
  MonadOpsMonad(this._pure);
  @override F pure(a) => _pure(a);
  @override F bind(F fa, F f(_)) => fa.bind(f);
  @override F ap(F fa, F ff) => fa.ap(ff);
  @override F map(F fa, f(_)) => fa.map(f);
}