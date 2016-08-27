library free_io_console_io;

import 'package:dartz/dartz.dart';
import 'io.dart';
import 'dart:io';
import 'dart:async';

class _RandomAccessFileRef implements FileRef {
  final RandomAccessFile _f;
  _RandomAccessFileRef(this._f);
  @override Future<Unit> close() => _f.close().then((_) => unit);
  @override Future<IList<int>> read(int byteCount) => _f.read(byteCount).then(ilist);
}

// Technique: Express Free monad using side effects through the console
Future consoleIOInterpreter(IOOp io) {
  if (io is Readln) {
    return new Future.value(stdin.readLineSync());

  } else if (io is Println) {
    print(io.s);
    return new Future.value(unit);

  } else if (io is Attempt) {
    return unsafePerformIO(io.fa).then(right).catchError(left);

  } else if (io is Fail) {
    return new Future.error(io.failure);

  } else if (io is OpenFile) {
    return new File(io.path).open().then((f) => new _RandomAccessFileRef(f));

  } else if (io is CloseFile) {
    return io.file.close();

  } else if (io is ReadBytes) {
    return io.file.read(io.byteCount);

  } else {
    throw new UnimplementedError("Unimplemented IO op: $io");
  }
}
// Technique: Interpret Free monad using Future monad, to allow for asynchronous side effecting operations
Future/*<A>*/ unsafePerformIO/*<A>*/(Free<IOOp, dynamic/*=A*/> io) => io.foldMap(FutureM, consoleIOInterpreter);