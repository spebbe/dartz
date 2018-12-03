part of dartz;

// Internally implemented using imperative loops and mutations, for stack safety and performance.
// The external API should be safe and referentially transparent, though.

abstract class IList<A> implements TraversableMonadPlusOps<IList, A> {
  Option<A> get headOption;

  Option<IList<A>> get tailOption;

  bool _isCons();

  A _unsafeHead();

  IList<A> _unsafeTail();

  void _unsafeSetTail(IList<A> newTail);

  const IList();

  factory IList.from(Iterable<A> iterable) {
    final IList<A> aNil = nil();
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

  factory IList.generate(int n, A f(int i)) {
    final IList<A> aNil = nil();
    if (n <= 0) {
      return aNil;
    }
    Cons<A> result = new Cons(f(0), aNil);
    final IList<A> resultHead = result;
    for(int i = 1;i < n;i++) {
      final next = new Cons(f(i), aNil);
      result._unsafeSetTail(next);
      result = next;
    }
    return resultHead;
  }

  @override IList<B> bind<B>(IList<B> f(A a)) {
    final IList<B> bNil = nil();
    if (!_isCons()) {
      return bNil;
    }
    Cons<B> result = null;
    IList<B> resultHead = null;
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

  @override IList<B> flatMap<B>(IList<B> f(A a)) => bind(f);

  @override IList<B> map<B>(B f(A a)) {
    final IList<B> bNil = nil();
    if (!_isCons()) {
      return bNil;
    }
    Cons<B> last = new Cons(f(_unsafeHead()), bNil);
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

  @override B foldLeft<B>(B z, B f(B previous, A a)) {
    var result = z;
    var current = this;
    while (current._isCons()) {
      result = f(result, current._unsafeHead());
      current = current._unsafeTail();
    }
    return result;
  }

  @override B foldRight<B>(B z, B f(A a, B previous)) => reverse().foldLeft<B>(z, (a, b) => f(b, a));

  @override B foldMap<B>(Monoid<B> bMonoid, B f(A a)) => foldLeft(bMonoid.zero(), (a, b) => bMonoid.append(a, f(b)));

  IList<A> reverse() => foldLeft(nil(), (a, h) => new Cons(h, a));

  @override IList<A> plus(IList<A> l2) => foldRight(l2, (e, p) => new Cons(e, p));


  @override IList<A> filter(bool predicate(A a)) {
    var rresult = nil<A>();
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

  @override IList<A> where(bool predicate(A a)) => filter(predicate);

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
      return otherCurrent is Nil;
    } else {
      return false;
    }
  }

  @override int get hashCode => foldLeft(0, (hash, a) => hash ^ a.hashCode);

  Tuple2<IList<A>, IList<A>> partition(bool f(A a)) =>
    foldRight(tuple2(nil(), nil()), (A a, acc) => f(a)
      ? acc.map1((xs) => cons(a, xs))
      : acc.map2((xs) => cons(a, xs)));

  @override IList<A> prependElement(A a) => new Cons(a, this);

  @override IList<A> appendElement(A a) => this.plus(new Cons(a, nil()));

  Option<B> unconsO<B>(B f(A head, IList<A> tail)) => _isCons() ? some(f(_unsafeHead(), _unsafeTail())) : none();

  B uncons<B>(B z(), B f(A head, IList<A> tail)) => _isCons() ? f(_unsafeHead(), _unsafeTail()) : z();

  IList<A> sort(Order<A> oa) => uncons(nil, (pivot, rest) => rest
      .partition((e) => oa.lt(e, pivot))
      .apply((smaller, larger) => smaller.sort(oa).plus(larger.sort(oa).prependElement(pivot))));

  IList<Tuple2<A, B>> zip<B>(IList<B> bs) {
    final IList<Tuple2<A, B>> abNil = nil();
    if (!(_isCons() && bs._isCons())) {
      return abNil;
    } else {
      final IList<Tuple2<A, B>> result = new Cons(tuple2(this._unsafeHead(), bs._unsafeHead()), abNil);
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

  // TODO: kill MonadOps flatten and rename in 0.8.0
  static IList<A> flattenIList<A>(IList<IList<A>> ffa) => ffa.flatMap(id);

  static IList<A> flattenOption<A>(IList<Option<A>> oas) => oas.flatMap((oa) => oa.fold(nil, (a) => cons(a, nil())));

  // PURISTS BEWARE: side effecty stuff below -- proceed with caution!

  List<A> toList() => foldLeft([], (List<A> p, a) => p..add(a));

  Iterable<A> toIterable() => new _IListIterable(this);

  Iterator<A> iterator() => new _IListIterator(this);

  void forEach(void sideEffect(A a)) {
    var current = this;
    while (current._isCons()) {
      sideEffect(current._unsafeHead());
      current = current._unsafeTail();
    }
  }

  Option<IList<B>> traverseOption<B>(Option<B> f(A a)) {
    Option<IList<B>> result = some(nil());
    var current = this;
    while(current._isCons()) {
      final gb = f(current._unsafeHead());
      result = result.fold(none, (a) => gb.fold(none, (h) => some(new Cons(h, a))));
      current = current._unsafeTail();
    }
    return result.map((l) => l.reverse());
  }

  Either<L, IList<B>> traverseEither<B, L>(Either<L, B> f(A a)) {
    Either<L, IList<B>> result = right(nil());
    var current = this;
    while(current._isCons()) {
      final gb = f(current._unsafeHead());
      result = result.fold(left, (a) => gb.fold(left, (h) => right(new Cons(h, a))));
      current = current._unsafeTail();
    }
    return result.map((l) => l.reverse());
  }

  Future<IList<B>> traverseFuture<B>(Future<B> f(A a)) {
    Future<IList<B>> result = new Future.microtask(nil);
    var current = this;
    while(current._isCons()) {
      final gb = f(current._unsafeHead());
      result = result.then((a) => gb.then((h) => new Cons(h, a)));
      current = current._unsafeTail();
    }
    return result.then((l) => l.reverse());
  }

  State<S, IList<B>> traverseState<B, S>(State<S, B> f(A a)) {
    State<S, IList<B>> result = new State((s) => tuple2(nil(), s));
    var current = this;
    while(current._isCons()) {
      final gb = f(current._unsafeHead());
      result = result.flatMap((a) => gb.map((h) => new Cons(h, a)));
      current = current._unsafeTail();
    }
    return result.map((l) => l.reverse());
  }

  Evaluation<E, R, W, S, IList<B>> traverseEvaluation<B, E, R, W, S>(Monoid<W> WMi, Evaluation<E, R, W, S, B> f(A a)) {
    Evaluation<E, R, W, S, IList<B>> result = new Evaluation(WMi, (r, s) => new Future.value(new Right(new Tuple3(WMi.zero(), s, nil()))));
    var current = this;
    while(current._isCons()) {
      final gb = f(current._unsafeHead());
      result = result.flatMap((a) => gb.map((h) => new Cons(h, a)));
      current = current._unsafeTail();
    }
    return result.map((l) => l.reverse());
  }

  Option<IList<B>> traverseOptionM<B>(Option<IList<B>> f(A a)) {
    var result = some(nil<B>());
    var current = this;
    while(current._isCons()) {
      final gb = f(current._unsafeHead());
      result = Option.map2(result, gb, (IList<B> a, IList<B> h) => a.plus(h));
      current = current._unsafeTail();
    }
    return result;
  }

  static Option<IList<A>> sequenceOption<A>(IList<Option<A>> loa) => loa.traverseOption(id);

  static Either<L, IList<A>> sequenceEither<A, L>(IList<Either<L, A>> loa) => loa.traverseEither(id);

  static Future<IList<A>> sequenceFuture<A>(IList<Future<A>> lfa) => lfa.traverseFuture(id);

  static State<S, IList<A>> sequenceState<A, S>(IList<State<S, A>> lsa) => lsa.traverseState(id);

  @override IList<B> mapWithIndex<B>(B f(int i, A a)) {
    final IList<B> bNil = nil();
    if (!_isCons()) {
      return bNil;
    }
    int i = 0;
    Cons<B> last = new Cons(f(i++, _unsafeHead()), bNil);
    if (!_unsafeTail()._isCons()) {
      return last;
    }
    final result = last;
    var current = _unsafeTail();
    while (current._isCons()) {
      final next = new Cons(f(i++, current._unsafeHead()), bNil);
      last._unsafeSetTail(next);
      last = next;
      current = current._unsafeTail();
    }
    return result;
  }

  @override IList<Tuple2<int, A>> zipWithIndex() => mapWithIndex(tuple2);

  @override bool all(bool f(A a)) => foldMap(BoolAndMi, f); // TODO: optimize

  @override IList<B> andThen<B>(IList<B> next) => bind((_) => next);

  @override bool any(bool f(A a)) => foldMap(BoolOrMi, f); // TODO: optimize

  @override IList<B> ap<B>(IList<Function1<A, B>> ff) => ff.bind((f) => map(f)); // TODO: optimize

  @override A concatenate(Monoid<A> mi) => foldMap(mi, id);

  @override Option<A> concatenateO(Semigroup<A> si) => foldMapO(si, id);

  @override B foldLeftWithIndex<B>(B z, B f(B previous, int i, A a)) {
    var i = 0;
    var result = z;
    var current = this;
    while (current._isCons()) {
      result = f(result, i++, current._unsafeHead());
      current = current._unsafeTail();
    }
    return result;
  }

  @override Option<B> foldMapO<B>(Semigroup<B> si, B f(A a)) =>
    uncons(none, (head, tail) => some(tail.foldLeft(f(head), (acc, a) => si.append(acc, f(a)))));

  @override B foldRightWithIndex<B>(B z, B f(int i, A a, B previous)) =>
    foldRight<Tuple2<B, int>>(tuple2(z, length()-1), (a, t) => tuple2(f(t.value2, a, t.value1), t.value2-1)).value1; // TODO: optimize

  @override A intercalate(Monoid<A> mi, A a) =>
    foldRight(none<A>(), (A ca, Option<A> oa) => some(mi.append(ca, oa.fold(mi.zero, mi.appendC(a))))) | mi.zero(); // TODO: optimize

  @override int length() =>
    foldLeft(0, (a, b) => a+1); // TODO: optimize

  @override Option<A> maximum(Order<A> oa) => concatenateO(oa.maxSi());

  @override Option<A> minimum(Order<A> oa) => concatenateO(oa.minSi());

  @override IList<B> replace<B>(B replacement) => map((_) => replacement);

  @override IList<Tuple2<B, A>> strengthL<B>(B b) => map((a) => tuple2(b, a));

  @override IList<Tuple2<A, B>> strengthR<B>(B b) => map((a) => tuple2(a, b));

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

class Nil<A> extends IList<A> {
  const Nil();

  bool _isCons() => false;
  A _unsafeHead() => throw new UnsupportedError("_unsafeHead called on Nil");
  IList<A> _unsafeTail() => throw new UnsupportedError("_unsafeTail called on Nil");
  void _unsafeSetTail(IList<A> newTail) => throw new UnsupportedError("_unsafeSetTail called on Nil");

  @override Option<A> get headOption => none();

  @override Option<IList<A>> get tailOption => none();
}

IList<A> nil<A>() => new Nil();
IList<A> cons<A>(A head, IList<A> tail) => new Cons(head, tail);

final MonadPlus<IList> IListMP = new MonadPlusOpsMonadPlus<IList>((a) => new Cons(a, nil()), nil);
MonadPlus<IList<A>> ilistMP<A>() => cast(IListMP);
final Traversable<IList> IListTr = new TraversableOpsTraversable<IList>();

class IListMonoid<A> extends Monoid<IList<A>> {
  @override IList<A> zero() => nil();
  @override IList<A> append(IList<A> l1, IList<A> l2) => l1.plus(l2);
}

final Monoid<IList> IListMi = new IListMonoid();
Monoid<IList<A>> ilistMi<A>() => new IListMonoid();

class IListTMonad<M> extends Functor<M> with Applicative<M>, Monad<M> {
  Monad<M> _stackedM;
  IListTMonad(this._stackedM);
  Monad underlying() => IListMP;

  @override M pure<A>(A a) => _stackedM.pure(new Cons(a, nil()));

  M _concat(M a, M b) => _stackedM.bind(a, (l1) => _stackedM.map(b, (l2) => l1.plus(l2)));

  @override M bind<A, B>(M mla, M f(A a)) => _stackedM.bind(mla, (IList l) => l.map<M>(cast(f)).foldLeft(_stackedM.pure(nil()), _concat));
}

Monad ilistTMonad(Monad mmonad) => new IListTMonad(mmonad);

IList<int> iota(int n) {
  Trampoline<IList<int>> go(int i, IList<int> result) => i > 0 ? tcall(() => go(i-1, new Cons(i-1, result))) : treturn(result);
  return go(n, nil()).run();
}

IList<A> ilist<A>(Iterable<A> iterable) => new IList.from(iterable);

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
    final IList<A> curr = _l;
    if (curr._isCons()) {
      if (_started) {
        final IList<A> next = curr._unsafeTail();
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