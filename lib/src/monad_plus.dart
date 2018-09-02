part of dartz;

abstract class MonadPlus<F> implements Functor<F>, Applicative<F>, Monad<F>, ApplicativePlus<F> {
  F filter(F fa, bool predicate(a)) => bind(fa, (t) => predicate(t) ? pure(t) : empty());
  F where(F fa, bool predicate(a)) => filter(fa, predicate);

  F unite(F fa, Foldable gFoldable) => bind(fa, (ga) => gFoldable.foldLeft(ga, empty(), (F p, a) => plus(p, pure(a))));
}

abstract class MonadPlusOps<F, A> implements MonadOps<F, A>, ApplicativePlusOps<F, A>  {
  F filter(bool predicate(A a));// => bind((t) => predicate(t) ? pure(t) : empty());
  F where(bool predicate(A a));// => filter(predicate);
}

class MonadPlusOpsMonadPlus<F extends MonadPlusOps> extends Functor<F> with Applicative<F>, ApplicativePlus<F>, Monad<F>, MonadPlus<F> {
  final Function1<dynamic, F> _pure;
  final Function0<F> _empty;

  MonadPlusOpsMonadPlus(this._pure, this._empty);
  @override F pure<A>(A a) => _pure(a);
  @override F bind<A, B>(F fa, F f(A a)) => cast<MonadPlusOps<F, dynamic>>(fa).bind(cast(f));
  @override F ap<A, B>(F fa, F ff) => cast<MonadPlusOps<F, dynamic>>(fa).ap(ff);
  @override F map<A, B>(F fa, B f(A a)) => cast<MonadPlusOps<F, dynamic>>(fa).map(cast(f));
  @override F empty<A>() => _empty();
  @override F plus<A>(F f1, F f2) => cast<MonadPlusOps<F, dynamic>>(f1).plus(f2);
}
