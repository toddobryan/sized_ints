import 'dart:typed_data';

import 'package:sized_ints/sized_int.dart';
import 'package:checks/checks.dart';
import 'package:test/test.dart';

void main() {
  test('shiftRight', () {
    check(
      Uint8List.fromList([255]).shiftBitsRightUnsigned(3),
    ).deepEquals(Uint8List.fromList([31]));
  });
}
