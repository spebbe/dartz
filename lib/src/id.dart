// ignore_for_file: unnecessary_new

part of dartz;

class IdMonad extends Functor with Applicative, Monad {
  const IdMonad() : super._();

  @override
  A pure<A>(A a) => a;

  @override
  B bind<A, B>(covariant A fa, covariant Function1<A, B> f) => f(fa);

  IList<A> replicate<A>(int n, A fa) => IList.from(List.filled(n, fa));
}

const IdMonad IdM = IdMonad();

class IdTraversable extends Traversable {
  const IdTraversable() : super._();

  @override
  B foldMap<A, B>(Monoid<B> bMonoid, covariant A fa, B f(A a)) => f(fa);

  @override
  B map<A, B>(covariant A fa, B f(A a)) => f(fa);
}

const IdTraversable IdTr = IdTraversable();

A id<A>(A a) => a;
Endo<A> idF<A>() => id;
