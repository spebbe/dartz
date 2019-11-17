// ignore_for_file: unnecessary_new

part of dartz;

class Tuple2<T1, T2> {
  final T1 value1;
  final T2 value2;

  R apply<R>(Function2<T1, T2, R> f) => f(value1, value2);
  Tuple2<NT1, T2> map1<NT1>(Function1<T1, NT1> f) => new Tuple2(f(value1), value2);
  Tuple2<T1, NT2> map2<NT2>(Function1<T2, NT2> f) => new Tuple2(value1, f(value2));

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple2(this.value1, this.value2);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple2 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode;

  @override
  String toString() => '($value1, $value2)';

  Tuple2 copyWith({
    T1 value1,
    T2 value2,
  }) {
    return new Tuple2(
      value1 ?? this.value1,
      value2 ?? this.value2,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
    };
  }

  factory Tuple2.fromMap(Map<String, dynamic> map) {
    return new Tuple2(
      map['value1'] as T1,
      map['value2'] as T2,
    );
  }

//</editor-fold>
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

  R apply<R>(Function3<T1, T2, T3, R> f) => f(value1, value2, value3);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple3(this.value1, this.value2, this.value3);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple3 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode;

  @override
  String toString() => '($value1, $value2, $value3)';

  Tuple3 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
  }) {
    return new Tuple3(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
    };
  }

  factory Tuple3.fromMap(Map<String, dynamic> map) {
    return new Tuple3(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
    );
  }

//</editor-fold>
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

  R apply<R>(Function4<T1, T2, T3, T4, R> f) => f(value1, value2, value3, value4);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple4(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple4 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4)';

  Tuple4 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
  }) {
    return new Tuple4(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
    };
  }

  factory Tuple4.fromMap(Map<String, dynamic> map) {
    return new Tuple4(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
    );
  }

//</editor-fold>
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

class Tuple5<T1, T2, T3, T4, T5> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;

  R apply<R>(Function5<T1, T2, T3, T4, T5, R> f) =>
      f(value1, value2, value3, value4, value5);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple5(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple5 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5)';

  Tuple5 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
  }) {
    return new Tuple5(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
    };
  }

  factory Tuple5.fromMap(Map<String, dynamic> map) {
    return new Tuple5(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
    );
  }

//</editor-fold>
}

class Tuple6<T1, T2, T3, T4, T5, T6> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;

  R apply<R>(Function6<T1, T2, T3, T4, T5, T6, R> f) =>
      f(value1, value2, value3, value4, value5, value6);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple6(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple6 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6)';

  Tuple6 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
  }) {
    return new Tuple6(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
    };
  }

  factory Tuple6.fromMap(Map<String, dynamic> map) {
    return new Tuple6(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
    );
  }

//</editor-fold>
}

class Tuple7<T1, T2, T3, T4, T5, T6, T7> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;

  R apply<R>(Function7<T1, T2, T3, T4, T5, T6, T7, R> f) =>
      f(value1, value2, value3, value4, value5, value6, value7);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple7(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple7 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6 &&
              value7 == other.value7
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode ^
      value7.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6, $value7)';

  Tuple7 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
    T7 value7,
  }) {
    return new Tuple7(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
      value7 ?? this.value7,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
      'value7': this.value7,
    };
  }

  factory Tuple7.fromMap(Map<String, dynamic> map) {
    return new Tuple7(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
      map['value7'] as T7,
    );
  }

//</editor-fold>
}

class Tuple8<T1, T2, T3, T4, T5, T6, T7, T8> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;
  final T8 value8;

  R apply<R>(Function8<T1, T2, T3, T4, T5, T6, T7, T8, R> f) =>
      f(value1, value2, value3, value4, value5, value6, value7, value8);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple8(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple8 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6 &&
              value7 == other.value7 &&
              value8 == other.value8
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode ^
      value7.hashCode ^
      value8.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6, $value7, $value8)';

  Tuple8 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
    T7 value7,
    T8 value8,
  }) {
    return new Tuple8(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
      value7 ?? this.value7,
      value8 ?? this.value8,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
      'value7': this.value7,
      'value8': this.value8,
    };
  }

  factory Tuple8.fromMap(Map<String, dynamic> map) {
    return new Tuple8(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
      map['value7'] as T7,
      map['value8'] as T8,
    );
  }

