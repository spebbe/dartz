part of dartz;

abstract class IOOp<A> {}

class Readln extends IOOp<String> {}
final Free<IOOp, String> readln = liftF(new Readln());

class Println extends IOOp<Unit> {
  final String _s;
  String get s => _s;
  Println(this._s);
}
Free<IOOp, Unit> println(Object o) => liftF(new Println(o.toString()));

Free<IOOp, Unit> ios(IList<Free<IOOp, Unit>> ioList) => FreeM.sequenceL_(ioList) as dynamic/*=Free<IOOp, Unit>*/;

final Monad<Free<IOOp, dynamic>> IOM = FreeM;

// Example interpreter that expresses side effects using the console through dart:io
/*
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

dynamic unsafePerformIO(Free<IOOp, dynamic> io) => io.foldMap(IdM, consoleIOInterpreter);

abstract class IOApp {
  Free<IOOp, Unit> ioMain();
}

void runIOApp(IOApp ioApp) { unsafePerformIO(ioApp.ioMain()); }
*/
