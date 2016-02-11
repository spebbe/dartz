part of dartz;

abstract class Semigroup<A> {
  A append(A a1, A a2);
}

class _AnonymousSemigroup extends Semigroup {
  final _append;

  _AnonymousSemigroup(this._append);

  @override append(a1, a2) => _append(a1, a2);
}

Semigroup semigroup(append(a1, a2)) => new _AnonymousSemigroup(append);

final Semigroup firstSemigroup = semigroup((a1, a2) => a1);

final Semigroup secondSemigroup = semigroup((a1, a2) => a2);

