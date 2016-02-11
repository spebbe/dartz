import 'package:test/test.dart';
import 'package:enumerators/combinators.dart' as c;
import 'package:dartz/dartz.dart';
import 'laws.dart';

void main() {
  test("demo", () {
    final Monad<List<Option>> M = optionTMonad(ListM);
    final expected = [some("a!"), some("a!!"), none, some("c!"), some("c!!")];
    expect(M.bind([some("a"), none, some("c")], (e) => [some(e + "!"), some(e + "!!")]), expected);
  });

  test("sequencing", () {
    final IList<Option<int>> l = ilist([some(1), some(2)]);
    expect(l.sequence(OptionM), some(ilist([1,2])));
    expect(l.sequence(OptionM).sequence(IListM), l);

    final IList<Option<int>> l2 = ilist([some(1), none, some(2)]);
    expect(l2.sequence(OptionM), none);
    expect(l2.sequence(OptionM).sequence(IListM), ilist([none]));
  });

  group("OptionM", () => checkMonadLaws(OptionM));

  group("OptionTMonad+Id", () => checkMonadLaws(optionTMonad(IdM)));

  group("OptionTMonad+IList", () => checkMonadLaws(optionTMonad(IListM)));

  group("OptionM+Foldable", () => checkFoldableMonadLaws(OptionFo, OptionM));

  group("OptionMi", () => checkMonoidLaws(new OptionMonoid(NumSumMi), c.ints.map(some)));

  final intOptions = c.ints.map((i) => i%2==0 ? some(i) : none);

  group("OptionTr", () => checkTraversableLaws(OptionTr, intOptions));
}