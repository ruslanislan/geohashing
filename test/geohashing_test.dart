import 'package:flutter_test/flutter_test.dart';

import 'package:geohashing/geohashing.dart';

import 'helpers.dart';

void main() {
  group('boxes module', () {
    test('decodes bbox from int hash with even depth', () {
      final list = givenHash('11000111111010111000110000111110');
      final hashInt = list[0];
      final bitDepth = list[1];

      const expectedMinLat = 40.1824951171875;
      const expectedMinLng = 44.5111083984375;
      const expectedMaxLat = 40.18524169921875;
      const expectedMaxLng = 44.5166015625;

      final box = decodeBboxInt(hashInt: hashInt, bitDepth: bitDepth);

      expect(box.minLat, expectedMinLat);
      expect(box.minLng, expectedMinLng);
      expect(box.maxLat, expectedMaxLat);
      expect(box.maxLng, expectedMaxLng);
    });

    test('decodes bbox from int hash with odd depth', () {
      final list = givenHash('1100011111101011100011000011111');
      final hashInt = list[0];
      final bitDepth = list[1];

      const expectedMinLat = 40.1824951171875;
      const expectedMinLng = 44.5111083984375;
      const expectedMaxLat = 40.18798828125;
      const expectedMaxLng = 44.5166015625;

      final box = decodeBboxInt(hashInt: hashInt, bitDepth: bitDepth);

      expect(box.minLat, expectedMinLat);
      expect(box.minLng, expectedMinLng);
      expect(box.maxLat, expectedMaxLat);
      expect(box.maxLng, expectedMaxLng);
    });

    test('throws error due to invalid bit depth when decoding bbox', () {
      final list = givenHash('1100011111101011100011000011111');
      final hashInt = list[0];
      const tooSmallBitDepth = 0;
      const tooBigBitDepth = 53;

      expect(
        () => decodeBboxInt(hashInt: hashInt, bitDepth: tooSmallBitDepth),
        RangeError,
      );
      expect(
        () => decodeBboxInt(hashInt: hashInt, bitDepth: tooBigBitDepth),
        RangeError,
      );
    });

    test('encodes bbox and returns int hash with odd depth', () {
      const minLat = 40.18310749942694;
      const minLng = 44.51227395945389;
      const maxLat = 40.18729483721813;
      const maxLng = 44.51623995096614;
      final list = givenHash('1100011111101011100011000011111');
      final expectedHashInt = list[0];
      final expectedBitDepth = list[1];

      final bboxIntObj = encodeBboxInt(
        minLat: minLat,
        minLng: minLng,
        maxLat: maxLat,
        maxLng: maxLng,
      );

      expect(bboxIntObj, isNotNull);
      expect(bboxIntObj?.hashInt, expectedHashInt);
      expect(bboxIntObj?.bitDepth, expectedBitDepth);
    });

    test('decodes bbox from base-32 hash', () {
      const hashBase32 = 'szpssgr';
      const expectedMinLat = 40.183868408203125;
      const expectedMinLng = 44.515228271484375;
      const expectedMaxLat = 40.18524169921875;
      const expectedMaxLng = 44.5166015625;

      final box = decodeBboxBase32(hashBase32);

      expect(box.minLat, expectedMinLat);
      expect(box.minLng, expectedMinLng);
      expect(box.maxLat, expectedMaxLat);
      expect(box.maxLng, expectedMaxLng);
    });

    test('encodes bbox with exact edge coordinates to base-32 hash', () {
      const minLat = 40.183868408203125;
      const minLng = 44.515228271484375;
      const maxLat = 40.18524169921875;
      const maxLng = 44.5166015625;
      const expectedHashBase32 = 'szpssgr';

      final hashBase32 = encodeBboxBase32(
        minLat: minLat,
        minLng: minLng,
        maxLat: maxLat,
        maxLng: maxLng,
      );

      expect(hashBase32, expectedHashBase32);
    });

    test('encodes bbox to base-32 hash', () {
      const minLat = 40.18386841820312;
      const minLng = 44.51522837148437;
      const maxLat = 40.18524168921875;
      const maxLng = 44.5166014625;
      const expectedHashBase32 = 'szpssgr';

      final hashBase32 = encodeBboxBase32(
        minLat: minLat,
        minLng: minLng,
        maxLat: maxLat,
        maxLng: maxLng,
      );

      expect(hashBase32, expectedHashBase32);
    });

    test(
        'returns null because bbox occupies both eastern and western hemispheres',
        () {
      const minLat = 40.18386841820312;
      const minLng = -104.51522837148437;
      const maxLat = 40.18524168921875;
      const maxLng = 120.5166014625;

      final hashInt = encodeBboxInt(
        minLat: minLat,
        minLng: minLng,
        maxLat: maxLat,
        maxLng: maxLng,
      );
      final hashBase32 = encodeBboxBase32(
        minLat: minLat,
        minLng: minLng,
        maxLat: maxLat,
        maxLng: maxLng,
      );

      expect(hashInt, null);
      expect(hashBase32, null);
    });

    test('throws error because of invalid coordinates', () {
      const minLat = 40.18386841820312;
      const minLng = 44.51522837148437;
      const maxLat = 40.18524168921875;
      const maxLng = 44.5166014625;

      const tooSmallLat = -91.0;
      const toSmallLng = -181.0;
      const tooBigLat = 91.0;
      const tooBigLng = 181.0;

      expect(
        () => encodeBboxBase32(
          minLat: tooSmallLat,
          minLng: minLng,
          maxLat: maxLat,
          maxLng: maxLng,
        ),
        RangeError,
      );
      expect(
        () => encodeBboxBase32(
          minLat: minLat,
          minLng: toSmallLng,
          maxLat: maxLat,
          maxLng: maxLng,
        ),
        RangeError,
      );
      expect(
        () => encodeBboxBase32(
          minLat: minLat,
          minLng: minLng,
          maxLat: tooBigLat,
          maxLng: maxLng,
        ),
        RangeError,
      );
      expect(
        () => encodeBboxBase32(
          minLat: minLat,
          minLng: minLng,
          maxLat: maxLat,
          maxLng: tooBigLng,
        ),
        RangeError,
      );
    });

    test('calculates all int hashes within a bbox', () {
      const minLat = 40.17520776009799;
      const minLng = 44.50734670780776;
      const maxLat = 40.18798176349887;
      const maxLng = 44.51627726366204;
      const bitDepth = 32;
      final expectedHashesInt = [
        3354102829,
        3354102831,
        3354102840,
        3354102842,
        3354102841,
        3354102843,
        3354102844,
        3354102846,
        3354102845,
        3354102847,
      ]..sort(compare);

      final hashesInt = getHashesWithinBboxInt(
        minLat: minLat,
        minLng: minLng,
        maxLat: maxLat,
        maxLng: maxLng,
        bitDepth: bitDepth,
      );

      expect(hashesInt..sort(compare), expectedHashesInt);
    });

    test('calculates all base-32 hashes within a bbox', () {
      const minLat = 40.18320776009799;
      const minLng = 44.51334670780776;
      const maxLat = 40.18798176349887;
      const maxLng = 44.51627726366204;
      const precision = 7;
      final expectedHashesBase32 = [
        'szpssgj',
        'szpssgn',
        'szpssgp',
        'szpssgm',
        'szpssgq',
        'szpssgr',
        'szpssgt',
        'szpssgw',
        'szpssgx',
        'szpssgv',
        'szpssgy',
        'szpssgz',
      ]..sort();

      final hashesBase32 = getHashesWithinBboxBase32(
        minLat: minLat,
        minLng: minLng,
        maxLat: maxLat,
        maxLng: maxLng,
        length: precision,
      );

      expect(hashesBase32..sort(), expectedHashesBase32);
    });
  });
}
