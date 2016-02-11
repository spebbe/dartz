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

  A max(A a1, A a2) => gte(a1, a2) ? a1 : a2;

  Tuple2<A, A> sort(A a1, A a2) => lte(a1, a2) ? tuple2(a1, a2) : tuple2(a2, a1);
}

class ComparableOrder<A extends Comparable> extends Order<A> {
  @override Ordering order(A a1, A a2) {
    final c = a1.compareTo(a2);
    return c < 0 ? Ordering.LT : (c > 0 ? Ordering.GT : Ordering.EQ);
  }
}

final Order comparableOrder = new ComparableOrder();

class ToStringOrder<A extends Object> extends Order<A> {
  Ordering order(A a1, A a2) => comparableOrder.order(a1.toString(), a2.toString());
}

final Order toStringOrder = new ToStringOrder();

