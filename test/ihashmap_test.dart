import "package:test/test.dart";
import 'package:dartz/dartz.dart';
import 'ihashset_test.dart';
import 'laws.dart';
import 'proptest/PropTest.dart';

void main() {
  final pt = new PropTest();
  final intMaps = Gen.mapOf(Gen.ints, Gen.ints);
  final intIHashMaps = intMaps.map((m) => new IHashMap.from(m));
  final hashDegenerateIHashMaps = Gen.mapOf(Gen.ints.map((i) => new HashDegenerate(i)), Gen.ints)
    .map((m) => new IHashMap.from(m));

  test("create from Map", () {
    pt.check(forAll(intMaps)((m) {
      final IHashMap<int, int> im = new IHashMap.from(m);
      return m.length == im.length() &&  m.keys.every((i) => some(m[i]) == im[i]);
    }));
  });

  test("create from pairs", () => pt.check(forAll(intIHashMaps)((m) {
    final mPairs = ivector(m.pairIterable());
    final mFromPairs = new IHashMap.fromPairs(mPairs);
    return m == mFromPairs;
  })));

  test("deletion", () {
    pt.check(forAll2(intMaps, intMaps)((m1, m2) {
      final Map<int, int> expected = new Map.from(m1);
      m2.keys.forEach((i) => expected.remove(i));
      final actual = m2.keys.fold(new IHashMap.from(m1), (IHashMap<int, int> p, k) => p.remove(k));
      return expected.keys.length == actual.length() && expected.keys.every((i) => some(expected[i]) == actual[i]);
    }));
  });

  test("pair iterable", () => pt.check(forAll(intIHashMaps)((m) => m.foldRightKV<IList<Tuple2<int, int>>>(nil<Tuple2<int, int>>(), (k, v, IList<Tuple2<int, int>> p) => cons(tuple2(k, v), p)) == ilist(m.pairIterable()))));

  test("key iterable", () => pt.check(forAll(intIHashMaps)((m) => m.foldRightKV<IList<int>>(nil<int>(), (k, v, IList<int> p) => cons(k, p)) == ilist(m.keyIterable()))));

  test("value iterable", () => pt.check(forAll(intIHashMaps)((m) => m.foldRightKV<IList<int>>(nil<int>(), (k, v, IList<int> p) => cons(v, p)) == ilist(m.valueIterable()))));

  group("IHashMapTr", () => checkTraversableLaws(IHashMapTr, intIHashMaps));

  group("IHashMap FoldableOps", () => checkFoldableOpsProperties(intIHashMaps));

  test("hash degenerate isEmpty", () =>
    pt.check(forAll(hashDegenerateIHashMaps)((m) {
      final emptied = m.foldLeftKV(m, (IHashMap<HashDegenerate, int> previous, k, _) => previous.remove(k));
        return emptied.isEmpty;
    })));

}