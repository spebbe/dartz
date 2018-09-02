// ignore_for_file: unnecessary_new

part of dartz;

enum Ordering {
  LT,
  EQ,
  GT
}

abstract class Order<A> extends Eq<A> {
  Ordering order(A a1, A a2);

  bool eq(A a1, A a2) => order(a1, a2) == Ordering.EQ;

  bool lt(A a1, A a2) => order(a1, a2) == Ordering.LT;

  bool lte(A a1, A a2) => order(a1, a2) != Ordering.GT;

  bool gt(A a1, A a2) => order(a1, a2) == Ordering.GT;

  bool gte(A a1, A a2) => order(a1, a2) != Ordering.LT;

  A min(A a1, A a2) => lt(a1, a2) ? a1 : a2;

  Semigroup<A> minSi() => new MinSemigroup(this);

  A max(A a1, A a2) => gte(a1, a2) ? a1 : a2;

  Semigroup<A> maxSi() => new MaxSemigroup(this);

  Tuple2<A, A> sort(A a1, A a2) => lte(a1, a2) ? tuple2(a1, a2) : tuple2(a2, a1);

  Order<A> reverse() => new _AnonymousOrder(flip(order));

  Order<A> andThen(Order<A> secondary) => new _AnonymousOrder((a1, a2) {
    final Ordering primary = order(a1, a2);
    return (primary == Ordering.EQ) ? secondary.order(a1, a2) : primary;
  });
}

typedef Ordering OrderF<A>(A a1, A a2);
class _AnonymousOrder<A> extends Order<A> {
  final OrderF<A> _f;
  _AnonymousOrder(this._f);
  @override Ordering order(A a1, A a2) => _f(a1, a2);
}

Order<A> order<A>(OrderF<A> f) => new _AnonymousOrder(f);
Order<A> orderBy<A, B>(Order<B> o, B by(A a)) => new _AnonymousOrder((A a1, A a2) => o.order(by(a1), by(a2)));

class ComparableOrder<A extends Comparable> extends Order<A> {
  final Type _tpe;

  ComparableOrder(): _tpe = A;

  @override Ordering order(A a1, A a2) {
    final c = a1.compareTo(a2);
    return c < 0 ? Ordering.LT : (c > 0 ? Ordering.GT : Ordering.EQ);
  }

  @override bool operator ==(Object other) => identical(this, other) || other is ComparableOrder && _tpe == other._tpe;

  @override int get hashCode => 0;
}

final Order _comparableOrder = new ComparableOrder();
Order<A> comparableOrder<A extends Comparable>() => new ComparableOrder();

class ToStringOrder<A extends Object> extends Order<A> {
  Ordering order(A a1, A a2) => _comparableOrder.order(a1.toString(), a2.toString());
}

final Order toStringOrder = new ToStringOrder();

class MinSemigroup<A> extends Semigroup<A> {
  final Order<A> _aOrder;
  MinSemigroup(this._aOrder);
  @override A append(A a1, A a2) => _aOrder.lt(a1, a2) ? a1 : a2;
}

class MaxSemigroup<A> extends Semigroup<A> {
  final Order<A> _aOrder;
  MaxSemigroup(this._aOrder);
  @override A append(A a1, A a2) => _aOrder.gt(a1, a2) ? a1 : a2;
}