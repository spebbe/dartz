import "package:test/test.dart";
//import 'package:enumerators/combinators.dart' as c;
import 'combinators_stubs.dart' as c;
//import 'package:propcheck/propcheck.dart';
import 'propcheck_stubs.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';


void main() {
  final qc = new QuickCheck(maxSize: 300, seed: 42);
  final intLists = c.listsOf(c.ints);
  final intIVectors = intLists.map(ivector);

  group("IVectorM", () => checkMonadLaws(IVectorMP));

  group("IVectorTr", () => checkTraversableLaws(IVectorTr, intIVectors));

  group("IVectorM+Foldable", () => checkFoldableMonadLaws(IVectorTr, IVectorMP));

  group("IVectorMi", () => checkMonoidLaws(ivectorMi<int>(), intIVectors));

  test("IVector indexing", () {
    final IVector<String> v = ivector(["a", "b", "c"]);
    final IVector<String> vReversed = v.foldLeft(emptyVector(), (p, e) => p.prependElement(e));
    expect(vReversed[-1], none());
    expect(vReversed[0], some("c"));
    expect(vReversed[1], some("b"));
    expect(vReversed[2], some("a"));
    expect(vReversed[3], none());

    final IVector<String> v2 = v.plus(vReversed);
    expect(v2.mapWithIndex((i, s) => v2[i] == some(s)).concatenate(BoolAndMi), true);

    expect(v2.set(1, "d"), some(ivector(["a", "d", "c", "c", "b", "a"])));
    expect(v2.set(3, "d"), some(ivector(["a", "b", "c", "d", "b", "a"])));
    expect(v2.set(6, "ö"), none());
  });

  test("IVector foldLeftWithIndex", () {
    final v = ivector(["c"]).prependElement("b").prependElement("a").appendElement("d").appendElement("e");
    final vIndices = v.foldLeftWithIndex(nil<String>(), (IList<String> acc, i, v) => cons("$i$v", acc)).reverse();
    expect(vIndices, ilist(["0a", "1b", "2c", "3d", "4e"]));
  });

  test("IVector foldRightWithIndex", () {
    final v = ivector(["c"]).prependElement("b").prependElement("a").appendElement("d").appendElement("e");
    final vIndices = v.foldRightWithIndex(nil<String>(), (i, v, IList<String> acc) => cons("$i$v", acc));
    expect(vIndices, ilist(["0a", "1b", "2c", "3d", "4e"]));
  });

  test("IVector update", () {
    qc.check(forall2(intLists, c.ints, (dynamicL, dynamicI) {
      final l = dynamicL as List<int>;
      final i = dynamicI as int;
      if (l.length == 0) {
        return true;
      } else {
        final index = i % l.length;
        final im = new IVector.from(l).setIfPresent(index, i);
        l[index] = i;
        return im == new IVector.from(l);
      }
    }));
  });

  test("IVector removeFirst", () {
    qc.check(forall(intLists, (dynamicL) {
      final l = dynamicL as List<int>;
      final v = new IVector.from(l);
      if (l.length > 0) {
        final removed = l.removeAt(0);
        return v.removeFirst().fold(() => false, (t) => t.value1 == removed && t.value2 == new IVector.from(l));
      } else {
        return v.removeFirst() == none();
      }
    }));
  });

  test("IVector dropFirst", () {
    qc.check(forall(intLists, (dynamicL) {
      final l = dynamicL as List<int>;
      final v = new IVector.from(l);
      if (l.length > 0) {
        l.removeAt(0);
        return v.dropFirst() == new IVector.from(l);
      } else {
        return v.dropFirst() == v;
      }
    }));
  });

  test("IVector removeLast", () {
    qc.check(forall(intLists, (dynamicL) {
      final l = dynamicL as List<int>;
      final v = new IVector.from(l);
      if (l.length > 0) {
        final removed = l.removeLast();
        return v.removeLast().fold(() => false, (t) => t.value1 == removed && t.value2 == new IVector.from(l));
      } else {
        return v.removeLast() == none();
      }
    }));
  });

  test("IVector dropLast", () {
    qc.check(forall(intLists, (dynamicL) {
      final l = dynamicL as List<int>;
      final v = new IVector.from(l);
      if (l.length > 0) {
        l.removeLast();
        return v.dropLast() == new IVector.from(l);
      } else {
        return v.dropLast() == v;
      }
    }));
  });

  test("IVector foldLeftWithIndexBetween", () {
    qc.check(forall(intIVectors, (dynamicV) {
      final v = dynamicV as IVector<int>;
      final partialSum = v.foldLeftWithIndexBetween<int>(1, v.length()-2, 0, (sum, _, i) => sum+i);
      return partialSum == v.dropFirst().dropLast().concatenate(IntSumMi);
    }));
  });

  test("IVector foldRightWithIndexBetween", () {
    qc.check(forall(intIVectors, (IVector<int> v) {
      final partialSum = v.foldRightWithIndexBetween<int>(1, (v).length()-2, 0, (_, i, sum) => sum+i);
      return partialSum == v.dropFirst().dropLast().concatenate(IntSumMi);
    }));
  });

  group("IVector FoldableOps", () => checkFoldableOpsProperties(intIVectors));

  test("iterable", () => qc.check(forall(intIVectors, (v) => v == ivector((v as IVector<int>).toIterable()))));

  test("flattenOption", () {
    qc.check(forall(intIVectors, (IVector<int> v) {
      final ov = v.map((i) => i % 2 == 0 ? some(i) : none<int>());
      final unitedV = IVector.flattenOption(ov);
      final evenV = v.filter((i) => i % 2 == 0);
      return unitedV == evenV;
    }));
  });

  test("flattenIVector", () {
    qc.check(forall(intIVectors, (dynamicV) {
      final v = dynamicV as IVector<int>;
      final vv = v.map((int i) => i % 2 == 0 ? ivector([i]) : emptyVector<int>());
      final flattenedV = IVector.flattenIVector(vv);
      final evenV = v.filter((i) => i % 2 == 0);
      return flattenedV == evenV;
    }));
  });

  test("isEmpty", () => qc.check(forall(intIVectors, (IVector<int> v) => (v.length() == 0) == v.isEmpty)));

  test("indexOf", () {
    qc.check(forall3(intIVectors, c.ints, c.ints, (IVector<int> v, int i, int s) {
      final index = v.isEmpty ? 0 : i.abs() % v.length();
      final start = v.isEmpty ? 0 : s.abs() % v.length();
      final element = v[index]|0;
      return v.indexOf(element, start: start)|-1 == v.toIterable().toList().indexOf(element, start);
    }));
  });

  test("indexOf manual", () {
    final v = ivector(["x", "b"]).dropFirst().prependElement("a").appendElement("c").plus(ivector(["a", "b", "c"]));
    expect(v.indexOf("a"), some(0));
    expect(v.indexOf("b"), some(1));
    expect(v.indexOf("c"), some(2));
    expect(v.indexOf("a", start: 1), some(3));
    expect(v.indexOf("a", start: 100), none());
    expect(v.indexOf("d"), none());
  });
}
