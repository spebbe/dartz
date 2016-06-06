library free_io_example;

import 'package:dartz/dartz.dart';
import 'io.dart';
import 'console_io.dart';
import 'mock_io.dart';

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
  // Referentially transparent, since execution is only affected by the input vector argument.
  print(await mockPerformIO(greeter, ivector(["Björn", "dartz", "q"])));

  // Interpret IO program using side-effecting console interpreter.
  // _NOT_ referentially transparent, since execution is affected by whatever the user inputs in the console.
  unsafePerformIO(greeter);

  // Now imagine an interpreter that takes input from a DOM 'input' element and writes output to a DOM 'ul' element.
  // ...or an interpreter that reads and writes from/to REST services using XHR/fetch.
  // Regardless of the interpreter used, 'greeter' remains unchanged.

}