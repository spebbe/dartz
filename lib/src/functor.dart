part of dartz;

abstract class Functor<F> {
  F map(F fa, f(_));

  Functor<F> /*Functor<F<G<_>>> */ composeF(Functor G) => new ComposedFunctor(this, G);
}

// Compose Functor<F<_>> with Functor<G<_>>, yielding Functor<F<G<_>>>
class ComposedFunctor<F, G> extends Functor<F> {
  final Functor<F> _F;
  final Functor<G> _G;

  ComposedFunctor(this._F, this._G);

  @override F map(F fga, f(_)) => _F.map(fga, (G ga) => _G.map(ga, f));
}

abstract class FunctorOps<F, A> {
  F map(f(A a));
}