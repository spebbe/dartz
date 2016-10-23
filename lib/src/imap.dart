part of dartz;

class IMap<K, V> extends TraversableOps<IMap<K, dynamic>, V> {
  final Order<K> _order;
  final _IMapAVLNode<K, V> _tree;

  IMap(this._order, this._tree);

  IMap.empty(): _order = comparableOrder(), _tree = emptyIMapAVLNode();

  IMap.emptyWithOrder(this._order): _tree = emptyIMapAVLNode();

  factory IMap.from(Map<K, V> m) => m.keys.fold(new IMap.empty(), (IMap<K, V> p, K k) => p.put(k, m[k]));

  factory IMap.fromWithOrder(Order<K> kOrder, Map<K, V> m) => m.keys.fold(new IMap.emptyWithOrder(kOrder), (IMap<K, V> p, K k) => p.put(k, m[k]));

  IMap<K, V> put(K k, V v) => new IMap(_order, _tree.insert(_order, k, v));

  Option<V> get(K k) => _tree.get(_order, k);

  IMap<K, V> modify(K k, V f(V v), V dflt) => new IMap(_order, _tree.modify(_order, k, f, dflt));

  Option<IMap<K, V>> set(K k, V v) => _tree.set(_order, k, v).map((newTree) => new IMap(_order, newTree));

  IMap<K, V> remove(K k) => new IMap(_order, _tree.remove(_order, k));

  IList<K> keys() => _tree.foldRight(nil(), (k, v, p) => new Cons(k, p));

  IList<V> values() => _tree.foldRight(nil(), (k, v, p) => new Cons(v, p));

  /*=B*/ foldLeftKV/*<B>*/(/*=B*/ z, /*=B*/ f(/*=B*/ previous, K k, V v)) => _tree.foldLeft(z, f);

  /*=B*/ foldRightKV/*<B>*/(/*=B*/ z, /*=B*/ f(K k, V v, /*=B*/ previous)) => _tree.foldRight(z, f);

  /*=B*/ foldMapKV/*<B>*/(Monoid/*<B>*/ mi, /*=B*/ f(K k, V v)) => _tree.foldLeft(mi.zero(), (p, k, v) => mi.append(p, f(k, v)));

  IMap<K, dynamic/*=V2*/> mapWithKey/*<V2>*/(/*=V2*/ f(K k, V v)) => foldLeftKV(new IMap/*<K, V2>*/(_order, emptyIMapAVLNode()), (IMap<K, dynamic/*=V2*/> p, k, v) => p.put(k, f(k, v)));

  IList<Tuple2<K, V>> pairs() => _tree.foldRight(nil(), (k, v, p) => new Cons(tuple2(k, v), p));

  @override /*=G*/ traverse/*<G>*/(Applicative/*<G>*/ gApplicative, /*=G*/ f(V v)) =>
      _tree.foldLeft(gApplicative.pure(
          new IMap(_order, _emptyIMapAVLNode)),
          (prev, k, v) => gApplicative.map2(prev, f(v), (IMap p, v2) => p.put(k, v2)));

  @override /*=B*/ foldMap/*<B>*/(Monoid/*<B>*/ bMonoid, /*=B*/ f(V v)) =>  _tree.foldLeft(bMonoid.zero(), (p, k, v) => bMonoid.append(p, f(v)));

  @override /*=B*/ foldLeft/*<B>*/(/*=B*/ z, /*=B*/ f(/*=B*/ previous, V v)) => _tree.foldLeft(z, (p, k, v) => f(p, v));

  @override /*=B*/ foldRight/*<B>*/(/*=B*/ z, /*=B*/ f(V v, /*=B*/ previous)) => _tree.foldRight(z, (k, v, p) => f(v, p));

  @override IMap<K, dynamic/*=V2*/> map/*<V2>*/(/*=V2*/ f(V v)) => new IMap/*<K, V2>*/(_order, _tree.map(f));

  Map<K, V> toMap() => foldLeftKV(new Map(), (Map<K, V> p, K k, V v) => p..[k] = v);

  @override bool operator ==(other) => identical(this, other) || (other is IMap && _order == other._order && pairs() == other.pairs());

  @override String toString() => "imap{${foldMapKV(IListMi, (k, v) => new Cons("$k: $v", nil/*<String>*/())).intercalate(StringMi, ", ")}}";
}

IMap/*<K, V>*/ imap/*<K, V>*/(Map/*<K, V>*/ m) => new IMap.from(m);
IMap/*<K, V>*/ imapWithOrder/*<K, V>*/(Order/*<K>*/ o, Map/*<K, V>*/ m) => new IMap.fromWithOrder(o, m);
IMap/*<K, V>*/ emptyMap/*<K, V>*/() => new IMap.empty();
IMap/*<K, V>*/ singletonMap/*<K, V>*/(/*=K*/ k, /*=V*/ v) => new IMap/*<K, V>*/.empty().put(k, v);

