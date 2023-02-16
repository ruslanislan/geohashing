import 'package:geohashing/geohashing.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void neighborsTest() {
  group('neighbors module', () {
    test('matches directions to multipliers properly', () {
      const expectedMultipliers = [
        [1, 0],
        [1, 1],
        [0, 1],
        [-1, 1],
        [-1, 0],
        [-1, -1],
        [0, -1],
        [1, -1],
      ];

      final multipliers = Direction.values.map(mapDirectionToMultipliers);

      expect(multipliers, expectedMultipliers);
    });

    test("calculates neighbor's int hash", () {
      final list = givenHash('110001111110101110001100001111');
      final hashInt = list[0];
      final bitDepth = list[1];
      const direction = Direction.south;
      const expectedNeighborHashInt = 838525710;

      final neighborHashInt = getNeighborInt(
          hashInt: hashInt, direction: direction, bitDepth: bitDepth);

      expect(neighborHashInt, expectedNeighborHashInt);
    });

    test(
        "throws error due to invalid bit depth while calculating neighbor's hash",
        () {
      final hashInt = givenHash('1100011111101011100011000011111')[0];
      const direction = Direction.south;
      const tooSmallBitDepth = 0;
      const tooBigBitDepth = 53;

      expect(
        () => getNeighborInt(
            hashInt: hashInt, direction: direction, bitDepth: tooSmallBitDepth),
        throwsA(
          const TypeMatcher<RangeError>(),
        ),
      );
      expect(
        () => getNeighborInt(
            hashInt: hashInt, direction: direction, bitDepth: tooBigBitDepth),
        throwsA(
          const TypeMatcher<RangeError>(),
        ),
      );
    });

    test("calculates neighbor's base-32 hash", () {
      const hashBase32 = 'ww8p1r4t8';
      const direction = Direction.east;
      const expectedNeighborHashBase32 = 'ww8p1r4t9';

      final neighborHash = getNeighborBase32(hashBase32, direction);

      expect(neighborHash, expectedNeighborHashBase32);
    });

    test("calculates all neighbors' int hashes", () {
      final list = givenHash('110001111110101110001100001111');
      final hashInt = list[0];
      final bitDepth = list[1];
      const expectedNeighborsInt = {
        Direction.north: 838525722,
        Direction.northEast: 838525744,
        Direction.east: 838525733,
        Direction.southEast: 838525732,
        Direction.south: 838525710,
        Direction.southWest: 838525708,
        Direction.west: 838525709,
        Direction.northWest: 838525720,
      };

      final neighborHashesInt =
          getNeighborsInt(hashInt: hashInt, bitDepth: bitDepth);

      expect(neighborHashesInt, expectedNeighborsInt);
    });

    test(
        "throws error due to invalid bit depth while calculating neighbors' hashes",
        () {
      final hashInt = givenHash('1100011111101011100011000011111')[0];
      const tooSmallBitDepth = 0;
      const tooBigBitDepth = 53;

      expect(
        () => getNeighborsInt(hashInt: hashInt, bitDepth: tooSmallBitDepth),
        throwsA(
          const TypeMatcher<RangeError>(),
        ),
      );
      expect(
        () => getNeighborsInt(hashInt: hashInt, bitDepth: tooBigBitDepth),
        throwsA(
          const TypeMatcher<RangeError>(),
        ),
      );
    });

    test("calculates all neighbors' base-32 hashes", () {
      const hashBase32 = 'szpssgq';
      const expectedNeighborsBase32 = {
        Direction.north: 'szpssgw',
        Direction.northEast: 'szpssgx',
        Direction.east: 'szpssgr',
        Direction.southEast: 'szpssgp',
        Direction.south: 'szpssgn',
        Direction.southWest: 'szpssgj',
        Direction.west: 'szpssgm',
        Direction.northWest: 'szpssgt',
      };

      final neighborHashesBase32 = getNeighborsBase32(hashBase32);

      expect(neighborHashesBase32, expectedNeighborsBase32);
    });
  });
}
