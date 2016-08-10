library interpreter_minilanguage;

import 'package:dartz/dartz.dart';

// Inspired by "Monad Transformers Step by Step" by Martin Grabmüller:
// http://catamorph.de/documents/Transformers.pdf
// Instead of stacking monad transformers, we use Evaluation in this example.
// Evaluation corresponds roughly to the final monad transformer stack described
// in the paper, but pre-stacked and with asynchrony as a bonus effect.

abstract class Exp {}

class Literal extends Exp {
  final int i;
  Literal(this.i);
}
Exp literal(int i) => new Literal(i);

class Variable extends Exp {
  final String name;
  Variable(this.name);
}
Exp variable(String name) => new Variable(name);

class Plus extends Exp {
  final Exp left;
  final Exp right;
  Plus(this.left, this.right);
}
Exp plus(Exp left, Exp right) => new Plus(left, right);

class Lambda extends Exp {
  final String formal;
  final Exp body;
  Lambda(this.formal, this.body);
}
Exp lambda(String name, Exp exp) => new Lambda(name, exp);

class Apply extends Exp {
  final Exp fun;
  final Exp param;
  Apply(this.fun, this.param);
}
Exp apply(Exp fun, Exp param) => new Apply(fun, param);

class Conditional extends Exp {
  final Exp guard;
  final Exp trueCase;
  final Exp falseCase;
  Conditional(this.guard, this.trueCase, this.falseCase);
}
Exp conditional(Exp guard, Exp trueCase, Exp falseCase) => new Conditional(guard, trueCase, falseCase);


abstract class Value {}

class IntVal extends Value {
  final int i;
  IntVal(this.i);
  @override String toString() => "IntVal($i)";
}

class FunVal extends Value {
  final IMap<String, Value> env;
  final String formal;
  final Exp body;
  FunVal(this.env, this.formal, this.body);
  @override String toString() => "FunVal($env, $formal, $body)";
}

// Technique: Instantiate EvaluationMonad, specifying types for either, reader, writer and state
final EvaluationMonad<String, IMap<String, Value>, IVector<String>, int> M = new EvaluationMonad(ivectorMi());

final tick = M.modify((i) => i+1);

// Technique: Interpreting custom ADT into Evaluation
Evaluation<String, IMap<String, Value>, IVector<String>, int, Value> interpret(Exp exp) {
  if (exp is Literal) {
    return M.pure(new IntVal(exp.i));

  } else if (exp is Variable) {
    return M.write(ivector([exp.name]))
        .andThen(M.ask())
        .bind((env) =>
        M.liftOption(env.get(exp.name), () => "unbound variable: ${exp.name}"));

  } else if (exp is Plus) {
    return evaluate(exp.left)
        .bind((l) => evaluate(exp.right)
        .bind((r) => (l is IntVal && r is IntVal)
        ? M.pure(new IntVal(l.i + r.i))
        : M.raiseError("type error in addition")));

  } else if (exp is Lambda) {
    return M.asks((env) => new FunVal(env, exp.formal, exp.body));

  } else if (exp is Apply) {
    return evaluate(exp.fun)
        .bind((fun) => evaluate(exp.param)
        .bind((param) => (fun is FunVal)
        ? M.scope(fun.env.put(fun.formal, param), evaluate(fun.body))
        : M.raiseError("type error in application")));

  } else if (exp is Conditional) {
    return evaluate(exp.guard)
        .bind((guard) => (guard is IntVal)
        ? evaluate((guard.i > 0) ? exp.trueCase : exp.falseCase)
        : M.raiseError("type error in conditional"));

  } else {
    return M.raiseError("unknown exp: $exp");
  }
}

Evaluation<String, IMap<String, Value>, IVector<String>, int, Value> evaluate(Exp exp) => tick.andThen(interpret(exp));
