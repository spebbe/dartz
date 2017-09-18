library streaming_io_example_2;

import '../free_io/mock_io.dart';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dartz/dartz_streaming.dart';
import 'package:dartz/dartz_unsafe.dart';

main() async {
  // set up some paths
  final libDir = Platform.script.resolve("../../lib/");
  final dartzPath = libDir.resolve("dartz.dart");

  final Conveyor<Free<IOOp, dynamic>, String> dartzPublicClasses = IO.fileLineReader(dartzPath.path) // stream file lines
      .filter((line) => line.startsWith("part '"))                                                   // find 'part' declarations
      .map((partDeclaration) => partDeclaration.substring(6, partDeclaration.length-2))              // extract part path
      .flatMap((partName) => IO.fileLineReader(libDir.resolve(partName).path)                        // stream part file lines
      .pipe(Text.regexp("\^(abstract )?class (\\w+)", group: 2))                                     // extract declared class names
      .filter((className) => !className.startsWith("_"))                                             // drop private classes
      .map((className) => "$className${' '*(30 - className.length)}<- $partName"));                  // present results

  // compose abstract streaming program
  final program = dartzPublicClasses.to(IO.stdoutWriter);

  // now that we have an abstract streaming program, we can set up a pretend world for it...
  final mockedInputs = imap({
    dartzPath.path: ivector(["some unrelated line\n", "part 'mockedPart.dart';\n", "another line\n"]),
    libDir.resolve("mockedPart.dart").path: ivector(["abstract class _MockedPrivateClass\n", "class MockedPublicClass\n"])});

  // ...construct an expected output...
  final expectedOutput = right(ivector(["stdout: MockedPublicClass             <- mockedPart.dart"]));

  // ...and test it using a non side effecting interpreter...
  assert((await mockConveyIO(program, mockedInputs)).map((result) => result.value1) == expectedOutput);

  // ...or just run it using an interpreter that does real IO side effects!
  await unsafeConveyIO(program);
}