part of dartz;

class ISet<A> extends FoldableOps<ISet, A> {
  final AVLTree<A> _tree;

  ISet(this._tree);
  factory ISet.empty(Order<A> order) => new ISet(new AVLTree<A>(order, emptyAVLNode()));
  factory ISet.fromFoldable(Order<A> order, Foldable foldable, fa) => foldable.foldLeft(fa, new ISet.empty(order), (p, a) => p.insert(cast(a)));
  factory ISet.fromIList(Order<A> order, IList<A> l) => new ISet.fromFoldable(order, IListTr, l);
  factory ISet.fromIterable(Order<A> order, Iterable<A> i) => i.fold(new ISet.empty(order), (acc, a) => acc.insert(a));

  @override B foldMap<B>(Monoid<B> bMonoid, B f(A a)) => _tree.foldMap(bMonoid, f);
  @override B foldLeft<B>(B z, B f(B previous, A a)) => _tree.foldLeft(z, f);
  B foldLeftBetween<B>(A minA, A maxA, B z, B f(B previous, A a)) => _tree.foldLeftBetween(minA, maxA, z, f);
  @override B foldRight<B>(B z, B f(A a, B previous)) => _tree.foldRight(z, f);
  B foldRightBetween<B>(A minA, A maxA, B z, B f(A a, B previous)) => _tree.foldRightBetween(minA, maxA, z, f);

  ISet<A> subSetBetween(A minA, A maxA) => foldLeftBetween(minA, maxA, new ISet.empty(_tree._order), (acc, a) => acc.insert(a));

  ISet<A> insert(A a) => new ISet(_tree.insert(a));

  ISet<A> remove(A a) => new ISet(_tree.remove(a));

  bool contains(A a) => _tree.get(a) != none();

  ISet<A> union(ISet<A> other) => other._tree.foldLeft(this, (p, A a) => p.insert(a));
  ISet<A> operator |(ISet<A> other) => union(other);
  ISet<A> operator +(ISet<A> other) => union(other);

  ISet<A> intersection(ISet<A> other) => other._tree.foldLeft(new ISet.empty(_tree._order), (p, A a) => contains(a) ? p.insert(a) : p);
  ISet<A> operator &(ISet<A> other) => intersection(other);

  ISet<A> difference(ISet<A> other) => other._tree.foldLeft(this, (p, A a) => p.remove(a));
  ISet<A> operator -(ISet<A> other) => difference(other);

  IList<A> toIList() => _tree.toIList();

  ISet<B> transform<B>(Order<B> order, B f(A a)) => foldLeft(new ISet.empty(order), (acc, a) => acc.insert(f(a)));

  ISet<A> filter(bool predicate(A a)) => foldLeft(this, (acc, a) => predicate(a) ? acc : acc.remove(a));
  ISet<A> where(bool predicate(A a)) => filter(predicate);

  Tuple2<ISet<A>, ISet<A>> partition(bool f(A a)) =>
    foldLeft(tuple2(new ISet.empty(_tree._order), new ISet.empty(_tree._order)),
        (acc, a) => f(a)
          ? acc.map1((s1) => s1.insert(a))
          : acc.map2((s2) => s2.insert(a)));

  @override bool operator ==(other) => identical(this, other) || (other is ISet && _tree == other._tree);

  @override int get hashCode => _tree.hashCode;

  @override String toString() => "iset<${_tree.toIList().map((a) => a.toString()).intercalate(StringMi, ", ")}>";

  // PURISTS BEWARE: side effecty stuff below -- proceed with caution!

  Iterable<A> toIterable() => _tree.toIterable();

  Iterator<A> iterator() => _tree.iterator();

  void forEach(void sideEffect(A a)) => foldLeft(null, (_, a) => sideEffect(a));
}

final Foldable<ISet> ISetFo = new FoldableOpsFoldable<ISet>();

ISet<A> emptySet<A extends Comparable>() => new ISet.empty(comparableOrder());
ISet<A> emptySetWithOrder<A>(Order<A> order) => new ISet.empty(order);

ISet<A> iset<A extends Comparable>(Iterable<A> i) => new ISet.fromIterable(comparableOrder(), i);
ISet<A> isetWithOrder<A, A2 extends A>(Order<A> order, Iterable<A2> i) => new ISet.fromIterable(order, i);

class ISetMonoid<A> extends Monoid<ISet<A>> {
  final Order<A> _aOrder;

  ISetMonoid(this._aOrder);

  @override ISet<A> zero() => new ISet.empty(_aOrder);
  @override ISet<A> append(ISet<A> a1, ISet<A> a2) => a1.union(a2);
}

Monoid<ISet<A>> isetMi<A>(Order<A> o) => new ISetMonoid(o);
