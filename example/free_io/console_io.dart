library free_io_console_io;

import 'package:dartz/dartz.dart';
import 'io.dart';
import 'dart:io';

// Technique: Express Free monad using side effects through the console
consoleIOInterpreter(IOOp io) {
  if (io is Readln) {
    return stdin.readLineSync();

  } else if (io is Println) {
    print(io.s);
    return unit;

  } else {
    throw new UnimplementedError("Unimplemented IO op: $io");
  }
}

// Technique: Interpret Free monad using identity monad, since interpreter is side effecting
/*=A*/ unsafePerformIO/*<A>*/(Free<IOOp, dynamic/*=A*/> io) => io.foldMap(IdM, consoleIOInterpreter);
