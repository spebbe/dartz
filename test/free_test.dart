import 'package:test/test.dart';
import 'package:dartz/dartz.dart';
import 'laws.dart';

abstract class RPNOp<T> {}

class PushSymbol extends RPNOp<Unit> {
  final String symbol;
  PushSymbol(this.symbol);
}
Free<RPNOp, Unit> pushSymbol(String symbol) => liftF(new PushSymbol(symbol));

class Push extends RPNOp<Unit> {
  final double value;
  Push(this.value);
}
Free<RPNOp, Unit> push(double value) => liftF(new Push(value));

class Pop extends RPNOp<double> {}
final Free<RPNOp, double> pop = liftF(new Pop());

final Free<RPNOp, Unit> dup = pop.bind((i) => push(i).andThen(push(i)));

final Free<RPNOp, Unit> multiply = Free.map2(pop, pop, (double a, double b) => a*b).bind(push);

void main() {
  final M = new EvaluationMonad<String, IMap<String, double>, IList<String>, IList<double>>(ilistMi());

  Evaluation<String, IMap<String, double>, IList<String>, IList<double>, dynamic> rpnInterpreter(RPNOp<dynamic> op) {
    if (op is PushSymbol) {
      return M.asks((IMap<String, double> symbols) => symbols[op.symbol]).bind((Option<double> symbolValue) {
        return symbolValue.fold(() =>
            M.raiseError("Undefined symbol: ${op.symbol}"),
            (double value) => M.write(ilist(["Pushing value of ${op.symbol}: $value"])).andThen(M.modify((IList<double> stack) => new Cons(value, stack))));
      });

    } else if (op is Push) {
      return M.modify((IList<double> stack) => new Cons(op.value, stack));

    } else if (op is Pop) {
      return M.get().bind((IList<double> stack) {
        return stack.headOption.fold(() =>
            M.raiseError("Stack underflow"),
            (double value) => M.put(stack.tailOption | nil<double>()).andThen(M.pure(value)));
      });

    } else {
      throw new UnimplementedError("Unimplemented RPNOp: $op");
    }
  }

  final circleArea = pushSymbol("PI").andThen(pushSymbol("r")).andThen(dup).andThen(multiply).andThen(multiply).andThen(pop);

  group("free RPN interpreter demo", (){
    test("successful evaluation", () async {
      expect(await circleArea.foldMap(M, rpnInterpreter).run(imap({"PI": 3.14159, "r": 5.0}), nil()),
          right(tuple3(ilist(["Pushing value of PI: 3.14159", "Pushing value of r: 5.0"]), nil(), 78.53975)));
    });

    test("failing evaluation 1", () async {
      expect(await circleArea.foldMap(M, rpnInterpreter).run(imap({"PI": 3.14159, "radius": 5.0}), nil()),
          left("Undefined symbol: r"));
    });

    test("failing evaluation 2", () async {
      expect(await pop.foldMap(M, rpnInterpreter).run(emptyMap(), nil()),
          left("Stack underflow"));
    });
  });

  group("FreeM", () => checkMonadLaws(FreeM, equality: (a, b) => a.foldMap(IdM, (x) => x) == b.foldMap(IdM, (x) => x)));
}