import 'package:enumerators/enumerators.dart';
import 'package:propcheck/propcheck.dart';
import "package:test/test.dart";
import 'package:enumerators/combinators.dart' as c;
import 'package:dartz/dartz.dart';
import 'laws.dart';


void main() {
  final qc = new QuickCheck(maxSize: 300, seed: 42);
  final intLists = c.listsOf(c.ints);
  final intIVectors = intLists.map(ivector) as Enumeration<IVector<int>>;

  group("IVectorM", () => checkMonadLaws(IVectorMP));

  group("IVectorTr", () => checkTraversableLaws(IVectorTr, intIVectors));

  group("IVectorM+Foldable", () => checkFoldableMonadLaws(IVectorTr, IVectorMP));

  group("IVectorMi", () => checkMonoidLaws(IVectorMi, intIVectors));

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
    qc.check(forall2(intLists, c.ints, (List<int> l, int i) {
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
    qc.check(forall(intLists, (List<int> l) {
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
    qc.check(forall(intLists, (List<int> l) {
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
    qc.check(forall(intLists, (List<int> l) {
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
    qc.check(forall(intLists, (List<int> l) {
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
    qc.check(forall(intIVectors, (IVector<int> v) {
      final partialSum = v.foldLeftWithIndexBetween<int>(1, v.length()-2, 0, (sum, _, i) => sum+i);
      return partialSum == v.dropFirst().dropLast().concatenate(IntSumMi);
    }));
  });

  test("IVector foldRightWithIndexBetween", () {
    qc.check(forall(intIVectors, (IVector<int> v) {
      final partialSum = v.foldRightWithIndexBetween<int>(1, v.length()-2, 0, (_, i, sum) => sum+i);
      return partialSum == v.dropFirst().dropLast().concatenate(IntSumMi);
    }));
  });

  group("IVector FoldableOps", () => checkFoldableOpsProperties(intIVectors));

  test("iterable", () => qc.check(forall(intIVectors, (IVector<int> v) => v == ivector(v.toIterable()))));

}
