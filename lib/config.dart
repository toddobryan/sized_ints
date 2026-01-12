import "dart:typed_data";

// Change this section to use a different bit size for elements of the list
final int bitsPerListElement = 8;

TypedDataList<int> newList(int length) => Uint8List(length);

TypedDataList<int> listFromInts(List<int> ints) => Uint8List.fromList(ints);
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
