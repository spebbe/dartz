import "package:test/test.dart";
//import 'package:enumerators/combinators.dart' as c;
import 'combinators_stubs.dart' as c;
//import 'package:propcheck/propcheck.dart';
import 'propcheck_stubs.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';

void main() {
  final qc = new QuickCheck(maxSize: 300, seed: 42);
  final intLists = c.listsOf(c.ints);
  final simpleIntSets = intLists.map((il) => new ISet<int>.fromIList(IntOrder, ilist(il)));
  final intSets = simpleIntSets.flatMap((a) => simpleIntSets.flatMap((b) => simpleIntSets.map((c) => a + b + c)));

  test("insertion", () {
    qc.check(forall(intLists, (dynamicL) {
      final l = dynamicL as List<int>;
      return ilist(l.toSet().toList()..sort()) == iset(l).toIList();
    }));
  });

  test("deletion", () {
    qc.check(forall2(intLists, intLists, (dynamicL1, dynamicL2) {
      final l1 = dynamicL1 as List<int>;
      final l2 = dynamicL2 as List<int>;
      final actual = l2.fold<ISet<int>>(iset(l1), (s, i) => s.remove(i)).toIList();
      final expected = ilist(l1.where((i) => !l2.contains(i)).toSet().toList()..sort());
      return actual == expected;
    }));
  });

  test("demo", () {
    final ISet<String> s = iset(["row", "row", "row", "your", "boat"]);

    expect(s.contains("row"), true);
    expect(s.contains("paddle"), false);
    expect(s, iset(["row", "your", "boat"]));
  });

  group("ISetMonoid", () => checkMonoidLaws(new ISetMonoid(IntOrder), intSets));

  group("ISetTreeFo", () => checkFoldableLaws(ISetFo, intSets));

  group("ISet FoldableOps", () => checkFoldableOpsProperties(intSets));

  test("iterable", () => qc.check(forall(intSets, (dynamicS) {
    final s = dynamicS as ISet<int>;
    return s.toIList() == ilist(s.toIterable());
  })));

  test("filter", () => qc.check(forall<ISet<int>>(intSets, (intSet) {
    final positives = intSet.filter((i) => i >= 0);
    final negatives = intSet.filter((i) => i < 0);
    final allElementsRepresented = negatives.length() + positives.length() == intSet.length();
    final correctSubsets = positives.all((i) => i >= 0) && negatives.all((i) => i < 0);
    return allElementsRepresented && correctSubsets;
  })));

  test("partition", () => qc.check(forall<ISet<int>>(intSets, (intSet) {
    final positivesAndNegatives = intSet.partition((i) => i >= 0);
    final positives = positivesAndNegatives.value1;
    final negatives = positivesAndNegatives.value2;
    final allElementsRepresented = negatives.length() + positives.length() == intSet.length();
    final correctSubsets = positives.all((i) => i >= 0) && negatives.all((i) => i < 0);
    return allElementsRepresented && correctSubsets;
  })));

  test("transform", () => qc.check(forall<ISet<int>>(intSets, (intSet) {
    final positives = intSet.filter((i) => i >= 0);
    final sum = positives.concatenate(IntSumMi);
    final doubledPositives = positives.transform(IntOrder, (i) => i*2);
    final doubledSum = doubledPositives.concatenate(IntSumMi);
    return doubledSum == sum*2;
  })));

}
