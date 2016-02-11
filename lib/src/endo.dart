part of dartz;

// type Endo[A] = A => A
typedef Endo(a);

class EndoMonoid extends Monoid<Endo> {
  @override Endo zero() => id;

  @override Endo append(Endo e1, Endo e2) => (a) => e1(e2(a));
}

final Monoid<Endo> EndoMi = new EndoMonoid();

final Monoid<Endo> DualEndoMi = dualMonoid(EndoMi);