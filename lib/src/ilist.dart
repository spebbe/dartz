part of dartz;

// stack safety - tail call elimination => icky mutating loops
// everything should be externally RT though and mostly stack safe.

abstract class IList<A> extends TraversableOps<IList, A> with MonadOps<IList, A> {
  Option<A> get headOption;
  Option<IList<A>> get tailOption;
  bool get empty;

  IList();

  factory IList.from(Iterable<A> iterable) => iterable.fold(Nil, (a, h) => new Cons(h, a)).reverse();

  @override IList pure(a) => new Cons(a, Nil);

  @override traverse(Applicative gApplicative, f(A a)) {
    var result = gApplicative.pure(Nil);
    var current = this;
    while(current is Cons) {
      final gb = f(current._head);
      result = gApplicative.map2(result, gb, (a, h) => new Cons(h, a));
      current = current._tail;
    }
    return gApplicative.map(result, (l) => l.reverse());
  }

  @override traverse_(Applicative gApplicative, f(A a)) {
    var result = gApplicative.pure(unit);
    var current = this;
    while(current is Cons) {
      final gb = f(current._head);
      result = gApplicative.map2(result, gb, (a, h) => unit);
      current = current._tail;
    }
    return result;
  }

  @override IList bind(IList f(A a)) {
    List mresult = [];
    var current = this;
    while(current is Cons) {
      final IList sublist = f(current._head);
      var subcurrent = sublist;
      while(subcurrent is Cons) {
        mresult.add(subcurrent._head);
        subcurrent = subcurrent._tail;
      }
      current = current._tail;
    }

    IList result = Nil;
    for(int i = mresult.length-1;i >= 0;i--) {
      result = new Cons(mresult[i], result);
    }
    return result;
  }

  @override IList map(f(A a)) {
    List mresult = [];
    var current = this;
    while(current is Cons) {
      mresult.add(f(current._head));
      current = current._tail;
    }

    IList result = Nil;
    for(int i = mresult.length-1;i >= 0;i--) {
      result = new Cons(mresult[i], result);
    }
    return result;
  }

  @override foldLeft(z, f(p, A a)) {
    var result = z;
    var current = this;
    while(current is Cons) {
      result = f(result, current._head);
      current = current._tail;
    }
    return result;
  }

  @override foldRight(z, f(A a, p)) => reverse().foldLeft(z, (a, b) => f(b, a));

  @override foldMap(Monoid bMonoid, f(A a)) => foldLeft(bMonoid.zero(), (a, b) => bMonoid.append(a, f(b)));

  IList<A> reverse() => foldLeft(Nil, (a, h) => new Cons(h, a));

  IList<A> append(IList<A> l2) => new Cons(this, new Cons(l2, Nil)).join();

  IList<A> filter(bool predicate(A a)) => flatMap((t) => predicate(t) ? pure(t) : Nil);

  int length() => foldLeft(0, (a, b) => a+1);
}

class Cons<A> extends IList<A> {
  final A _head;
  final IList<A> _tail;

  Cons(this._head, this._tail);

  @override Option<A> get headOption => some(_head);

  @override Option<IList<A>> get tailOption => some(_tail);

  @override bool get empty => false;

  @override String toString() => "${_head}::${_tail}";

  @override bool operator ==(other) => other is Cons && other._head == _head && other._tail == _tail;
}

class _Nil<A> extends IList<A> {
  @override Option<A> get headOption => none;

  @override Option<IList<A>> get tailOption => none;

  @override bool get empty => true;

  @override String toString() => "Nil";

  @override bool operator ==(other) => other is _Nil;
}

final IList Nil = new _Nil();

final Monad<IList> IListM = new MonadOpsMonad<IList>((a) => new Cons(a, Nil));
final Applicative<IList> IListA = IListM;
final Functor<IList> IListF = IListM;
final Traversable<IList> IListTr = new TraversableOpsTraversable<IList>();
final Foldable<IList> IListFo = IListTr;

class IListMonoid extends Monoid<IList> {
  @override IList zero() => Nil;
  @override IList append(IList l1, IList l2) => l1.append(l2);
}

final Monoid<IList> IListMi = new IListMonoid();

class IListTMonad<M> extends Monad<M> {
  Monad _stackedM;
  IListTMonad(this._stackedM);
  Monad underlying() => IListM;

  @override M pure(a) => _stackedM.pure(new Cons(a, Nil));

  _concat(M a, M b) => _stackedM.bind(a, (l1) => _stackedM.map(b, (l2) => l1.append(l2)));

  @override M bind(M mla, M f(_)) => _stackedM.bind(mla, (IList l) => l.map(f).foldLeft(_stackedM.pure(Nil), _concat));
}

Monad ilistTMonad(Monad mmonad) => new IListTMonad(mmonad);

IList<int> iota(int n) {
  IList<int> go(int i, IList<int> result) => i > 0 ? go(i-1, new Cons(i-1, result)) : result;
  return go(n, Nil);
}

IList ilist(Iterable iterable) => new IList.from(iterable);