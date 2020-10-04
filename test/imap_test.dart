import "package:test/test.dart";
import 'package:dartz/dartz.dart';
import 'laws.dart';
import 'proptest/PropTest.dart';

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

  final pt = new PropTest();
  final intMaps = Gen.mapOf(Gen.ints, Gen.ints);
  final intIMaps = intMaps.map((m) => new IMap.from(IntOrder, m));

  test("create from Map", () {
    pt.check(forAll(intMaps)((m) {
      final IMap<int, int> im = imap(m);
      return m.keys.length == im.keys().length() &&  m.keys.every((i) => some(m[i]) == im[i]);
    }));
  });

  test("create from pairs", () => pt.check(forAll(intIMaps)((m) {
    final mPairs = m.pairs();
    final mFromPairs = new IMap.fromPairs(mPairs, IntOrder);
    return m == mFromPairs;
  })));

  test("deletion", () {
    pt.check(forAll2(intMaps, intMaps)((m1, m2) {
      final Map<int, int> expected = new Map.from(m1);
      m2.keys.forEach((i) => expected.remove(i));
      final actual = m2.keys.fold(imap(m1), (IMap<int, int> p, k) => p.remove(k));
      return expected.keys.length == actual.keys().length() && expected.keys.every((i) => some(expected[i]) == actual[i]);
    }));
  });

  test("key lookup", () {
    final o = orderBy(IntOrder, (Tuple2<int, int> t) => t.value1);
    final complexIMaps = intIMaps.map((m) => m.foldLeftKV<IMap<Tuple2<int, int>, int>>(new IMap.empty(o), (acc, k, v) => acc.put(tuple2(k, -k), v)));
    pt.check(forAll(complexIMaps)((m) {
      return m.keys().all((t) => m.getKey(tuple2(t.value1, 0)) == some(t));
    }));
  });

  test("pair iterable", () => pt.check(forAll(intIMaps)((m) {
    return m.pairs() == ilist(m.pairIterable());
  })));

  test("key iterable", () => pt.check(forAll(intIMaps)((m) {
    return m.keys() == ilist(m.keyIterable());
  })));

  test("value iterable", () =>  pt.check(forAll(intIMaps)((m) {
    return  m.values() == ilist(m.valueIterable());
  })));

  test("create from iterables", () =>  pt.check(forAll(intIMaps)((m) {
    return m == new IMap.fromIterables(m.keyIterable(), m.valueIterable(), IntOrder);
  })));

  test("min", () =>  pt.check(forAll(intIMaps)((m) {
    return m.min() == m.keys().minimum(IntOrder).flatMap((k) => m[k].map((v) => tuple2(k, v)));
  })));

  test("max", () =>  pt.check(forAll(intIMaps)((m) {
    return m.max() == m.keys().maximum(IntOrder).flatMap((k) => m[k].map((v) => tuple2(k, v)));
  })));

  test("minGreaterThan", () =>  pt.check(forAll(intIMaps)((m) {
    final supremumEqualsMinimum = m.minKey().flatMap((minK) => m.minGreaterThan(minK-1)) == m.min();
    final correctSuccessorOfMinimum = m.minKey().flatMap((minK) => m.minGreaterThan(minK)) == m.pairs().tailOption.flatMap((l) => l.headOption);
    final noneGreaterThanMaximum = m.maxKey().flatMap((maxK) => m.minGreaterThan(maxK)) == none();
    return supremumEqualsMinimum && correctSuccessorOfMinimum && noneGreaterThanMaximum;
  })));

  test("maxLessThan", () =>  pt.check(forAll(intIMaps)((m) {
    final infimumEqualsMaximum = m.maxKey().flatMap((maxK) => m.maxLessThan(maxK+1)) == m.max();
    final correctPredecessorOfMaximum = m.maxKey().flatMap((maxK) => m.maxLessThan(maxK)) == m.pairs().reverse().tailOption.flatMap((l) => l.headOption);
    final noneLessThanMinimum = m.minKey().flatMap((minK) => m.maxLessThan(minK)) == none();
    return infimumEqualsMaximum && correctPredecessorOfMaximum && noneLessThanMinimum;
  })));

  test("foldLeftKVBetween", () =>  pt.check(forAll(intIMaps)((m) {
    final min = m.minKey()|0;
    final max = m.maxKey()|0;
    final canScanAll = m.foldLeftKVBetween(min, max, nil(), (acc, _, i) => acc.appendElement(i)) == m.values();
    final canScanSome = m.foldLeftKVBetween(min+1, max-1, nil(), (acc, _, i) => acc.appendElement(i)) == m.pairs().filter((kv) => kv.value1 >= min+1 && kv.value1 <= max-1).map((kv) => kv.value2);
    return canScanAll && canScanSome;
  })));

  test("foldRightKVBetween", () =>  pt.check(forAll(intIMaps)((m) {
    final min = m.minKey()|0;
    final max = m.maxKey()|0;
    final canScanAll = m.foldRightKVBetween(min, max, nil(), (_, i, acc) => acc.appendElement(i)) == m.values().reverse();
    final canScanSome = m.foldRightKVBetween(min+1, max-1, nil(), (_, i, acc) => acc.appendElement(i)) == m.pairs().filter((kv) => kv.value1 >= min+1 && kv.value1 <= max-1).map((kv) => kv.value2).reverse();
    return canScanAll && canScanSome;
  })));

  test("cata", () =>  pt.check(forAll(intIMaps)((m) {
    final cataed = m.cata<IMap<int, int>>(new IMap.empty(IntOrder), id, (acc, k, v, cataLeft, cataRight) => cataRight(cataLeft(acc.put(k, v))));
    return m == cataed;
  })));

  group("IMapTr", () => checkTraversableLaws(IMapTr, intIMaps));

  group("imapMonoid(IListMi)", () => checkMonoidLaws(imapMonoidWithOrder<int, IList<int>>(ilistMi<int>(), IntOrder), Gen.ints.map((i) => new IMap.from(IntOrder, {i: ilist([i])}))));

  group("IMapMi", () => checkMonoidLaws(IMapMi, Gen.ints.map((i) => new IMap.from(comparableOrder(), {i: i}))));

  group("IMap FoldableOps", () => checkFoldableOpsProperties(intIMaps));

  test("isEmpty", () => pt.check(forAll(intIMaps)((m) => (m.length() == 0) == m.isEmpty)));

  final _IntS = stateM<int>();

  test("traverseState", () =>
    pt.check(forAll(intIMaps)((m) =>
    m.traverseState((k, v) => _IntS.modify((s) => s+v).replace("$k -> $v")).run(0) ==
      tuple2(m.mapKV((k, v) => "$k -> $v"), m.concatenate(IntSumMi)))));

  test("traverseState_", () =>
    pt.check(forAll(intIMaps)((m) => m.traverseState_((k, v) => _IntS.modify((s) => s+v)).state(0) == m.concatenate(IntSumMi))));

  final _IntE = new EvaluationMonad<Unit, Unit, Unit, int>(UnitMi);

  test("traverseEvaluation_", () =>
    pt.check(forAll(intIMaps)(
        (m) async => await m.traverseEvaluation_(UnitMi, (k, v) => _IntE.modify((s) => s+v)).state(unit, 0) ==
          right(m.concatenate(IntSumMi)))));
}
