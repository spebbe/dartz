import 'package:test/test.dart';
//import 'package:enumerators/enumerators.dart';
//import 'enumerators_stubs.dart';
//import 'package:enumerators/combinators.dart' as c;
import 'combinators_stubs.dart' as c;
import 'package:dartz/dartz.dart';
import 'laws.dart';

void main() {

  test("demo", () {
    Option<int> stringToInt(String intString) => catching(() => int.parse(intString)).toOption();
    final IMap<int, String> intToEnglish = imap({1: "one", 2: "two", 3: "three"});
    final IMap<String, String> englishToSwedish = imap({"one": "ett", "two": "två"});
    Option<String> intStringToSwedish(String intString) => stringToInt(intString).bind(intToEnglish.get).bind(englishToSwedish.get);

    expect(intStringToSwedish("1"), some("ett"));
    expect(intStringToSwedish("2"), some("två"));
    expect(intStringToSwedish("siffra"), none());
    expect(intStringToSwedish("3"), none());
  });
/*
  test("transformer demo", () {
    final Monad<List<Option>> M = optionTMonad(ListMP) as Monad<List<Option>>;
    final expected = [some("a!"), some("a!!"), none(), some("c!"), some("c!!")];
    expect(M.bind([some("a"), none(), some("c")], (e) => [some(e + "!"), some(e + "!!")]), expected);
  });
*/
  test("sequencing", () {
    final IList<Option<int>> l = ilist([some(1), some(2)]);
    expect(IList.sequenceOption(l), some(ilist([1,2])));
    expect(Option.sequenceIList(IList.sequenceOption(l)), l);

    final IList<Option<int>> l2 = ilist([some(1), none(), some(2)]);
    expect(IList.sequenceOption(l2), none());
    expect(Option.sequenceIList(IList.sequenceOption(l2)), ilist([none()]));
  });

  group("OptionM", () => checkMonadLaws(new OptionMonadPlus()));

  //group("OptionTMonad+Id", () => checkMonadLaws(optionTMonad(IdM)));

  //group("OptionTMonad+IList", () => checkMonadLaws(optionTMonad(IListMP)));

  group("OptionM+Foldable", () => checkFoldableMonadLaws(new OptionTraversable(), new OptionMonadPlus()));

  group("OptionMi", () => checkMonoidLaws(new OptionMonoid(NumSumMi), c.ints.map(some)));

  final intOptions = c.ints.map((i) => i%2==0 ? some(i) : none<int>());

  group("OptionTr", () => checkTraversableLaws(new OptionTraversable(), intOptions));

  group("Option FoldableOps", () => checkFoldableOpsProperties(intOptions));

  test("iterable", () {
    expect(some(1).toIterable().toList(), [1]);
    expect(none().toIterable().toList(), []);
  });

  group("Some", () {
    test("value", () {
      final some = new Some(2);
      expect(some.value, 2);
    });
  });
}