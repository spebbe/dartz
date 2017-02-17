part of dartz;

// NOTE: IHashMap is backed by an AVL tree, not by a traditional hash table, so lookup/insert is O(log n), not O(1)
//       Unlike IMap, IHashMap doesn't rely on a total ordering of keys, but instead uses hashCode and '==' to insert
//       and locate key/value pairs in balanced bucket trees,

class IHashMap<K, V> extends TraversableOps<IHashMap<K, dynamic>, V> {
  final IMap<int, IList<Tuple2<K, V>>> _map;

  IHashMap.internal(this._map);

  factory IHashMap.empty() => new IHashMap.internal(new IMap.emptyWithOrder(IntOrder));

  factory IHashMap.from(Map<K, V> m) => m.keys.fold(new IHashMap.empty(), (IHashMap<K, V> p, K k) => p.put(k, m[k]));

  Option<V> get(K k) => _map.get(k.hashCode).bind((candidates) =>
      candidates.find((candidate) => candidate.value1 == k).map((candidate) => candidate.value2));

  Option<V> operator[](K k) => get(k);

  IHashMap<K, V> put(K k, V v) => new IHashMap.internal(_map.modify(k.hashCode,
      (existing) => new Cons(tuple2(k, v), existing.filter((kv) => kv.value1 != k)),
      new Cons(tuple2(k, v), nil())));

  IHashMap<K, V> remove(K k) => new IHashMap.internal(_map.modify(k.hashCode,
      (existing) => existing.filter((kv) => kv.value1 != k),
      nil()));

  IHashMap<K, V> modify(K k, V f(V v), V dflt) => new IHashMap.internal(_map.modify(k.hashCode,
      (existing) => existing
          .find((kv) => kv.value1 == k)
          .fold(() => cons(tuple2(k, dflt), existing), (_) => existing.map((kv) => kv.value1 == k ? tuple2(kv.value1, f(kv.value2)) : kv)),
      new Cons(tuple2(k, dflt), nil())));

  Option<IHashMap<K, V>> set(K k, V v) => get(k).map((_) => put(k, v)); // TODO: optimize

  @override IHashMap<K, V2> map<V2>(V2 f(V v)) => new IHashMap.internal(_map.map((kvs) => kvs.map((kv) => kv.map2(f))));

  Map<K, V> toMap() => foldLeftKV(new Map(), (Map<K, V> p, K k, V v) => p..[k] = v);

  B foldLeftKV<B>(B z, B f(B previous, K k, V v)) =>
      _map.foldLeft(z, (prev, kvs) => kvs.foldLeft(prev, (pprev, kv) => f(pprev, kv.value1, kv.value2)));

  B foldRightKV<B>(B z, B f(K k, V v, B previous)) =>
      _map.foldRight(z, (kvs, prev) => kvs.foldRight(prev, (kv, pprev) => f(kv.value1, kv.value2, pprev)));

  @override B foldLeft<B>(B z, B f(B previous, V v)) =>
      _map.foldLeft(z, (prev, kvs) => kvs.foldLeft(prev, (pprev, kv) => f(pprev, kv.value2)));

  @override B foldRight<B>(B z, B f(V v, B previous)) =>
      _map.foldRight(z, (kvs, prev) => kvs.foldRight(prev, (kv, pprev) => f(kv.value2, pprev)));

  @override G traverse<G>(Applicative<G> gApplicative, G f(V v)) =>
      _map.foldLeft(gApplicative.pure(new IHashMap.empty()),
          (prev, kvs) => kvs.foldLeft(prev,
              (pprev, kv) => gApplicative.map2(pprev, f(kv.value2),
                  (p, v2) => p.put(kv.value1, v2))));

  @override String toString() => "ihashmap{${_map.foldMap(IListMi, (kvs) => kvs.map((kv) => "${kv.value1}: ${kv.value2}")).intercalate(StringMi, ", ")}}";
  @override bool operator ==(other) => identical(this, other) || (other is IHashMap && _map == other._map);
  @override int get hashCode => _map.hashCode;

  // PURISTS BEWARE: mutable Iterable/Iterator integrations below -- proceed with caution!

  Iterable<Tuple2<K, V>> pairIterable() => _map.valueIterable().expand((tuples) => tuples.toIterable());

  Iterator<Tuple2<K, V>> pairIterator() => pairIterable().iterator;

  Iterable<K> keyIterable() => pairIterable().map((t) => t.value1);

  Iterator<K> keyIterator() => keyIterable().iterator;

  Iterable<V> valueIterable() => pairIterable().map((t) => t.value2);

  Iterator<V> valueIterator() => valueIterable().iterator;

  Iterable<Tuple2<K, V>> toIterable() => pairIterable();

  Iterator<Tuple2<K, V>> iterator() => pairIterator();
}

final Traversable<IHashMap> IHashMapTr = new TraversableOpsTraversable<IHashMap>();

IHashMap<K, V> ihashmap<K, V>(Map<K, V> m) => new IHashMap.from(m);
