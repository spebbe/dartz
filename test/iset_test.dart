import "package:test/test.dart";
import 'package:enumerators/combinators.dart' as c;
import 'package:propcheck/propcheck.dart';
import 'package:dartz/dartz.dart';

void main() {
  final qc = new QuickCheck(maxSize: 300, seed: 42);
  final intLists = c.listsOf(c.ints);

  test("insertion", () {
    qc.check(forall(intLists,
        (List<int> l) => ilist(l.toSet().toList()..sort()) == iset(ilist(l)).toIList()));
  });

  test("deletion", () {
    qc.check(forall2(intLists, intLists, (List<int> l1, List<int> l2) {
      final IList<int> actual = l2.fold(iset(ilist(l1)), (s, i) => s.remove(i)).toIList();
      final expected = ilist(l1.where((i) => !l2.contains(i)).toSet().toList()..sort());
      return actual == expected;
    }));
  });

  test("demo", () {
    final ISet<String> s = iset(ilist(["row", "row", "row", "your", "boat"]));

    expect(s.contains("row"), true);
    expect(s.contains("paddle"), false);
    expect(s, iset(ilist(["row", "your", "boat"])));
  });
}
