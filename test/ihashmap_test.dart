import 'package:enumerators/enumerators.dart';
import "package:test/test.dart";
import 'package:enumerators/combinators.dart' as c;
import 'package:dartz/dartz.dart';
import 'laws.dart';
import 'package:propcheck/propcheck.dart';

void main() {
  final qc = new QuickCheck(maxSize: 300, seed: 42);
  final intMaps = c.mapsOf(c.ints, c.ints);
  final intIHashMaps = intMaps.map((m) => new IHashMap.from(m)) as Enumeration<IHashMap<int, int>>;

  test("create from Map", () {
    qc.check(forall(intMaps, (dynamicM) {
      final m = dynamicM as Map<int, int>;
      final IHashMap<int, int> im = new IHashMap.from(m);
      return m.length == im.length() &&  m.keys.every((i) => some(m[i]) == im[i]);
    }));
  });

  test("create from pairs", () => qc.check(forall(intIHashMaps, (dynamicM) {
    final m = dynamicM as IHashMap<int, int>;
    final mPairs = ivector(m.pairIterable());
    final mFromPairs = new IHashMap.fromPairs(mPairs, comparableOrder());
    return m == mFromPairs;
  })));

  test("deletion", () {
    qc.check(forall2(intMaps, intMaps, (dynamicM1, dynamicM2) {
      final m1 = dynamicM1 as Map<int, int>;
      final m2 = dynamicM2 as Map<int, int>;
      final Map<int, int> expected = new Map.from(m1);
      m2.keys.forEach((i) => expected.remove(i));
      final actual = m2.keys.fold(new IHashMap.from(m1), (IHashMap<int, int> p, k) => p.remove(k));
      return expected.keys.length == actual.length() && expected.keys.every((i) => some(expected[i]) == actual[i]);
    }));
  });

  test("pair iterable", () => qc.check(forall(intIHashMaps, (m) => m.foldRightKV<IList<Tuple2<int, int>>>(nil(), (k, v, IList<Tuple2<int, int>> p) => cons(tuple2(k, v), p)) == ilist((m as IHashMap<int, int>).pairIterable()))));

  test("key iterable", () => qc.check(forall(intIHashMaps, (m) => m.foldRightKV<IList<int>>(nil(), (k, v, IList<int> p) => cons(k, p)) == ilist((m as IHashMap<int, int>).keyIterable()))));

  test("value iterable", () => qc.check(forall(intIHashMaps, (m) => m.foldRightKV<IList<int>>(nil(), (k, v, IList<int> p) => cons(v, p)) == ilist((m as IHashMap<int, int>).valueIterable()))));

  group("IHashMapTr", () => checkTraversableLaws(IHashMapTr, intIHashMaps));

  group("IHashMap FoldableOps", () => checkFoldableOpsProperties(intIHashMaps));
}