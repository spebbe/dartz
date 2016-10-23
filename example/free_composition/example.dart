library free_composition_example;

import 'package:dartz/dartz.dart';
import 'package:dartz/dartz_unsafe.dart';
import '../free_io/mock_io.dart' as mockIO;
import 'free_rand.dart';

// Technique: Compose IOOp and RandOp algebras, deriving Free algebras and interpreters capable of handling both.
final ioAndRand = new Free2<IOOp, RandOp>();
final ioOps = new IOOps(ioAndRand.firstComposer);
final randOps = new RandOps(ioAndRand.secondComposer);
final unsafePerformIOAndRand = ioAndRand.interpreter(FutureM, unsafeIOInterpreter, unsafeRandInterpreter);

// Technique: Construct RT program, sequencing both RandOp and IOOp through the composed algebra
final thinkOfNumber = randOps.nextIntBetween(1, 5);
final promptUser = ioOps.println("I'm thinking of a number between 1 and 5. Guess which one!");
final readUserGuess = ioOps.readln().map((s) => catching(() => int.parse(s)).toOption());
final checkUserGuess = (int myNumber) => (Option<int> maybeUserGuess) => maybeUserGuess.map(
    (userGuess) => (userGuess == myNumber)
        ? ioOps.println("O... M... G... you're like telepathic!!!")
        : ioOps.println("Sorry... I was thinking of $myNumber..."))
| ioOps.println("""ok... that's an unusual "number"... anyway, you're wrong.""");
final program = thinkOfNumber.bind((myNumber) => promptUser.andThen(readUserGuess.bind(checkUserGuess(myNumber))));


// Technique: Test program using composed mock interpreters
testProgram() async {
  final mockedProgram = ioAndRand.interpreter(mockIO.MockM, mockIO.mockIOInterpreter, curry2(mockRandInterpreter)(0))(program);

  final correctGuess = await mockedProgram.run(imap({"stdin": ivector(["1"])}), emptyMap());
  assert(correctGuess == right(tuple3(ivector([
    "stdout: I'm thinking of a number between 1 and 5. Guess which one!",
    "stdout: O... M... G... you're like telepathic!!!"])
  , imap({"stdin": 1}), unit)));

  final incorrectGuess = await mockedProgram.run(imap({"stdin": ivector(["2"])}), emptyMap());
  assert(incorrectGuess == right(tuple3(ivector([
    "stdout: I'm thinking of a number between 1 and 5. Guess which one!",
    "stdout: Sorry... I was thinking of 1..."])
  , imap({"stdin": 1}), unit)));

  final invalidGuess = await mockedProgram.run(imap({"stdin": ivector(["kossan"])}), emptyMap());
  assert(invalidGuess == right(tuple3(ivector([
    "stdout: I'm thinking of a number between 1 and 5. Guess which one!",
    """stdout: ok... that's an unusual "number"... anyway, you're wrong."""])
  , imap({"stdin": 1}), unit)));

  final noInput = await mockedProgram.run(emptyMap(), emptyMap());
  assert(noInput == right(tuple3(ivector([
    "stdout: I'm thinking of a number between 1 and 5. Guess which one!",
    """stdout: ok... that's an unusual "number"... anyway, you're wrong."""])
  , imap({"stdin": 1}), unit)));
}

main() async {
  // Test program correctness without performing any side effects
  await testProgram();

  // Run program using composed side effecting interpreter
  await unsafePerformIOAndRand(program);
}