class IMapMonoid<K, V> extends Monoid<IMap<K, V>> {
  final Semigroup<V> _vSemigroup;

  IMapMonoid(this._vSemigroup);

  @override IMap<K, V> zero() => new IMap.empty();
  @override IMap<K, V> append(IMap<K, V> m1, IMap<K, V> m2) =>
      m2.pairs().foldLeft(m1, (IMap<K, V> p, Tuple2<K, V> kv) =>
          m1.get(kv.value1).fold(() =>
              p.put(kv.value1, kv.value2),
              (m1v) => p.put(kv.value1, _vSemigroup.append(m1v, kv.value2))));
}

Monoid<IMap/*<K, V>*/> imapMonoid/*<K, V>*/(Semigroup/*<V>*/ si) => new IMapMonoid/*<K, V>*/(si);

final Monoid<IMap> IMapMi = imapMonoid(secondSemigroup());
Monoid<IMap/*<K, V>*/> imapMi/*<K, V>*/() => IMapMi;

final Traversable<IMap> IMapTr = new TraversableOpsTraversable<IMap>();

abstract class _IMapAVLNode<K, V> extends FunctorOps<_IMapAVLNode<K, dynamic>, V> {
  _IMapAVLNode();

  _IMapAVLNode<K, V> insert(Order<K> order, K k, V v);
  _IMapAVLNode<K, V> remove(Order<K> order, K k);
  /*=B*/ foldLeft/*<B>*/(/*=B*/ z, /*=B*/ f(/*=B*/ previous, K k, V v));
  /*=B*/ foldRight/*<B>*/(/*=B*/ z, /*=B*/ f(K k, V v, /*=B*/ previous));
  Option<V> get(Order<K> order, K k);
  int get height;
  int get balance;
  Option<Tuple3<_IMapAVLNode<K, V>, K, V>> _removeMax();
  Option<_IMapAVLNode<K, V>> set(Order<K> order, K k, V v);
  _IMapAVLNode<K, V> modify(Order<K> order, K k, V f(V v), V dflt);
  _IMapAVLNode<K, dynamic/*=V2*/> map/*<V2>*/(/*=V2*/ f(V v));
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
      return new _NonEmptyIMapAVLNode/*<K, V>*/(_k, _v, newLeft, _right)._rebalance();
    } else if (o == Ordering.GT) {
      final newRight = _right.insert(order, k, v);
      return new _NonEmptyIMapAVLNode/*<K, V>*/(_k, _v, _left, newRight)._rebalance();
    } else {
      return new _NonEmptyIMapAVLNode(k, v, _left, _right);
    }
  }

  _IMapAVLNode<K, V> remove(Order<K> order, K k) {
    final Ordering o = order.order(k, _k);
    if (o == Ordering.LT) {
      return new _NonEmptyIMapAVLNode/*<K, V>*/(_k, _v, _left.remove(order, k), _right)._rebalance();
    } else if (o == Ordering.GT) {
      return new _NonEmptyIMapAVLNode/*<K, V>*/(_k, _v, _left, _right.remove(order, k))._rebalance();
    } else {
      return _left._removeMax().fold(() => _right, (lr) => new _NonEmptyIMapAVLNode/*<K, V>*/(lr.value2, lr.value3, lr.value1, _right)._rebalance());
    }
  }

  Option<Tuple3<_IMapAVLNode<K, V>, K, V>> _removeMax() =>
      _right._removeMax().fold(() => some(tuple3(_left, _k, _v)),
          (rightResult) => some(tuple3(new _NonEmptyIMapAVLNode/*<K, V>*/(_k, _v, _left, rightResult.value1)._rebalance(), rightResult.value2, rightResult.value3)));

  _IMapAVLNode<K, V> _rebalance() {
    final b = balance;
    if (b < -1) {
      if (_left.balance < 0) {
        return llRotate(_left);
      } else {
        return doubleLrRotate(_left);
      }
    } else if (b > 1) {
      if (_right.balance > 0) {
        return rrRotate(_right);
      } else {
        return doubleRlRotate(_right);
      }
    } else {
      return this;
    }
  }

  _NonEmptyIMapAVLNode<K, V> llRotate(_NonEmptyIMapAVLNode<K, V> l) => new _NonEmptyIMapAVLNode(l._k, l._v, l._left, new _NonEmptyIMapAVLNode(_k, _v, l._right, _right));

  _NonEmptyIMapAVLNode<K, V> doubleLrRotate(_NonEmptyIMapAVLNode<K, V> l) => llRotate(l.rrRotate(l._right));

  _NonEmptyIMapAVLNode<K, V> rrRotate(_NonEmptyIMapAVLNode<K, V> r) => new _NonEmptyIMapAVLNode(r._k, r._v, new _NonEmptyIMapAVLNode(_k, _v, _left, r._left), r._right);

  _NonEmptyIMapAVLNode<K, V> doubleRlRotate(_NonEmptyIMapAVLNode<K, V> r) => rrRotate(r.llRotate(r._left));

  /*=B*/ foldLeft/*<B>*/(/*=B*/ z, /*=B*/ f(/*=B*/ previous, K k, V v)) {
    final leftResult = _left.foldLeft(z, f);
    final midResult = f(leftResult, _k, _v);
    return _right.foldLeft(midResult, f);
  }

  /*=B*/ foldRight/*<B>*/(/*=B*/ z, /*=B*/ f(K k, V v, /*=B*/ previous)) {
    final rightResult =_right.foldRight(z, f);
    final midResult = f(_k, _v, rightResult);
    return _left.foldRight(midResult, f);
  }

  Option<V> get(Order<K> order, K k) {
    var current = this;
    while(current is _NonEmptyIMapAVLNode) {
      final Ordering o = order.order(k, current._k);
      if (o == Ordering.EQ) {
        return some(current._v);
      } else if (o == Ordering.LT) {
        current = current._left;
      } else {
        current = current._right;
      }
    }
    return none();
  }

  @override _IMapAVLNode<K, dynamic/*=V2*/> map/*<V2>*/(/*=V2*/ f(V v)) {
    final _IMapAVLNode<K, dynamic/*=V2*/> newLeft = _left.map(f);
    final newV = f(_v);
    final _IMapAVLNode<K, dynamic/*=V2*/> newRight = _right.map(f);
    return new _NonEmptyIMapAVLNode/*<K, V2>*/(_k, newV, newLeft, newRight);
  }

  @override Option<_IMapAVLNode<K, V>> set(Order<K> order, K k, V v) {
    final Ordering o = order.order(k, _k);
    if (o == Ordering.LT) {
      return _left.set(order, k, v).map((newLeft) => new _NonEmptyIMapAVLNode(_k, _v, newLeft, _right));
    } else if (o == Ordering.GT) {
      return _right.set(order, k, v).map((newRight) => new _NonEmptyIMapAVLNode(_k, _v, _left, newRight));
    } else {
      return some(new _NonEmptyIMapAVLNode(_k, v, _left, _right));
    }
  }

  @override _IMapAVLNode<K, V> modify(Order<K> order, K k, V f(V v), V dflt) {
    final Ordering o = order.order(k, _k);
    if (o == Ordering.LT) {
      final newLeft = _left.modify(order, k, f, dflt);
      return new _NonEmptyIMapAVLNode/*<K, V>*/(_k, _v, newLeft, _right)._rebalance();
    } else if (o == Ordering.GT) {
      final newRight = _right.modify(order, k, f, dflt);
      return new _NonEmptyIMapAVLNode/*<K, V>*/(_k, _v, _left, newRight)._rebalance();
    } else {
      return new _NonEmptyIMapAVLNode(_k, f(_v), _left, _right);
    }
  }
}

