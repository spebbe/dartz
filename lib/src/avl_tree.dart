part of dartz;

// Not technically stack safe

// TODO: naive implementation. does too much work and too many allocations.

class AVLTree<A> extends FoldableOps<AVLTree, A> {
  final Order<A> _order;
  final _AVLNode<A> _root;

  AVLTree(this._order, this._root);

  AVLTree<A> insert(A a) => new AVLTree(_order, _root.insert(_order, a));

  AVLTree<A> remove(A a) => new AVLTree(_order, _root.remove(_order, a));

  @override B foldLeft<B>(B z, B f(B previous, A a)) => _root.foldLeft(z, f);

  @override B foldRight<B>(B z, B f(A a, B previous)) => _root.foldRight(z, f);

  @override B foldMap<B>(Monoid<B> bMonoid, B f(A a)) => foldLeft(bMonoid.zero(), (p, a) => bMonoid.append(p, f(a)));

  factory AVLTree.fromIList(Order<A> order, IList<A> l) => l.foldLeft(new AVLTree(order, emptyAVLNode()), (tree, A a) => tree.insert(a));

  IList<A> toIList() => foldRight(nil(), (A a, IList<A> p) => new Cons(a, p));

  Option<A> get(A a) => _root.get(_order, a);

  Option<A> min() => _root.min();

  Option<A> max() => _root.max();

  @override bool operator ==(other) => identical(this, other) || (other is AVLTree && _order == other._order && toIList() == other.toIList());

  @override int get hashCode => _order.hashCode ^ toIList().hashCode;

  @override String toString() => 'avltree<${toIList()}>';

  // PURISTS BEWARE: mutable Iterable/Iterator integrations below -- proceed with caution!

  Iterable<A> toIterable() => new _AVLTreeIterable(this);

  Iterator<A> iterator() => toIterable().iterator;
}

abstract class _AVLNode<A> {
  const _AVLNode();

  _AVLNode<A> insert(Order<A> order, A a);
  _AVLNode<A> remove(Order<A> order, A a);
  B foldLeft<B>(B z, B f(B previous, A a));
  B foldRight<B>(B z, B f(A a, B previous));
  Option<A> get(Order<A> order, A a);
  Option<A> min();
  Option<A> max();
  int get height;
  int get balance;
  Option<Tuple2<_AVLNode<A>, A>> _removeMax();
  bool get empty;
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

  _NonEmptyAVLNode<A> llRotate(_NonEmptyAVLNode<A> l) => new _NonEmptyAVLNode(l._a, l._left, new _NonEmptyAVLNode(_a, l._right, _right));

  _NonEmptyAVLNode<A> doubleLrRotate(_NonEmptyAVLNode<A> l) => llRotate(l.rrRotate(cast(l._right)));

  _NonEmptyAVLNode<A> rrRotate(_NonEmptyAVLNode<A> r) => new _NonEmptyAVLNode(r._a, new _NonEmptyAVLNode(_a, _left, r._left), r._right);

  _NonEmptyAVLNode<A> doubleRlRotate(_NonEmptyAVLNode<A> r) => rrRotate(r.llRotate(cast(r._left)));

  B foldLeft<B>(B z, B f(B previous, A a)) {
    final leftResult = _left.foldLeft(z, f);
    final midResult = f(leftResult, _a);
    return _right.foldLeft(midResult, f);
  }

  B foldRight<B>(B z, B f(A a, B previous)) {
    final rightResult =_right.foldRight(z, f);
    final midResult = f(_a, rightResult);
    return _left.foldRight(midResult, f);
  }

  Option<A> get(Order<A> order, A a) {
    var current = this;
    while(!current.empty) {
      final Ordering o = order.order(a, current._a);
      if (o == Ordering.EQ) {
        return some(current._a);
      } else if (o == Ordering.LT) {
        current = cast(current._left);
      } else {
        current = cast(current._right);
      }
    }
    return none();
  }

  Option<A> min() => _left == _emptyAVLNode ? some(_a) : _left.min();

  Option<A> max() => _right == _emptyAVLNode ? some(_a) : _right.max();

  bool get empty => false;
}

class _EmptyAVLNode<A> extends _AVLNode<A> {
  const _EmptyAVLNode();

  @override B foldLeft<B>(B z, B f(B previous, A a)) => z;

  @override B foldRight<B>(B z, B f(A a, B previous)) => z;

  @override Option<A> get(Order<A> order, A a) => none();

  @override _AVLNode<A> insert(Order<A> order, A a) => new _NonEmptyAVLNode(a, emptyAVLNode(), emptyAVLNode());

  @override Option<A> max() => none();

  @override Option<A> min() => none();

  @override _AVLNode<A> remove(Order<A> order, A a) => this;

  @override int get height => -1;

  @override int get balance => 0;

  @override Option<Tuple2<_AVLNode<A>, A>> _removeMax() => none();

  @override operator ==(other) => identical(_emptyAVLNode, other);

  @override int get hashCode => 0;

  bool get empty => true;
}

_AVLNode _emptyAVLNode = const _EmptyAVLNode();
_AVLNode<A> emptyAVLNode<A>() => cast(_emptyAVLNode);

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
  @override Iterator<A> get iterator => _tree._root.empty ? new _AVLTreeIterator(null) : new _AVLTreeIterator(cast(_tree._root));
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
        final _NonEmptyAVLNode<A> cl = cast(currentLeft);
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