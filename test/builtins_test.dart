import 'package:test/test.dart';
//import 'package:enumerators/combinators.dart' as c;
import 'combinators_stubs.dart' as c;
import 'package:dartz/dartz.dart';
import 'laws.dart';

void main() {
  group("NumSumMi", () => checkMonoidLaws(NumSumMi, c.ints));

  group("NumProductMi", () => checkMonoidLaws(NumProductMi, c.ints));

  group("NumMaxSi", () => checkSemigroupLaws(NumMaxSi, c.ints));

  group("NumMinSi", () => checkSemigroupLaws(NumMinSi, c.ints));

  group("StringMi", () => checkMonoidLaws(StringMi, c.strings));

  group("BoolOrMi", () => checkMonoidLaws(BoolOrMi, c.bools));

  group("BoolAndMi", () => checkMonoidLaws(BoolAndMi, c.bools));
}