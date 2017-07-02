part of dartz;

class IMap<K, V> extends TraversableOps<IMap<K, dynamic>, V> {
  final Order<K> _order;
  final _IMapAVLNode<K, V> _tree;

  IMap(this._order, this._tree);

  factory IMap.empty() => emptyMap();

  IMap.emptyWithOrder(this._order): _tree = emptyIMapAVLNode();

  factory IMap.from(Map<K, V> m) => m.keys.fold(new IMap.empty(), (IMap<K, V> p, K k) => p.put(k, m[k]));

  factory IMap.fromWithOrder(Order<K> kOrder, Map<K, V> m) => m.keys.fold(new IMap.emptyWithOrder(kOrder), (p, K k) => p.put(k, m[k]));

  factory IMap.fromIterables(Iterable<K> keys, Iterable<V> values, [Order<K> kOrder]) {
    IMap<K, V> result = new IMap.emptyWithOrder(kOrder ?? comparableOrder());
    final keyIterator = keys.iterator;
    final valueIterator = values.iterator;
    while(keyIterator.moveNext() && valueIterator.moveNext()) {
      result = result.put(keyIterator.current, valueIterator.current);
    }
    return result;
  }

  IMap<K, V> put(K k, V v) => new IMap(_order, _tree.insert(_order, k, v));

  Option<V> get(K k) => _tree.get(_order, k);

  Option<V> operator[](K k) => get(k);

  IMap<K, V> modify(K k, V f(V v), V dflt) => new IMap(_order, _tree.modify(_order, k, f, dflt));

  Option<IMap<K, V>> set(K k, V v) {
    final newMap = setIfPresent(k, v);
    return identical(this, newMap) ? none() : some(newMap);
  }

  IMap<K, V> setIfPresent(K k, V v) {
    final newTree = _tree.setIfPresent(_order, k, v);
    return identical(_tree, newTree) ? this : new IMap(_order, newTree);
  }

  IMap<K, V> remove(K k) => new IMap(_order, _tree.remove(_order, k));

  IList<K> keys() => _tree.foldRight(nil(), (k, v, p) => new Cons(k, p));

  IList<V> values() => _tree.foldRight(nil(), (k, v, p) => new Cons(v, p));

  B foldLeftKV<B>(B z, B f(B previous, K k, V v)) => _tree.foldLeft(z, f);

  B foldLeftKVBetween<B>(K minK, K maxK, B z, B f(B previous, K k, V v)) => _tree.foldLeftBetween(_order, minK, maxK, z, f);

  B foldRightKV<B>(B z, B f(K k, V v, B previous)) => _tree.foldRight(z, f);

  B foldRightKVBetween<B>(K minK, K maxK, B z, B f(K k, V v, B previous)) => _tree.foldRightBetween(_order, minK, maxK, z, f);

  B foldMapKV<B>(Monoid<B> mi, B f(K k, V v)) => _tree.foldLeft(mi.zero(), (p, k, v) => mi.append(p, f(k, v)));

  IMap<K, V2> mapWithKey<V2>(V2 f(K k, V v)) => foldLeftKV(new IMap(_order, emptyIMapAVLNode()), (p, k, v) => p.put(k, f(k, v)));

  IList<Tuple2<K, V>> pairs() => _tree.foldRight(nil(), (k, v, p) => new Cons(tuple2(k, v), p));

  @override G traverse<G>(Applicative<G> gApplicative, G f(V v)) =>
      _tree.foldLeft(gApplicative.pure(
          new IMap(_order, _emptyIMapAVLNode)),
          (prev, k, v) => gApplicative.map2(prev, f(v), (IMap p, v2) => p.put(k, v2)));

  @override B foldMap<B>(Monoid<B> bMonoid, B f(V v)) =>  _tree.foldLeft(bMonoid.zero(), (p, k, v) => bMonoid.append(p, f(v)));

  @override B foldLeft<B>(B z, B f(B previous, V v)) => _tree.foldLeft(z, (p, k, v) => f(p, v));

  @override B foldRight<B>(B z, B f(V v, B previous)) => _tree.foldRight(z, (k, v, p) => f(v, p));

  @override IMap<K, V2> map<V2>(V2 f(V v)) => new IMap(_order, _tree.map(f));

  Map<K, V> toMap() => foldLeftKV(new Map(), (p, K k, V v) => p..[k] = v);

  Option<K> minKey() => _tree.min().map((node) => node._k);

  Option<Tuple2<K, V>> min() => _tree.min().map((node) => tuple2(node._k, node._v));

