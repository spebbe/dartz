part of dartz;

abstract class MonadPlus<F> extends Monad<F> with ApplicativePlus<F> {
  F filter(F fa, bool predicate(a)) => bind(fa, (t) => predicate(t) ? pure(t) : empty());

  F unite(F fa, Foldable gFoldable) => bind(fa, (ga) => gFoldable.foldLeft(ga, empty(), (F p, a) => plus(p, pure(a))));
}

abstract class MonadPlusOps<F, A> implements MonadOps<F, A>, ApplicativePlusOps<F, A>  {
  F filter(bool predicate(A a)) => bind((t) => predicate(t) ? pure(t) : empty());

  F unite(Foldable gFoldable) => bind((ga) => gFoldable.foldLeft(ga, empty(), (p, a) => p.plus(pure(a))));
}

class MonadPlusOpsMonad<F extends MonadPlusOps> extends MonadOpsMonad<F> with MonadPlus<F> {
  final Thunk _empty;
  MonadPlusOpsMonad(Function pure, this._empty) : super(pure);
  @override F empty() => _empty();
  @override F plus(F f1, F f2) => f1.plus(f2);
}
