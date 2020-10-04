import 'package:test/test.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';
import 'proptest/PropTest.dart';

void main() {
  group("NumSumMi", () => checkMonoidLaws(NumSumMi, Gen.ints));

  group("NumProductMi", () => checkMonoidLaws(NumProductMi, Gen.ints));

  group("NumMaxSi", () => checkSemigroupLaws(NumMaxSi, Gen.ints));

  group("NumMinSi", () => checkSemigroupLaws(NumMinSi, Gen.ints));

  group("StringMi", () => checkMonoidLaws(StringMi, Gen.strings));

  group("BoolOrMi", () => checkMonoidLaws(BoolOrMi, Gen.bools));

  group("BoolAndMi", () => checkMonoidLaws(BoolAndMi, Gen.bools));
}