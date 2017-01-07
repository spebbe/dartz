part of dartz;

// Internally implemented using imperative loops and mutations, for stack safety and performance.
// The external API should be safe and referentially transparent, though.

abstract class IList<A> extends TraversableOps<IList, A> with FunctorOps<IList, A>, ApplicativeOps<IList, A>, ApplicativePlusOps<IList, A>, MonadOps<IList, A>, MonadPlusOps<IList, A>, TraversableMonadOps<IList, A>, TraversableMonadPlusOps<IList, A> {
  Option<A> get headOption;

  Option<IList<A>> get tailOption;

  bool _isCons();

  A _unsafeHead();

  IList<A> _unsafeTail();

  void _unsafeSetTail(IList<A> newTail);

  IList();

  factory IList.from(Iterable<A> iterable) {
    final IList<A> aNil = Nil as dynamic/*=IList<A>*/;
    final Iterator<A> it = iterable.iterator;
    if (!it.moveNext()) {
      return aNil;
    }
    Cons<A> result = new Cons(it.current, aNil);
    final IList<A> resultHead = result;
    while(it.moveNext()) {
      final next = new Cons(it.current, aNil);
      result._unsafeSetTail(next);
      result = next;
    }
    return resultHead;
  }

  @override IList/*<B>*/ pure/*<B>*/(/*=B*/ b) => new Cons(b, nil());

  @override /*=G*/ traverse/*<G>*/(Applicative/*<G>*/ gApplicative, /*=G*/ f(A a)) {
    IList resultHead = Nil;
    dynamic/*=G*/ result = gApplicative.pure(resultHead);
    IList<A> current = this;
    while (current._isCons()) {
      final gb = f(current._unsafeHead());
      result = gApplicative.map2(result, gb, (/*=IList*/ a, h) {
        if (a._isCons()) {
          final next = new Cons(h, Nil);
          a._unsafeSetTail(next);
          return next;
        } else {
          resultHead = new Cons(h, Nil);
          return resultHead;
        }
      });
      current = current._unsafeTail();
    }
    return gApplicative.map(result, (_) => resultHead);
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
    final IList/*<B>*/ bNil = Nil as dynamic/*=IList<B>*/;
    if (!_isCons()) {
      return bNil;
    }
    Cons/*<B>*/ result = null;
    IList/*<B>*/ resultHead = null;
    var current = this;
    var sub = f(current._unsafeHead());
    while(current._isCons() && !sub._isCons()) {
      current = current._unsafeTail();
      if (current._isCons()) {
        sub = f(current._unsafeHead());
      }
    }
    if (sub._isCons()) {
      result = new Cons(sub._unsafeHead(), bNil);
      resultHead = result;
      sub = sub._unsafeTail();
      while(sub._isCons()) {
        final next = new Cons(sub._unsafeHead(), bNil);
        result._unsafeSetTail(next);
        result = next;
        sub = sub._unsafeTail();
      }
      current = current._unsafeTail();
    }
    while (current._isCons()) {
      sub = f(current._unsafeHead());
      while(sub._isCons()) {
        final next = new Cons(sub._unsafeHead(), bNil);
        result._unsafeSetTail(next);
        result = next;
        sub = sub._unsafeTail();
      }
      current = current._unsafeTail();
    }
    return resultHead ?? bNil;
  }

  @override IList/*<B>*/ flatMap/*<B>*/(IList/*<B>*/ f(A a)) => bind(f);

