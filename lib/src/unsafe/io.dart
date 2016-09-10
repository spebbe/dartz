part of dartz_unsafe;

class _RandomAccessFileRef implements FileRef {
  final RandomAccessFile _f;
  _RandomAccessFileRef(this._f);
}

Future<RandomAccessFile> unwrapFileRef(FileRef ref) => ref is _RandomAccessFileRef ? new Future.value(ref._f) : new Future.error("Not a valid FileRef: $ref");

Future _consoleIOInterpreter(IOOp io) {
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
    return new File(io.path).open(mode: io.openForRead ? FileMode.READ : FileMode.WRITE).then((f) => new _RandomAccessFileRef(f));

  } else if (io is CloseFile) {
    return unwrapFileRef(io.file).then((f) => f.close().then((_) => unit));

  } else if (io is ReadBytes) {
    return unwrapFileRef(io.file).then((f) => f.read(io.byteCount).then(ilist));

  } else if (io is WriteBytes) {
    return unwrapFileRef(io.file).then((f) => f.writeFrom(io.bytes.toList()).then((_) => unit));

  } else {
    throw new UnimplementedError("Unimplemented IO op: $io");
  }
}

Future/*<A>*/ unsafePerformIO/*<A>*/(Free<IOOp, dynamic/*=A*/> io) => io.foldMap(FutureM, _consoleIOInterpreter);
