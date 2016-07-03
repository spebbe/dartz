part of dartz;

abstract class ApplicativePlus<F> extends Applicative<F> implements PlusEmpty<F> {
  F prependElement/*<A>*/(F fa, /*=A*/ a) => plus(pure(a), fa);
  F appendElement/*<A>*/(F fa, /*=A*/ a) => plus(fa, pure(a));
}

abstract class ApplicativePlusOps<F, A> extends ApplicativeOps<F, A> with PlusEmptyOps<F, A> {
  F prependElement(A a) => (pure(a) as dynamic/*=ApplicativePlusOps<F, A>*/).plus(this as dynamic/*=F*/);
  F appendElement(A a) => plus(pure(a));
}