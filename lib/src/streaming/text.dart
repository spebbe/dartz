part of dartz_streaming;

class Text {

  static final Conveyor<From<IList<int>>, String> decodeUtf8 = Pipe.lift((l) => l.toList()).pipe(_decodeUtf8());

  static final Conveyor<From<String>, IList<int>> encodeUtf8 = Pipe.lift(composeF(ilist, UTF8.encode));

  // TODO: Naively buffers extremely long lines
  static final Conveyor<From<String>, String> lines = _lines(none());

  static Conveyor<From<String>, String> _lines(Option<String> spill) =>
      Pipe.consume((s) {
        final buffered = (spill|"") + s;
        final lines = ilist(buffered.split("\n"));
        return lines.reverse().uncons(Pipe.halt, (newSpill, completeLines) =>
            completeLines.foldLeft/*<Conveyor<From<String>, String>>*/(_lines(option(newSpill.length > 0, newSpill)), (rest, line) => Conveyor.produce(line, rest))
        );
      }, () => spill.fold(Pipe.halt, Pipe.produce));

  // TODO: missing some corner case here, right?
  static Conveyor<From<List<int>>, String> _decodeUtf8() {
    Tuple2<List<int>, List<int>> _findSpill(List<int> bytes) {
      final int byteCount = bytes.length;
      if (byteCount == 0) {
        return tuple2([], []);
      } else if ((bytes[byteCount-1] & 128) == 0) {
        return tuple2(bytes, []);
      } else if (byteCount > 1 && (bytes[byteCount-2] & 128) == 0) {
        return tuple2(bytes.sublist(0, byteCount-1), bytes.sublist(byteCount-1, byteCount));
      } else if (byteCount > 2 && (bytes[byteCount-3] & 128) == 0) {
        return tuple2(bytes.sublist(0, byteCount-2), bytes.sublist(byteCount-2, byteCount));
      } else if (byteCount > 3 && (bytes[byteCount-4] & 128) == 0) {
        return tuple2(bytes.sublist(0, byteCount-3), bytes.sublist(byteCount-3, byteCount));
      } else {
        return tuple2([], bytes);
      }
    }

    Conveyor<From<List<int>>, String> loop(List<int> oldSpill) => Pipe.consume((List<int> rawBytes) {
      final trimmedBytesAndSpill = _findSpill([oldSpill, rawBytes].expand(id).toList());
      return Pipe.produce(UTF8.decode(trimmedBytesAndSpill.value1), loop(trimmedBytesAndSpill.value2));
    });
    return loop([]);
  }

}