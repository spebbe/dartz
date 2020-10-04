import "package:test/test.dart";
import 'package:dartz/dartz.dart';
import 'laws.dart';
import 'proptest/PropTest.dart';

void main() {
  final pt = new PropTest();
  final intLists = Gen.listOf(Gen.ints);
  final intILists = intLists.map((l) => new IList.from(l));

  test("grab bag", () {
    final l = iota(3).map((i) => i + 1);

    final l2 = l.flatMap<int>((i) => new Cons(i * 2, new Cons(i * 2, nil())));
    expect(IListMi.append(l2, l2.reverse()), ilist([2,2,4,4,6,6,6,6,4,4,2,2]));
    expect(l2.foldLeft<int>(0, (a, b) => a + b), 24);
/*
    final Monad<Option<IList>> OptionIListM = new IListTMonad(OptionMP as Monad<Option<IList>>);
    final ol = some(l);
    final stackedResult = OptionIListM.bind(ol, (i) => i % 2 == 1 ? some(new Cons("$i!", nil<String>())) : some(nil()));
    expect(stackedResult, some(ilist(["1!", "3!"])));
*/
    final IList<int> nums = ilist([743, 59, 633, 532, 744, 234, 792, 891, 178, 356]);
    Tuple4<int, int, int, int> mapper(int i) => new Tuple4(i, 1, i, i);
    final reducer = tuple4Semigroup(NumSumMi, NumSumMi, NumMinSi, NumMaxSi);
    Tuple3<num, num, num> polish(num sum, num count, num min, num max) => new Tuple3(sum / count, min, max);
    final result = nums.foldMapO(reducer, mapper).map(tuplize4(polish));
    expect(result, some(new Tuple3(516.2, 59, 891)));

    IList<int> dup(int i) => new Cons<int>(i, new Cons<int>(i, nil()));
    expect(l.flatMap(dup), ilist([1,1,2,2,3,3]));
    expect(l.flatMap(dup), l.foldMap(IListMi, dup));

    expect(IList.sequenceEither(new IList.from([right(1), right(2), right(3)])), right(ilist([1,2,3])));

    final l1 = ilist([1,2,3,4]);
    expect(l1.traverseEither((i) => i<4 ? right(i) : left("too big")), left("too big"));
    expect(IList.sequenceEither(l1.map((i) => right(i))), right(ilist([1,2,3,4])));

    expect(l1.foldMap<num>(NumSumMi, idF<num>()), 10);
    expect(l1.foldRight<int>(0, (a, b) => a+b), 10);

    expect(ilist([2,4,6]).any((i) => i%2==0), true);
    expect(ilist([2,4,6]).any((i) => i%2==1), false);
    expect(ilist([2,4,6]).all((i) => i < 7), true);
    expect(ilist([2,4,6]).all((i) => i < 6), false);

    expect(ilist([1,2,3,4]).filter((i) => i%2==0), ilist([2,4]));

    expect(IList.flattenOption(ilist([1,2,3,4]).map((i) => i%2 == 1 ? some(i) : none())), ilist([1,3]));

    //expect(ilist([1,2,3]).foldLeftM(OptionMP, "", (p, i) => some(p+i.toString())), some("123"));
    //expect(ilist([1,2,3]).foldRightM(OptionMP, "", (i, p) => some(p+i.toString())), some("321"));
  });

  test('length', () {
    pt.check(forAll(intLists)( (l) => l.length == ilist(l).length()));
  });

  test('reverse', () {
    pt.check(forAll2(intILists, intILists)(
        (xs, ys) => xs.plus(ys).reverse() == ys.reverse().plus(xs.reverse())));
  });

  test('bind', () {
    pt.check(forAll(intILists)(
        (l) => l.bind((i) => ilist([i, i])) == IList.flattenIList(l.map((i) => ilist([i, i])))));
  });

  test('traverse', () {
    expect(ilist([2,4,6,8]).traverseOption((i) => option(i%2==0, i)), some(ilist([2,4,6,8])));
    expect(ilist([2,3,4,6]).traverseOption((i) => option(i%2==0, i)), none());
  });

  test('sequence', () {
    expect(IList.sequenceOption(ilist([2,4,6,8]).map((i) => option(i%2==0, i))), some(ilist([2,4,6,8])));
    expect(IList.sequenceOption(ilist([2,3,4,6]).map((i) => option(i%2==0, i))), none());
  });

  group("IListM", () => checkMonadLaws(IListMP));

  group("IListTMonad+Id", () => checkMonadLaws(ilistTMonad(IdM)));

  //group("IListTMonad+Either", () => checkMonadLaws(ilistTMonad(EitherM)));

  group("IListTr", () => checkTraversableLaws(IListTr, intILists));

  group("IListM+Foldable", () => checkFoldableMonadLaws(IListTr, IListMP));

  group("IListMi", () => checkMonoidLaws(ilistMi<int>(), intILists));

  test("stack safety (traverse and bind)", () async {
    final EM = new EvaluationMonad(UnitMi);
    final IList<int> massive = IdM.replicate(10000, 1).flatMap((i) => ilist([i, i]));
    expect(await massive.traverseEvaluation(UnitMi, (i) => EM.modify((s) => s + i)).state(unit, 0), right(20000));
  });

  test("stack safety (foldLeft)", () {
    final IList<int> massive = IdM.replicate(20000, 1);
    expect(massive.foldLeft<int>(0, (a,b) => a+b), 20000);
  });

  test("stack safety (foldRight)", () {
    final IList<int> massive = IdM.replicate(20000, 1);
    expect(massive.foldRight<int>(0, (a,b) => a+b), 20000);
  });

  test("stack safety (foldMap)", () {
    final IList<int> massive = IdM.replicate(20000, 1);
    expect(massive.foldMap(NumSumMi, (a) => a*2), 40000);
  });

  test("stack safety (concatenate)", () {
    final IList<num> massive = IdM.replicate(20000, 1);
    expect(massive.concatenate(NumSumMi), 20000);
  });

  test("equality", () {
    pt.check(forAll2(intILists, intILists)((l1, l2) {
      return  (l1 == l1) &&
        (l2 == l2) &&
        (l1 == l1.reverse().reverse()) &&
        (l2 == l2.reverse().reverse()) &&
        (new Cons(1, l1) != l1) &&
        ((l1 == l2) == (l1.toString() == l2.toString()));
    }));
  });

  test("to/from iterable", () {
    pt.check(forAll(intILists)((l) => l == new IList.from(l.toIterable())));
  });

  group("IList FoldableOps", () => checkFoldableOpsProperties(intILists));

  test("flattenOption", () {
    pt.check(forAll(intILists)((l) {
      final ol = l.map((i) => i % 2 == 0 ? some(i) : none<int>());
      final unitedL = IList.flattenOption(ol);
      final evenL = l.filter((i) => i % 2 == 0);
      return unitedL == evenL;
    }));
  });

  test("flattenIList", () {
    pt.check(forAll(intILists)((l) {
      final ll = l.map((i) => i % 2 == 0 ? cons(i, nil<int>()) : nil<int>());
      final flattenedL = IList.flattenIList(ll);
      final evenL = l.filter((i) => i % 2 == 0);
      return flattenedL == evenL;
    }));
  });

  test("to option", () {
    pt.check(forAll(intILists)((l) {
      final empty = l.option.fold(() => true, (_) => false);
      return empty == (l == nil());
    }));
  });

  test("asCons, head and tail", () {
    int sumThroughAsCons(IList<int> l) => l.asCons().fold(() => 0, (c) => c.head + sumThroughAsCons(c.tail));

    pt.check(forAll(intILists)((l) {
      return sumThroughAsCons(l) == l.concatenate(IntSumMi);
    }));
  });

  test("isEmpty", () => pt.check(forAll(intILists)((il) => (il.length() == 0) == il.isEmpty)));

}
