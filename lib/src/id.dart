part of dartz;

class IdMonad extends Monad {
  @override pure(a) => a;
  @override bind(fa, f(_)) => f(fa);

  IList/*<A>*/ replicate/*<A>*/(int n, /*=A*/ fa) => super.replicate(n, fa) as IList/*<A>*/;
}

final IdMonad IdM = new IdMonad();

class IdTraversable extends Traversable {
  @override /*=G*/ traverse/*<G>*/(Applicative/*<G>*/ gApplicative, fa, /*=G*/ f(a)) => f(fa);
}

final Traversable IdTr = new IdTraversable();

/*=A*/ id/*<A>*/(/*=A*/ a) => a;
/*=Endo<A>*/ idF/*<A>*/() => id;
