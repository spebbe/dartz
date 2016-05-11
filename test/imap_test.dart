import "package:test/test.dart";
import 'package:enumerators/combinators.dart' as c;
import 'package:propcheck/propcheck.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';

IMap<String, IList<String>> parseName(String name) {
  final IList<String> parts = ilist(name.split(" ")).reverse();
  return (parts.headOption >= (last) => parts.tailOption.map((first) => imap({last: first}))) | imap({}) as IMap<String, IList<String>>;
}

void main() {
  test("demo", () {
    final boyz = ilist(["Nick Jonas", "Joe Jonas", "Isaac Hanson", "Justin Bieber", "Taylor Hanson", "Kevin Jonas", "Zac Hanson"]);

    final boyzByLastName = imap({"Jonas": ilist(["Nick", "Joe", "Kevin"]), "Hanson": ilist(["Isaac", "Taylor", "Zac"]), "Bieber": ilist(["Justin"])});
    expect(boyz.foldMap(imapMonoid(IListMi), parseName), boyzByLastName);

    final numberOfBoyzByLastName = imap({"Jonas": 3, "Bieber": 1, "Hanson": 3});
    expect(boyz.foldMap(imapMonoid(NumSumMi), (name) => parseName(name).map(constF/*<IList<String>, int>*/(1))), numberOfBoyzByLastName);
  });

  final qc = new QuickCheck(maxSize: 300, seed: 42);
  final intMaps = c.mapsOf(c.ints, c.ints);
  final intIMaps = intMaps.map(imap);

  test("create from Map", () {
    qc.check(forall(intMaps, (Map<int, int> m) {
      final IMap<int, int> im = imap(m);
      return m.keys.length == im.keys().length() &&  m.keys.every((i) => some(m[i]) == im.get(i));
    }));
  });

  test("deletion", () {
    qc.check(forall2(intMaps, intMaps, (Map<int, int> m1, Map<int, int> m2) {
      final Map<int, int> expected = new Map.from(m1);
      m2.keys.forEach((i) => expected.remove(i));
      final actual = m2.keys.fold(imap(m1), (IMap<int, int> p, k) => p.remove(k));
      return expected.keys.length == actual.keys().length() &&  expected.keys.every((i) => some(expected[i]) == actual.get(i));
    }));
  });

  group("IMapTr", () => checkTraversableLaws(IMapTr, intIMaps));

  group("imapMonoid(IListMi)", () => checkMonoidLaws(imapMonoid(IListMi), c.ints.map((i) => imap({i: ilist([i])}))));

  group("IMapMi", () => checkMonoidLaws(IMapMi, c.ints.map((i) => imap({i: i}))));

}