  Option<K> maxKey() => _tree.max().map((node) => node._k);

  Option<Tuple2<K, V>> max() => _tree.max().map((node) => tuple2(node._k, node._v));

  Option<Tuple2<K, V>> minGreaterThan(K k) => _tree.minGreaterThan(_order, k).map((node) => tuple2(node._k, node._v));

  Option<Tuple2<K, V>> maxLessThan(K k) => _tree.maxLessThan(_order, k).map((node) => tuple2(node._k, node._v));

  @override bool operator ==(other) => identical(this, other) || (other is IMap && _order == other._order && pairs() == other.pairs());

  @override int get hashCode => _order.hashCode ^ pairs().hashCode;

  @override String toString() => "imap{${foldMapKV(IListMi, (k, v) => new Cons("$k: $v", nil())).intercalate(StringMi, ", ")}}";

  // PURISTS BEWARE: mutable Iterable/Iterator integrations -- proceed with caution!

  Iterable<Tuple2<K, V>> pairIterable() => new _IMapPairIterable(this);

  Iterator<Tuple2<K, V>> pairIterator() => pairIterable().iterator;

  Iterable<K> keyIterable() => new _IMapKeyIterable(this);

  Iterator<K> keyIterator() => keyIterable().iterator;

  Iterable<V> valueIterable() => new _IMapValueIterable(this);

  Iterator<V> valueIterator() => valueIterable().iterator;

  Iterable<Tuple2<K, V>> toIterable() => pairIterable();

  Iterator<Tuple2<K, V>> iterator() => pairIterator();
}


IMap<K, V> imap<K, V>(Map<K, V> m) => new IMap.from(m);
IMap<K, V> imapWithOrder<K, K2 extends K, V>(Order<K> o, Map<K2, V> m) => new IMap.fromWithOrder(o, m);
IMap _emptyIMap = new IMap(comparableOrder(), emptyIMapAVLNode());
IMap<K, V> emptyMap<K, V>() => cast(_emptyIMap);
IMap<K, V> singletonMap<K, V>(K k, V v) => emptyMap<K, V>().put(k, v);

class IMapMonoid<K, V> extends Monoid<IMap<K, V>> {
  final Semigroup<V> _vSemigroup;

  IMapMonoid(this._vSemigroup);

  @override IMap<K, V> zero() => new IMap.empty();
  @override IMap<K, V> append(IMap<K, V> m1, IMap<K, V> m2) =>
      m2.pairs().foldLeft(m1, (p, kv) =>
          m1.get(kv.value1).fold(() =>
              p.put(kv.value1, kv.value2),
              (m1v) => p.put(kv.value1, _vSemigroup.append(m1v, kv.value2))));
}

Monoid<IMap<K, V>> imapMonoid<K, V>(Semigroup<V> si) => new IMapMonoid(si);

final Monoid<IMap> IMapMi = imapMonoid(secondSemigroup());
Monoid<IMap<K, V>> imapMi<K, V>() => cast(IMapMi);

final Traversable<IMap> IMapTr = new TraversableOpsTraversable<IMap>();

abstract class _IMapAVLNode<K, V> extends FunctorOps<_IMapAVLNode<K, dynamic>, V> {
  _IMapAVLNode();

  _IMapAVLNode<K, V> insert(Order<K> order, K k, V v);
  _IMapAVLNode<K, V> remove(Order<K> order, K k);
  B foldLeft<B>(B z, B f(B previous, K k, V v));
  B foldLeftBetween<B>(Order<K> order, K minK, K maxK, B z, B f(B previous, K k, V v));
  B foldRight<B>(B z, B f(K k, V v, B previous));
  B foldRightBetween<B>(Order<K> order, K minK, K maxK, B z, B f(K k, V v, B previous));
  Option<V> get(Order<K> order, K k);
  int get height;
  int get balance;
  Option<Tuple3<_IMapAVLNode<K, V>, K, V>> _removeMax();
  _IMapAVLNode<K, V> setIfPresent(Order<K> order, K k, V v);
  _IMapAVLNode<K, V> modify(Order<K> order, K k, V f(V v), V dflt);
  _IMapAVLNode<K, V2> map<V2>(V2 f(V v));
  Option<_NonEmptyIMapAVLNode<K, V>> min();
  Option<_NonEmptyIMapAVLNode<K, V>> max();
  Option<_NonEmptyIMapAVLNode<K, V>> minGreaterThan(Order<K> order, K k);
  Option<_NonEmptyIMapAVLNode<K, V>> maxLessThan(Order<K> order, K k);
  bool get empty;
}

