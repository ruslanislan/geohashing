import 'package:geohashing/geohashing.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void hashingTest() {
  group('hashing module', () {
    test('decodes int hash with even depth', () {
      final list = givenHash('11000111111010111000110000111110');
      final hashInt = list[0];
      final bitDepth = list[1];
      const expectedLat = 40.183868408203125;
      const expectedLng = 44.51385498046875;
      const expectedLatError = 0.001373291015625;
      const expectedLngError = 0.00274658203125;

      final coords = decodeInt(hashInt: hashInt, bitDepth: bitDepth);

      expect(coords.lat, expectedLat);
      expect(coords.error!.lat, expectedLatError);
      expect(coords.lng, expectedLng);
      expect(coords.error!.lng, expectedLngError);
    });

    test('decodes int hash with odd depth', () {
      final list = givenHash('1100011111101011100011000011111');
      final hashInt = list[0];
      final bitDepth = list[1];
      const expectedLat = 40.18524169921875;
      const expectedLng = 44.51385498046875;
      const expectedLatError = 0.00274658203125;
      const expectedLngError = 0.00274658203125;

      final coords = decodeInt(hashInt: hashInt, bitDepth: bitDepth);

      expect(coords.lat, expectedLat);
      expect(coords.error, isNotNull);
      expect(coords.error!.lat, expectedLatError);
      expect(coords.lng, expectedLng);
      expect(coords.error!.lng, expectedLngError);
    });

    test('throws error due to invalid bit depth', () {
      final list = givenHash('1100011111101011100011000011111');
      final hashInt = list[0];
      const tooSmallBitDepth = 0;
      const tooBigBitDepth = 53;

      expect(
            () => decodeInt(hashInt: hashInt, bitDepth: tooSmallBitDepth),
        throwsA(
          const TypeMatcher<RangeError>(),
        ),
      );
      expect(
            () => decodeInt(hashInt: hashInt, bitDepth: tooBigBitDepth),
        throwsA(
          const TypeMatcher<RangeError>(),
        ),
      );
    });

    test('encodes int hash with even depth', () {
      const lat = 40.183868408203125;
      const lng = 44.51385498046875;
      const bitDepth = 32;
      final list = givenHash('11000111111010111000110000111110');
      final expectedHashInt = list[0];
      final hashInt = encodeInt(lat: lat, lng: lng, bitDepth: bitDepth);

      expect(hashInt, expectedHashInt);
    });

    test('encodes int hash with odd depth', () {
      const lat = 40.183868408203125;
      const lng = 44.51385498046875;
      const bitDepth = 31;
      final expectedHashInt = givenHash('1100011111101011100011000011111')[0];

      final hashInt = encodeInt(lat: lat, lng: lng, bitDepth: bitDepth);

      expect(hashInt, expectedHashInt);
    });

    test('encodes base-32 hash', () {
      const lat = 37.8324;
      const lng = 112.5584;
      const expectedHashBase32 = 'ww8p1r4t8';

      final hashBase32 = encodeBase32(lat: lat, lng: lng);

      expect(hashBase32, expectedHashBase32);
    });

    test('throws error due to invalid base-32 hash length', () {
      const lat = 37.8324;
      const lng = 112.5584;
      const tooSmallLength = 0;
      const tooBigLength = 10;

      expect(
            () => encodeBase32(lat: lat, lng: lng, length: tooSmallLength),
        throwsA(
          const TypeMatcher<RangeError>(),
        ),
      );
      expect(
            () => encodeBase32(lat: lat, lng: lng, length: tooBigLength),
        throwsA(
          const TypeMatcher<RangeError>(),
        ),
      );
    });

    test('throws error due to invalid latitude or longitude', () {
      const lat = 37.8324;
      const lng = 112.5584;
      const tooSmallLat = -91.0;
      const toSmallLng = -181.0;
      const tooBigLat = 91.0;
      const tooBigLng = 181.0;

      expect(
            () => encodeBase32(lat: tooSmallLat, lng: lng),
        throwsA(
          const TypeMatcher<RangeError>(),
        ),
      );
      expect(
            () => encodeBase32(lat: lat, lng: toSmallLng),
        throwsA(
          const TypeMatcher<RangeError>(),
        ),
      );
      expect(
            () => encodeBase32(lat: tooBigLat, lng: lng),
        throwsA(
          const TypeMatcher<RangeError>(),
        ),
      );
      expect(
            () => encodeBase32(lat: lat, lng: tooBigLng),
        throwsA(
          const TypeMatcher<RangeError>(),
        ),
      );
    });

    test('decodes base-32 hash', () {
      const hashBase32 = 'ww8p1r4t8';
      const expectedLat = 37.83238649368286;
      const expectedLng = 112.55838632583618;

      final coords = decodeBase32(hashBase32);

      final lat = coords.lat;
      final lng = coords.lng;
      expect(lat, expectedLat);
      expect(lng, expectedLng);
    });

    test('throws error due to invalid character in base-32 hash', () {
      const hashBase32 = 'wi8p1r4t8';

      expect(
            () => decodeBase32(hashBase32),
        throwsA(
          const TypeMatcher<RangeError>(),
        ),
      );
    });

    test('encodes edge case coordinates properly', () {
      expect(encodeBase32(lat: -90, lng: -180), '000000000');
      expect(encodeBase32(lat: -90, lng: 0), 'h00000000');
      expect(encodeBase32(lat: -90, lng: 180), 'pbpbpbpbp');
      expect(encodeBase32(lat: 0, lng: -180), '800000000');
      expect(encodeBase32(lat: 0, lng: 0), 's00000000');
      expect(encodeBase32(lat: 0, lng: 180), 'xbpbpbpbp');
      expect(encodeBase32(lat: 90, lng: -180), 'bpbpbpbpb');
      expect(encodeBase32(lat: 90, lng: 0), 'upbpbpbpb');
      expect(encodeBase32(lat: 90, lng: 180), 'zzzzzzzzz');
    });

    test('decodes edge case hashes properly', () {
      final errorCoords =
      Coordinates(0.000021457672119140625, 0.000021457672119140625, null);

      expect(
        decodeBase32('000000000'),
        Coordinates(-89.99997854232788, -179.99997854232788, errorCoords),
      );
      expect(
        decodeBase32('h00000000'),
        Coordinates(-89.99997854232788, 0.000021457672119140625, errorCoords),
      );
      expect(decodeBase32('pbpbpbpbp'),
          Coordinates(-89.99997854232788, 179.99997854232788, errorCoords));
      expect(
          decodeBase32('800000000'),
          Coordinates(
              0.000021457672119140625, -179.99997854232788, errorCoords));
      expect(
          decodeBase32('s00000000'),
          Coordinates(
              0.000021457672119140625, 0.000021457672119140625, errorCoords));
      expect(
          decodeBase32('xbpbpbpbp'),
          Coordinates(
              0.000021457672119140625, 179.99997854232788, errorCoords));
      expect(decodeBase32('bpbpbpbpb'),
          Coordinates(89.99997854232788, -179.99997854232788, errorCoords));
      expect(decodeBase32('upbpbpbpb'),
          Coordinates(89.99997854232788, 0.000021457672119140625, errorCoords));
      expect(decodeBase32('zzzzzzzzz'),
          Coordinates(89.99997854232788, 179.99997854232788, errorCoords));
    });
  });
}