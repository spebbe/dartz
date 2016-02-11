part of dartz;

class _IMapOrder<K, V> extends Order<Tuple2<K, V>> {
  final Order<K> _kOrder;

  _IMapOrder(this._kOrder);

  @override Ordering order(Tuple2<K, V> kv1, Tuple2<K, V> kv2) => _kOrder.order(kv1.value1, kv2.value1);

  @override bool operator ==(other) => other is _IMapOrder && _kOrder == other._kOrder;
}

class IMap<K, V> extends TraversableOps<IMap, V> {
  final AVLTree<Tuple2<K, V>> _tree;

  static Order<Tuple2> _imapOrder(Order kOrder) => new _IMapOrder(kOrder);

  IMap(this._tree);

  IMap.empty(): _tree = new AVLTree<Tuple2<K, V>>(_imapOrder(comparableOrder), none);

  IMap.emptyWithOrder(Order<K> kOrder): _tree = new AVLTree<Tuple2<K, V>>(_imapOrder(kOrder), none);

  factory IMap.from(Map<K, V> m) => m.keys.fold(new IMap.empty(), (IMap<K, V> p, K k) => p.put(k, m[k]));

  factory IMap.fromWithOrder(Order<K> kOrder, Map<K, V> m) => m.keys.fold(new IMap.emptyWithOrder(kOrder), (IMap<K, V> p, K k) => p.put(k, m[k]));

  IMap<K, V> put(K k, V v) => new IMap(_tree.insert(tuple2(k, v)));

  Option<V> get(K k) => _tree.get(tuple2(k, null)).map((t) => t.value2); // mea culpa...

  IMap<K, V> remove(K k) => new IMap(_tree.remove(tuple2(k, null))); // mea maxima culpa...

  IList<K> keys() => _tree.foldRight(Nil, (kv, p) => new Cons(kv.value1, p));

  IList<K> values() => _tree.foldRight(Nil, (kv, p) => new Cons(kv.value2, p));

  IList<Tuple2<K, V>> pairs() => _tree.toIList();

  @override traverse(Applicative gApplicative, f(V v)) =>
      _tree.foldLeft(gApplicative.pure(
          new IMap(new AVLTree<Tuple2<K, V>>(_tree._order, none))),
          (prev, Tuple2<K, V> kv) => gApplicative.map2(prev, f(kv.value2), (IMap p, v) => p.put(kv.value1, v)));

  Map<K, V> toMap() => pairs().foldLeft(new Map<K, V>(), (Map<K, V> p, Tuple2<K, V> kv) {
    p[kv.value1] = kv.value2;
    return p;
  });

  @override bool operator ==(other) => other is IMap && _tree == other._tree;

  @override String toString() => "IMap<${_tree.toString()}>";
}

IMap imap(Map m) => new IMap.from(m);
IMap imapWithOrder(Order o, Map m) => new IMap.fromWithOrder(o, m);

class IMapMonoid<K, V> extends Monoid<IMap<K, V>> {
  final Semigroup<V> _vSemigroup;

  IMapMonoid(this._vSemigroup);

  @override IMap<K, V> zero() => new IMap<K, V>.empty();
  @override IMap<K, V> append(IMap<K, V> m1, IMap<K, V> m2) =>
      m2.pairs().foldLeft(m1, (IMap<K, V> p, Tuple2<K, V> kv) =>
          m1.get(kv.value1).fold(() =>
              p.put(kv.value1, kv.value2),
              (m1v) => p.put(kv.value1, _vSemigroup.append(m1v, kv.value2))));
}

Monoid<IMap> imapMonoid(Semigroup si) => new IMapMonoid(si);

final Monoid<IMap> IMapMi = imapMonoid(secondSemigroup);

final Traversable<IMap> IMapTr = new TraversableOpsTraversable<IMap>();