//</editor-fold>
}

class Tuple9<T1, T2, T3, T4, T5, T6, T7, T8, T9> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;
  final T8 value8;
  final T9 value9;

  R apply<R>(Function9<T1, T2, T3, T4, T5, T6, T7, T8, T9, R> f) =>
      f(value1, value2, value3, value4, value5, value6, value7, value8, value9);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple9(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
    this.value9,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple9 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6 &&
              value7 == other.value7 &&
              value8 == other.value8 &&
              value9 == other.value9
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode ^
      value7.hashCode ^
      value8.hashCode ^
      value9.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6, $value7, $value8, $value9)';

  Tuple9 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
    T7 value7,
    T8 value8,
    T9 value9,
  }) {
    return new Tuple9(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
      value7 ?? this.value7,
      value8 ?? this.value8,
      value9 ?? this.value9,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
      'value7': this.value7,
      'value8': this.value8,
      'value9': this.value9,
    };
  }

  factory Tuple9.fromMap(Map<String, dynamic> map) {
    return new Tuple9(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
      map['value7'] as T7,
      map['value8'] as T8,
      map['value9'] as T9,
    );
  }

//</editor-fold>
}

class Tuple10<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;
  final T8 value8;
  final T9 value9;
  final T10 value10;

  R apply<R>(Function10<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, R> f) =>
      f(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple10(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
    this.value9,
    this.value10,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple10 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6 &&
              value7 == other.value7 &&
              value8 == other.value8 &&
              value9 == other.value9 &&
              value10 == other.value10
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode ^
      value7.hashCode ^
      value8.hashCode ^
      value9.hashCode ^
      value10.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6, $value7, $value8, $value9, $value10)';

  Tuple10 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
    T7 value7,
    T8 value8,
    T9 value9,
    T10 value10,
  }) {
    return new Tuple10(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
      value7 ?? this.value7,
      value8 ?? this.value8,
      value9 ?? this.value9,
      value10 ?? this.value10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
      'value7': this.value7,
      'value8': this.value8,
      'value9': this.value9,
      'value10': this.value10,
    };
  }

  factory Tuple10.fromMap(Map<String, dynamic> map) {
    return new Tuple10(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
      map['value7'] as T7,
      map['value8'] as T8,
      map['value9'] as T9,
      map['value10'] as T10,
    );
  }

//</editor-fold>
}

class Tuple11<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;
  final T8 value8;
  final T9 value9;
  final T10 value10;
  final T11 value11;

  R apply<R>(Function11<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, R> f) =>
      f(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple11(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
    this.value9,
    this.value10,
    this.value11,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple11 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6 &&
              value7 == other.value7 &&
              value8 == other.value8 &&
              value9 == other.value9 &&
              value10 == other.value10 &&
              value11 == other.value11
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode ^
      value7.hashCode ^
      value8.hashCode ^
      value9.hashCode ^
      value10.hashCode ^
      value11.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6, $value7, $value8, $value9, $value10, $value11)';

  Tuple11 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
    T7 value7,
    T8 value8,
    T9 value9,
    T10 value10,
    T11 value11,
  }) {
    return new Tuple11(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
      value7 ?? this.value7,
      value8 ?? this.value8,
      value9 ?? this.value9,
      value10 ?? this.value10,
      value11 ?? this.value11,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
      'value7': this.value7,
      'value8': this.value8,
      'value9': this.value9,
      'value10': this.value10,
      'value11': this.value11,
    };
  }

  factory Tuple11.fromMap(Map<String, dynamic> map) {
    return new Tuple11(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
      map['value7'] as T7,
      map['value8'] as T8,
      map['value9'] as T9,
      map['value10'] as T10,
      map['value11'] as T11,
    );
  }

