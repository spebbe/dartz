part of dartz;

// NOTE: First simplistic attempt at practical dart lenses. A bit wonky and different from STAB lenses/prisms. Will probably change in the future.

class Lens<AIn, AOut, BIn, BOut> {
  final Function1<AIn, BOut> _getter;
  final Function2<AIn, BIn, AOut> _setter;
  Lens(this._getter, this._setter);
  BOut get(AIn a) => _getter(a);
  AOut set(AIn a, BIn b) => _setter(a, b);
  AOut modify(AIn a, Function1<BOut, BIn> f) => set(a, f(get(a)));
  Lens<AIn, AOut, CIn, COut> andThen<CIn, COut>(Lens<BOut, BIn, CIn, COut> otherLens) => new Lens((a) => otherLens.get(get(a)), (a, c) => set(a, otherLens.set(get(a), c)));
}

Lens<AIn, AOut, BIn, BOut> lens<AIn, AOut, BIn, BOut>(Function1<AIn, BOut> getter, Function2<AIn, BIn, AOut> setter) => new Lens(getter, setter);

class SimpleLens<A, B> extends Lens<A, A, B, B> {
  SimpleLens(Function1<A, B> getter, Function2<A, B, A> setter): super(getter, setter);
  SimpleLens<A, C> andThenS<C>(Lens<B, B, C, C> otherLens) => new SimpleLens((a) => otherLens.get(get(a)), (a, c) => set(a, otherLens.set(get(a), c)));
  OptionLens<A, C> andThenO<C>(OptionLens<B, C> otherLens) => new OptionLens((a) => otherLens.get(get(a)), (a, c) => otherLens.set(get(a), c).map((b) => set(a, b)));
  EitherLens<A, C, E> andThenE<C, E>(EitherLens<B, C, E> otherLens) => new EitherLens((a) => otherLens.get(get(a)), (a, c) => otherLens.set(get(a), c).map((b) => set(a, b)));
}

SimpleLens<A, B> lensS<A, B>(Function1<A, B> getter, Function2<A, B, A> setter) => new SimpleLens(getter, setter);

class OptionLens<A, B> extends Lens<A, Option<A>, B, Option<B>> {
  OptionLens(Function1<A, Option<B>> getter, Function2<A, B, Option<A>> setter): super(getter, setter);
  OptionLens<A, C> oAndThen<C>(Lens<B, B, C, C> otherLens) => new OptionLens((a) => get(a).map(otherLens.get), (a, c) => get(a).bind((b) => set(a, otherLens.set(b, c))));
  OptionLens<A, C> oAndThenO<C>(OptionLens<B, C> otherLens) => new OptionLens((a) => get(a).bind(otherLens.get), (a, c) => get(a).bind((b1) => otherLens.set(b1, c)).bind((b) => set(a, b)));
  Option<A> modifyO(A a, Function1<B, B> f) => get(a).bind((b) => set(a, f(b)));
}

OptionLens<A, B> lensO<A, B>(Function1<A, Option<B>> getter, Function2<A, B, Option<A>> setter) => new OptionLens(getter, setter);

OptionLens<IVector<A>, A> ivectorLensO<A>(int i) => lensO((v) => v[i], (v, a) => v.set(i, a));
OptionLens<IMap<K, V>, V> imapLensO<K, V>(K k) => lensO((m) => m[k], (m, v) => m.set(k, v));

class EitherLens<A, B, E> extends Lens<A, Either<E, A>, B, Either<E, B>> {
  EitherLens(Function1<A, Either<E, B>> getter, Function2<A, B,  Either<E, A>> setter): super(getter, setter);
  EitherLens<A, C, E> eAndThen<C>(Lens<B, B, C, C> otherLens) => new EitherLens((a) => get(a).map(otherLens.get), (a, c) => get(a).bind((b) => set(a, otherLens.set(b, c))));
  EitherLens<A, C, E> eAndThenE<C>(EitherLens<B, C, E> otherLens) => new EitherLens((a) => get(a).bind(otherLens.get), (a, c) => get(a).bind((b1) => otherLens.set(b1, c)).bind((b) => set(a, b)));
  Either<E, A> modifyE(A a, Function1<B, B> f) => get(a).bind((b) => set(a, f(b)));
}

EitherLens<A, B, E> lensE<A, B, E>(Function1<A, Either<E, B>> getter, Function2<A, B, Either<E, A>> setter) => new EitherLens(getter, setter);
EitherLens<A, B, E> lensOToE<A, B, E>(OptionLens<A, B> aLens, E eF()) => lensE((a) => aLens.get(a).toEither(eF), (a, b) => aLens.set(a, b).toEither(eF));
OptionLens<A, B> lensEtoO<A, B>(EitherLens<A, B, dynamic> aLens) => lensO((a) => aLens.get(a).toOption(), (a, b) => aLens.set(a, b).toOption());

EitherLens<IVector<A>, A, E> ivectorLensE<A, E>(int i, E eF()) => lensE((v) => v[i].toEither(eF), (v, a) => v.set(i, a).toEither(eF));
EitherLens<IMap<K, V>, V, E> imapLensE<K, V, E>(K k, E eF()) => lensE((m) => m[k].toEither(eF), (m, v) => m.set(k, v).toEither(eF));
