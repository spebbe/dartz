part of dartz;

class Tuple2<T1, T2> {
  final T1 value1;
  final T2 value2;
  Tuple2(this.value1, this.value2);
  R apply<R>(Function2<T1, T2, R> f) => f(value1, value2);
  Tuple2<NT1, T2> map1<NT1>(Function1<T1, NT1> f) => new Tuple2(f(value1), value2);
  Tuple2<T1, NT2> map2<NT2>(Function1<T2, NT2> f) => new Tuple2(value1, f(value2));
  @override String toString() => '($value1, $value2)';
  @override bool operator ==(other) => other is Tuple2 && other.value1 == value1 && other.value2 == value2;
  @override int get hashCode => value1.hashCode ^ value2.hashCode;
}

Tuple2<T1, T2> tuple2<T1, T2>(T1 v1, T2 v2) => new Tuple2(v1, v2);

class Tuple2Semigroup<T1, T2> extends Semigroup<Tuple2<T1, T2>> {
  final Semigroup<T1> _value1Semigroup;
  final Semigroup<T2> _value2Semigroup;

  Tuple2Semigroup(this._value1Semigroup, this._value2Semigroup);

  @override Tuple2<T1, T2> append(Tuple2<T1, T2> t1, Tuple2<T1, T2> t2) =>
      new Tuple2<T1, T2>(_value1Semigroup.append(t1.value1, t2.value1), _value2Semigroup.append(t1.value2, t2.value2));
}

Semigroup<Tuple2<T1, T2>> tuple2Semigroup<T1, T2>(Semigroup<T1> value1Semigroup, Semigroup<T2> value2Semigroup) => new Tuple2Semigroup(value1Semigroup, value2Semigroup);

class Tuple2Monoid<T1, T2> extends Monoid<Tuple2<T1, T2>> {
  final Monoid<T1> _value1Monoid;
  final Monoid<T2> _value2Monoid;

  Tuple2Monoid(this._value1Monoid, this._value2Monoid);

  @override Tuple2<T1, T2> append(Tuple2<T1, T2> t1, Tuple2<T1, T2> t2) =>
      new Tuple2<T1, T2>(_value1Monoid.append(t1.value1, t2.value1), _value2Monoid.append(t1.value2, t2.value2));

  @override Tuple2<T1, T2> zero() => new Tuple2<T1, T2>(_value1Monoid.zero(), _value2Monoid.zero());
}

Monoid<Tuple2<T1, T2>> tuple2Monoid<T1, T2>(Monoid<T1> value1Monoid, Monoid<T2> value2Monoid) => new Tuple2Monoid(value1Monoid, value2Monoid);

class Tuple3<T1, T2, T3> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  Tuple3(this.value1, this.value2, this.value3);
  R apply<R>(Function3<T1, T2, T3, R> f) => f(value1, value2, value3);
  @override String toString() => '($value1, $value2, $value3)';
  @override bool operator ==(other) => other is Tuple3 && other.value1 == value1 && other.value2 == value2 && other.value3 == value3;
  @override int get hashCode => value1.hashCode ^ value2.hashCode ^ value3.hashCode;
}

Tuple3<T1, T2, T3> tuple3<T1, T2, T3>(T1 v1, T2 v2, T3 v3) => new Tuple3(v1, v2, v3);

class Tuple3Semigroup<T1, T2, T3> extends Semigroup<Tuple3<T1, T2, T3>> {
  final Semigroup<T1> _value1Semigroup;
  final Semigroup<T2> _value2Semigroup;
  final Semigroup<T3> _value3Semigroup;

  Tuple3Semigroup(this._value1Semigroup, this._value2Semigroup, this._value3Semigroup);

  @override Tuple3<T1, T2, T3> append(Tuple3<T1, T2, T3> t1, Tuple3<T1, T2, T3> t2) =>
      new Tuple3<T1, T2, T3>(_value1Semigroup.append(t1.value1, t2.value1), _value2Semigroup.append(t1.value2, t2.value2), _value3Semigroup.append(t1.value3, t2.value3));
}

Semigroup<Tuple3<T1, T2, T3>> tuple3Semigroup<T1, T2, T3>(Semigroup<T1> value1Semigroup, Semigroup<T2> value2Semigroup, Semigroup<T3> value3Semigroup) => new Tuple3Semigroup(value1Semigroup, value2Semigroup, value3Semigroup);

class Tuple3Monoid<T1, T2, T3> extends Monoid<Tuple3<T1, T2, T3>> {
  final Monoid<T1> _value1Monoid;
  final Monoid<T2> _value2Monoid;
  final Monoid<T3> _value3Monoid;

