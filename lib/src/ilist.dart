part of dartz;

// (stack safety - tail call elimination) => icky mutating loops
// everything should be externally RT though and mostly stack safe.

abstract class IList<A> extends TraversableOps<IList, A> with MonadOps<IList, A>, MonadPlusOps<IList, A>, TraversableMonadOps<IList, A> {
  Option<A> get headOption;

  Option<IList<A>> get tailOption;

  bool _isCons();

  A _unsafeHead();

  IList<A> _unsafeTail();

  IList();

  factory IList.from(Iterable<A> iterable) => iterable.fold/*<IList<A>>*/(nil(), (a, h) => new Cons(h, a)).reverse();

  @override IList/*<B>*/ pure/*<B>*/(/*=B*/ b) => new Cons(b, nil());

  @override /*=G*/ traverse/*<G>*/(Applicative/*<G>*/ gApplicative, /*=G*/ f(A a)) {
    var result = gApplicative.pure(Nil);
    var current = this;
    while (current._isCons()) {
      final gb = f(current._unsafeHead());
      result = gApplicative.map2(result, gb, (a, h) => new Cons(h, a));
      current = current._unsafeTail();
    }
    return gApplicative.map(result, (l) => l.reverse());
  }

  @override /*=G*/ traverse_/*<G>*/(Applicative/*<G>*/ gApplicative, /*=G*/ f(A a)) {
    var result = gApplicative.pure(unit);
    var current = this;
    while (current._isCons()) {
      final gb = f(current._unsafeHead());
      result = gApplicative.map2(result, gb, (a, h) => unit);
      current = current._unsafeTail();
    }
    return result;
  }

  @override IList/*<B>*/ bind/*<B>*/(IList/*<B>*/ f(A a)) {
    List/*<B>*/ mresult = [];
    var current = this;
    while (current._isCons()) {
      final IList/*<B>*/ sublist = f(current._unsafeHead());
      var subcurrent = sublist;
      while (subcurrent._isCons()) {
        mresult.add(subcurrent._unsafeHead());
        subcurrent = subcurrent._unsafeTail();
      }
      current = current._unsafeTail();
    }

    IList/*<B>*/ result = nil();
    for (int i = mresult.length - 1; i >= 0; i--) {
      result = new Cons(mresult[i], result);
    }
    return result;
  }

  @override IList/*<B>*/ flatMap/*<B>*/(IList/*<B>*/ f(A a)) => bind(f);

  @override IList /*<B>*/ map/*<B>*/(/*=B*/ f(A a)) {
    List /*<B>*/ mresult = [];
    var current = this;
    while (current._isCons()) {
      mresult.add(f(current._unsafeHead()));
      current = current._unsafeTail();
    }

    IList /*<B>*/ result = nil();
    for (int i = mresult.length - 1; i >= 0; i--) {
      result = new Cons(mresult[i], result);
    }
    return result;
  }

  @override /*=B*/ foldLeft/*<B>*/(/*=B*/ z, /*=B*/ f(/*=B*/ previous, A a)) {
    var result = z;
    var current = this;
    while (current._isCons()) {
      result = f(result, current._unsafeHead());
      current = current._unsafeTail();
    }
    return result;
  }

  List<A> toList() => foldLeft([], (List<A> p, a) => p..add(a));

  Iterable<A> toIterable() => new _IListIterable<A>(this);

  Iterator<A> iterator() => new _IListIterator<A>(this);

  @override /*=B*/ foldRight/*<B>*/(/*=B*/ z, /*=B*/ f(A a, /*=B*/ previous)) => reverse().foldLeft(z, (a, b) => f(b, a));

  @override /*=B*/ foldMap/*<B>*/(Monoid/*<B>*/ bMonoid, /*=B*/ f(A a)) => foldLeft(bMonoid.zero(), (a, b) => bMonoid.append(a, f(b)));

  IList<A> reverse() => foldLeft(nil(), (a, h) => new Cons(h, a));

  @override IList<A> empty() => nil();

  @override IList<A> plus(IList<A> l2) => foldRight(l2, (e, p) => new Cons(e, p));


  @override IList<A> filter(bool predicate(A a)) {
    var rresult = nil/*<A>*/();
    var current = this;
    while(current._isCons()) {
      final currentHead = current._unsafeHead();
      if (predicate(currentHead)) {
        rresult = new Cons(currentHead, rresult);
      }
      current = current._unsafeTail();
    }
    return rresult.reverse();
  }

