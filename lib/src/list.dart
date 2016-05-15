part of dartz;

// List is mutable, so use with care.
// If possible, use IList and its associated instances instead.

class ListMonad extends MonadPlus<List> {
  @override List/*<A>*/ pure/*<A>*/(/*=A*/ a) => [a];
  @override List/*<B>*/ bind/*<A, B>*/(List/*<A>*/ fa, List/*<B>*/ f(/*=A*/ a)) => fa.expand(f).toList();
  @override List/*<A>*/ empty/*<A>*/() => [];

  @override List/*<A>*/ plus/*<A>*/(List/*<A>*/ f1, List/*<A>*/ f2) => new List.from(f1)..addAll(f2);
}

class ListMonoid<A> extends Monoid<List<A>> {
  @override List<A> zero() => new List();
  @override List<A> append(List<A> l1, List<A> l2) => l1.isEmpty ? l2 : (l2.isEmpty ? l1 : new List.from(l1)..addAll(l2));
}

final MonadPlus<List> ListMP = new ListMonad();
final Monad<List> ListM = ListMP;
final ApplicativePlus<List> ListAP = ListMP;
final Applicative<List> ListA = ListMP;
final Functor<List> ListF = ListMP;
final Monoid<List> ListMi = new ListMonoid();
Monoid<List/*<A>*/> listMi/*<A>*/() => ListMi;

class ListTMonad<M> extends Monad<M> {
  Monad<M> _stackedM;
  ListTMonad(this._stackedM);
  Monad underlying() => ListM;

  @override M pure(a) => _stackedM.pure([a]);
  M _concat(M a, M b) => _stackedM.bind(a, (l1) => _stackedM.map(b, (l2) => new List.from(l1)..addAll(l2)));
  @override M bind(M mla, M f(_)) => _stackedM.bind(mla, (List l) => ((l.length == 0) ? pure([]) : l.map(f).reduce(_concat)));
}

Monad/*<M>*/ listTMonad/*<M>*/(Monad/*<M>*/ mmonad) => new ListTMonad/*<M>*/(mmonad);

class ListTraversable extends Traversable<List> {
  @override /*=G*/ traverse/*<G>*/(Applicative/*<G>*/ gApplicative, List fas, /*=G*/ f(_)) => fas.fold(gApplicative.pure([]), (previous, e) {
    return gApplicative.lift2((List a, b) {
      final r = new List.from(a);
      r.add(b);
      return r;
    })(previous, f(e));
  });
}

final Traversable<List> ListTr = new ListTraversable();
final Foldable<List> ListFo = ListTr;
