library streaming_io_utils;

import 'package:dartz/dartz.dart';
import 'dart:io';
import 'dart:async';
import '../free_io/io.dart';
import '../free_io/console_io.dart';

Future<Either<Object, IList/*<A>*/>> dump/*<A>*/(Conveyor<Free<IOOp, dynamic>, String> conveyor) =>
    unsafePerformIO/*<Either<Object, IList<A>>>*/(IOM.attempt(conveyor.sink(println).runLog(IOM)));

// Note: Just a toy implementation!!! RIDICULOUSLY inefficient and doesn't work for multi-byte characters!
Conveyor<Free<IOOp, dynamic>, String> fileLines(String path) => Source.resource(
    println("\n*** opening $path ***") >> openFile(path),
    (RandomAccessFile file) =>
        Source.eval(readBytes(file, 1))
            .repeat()
            .takeWhile((byte) => byte.isNotEmpty)
            .map(SYSTEM_ENCODING.decode)
            .pipe(bufferLine.repeat()),
    (RandomAccessFile file) =>
        Source.eval_(println("*** closing $path ***") >> closeFile(file)));

Conveyor<From<String>, String> bufferLine = Pipe.takeWhile((String s) => s != "\n").concatenate(StringMi);

final toUppercase = Pipe.lift((String s) => s.toUpperCase());