  Option<A> find(bool predicate(A a)) {
    var current = this;
    while(current._isCons()) {
      final currentHead = current._unsafeHead();
      if (predicate(currentHead)) {
        return some(currentHead);
      }
      current = current._unsafeTail();
    }
    return none();
  }

  @override String toString() => 'ilist[' + map((A a) => a.toString()).intercalate(StringMi, ', ') + ']';

  @override bool operator ==(other) {
    if (other is IList) {
      var thisCurrent = this;
      var otherCurrent = other;
      while (thisCurrent._isCons()) {
        if (otherCurrent._isCons()) {
          if (identical(thisCurrent, otherCurrent)) {
            return true;
          } else if (thisCurrent._unsafeHead() == otherCurrent._unsafeHead()) {
            thisCurrent = thisCurrent._unsafeTail();
            otherCurrent = otherCurrent._unsafeTail();
          } else {
            return false;
          }
        } else {
          return false;
        }
      }
      return otherCurrent is _Nil;
    } else {
      return false;
    }
  }
}

class Cons<A> extends IList<A> {
  final A _head;
  final IList<A> _tail;
  bool _isCons() => true;
  A _unsafeHead() => _head;
  IList<A> _unsafeTail() => _tail;

  Cons(this._head, this._tail);

  @override Option<A> get headOption => some(_head);

  @override Option<IList<A>> get tailOption => some(_tail);
}

class _Nil<A> extends IList<A> {
  bool _isCons() => false;
  A _unsafeHead() => throw new UnsupportedError("_unsafeHead called on _Nil");
  IList<A> _unsafeTail() => throw new UnsupportedError("_unsafeTail called on _Nil");

  @override Option<A> get headOption => none();

  @override Option<IList<A>> get tailOption => none();
}

final IList Nil = new _Nil();
IList/*<A>*/ nil/*<A>*/() => Nil as dynamic/*=IList<A>*/;
IList/*<A>*/ cons/*<A>*/(/*=A*/ head, IList/*<A>*/ tail) => new Cons(head, tail);

final MonadPlus<IList> IListMP = new MonadPlusOpsMonadPlus<IList>((a) => new Cons(a, Nil), () => Nil);
MonadPlus<IList/*<A>*/> ilistMP/*<A>*/() => IListMP as dynamic/*=MonadPlus<IList<A>>*/;
final Traversable<IList> IListTr = new TraversableOpsTraversable<IList>();

class IListMonoid extends Monoid<IList> {
  @override IList zero() => Nil;
  @override IList append(IList l1, IList l2) => l1.plus(l2);
}

final Monoid<IList> IListMi = new IListMonoid();

class IListTMonad<M> extends Functor<M> with Applicative<M>, Monad<M> {
  Monad<M> _stackedM;
  IListTMonad(this._stackedM);
  Monad underlying() => IListMP;

  @override M pure(a) => _stackedM.pure(new Cons(a, Nil));

  M _concat(M a, M b) => _stackedM.bind(a, (l1) => _stackedM.map(b, (l2) => l1.plus(l2)));

  @override M bind(M mla, M f(_)) => _stackedM.bind(mla, (IList l) => l.map(f).foldLeft(_stackedM.pure(Nil), _concat));
}

Monad ilistTMonad(Monad mmonad) => new IListTMonad(mmonad);

IList<int> iota(int n) {
  Trampoline<IList<int>> go(int i, IList<int> result) => i > 0 ? tcall/*<IList<int>>*/(() => go(i-1, new Cons(i-1, result))) : treturn(result);
  return go(n, nil()).run();
}

IList/*<A>*/ ilist/*<A>*/(Iterable/*<A>*/ iterable) => new IList.from(iterable);

class _IListIterable<A> extends Iterable<A> {
  final IList<A> _l;

  _IListIterable(this._l);

  @override Iterator<A> get iterator => new _IListIterator<A>(_l);
}

class _IListIterator<A> extends Iterator<A> {
  bool started = false;
  IList<A> _l;
  A _current = null;

  _IListIterator(this._l);

  @override A get current => _current;

  bool moveNext() {
    final IList/*<A>*/ curr = _l;
    if (curr._isCons()) {
      if (started) {
        final IList/*<A>*/ next = curr._unsafeTail();
        _l = next;
        if (next._isCons()) {
          _current = next._unsafeHead();
          return true;
        } else {
          _current = null;
          return false;
        }
      } else {
        _current = curr._unsafeHead();
        started = true;
        return true;
      }
    } else {
      _current = null;
      return false;
    }
  }
}