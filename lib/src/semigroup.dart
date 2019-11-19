// ignore_for_file: unnecessary_new

part of dartz;

abstract class Semigroup<A> {
  A append(A a1, A a2);
  Endo<A> appendC(A a1) => (A a2) => append(a1, a2);
}

class _AnonymousSemigroup<A> extends Semigroup<A> {
  final Function2<A, A, A> _append;

  _AnonymousSemigroup(this._append);

  @override A append(A a1, A a2) => _append(a1, a2);
}

Semigroup<A> semigroup<A>(A append(A a1, A a2)) => new _AnonymousSemigroup(append);

final Semigroup FirstSemigroup = semigroup((a1, a2) => a1);
Semigroup<A> firstSemigroup<A>() => semigroup((a1, a2) => a1);

final Semigroup SecondSemigroup = semigroup((a1, a2) => a2);
Semigroup<A> secondSemigroup<A>() => semigroup((a1, a2) => a2);


