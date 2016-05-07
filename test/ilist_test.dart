import "package:test/test.dart";
import 'package:enumerators/combinators.dart' as c;
import 'package:propcheck/propcheck.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';

void main() {
  final qc = new QuickCheck(maxSize: 300, seed: 42);
  final intLists = c.listsOf(c.ints);
  final intILists = intLists.map((l) => new IList.from(l));

  test("grab bag", () {
    final l = iota(3).map((i) => i + 1);

    final l2 = l.flatMap((i) => new Cons(i * 2, new Cons(i * 2, Nil)));
    expect(IListMi.append(l2, l2.reverse()), ilist([2,2,4,4,6,6,6,6,4,4,2,2]));
    expect(l2.foldLeft(0, (a, b) => a + b), 24);

    final Monad<Option<IList>> OptionIListM = new IListTMonad(OptionM);
    final ol = some(l);
    final stackedResult = OptionIListM.bind(ol, (i) => i % 2 == 1 ? some(new Cons("$i!", Nil)) : some(Nil));
    expect(stackedResult, some(ilist(["1!", "3!"])));

    final IList<int> nums = ilist([743, 59, 633, 532, 744, 234, 792, 891, 178, 356]);
    Tuple4<int, int, int, int> mapper(int i) => new Tuple4(i, 1, i, i);
    final reducer = tuple4Semigroup(NumSumMi, NumSumMi, NumMinSi, NumMaxSi);
    Tuple3<double, int, int> polish(int sum, int count, int min, int max) => new Tuple3(sum / count, min, max);
    final result = nums.foldMapO(reducer, mapper).map(tuplize4(polish));
    expect(result, some(new Tuple3(516.2, 59, 891)));

    IList<int> dup(int i) => new Cons<int>(i, new Cons<int>(i, Nil));
    expect(l.flatMap(dup), ilist([1,1,2,2,3,3]));
    expect(l.flatMap(dup), l.foldMap(IListMi, dup));

    expect(EitherM.sequenceL(new IList.from([right(1), right(2), right(3)])), right(ilist([1,2,3])));

    final l1 = ilist([1,2,3,4]);
    expect(IListTr.traverse(EitherM, l1, (i) => i<4 ? right(i) : left("too big")), left("too big"));
    expect(IListTr.sequence(EitherM, l1.map((i) => right(i))), right(ilist([1,2,3,4])));

    expect(IListTr.foldMap(NumSumMi, l1, id), 10);
    expect(IListTr.foldRight(l1, 0, (a, b) => a+b), 10);

    expect(ilist([2,4,6]).any((i) => i%2==0), true);
    expect(ilist([2,4,6]).any((i) => i%2==1), false);
    expect(ilist([2,4,6]).all((i) => i < 7), true);
    expect(ilist([2,4,6]).all((i) => i < 6), false);

    expect(ilist([1,2,3,4]).filter((i) => i%2==0), ilist([2,4]));

    expect(ilist([1,2,3,4]).map((i) => i%2 == 1 ? some(i) : none()).unite(OptionFo), ilist([1,3]));

    expect(ilist([1,2,3]).foldLeftM(OptionM, "", (p, i) => some(p+i.toString())), some("123"));
    expect(ilist([1,2,3]).foldRightM(OptionM, "", (i, p) => some(p+i.toString())), some("321"));
  });

  test('length', () {
    qc.check(forall(intLists, (List<int> l) => l.length == ilist(l).length()));
  });

  test('reverse', () {
    qc.check(forall2(intILists, intILists,
        (xs, ys) => xs.plus(ys).reverse() == ys.reverse().plus(xs.reverse())));
  });

  test('bind', () {
    qc.check(forall(intILists,
        (l) => l.bind((i) => ilist([i, i])) == l.map((i) => ilist([i, i])).join()));
  });

  test('traverse', () {
    expect(ilist([2,4,6,8]).traverse(OptionM, (i) => option(i%2==0, i)), some(ilist([2,4,6,8])));
    expect(ilist([2,3,4,6]).traverse(OptionM, (i) => option(i%2==0, i)), none());
  });

  test('sequence', () {
    expect(ilist([2,4,6,8]).map((i) => option(i%2==0, i)).sequence(OptionM), some(ilist([2,4,6,8])));
    expect(ilist([2,3,4,6]).map((i) => option(i%2==0, i)).sequence(OptionM), none());
  });

  group("IListM", () => checkMonadLaws(IListM));

  group("IListTMonad+Id", () => checkMonadLaws(ilistTMonad(IdM)));

  group("IListTMonad+Either", () => checkMonadLaws(ilistTMonad(EitherM)));

  group("IListTr", () => checkTraversableLaws(IListTr, intILists));

  group("IListM+Foldable", () => checkFoldableMonadLaws(IListFo, IListM));

  group("IListMi", () => checkMonoidLaws(IListMi, intILists));

  test("stack safety (traverse and bind)", () async {
    final EM = new EvaluationMonad(UnitMi);
    final IList<int> massive = IdM.replicate(10000, 1).flatMap((i) => ilist([i, i]));
    expect(await massive.traverse(EM, (i) => EM.modify((s) => s + i)).state(unit, 0), right(20000));
  });

  test("stack safety (foldLeft)", () {
    final IList<int> massive = IdM.replicate(20000, 1);
    expect(massive.foldLeft(0, (a,b) => a+b), 20000);
  });

  test("stack safety (foldRight)", () {
    final IList<int> massive = IdM.replicate(20000, 1);
    expect(massive.foldRight(0, (a,b) => a+b), 20000);
  });

  test("stack safety (foldMap)", () {
    final IList<int> massive = IdM.replicate(20000, 1);
    expect(massive.foldMap(NumSumMi, (a) => a*2), 40000);
  });

  test("stack safety (concatenate)", () {
    final IList<int> massive = IdM.replicate(20000, 1);
    expect(massive.concatenate(NumSumMi), 20000);
  });

  test("equality", () {
    qc.check(forall2(intILists, intILists,
        (IList<int> l1, IList<int> l2) =>
        (l1 == l1) &&
            (l2 == l2) &&
            (l1 == l1.reverse().reverse()) &&
            (l2 == l2.reverse().reverse()) &&
            (new Cons(1, l1) != l1) &&
            ((l1 == l2) == (l1.toString() == l2.toString()))));
  });

  test("to/from iterable", () {
    qc.check(forall(intILists, (IList l) => l == new IList.from(l.toIterable())));
  });

}