class _NonEmptyIMapAVLNode<K, V> extends _IMapAVLNode<K, V> {
  final K _k;
  final V _v;
  final int _height;
  int get height => _height;
  int get balance => _right.height - _left.height;
  final _IMapAVLNode<K, V> _left;
  final _IMapAVLNode<K, V> _right;

  _NonEmptyIMapAVLNode(this._k, this._v, _IMapAVLNode<K, V> left, _IMapAVLNode<K, V> right)
      : _height = (left.height > right.height) ? left.height+1 : right.height+1,
        _left = left,
        _right = right;

  _IMapAVLNode<K, V> insert(Order<K> order, K k, V v) {
    final Ordering o = order.order(k, _k);
    if (o == Ordering.LT) {
      final newLeft = _left.insert(order, k, v);
      return new _NonEmptyIMapAVLNode(_k, _v, newLeft, _right)._rebalance();
    } else if (o == Ordering.GT) {
      final newRight = _right.insert(order, k, v);
      return new _NonEmptyIMapAVLNode(_k, _v, _left, newRight)._rebalance();
    } else {
      return new _NonEmptyIMapAVLNode(k, v, _left, _right);
    }
  }

  _IMapAVLNode<K, V> remove(Order<K> order, K k) {
    final Ordering o = order.order(k, _k);
    if (o == Ordering.LT) {
      return new _NonEmptyIMapAVLNode(_k, _v, _left.remove(order, k), _right)._rebalance();
    } else if (o == Ordering.GT) {
      return new _NonEmptyIMapAVLNode(_k, _v, _left, _right.remove(order, k))._rebalance();
    } else {
      return _left._removeMax().fold(() => _right, (lr) => new _NonEmptyIMapAVLNode(lr.value2, lr.value3, lr.value1, _right)._rebalance());
    }
  }

  Option<Tuple3<_IMapAVLNode<K, V>, K, V>> _removeMax() =>
      _right._removeMax().fold(() => some(tuple3(_left, _k, _v)),
          (rightResult) => some(tuple3(new _NonEmptyIMapAVLNode(_k, _v, _left, rightResult.value1)._rebalance(), rightResult.value2, rightResult.value3)));

  _IMapAVLNode<K, V> _rebalance() {
    final b = balance;
    if (b < -1) {
      if (_left.balance < 0) {
        return llRotate(cast(_left));
      } else {
        return doubleLrRotate(cast(_left));
      }
    } else if (b > 1) {
      if (_right.balance > 0) {
        return rrRotate(cast(_right));
      } else {
        return doubleRlRotate(cast(_right));
      }
    } else {
      return this;
    }
  }

  _NonEmptyIMapAVLNode<K, V> llRotate(_NonEmptyIMapAVLNode<K, V> l) => new _NonEmptyIMapAVLNode(l._k, l._v, l._left, new _NonEmptyIMapAVLNode(_k, _v, l._right, _right));

  _NonEmptyIMapAVLNode<K, V> doubleLrRotate(_NonEmptyIMapAVLNode<K, V> l) => llRotate(l.rrRotate(cast(l._right)));

  _NonEmptyIMapAVLNode<K, V> rrRotate(_NonEmptyIMapAVLNode<K, V> r) => new _NonEmptyIMapAVLNode(r._k, r._v, new _NonEmptyIMapAVLNode(_k, _v, _left, r._left), r._right);

  _NonEmptyIMapAVLNode<K, V> doubleRlRotate(_NonEmptyIMapAVLNode<K, V> r) => rrRotate(r.llRotate(cast(r._left)));

  B foldLeft<B>(B z, B f(B previous, K k, V v)) {
    final leftResult = _left.foldLeft(z, f);
    final midResult = f(leftResult, _k, _v);
    return _right.foldLeft(midResult, f);
  }

  B foldLeftBetween<B>(Order<K> order, K minK, K maxK, B z, B f(B previous, K k, V v)) {
    if (order.lt(_k, minK)) {
      return _right.foldLeftBetween(order, minK, maxK, z, f);
    } else if (order.gt(_k, maxK)) {
      return _left.foldLeftBetween(order, minK, maxK, z, f);
    } else {
      final leftResult = _left.foldLeftBetween(order, minK, maxK, z, f);
      final midResult = f(leftResult, _k, _v);
      return _right.foldLeftBetween(order, minK, maxK, midResult, f);
    }
  }

