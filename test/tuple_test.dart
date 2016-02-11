import 'package:test/test.dart';
import 'package:enumerators/combinators.dart' as c;
import 'package:enumerators/enumerators.dart' as e;
import 'package:dartz/dartz.dart';
import 'laws.dart';

void main() {
  group("Tuple2Mi", () => checkMonoidLaws(tuple2Monoid(NumSumMi, NumSumMi), e.apply(tuple2, c.ints, c.ints)));

  group("Tuple3Mi", () => checkMonoidLaws(tuple3Monoid(NumSumMi, NumSumMi, NumSumMi), e.apply(tuple3, c.ints, c.ints, c.ints)));

  group("Tuple4Mi", () => checkMonoidLaws(tuple4Monoid(NumSumMi, NumSumMi, NumSumMi, NumSumMi), e.apply(tuple4, c.ints, c.ints, c.ints, c.ints)));
}