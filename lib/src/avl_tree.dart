part of dartz;

// Not technically stack safe

// TODO: naive implementation. does too much work and too many allocations.

class AVLTree<A> implements FoldableOps<AVLTree, A> {
  final Order<A> _order;
  final _AVLNode<A> _root;

  AVLTree(this._order, this._root);

  AVLTree<A> insert(A a) => new AVLTree(_order, _root.insert(_order, a));

  AVLTree<A> remove(A a) => new AVLTree(_order, _root.remove(_order, a));

  @override B foldLeft<B>(B z, B f(B previous, A a)) => _root.foldLeft(z, f);

  B foldLeftBetween<B>(A minA, A maxA, B z, B f(B previous, A a)) => _root.foldLeftBetween(_order, minA, maxA, z, f);

  @override B foldRight<B>(B z, B f(A a, B previous)) => _root.foldRight(z, f);

  B foldRightBetween<B>(A minA, A maxA, B z, B f(A a, B previous)) => _root.foldRightBetween(_order, minA, maxA, z, f);

  @override B foldMap<B>(Monoid<B> bMonoid, B f(A a)) => foldLeft(bMonoid.zero(), (p, a) => bMonoid.append(p, f(a)));

  factory AVLTree.fromIList(Order<A> order, IList<A> l) => l.foldLeft(new AVLTree(order, emptyAVLNode()), (tree, A a) => tree.insert(a));

  IList<A> toIList() => foldRight(nil(), (A a, IList<A> p) => new Cons(a, p));

  Option<A> get(A a) => _root.get(_order, a);

  Option<A> min() => _root.min();

  Option<A> max() => _root.max();

  @override bool operator ==(other) => identical(this, other) || (other is AVLTree && _order == other._order && ObjectIteratorEq.eq(iterator(), other.iterator()));

  @override int get hashCode => _order.hashCode ^ toIList().hashCode;

  @override String toString() => 'avltree<${toIList()}>';

  @override bool all(bool f(A a)) => foldMap(BoolAndMi, f); // TODO: optimize
  @override bool every(bool f(A a)) => all(f);

  @override bool any(bool f(A a)) => foldMap(BoolOrMi, f); // TODO: optimize

  @override A concatenate(Monoid<A> mi) => foldMap(mi, id); // TODO: optimize

  @override Option<A> concatenateO(Semigroup<A> si) => foldMapO(si, id); // TODO: optimize

  @override B foldLeftWithIndex<B>(B z, B f(B previous, int i, A a)) =>
    foldLeft<Tuple2<B, int>>(tuple2(z, 0), (t, a) => tuple2(f(t.value1, t.value2, a), t.value2+1)).value1; // TODO: optimize

  @override Option<B> foldMapO<B>(Semigroup<B> si, B f(A a)) =>
    foldMap(new OptionMonoid(si), composeF(some, f)); // TODO: optimize

  @override B foldRightWithIndex<B>(B z, B f(int i, A a, B previous)) =>
    foldRight<Tuple2<B, int>>(tuple2(z, length()-1), (a, t) => tuple2(f(t.value2, a, t.value1), t.value2-1)).value1; // TODO: optimize

  @override A intercalate(Monoid<A> mi, A a) =>
    foldRight(none<A>(), (A ca, Option<A> oa) => some(mi.append(ca, oa.fold(mi.zero, mi.appendC(a))))) | mi.zero(); // TODO: optimize

  @override int length() => foldLeft(0, (a, b) => a+1); // TODO: optimize

  @override Option<A> maximum(Order<A> oa) => concatenateO(oa.maxSi());

  @override Option<A> minimum(Order<A> oa) => concatenateO(oa.minSi());


  // PURISTS BEWARE: side effecty stuff below -- proceed with caution!

  Iterable<A> toIterable() => new _AVLTreeIterable(this);

  Iterator<A> iterator() => toIterable().iterator;

  void forEach(void sideEffect(A a)) => foldLeft(null, (_, a) => sideEffect(a));
}

abstract class _AVLNode<A> {
  const _AVLNode();

