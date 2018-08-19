part of dartz;

typedef A Endo<A>(A a);

class EndoMonoid<A> extends Monoid<Endo<A>> {
  @override Endo<A> zero() => (A a) => a;

  @override Endo<A> append(Endo<A> e1, Endo<A> e2) => (A a) => e1(e2(a));
}

final Monoid<Endo> EndoMi = new EndoMonoid();
Monoid<Endo<A>> endoMi<A>() => new EndoMonoid();

final Monoid<Endo> DualEndoMi = dualMonoid(EndoMi);
Monoid<Endo<A>> dualEndoMi<A>() => dualMonoid(endoMi());
