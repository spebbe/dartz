import 'package:test/test.dart';
import 'package:dartz/dartz.dart';

void main() {

  test("Task basic usage", () async {
    final Task<num> t = Task.delay(() => "5")
      .flatMap((s) => Task.delay(() => num.parse(s)))
      .map((i) => i*2);

    final result1 = await t.run();
    final result2 = await t.run();

    expect(result1, 10);
    expect(result1, result2);
  });

  test("Task attempt", () async {
    final Task<Either<Object, num>> t = Task.delay(() => "notanumber")
      .map(num.parse)
      .attempt();

    final result = await t.run();
    expect(result.fold(id, id) is FormatException, true);
  });

}
