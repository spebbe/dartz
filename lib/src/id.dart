part of dartz;

class IdMonad extends Functor with Applicative, Monad {
  @override A pure<A>(A a) => a;
  @override B bind<A, B>(A fa, Function1<A, B> f) => f(fa);

  IList<A> replicate<A>(int n, A fa) => new IList.from(new List.filled(n, fa));
}

final IdMonad IdM = new IdMonad();

class IdTraversable extends Traversable {
  @override B foldMap<A, B>(Monoid<B> bMonoid, A fa, B f(A a)) => f(fa);

  @override B map<A, B>(A fa, B f(A a)) => f(fa);
}

final IdTraversable IdTr = new IdTraversable();

A id<A>(A a) => a;
Endo<A> idF<A>() => id;
