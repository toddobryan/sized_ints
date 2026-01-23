import 'dart:typed_data';

class Config {
  static int? _bitsPerListElement;

  static void setElementBitSize(int elementBitSize) {
    if (_bitsPerListElement != null) {
      throw StateError("elementBitSize may only be set once");
    } else if (elementBitSize != 8 && elementBitSize != 16 && elementBitSize != 32) {
      throw ArgumentError("Only 8, 16, and 32 are allowed for bitsPerListElement");
    } else {
      _bitsPerListElement = elementBitSize;
    }
  }

  static int get bitsPerListElement {
    _bitsPerListElement ??= 8;
    return _bitsPerListElement!;
  }

  static TypedDataList<int> newList(int length) => switch(bitsPerListElement) {
    8 => Uint8List(length),
    16 => Uint16List(length),
    32 => Uint32List(length),
    _ => throw StateError("illegal bitsPerListElement: $bitsPerListElement"),
  };

  static TypedDataList<int> listFromInts(List<int> ints) => switch(bitsPerListElement) {
    8 => Uint8List.fromList(ints),
    16 => Uint16List.fromList(ints),
    32 => Uint32List.fromList(ints),
    _ => throw StateError("illegal bitsPerListElement: $bitsPerListElement"),
  };
}