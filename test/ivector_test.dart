import 'package:enumerators/enumerators.dart';
import "package:test/test.dart";
import 'package:enumerators/combinators.dart' as c;
import 'package:dartz/dartz.dart';
import 'laws.dart';


void main() {

  final intLists = c.listsOf(c.ints);
  final intIVectors = intLists.map(ivector) as Enumeration<IVector<int>>;

  group("IVectorM", () => checkMonadLaws(IVectorMP));

  group("IVectorTr", () => checkTraversableLaws(IVectorTr, intIVectors));

  group("IVectorM+Foldable", () => checkFoldableMonadLaws(IVectorTr, IVectorMP));

  group("IVectorMi", () => checkMonoidLaws(IVectorMi, intIVectors));

  test("IVector indexing", () {
    final IVector<String> v = ivector(["a", "b", "c"]);
    final IVector<String> vReversed = v.foldLeft(emptyVector(), (p, e) => p.prependElement(e));
    expect(vReversed.get(-1), none());
    expect(vReversed.get(0), some("c"));
    expect(vReversed.get(1), some("b"));
    expect(vReversed.get(2), some("a"));
    expect(vReversed.get(3), none());

    final IVector<String> v2 = v.plus(vReversed);
    expect(v2.mapWithIndex((i, s) => v2.get(i) == some(s)).concatenate(BoolAndMi), true);

    expect(v2.set(1, "d"), some(ivector(["a", "d", "c", "c", "b", "a"])));
    expect(v2.set(3, "d"), some(ivector(["a", "b", "c", "d", "b", "a"])));
    expect(v2.set(6, "ö"), none());
  });

  group("IVector FoldableOps", () => checkFoldableOpsProperties(intIVectors));

}