  @override IList/*<B>*/ map/*<B>*/(/*=B*/ f(A a)) {
    final IList/*<B>*/ bNil = Nil as dynamic/*=IList<B>*/;
    if (!_isCons()) {
      return bNil;
    }
    Cons/*<B>*/ last = new Cons(f(_unsafeHead()), bNil);
    if (!_unsafeTail()._isCons()) {
      return last;
    }
    final result = last;
    var current = _unsafeTail();
    while (current._isCons()) {
      final next = new Cons(f(current._unsafeHead()), bNil);
      last._unsafeSetTail(next);
      last = next;
      current = current._unsafeTail();
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

  Tuple2<IList<A>, IList<A>> partition(bool f(A a)) => super.partition(f) as dynamic/*=Tuple2<IList<A>, IList<A>>*/;

  @override IList<A> prependElement(A a) => new Cons(a, this);

  @override IList<A> appendElement(A a) => this.plus(new Cons(a, nil()));

  Option/*<B>*/ unconsO/*<B>*/(/*=B*/ f(A head, IList<A> tail)) => _isCons() ? some(f(_unsafeHead(), _unsafeTail())) : none();

  /*=B*/ uncons/*<B>*/(/*=B*/ z(), /*=B*/ f(A head, IList<A> tail)) => _isCons() ? f(_unsafeHead(), _unsafeTail()) : z();

  IList<A> sort(Order<A> oa) => uncons(nil, (pivot, rest) => rest
      .partition((e) => oa.lt(e, pivot))
      .apply((smaller, larger) => smaller.sort(oa).plus(larger.sort(oa).prependElement(pivot))));

  IList<Tuple2<A, dynamic/*=B*/>> zip/*<B>*/(IList/*<B>*/ bs) {
    final IList/*<Tuple2<A, B>>*/ abNil = Nil as dynamic/*=IList<Tuple2<A, B>>*/;
    if (!(_isCons() && bs._isCons())) {
      return abNil;
    } else {
      final IList/*<Tuple2<A, B>>*/ result = new Cons(tuple2(this._unsafeHead(), bs._unsafeHead()), abNil);
      var thisCurrent = this._unsafeTail();
      var bsCurrent = bs._unsafeTail();
      var resultCurrent = result;
      while(thisCurrent._isCons() && bsCurrent._isCons()) {
        final next = new Cons(tuple2(thisCurrent._unsafeHead(), bsCurrent._unsafeHead()), abNil);
        resultCurrent._unsafeSetTail(next);
        resultCurrent = next;
        thisCurrent = thisCurrent._unsafeTail();
        bsCurrent = bsCurrent._unsafeTail();
      }
      return result;
    }
  }

  // PURISTS BEWARE: mutable List/Iterable/Iterator integrations below -- proceed with caution!

  List<A> toList() => foldLeft([], (List<A> p, a) => p..add(a));

  Iterable<A> toIterable() => new _IListIterable<A>(this);

  Iterator<A> iterator() => new _IListIterator<A>(this);
}

class Cons<A> extends IList<A> {
  final A _head;
  IList<A> _tail; // ...it's a secret...
  bool _isCons() => true;
  A _unsafeHead() => _head;
  IList<A> _unsafeTail() => _tail;
  void _unsafeSetTail(IList<A> newTail) { _tail = newTail; } // move along, people -- nothing to see here! certainly no secretly mutable state...

  Cons(this._head, this._tail);

  @override Option<A> get headOption => some(_head);

  @override Option<IList<A>> get tailOption => some(_tail);
}

class _Nil<A> extends IList<A> {
  bool _isCons() => false;
  A _unsafeHead() => throw new UnsupportedError("_unsafeHead called on _Nil");
  IList<A> _unsafeTail() => throw new UnsupportedError("_unsafeTail called on _Nil");
  void _unsafeSetTail(IList<A> newTail) => throw new UnsupportedError("_unsafeSetTail called on _Nil");

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
Monoid<IList/*<A>*/> ilistMi/*<A>*/() => IListMi as dynamic/*=Monoid<IList<A>>*/;

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
  bool _started = false;
  IList<A> _l;
  A _current = null;

  _IListIterator(this._l);

  @override A get current => _current;

  bool moveNext() {
    final IList/*<A>*/ curr = _l;
    if (curr._isCons()) {
      if (_started) {
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
        _started = true;
        return true;
      }
    } else {
      _current = null;
      return false;
    }
  }
}