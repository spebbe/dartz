import 'dart:async';

import 'package:test/test.dart';
import 'package:dartz/dartz.dart';

void main() {
  test("Task basic usage", () async {
    final Task<num> t = Task.delay(() => "5")
        .flatMap((s) => Task.delay(() => num.parse(s)))
        .map((i) => i * 2);

    final result1 = await t.run();
    final result2 = await t.run();

    expect(result1, 10);
    expect(result1, result2);
  });

  test("Task attempt", () async {
    final Task<Either<Object, num>> t =
        Task.delay(() => "notanumber").map(num.parse).attempt();

    final result = await t.run();
    expect(result.fold(id, id) is FormatException, true);
  });

  test("Task.both (concurrent)", () async {
    final one = Task.value(1).delayBy(Duration(seconds: 1));
    final two = Task.value(2).delayBy(Duration(seconds: 1));

    final result =
        await one.both(two).map((t) => t.value1 + t.value2).timed.run();

    expect(result.value2, 3);
    expect(result.value1 >= Duration(seconds: 1), true);
    expect(result.value1 < Duration(milliseconds: 1100), true);
  });

  test("Task.bracket", () async {
    var count = 0;

    final acquire = Task.delay(() => count++);
    final fail = Task.failed('failed');
    final release = Task.delay(() => count--);

    final result = await acquire
        .bracket(
          (a) => Task.delay(() => expect(count, 1)).andThen(fail),
          (a) => release,
        )
        .attempt()
        .run();

    expect(result, left('failed'));
    expect(count, 0);
  });

  test("Task.delayBy", () async {
    final Task<Tuple2<Duration, String>> t =
        Task.value('foo').delayBy(Duration(milliseconds: 500)).timed;

    final result = await t.run();

    expect(result.value1 >= Duration(milliseconds: 500), true);
  });

  test("Task.flatten", () async {
    final Task<String> t = Task.value(Task.value('foo')).flatten;

    final result = await t.run();
    expect(result, 'foo');
  });

  test("Task.guarantee", () async {
    var count = 0;

    final inc = Task.delay(() => count++);
    final fail = Task.failed<String>('failed');

    await inc.run();
    expect(count, 1);

    await fail.andThen(inc).attempt().run();
    expect(count, 1);

    await fail.guarantee(inc).attempt().run();
    expect(count, 2);
  });

  test("Task.handleError", () async {
    final Task<Either<Object, String>> t = Task.failed<String>('error')
        .handleError((err) => 'handled: $err')
        .attempt();

    final result = await t.run();
    result.fold(
      (err) => fail('Task.handleError failed: $err'),
      (a) => expect(a, 'handled: error'),
    );
  });

  test("Task.handleErrorWith", () async {
    final Task<Either<Object, String>> t = Task.failed<String>('error')
        .handleErrorWith((err) => Task.value('handled: $err'))
        .attempt();

    final result = await t.run();
    result.fold(
      (err) => fail('Task.handleErrorWith failed: $err'),
      (a) => expect(a, 'handled: error'),
    );
  });

  test("Task.handleErrorWith (another error)", () async {
    final Task<Either<Object, String>> t = Task.failed<String>('error')
        .handleErrorWith((err) => Task.failed('kaboom!'))
        .attempt();

    final result = await t.run();
    result.fold(
      (err) => expect(err, 'kaboom!'),
      (a) => fail('Task.handleErrorWith failed: $a'),
    );
  });

  test("Task.option", () async {
    final resultSome = await Task.value(42).option.run();
    final resultNone = await Task.failed<int>('FAIL').option.run();

    resultSome.fold(
      () => fail('Task.option [some] failed: none'),
      (a) => expect(a, 42),
    );

    resultNone.fold(
      () => expect(true, true),
      (a) => fail('Task.option [none] failed: a'),
    );
  });

  test("Task.product", () async {
    final Task<Either<Object, Tuple2<int, String>>> t =
        Task.value(42).product(Task.value('other')).attempt();

    final result = await t.run();
    result.fold((err) => fail('Task.product failed: $err'),
        (tuple) => expect(tuple, tuple2(42, 'other')));
  });

  test("Task.product (serial)", () async {
    final one = Task.value(1).delayBy(Duration(seconds: 1));
    final two = Task.value(2).delayBy(Duration(seconds: 1));

    final result = await one.product(two).timed.run();

    expect(result.value1 >= Duration(seconds: 2), true);
  });

  test("Task.productL", () async {
    final Task<Either<Object, int>> t =
        Task.value(42).productL(Task.value('foo')).attempt();

    final result = await t.run();
    result.fold(
        (err) => fail('Task.productL failed: $err'), (a) => expect(a, 42));
  });

  test("Task.productR", () async {
    final Task<Either<Object, String>> t =
        Task.value(42).productR(Task.value('foo')).attempt();

    final result = await t.run();
    result.fold(
        (err) => fail('Task.productR failed: $err'), (a) => expect(a, 'foo'));
  });

  test("Task.redeem", () async {
    final Task<Either<Object, String>> t =
        Task.failed<String>('error').redeem((_) => 'redeemed!', id).attempt();

    final result = await t.run();
    result.fold((err) => fail('Task.redeem failed: $err'),
        (a) => expect(a, 'redeemed!'));
  });

  test("Task.redeemWith", () async {
    final Task<Either<Object, String>> t = Task.failed<String>('error')
        .redeemWith((_) => Task.value('redeemed!'), Task.value)
        .attempt();

    final result = await t.run();
    result.fold(
      (err) => fail('Task.redeemWith failed: $err'),
      (a) => expect(a, 'redeemed!'),
    );
  });

  test("Task.race A", () async {
    final a = Task.value('a');
    final b = Task.value(42).delayBy(Duration(milliseconds: 100));

    final resA = await a.race(b).run();

    resA.fold((a) => expect(a, 'a'), (b) => fail('Task.race A failed: $b'));
  });

  test("Task.race B", () async {
    final a = Task.value('a').delayBy(Duration(milliseconds: 100));
    final b = Task.value(42);

    final resB = await a.race(b).run();

    resB.fold((a) => fail('Task.race A failed: $a'), (b) => expect(b, 42));
  });

  test("Task.race (same type)", () async {
    final a = Task.value(24).delayBy(Duration(milliseconds: 100));
    final b = Task.value(42);

    final resB = await a.race(b).run();

    resB.fold((a) => fail('Task.race failed: $a'), (b) => expect(b, 42));
  });

  test("Task.replicate", () async {
    final a = Task.value('a').replicate(5);

    final result = await a.run();

    expect(result, ilist(['a', 'a', 'a', 'a', 'a']));
  });

  test("Task.timeout (success)", () async {
    final Task<Either<Object, String>> t = Task.value('foo')
        .delayBy(Duration(milliseconds: 500))
        .timeout(Duration(seconds: 1))
        .attempt();

    final result = await t.run();
    result.fold(
      (err) => fail('Task.timeout failed: $err'),
      (a) => expect(a, 'foo'),
    );
  });

  test("Task.timeout (failure)", () async {
    final Task<Either<Object, String>> t = Task.value('foo')
        .delayBy(Duration(milliseconds: 1500))
        .timeout(Duration(seconds: 1))
        .attempt();

    final result = await t.run();
    expect(result.fold(id, id) is TimeoutException, true);
  });

  test("Task.timeoutTo (fallback)", () async {
    final Task<Either<Object, String>> t = Task.value('foo')
        .delayBy(Duration(milliseconds: 400))
        .timeoutTo(Duration(milliseconds: 200), Task.value('fallback'))
        .attempt();

    final result = await t.run();
    result.fold(
      (err) => fail('Task.timeoutTo failed: $err'),
      (a) => expect(a, 'fallback'),
    );
  });

  test("Task.timeoutTo (error)", () async {
    final Task<Either<Object, int>> t = Task.value('foo')
        .map(int.parse)
        .timeoutTo(Duration(milliseconds: 100), Task.value(42))
        .attempt();

    final result = await t.run();
    result.fold(
      (err) => expect(err is FormatException, true),
      (a) => fail('Task.timeoutTo failed: $a'),
    );
  });

  test("Task.ifM", () async {
    final result = await Task.value(true)
        .ifM(Task.value('ifTrue'), Task.value('ifFalse'))
        .run();

    expect(result, 'ifTrue');
  });

  test("Task.traverse ilist", () async {
    final t = ilist(List.generate(5, id)).traverseTask((ix) =>
        Task.delay(() => ix * 3).delayBy(Duration(milliseconds: ix * 10)));

    final result = await t.run();
    expect(result, ilist([0, 3, 6, 9, 12]));
  });

  test("Task.traverse either", () async {
    final tr = right<String, int>(42)
        .traverseTask((i) => Task.sleep(Duration(milliseconds: i)).replace(24));
    final tl = left<String, int>('boom')
        .traverseTask((i) => Task.sleep(Duration(milliseconds: i)).replace(24));

    final resultR = await tr.run();
    final resultL = await tl.run();

    expect(resultR, right(24));
    expect(resultL, left('boom'));
  });

  test("Task.traverse option", () async {
    final ts = some(42)
        .traverseTask((i) => Task.sleep(Duration(milliseconds: i)).replace(24));
    final tn = none<int>()
        .traverseTask((i) => Task.sleep(Duration(milliseconds: i)).replace(24));

    final resultS = await ts.run();
    final resultN = await tn.run();

    expect(resultS, some(24));
    expect(resultN, none());
  });
}
