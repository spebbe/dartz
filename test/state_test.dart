import 'package:test/test.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';

void main() {
  test("demo", () {
    final State<num, String> st = StateM.pure("hej");
    final State<num, Unit> inc = State.modify((num n) => n+1);
    expect((inc >> inc >> st).map((v) => "$v!").run(5), tuple2("hej!", 7));
  });

  group("StateM", () => checkMonadLaws(StateM, equality: (a, b) => a.run(0) == b.run(0)));

  group("StateTMonad+Id", () => checkMonadLaws(new StateTMonad(IdM), equality: (a, b) => a.run(0) == b.run(0)));

  group("StateTMonad+Trampoline", () => checkMonadLaws(new StateTMonad(TrampolineM), equality: (a, b) => a.run(0).run() == b.run(0).run()));

  test("StateTMonad+Trampoline stack safety", () {
    final StateTMonad<Trampoline, int> M = new StateTMonad(TrampolineM);

    final StateT<Trampoline, int, Unit> inc20k = M.replicate_(20000, M.modify((i) => i+1));
    expect(inc20k.state(17).run(), 20017);
  });
}