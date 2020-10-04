import 'package:test/test.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';
import 'proptest/PropTest.dart';

void main() {
  final pt = new PropTest();
  final intTrees = Gen.listOf(Gen.ints).map((l) => new AVLTree.fromIList(NumOrder, ilist(l)));

  test("min", () {
    pt.check(forAll(intTrees)(
        (t) => t.concatenateO(NumMinSi) == t.min()));
  });

  test("max", () {
    pt.check(forAll(intTrees)(
        (t) => t.concatenateO(NumMaxSi) == t.max()));
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
      pt.check(forAll2(intTrees, intTrees)(
          (t1, t2) =>
          (t1 == t1) &&
              (t2 == t2) &&
              (t1.insert((t1.max()|0) + 1) != t1) &&
              ((t1 == t2) == (t1.toString() == t2.toString()))));
    });
  });

  group("AVLTree FoldableOps", () => checkFoldableOpsProperties(intTrees));

  test("iterable", () => pt.check(forAll(intTrees)((t) => t.toIList() == ilist(t.toIterable()))));

  test("isEmpty", () => pt.check(forAll(intTrees)((AVLTree<num> t) => (t.length() == 0) == t.isEmpty)));
}