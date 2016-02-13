part of dartz;

abstract class ApplicativePlus<F> extends Applicative<F> with PlusEmpty<F> {
}

abstract class ApplicativePlusOps<F, A> extends ApplicativeOps<F, A> with PlusEmptyOps<F, A> {
}