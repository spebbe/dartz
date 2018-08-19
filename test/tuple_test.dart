import 'package:test/test.dart';
//import 'package:enumerators/combinators.dart' as c;
import 'combinators_stubs.dart' as c;
//import 'package:enumerators/enumerators.dart' as e;
import 'enumerators_stubs.dart' as e;
import 'package:dartz/dartz.dart';
import 'laws.dart';

void main() {
  group("Tuple2Mi", () => checkMonoidLaws(tuple2Monoid(NumSumMi, NumSumMi), e.apply2((int a, int b) => tuple2(a, b), c.ints, c.ints)));

  group("Tuple3Mi", () => checkMonoidLaws(tuple3Monoid(NumSumMi, NumSumMi, NumSumMi), e.apply3((int a, int b, int c) => tuple3(a, b, c), c.ints, c.ints, c.ints)));

  group("Tuple4Mi", () => checkMonoidLaws(tuple4Monoid(NumSumMi, NumSumMi, NumSumMi, NumSumMi), e.apply4((int a, int b, int c, int d) => tuple4(a, b, c, d), c.ints, c.ints, c.ints, c.ints)));
}