  B foldRight<B>(B z, B f(K k, V v, B previous)) {
    final rightResult =_right.foldRight(z, f);
    final midResult = f(_k, _v, rightResult);
    return _left.foldRight(midResult, f);
  }

  B foldRightBetween<B>(Order<K> order, K minK, K maxK, B z, B f(K k, V v, B previous)) {
    if (order.lt(_k, minK)) {
      return _right.foldRightBetween(order, minK, maxK, z, f);
    } else if (order.gt(_k, maxK)) {
      return _left.foldRightBetween(order, minK, maxK, z, f);
    } else {
      final rightResult =_right.foldRightBetween(order, minK, maxK, z, f);
      final midResult = f(_k, _v, rightResult);
      return _left.foldRightBetween(order, minK, maxK, midResult, f);
    }
  }

  Option<V> get(Order<K> order, K k) {
    var current = this;
    while(!current.empty) {
      final Ordering o = order.order(k, current._k);
      if (o == Ordering.EQ) {
        return some(current._v);
      } else if (o == Ordering.LT) {
        current = cast(current._left);
      } else {
        current = cast(current._right);
      }
    }
    return none();
  }

  @override _IMapAVLNode<K, V2> map<V2>(V2 f(V v)) {
    final newLeft = _left.map(f);
    final newV = f(_v);
    final newRight = _right.map(f);
    return new _NonEmptyIMapAVLNode(_k, newV, newLeft, newRight);
  }

  @override _IMapAVLNode<K, V> setIfPresent(Order<K> order, K k, V v) {
    final Ordering o = order.order(k, _k);
    if (o == Ordering.LT) {
      final newLeft = _left.setIfPresent(order, k, v);
      return identical(newLeft, _left) ? this : new _NonEmptyIMapAVLNode(_k, _v, newLeft, _right);
    } else if (o == Ordering.GT) {
      final newRight = _right.setIfPresent(order, k, v);
      return identical(newRight, _right) ? this : new _NonEmptyIMapAVLNode(_k, _v, _left, newRight);
    } else {
      return new _NonEmptyIMapAVLNode(_k, v, _left, _right);
    }
  }

  @override _IMapAVLNode<K, V> modify(Order<K> order, K k, V f(V v), V dflt) {
    final Ordering o = order.order(k, _k);
    if (o == Ordering.LT) {
      final newLeft = _left.modify(order, k, f, dflt);
      return new _NonEmptyIMapAVLNode(_k, _v, newLeft, _right)._rebalance();
    } else if (o == Ordering.GT) {
      final newRight = _right.modify(order, k, f, dflt);
      return new _NonEmptyIMapAVLNode(_k, _v, _left, newRight)._rebalance();
    } else {
      return new _NonEmptyIMapAVLNode(_k, f(_v), _left, _right);
    }
  }

  @override Option<_NonEmptyIMapAVLNode<K, V>> min() => _left.empty ? some(this) : _left.min();

  @override Option<_NonEmptyIMapAVLNode<K, V>> max() => _right.empty ? some(this) : _right.max();

  @override Option<_NonEmptyIMapAVLNode<K, V>> minGreaterThan(Order<K> order, K k) => order.gt(_k, k)
      ? _left.minGreaterThan(order, k).orElse(() => some(this))
      : _right.minGreaterThan(order, k);

  @override Option<_NonEmptyIMapAVLNode<K, V>> maxLessThan(Order<K> order, K k) => order.lt(_k, k)
      ? _right.maxLessThan(order, k).orElse(() => some(this))
      : _left.maxLessThan(order, k);

  bool get empty => false;
}

class _EmptyIMapAVLNode<K, V> extends _IMapAVLNode<K, V> {
  _EmptyIMapAVLNode();

  @override B foldLeft<B>(B z, B f(B previous, K k, V v)) => z;

  B foldLeftBetween<B>(Order<K> order, K minK, K maxK, B z, B f(B previous, K k, V v)) => z;

  @override B foldRight<B>(B z, B f(K k, V v, B previous)) => z;

  B foldRightBetween<B>(Order<K> order, K minK, K maxK, B z, B f(K k, V v, B previous)) => z;

  @override Option<V> get(Order<K> order, K k) => none();

  @override _IMapAVLNode<K, V> insert(Order<K> order, K k, V v) => new _NonEmptyIMapAVLNode(k, v, emptyIMapAVLNode(), emptyIMapAVLNode());

  @override _IMapAVLNode<K, V> remove(Order<K> order, K k) => this;

  @override int get height => -1;

  @override int get balance => 0;

  @override Option<Tuple3<_IMapAVLNode<K, V>, K, V>> _removeMax() => none();

