library huffman_example;

import 'huffmancodec.dart';
import 'package:dartz/dartz.dart';

void main() {

  final plainText = """
In computer science and information theory, a Huffman code is a particular type of optimal prefix code
that is commonly used for lossless data compression. The process of finding and/or using such a code
proceeds by means of Huffman coding, an algorithm developed by David A. Huffman while he was a Ph.D.student
at MIT, and published in the 1952 paper "A Method for the Construction of Minimum-Redundancy Codes".
""";

  final HuffmanCodec codec = HuffmanCodec.fromSource(plainText).getOrElse(() => throw "Failed to build codec");

  final IList<Bit> compressed = codec.encode(plainText).getOrElse(() => throw "Failed to compress");

  final compressionRatio = plainText.length*8 / compressed.length();
  final savings = 1.0-1.0/compressionRatio;
  print("Compression ratio: ${compressionRatio.toStringAsFixed(2)}, space saved: ${(100.0*savings).toStringAsFixed(2)}%");

  final String decompressed = codec.decode(compressed);

  print("plainText == decompressed: ${plainText == decompressed}");

}