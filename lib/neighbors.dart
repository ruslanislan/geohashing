part of 'geohashing.dart';

/// Calculates all neighbors' Base32 Geohashes.
/// @param hashBase32 Base32 string (Geohash version of Base32)
/// @returns A {@link Neighbors} with Base32 Geohashes starting from North
Iterable<Map<Direction, String>> getNeighborsBase32(String hashBase32) {
  final precision = hashBase32.length;
  final hashInt = base32ToInt(hashBase32);

  final neighborsInt = getNeighborsInt(
    hashInt: hashInt,
    bitDepth: precision * _base32BitsPerChar,
  );
  final neighborsBase32Entries = neighborsInt.map(
    (e) => {e.keys.first: intToBase32(e.values.first, precision)},
  );
  return neighborsBase32Entries;
}

/// Calculates all neighbors' integer Geohashes.
/// @param hashInt Geohash integer
/// @param bitDepth Defines precision of encoding.
/// The bigger the value, the smaller the encoded cell.
/// Can be either even or odd. Must be between 1 and 52.
/// @returns A {@link Neighbors} with Geohash integers starting from North.
Iterable<Map<Direction, int>> getNeighborsInt(
    {required int hashInt, int bitDepth = _maxBitDepth}) {
  assertBitDepthIsValid(bitDepth);

  final neighborsIntEntries = Direction.values.map(
    (direction) => {
      direction: getNeighborInt(
        hashInt: hashInt,
        direction: direction,
        bitDepth: bitDepth,
      ),
    },
  );
  return neighborsIntEntries;
}

/// Calculates neighbor's Geohash Base32 string.
/// @param hashBase32 Base32 string (Geohash version of Base32) whose neighbor should be found.
/// @param direction Specifies which neighbor should be found (e.g. northern, southwestern, etc.)
/// @returns Neighbor's Base32 Geohash.
getNeighborBase32(String hashBase32, Direction direction) {
  final precision = hashBase32.length;
  final hashInt = base32ToInt(hashBase32);
  final neighborHashInt = getNeighborInt(
    hashInt: hashInt,
    direction: direction,
    bitDepth: precision * _base32BitsPerChar,
  );
  return intToBase32(neighborHashInt, precision);
}

/// Calculates neighbor's Geohash integer.
/// @param hashInt Geohash integer whose neighbor should be found.
/// @param direction Specifies which neighbor should be found (e.g. northern, southwestern, etc.)
/// @param bitDepth Defines precision of encoding.
/// The bigger the value, the smaller the encoded cell.
/// Can be either even or odd. Must be between 1 and 52.
/// @returns Neighbor's Geohash integer.
int getNeighborInt({
  required int hashInt,
  required Direction direction,
  int bitDepth = _maxBitDepth,
}) {
  assertBitDepthIsValid(bitDepth);

  final list = mapDirectionToMultipliers(direction);
  return translateCell(
    hashInt: hashInt,
    translation: list,
    bitDepth: bitDepth,
  );
}

int translateCell({
  required int hashInt,
  required List<int> translation,
  required int bitDepth,
}) {
  final coordinates = decodeInt(
    hashInt: hashInt,
    bitDepth: bitDepth,
  );
  final lat = coordinates.lat;
  final lng = coordinates.lng;
  final error = coordinates.error!;
  return encodeInt(
    lat: lat + translation[0] * error.lat * 2,
    lng: lng + translation[1] * error.lng * 2,
    bitDepth: bitDepth,
  );
}

List<int> mapDirectionToMultipliers(Direction direction) {
  var latMultiplier = 0;
  var lngMultiplier = 0;

  switch (direction) {
    case Direction.west:
      lngMultiplier = -1;
      break;

    case Direction.northWest:
      latMultiplier = 1;
      lngMultiplier = -1;
      break;

    case Direction.north:
      latMultiplier = 1;
      break;

    case Direction.northEast:
      latMultiplier = 1;
      lngMultiplier = 1;
      break;

    case Direction.east:
      lngMultiplier = 1;
      break;

    case Direction.southEast:
      latMultiplier = -1;
      lngMultiplier = 1;
      break;

    case Direction.south:
      latMultiplier = -1;
      break;

    case Direction.southWest:
      latMultiplier = -1;
      lngMultiplier = -1;
      break;
  }

  return [latMultiplier, lngMultiplier];
}