  @override _IMapAVLNode<K, V> setIfPresent(Order<K> order, K k, V v) => this;

  @override _IMapAVLNode<K, V> modify(Order<K> order, K k, V f(V v), V dflt) => new _NonEmptyIMapAVLNode(k, dflt, emptyIMapAVLNode(), emptyIMapAVLNode());

  @override _IMapAVLNode<K, V2> map<V2>(V2 f(V v)) => cast(this);

  @override operator ==(other) => identical(_emptyIMapAVLNode, other);

  @override int get hashCode => 0;

  @override Option<_NonEmptyIMapAVLNode<K, V>> min() => none();

  @override Option<_NonEmptyIMapAVLNode<K, V>> max() => none();

  @override Option<_NonEmptyIMapAVLNode<K, V>> minGreaterThan(Order<K> order, K k) => none();

  @override Option<_NonEmptyIMapAVLNode<K, V>> maxLessThan(Order<K> order, K k) => none();

  bool get empty => true;
}

final _IMapAVLNode _emptyIMapAVLNode = new _EmptyIMapAVLNode();
_IMapAVLNode<K, V> emptyIMapAVLNode<K, V>() => cast(_emptyIMapAVLNode);

abstract class _IMapIterable<K, V, A> extends Iterable<A> {
  final IMap<K, V> _m;
  _IMapIterable(this._m);
}

class _IMapPairIterable<K, V> extends _IMapIterable<K, V, Tuple2<K, V>> {
  _IMapPairIterable(IMap<K, V> m) : super(m);
  @override Iterator<Tuple2<K, V>> get iterator => _m._tree.empty ? new _IMapPairIterator(null) : new _IMapPairIterator(cast(_m._tree));
}

class _IMapKeyIterable<K, V> extends _IMapIterable<K, V, K> {
  _IMapKeyIterable(IMap<K, V> m) : super(m);
  @override Iterator<K> get iterator => _m._tree.empty ? new _IMapKeyIterator(null) : new _IMapKeyIterator(cast(_m._tree));
}

class _IMapValueIterable<K, V> extends _IMapIterable<K, V, V> {
  _IMapValueIterable(IMap<K, V> m) : super(m);
  @override Iterator<V> get iterator => _m._tree.empty ? new _IMapValueIterator(null) : new _IMapValueIterator(cast(_m._tree));
}

abstract class _IMapAVLNodeIterator<K, V, A> extends Iterator<A> {

  bool _started = false;
  _NonEmptyIMapAVLNode<K, V> _currentNode = null;
  IList<_NonEmptyIMapAVLNode<K, V>> _path = nil();

  _IMapAVLNodeIterator(this._currentNode);

  @override bool moveNext() {
    if (_currentNode != null) {
      if (_started) {
        return _descend();
      } else {
        _descendLeft();
        _started = true;
        return true;
      }
    } else {
      _currentNode = null;
      return false;
    }
  }

  bool _descend() {
    if (!_currentNode._right.empty) {
      _currentNode = cast(_currentNode._right);
      _descendLeft();
      return true;
    } else {
      if (_path._isCons()) {
        _currentNode = _path._unsafeHead();
        _path = _path._unsafeTail();
        return true;
      } else {
        return false;
      }
    }
  }

  void _descendLeft() {
    var current = _currentNode;
    var currentLeft = current._left;
    while(true) {
      if (!currentLeft.empty) {
        final _NonEmptyIMapAVLNode<K, V> cl = cast(currentLeft);
        _path = cons(current, _path);
        current = cl;
        currentLeft = cl._left;
      } else {
        _currentNode = current;
        return;
      }
    }
  }

}

class _IMapPairIterator<K, V> extends _IMapAVLNodeIterator<K, V, Tuple2<K, V>> {
  _IMapPairIterator(_NonEmptyIMapAVLNode<K, V> root) : super(root);
  @override Tuple2<K, V> get current => _currentNode != null ? tuple2(_currentNode._k, _currentNode._v) : null;
}

class _IMapKeyIterator<K, V> extends _IMapAVLNodeIterator<K, V, K> {
  _IMapKeyIterator(_NonEmptyIMapAVLNode<K, V> root) : super(root);
  @override K get current => _currentNode != null ? _currentNode._k : null;
}

class _IMapValueIterator<K, V> extends _IMapAVLNodeIterator<K, V, V> {
  _IMapValueIterator(_NonEmptyIMapAVLNode<K, V> root) : super(root);
  @override V get current => _currentNode != null ? _currentNode._v : null;
}
