import "package:test/test.dart";
import 'package:dartz/dartz.dart';
import 'laws.dart';
import 'proptest/PropTest.dart';

class HashDegenerate {
  final int i;

  HashDegenerate(this.i);

  @override
  bool operator ==(Object other) => identical(this, other) || other is HashDegenerate && i == other.i;

  @override
  int get hashCode => 15;

  @override
  String toString() {
    return 'HashDegenerate{i: $i}';
  }
}

void main() {
  final pt = new PropTest();
  final intLists = Gen.listOf(Gen.ints);
  final simpleIntSets = intLists.map((il) => new IHashSet<int>.fromIList(ilist(il)));
  final intSets = simpleIntSets.flatMap((a) => simpleIntSets.flatMap((b) => simpleIntSets.map((c) => a + b + c)));
  final hashDegenerateSets = intSets.map((s) => s.transform((i) => new HashDegenerate(i)));

  test("insertion", () {
    pt.check(forAll(intLists)((l) {
      return ilist(l.toSet().toList()..sort()) == ihashset(l).toIList();
    }));
  });

  test("deletion", () {
    pt.check(forAll2(intLists, intLists)((l1, l2) {
      final actual = l2.fold<IHashSet<int>>(ihashset(l1), (s, i) => s.remove(i)).toIList();
      final expected = ilist(l1.where((i) => !l2.contains(i)).toSet().toList()..sort());
      return actual == expected;
    }));
  });

  test("demo", () {
    final IHashSet<String> s = ihashset(["row", "row", "row", "your", "boat"]);

    expect(s.contains("row"), true);
    expect(s.contains("paddle"), false);
    expect(s, ihashset(["row", "your", "boat"]));
  });

  //group("IHashSetMonoid", () => checkMonoidLaws(new IHashSetMonoid(IntOrder), intSets));

  //group("IHashSetTreeFo", () => checkFoldableLaws(IHashSetFo, intSets));

  group("IHashSet FoldableOps", () => checkFoldableOpsProperties(intSets));

  test("iterable", () => pt.check(forAll(intSets)((s) {
    return s.toIList() == ilist(s.toIterable());
  })));

  test("filter", () => pt.check(forAll(intSets)((intSet) {
    final positives = intSet.filter((i) => i >= 0);
    final negatives = intSet.filter((i) => i < 0);
    final allElementsRepresented = negatives.length() + positives.length() == intSet.length();
    final correctSubsets = positives.all((i) => i >= 0) && negatives.all((i) => i < 0);
    return allElementsRepresented && correctSubsets;
  })));

  test("partition", () => pt.check(forAll(intSets)((intSet) {
    final positivesAndNegatives = intSet.partition((i) => i >= 0);
    final positives = positivesAndNegatives.value1;
    final negatives = positivesAndNegatives.value2;
    final allElementsRepresented = negatives.length() + positives.length() == intSet.length();
    final correctSubsets = positives.all((i) => i >= 0) && negatives.all((i) => i < 0);
    return allElementsRepresented && correctSubsets;
  })));

  test("transform", () => pt.check(forAll(intSets)((intSet) {
    final positives = intSet.filter((i) => i >= 0);
    final sum = positives.concatenate(IntSumMi);
    final doubledPositives = positives.transform((i) => i*2);
    final doubledSum = doubledPositives.concatenate(IntSumMi);
    return doubledSum == sum*2;
  })));

  test("isEmpty", () => pt.check(forAll(intSets)((s) => (s.length() == 0) == s.isEmpty)));

  test("hash degenerate isEmpty", () => pt.check(forAll(hashDegenerateSets)((s) => (s-s).isEmpty)));

}
