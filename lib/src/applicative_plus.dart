part of dartz;

abstract class ApplicativePlus<F> extends Applicative<F> implements PlusEmpty<F> {
}

abstract class ApplicativePlusOps<F, A> extends ApplicativeOps<F, A> with PlusEmptyOps<F, A> {
}