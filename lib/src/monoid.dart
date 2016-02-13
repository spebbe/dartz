part of dartz;

abstract class Monoid<A> extends Semigroup<A> {
  A zero();
}

class _AnonymousMonoid extends Monoid {
  final _zero;
  final _append;

  _AnonymousMonoid(this._zero, this._append);

  @override zero() => _zero();

  @override append(a1, a2) => _append(a1, a2);
}

Monoid monoid(zero(), append(t1, t2)) => new _AnonymousMonoid(zero, append);
