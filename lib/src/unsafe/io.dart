part of dartz_unsafe;

class _RandomAccessFileRef implements FileRef {
  final RandomAccessFile _f;
  _RandomAccessFileRef(this._f);
  @override Future<Unit> close() => _f.close().then((_) => unit);
  @override Future<IList<int>> read(int byteCount) => _f.read(byteCount).then(ilist);
  @override Future<Unit> write(IList<int> bytes) => _f.writeFrom(bytes.toList()).then((_) => unit);
}

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
    return io.file.close();

  } else if (io is ReadBytes) {
    return io.file.read(io.byteCount);

  } else if (io is WriteBytes) {
    return io.file.write(io.bytes);

  } else {
    throw new UnimplementedError("Unimplemented IO op: $io");
  }
}

Future/*<A>*/ unsafePerformIO/*<A>*/(Free<IOOp, dynamic/*=A*/> io) => io.foldMap(FutureM, _consoleIOInterpreter);
