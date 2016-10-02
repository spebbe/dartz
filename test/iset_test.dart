import 'package:enumerators/src/enumeration.dart';
import "package:test/test.dart";
import 'package:enumerators/combinators.dart' as c;
import 'package:propcheck/propcheck.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';

void main() {
  final qc = new QuickCheck(maxSize: 300, seed: 42);
  final intLists = c.listsOf(c.ints);
  final intSets = intLists.map((il) => new ISet<int>.fromIListWithOrder(IntOrder, ilist(il as List<int>))) as Enumeration<ISet<int>>;

  test("insertion", () {
    qc.check(forall(intLists,
        (List<int> l) => ilist(l.toSet().toList()..sort()) == iset(l).toIList()));
  });

  test("deletion", () {
    qc.check(forall2(intLists, intLists, (List<int> l1, List<int> l2) {
      final actual = l2.fold/*<ISet<int>>*/(iset(l1), (s, i) => s.remove(i)).toIList();
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
}
