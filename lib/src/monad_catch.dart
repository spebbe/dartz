part of dartz;

abstract class MonadCatch<F> implements Monad<F> {
  F attempt<A>(covariant F fa); // F<A> => F<Either<Object, A>>
  F fail<A>(Object err); // Object => F<A>
}

abstract class MonadCatchOps<F, A> implements MonadOps<F, A> {
  F attempt(); // () => F<Either<Object, A>>
  F fail(Object err); // Object => F<A>
}