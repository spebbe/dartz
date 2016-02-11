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
}