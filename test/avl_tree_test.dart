import 'package:test/test.dart';
import 'package:enumerators/combinators.dart' as c;
import 'package:propcheck/propcheck.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';

void main() {
  final qc = new QuickCheck(maxSize: 300, seed: 42);
  final intTrees = c.listsOf(c.ints).map((l) =>  new AVLTree.fromIList(NumOrder, ilist(l)));

  test("min", () {
    qc.check(forall(intTrees,
        (AVLTree<int> t) => t.concatenateO(NumMinSi) == t.min()));
  });

  test("max", () {
    qc.check(forall(intTrees,
        (AVLTree<int> t) => t.concatenateO(NumMaxSi) == t.max()));
  });

  test("demo", () {
    final AVLTree<num> t = new AVLTree<num>.fromIList(NumOrder, ilist([5,1,6,7,3,6]));
    expect(t.get(3), some(3));
    expect(t.get(4), none);
    expect(t.toIList(), ilist([1,3,5,6,7]));
  });

  group("AVLTreeMonoid", () => checkMonoidLaws(new AVLTreeMonoid(NumOrder), intTrees));

  group("AVLTreeFo", () => checkFoldableLaws(AVLTreeFo, intTrees));
}