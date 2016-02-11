part of dartz;

abstract class Unit {}
class _ConcreteUnit extends Unit {
  @override String toString() => "()";
}
final Unit unit = new _ConcreteUnit();

class UnitMonoid extends Monoid<Unit> {
  @override Unit zero() => unit;

  @override Unit append(Unit u1, Unit u2) => unit;
}

final Monoid<Unit> UnitMi = new UnitMonoid();
