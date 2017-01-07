import 'package:enumerators/enumerators.dart';
import 'package:test/test.dart';
import 'package:enumerators/combinators.dart' as c;
import 'package:propcheck/propcheck.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';

void main() {
  final qc = new QuickCheck(maxSize: 300, seed: 42);
  final intTrees = c.listsOf(c.ints).map((l) =>  new AVLTree.fromIList(NumOrder, ilist(l as List<num>))) as Enumeration<AVLTree<int>>;

  test("min", () {
    qc.check(forall(intTrees,
        (AVLTree<num> t) => t.concatenateO(NumMinSi) == t.min()));
  });

  test("max", () {
    qc.check(forall(intTrees,
        (AVLTree<num> t) => t.concatenateO(NumMaxSi) == t.max()));
  });

  test("demo", () {
    final AVLTree<num> t = new AVLTree<num>.fromIList(NumOrder, ilist([5,1,6,7,3,6]));
    expect(t.get(3), some(3));
    expect(t.get(4), none());
    expect(t.toIList(), ilist([1,3,5,6,7]));
  });

  group("AVLTreeMonoid", () => checkMonoidLaws(new AVLTreeMonoid(NumOrder), intTrees));

  group("AVLTreeFo", () => checkFoldableLaws(AVLTreeFo, intTrees));

  group("equality", () {
    test("equality", () {
      qc.check(forall2(intTrees, intTrees,
          (AVLTree<int> t1, AVLTree<int> t2) =>
          (t1 == t1) &&
              (t2 == t2) &&
              (t1.insert((t1.max()|0) + 1) != t1) &&
              ((t1 == t2) == (t1.toString() == t2.toString()))));
    });
  });

  group("AVLTree FoldableOps", () => checkFoldableOpsProperties(intTrees));

  test("iterable", () => qc.check(forall(intTrees, (AVLTree<int> t) => t.toIList() == ilist(t.toIterable()))));
}