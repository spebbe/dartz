import 'package:test/test.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';

Trampoline<bool> even(int n) => n == 0 ? treturn(true) : tcall(() => odd(n-1));
Trampoline<bool> odd(int n) => n == 0 ? treturn(false) : tcall(() => even(n-1));

void main() {
  test("demo", () {
    expect(even(20017).run(), false);
    expect(odd(20017).run(), true);
  });

  group("TrampolineM", () => checkMonadLaws(TrampolineM, equality: (a, b) => a.run() == b.run()));
}
