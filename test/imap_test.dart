import 'package:enumerators/enumerators.dart';
import "package:test/test.dart";
import 'package:enumerators/combinators.dart' as c;
import 'package:propcheck/propcheck.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';

void main() {
  test("demo", () {
    final boyz = ilist(["Nick Jonas", "Joe Jonas", "Isaac Hanson", "Justin Bieber", "Taylor Hanson", "Kevin Jonas", "Zac Hanson"]);

    final boyzByLastName = imap({"Jonas": ilist(["Nick", "Joe", "Kevin"]), "Hanson": ilist(["Isaac", "Taylor", "Zac"]), "Bieber": ilist(["Justin"])});

    IMap<String, IList<String>> parseName(String name) => ilist(name.split(" ")).reverse().uncons(emptyMap, singletonMap);

    expect(boyz.foldMap(imapMonoid(IListMi), parseName), boyzByLastName);

    final numberOfBoyzByLastName = imap({"Jonas": 3, "Bieber": 1, "Hanson": 3});
    expect(boyz.foldMap(imapMonoid(NumSumMi), (name) => parseName(name).map(constF<IList<String>, int>(1))), numberOfBoyzByLastName);
  });

  final qc = new QuickCheck(maxSize: 300, seed: 42);
  final intMaps = c.mapsOf(c.ints, c.ints) as Enumeration<Map<int, int>>;
  final intIMaps = intMaps.map(imap) as Enumeration<IMap<int, int>>;

  test("create from Map", () {
    qc.check(forall(intMaps, (Map<int, int> m) {
      final IMap<int, int> im = imap(m);
      return m.keys.length == im.keys().length() &&  m.keys.every((i) => some(m[i]) == im[i]);
    }));
  });

  test("deletion", () {
    qc.check(forall2(intMaps, intMaps, (Map<int, int> m1, Map<int, int> m2) {
      final Map<int, int> expected = new Map.from(m1);
      m2.keys.forEach((i) => expected.remove(i));
      final actual = m2.keys.fold(imap(m1), (IMap<int, int> p, k) => p.remove(k));
      return expected.keys.length == actual.keys().length() && expected.keys.every((i) => some(expected[i]) == actual[i]);
    }));
  });

  test("pair iterable", () => qc.check(forall(intIMaps, (IMap<int, int> m) => m.pairs() == ilist(m.pairIterable()))));

  test("key iterable", () => qc.check(forall(intIMaps, (IMap<int, int> m) => m.keys() == ilist(m.keyIterable()))));

  test("value iterable", () => qc.check(forall(intIMaps, (IMap<int, int> m) => m.values() == ilist(m.valueIterable()))));

  test("create from iterables", () => qc.check(forall(intIMaps, (IMap<int, int> m) => m == new IMap.fromIterables(m.keyIterable(), m.valueIterable()))));

  test("min", () => qc.check(forall(intIMaps, (IMap<int, int> m) {
    return m.min() == m.keys().minimum(IntOrder).flatMap((k) => m[k].map((v) => tuple2(k, v)));
  })));

  test("max", () => qc.check(forall(intIMaps, (IMap<int, int> m) {
    return m.max() == m.keys().maximum(IntOrder).flatMap((k) => m[k].map((v) => tuple2(k, v)));
  })));

  test("minGreaterThan", () => qc.check(forall(intIMaps, (IMap<int, int> m) {
    final supremumEqualsMinimum = m.minKey().flatMap((minK) => m.minGreaterThan(minK-1)) == m.min();
    final correctSuccessorOfMinimum = m.minKey().flatMap((minK) => m.minGreaterThan(minK)) == m.pairs().tailOption.flatMap((l) => l.headOption);
    final noneGreaterThanMaximum = m.maxKey().flatMap((maxK) => m.minGreaterThan(maxK)) == none();
    return supremumEqualsMinimum && correctSuccessorOfMinimum && noneGreaterThanMaximum;
  })));

  test("maxLessThan", () => qc.check(forall(intIMaps, (IMap<int, int> m) {
    final infimumEqualsMaximum = m.maxKey().flatMap((maxK) => m.maxLessThan(maxK+1)) == m.max();
    final correctPredecessorOfMaximum = m.maxKey().flatMap((maxK) => m.maxLessThan(maxK)) == m.pairs().reverse().tailOption.flatMap((l) => l.headOption);
    final noneLessThanMinimum = m.minKey().flatMap((minK) => m.maxLessThan(minK)) == none();
    return infimumEqualsMaximum && correctPredecessorOfMaximum && noneLessThanMinimum;
  })));

  test("foldLeftKVBetween", () => qc.check(forall(intIMaps, (IMap<int, int> m) {
    final min = m.minKey()|0;
    final max = m.maxKey()|0;
    final canScanAll = m.foldLeftKVBetween(min, max, nil(), (acc, _, i) => acc.appendElement(i)) == m.values();
    final canScanSome = m.foldLeftKVBetween(min+1, max-1, nil(), (acc, _, i) => acc.appendElement(i)) == m.pairs().filter((kv) => kv.value1 >= min+1 && kv.value1 <= max-1).map((kv) => kv.value2);
    return canScanAll && canScanSome;
  })));

  test("foldRightKVBetween", () => qc.check(forall(intIMaps, (IMap<int, int> m) {
    final min = m.minKey()|0;
    final max = m.maxKey()|0;
    final canScanAll = m.foldRightKVBetween(min, max, nil(), (_, i, acc) => acc.appendElement(i)) == m.values().reverse();
    final canScanSome = m.foldRightKVBetween(min+1, max-1, nil(), (_, i, acc) => acc.appendElement(i)) == m.pairs().filter((kv) => kv.value1 >= min+1 && kv.value1 <= max-1).map((kv) => kv.value2).reverse();
    return canScanAll && canScanSome;
  })));

  group("IMapTr", () => checkTraversableLaws(IMapTr, intIMaps));

  group("imapMonoid(IListMi)", () => checkMonoidLaws(imapMonoid(IListMi), c.ints.map((i) => imap({i: ilist([i])}))));

  group("IMapMi", () => checkMonoidLaws(IMapMi, c.ints.map((i) => imap({i: i}))));

  group("IMap FoldableOps", () => checkFoldableOpsProperties(intIMaps));
}
