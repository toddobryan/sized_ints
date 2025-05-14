import 'package:sized_ints/sized_int.dart';
import 'package:checks/checks.dart';
import 'package:test/test.dart';

void main() {
  group('statics', () {
    test('positiveMask', () {
      check(SizedInt.positiveMask(1)).equals(1);
      check(SizedInt.positiveMask(2)).equals(3);
      check(SizedInt.positiveMask(8)).equals(255);
    });
    test('negativeMask', () {
      check(SizedInt.negativeMask(1)).equals(-2);
      check(SizedInt.negativeMask(3)).equals(-8);
      check(SizedInt.negativeMask(8)).equals(-256);
    });
    test('sizedIntToList', () {
      check(SizedInt.signedIntToList(8, -1).toString()).equals('[255]');
    });
  });
}
