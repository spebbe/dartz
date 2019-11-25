// ignore_for_file: unnecessary_new

part of dartz;

class DualSemigroup<A> extends Semigroup<A> {
  final Semigroup<A> _aSemigroup;

  DualSemigroup(this._aSemigroup);

  @override A append(A a1, A a2) => _aSemigroup.append(a2, a1);
}

Semigroup<A> dualSemigroup<A>(Semigroup<A> si) => new DualSemigroup(si);

class DualMonoid<A> extends Monoid<A> {
  final Monoid<A> _aMonoid;

  DualMonoid(this._aMonoid);

  @override A zero() => _aMonoid.zero();

  @override A append(A a1, A a2) => _aMonoid.append(a2, a1);
}

Monoid<A> dualMonoid<A>(Monoid<A> mi) => new DualMonoid(mi);