class _EmptyIMapAVLNode<K, V> extends _IMapAVLNode<K, V> {
  _EmptyIMapAVLNode();

  @override /*=B*/ foldLeft/*<B>*/(/*=B*/ z, /*=B*/ f(/*=B*/ previous, K k, V v)) => z;

  @override /*=B*/ foldRight/*<B>*/(/*=B*/ z, /*=B*/ f(K k, V v, /*=B*/ previous)) => z;

  @override Option<V> get(Order<K> order, K k) => none();

  @override _IMapAVLNode<K, V> insert(Order<K> order, K k, V v) => new _NonEmptyIMapAVLNode(k, v, emptyIMapAVLNode(), emptyIMapAVLNode());

  @override _IMapAVLNode<K, V> remove(Order<K> order, K k) => this;

  @override int get height => -1;

  @override int get balance => 0;

  @override Option<Tuple3<_IMapAVLNode<K, V>, K, V>> _removeMax() => none();

  @override Option<_IMapAVLNode<K, V>> set(Order<K> order, K k, V v) => none();

  @override _IMapAVLNode<K, V> modify(Order<K> order, K k, V f(V v), V dflt) => new _NonEmptyIMapAVLNode(k, dflt, emptyIMapAVLNode(), emptyIMapAVLNode());

  @override _IMapAVLNode<K, dynamic/*=V2*/> map/*<V2>*/(/*=V2*/ f(V v)) => emptyIMapAVLNode();

  @override operator ==(other) => identical(_emptyIMapAVLNode, other);

}

final _IMapAVLNode _emptyIMapAVLNode = new _EmptyIMapAVLNode();
_IMapAVLNode/*<K, V>*/ emptyIMapAVLNode/*<K, V>*/() => _emptyIMapAVLNode as dynamic/*=_IMapAVLNode<K, V>*/;
