library free_io_mock_io;

import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'dart:async';

// Technique: Instantiate EvaluationMonad using types for either, reader, writer and state, as well as a monoid for the writer type
final EvaluationMonad<String, IMap<String, IVector<String>>, IVector<String>, IMap<String, int>> MockM = new EvaluationMonad(ivectorMi());

class _MockFileRef implements FileRef {
  final String name;
  _MockFileRef(this.name);
}

Evaluation<String, IMap<String, IVector<String>>, IVector<String>, IMap<String, int>, dynamic> mockReadFile(String fileName) =>
    MockM.gets((counters) => counters.get(fileName)|0) >= (int i) =>
    MockM.asks((inputs) => inputs.get(fileName)|emptyVector/*<String>*/()) >= (IVector<String> vs) =>
    MockM.pure(vs.get(i)|null) << MockM.modify((counters) => counters.put(fileName, i+1));

// Technique: Interpret Free monad into Evaluation
Evaluation<String, IMap<String, IVector<String>>, IVector<String>, IMap<String, int>, dynamic> mockIOInterpreter(IOOp io) {
  if (io is Readln) {
    return mockReadFile("stdin");

  } else if (io is Println) {
    return MockM.write(ivector(["stdout: ${io.s}"]));

  } else if (io is Attempt) {
    return io.fa.foldMap/*<Evaluation, Evaluation<String, IMap<String, IVector<String>>, IVector<String>, IMap<String, int>, dynamic>>*/(
        MockM, mockIOInterpreter).map(right).handleError((e) => MockM.pure(left(e)));

  } else if (io is Fail) {
    return MockM.raiseError(io.failure.toString());

  } else if (io is OpenFile) {
    return MockM.pure(new _MockFileRef(io.path));

  } else if (io is CloseFile) {
    return MockM.pure(unit);

  } else if (io is ReadBytes) {
    return mockReadFile((io.file as _MockFileRef).name).map((s) => s == null ? nil() : ilist(UTF8.encode(s)));

  } else if (io is WriteBytes) {
    return MockM.write(ivector(["${(io.file as _MockFileRef).name}: ${UTF8.decode(io.bytes.toList())}"]));

  } else if (io is Execute) {
    return MockM.pure(new ExecutionResult(0, "<<< Mocked result of '${io.command} ${io.arguments.intercalate(StringMi, " ")}' >>>", ""));

  } else {
    return MockM.raiseError("Unimplemented IO op: $io");
  }
}

// Technique: Interpret Free monad and run resulting Evaluation using reader (mocked inputs) and initial state (index in input vector)
Future<Either<String, Tuple3<IVector<String>, IMap<String, int>, dynamic/*=A*/>>> mockPerformIO/*<A>*/(Free<IOOp, dynamic/*=A*/> io, IMap<String, IVector<String>> input) =>
    io.foldMap(MockM, mockIOInterpreter).run(input, emptyMap()) as Future<Either<String, Tuple3<IVector<String>, IMap<String, int>, dynamic/*=A*/>>>;
