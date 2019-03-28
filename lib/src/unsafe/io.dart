// ignore_for_file: unnecessary_new

part of dartz_unsafe;

class _RandomAccessFileRef implements FileRef {
  final RandomAccessFile _f;
  _RandomAccessFileRef(this._f);
}

Future<RandomAccessFile> unwrapFileRef(FileRef ref) => ref is _RandomAccessFileRef ? new Future.value(ref._f) : new Future.error("Not a valid FileRef: $ref");

Future unsafeIOInterpreter(IOOp io) {
  if (io is Readln) {
    return new Future.value(stdin.readLineSync());

  } else if (io is Println) {
    print(io.s);
    return new Future.value(unit);

  } else if (io is Attempt) {
    return unsafePerformIO(io.fa).then(io.succeed).catchError(io.fail);

  } else if (io is Fail) {
    return new Future.error(io.failure);

  } else if (io is OpenFile) {
    return new File(io.path).open(mode: io.openForRead ? FileMode.READ : FileMode.WRITE).then((f) => new _RandomAccessFileRef(f));

  } else if (io is CloseFile) {
    return unwrapFileRef(io.file).then((f) => f.close().then((_) => unit));

  } else if (io is ReadBytes) {
    return unwrapFileRef(io.file).then((f) => f.read(io.byteCount).then((bytes) => new UnmodifiableListView(bytes)));

  } else if (io is WriteBytes) {
    return unwrapFileRef(io.file).then((f) => f.writeFrom(io.bytes.toList()).then((_) => unit));

  } else if (io is Execute) {
    return Process.run(io.command, io.arguments.toList()).then((pr) => new ExecutionResult(pr.exitCode, cast(pr.stdout), cast(pr.stderr)));

  } else if (io is Delay) {
    return new Future.delayed(io.duration, () => unsafePerformIO(io.a));

  } else if (io is Gather) {
    return io.ops.traverseFuture(unsafePerformIO);

  } else {
    throw new UnimplementedError("Unimplemented IO op: $io");
  }
}

Future<A> unsafePerformIO<A>(Free<IOOp, A> io) => io.foldMapFuture(unsafeIOInterpreter);

Future<Either<Object, IList<A>>> unsafeConveyIO<A>(Conveyor<Free<IOOp, dynamic>, A> conveyor) => unsafePerformIO(IOM.attempt(Conveyor.runLogIO(conveyor)));
