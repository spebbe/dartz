part of dartz;

// List is mutable, so use with care.
// If possible, use IList and its associated instances instead.

class ListMonad extends MonadPlus<List> {
  @override List pure(a) => [a];
  @override List bind(List fa, List f(_)) => fa.expand(f).toList();
  @override List empty() => [];

  @override List plus(List f1, List f2) => new List.from(f1)..addAll(f2);
}

class ListMonoid extends Monoid<List> {
  @override List zero() => new List();
  @override List append(List l1, List l2) => l1.isEmpty ? l2 : (l2.isEmpty ? l1 : new List.from(l1)..addAll(l2));
}

final MonadPlus<List> ListMP = new ListMonad();
final Monad<List> ListM = ListMP;
final ApplicativePlus<List> ListAP = ListMP;
final Applicative<List> ListA = ListMP;
final Functor<List> ListF = ListMP;
final Monoid<List> ListMi = new ListMonoid();

class ListTMonad<M> extends Monad<M> {
  Monad _stackedM;
  ListTMonad(this._stackedM);
  Monad underlying() => ListM;

  @override M pure(a) => _stackedM.pure([a]);
  concat(M a, M b) => _stackedM.bind(a, (l1) => _stackedM.map(b, (l2) => new List.from(l1)..addAll(l2)));
  @override M bind(M mla, M f(_)) => _stackedM.bind(mla, (List l) => (l.length == 0) ? [] : l.map(f).reduce(concat));
}

Monad listTMonad(Monad mmonad) => new ListTMonad(mmonad);

class ListTraversable extends Traversable<List> {
  @override traverse(Applicative gApplicative, List fas, f(_)) => fas.fold(gApplicative.pure([]), (previous, e) {
    return gApplicative.lift2((List a, b) {
      final r = new List.from(a);
      r.add(b);
      return r;
    })(previous, f(e));
  });
}

final Traversable<List> ListTr = new ListTraversable();
final Foldable<List> ListFo = ListTr;
