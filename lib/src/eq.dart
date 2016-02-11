part of dartz;

abstract class Eq<A> {
  bool eq(A a1, A a2);
  bool neq(A a1, A a2) => !eq(a1, a2);
}

abstract class EqOps<A> {
  bool eq(A other);
  bool neq(A other) => !eq(other);
}
