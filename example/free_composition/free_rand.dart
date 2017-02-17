library free_composition_free_rand;

import 'dart:async';
import 'dart:math';
import 'package:dartz/dartz.dart';
import '../free_io/mock_io.dart' as mockIO;

// Technique: Model algebra for random number generation
abstract class RandOp<T> {}
class NextInt extends RandOp<int> {}

// Technique: Lift primitives into composable Free algebra and add combinators
class RandOps<F> extends FreeOps<F, RandOp> {
  RandOps(FreeComposer<F, RandOp> composer) : super(composer);

  Free<F, int> nextInt() => liftOp(new NextInt());

  Free<F, int> nextIntBetween(int min, int max) =>
      (min < 0 || min > max) ? freeM<F, int>().pure(0) : nextInt().map((i) => (i%(max-min+1))+min);
}

// Technique: Express RandOp using side effecting random number generator
Future unsafeRandInterpreter(RandOp op) {
  if (op is NextInt) {
    return new Future.value(new Random().nextInt(1<<32));

  } else {
    throw new UnimplementedError("Unimplemented RandOp: $op");
  }
}

// Technique: Express RandOp using mocked random number
mockRandInterpreter(int mockedRandomInt, RandOp op) {
  if (op is NextInt) {
    return mockIO.MockM.pure(mockedRandomInt);

  } else {
    return mockIO.MockM.raiseError("Unimplemented RandOp: $op");
  }
}