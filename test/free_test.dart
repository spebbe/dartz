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

final Free<RPNOp, Unit> dup = pop >= (i) => push(i) >> push(i);

final Free<RPNOp, Unit> multiply = pop >= (a) => pop >= (b) => push(a*b);

void main() {
  final M = new EvaluationMonad(IListMi);

  Evaluation<String, IMap<String, double>, IList<String>, IList<double>, dynamic> rpnInterpreter(RPNOp<dynamic> op) {
    if (op is PushSymbol) {
      return M.asks((IMap<String, double> symbols) => symbols.get(op.symbol)) >= (Option<double> symbolValue) {
        return symbolValue.fold(() =>
            M.raiseError("Undefined symbol: ${op.symbol}"),
            (double value) => M.write(ilist(["Pushing value of ${op.symbol}: $value"])) >> M.modify((IList<double> stack) => new Cons(value, stack)));
      };

    } else if (op is Push) {
      return M.modify((IList<double> stack) => new Cons(op.value, stack));

    } else if (op is Pop) {
      return M.get() >= (IList<double> stack) {
        return stack.headOption.fold(() =>
            M.raiseError("Stack underflow"),
            (double value) => M.put(stack.tailOption | Nil) >> M.pure(value));
      };

    } else {
      throw new UnimplementedError("Unimplemented RPNOp: $op");
    }
  }

  final Free<RPNOp, double> circleArea = pushSymbol("PI") >> pushSymbol("r") >> dup >> multiply >> multiply >> pop;

  group("free RPN interpreter demo", (){
    test("successful evaluation", () async {
      expect(await circleArea.foldMap(M, rpnInterpreter).run(imap({"PI": 3.14159, "r": 5.0}), Nil),
          right(tuple3(ilist(["Pushing value of PI: 3.14159", "Pushing value of r: 5.0"]), Nil, 78.53975)));
    });

    test("failing evaluation 1", () async {
      expect(await circleArea.foldMap(M, rpnInterpreter).run(imap({"PI": 3.14159, "radius": 5.0}), Nil),
          left("Undefined symbol: r"));
    });

    test("failing evaluation 2", () async {
      expect(await pop.foldMap(M, rpnInterpreter).run(imap({}), Nil),
          left("Stack underflow"));
    });
  });

  group("FreeM", () => checkMonadLaws(FreeM, equality: (a, b) => a.foldMap(IdM, id) == b.foldMap(IdM, id)));
}