  _AVLNode<A> insert(Order<A> order, A a);
  _AVLNode<A> remove(Order<A> order, A a);
  B foldLeft<B>(B z, B f(B previous, A a));
  B foldLeftBetween<B>(Order<A> order, A minA, A maxA, B z, B f(B previous, A a));
  B foldRight<B>(B z, B f(A a, B previous));
  B foldRightBetween<B>(Order<A> order, A minA, A maxA, B z, B f(A a, B previous));
  Option<A> get(Order<A> order, A a);
  Option<A> min();
  Option<A> max();
  int get height;
  int get balance;
  Option<Tuple2<_AVLNode<A>, A>> _removeMax();
  bool get empty;
  _NonEmptyAVLNode<A> _unsafeGetNonEmpty();
}

class _NonEmptyAVLNode<A> extends _AVLNode<A> {
  final A _a;
  final int _height;
  int get height => _height;
  int get balance => _right.height - _left.height;
  final _AVLNode<A> _left;
  final _AVLNode<A> _right;

  _NonEmptyAVLNode(this._a, _AVLNode<A> left, _AVLNode<A> right)
      : _height = (left.height > right.height) ? left.height+1 : right.height+1,
        _left = left,
        _right = right;

  _AVLNode<A> insert(Order<A> order, A a) {
    final Ordering o = order.order(a, _a);
    if (o == Ordering.LT) {
      final newLeft = _left.insert(order, a);
      return new _NonEmptyAVLNode(_a, newLeft, _right)._rebalance();
    } else if (o == Ordering.GT) {
      final newRight = _right.insert(order, a);
      return new _NonEmptyAVLNode(_a, _left, newRight)._rebalance();
    } else {
      return new _NonEmptyAVLNode(a, _left, _right);
    }
  }

  _AVLNode<A> remove(Order<A> order, A a) {
    final Ordering o = order.order(a, _a);
    if (o == Ordering.LT) {
      return new _NonEmptyAVLNode(_a, _left.remove(order, a), _right)._rebalance();
    } else if (o == Ordering.GT) {
      return new _NonEmptyAVLNode(_a, _left, _right.remove(order, a))._rebalance();
    } else {
      return _left._removeMax().fold(() => _right, (lr) => new _NonEmptyAVLNode(lr.value2, lr.value1, _right)._rebalance());
    }
  }

  Option<Tuple2<_AVLNode<A>, A>> _removeMax() =>
      _right._removeMax().fold(() => some(tuple2(_left, _a)),
          (rightResult) => some(tuple2(new _NonEmptyAVLNode(_a, _left, rightResult.value1)._rebalance(), rightResult.value2)));

  _AVLNode<A> _rebalance() {
    final b = balance;
    if (b < -1) {
      if (_left.balance < 0) {
        return llRotate(_left._unsafeGetNonEmpty());
      } else {
        return doubleLrRotate(_left._unsafeGetNonEmpty());
      }
    } else if (b > 1) {
      if (_right.balance > 0) {
        return rrRotate(_right._unsafeGetNonEmpty());
      } else {
        return doubleRlRotate(_right._unsafeGetNonEmpty());
      }
    } else {
      return this;
    }
  }

  _NonEmptyAVLNode<A> llRotate(_NonEmptyAVLNode<A> l) => new _NonEmptyAVLNode(l._a, l._left, new _NonEmptyAVLNode(_a, l._right, _right));

  _NonEmptyAVLNode<A> doubleLrRotate(_NonEmptyAVLNode<A> l) => llRotate(l.rrRotate(l._right._unsafeGetNonEmpty()));

  _NonEmptyAVLNode<A> rrRotate(_NonEmptyAVLNode<A> r) => new _NonEmptyAVLNode(r._a, new _NonEmptyAVLNode(_a, _left, r._left), r._right);

  _NonEmptyAVLNode<A> doubleRlRotate(_NonEmptyAVLNode<A> r) => rrRotate(r.llRotate(r._left._unsafeGetNonEmpty()));

  B foldLeft<B>(B z, B f(B previous, A a)) {
    final leftResult = _left.foldLeft(z, f);
    final midResult = f(leftResult, _a);
    return _right.foldLeft(midResult, f);
  }

  B foldLeftBetween<B>(Order<A> order, A minA, A maxA, B z, B f(B previous, A a)) {
    if (order.lt(_a, minA)) {
      return _right.foldLeftBetween(order, minA, maxA, z, f);
    } else if (order.gt(_a, maxA)) {
      return _left.foldLeftBetween(order, minA, maxA, z, f);
    } else {
      final leftResult = _left.foldLeftBetween(order, minA, maxA, z, f);
      final midResult = f(leftResult, _a);
      return _right.foldLeftBetween(order, minA, maxA, midResult, f);
    }
  }

