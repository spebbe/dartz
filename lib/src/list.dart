part of dartz;

// List is mutable, so use with care.
// If possible, use IList and its associated instances instead.

class ListTraversableMonadPlus extends Traversable<List> with Applicative<List>, ApplicativePlus<List>, Monad<List>, MonadPlus<List>, TraversableMonad<List>, TraversableMonadPlus<List>, Plus<List> {
  @override List<A> pure<A>(A a) => [a];
  @override List<B> bind<A, B>(List<A> fa, List<B> f(A a)) => fa.expand(f).toList();

  @override List<A> empty<A>() => [];
  @override List<A> plus<A>(List<A> f1, List<A> f2) => new List.from(f1)..addAll(f2);

  @override G traverse<G>(Applicative<G> gApplicative, List fas, G f(_)) => fas.fold(gApplicative.pure([]), (previous, e) {
    return gApplicative.map2(previous, f(e), (a, b) {
      final r = new List.from(cast(a));
      r.add(b);
      return r;
    });
  });
}

class ListMonoid<A> extends Monoid<List<A>> {
  @override List<A> zero() => new List();
  @override List<A> append(List<A> l1, List<A> l2) => l1.isEmpty ? l2 : (l2.isEmpty ? l1 : new List.from(l1)..addAll(l2));
}

final ListTraversableMonadPlus ListMP = new ListTraversableMonadPlus();
MonadPlus<List<A>> listMP<A>() => cast(ListMP);
final Traversable<List> ListTr = ListMP;

final Monoid<List> ListMi = new ListMonoid();
Monoid<List<A>> listMi<A>() => new ListMonoid();

class ListTMonad<M> extends Functor<M> with  Applicative<M>, Monad<M> {
  Monad<M> _stackedM;
  ListTMonad(this._stackedM);
  Monad underlying() => ListMP;

  @override M pure<A>(A a) => _stackedM.pure([a]);
  M _concat(M a, M b) => _stackedM.bind(a, (Iterable l1) => _stackedM.map(b, (Iterable l2) => new List.from(l1)..addAll(l2)));
  @override M bind<A, B>(M mla, M f(A a)) => _stackedM.bind(mla, (List l) => ((l.length == 0) ? pure([]) : l.map<M>(cast(f)).reduce(_concat)));
}

Monad<M> listTMonad<M>(Monad<M> mmonad) => new ListTMonad(mmonad);

