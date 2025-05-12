import 'package:sized_ints/sized_int.dart';
import 'package:spec/spec.dart';

void main() {
  group('statics', () {
    test('positiveMask', () {
      expect(SizedInt.positiveMask(1)).toEqual(1);
      expect(SizedInt.positiveMask(2)).toEqual(3);
      expect(SizedInt.positiveMask(8)).toEqual(255);
    });
    test('negativeMask', () {
      expect(SizedInt.negativeMask(1)).toEqual(-2);
      expect(SizedInt.negativeMask(3)).toEqual(-8);
      expect(SizedInt.negativeMask(8)).toEqual(-256);
    });
    test('sizedIntToList', () {
      expect(SizedInt.signedIntToList(8, -1).toString()).toEqual('[255]');
    });
  });
}
