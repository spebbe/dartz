library streaming_io_example;

import 'dart:async';

import 'package:dartz/dartz_streaming.dart';
import 'package:dartz/dartz_unsafe.dart';

import 'dart:io';

amain() async {

  final pathToThisFile = "/Users/bjorns/Documents/Development/github/spebbe/dartz/example/streaming_io/example.dart";// Platform.script.toFilePath();

  // Construct Conveyor that:
  // 1. Reads lines from this file
  // 2. Trims leading and trailing whitespace
  // 3, 4. Finds single line comments and removes consecutive duplicates
  // 3, 4. Finds single line comments and removes consecutive duplicates
  // 5. Stops after five comments are consumed
  final firstFiveCommentsInThisFile = IO.fileLineReader(pathToThisFile)
      .map((line) => line.trim())
      .filter((line) => line.startsWith("//"))
      .skipDuplicates()
      .take(5)
      .appendElement("---");

  // This is the sixth comment. It might never be read from the file,
  // since the Conveyor finishes as soon as the fifth comment is consumed.
  // The file will be closed as soon as the Conveyor finishes.

  print("Here we go!");

  await unsafeConveyIO(firstFiveCommentsInThisFile.to(IO.stdoutWriter));

  // Conveyors are pure values, and can safely be reused:
  await unsafeConveyIO(firstFiveCommentsInThisFile.to(IO.stdoutWriter));

  // ...and composed further:
  await unsafeConveyIO(firstFiveCommentsInThisFile.map((s) => s.toUpperCase()).to(IO.stdoutWriter));
}

void main() {
  print("Starting!");
  amain();
  //sleep(new Duration(seconds: 1));
  new Future(() => print("Bye!"));
}