//</editor-fold>
}

class Tuple12<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;
  final T8 value8;
  final T9 value9;
  final T10 value10;
  final T11 value11;
  final T12 value12;

  R apply<R>(Function12<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, R> f) =>
      f(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11, value12);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple12(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
    this.value9,
    this.value10,
    this.value11,
    this.value12,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple12 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6 &&
              value7 == other.value7 &&
              value8 == other.value8 &&
              value9 == other.value9 &&
              value10 == other.value10 &&
              value11 == other.value11 &&
              value12 == other.value12
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode ^
      value7.hashCode ^
      value8.hashCode ^
      value9.hashCode ^
      value10.hashCode ^
      value11.hashCode ^
      value12.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6, $value7, $value8, $value9, $value10, $value11, $value12)';

  Tuple12 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
    T7 value7,
    T8 value8,
    T9 value9,
    T10 value10,
    T11 value11,
    T12 value12,
  }) {
    return new Tuple12(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
      value7 ?? this.value7,
      value8 ?? this.value8,
      value9 ?? this.value9,
      value10 ?? this.value10,
      value11 ?? this.value11,
      value12 ?? this.value12,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
      'value7': this.value7,
      'value8': this.value8,
      'value9': this.value9,
      'value10': this.value10,
      'value11': this.value11,
      'value12': this.value12,
    };
  }

  factory Tuple12.fromMap(Map<String, dynamic> map) {
    return new Tuple12(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
      map['value7'] as T7,
      map['value8'] as T8,
      map['value9'] as T9,
      map['value10'] as T10,
      map['value11'] as T11,
      map['value12'] as T12,
    );
  }

//</editor-fold>
}

class Tuple13<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;
  final T8 value8;
  final T9 value9;
  final T10 value10;
  final T11 value11;
  final T12 value12;
  final T13 value13;

  R apply<R>(Function13<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, R> f) =>
      f(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11, value12, value13);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple13(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
    this.value9,
    this.value10,
    this.value11,
    this.value12,
    this.value13,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple13 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6 &&
              value7 == other.value7 &&
              value8 == other.value8 &&
              value9 == other.value9 &&
              value10 == other.value10 &&
              value11 == other.value11 &&
              value12 == other.value12 &&
              value13 == other.value13
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode ^
      value7.hashCode ^
      value8.hashCode ^
      value9.hashCode ^
      value10.hashCode ^
      value11.hashCode ^
      value12.hashCode ^
      value13.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6, $value7, $value8, $value9, $value10, $value11, $value12, $value13)';

  Tuple13 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
    T7 value7,
    T8 value8,
    T9 value9,
    T10 value10,
    T11 value11,
    T12 value12,
    T13 value13,
  }) {
    return new Tuple13(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
      value7 ?? this.value7,
      value8 ?? this.value8,
      value9 ?? this.value9,
      value10 ?? this.value10,
      value11 ?? this.value11,
      value12 ?? this.value12,
      value13 ?? this.value13,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
      'value7': this.value7,
      'value8': this.value8,
      'value9': this.value9,
      'value10': this.value10,
      'value11': this.value11,
      'value12': this.value12,
      'value13': this.value13,
    };
  }

  factory Tuple13.fromMap(Map<String, dynamic> map) {
    return new Tuple13(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
      map['value7'] as T7,
      map['value8'] as T8,
      map['value9'] as T9,
      map['value10'] as T10,
      map['value11'] as T11,
      map['value12'] as T12,
      map['value13'] as T13,
    );
  }

//</editor-fold>
}

