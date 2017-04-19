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
    MockM.gets((counters) => counters[fileName]|0) >= (int i) =>
    MockM.asks((inputs) => inputs[fileName]|emptyVector/*<String>*/()) >= (IVector<String> vs) =>
    MockM.pure(vs[i]|null) << MockM.modify((counters) => counters.put(fileName, i+1));

Evaluation<String, IMap<String, IVector<String>>, IVector<String>, IMap<String, int>, dynamic/*=A*/> _interpret/*<A>*/(Free<IOOp, dynamic/*=A*/> op) =>
  op.foldMap(MockM, mockIOInterpreter);

// Technique: Interpret Free monad into Evaluation
Evaluation<String, IMap<String, IVector<String>>, IVector<String>, IMap<String, int>, dynamic> mockIOInterpreter(IOOp io) {
  if (io is Readln) {
    return mockReadFile("stdin");

  } else if (io is Println) {
    return MockM.write(ivector(["stdout: ${io.s}"]));

  } else if (io is Attempt) {
    return _interpret(io.fa).map(right).handleError((e) => MockM.pure(left(e)));

  } else if (io is Fail) {
    return MockM.raiseError(io.failure.toString());

  } else if (io is OpenFile) {
    return MockM.pure(new _MockFileRef(io.path));

  } else if (io is CloseFile) {
    return MockM.pure(unit);

  } else if (io is ReadBytes) {
    return mockReadFile((io.file as _MockFileRef).name).map((String s) => s == null ? nil() : ilist(UTF8.encode(s)));

  } else if (io is WriteBytes) {
    return MockM.write(ivector(["${(io.file as _MockFileRef).name}: ${UTF8.decode(io.bytes.toList())}"]));

  } else if (io is Execute) {
    return MockM.pure(new ExecutionResult(0, "<<< Mocked result of '${io.command} ${io.arguments.intercalate(StringMi, " ")}' >>>", ""));

  } else if (io is Delay) {
    return _interpret(io.a);

  } else if (io is Gather) {
    return io.ops.traverse(MockM, _interpret);

  } else {
    return MockM.raiseError("Unimplemented IO op: $io");
  }
}

// Technique: Interpret Free monad and run resulting Evaluation using reader (mocked inputs) and initial state (index in input vector)
Future<Either<String, Tuple3<IVector<String>, IMap<String, int>, dynamic/*=A*/>>> mockPerformIO/*<A>*/(Free<IOOp, dynamic/*=A*/> io, IMap<String, IVector<String>> input) =>
    _interpret(io).run(input, emptyMap());
