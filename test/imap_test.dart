import "package:test/test.dart";
//import 'package:enumerators/combinators.dart' as c;
import 'combinators_stubs.dart' as c;
//import 'package:propcheck/propcheck.dart';
import 'propcheck_stubs.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';

void main() {
  test("demo", () {
    final boyz = ilist(["Nick Jonas", "Joe Jonas", "Isaac Hanson", "Justin Bieber", "Taylor Hanson", "Kevin Jonas", "Zac Hanson"]);

    final boyzByLastName = imap({"Jonas": ilist(["Nick", "Joe", "Kevin"]), "Hanson": ilist(["Isaac", "Taylor", "Zac"]), "Bieber": ilist(["Justin"])});

    IMap<String, IList<String>> parseName(String name) => ilist(name.split(" ")).reverse().uncons(emptyMap, singletonMap);

    final accumulatorMonoid = imapMonoid<String, IList<String>>(ilistMi());
    expect(boyz.foldMap(accumulatorMonoid, parseName), boyzByLastName);

    final numberOfBoyzByLastName = imap({"Jonas": 3, "Bieber": 1, "Hanson": 3});

    final counterMonoid = imapMonoid<String, int>(IntSumMi);
    expect(boyz.foldMap(counterMonoid, (name) => parseName(name).map(constF<IList<String>, int>(1))), numberOfBoyzByLastName);
  });

  final qc = new QuickCheck(maxSize: 300, seed: 42);
  final intMaps = c.mapsOf(c.ints, c.ints);
  final intIMaps = intMaps.map((m) => new IMap.from(IntOrder, m));

  test("create from Map", () {
    qc.check(forall(intMaps, (dynamicM) {
      final m = dynamicM as Map<int, int>;
      final IMap<int, int> im = imap(m);
      return m.keys.length == im.keys().length() &&  m.keys.every((i) => some(m[i]) == im[i]);
    }));
  });

  test("create from pairs", () => qc.check(forall(intIMaps, (dynamicM) {
    final m = dynamicM as IMap<int, int>;
    final mPairs = m.pairs();
    final mFromPairs = new IMap.fromPairs(mPairs, IntOrder);
    return m == mFromPairs;
  })));

  test("deletion", () {
    qc.check(forall2(intMaps, intMaps, (dynamicM1, dynamicM2) {
      final m1 = dynamicM1 as Map<int, int>;
      final m2 = dynamicM2 as Map<int, int>;
      final Map<int, int> expected = new Map.from(m1);
      m2.keys.forEach((i) => expected.remove(i));
      final actual = m2.keys.fold(imap(m1), (IMap<int, int> p, k) => p.remove(k));
      return expected.keys.length == actual.keys().length() && expected.keys.every((i) => some(expected[i]) == actual[i]);
    }));
  });

  test("key lookup", () {
    final o = orderBy(IntOrder, (Tuple2<int, int> t) => t.value1);
    final complexIMaps = intIMaps.map((m) => m.foldLeftKV<IMap<Tuple2<int, int>, int>>(new IMap.empty(o), (acc, k, v) => acc.put(tuple2(k, -k), v)));
    qc.check(forall(complexIMaps, (dynamicM) {
      final m = dynamicM as IMap<Tuple2<int, int>, int>;
      return m.keys().all((t) => m.getKey(tuple2(t.value1, 0)) == some(t));
    }));
  });

  test("pair iterable", () => qc.check(forall(intIMaps, (dynamicM) {
    final m = dynamicM as IMap<int, int>;
    return m.pairs() == ilist(m.pairIterable());
  })));

  test("key iterable", () => qc.check(forall(intIMaps, (dynamicM) {
    final m = dynamicM as IMap<int, int>;
    return m.keys() == ilist(m.keyIterable());
  })));

  test("value iterable", () => qc.check(forall(intIMaps, (dynamicM) {
    final m = dynamicM as IMap<int, int>;
    return  m.values() == ilist(m.valueIterable());
  })));

  test("create from iterables", () => qc.check(forall(intIMaps, (dynamicM) {
    final m = dynamicM as IMap<int, int>;
    return m == new IMap.fromIterables(m.keyIterable(), m.valueIterable(), IntOrder);
  })));

  test("min", () => qc.check(forall(intIMaps, (dynamicM) {
    final m = dynamicM as IMap<int, int>;
    return m.min() == m.keys().minimum(IntOrder).flatMap((k) => m[k].map((v) => tuple2(k, v)));
  })));

  test("max", () => qc.check(forall(intIMaps, (dynamicM) {
    final m = dynamicM as IMap<int, int>;
    return m.max() == m.keys().maximum(IntOrder).flatMap((k) => m[k].map((v) => tuple2(k, v)));
  })));

  test("minGreaterThan", () => qc.check(forall(intIMaps, (dynamicM) {
    final m = dynamicM as IMap<int, int>;
    final supremumEqualsMinimum = m.minKey().flatMap((minK) => m.minGreaterThan(minK-1)) == m.min();
    final correctSuccessorOfMinimum = m.minKey().flatMap((minK) => m.minGreaterThan(minK)) == m.pairs().tailOption.flatMap((l) => l.headOption);
    final noneGreaterThanMaximum = m.maxKey().flatMap((maxK) => m.minGreaterThan(maxK)) == none();
    return supremumEqualsMinimum && correctSuccessorOfMinimum && noneGreaterThanMaximum;
  })));

  test("maxLessThan", () => qc.check(forall(intIMaps, (dynamicM) {
    final m = dynamicM as IMap<int, int>;
    final infimumEqualsMaximum = m.maxKey().flatMap((maxK) => m.maxLessThan(maxK+1)) == m.max();
    final correctPredecessorOfMaximum = m.maxKey().flatMap((maxK) => m.maxLessThan(maxK)) == m.pairs().reverse().tailOption.flatMap((l) => l.headOption);
    final noneLessThanMinimum = m.minKey().flatMap((minK) => m.maxLessThan(minK)) == none();
    return infimumEqualsMaximum && correctPredecessorOfMaximum && noneLessThanMinimum;
  })));

  test("foldLeftKVBetween", () => qc.check(forall(intIMaps, (dynamicM) {
    final m = dynamicM as IMap<int, int>;
    final min = m.minKey()|0;
    final max = m.maxKey()|0;
    final canScanAll = m.foldLeftKVBetween<IList<int>>(min, max, nil(), (acc, _, i) => acc.appendElement(i)) == m.values();
    final canScanSome = m.foldLeftKVBetween<IList<int>>(min+1, max-1, nil(), (acc, _, i) => acc.appendElement(i)) == m.pairs().filter((kv) => kv.value1 >= min+1 && kv.value1 <= max-1).map((kv) => kv.value2);
    return canScanAll && canScanSome;
  })));

  test("foldRightKVBetween", () => qc.check(forall(intIMaps, (dynamicM) {
    final m = dynamicM as IMap<int, int>;
    final min = m.minKey()|0;
    final max = m.maxKey()|0;
    final canScanAll = m.foldRightKVBetween<IList<int>>(min, max, nil(), (_, i, acc) => acc.appendElement(i)) == m.values().reverse();
    final canScanSome = m.foldRightKVBetween<IList<int>>(min+1, max-1, nil(), (_, i, acc) => acc.appendElement(i)) == m.pairs().filter((kv) => kv.value1 >= min+1 && kv.value1 <= max-1).map((kv) => kv.value2).reverse();
    return canScanAll && canScanSome;
  })));

  test("cata", () => qc.check(forall(intIMaps, (dynamicM) {
    final m = dynamicM as IMap<int, int>;
    final cataed = m.cata<IMap<int, int>>(new IMap.empty(IntOrder), id, (acc, k, v, cataLeft, cataRight) => cataRight(cataLeft(acc.put(k, v))));
    return m == cataed;
  })));

  group("IMapTr", () => checkTraversableLaws(IMapTr, intIMaps));

  group("imapMonoid(IListMi)", () => checkMonoidLaws(imapMonoidWithOrder<int, IList<int>>(ilistMi<int>(), IntOrder), c.ints.map((i) => new IMap.from(IntOrder, {i: ilist([i])}))));

  group("IMapMi", () => checkMonoidLaws(IMapMi, c.ints.map((i) => new IMap.from(comparableOrder(), {i: i}))));

  group("IMap FoldableOps", () => checkFoldableOpsProperties(intIMaps));

  test("isEmpty", () => qc.check(forall(intIMaps, (IMap<int, int> m) => (m.length() == 0) == m.isEmpty)));

}
