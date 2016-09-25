part of dartz;

abstract class IOOp<A> {}

class Readln extends IOOp<String> {}
final Free<IOOp, String> readln = liftF(new Readln());

class Println extends IOOp<Unit> {
  final String s;
  Println(this.s);
}
Free<IOOp, Unit> println(String s) => liftF(new Println(s));

abstract class FileRef {}
class OpenFile extends IOOp<FileRef> {
  final String path;
  final bool openForRead;
  OpenFile(this.path, this.openForRead);
}
Free<IOOp, FileRef> openFile(String path, bool openForRead) => liftF(new OpenFile(path, openForRead));

class ReadBytes extends IOOp<IList<int>> {
  final FileRef file;
  final int byteCount;
  ReadBytes(this.file, this.byteCount);
}
Free<IOOp, IList<int>> readBytes(FileRef file, int byteCount) => liftF(new ReadBytes(file, byteCount));

class WriteBytes extends IOOp<Unit> {
  final FileRef file;
  final IList<int> bytes;
  WriteBytes(this.file, this.bytes);
}
Free<IOOp, Unit> writeBytes(FileRef file, IList<int> bytes) => liftF(new WriteBytes(file, bytes));

class CloseFile extends IOOp<Unit> {
  final FileRef file;
  CloseFile(this.file);
}
Free<IOOp, Unit> closeFile(FileRef file) => liftF(new CloseFile(file));

class Attempt<A> extends IOOp<Either<Object, A>> {
  final Free<IOOp, A> fa;
  Attempt(this.fa);
}
Free<IOOp, Either<Object, dynamic/*=A*/>> attempt/*<A>*/(Free<IOOp, dynamic/*=A*/> fa) => liftF(new Attempt(fa));

class Fail<A> extends IOOp<A> {
  final Object failure;
  Fail(this.failure);
}

class IOMonad extends MonadOpsMonad<Free<IOOp, dynamic>> with MonadCatch<Free<IOOp, dynamic>> {
  IOMonad() : super((a) => new Pure(a));
  @override Free<IOOp, Either<Object, dynamic/*=A*/>> attempt/*<A>*/(Free<IOOp, dynamic/*=A*/> fa) => liftF(new Attempt(fa));
  @override Free<IOOp, dynamic> fail(Object err) => liftF(new Fail(err));
}

final IOMonad IOM = new IOMonad();
