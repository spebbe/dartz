library streaming_io_utils;

import 'package:dartz/dartz.dart';
import 'package:dartz/dartz_unsafe.dart';
import 'dart:async';
import 'dart:convert';

final Conveyor<Free<IOOp, dynamic>, SinkF<Free<IOOp, dynamic>, String>> stdoutSink = Source.constant(IOM, (String s) => Source.eval_(println(s)));

Future<Either<Object, IList/*<A>*/>> unsafeConveyIO/*<A>*/(Conveyor<Free<IOOp, dynamic>, dynamic/*=A*/> conveyor) =>
    unsafePerformIO/*<Either<Object, IList<A>>>*/(IOM.attempt(conveyor.runLog(IOM)));

// Note: Just a basic implementation!!! Assumes Latin-1 encoding, not super efficient, naively buffers extremely long lines, etc...
Conveyor<Free<IOOp, dynamic>, String> fileLineReader(String path) => Source.resource(
    openFile(path, true) << println("\n*** opened $path ***"),
    (FileRef file) =>
        Source.eval/*<Free<IOOp, dynamic>, IList<int>>*/(readBytes(file, 4096))
            .repeat()
            .takeWhile((bytes) => bytes != nil())
            .map((bytes) => LATIN1.decode(bytes.toList()))
            .pipe(bufferLines),
    (FileRef file) =>
        Source.eval_(closeFile(file) << println("*** closed $path ***")));

Conveyor<Free<IOOp, dynamic>, SinkF<Free<IOOp, dynamic>, String>> fileWriter(String path) => Source.resource(
    openFile(path, false) << println("*** opened $path for writing ***"),
    (FileRef file) => Source.constant(IOM, (String s) => Source.eval_(writeBytes(file, ilist(LATIN1.encode(s))))),
    (FileRef file) => Source.eval_(closeFile(file) << println("*** closed $path for writing ***")));

Conveyor/*<From<A>, A>*/ chunk/*<A>*/(Monoid/*<A>*/ monoid, int chunkSize) {
  Conveyor/*<From<A>, A>*/ go(int n, /*=A*/ sofar) =>
      Pipe.consume(
          (a) => n > 1 ? go(n-1, monoid.append(sofar, a)) : Pipe.produce(monoid.append(sofar, a), go(chunkSize, monoid.zero()))
          ,() => sofar == monoid.zero() ? Pipe.halt() : Pipe.produce(sofar));
  return go(chunkSize, monoid.zero());
}

Conveyor<From<String>, String> _bufferLines(Option<String> spill) =>
    Pipe.consume((s) {
      final buffered = (spill|"") + s;
      final lines = ilist(buffered.split("\n"));
      return lines.reverse().uncons(Pipe.halt, (newSpill, completeLines) =>
          completeLines.foldLeft/*<Conveyor<From<String>, String>>*/(_bufferLines(option(newSpill.length > 0, newSpill)), (rest, line) => Conveyor.produce(line, rest))
      );
    }, () => spill.fold(Pipe.halt, Pipe.produce));

final Conveyor<From<String>, String> bufferLines = _bufferLines(none());

final Conveyor<From<String>, String> toUppercase = Pipe.lift((String s) => s.toUpperCase());

Conveyor<From/*<A>*/, dynamic/*=A*/> skipDuplicates/*<A>*/([Eq/*<A>*/ _eq]) {
  final Eq/*<A>*/ eq = _eq ?? ObjectEq;
  Conveyor<From/*<A>*/, dynamic/*=A*/> loop(/*=A*/ lastA) =>
      Pipe.consume((/*=A*/ a) => eq.eq(lastA, a) ? loop(lastA) : Pipe.produce(a, loop(a)));
  return Pipe.consume((/*=A*/ a) => Pipe.produce(a, loop(a)));
}