class Tuple14<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;
  final T8 value8;
  final T9 value9;
  final T10 value10;
  final T11 value11;
  final T12 value12;
  final T13 value13;
  final T14 value14;

  R apply<R>(Function14<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, R> f) =>
      f(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11, value12, value13, value14);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple14(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
    this.value9,
    this.value10,
    this.value11,
    this.value12,
    this.value13,
    this.value14,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple14 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6 &&
              value7 == other.value7 &&
              value8 == other.value8 &&
              value9 == other.value9 &&
              value10 == other.value10 &&
              value11 == other.value11 &&
              value12 == other.value12 &&
              value13 == other.value13 &&
              value14 == other.value14
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode ^
      value7.hashCode ^
      value8.hashCode ^
      value9.hashCode ^
      value10.hashCode ^
      value11.hashCode ^
      value12.hashCode ^
      value13.hashCode ^
      value14.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6, $value7, $value8, $value9, $value10, $value11, $value12, $value13, $value14)';

  Tuple14 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
    T7 value7,
    T8 value8,
    T9 value9,
    T10 value10,
    T11 value11,
    T12 value12,
    T13 value13,
    T14 value14,
  }) {
    return new Tuple14(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
      value7 ?? this.value7,
      value8 ?? this.value8,
      value9 ?? this.value9,
      value10 ?? this.value10,
      value11 ?? this.value11,
      value12 ?? this.value12,
      value13 ?? this.value13,
      value14 ?? this.value14,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
      'value7': this.value7,
      'value8': this.value8,
      'value9': this.value9,
      'value10': this.value10,
      'value11': this.value11,
      'value12': this.value12,
      'value13': this.value13,
      'value14': this.value14,
    };
  }

  factory Tuple14.fromMap(Map<String, dynamic> map) {
    return new Tuple14(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
      map['value7'] as T7,
      map['value8'] as T8,
      map['value9'] as T9,
      map['value10'] as T10,
      map['value11'] as T11,
      map['value12'] as T12,
      map['value13'] as T13,
      map['value14'] as T14,
    );
  }

//</editor-fold>
}

class Tuple15<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;
  final T8 value8;
  final T9 value9;
  final T10 value10;
  final T11 value11;
  final T12 value12;
  final T13 value13;
  final T14 value14;
  final T15 value15;

  R apply<R>(Function15<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, R> f) =>
      f(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11, value12, value13, value14, value15);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple15(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
    this.value9,
    this.value10,
    this.value11,
    this.value12,
    this.value13,
    this.value14,
    this.value15,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple15 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6 &&
              value7 == other.value7 &&
              value8 == other.value8 &&
              value9 == other.value9 &&
              value10 == other.value10 &&
              value11 == other.value11 &&
              value12 == other.value12 &&
              value13 == other.value13 &&
              value14 == other.value14 &&
              value15 == other.value15
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode ^
      value7.hashCode ^
      value8.hashCode ^
      value9.hashCode ^
      value10.hashCode ^
      value11.hashCode ^
      value12.hashCode ^
      value13.hashCode ^
      value14.hashCode ^
      value15.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6, $value7, $value8, $value9, $value10, $value11, $value12, $value13, $value14, $value15)';

  Tuple15 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
    T7 value7,
    T8 value8,
    T9 value9,
    T10 value10,
    T11 value11,
    T12 value12,
    T13 value13,
    T14 value14,
    T15 value15,
  }) {
    return new Tuple15(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
      value7 ?? this.value7,
      value8 ?? this.value8,
      value9 ?? this.value9,
      value10 ?? this.value10,
      value11 ?? this.value11,
      value12 ?? this.value12,
      value13 ?? this.value13,
      value14 ?? this.value14,
      value15 ?? this.value15,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
      'value7': this.value7,
      'value8': this.value8,
      'value9': this.value9,
      'value10': this.value10,
      'value11': this.value11,
      'value12': this.value12,
      'value13': this.value13,
      'value14': this.value14,
      'value15': this.value15,
    };
  }

  factory Tuple15.fromMap(Map<String, dynamic> map) {
    return new Tuple15(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
      map['value7'] as T7,
      map['value8'] as T8,
      map['value9'] as T9,
      map['value10'] as T10,
      map['value11'] as T11,
      map['value12'] as T12,
      map['value13'] as T13,
      map['value14'] as T14,
      map['value15'] as T15,
    );
  }

//</editor-fold>
}

