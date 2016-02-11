import 'package:test/test.dart';
import 'package:enumerators/combinators.dart' as c;
import 'package:dartz/dartz.dart';
import 'dart:async';
import 'laws.dart';

void main() {
  test("transformer demo", () async {
    final Monad<Future<List<Either>>> M = eitherTMonad(listTMonad(FutureM));
    final stacked = M.map(M.bind(M.map(new Future.sync(() => [right("a"), left("b"), right("c")]),
        (x) => x + "!"),
        (x) => new Future.delayed(new Duration(seconds: 1), () => [right(x), right(x)])),
        (x) => x.toUpperCase());

    expect(await stacked, [right("A!"), right("A!"), left("b"), right("C!"), right("C!")]);
  });

  test("sequencing", () {
    final IList<Either<String, int>> l = ilist([right(1), right(2)]);
    expect(l.sequence(EitherM), right(ilist([1,2])));
    expect(l.sequence(EitherM).sequence(IListM), l);

    final IList<Either<String, int>> l2 = ilist([right(1), left("out of ints..."), right(2)]);
    expect(l2.sequence(EitherM), left("out of ints..."));
    expect(l2.sequence(EitherM).sequence(IListM), ilist([left("out of ints...")]));
  });

  group("EitherM", () => checkMonadLaws(EitherM));

  group("EitherTMonad+Id", () => checkMonadLaws(eitherTMonad(IdM)));

  group("EitherTMonad+IList", () => checkMonadLaws(eitherTMonad(IListM)));

  group("EitherM+Foldable", () => checkFoldableMonadLaws(EitherFo, EitherM));

  final intEithers = c.ints.map((i) => i%2==0 ? right(i) : left(i));

  group("EitherTr", () => checkTraversableLaws(EitherTr, intEithers));
}