  Tuple3Monoid(this._value1Monoid, this._value2Monoid, this._value3Monoid);

  @override Tuple3<T1, T2, T3> append(Tuple3<T1, T2, T3> t1, Tuple3<T1, T2, T3> t2) =>
      new Tuple3<T1, T2, T3>(_value1Monoid.append(t1.value1, t2.value1), _value2Monoid.append(t1.value2, t2.value2), _value3Monoid.append(t1.value3, t2.value3));

  @override Tuple3<T1, T2, T3> zero() => new Tuple3<T1, T2, T3>(_value1Monoid.zero(), _value2Monoid.zero(), _value3Monoid.zero());
}

Monoid<Tuple3<T1, T2, T3>> tuple3Monoid<T1, T2, T3>(Monoid<T1> value1Monoid, Monoid<T2> value2Monoid, Monoid<T3> value3Monoid) => new Tuple3Monoid(value1Monoid, value2Monoid, value3Monoid);


class Tuple4<T1, T2, T3, T4> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  Tuple4(this.value1, this.value2, this.value3, this.value4);
  R apply<R>(Function4<T1, T2, T3, T4, R> f) => f(value1, value2, value3, value4);
  @override String toString() => '($value1, $value2, $value3, $value4)';
  @override bool operator ==(other) => other is Tuple4 && other.value1 == value1 && other.value2 == value2 && other.value3 == value3 && other.value4 == value4;
  @override int get hashCode => value1.hashCode ^ value2.hashCode ^ value3.hashCode ^ value4.hashCode;
}

Tuple4<T1, T2, T3, T4> tuple4<T1, T2, T3, T4>(T1 v1, T2 v2, T3 v3, T4 v4) => new Tuple4(v1, v2, v3, v4);

class Tuple4Semigroup<T1, T2, T3, T4> extends Semigroup<Tuple4<T1, T2, T3, T4>> {
  final Semigroup<T1> _value1Semigroup;
  final Semigroup<T2> _value2Semigroup;
  final Semigroup<T3> _value3Semigroup;
  final Semigroup<T4> _value4Semigroup;

  Tuple4Semigroup(this._value1Semigroup, this._value2Semigroup, this._value3Semigroup, this._value4Semigroup);

  @override Tuple4<T1, T2, T3, T4> append(Tuple4<T1, T2, T3, T4> t1, Tuple4<T1, T2, T3, T4> t2) =>
      new Tuple4<T1, T2, T3, T4>(_value1Semigroup.append(t1.value1, t2.value1), _value2Semigroup.append(t1.value2, t2.value2), _value3Semigroup.append(t1.value3, t2.value3), _value4Semigroup.append(t1.value4, t2.value4));
}

Semigroup<Tuple4<T1, T2, T3, T4>> tuple4Semigroup<T1, T2, T3, T4>(Semigroup<T1> value1Semigroup, Semigroup<T2> value2Semigroup, Semigroup<T3> value3Semigroup, Semigroup<T4> value4Semigroup) => new Tuple4Semigroup(value1Semigroup, value2Semigroup, value3Semigroup, value4Semigroup);


class Tuple4Monoid<T1, T2, T3, T4> extends Monoid<Tuple4<T1, T2, T3, T4>> {
  final Monoid<T1> _value1Monoid;
  final Monoid<T2> _value2Monoid;
  final Monoid<T3> _value3Monoid;
  final Monoid<T4> _value4Monoid;

  Tuple4Monoid(this._value1Monoid, this._value2Monoid, this._value3Monoid, this._value4Monoid);

  @override Tuple4<T1, T2, T3, T4> append(Tuple4<T1, T2, T3, T4> t1, Tuple4<T1, T2, T3, T4> t2) =>
      new Tuple4<T1, T2, T3, T4>(_value1Monoid.append(t1.value1, t2.value1), _value2Monoid.append(t1.value2, t2.value2), _value3Monoid.append(t1.value3, t2.value3), _value4Monoid.append(t1.value4, t2.value4));

  @override Tuple4<T1, T2, T3, T4> zero() => new Tuple4<T1, T2, T3, T4>(_value1Monoid.zero(), _value2Monoid.zero(), _value3Monoid.zero(), _value4Monoid.zero());
}

Monoid<Tuple4<T1, T2, T3, T4>> tuple4Monoid<T1, T2, T3, T4>(Monoid<T1> value1Monoid, Monoid<T2> value2Monoid, Monoid<T3> value3Monoid, Monoid<T4> value4Monoid) => new Tuple4Monoid(value1Monoid, value2Monoid, value3Monoid, value4Monoid);