class Tuple16<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;
  final T8 value8;
  final T9 value9;
  final T10 value10;
  final T11 value11;
  final T12 value12;
  final T13 value13;
  final T14 value14;
  final T15 value15;
  final T16 value16;

  R apply<R>(Function16<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, R> f) =>
      f(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11, value12, value13, value14, value15, value16);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple16(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
    this.value9,
    this.value10,
    this.value11,
    this.value12,
    this.value13,
    this.value14,
    this.value15,
    this.value16,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple16 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6 &&
              value7 == other.value7 &&
              value8 == other.value8 &&
              value9 == other.value9 &&
              value10 == other.value10 &&
              value11 == other.value11 &&
              value12 == other.value12 &&
              value13 == other.value13 &&
              value14 == other.value14 &&
              value15 == other.value15 &&
              value16 == other.value16
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode ^
      value7.hashCode ^
      value8.hashCode ^
      value9.hashCode ^
      value10.hashCode ^
      value11.hashCode ^
      value12.hashCode ^
      value13.hashCode ^
      value14.hashCode ^
      value15.hashCode ^
      value16.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6, $value7, $value8, $value9, $value10, $value11, $value12, $value13, $value14, $value15, $value16)';

  Tuple16 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
    T7 value7,
    T8 value8,
    T9 value9,
    T10 value10,
    T11 value11,
    T12 value12,
    T13 value13,
    T14 value14,
    T15 value15,
    T16 value16,
  }) {
    return new Tuple16(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
      value7 ?? this.value7,
      value8 ?? this.value8,
      value9 ?? this.value9,
      value10 ?? this.value10,
      value11 ?? this.value11,
      value12 ?? this.value12,
      value13 ?? this.value13,
      value14 ?? this.value14,
      value15 ?? this.value15,
      value16 ?? this.value16,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
      'value7': this.value7,
      'value8': this.value8,
      'value9': this.value9,
      'value10': this.value10,
      'value11': this.value11,
      'value12': this.value12,
      'value13': this.value13,
      'value14': this.value14,
      'value15': this.value15,
      'value16': this.value16,
    };
  }

  factory Tuple16.fromMap(Map<String, dynamic> map) {
    return new Tuple16(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
      map['value7'] as T7,
      map['value8'] as T8,
      map['value9'] as T9,
      map['value10'] as T10,
      map['value11'] as T11,
      map['value12'] as T12,
      map['value13'] as T13,
      map['value14'] as T14,
      map['value15'] as T15,
      map['value16'] as T16,
    );
  }

//</editor-fold>
}

class Tuple17<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;
  final T8 value8;
  final T9 value9;
  final T10 value10;
  final T11 value11;
  final T12 value12;
  final T13 value13;
  final T14 value14;
  final T15 value15;
  final T16 value16;
  final T17 value17;

  R apply<R>(Function17<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, R> f) =>
      f(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11, value12, value13, value14, value15, value16, value17);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple17(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
    this.value9,
    this.value10,
    this.value11,
    this.value12,
    this.value13,
    this.value14,
    this.value15,
    this.value16,
    this.value17,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple17 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6 &&
              value7 == other.value7 &&
              value8 == other.value8 &&
              value9 == other.value9 &&
              value10 == other.value10 &&
              value11 == other.value11 &&
              value12 == other.value12 &&
              value13 == other.value13 &&
              value14 == other.value14 &&
              value15 == other.value15 &&
              value16 == other.value16 &&
              value17 == other.value17
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode ^
      value7.hashCode ^
      value8.hashCode ^
      value9.hashCode ^
      value10.hashCode ^
      value11.hashCode ^
      value12.hashCode ^
      value13.hashCode ^
      value14.hashCode ^
      value15.hashCode ^
      value16.hashCode ^
      value17.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6, $value7, $value8, $value9, $value10, $value11, $value12, $value13, $value14, $value15, $value16, $value17)';

  Tuple17 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
    T7 value7,
    T8 value8,
    T9 value9,
    T10 value10,
    T11 value11,
    T12 value12,
    T13 value13,
    T14 value14,
    T15 value15,
    T16 value16,
    T17 value17,
  }) {
    return new Tuple17(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
      value7 ?? this.value7,
      value8 ?? this.value8,
      value9 ?? this.value9,
      value10 ?? this.value10,
      value11 ?? this.value11,
      value12 ?? this.value12,
      value13 ?? this.value13,
      value14 ?? this.value14,
      value15 ?? this.value15,
      value16 ?? this.value16,
      value17 ?? this.value17,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
      'value7': this.value7,
      'value8': this.value8,
      'value9': this.value9,
      'value10': this.value10,
      'value11': this.value11,
      'value12': this.value12,
      'value13': this.value13,
      'value14': this.value14,
      'value15': this.value15,
      'value16': this.value16,
      'value17': this.value17,
    };
  }

  factory Tuple17.fromMap(Map<String, dynamic> map) {
    return new Tuple17(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
      map['value7'] as T7,
      map['value8'] as T8,
      map['value9'] as T9,
      map['value10'] as T10,
      map['value11'] as T11,
      map['value12'] as T12,
      map['value13'] as T13,
      map['value14'] as T14,
      map['value15'] as T15,
      map['value16'] as T16,
      map['value17'] as T17,
    );
  }

