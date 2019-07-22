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

class ReadBytes extends IOOp<UnmodifiableListView<int>> {
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

class Gather<A> extends IOOp<IList<A>> {
  final IList<Free<IOOp, A>> ops;
  Gather(this.ops);
}

class IOMonad extends FreeMonad<IOOp> implements MonadCatch<Free<IOOp, dynamic>> {
  @override Free<IOOp, A> pure<A>(A a) => new Pure(a);
  @override Free<IOOp, Either<Object, A>> attempt<A>(Free<IOOp, A> fa) => liftF(new Attempt(fa));
  @override Free<IOOp, A> fail<A>(Object err) => liftF(new Fail(err));
  // appease the twisted type system (issue #18)
  @override Free<IOOp, B> bind<A, B>(Free<IOOp, A> fa, Free<IOOp, B> f(A a)) => super.bind(fa, f);
}

final IOMonad IOM = new IOMonad();
final MonadCatch<Free<IOOp, dynamic>> IOMC = IOM;
MonadCatch<Free<IOOp, A>> iomc<A>() => cast(IOMC);

class IOOps<F> extends FreeOps<F, IOOp> {
  IOOps(FreeComposer<F, IOOp> composer) : super(composer);

  Free<F, String> readln() => liftOp(new Readln());

  Free<F, Unit> println(String s) => liftOp(new Println(s));

  Free<F, FileRef> openFile(String path, bool openForRead) => liftOp(new OpenFile(path, openForRead));

  Free<F, UnmodifiableListView<int>> readBytes(FileRef file, int byteCount) => liftOp(new ReadBytes(file, byteCount));

  Free<F, Unit> writeBytes(FileRef file, IList<int> bytes) => liftOp(new WriteBytes(file, bytes));

  Free<F, Unit> closeFile(FileRef file) => liftOp(new CloseFile(file));

  Free<F, ExecutionResult> execute(String command, IList<String> arguments) => liftOp(new Execute(command, arguments));

  Free<F, A> delay<A>(Duration duration, Free<IOOp, A> a) => liftOp(new Delay(duration, a));

  Free<F, Either<Object, A>> attempt<A>(Free<IOOp, A> fa) => liftOp(new Attempt(fa));

  Free<F, A> fail<A>(Object failure) => liftOp(new Fail(failure));

  Free<F, IList<A>> gather<A>(IList<Free<IOOp, A>> ops) => liftOp(new Gather(ops));
}

final io = new IOOps<IOOp>(new IdFreeComposer());
