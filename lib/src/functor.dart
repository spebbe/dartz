part of dartz;

abstract class Functor<F> {
  F map(F fa, f(_));

  F strengthL(F fa, b) => map(fa, (a) => tuple2(b, a));

  F strengthR(F fa, b) => map(fa, (a) => tuple2(a, b));

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
  F map/*<B>*/(/*=B*/ f(A a));

  F strengthL/*<B>*/(/*=B*/ b) => map((a) => tuple2(b, a));

  F strengthR/*<B>*/(/*=B*/ b) => map((a) => tuple2(a, b));
}