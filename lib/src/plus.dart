// ignore_for_file: unnecessary_new

part of dartz;

// universally quantified semigroup
// might seem pointless to separate from semigroup in dart, but clarifies intent

abstract class Plus<F> {
  F plus<A>(F f1, F f2);
}

abstract class PlusOps<F, A> {
  F plus(covariant F fa2); // F[A] => F[A]
}