extension BigIntOp on BigInt {
  int get signedBitLength => bitLength + 1;
  String get hex => toRadixString(16);
}

extension IntOp on int {
  int get signedBitLength => bitLength + 1;
}

BigInt parseWithUnderscores(String value) =>
    BigInt.parse(value.replaceAll('_', ''));