library streaming_io_utils;

import 'package:dartz/dartz.dart';
import 'dart:async';
import '../free_io/io.dart';
import '../free_io/console_io.dart';
import 'dart:convert';

Future<Either<Object, IList/*<A>*/>> dump/*<A>*/(Conveyor<Free<IOOp, dynamic>, String> conveyor) =>
    unsafePerformIO/*<Either<Object, IList<A>>>*/(IOM.attempt(conveyor.sink(println).runLog(IOM)));

// Note: Just a basic implementation!!! Assumes Latin-1 encoding, not super efficient, naively buffers extremely long lines, etc...
Conveyor<Free<IOOp, dynamic>, String> fileLines(String path) => Source.resource(
    println("\n*** opening $path ***") >> openFile(path),
    (FileRef file) =>
        Source.eval/*<Free<IOOp, dynamic>, IList<int>>*/(readBytes(file, 4096))
            .repeat()
            .takeWhile((bytes) => bytes != nil())
            .map((bytes) => LATIN1.decode(bytes.toList()))
            .pipe(bufferLines),
    (FileRef file) =>
        Source.eval_(println("*** closing $path ***") >> closeFile(file)));

Conveyor<From<String>, String> _bufferLines(Option<String> spill) =>
    Pipe.consume((s) {
      final buffered = (spill|"") + s;
      final lines = ilist(buffered.split("\n"));
      return lines.reverse().uncons(Pipe.halt, (newSpill, completeLines) =>
          completeLines.foldLeft/*<Conveyor<From<String>, String>>*/(_bufferLines(some(newSpill)), (rest, line) => Conveyor.produce(line, rest))
      );
    }, () => spill.fold(Pipe.halt, Pipe.produce));

final Conveyor<From<String>, String> bufferLines = _bufferLines(none());

final Conveyor<From<String>, String> toUppercase = Pipe.lift((String s) => s.toUpperCase());

Conveyor<From/*<A>*/, dynamic/*=A*/> skipDuplicates/*<A>*/([Eq/*<A>*/ _eq]) {
  final Eq/*<A>*/ eq = _eq ?? ObjectEq;
  Conveyor<From/*<A>*/, dynamic/*=A*/> loop(Option/*<A>*/ last) =>
      Pipe.consume((/*=A*/ a) => last.map((lastA) => eq.eq(lastA, a)) | false
          ? loop(last)
          : Pipe.produce(a, loop(some(a))));
  return loop(none());
}
