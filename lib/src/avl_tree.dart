part of dartz;

// Not technically stack safe

// TODO: naive implementation. does too much work and too many allocations.

class AVLTree<A> extends FoldableOps<AVLTree, A> {
  final Order<A> _order;
  final Option<AVLNode> _root;

  AVLTree(this._order, this._root);

  AVLTree<A> insert(A a) => _root.fold(() => new AVLTree(_order, some(new AVLNode(a, none, none))), (r) => new AVLTree(_order, some(r.insert(_order, a))));

  AVLTree<A> remove(A a) => _root.fold(() => this, (r) => new AVLTree(_order, r.remove(_order, a)));

  @override foldLeft(z, f(previous, A a)) => _root.fold(() => z, (r) => r.foldLeft(z, f));

  @override foldRight(z, f(A a, previous)) => _root.fold(() => z, (r) => r.foldRight(z, f));

  @override foldMap(Monoid bMonoid, f(A a)) => foldLeft(bMonoid.zero(), (p, a) => bMonoid.append(p, f(a)));

  factory AVLTree.fromIList(Order<A> order, IList<A> l) => l.foldLeft(new AVLTree<A>(order, none), (AVLTree<A> tree, A a) => tree.insert(a));

  IList<A> toIList() => foldRight(Nil, (A a, IList<A> p) => new Cons(a, p));

  Option<A> get(A a) => _root >= (r) => r.get(_order, a);

  Option<A> min() => _root.map((r) => r.min());

  Option<A> max() => _root.map((r) => r.max());

  @override bool operator ==(other) => other is AVLTree<A> && _order == other._order && toIList() == other.toIList();

  @override String toString() => toIList().toString();
}

class AVLNode<A> {
  final A _a;
  final int _height;
  final int _balance;
  final Option<AVLNode> _left;
  final Option<AVLNode> _right;

  AVLNode(this._a, Option<AVLNode> left, Option<AVLNode> right)
      : _height = IntOrder.max(left.fold(() => -1, (l) => l._height), right.fold(() => -1, (r) => r._height)) + 1,
        _balance = right.fold(() => -1, (r) => r._height) - left.fold(() => -1, (l) => l._height),
        _left = left,
        _right = right;

  AVLNode<A> insert(Order<A> order, A a) {
    final Ordering o = order.order(a, _a);
    if (o == Ordering.LT) {
      final AVLNode<A> newLeft = _left.fold(() => new AVLNode(a, none, none), (l) => l.insert(order, a));
      return new AVLNode(_a, some(newLeft), _right)._rebalance();
    } else if (o == Ordering.GT) {
      final AVLNode<A> newRight = _right.fold(() => new AVLNode(a, none, none), (r) => r.insert(order, a));
      return new AVLNode(_a, _left, some(newRight))._rebalance();
    } else {
      return new AVLNode(a, _left, _right);
    }
  }

  Option<AVLNode<A>> remove(Order<A> order, A a) {
    final Ordering o = order.order(a, _a);
    if (o == Ordering.LT) {
      return some(new AVLNode(_a, _left >= (l) => l.remove(order, a), _right)._rebalance());
    } else if (o == Ordering.GT) {
      return some(new AVLNode(_a, _left, _right >= (r) => r.remove(order, a))._rebalance());
    } else {
      final Option<Tuple2<Option<AVLNode<A>>, A>> leftResult = _left.map((l) => l._removeMax());
      return leftResult.fold(() => _right,
          (lr) {
            return some(new AVLNode(lr.value2, lr.value1, _right)._rebalance());
          });
    }
  }

  Tuple2<Option<AVLNode<A>>, A> _removeMax() => _right.fold(() => tuple2(_left, _a),
      (r) {
        final Tuple2<Option<AVLNode<A>>, A> rightResult = r._removeMax();
        return tuple2(some(new AVLNode(_a, _left, rightResult.value1)._rebalance()), rightResult.value2);
      });

  AVLNode<A> _rebalance() {
    if (_balance < -1) {
      final AVLNode<A> l = _left | null; // TODO: sloppy
      if (l._balance < 0) {
        return llRotate(l);
      } else {
        return doubleLrRotate(l);
      }
    } else if (_balance > 1) {
      final AVLNode<A> r = _right | null; // TODO: sloppy
      if (r._balance > 0) {
        return rrRotate(r);
      } else {
        return doubleRlRotate(r);
      }
    } else {
      return this;
    }
  }

  AVLNode<A> llRotate(AVLNode<A> l) => new AVLNode<A>(l._a, l._left, some(new AVLNode(_a, l._right, _right)));

  AVLNode<A> doubleLrRotate(AVLNode<A> l) => llRotate(l.rrRotate(l._right | null)); // TODO: sloppy

  AVLNode<A> rrRotate(AVLNode<A> r) => new AVLNode<A>(r._a, some(new AVLNode(_a, _left, r._left)), r._right);

  AVLNode<A> doubleRlRotate(AVLNode<A> r) => rrRotate(r.llRotate(r._left | null)); // TODO: sloppy

  foldLeft(z, f(previous, A a)) {
    final leftResult = _left.fold(() => z, (l) => l.foldLeft(z, f));
    final midResult = f(leftResult, _a);
    return _right.fold(() => midResult, (r) => r.foldLeft(midResult, f));
  }

  foldRight(z, f(A a, previous)) {
    final rightResult = _right.fold(() => z, (r) => r.foldRight(z, f));
    final midResult = f(_a, rightResult);
    return _left.fold(() => midResult, (l) => l.foldRight(midResult, f));
  }

  Option<A> get(Order<A> order, A a) {
    final Ordering o = order.order(a, _a);
    if (o == Ordering.EQ) {
      return some(_a);
    } else if (o == Ordering.LT) {
      return _left.fold(() => none, (l) => l.get(order, a));
    } else {
      return _right.fold(() => none, (r) => r.get(order, a));
    }
  }

  A min() => _left.fold(() => _a, (l) => l.min());

  A max() => _right.fold(() => _a, (r) => r.max());

}

class AVLTreeMonoid<A> extends Monoid<AVLTree<A>> {
  final Order<A> _tOrder;

  AVLTreeMonoid(this._tOrder);

  @override AVLTree<A> zero() => new AVLTree<A>(_tOrder, none);

  @override AVLTree<A> append(AVLTree<A> a1, AVLTree<A> t2) => t2.foldLeft(a1, (AVLTree<A> p, A a) => p.insert(a));
}

final Foldable<AVLTree> AVLTreeFo = new FoldableOpsFoldable<AVLTree>();
