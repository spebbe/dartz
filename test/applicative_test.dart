import 'package:test/test.dart';
import 'package:dartz/dartz.dart';

void main() {
  group("Applicative composition", () {
    final Applicative<Either<String, Option<IList>>> A = EitherA.composeA(OptionA.composeA(IListA));

    test("succeed", () {
      expect(A.map3(A.pure("hello"), right(some(ilist(["functor", "applicative"]))), A.pure("!"), (a,b,c) => a+" "+b+c),
          right(some(ilist(["hello functor!", "hello applicative!"]))));
    });

    test("fail 1", () {
      expect(A.map3(A.pure("hello"), right(some(ilist(["functor", "applicative"]))), left("out of exclamation marks..."), (a,b,c) => a+" "+b+c),
          left("out of exclamation marks..."));
    });

    test("fail 2", () {
      expect(A.map3(A.pure("hello"), right(some(ilist(["functor", "applicative"]))), right(none), (a,b,c) => a+" "+b+c),
          right(none));
    });
  });
}