import 'package:test/test.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';
import 'proptest/PropTest.dart';

void main() {
  group("Tuple2Mi", () => checkMonoidLaws(tuple2Monoid(NumSumMi, NumSumMi), Gen.ints.product(Gen.ints)));

  group("Tuple3Mi", () => checkMonoidLaws(tuple3Monoid(NumSumMi, NumSumMi, NumSumMi), Gen.ints.flatMap((a) => Gen.ints.flatMap((b) => Gen.ints.map((c) => tuple3(a, b, c))))));

  group("Tuple4Mi", () => checkMonoidLaws(tuple4Monoid(NumSumMi, NumSumMi, NumSumMi, NumSumMi), Gen.ints.flatMap((a) => Gen.ints.flatMap((b) => Gen.ints.flatMap((c) => Gen.ints.map((d) => tuple4(a, b, c, d)))))));
}