//</editor-fold>
}

class Tuple18<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;
  final T8 value8;
  final T9 value9;
  final T10 value10;
  final T11 value11;
  final T12 value12;
  final T13 value13;
  final T14 value14;
  final T15 value15;
  final T16 value16;
  final T17 value17;
  final T18 value18;

  R apply<R>(Function18<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, R> f) =>
      f(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11, value12, value13, value14, value15, value16, value17, value18);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple18(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
    this.value9,
    this.value10,
    this.value11,
    this.value12,
    this.value13,
    this.value14,
    this.value15,
    this.value16,
    this.value17,
    this.value18,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple18 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6 &&
              value7 == other.value7 &&
              value8 == other.value8 &&
              value9 == other.value9 &&
              value10 == other.value10 &&
              value11 == other.value11 &&
              value12 == other.value12 &&
              value13 == other.value13 &&
              value14 == other.value14 &&
              value15 == other.value15 &&
              value16 == other.value16 &&
              value17 == other.value17 &&
              value18 == other.value18
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode ^
      value7.hashCode ^
      value8.hashCode ^
      value9.hashCode ^
      value10.hashCode ^
      value11.hashCode ^
      value12.hashCode ^
      value13.hashCode ^
      value14.hashCode ^
      value15.hashCode ^
      value16.hashCode ^
      value17.hashCode ^
      value18.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6, $value7, $value8, $value9, $value10, $value11, $value12, $value13, $value14, $value15, $value16, $value17, $value18)';

  Tuple18 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
    T7 value7,
    T8 value8,
    T9 value9,
    T10 value10,
    T11 value11,
    T12 value12,
    T13 value13,
    T14 value14,
    T15 value15,
    T16 value16,
    T17 value17,
    T18 value18,
  }) {
    return new Tuple18(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
      value7 ?? this.value7,
      value8 ?? this.value8,
      value9 ?? this.value9,
      value10 ?? this.value10,
      value11 ?? this.value11,
      value12 ?? this.value12,
      value13 ?? this.value13,
      value14 ?? this.value14,
      value15 ?? this.value15,
      value16 ?? this.value16,
      value17 ?? this.value17,
      value18 ?? this.value18,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
      'value7': this.value7,
      'value8': this.value8,
      'value9': this.value9,
      'value10': this.value10,
      'value11': this.value11,
      'value12': this.value12,
      'value13': this.value13,
      'value14': this.value14,
      'value15': this.value15,
      'value16': this.value16,
      'value17': this.value17,
      'value18': this.value18,
    };
  }

  factory Tuple18.fromMap(Map<String, dynamic> map) {
    return new Tuple18(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
      map['value7'] as T7,
      map['value8'] as T8,
      map['value9'] as T9,
      map['value10'] as T10,
      map['value11'] as T11,
      map['value12'] as T12,
      map['value13'] as T13,
      map['value14'] as T14,
      map['value15'] as T15,
      map['value16'] as T16,
      map['value17'] as T17,
      map['value18'] as T18,
    );
  }

