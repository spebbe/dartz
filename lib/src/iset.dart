part of dartz;

class ISet<A> {
  final AVLTree<A> _tree;

  ISet(this._tree);
  factory ISet.emptyWithOrder(Order<A> order) => new ISet(new AVLTree<A>(order, none));
  factory ISet.empty() => new ISet<A>.emptyWithOrder(comparableOrder);
  factory ISet.fromFoldableWithOrder(Order<A> order, Foldable foldable, fa) => foldable.foldLeft(fa, new ISet.emptyWithOrder(order), (p, a) => p.insert(a));
  factory ISet.fromFoldable(Foldable foldable, fa) => new ISet<A>.fromFoldableWithOrder(comparableOrder, foldable, fa);
  factory ISet.fromIListWithOrder(Order<A> order, IList<A> l) => new ISet.fromFoldableWithOrder(order, IListTr, l);
  factory ISet.fromIList(IList<A> l) => new ISet<A>.fromIListWithOrder(comparableOrder, l);

  ISet<A> insert(A a) => new ISet(_tree.insert(a));

  ISet<A> remove(A a) => new ISet(_tree.remove(a));

  bool contains(A a) => _tree.get(a) != none;

  IList<A> toIList() => _tree.toIList();

  @override bool operator ==(other) => other is ISet && _tree == other._tree;
}

ISet iset(IList l) => new ISet.fromIList(l);
