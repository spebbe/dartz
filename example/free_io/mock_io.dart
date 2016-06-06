library free_io_mock_io;

import 'package:dartz/dartz.dart';
import 'io.dart';
import 'dart:async';

// Technique: Instantiate EvaluationMonad using types for either, reader, writer and state, as well as a monoid for the writer type
final EvaluationMonad<String, IVector<String>, IVector<String>, int> MockM = new EvaluationMonad(ivectorMi());

// Technique: Interpret Free monad into Evaluation
Evaluation<String, IVector<String>, IVector<String>, int, dynamic> mockIOInterpreter(IOOp io) {
  if (io is Readln) {
    return MockM.get() >= (int i) =>
    MockM.ask() >= (IVector<String> vs) =>
    MockM.liftOption(vs.get(i), () =>"Read past end of input") << MockM.put(i+1);

  } else if (io is Println) {
    return MockM.write(ivector([io.s]));

  } else {
    return MockM.raiseError("Unimplemented IO op: $io");

  }
}

// Technique: Interpret Free monad and run resulting Evaluation using reader (mocked inputs) and initial state (index in input vector)
Future<Either<String, Tuple3<IVector<String>, int, dynamic/*=A*/>>> mockPerformIO/*<A>*/(Free<IOOp, dynamic/*=A*/> io, IVector<String> input) =>
    io.foldMap(MockM, mockIOInterpreter).run(input, 0) as Future<Either<String, Tuple3<IVector<String>, int, dynamic/*=A*/>>>;
