// ignore_for_file: unnecessary_new

part of dartz;

// NOTE: IHashMap is backed by an AVL tree, not by a traditional hash table, so lookup/insert is O(log n), not O(1)
//       Unlike IMap, IHashMap doesn't rely on a total ordering of keys, but instead uses hashCode and '==' to insert
//       and locate key/value pairs in balanced bucket trees,

class IHashMap<K, V> implements TraversableOps<IHashMap<K, dynamic>, V> {
  final IMap<int, IList<Tuple2<K, V>>> _map;

  IHashMap.internal(this._map);

  factory IHashMap.empty() => new IHashMap.internal(new IMap.empty(IntOrder));

  factory IHashMap.from(Map<K, V> m) => m.keys.fold(new IHashMap.empty(), (IHashMap<K, V> p, K k) => p.put(k, m[k]));

  factory IHashMap.fromPairs(FoldableOps<dynamic, Tuple2<K, V>> foldableOps, Order<K> kOrder) =>
    foldableOps.foldLeft(new IHashMap.empty(), (acc, kv) => kv.apply(acc.put));

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

  Map<K, V> toMap() => foldLeftKV(new Map(), (p, K k, V v) => p..[k] = v);

  B foldLeftKV<B>(B z, B f(B previous, K k, V v)) =>
      _map.foldLeft(z, (prev, kvs) => kvs.foldLeft(prev, (pprev, kv) => f(pprev, kv.value1, kv.value2)));

  B foldRightKV<B>(B z, B f(K k, V v, B previous)) =>
      _map.foldRight(z, (kvs, prev) => kvs.foldRight(prev, (kv, pprev) => f(kv.value1, kv.value2, pprev)));

  @override B foldLeft<B>(B z, B f(B previous, V v)) =>
      _map.foldLeft(z, (prev, kvs) => kvs.foldLeft(prev, (pprev, kv) => f(pprev, kv.value2)));

  @override B foldRight<B>(B z, B f(V v, B previous)) =>
      _map.foldRight(z, (kvs, prev) => kvs.foldRight(prev, (kv, pprev) => f(kv.value2, pprev)));

  @override String toString() => "ihashmap{${_map.foldMap(IListMi, (kvs) => kvs.map((kv) => "${kv.value1}: ${kv.value2}")).intercalate(StringMi, ", ")}}";
  @override bool operator ==(other) => identical(this, other) || (other is IHashMap && _map == other._map);
  @override int get hashCode => _map.hashCode;

  // PURISTS BEWARE: side effecty stuff below -- proceed with caution!

  Iterable<Tuple2<K, V>> pairIterable() => _map.valueIterable().expand((tuples) => tuples.toIterable());

  Iterator<Tuple2<K, V>> pairIterator() => pairIterable().iterator;

  Iterable<K> keyIterable() => pairIterable().map((t) => t.value1);

  Iterator<K> keyIterator() => keyIterable().iterator;

  Iterable<V> valueIterable() => pairIterable().map((t) => t.value2);

  Iterator<V> valueIterator() => valueIterable().iterator;

  Iterable<Tuple2<K, V>> toIterable() => pairIterable();

  Iterator<Tuple2<K, V>> iterator() => pairIterator();

  void forEach(void sideEffect(V v)) => foldLeft(null, (_, v) => sideEffect(v));

  void forEachKV(void sideEffect(K k, V v)) => foldLeftKV(null, (_, k, v) => sideEffect(k, v));

  @override B foldMap<B>(Monoid<B> bMonoid, B f(V a)) => _map.foldMap(bMonoid, (kvs) => kvs.foldMap(bMonoid, (t) => f(t.value2)));

  @override IHashMap<K, B> mapWithIndex<B>(B f(int i, V a)) => throw "not implemented!!!"; // TODO

  @override IHashMap<K, Tuple2<int, V>> zipWithIndex() => mapWithIndex(tuple2);

  @override bool all(bool f(V a)) => foldMap(BoolAndMi, f); // TODO: optimize

  @override bool any(bool f(V a)) => foldMap(BoolOrMi, f); // TODO: optimize

  @override V concatenate(Monoid<V> mi) => foldMap(mi, id); // TODO: optimize

  @override Option<V> concatenateO(Semigroup<V> si) => foldMapO(si, id); // TODO: optimize

  @override B foldLeftWithIndex<B>(B z, B f(B previous, int i, V a)) =>
    foldLeft<Tuple2<B, int>>(tuple2(z, 0), (t, a) => tuple2(f(t.value1, t.value2, a), t.value2+1)).value1; // TODO: optimize

  @override Option<B> foldMapO<B>(Semigroup<B> si, B f(V a)) =>
    foldMap(new OptionMonoid(si), composeF(some, f)); // TODO: optimize

  @override B foldRightWithIndex<B>(B z, B f(int i, V a, B previous)) =>
    foldRight<Tuple2<B, int>>(tuple2(z, length()-1), (a, t) => tuple2(f(t.value2, a, t.value1), t.value2-1)).value1; // TODO: optimize

  @override V intercalate(Monoid<V> mi, V v) =>
    foldRight(none<V>(), (V cv, Option<V> ov) => some(mi.append(cv, ov.fold(mi.zero, mi.appendC(v))))) | mi.zero(); // TODO: optimize

  @override int length() => foldLeft(0, (a, b) => a+1); // TODO: optimize

  @override Option<V> maximum(Order<V> ov) => concatenateO(ov.maxSi());

  @override Option<V> minimum(Order<V> ov) => concatenateO(ov.minSi());

  @override IHashMap<K, Tuple2<B, V>> strengthL<B>(B b) => map((v) => tuple2(b, v));

  @override IHashMap<K, Tuple2<V, B>> strengthR<B>(B b) => map((v) => tuple2(v, b));
}

final Traversable<IHashMap> IHashMapTr = new TraversableOpsTraversable<IHashMap>();

IHashMap<K, V> ihashmap<K, V>(Map<K, V> m) => new IHashMap.from(m);
