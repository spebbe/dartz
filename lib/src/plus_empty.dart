part of dartz;

// universally quantified monoid
// might seem pointless to separate from monoid in dart, but clarifies intent

abstract class PlusEmpty<F> extends Plus<F> {
  F empty();
}

abstract class PlusEmptyOps<F, A> extends PlusOps<F, A> {
  F empty(); // () => F[A]
}