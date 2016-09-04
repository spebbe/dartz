library free_io_example;

import 'package:dartz/dartz.dart';
import 'mock_io.dart';
import 'package:dartz/dartz_unsafe.dart';

// Technique: Construct referentially transparent program using monadic sequencing.
//            The resulting program is a pure value and doesn't have any knowledge of
//            if, how, when and/or where it will be interpreted.
final Free<IOOp, dynamic> greeter = println("Please enter your name (or 'q' to quit):") >>
    readln >= (name) => (
    (name == "q")
        ? println("Bye!")
        : println("Hello $name!") >> greeter);

main() async {

  // Interpret IO program using mock interpreter.
  // Execution is only affected by the input vector argument.
  final actualOutput = await mockPerformIO(greeter, ivector(["Björn", "dartz", "q"]));
  final expectedOutput = right(tuple3(ivector([
    "Please enter your name (or 'q' to quit):",
    "Hello Björn!",
    "Please enter your name (or 'q' to quit):",
    "Hello dartz!",
    "Please enter your name (or 'q' to quit):",
    "Bye!"
  ]), 3, unit));
  print("greeter produces expected output for mocked input: ${actualOutput == expectedOutput}");

  // Interpret IO program using side-effecting console interpreter.
  // Execution is affected by whatever the user inputs in the console.
  await unsafePerformIO(greeter);

  // Now imagine an interpreter that takes input from a DOM 'input' element and writes output to a DOM 'ul' element.
  // ...or an interpreter that reads and writes from/to REST services.
  // Regardless of the interpreter used, 'greeter' remains unchanged.

}