  B foldRight<B>(B z, B f(A a, B previous)) {
    final rightResult =_right.foldRight(z, f);
    final midResult = f(_a, rightResult);
    return _left.foldRight(midResult, f);
  }

  B foldRightBetween<B>(Order<A> order, A minA, A maxA, B z, B f(A a, B previous)) {
    if (order.lt(_a, minA)) {
      return _right.foldRightBetween(order, minA, maxA, z, f);
    } else if (order.gt(_a, maxA)) {
      return _left.foldRightBetween(order, minA, maxA, z, f);
    } else {
      final rightResult = _right.foldRightBetween(order, minA, maxA, z, f);
      final midResult = f(_a, rightResult);
      return _left.foldRightBetween(order, minA, maxA, midResult, f);
    }
  }


  Option<A> get(Order<A> order, A a) {
    _NonEmptyAVLNode<A> current = this;
    while(!current.empty) {
      final Ordering o = order.order(a, current._a);
      if (o == Ordering.EQ) {
        return some(current._a);
      } else if (o == Ordering.LT) {
        final l = current._left._unsafeGetNonEmpty();
        if (l != null) {
          current = l;
        } else {
          return none();
        }
      } else {
        final r = current._right._unsafeGetNonEmpty();
        if (r != null) {
          current = r;
        } else {
          return none();
        }
      }
    }
    return none();
  }

  Option<A> min() => _left is _EmptyAVLNode ? some(_a) : _left.min();

  Option<A> max() => _right is _EmptyAVLNode ? some(_a) : _right.max();

  bool get empty => false;

  _NonEmptyAVLNode<A> _unsafeGetNonEmpty() => this;
}

class _EmptyAVLNode<A> extends _AVLNode<A> {
  const _EmptyAVLNode();

  @override B foldLeft<B>(B z, B f(B previous, A a)) => z;

  @override B foldLeftBetween<B>(Order<A> order, A minA, A maxA, B z, B f(B previous, A a)) => z;

  @override B foldRight<B>(B z, B f(A a, B previous)) => z;

  @override B foldRightBetween<B>(Order<A> order, A minA, A maxA, B z, B f(A a, B previous)) => z;

  @override Option<A> get(Order<A> order, A a) => none();

  @override _AVLNode<A> insert(Order<A> order, A a) => new _NonEmptyAVLNode(a, emptyAVLNode(), emptyAVLNode());

  @override Option<A> max() => none();

  @override Option<A> min() => none();

  @override _AVLNode<A> remove(Order<A> order, A a) => this;

  @override int get height => -1;

  @override int get balance => 0;

  @override Option<Tuple2<_AVLNode<A>, A>> _removeMax() => none();

  @override operator ==(other) => other is _EmptyAVLNode;

  @override int get hashCode => 0;

  bool get empty => true;

  _NonEmptyAVLNode<A> _unsafeGetNonEmpty() => null;
}

_AVLNode<A> emptyAVLNode<A>() => new _EmptyAVLNode();

class AVLTreeMonoid<A> extends Monoid<AVLTree<A>> {
  final Order<A> _tOrder;

  AVLTreeMonoid(this._tOrder);

  @override AVLTree<A> zero() => new AVLTree<A>(_tOrder, emptyAVLNode());

  @override AVLTree<A> append(AVLTree<A> a1, AVLTree<A> t2) => t2.foldLeft(a1, (p, a) => p.insert(a));
}

final Foldable<AVLTree> AVLTreeFo = new FoldableOpsFoldable<AVLTree>();

class _AVLTreeIterable<A> extends Iterable<A> {
  final AVLTree<A> _tree;
  _AVLTreeIterable(this._tree);
  @override Iterator<A> get iterator => new _AVLTreeIterator(_tree._root._unsafeGetNonEmpty());
}

class _AVLTreeIterator<A> extends Iterator<A> {

  bool _started = false;
  _NonEmptyAVLNode<A> _currentNode = null;
  IList<_NonEmptyAVLNode<A>> _path = nil();

  _AVLTreeIterator(this._currentNode);

  @override A get current => _currentNode != null ? _currentNode._a : null;

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
      _currentNode = _currentNode._right._unsafeGetNonEmpty();
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
        final _NonEmptyAVLNode<A> cl = currentLeft._unsafeGetNonEmpty();
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