part of dartz;

class IdMonad extends Monad {
  @override pure(a) => a;
  @override bind(fa, f(_)) => f(fa);
}

final Monad IdM = new IdMonad();

class IdTraversable extends Traversable {
  @override traverse(Applicative gApplicative, fa, f(a)) => f(fa);
}

final Traversable IdTr = new IdTraversable();

id(t) => t;
