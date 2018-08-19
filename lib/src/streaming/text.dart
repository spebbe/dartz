part of dartz_streaming;

class Text {

  static const _utf8 = const Utf8Codec();

  static final Conveyor<From<UnmodifiableListView<int>>, String> decodeUtf8 = Pipe.lift((UnmodifiableListView<int> l) => l).pipe(_decodeUtf8());

  static final Conveyor<From<String>, IList<int>> encodeUtf8 = Pipe.lift(composeF(ilist, _utf8.encode));

  // TODO: Naively buffers extremely long lines
  static final Conveyor<From<String>, String> lines = _lines(none());

  static Conveyor<From<String>, String> _lines(Option<String> spill) =>
      Pipe.consume((s) {
        final buffered = (spill|"") + s;
        final lines = ilist(buffered.split("\n"));
        return lines.reverse().uncons(Pipe.halt, (newSpill, completeLines) =>
            completeLines.foldLeft(_lines(option(newSpill.length > 0, newSpill)), (rest, line) => Conveyor.produce(line, rest))
        );
      }, () => spill.fold(Pipe.halt, Pipe.produce));

  // TODO: missing some corner case here, right?
  static Conveyor<From<UnmodifiableListView<int>>, String> _decodeUtf8() {
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

    Conveyor<From<UnmodifiableListView<int>>, String> loop(List<int> oldSpill) => Pipe.consume((rawBytes) {
      final trimmedBytesAndSpill = _findSpill([oldSpill, rawBytes].expand(id).toList(growable: false));
      return Pipe.produce(_utf8.decode(trimmedBytesAndSpill.value1), loop(trimmedBytesAndSpill.value2));
    });
    return loop(new UnmodifiableListView([]));
  }

  static Conveyor<From<String>, String> regexp(String regexpSource, {int group: 0}) {
    final regexp = new RegExp(regexpSource);
    final pipe = Pipe.consume<String, String>((s) {
      final matches = ilist(regexp.allMatches(s)).filter((m) => m.groupCount >= group);
      return matches.foldRight(Pipe.halt(), (match, acc) => Pipe.produce(match.group(group), acc));
    });
    return pipe.repeatUntilExhausted();
  }

}