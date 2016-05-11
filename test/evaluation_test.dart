import 'package:test/test.dart';
//import 'package:propcheck/propcheck.dart';
import 'package:dartz/dartz.dart';
import 'dart:async';
//import 'laws.dart';

void main() {
  //final qc = new QuickCheck(maxSize: 300, seed: 42);

  test("demo", () async {
    final M = new EvaluationMonad(tuple2Monoid(IListMi, StringMi));

    final Evaluation inc =
        M.get() >= ((oldState) {
          final newState = oldState+1;
          return M.put(newState) >> M.write(new Tuple2(IListM.pure("State transition from $oldState to $newState"), "!"));
        });

    final Evaluation p =
        inc >>
        (M.pure("hej") >= (v) =>
         inc >>
         M.get() >= ((s) => (s == 7) ? M.asks((suffix) => v + suffix) : M.raiseError("Gaah! State wasn't 7!!!"))
        ) << inc;

    expect(await p.run("!", 5), right(tuple3(tuple2(ilist(["State transition from 5 to 6", "State transition from 6 to 7", "State transition from 7 to 8"]), "!!!"), 8, "hej!")));
    expect(await p.run("!", 6), left("Gaah! State wasn't 7!!!"));
  });

  group("EvaluationM", () {
    // TODO: async law checks
    // checkMonadLaws(qc, new EvaluationMonad(IListMi));
  });

  test("stack safety", () async {
    final M = new EvaluationMonad(UnitMi);
    final deep = M.replicate_(10000, M.modify((i) => i+1));
    expect(await deep.state(unit, 0), right(10000));
  });

  test("liftFuture", () async {
    final M = new EvaluationMonad<Unit, String, Unit, Unit>(UnitMi);

    Future<String> expensiveComputation(String input) => new Future(() => input.toUpperCase());

    final ev = M.ask() >= composeF(M.liftFuture, expensiveComputation);

    expect(await ev.value("hello", unit), right("HELLO"));
  });

  test("liftEither", () async {
    final M = new EvaluationMonad<String, IList<int>, Unit, Unit>(UnitMi);

    Either<String, int> first(IList<int> l) => l.headOption.toEither(() => "Empty list");

    final ev = M.ask() >= composeF(M.liftEither, first);

    expect(await ev.value(nil(), unit), left("Empty list"));
    expect(await ev.value(ilist([1,2,3]), unit), right(1));
  });

}