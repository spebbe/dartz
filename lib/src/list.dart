// ignore_for_file: unnecessary_new

part of dartz;

// List is mutable, so use with care.
// If possible, use IList and its associated instances instead.

class ListTraversableMonadPlus extends Traversable<List> with Applicative<List>, ApplicativePlus<List>, Monad<List>, MonadPlus<List>, TraversableMonad<List>, TraversableMonadPlus<List>, Plus<List> {
  @override List<A> pure<A>(A a) => [a];
  @override List<B> bind<A, B>(covariant List<A> fa, covariant Function1<A, List<B>> f) => fa.expand(f).toList();

  @override List<A> empty<A>() => [];
  @override List<A> plus<A>(covariant List<A> f1, covariant List<A> f2) => new List.from(f1)..addAll(f2);

  /*
  @override G traverse<G>(Applicative<G> gApplicative, List fas, G f(_)) => fas.fold(gApplicative.pure([]), (previous, e) {
    return gApplicative.map2(previous, f(e), (a, b) {
      final r = new List.from(cast(a));
      r.add(b);
      return r;
    });
  });
  */

  @override B foldMap<A, B>(Monoid<B> bMonoid, covariant List<A> fa, B f(A a)) => fa.fold(bMonoid.zero(), (z, a) => bMonoid.append(z, f(a)));
}

class ListMonoid<A> extends Monoid<List<A>> {
  @override List<A> zero() => const [];
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
  @override M bind<A, B>(M mla, M f(A a)) => _stackedM.bind(mla, (List l) => ((l.isEmpty) ? pure([]) : l.map<M>(cast(f)).reduce(_concat)));
}

Monad<M> listTMonad<M>(Monad<M> mmonad) => new ListTMonad(mmonad);

