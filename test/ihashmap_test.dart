import "package:test/test.dart";
import 'package:enumerators/combinators.dart' as c;
import 'package:dartz/dartz.dart';
import 'laws.dart';
import 'package:propcheck/propcheck.dart';

void main() {
  final qc = new QuickCheck(maxSize: 300, seed: 42);
  final intMaps = c.mapsOf(c.ints, c.ints);
  final intIHashMaps = intMaps.map((m) => new IHashMap.from(m));

  test("create from Map", () {
    qc.check(forall(intMaps, (Map<int, int> m) {
      final IHashMap<int, int> im = new IHashMap.from(m);
      return m.length == im.length() &&  m.keys.every((i) => some(m[i]) == im.get(i));
    }));
  });

  test("deletion", () {
    qc.check(forall2(intMaps, intMaps, (Map<int, int> m1, Map<int, int> m2) {
      final Map<int, int> expected = new Map.from(m1);
      m2.keys.forEach((i) => expected.remove(i));
      final actual = m2.keys.fold(new IHashMap.from(m1), (IHashMap<int, int> p, k) => p.remove(k));
      return expected.keys.length == actual.length() && expected.keys.every((i) => some(expected[i]) == actual.get(i));
    }));
  });

  group("IHashMapTr", () => checkTraversableLaws(IHashMapTr, intIHashMaps));
}