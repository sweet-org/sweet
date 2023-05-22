import 'dart:core';
import 'dart:typed_data';
import 'dart:convert';

class Murmur32 {
  int c1 = 0xcc9e2d51.toUnsigned(32);
  int c2 = 0x1b873593.toUnsigned(32);

  late int _seed;
  Murmur32(int seed) {
    _seed = seed.toUnsigned(32);
    _reset();
  }

  int get seed => _seed;

  late int h1;
  late int length;

  void _reset() {
    h1 = seed;
    length = 0;
  }

  ByteData computeHashFromString(String source) {
    var buffer = Uint8List.fromList(utf8.encode(source));
    return computeHash(buffer, 0, buffer.length);
  }

  ByteData computeHash(Uint8List buffer, int offset, int count) {
    _reset();
    hashCore(buffer, 0, buffer.length);

    h1 = fMix((h1 ^ length).toUnsigned(32));
    return ByteData(4)..buffer.asByteData().setUint32(0, h1);
  }

  int fMix(int h) {
    // pipelining friendly algorithm
    h = ((h ^ (h >> 16)) * 0x85ebca6b).toUnsigned(32);
    h = ((h ^ (h >> 13)) * 0xc2b2ae35).toUnsigned(32);
    return (h ^ (h >> 16)).toUnsigned(32);
  }

  int rotateLeft(int x, int r) {
    return ((x << r) | (x >> (32 - r))).toUnsigned(32);
  }

  int toUint32(Uint8List data, int start) {
    return Endian.host == Endian.little
        ? (data[start] |
            data[start + 1] << 8 |
            data[start + 2] << 16 |
            data[start + 3] << 24)
        : (data[start] << 24 |
            data[start + 1] << 16 |
            data[start + 2] << 8 |
            data[start + 3]);
  }

  void hashCore(Uint8List buffer, int start, int count) {
    length += count.toUnsigned(32);
    var remainder = count & 3;
    var alignedLength = (start + (count - remainder)).toUnsigned(32);

    for (var i = start; i < alignedLength; i += 4) {
      var v1 = (toUint32(buffer, i) * c1).toUnsigned(32);
      var v2 = rotateLeft(v1, 15);
      var v3 = (v2 * c2).toUnsigned(32);
      var v4 = (h1 ^ v3).toUnsigned(32);
      var v5 = rotateLeft(v4, 13);
      var v6 = (v5 * 5).toUnsigned(32);

      h1 = (v6 + 0xe6546b64).toUnsigned(32);
    }

    if (remainder > 0) {
      // create our keys and initialize to 0
      var k1 = 0;

      // determine how many bytes we have left to work with based on length
      switch (remainder) {
        case 3:
          k1 ^= (buffer[alignedLength + 2] << 16).toUnsigned(32);
          continue case2;

        case2:
        case 2:
          k1 ^= (buffer[alignedLength + 1] << 8).toUnsigned(32);
          continue case1;

        case1:
        case 1:
          k1 ^= buffer[alignedLength];
          break;
      }

      h1 ^= (rotateLeft((k1 * c1).toUnsigned(32), 15) * c2).toUnsigned(32);
    }
  }
}
