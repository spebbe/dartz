part of dartz;

class Tuple2<T1, T2> {
  final T1 value1;
  final T2 value2;
  Tuple2(this.value1, this.value2);
  apply(f(T1, T2)) => f(value1, value2);
  @override String toString() => '($value1, $value2)';
  @override bool operator ==(other) => other is Tuple2 && other.value1 == value1 && other.value2 == value2;
}

Tuple2 tuple2(v1, v2) => new Tuple2(v1, v2);

class Tuple2Semigroup extends Semigroup<Tuple2> {
  final Semigroup _value1Semigroup;
  final Semigroup _value2Semigroup;

  Tuple2Semigroup(this._value1Semigroup, this._value2Semigroup);

  @override Tuple2 append(Tuple2 t1, Tuple2 t2) =>
      new Tuple2(_value1Semigroup.append(t1.value1, t2.value1), _value2Semigroup.append(t1.value2, t2.value2));
}

Semigroup<Tuple2> tuple2Semigroup(Semigroup value1Semigroup, Semigroup value2Semigroup) => new Tuple2Semigroup(value1Semigroup, value2Semigroup);

class Tuple2Monoid extends Tuple2Semigroup with Monoid<Tuple2> {
  final Tuple2 _z;

  Tuple2Monoid(Monoid v1m, Monoid v2m)
      : _z = new Tuple2(v1m.zero(), v2m.zero()), super(v1m, v2m);

  @override Tuple2 zero() => _z;
}

Monoid<Tuple2> tuple2Monoid(Monoid value1Monoid, Monoid value2Monoid) => new Tuple2Monoid(value1Monoid, value2Monoid);

class Tuple3<T1, T2, T3> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  Tuple3(this.value1, this.value2, this.value3);
  apply(f(T1, T2, T3)) => f(value1, value2, value3);
  @override String toString() => '($value1, $value2, $value3)';
  @override bool operator ==(other) => other is Tuple3 && other.value1 == value1 && other.value2 == value2 && other.value3 == value3;
}

Tuple3 tuple3(v1, v2, v3) => new Tuple3(v1, v2, v3);

class Tuple3Semigroup extends Semigroup<Tuple3> {
  final Semigroup _value1Semigroup;
  final Semigroup _value2Semigroup;
  final Semigroup _value3Semigroup;

  Tuple3Semigroup(this._value1Semigroup, this._value2Semigroup, this._value3Semigroup);

  @override Tuple3 append(Tuple3 t1, Tuple3 t2) =>
      new Tuple3(_value1Semigroup.append(t1.value1, t2.value1), _value2Semigroup.append(t1.value2, t2.value2), _value3Semigroup.append(t1.value3, t2.value3));
}

Semigroup<Tuple3> tuple3Semigroup(Semigroup value1Semigroup, Semigroup value2Semigroup, Semigroup value3Semigroup) => new Tuple3Semigroup(value1Semigroup, value2Semigroup, value3Semigroup);

class Tuple3Monoid extends Tuple3Semigroup with Monoid<Tuple3> {
  final Tuple3 _z;

  Tuple3Monoid(Monoid v1m, Monoid v2m, Monoid v3m)
      : _z = new Tuple3(v1m.zero(), v2m.zero(), v3m.zero()), super(v1m, v2m, v3m);

  @override Tuple3 zero() => _z;
}

Monoid<Tuple3> tuple3Monoid(Monoid value1Monoid, Monoid value2Monoid, Monoid value3Monoid) => new Tuple3Monoid(value1Monoid, value2Monoid, value3Monoid);


class Tuple4<T1, T2, T3, T4> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  Tuple4(this.value1, this.value2, this.value3, this.value4);
  apply(f(T1, T2, T3, T4)) => f(value1, value2, value3, value4);
  @override String toString() => '($value1, $value2, $value3, $value4)';
  @override bool operator ==(other) => other is Tuple4 && other.value1 == value1 && other.value2 == value2 && other.value3 == value3 && other.value4 == value4;
}

Tuple4 tuple4(v1, v2, v3, v4) => new Tuple4(v1, v2, v3, v4);

class Tuple4Semigroup extends Semigroup<Tuple4> {
  final Semigroup _value1Semigroup;
  final Semigroup _value2Semigroup;
  final Semigroup _value3Semigroup;
  final Semigroup _value4Semigroup;

  Tuple4Semigroup(this._value1Semigroup, this._value2Semigroup, this._value3Semigroup, this._value4Semigroup);

  @override Tuple4 append(Tuple4 t1, Tuple4 t2) =>
      new Tuple4(_value1Semigroup.append(t1.value1, t2.value1), _value2Semigroup.append(t1.value2, t2.value2), _value3Semigroup.append(t1.value3, t2.value3), _value4Semigroup.append(t1.value4, t2.value4));
}

Semigroup<Tuple4> tuple4Semigroup(Semigroup value1Semigroup, Semigroup value2Semigroup, Semigroup value3Semigroup, Semigroup value4Semigroup) => new Tuple4Semigroup(value1Semigroup, value2Semigroup, value3Semigroup, value4Semigroup);


class Tuple4Monoid extends Tuple4Semigroup with Monoid<Tuple4> {
  final Tuple4 _z;

  Tuple4Monoid(Monoid v1m, Monoid v2m, Monoid v3m, Monoid v4m)
      : _z = new Tuple4(v1m.zero(), v2m.zero(), v3m.zero(), v4m.zero()), super(v1m, v2m, v3m, v4m);

  @override Tuple4 zero() => _z;
}

Monoid<Tuple4> tuple4Monoid(Monoid value1Monoid, Monoid value2Monoid, Monoid value3Monoid, Monoid value4Monoid) => new Tuple4Monoid(value1Monoid, value2Monoid, value3Monoid, value4Monoid);
