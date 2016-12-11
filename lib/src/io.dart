part of dartz;

abstract class IOOp<A> {}

class Readln extends IOOp<String> {}

class Println extends IOOp<Unit> {
  final String s;
  Println(this.s);
}

abstract class FileRef {}
class OpenFile extends IOOp<FileRef> {
  final String path;
  final bool openForRead;
  OpenFile(this.path, this.openForRead);
}

class ReadBytes extends IOOp<IList<int>> {
  final FileRef file;
  final int byteCount;
  ReadBytes(this.file, this.byteCount);
}

class WriteBytes extends IOOp<Unit> {
  final FileRef file;
  final IList<int> bytes;
  WriteBytes(this.file, this.bytes);
}

class CloseFile extends IOOp<Unit> {
  final FileRef file;
  CloseFile(this.file);
}

class ExecutionResult {
  final int exitCode;
  final String stdout;
  final String stderr;
  ExecutionResult(this.exitCode, this.stdout, this.stderr);
}
class Execute extends IOOp<ExecutionResult> {
  final String command;
  final IList<String> arguments;
  Execute(this.command, this.arguments);
}

class Delay<A> extends IOOp<A> {
  final Duration duration;
  final Free<IOOp,A> a;
  Delay(this.duration, this.a);
}

class Attempt<A> extends IOOp<Either<Object, A>> {
  final Free<IOOp, A> fa;
  Attempt(this.fa);
}

class Fail<A> extends IOOp<A> {
  final Object failure;
  Fail(this.failure);
}

class IOMonad extends MonadOpsMonad<Free<IOOp, dynamic>> with MonadCatch<Free<IOOp, dynamic>> {
  IOMonad() : super((a) => new Pure(a));
  @override Free/*<IOOp, A>*/ pure/*<A>*/(/*=A*/ a) => new Pure(a);
  @override Free<IOOp, Either<Object, dynamic/*=A*/>> attempt/*<A>*/(Free<IOOp, dynamic/*=A*/> fa) => liftF(new Attempt(fa));
  @override Free<IOOp, dynamic> fail(Object err) => liftF(new Fail(err));
}

final IOMonad IOM = new IOMonad();
final MonadCatch<Free<IOOp, dynamic>> IOMC = IOM;
MonadCatch/*<Free<IOOp, A>>*/ iomc/*<A>*/() => IOMC as dynamic/*=MonadCatch<Free<IOOp, A>>*/;

class IOOps<F> extends FreeOps<F, IOOp> {
  IOOps(FreeComposer<F, IOOp> composer) : super(composer);

  Free<F, String> readln() => liftOp(new Readln());

  Free<F, Unit> println(String s) => liftOp(new Println(s));

  Free<F, FileRef> openFile(String path, bool openForRead) => liftOp(new OpenFile(path, openForRead));

  Free<F, IList<int>> readBytes(FileRef file, int byteCount) => liftOp(new ReadBytes(file, byteCount));

  Free<F, Unit> writeBytes(FileRef file, IList<int> bytes) => liftOp(new WriteBytes(file, bytes));

  Free<F, Unit> closeFile(FileRef file) => liftOp(new CloseFile(file));

  Free<F, ExecutionResult> execute(String command, IList<String> arguments) => liftOp(new Execute(command, arguments));

  Free<F, dynamic/*=A*/> delay/*<A>*/(Duration duration, Free<IOOp, dynamic/*=A*/> a) => liftOp(new Delay(duration, a));

  Free<F, Either<Object, dynamic/*=A*/>> attempt/*<A>*/(Free<IOOp, dynamic/*=A*/> fa) => liftOp(new Attempt(fa));

  Free<F, dynamic/*=A*/> fail/*<A>*/(Object failure) => liftOp(new Fail(failure));
}

final io = new IOOps(new IdFreeComposer());