//</editor-fold>
}

class Tuple19<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;
  final T8 value8;
  final T9 value9;
  final T10 value10;
  final T11 value11;
  final T12 value12;
  final T13 value13;
  final T14 value14;
  final T15 value15;
  final T16 value16;
  final T17 value17;
  final T18 value18;
  final T19 value19;

  R apply<R>(Function19<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19, R> f) =>
      f(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11, value12, value13, value14, value15, value16, value17, value18, value19);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple19(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
    this.value9,
    this.value10,
    this.value11,
    this.value12,
    this.value13,
    this.value14,
    this.value15,
    this.value16,
    this.value17,
    this.value18,
    this.value19,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple19 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6 &&
              value7 == other.value7 &&
              value8 == other.value8 &&
              value9 == other.value9 &&
              value10 == other.value10 &&
              value11 == other.value11 &&
              value12 == other.value12 &&
              value13 == other.value13 &&
              value14 == other.value14 &&
              value15 == other.value15 &&
              value16 == other.value16 &&
              value17 == other.value17 &&
              value18 == other.value18 &&
              value19 == other.value19
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode ^
      value7.hashCode ^
      value8.hashCode ^
      value9.hashCode ^
      value10.hashCode ^
      value11.hashCode ^
      value12.hashCode ^
      value13.hashCode ^
      value14.hashCode ^
      value15.hashCode ^
      value16.hashCode ^
      value17.hashCode ^
      value18.hashCode ^
      value19.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6, $value7, $value8, $value9, $value10, $value11, $value12, $value13, $value14, $value15, $value16, $value17, $value18, $value19)';

  Tuple19 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
    T7 value7,
    T8 value8,
    T9 value9,
    T10 value10,
    T11 value11,
    T12 value12,
    T13 value13,
    T14 value14,
    T15 value15,
    T16 value16,
    T17 value17,
    T18 value18,
    T19 value19,
  }) {
    return new Tuple19(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
      value7 ?? this.value7,
      value8 ?? this.value8,
      value9 ?? this.value9,
      value10 ?? this.value10,
      value11 ?? this.value11,
      value12 ?? this.value12,
      value13 ?? this.value13,
      value14 ?? this.value14,
      value15 ?? this.value15,
      value16 ?? this.value16,
      value17 ?? this.value17,
      value18 ?? this.value18,
      value19 ?? this.value19,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
      'value7': this.value7,
      'value8': this.value8,
      'value9': this.value9,
      'value10': this.value10,
      'value11': this.value11,
      'value12': this.value12,
      'value13': this.value13,
      'value14': this.value14,
      'value15': this.value15,
      'value16': this.value16,
      'value17': this.value17,
      'value18': this.value18,
      'value19': this.value19,
    };
  }

  factory Tuple19.fromMap(Map<String, dynamic> map) {
    return new Tuple19(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
      map['value7'] as T7,
      map['value8'] as T8,
      map['value9'] as T9,
      map['value10'] as T10,
      map['value11'] as T11,
      map['value12'] as T12,
      map['value13'] as T13,
      map['value14'] as T14,
      map['value15'] as T15,
      map['value16'] as T16,
      map['value17'] as T17,
      map['value18'] as T18,
      map['value19'] as T19,
    );
  }

//</editor-fold>
}

class Tuple20<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19, T20> {
  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;
  final T8 value8;
  final T9 value9;
  final T10 value10;
  final T11 value11;
  final T12 value12;
  final T13 value13;
  final T14 value14;
  final T15 value15;
  final T16 value16;
  final T17 value17;
  final T18 value18;
  final T19 value19;
  final T20 value20;

