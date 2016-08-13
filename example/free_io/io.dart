library free_io_io;

import 'package:dartz/dartz.dart';
import 'dart:io';

// Technique: Lift ADT into Free monad using liftF
abstract class IOOp<A> {}

class Readln extends IOOp<String> {}
final Free<IOOp, String> readln = liftF(new Readln());

class Println extends IOOp<Unit> {
  final String s;
  Println(this.s);
}
Free<IOOp, Unit> println(String s) => liftF(new Println(s));

class OpenFile extends IOOp<RandomAccessFile> {
  final String path;
  OpenFile(this.path);
}
Free<IOOp, RandomAccessFile> openFile(String path) => liftF(new OpenFile(path));

class ReadBytes extends IOOp<IList<int>> {
  final RandomAccessFile file;
  final int byteCount;
  ReadBytes(this.file, this.byteCount);
}
Free<IOOp, IList<int>> readBytes(RandomAccessFile file, int byteCount) => liftF(new ReadBytes(file, byteCount));

class CloseFile extends IOOp<Unit> {
  final RandomAccessFile file;
  CloseFile(this.file);
}
Free<IOOp, Unit> closeFile(RandomAccessFile file) => liftF(new CloseFile(file));

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

final IOM = new IOMonad();
