library free_io_io;

import 'package:dartz/dartz.dart';

// Technique: Lift ADT into Free monad using liftF
abstract class IOOp<A> {}

class Readln extends IOOp<String> {}
final Free<IOOp, String> readln = liftF(new Readln());

class Println extends IOOp<Unit> {
  final String s;
  Println(this.s);
}
Free<IOOp, Unit> println(String s) => liftF(new Println(s));

final Monad<Free<IOOp, dynamic>> IOM = freeM();