  R apply<R>(Function20<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19, T20, R> f) =>
      f(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11, value12, value13, value14, value15, value16, value17, value18, value19, value20);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Tuple20(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
    this.value9,
    this.value10,
    this.value11,
    this.value12,
    this.value13,
    this.value14,
    this.value15,
    this.value16,
    this.value17,
    this.value18,
    this.value19,
    this.value20,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Tuple20 &&
              runtimeType == other.runtimeType &&
              value1 == other.value1 &&
              value2 == other.value2 &&
              value3 == other.value3 &&
              value4 == other.value4 &&
              value5 == other.value5 &&
              value6 == other.value6 &&
              value7 == other.value7 &&
              value8 == other.value8 &&
              value9 == other.value9 &&
              value10 == other.value10 &&
              value11 == other.value11 &&
              value12 == other.value12 &&
              value13 == other.value13 &&
              value14 == other.value14 &&
              value15 == other.value15 &&
              value16 == other.value16 &&
              value17 == other.value17 &&
              value18 == other.value18 &&
              value19 == other.value19 &&
              value20 == other.value20
          );

  @override
  int get hashCode =>
      value1.hashCode ^
      value2.hashCode ^
      value3.hashCode ^
      value4.hashCode ^
      value5.hashCode ^
      value6.hashCode ^
      value7.hashCode ^
      value8.hashCode ^
      value9.hashCode ^
      value10.hashCode ^
      value11.hashCode ^
      value12.hashCode ^
      value13.hashCode ^
      value14.hashCode ^
      value15.hashCode ^
      value16.hashCode ^
      value17.hashCode ^
      value18.hashCode ^
      value19.hashCode ^
      value20.hashCode;

  @override
  String toString() => '($value1, $value2, $value3, $value4, $value5, $value6, $value7, $value8, $value9, $value10, $value11, $value12, $value13, $value14, $value15, $value16, $value17, $value18, $value19, $value20)';

  Tuple20 copyWith({
    T1 value1,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
    T6 value6,
    T7 value7,
    T8 value8,
    T9 value9,
    T10 value10,
    T11 value11,
    T12 value12,
    T13 value13,
    T14 value14,
    T15 value15,
    T16 value16,
    T17 value17,
    T18 value18,
    T19 value19,
    T20 value20,
  }) {
    return new Tuple20(
      value1 ?? this.value1,
      value2 ?? this.value2,
      value3 ?? this.value3,
      value4 ?? this.value4,
      value5 ?? this.value5,
      value6 ?? this.value6,
      value7 ?? this.value7,
      value8 ?? this.value8,
      value9 ?? this.value9,
      value10 ?? this.value10,
      value11 ?? this.value11,
      value12 ?? this.value12,
      value13 ?? this.value13,
      value14 ?? this.value14,
      value15 ?? this.value15,
      value16 ?? this.value16,
      value17 ?? this.value17,
      value18 ?? this.value18,
      value19 ?? this.value19,
      value20 ?? this.value20,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value1': this.value1,
      'value2': this.value2,
      'value3': this.value3,
      'value4': this.value4,
      'value5': this.value5,
      'value6': this.value6,
      'value7': this.value7,
      'value8': this.value8,
      'value9': this.value9,
      'value10': this.value10,
      'value11': this.value11,
      'value12': this.value12,
      'value13': this.value13,
      'value14': this.value14,
      'value15': this.value15,
      'value16': this.value16,
      'value17': this.value17,
      'value18': this.value18,
      'value19': this.value19,
      'value20': this.value20,
    };
  }

  factory Tuple20.fromMap(Map<String, dynamic> map) {
    return new Tuple20(
      map['value1'] as T1,
      map['value2'] as T2,
      map['value3'] as T3,
      map['value4'] as T4,
      map['value5'] as T5,
      map['value6'] as T6,
      map['value7'] as T7,
      map['value8'] as T8,
      map['value9'] as T9,
      map['value10'] as T10,
      map['value11'] as T11,
      map['value12'] as T12,
      map['value13'] as T13,
      map['value14'] as T14,
      map['value15'] as T15,
      map['value16'] as T16,
      map['value17'] as T17,
      map['value18'] as T18,
      map['value19'] as T19,
      map['value20'] as T20,
    );
  }

//</editor-fold>
}
