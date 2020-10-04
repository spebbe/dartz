part of dartz;

// When possible, use ISet instead. ISet offers superior performance, a richer API and clearer iteration/equality semantics.

// NOTE: IHashSet is backed by an AVL tree, not by a traditional hash table, so lookup/insert is O(log n), not O(1).
//       Unlike ISet, IHashSet doesn't rely on a total ordering of keys, but instead uses hashCode and '==' to insert
//       and locate key/value pairs in balanced bucket trees.

class IHashSet<A> implements FoldableOps<IHashSet, A> {
  final IHashMap<A, Unit> _map;

  IHashSet(this._map);

  factory IHashSet.empty() => new IHashSet(new IHashMap.empty());
  factory IHashSet.fromIList(IList<A> l) => new IHashSet(l.foldLeft(new IHashMap.empty(), (acc, a) => acc.put(a, unit)));
  factory IHashSet.fromIterable(Iterable<A> l) => new IHashSet(l.fold(new IHashMap.empty(), (acc, a) => acc.put(a, unit)));

  IHashSet<A> insert(A a) => new IHashSet(_map.put(a, unit));

  IHashSet<A> remove(A a) => new IHashSet(_map.remove(a));

  bool contains(A a) => _map[a].isSome();

  IHashSet<A> union(IHashSet<A> other) => new IHashSet(other._map.foldLeftKV(_map, (p, a, _) => p.put(a, unit)));
  IHashSet<A> operator |(IHashSet<A> other) => union(other);
  IHashSet<A> operator +(IHashSet<A> other) => union(other);

  IHashSet<A> intersection(IHashSet<A> other) => new IHashSet(other._map.foldLeftKV(new IHashMap.empty(), (p, a, _) => contains(a) ? p.put(a, unit) : p));
  IHashSet<A> operator &(IHashSet<A> other) => intersection(other);

  IHashSet<A> difference(IHashSet<A> other) => new IHashSet(other._map.foldLeftKV(_map, (p, A a, _) => p.remove(a)));
  IHashSet<A> operator -(IHashSet<A> other) => difference(other);

  IList<A> toIList() => ilist(_map.keyIterable());

  IHashSet<B> transform<B>(B f(A a)) => foldLeft(new IHashSet.empty(), (acc, a) => acc.insert(f(a)));

  IHashSet<A> filter(bool predicate(A a)) => foldLeft(this, (acc, a) => predicate(a) ? acc : acc.remove(a));
  IHashSet<A> where(bool predicate(A a)) => filter(predicate);

  Tuple2<IHashSet<A>, IHashSet<A>> partition(bool f(A a)) =>
    foldLeft(tuple2(new IHashSet.empty(), new IHashSet.empty()),
        (acc, a) => f(a)
        ? acc.map1((s1) => s1.insert(a))
        : acc.map2((s2) => s2.insert(a)));

  bool get isEmpty => _map.isEmpty;

  @override bool operator ==(Object other) => identical(this, other) || (other is IHashSet && _map == other._map);

  @override int get hashCode => _map.hashCode;

  @override String toString() => "ihashset<${toIList().map((a) => a.toString()).intercalate(StringMi, ", ")}>";


  @override
  bool all(bool Function(A a) f) => foldMap(BoolAndMi, f); // TODO: optimize

  @override
  bool any(bool Function(A a) f) => foldMap(BoolOrMi, f); // TODO: optimize

  @override
  A concatenate(Monoid<A> mi) => foldMap(mi, id); // TODO: optimize

  @override
  Option<A> concatenateO(Semigroup<A> si) => foldMapO(si, id); // TODO: optimize

  @override
  bool every(bool Function(A a) f) => all(f);

  @override
  B foldLeft<B>(B z, B Function(B previous, A a) f) =>
    _map.foldLeftKV(z, (previous, a, _) => f(previous, a));

  @override
  B foldLeftWithIndex<B>(B z, B Function(B previous, int i, A a) f)  =>
    foldLeft<Tuple2<B, int>>(tuple2(z, 0), (t, a) => tuple2(f(t.value1, t.value2, a), t.value2+1)).value1; // TODO: optimize


  @override
  B foldMap<B>(Monoid<B> bMonoid, B Function(A a) f) => foldLeft(bMonoid.zero(), (acc, a) => bMonoid.append(acc, f(a)));

  @override
  Option<B> foldMapO<B>(Semigroup<B> si, B Function(A a) f) =>
    foldMap(new OptionMonoid(si), composeF(some, f)); // TODO: optimize

  @override
  B foldRight<B>(B z, B Function(A a, B previous) f) =>
    _map.foldRightKV(z, (a, _, previous) => f(a, previous));

  @override
  B foldRightWithIndex<B>(B z, B Function(int i, A a, B previous) f) =>
    foldRight<Tuple2<B, int>>(tuple2(z, length()-1), (a, t) => tuple2(f(t.value2, a, t.value1), t.value2-1)).value1; // TODO: optimize

  @override
  A intercalate(Monoid<A> mi, A a) =>
    foldRight(none<A>(), (A ca, Option<A> oa) => some(mi.append(ca, oa.fold(mi.zero, mi.appendC(a))))) | mi.zero(); // TODO: optimize

  @override
  int length() => foldLeft(0, (a, b) => a+1); // TODO: optimize

  @override
  Option<A> maximum(Order<A> oa) => concatenateO(oa.maxSi());

  @override
  Option<A> minimum(Order<A> oa)  => concatenateO(oa.minSi());

  // PURISTS BEWARE: side effecty stuff below -- proceed with caution!

  Iterable<A> toIterable() => _map.keyIterable();

  Iterator<A> iterator() => _map.keyIterator();

  void forEach(void sideEffect(A a)) => foldLeft(null, (_, a) => sideEffect(a));

}

IHashSet<A> ihashset<A>(Iterable<A> i) => new IHashSet.fromIterable(i);
