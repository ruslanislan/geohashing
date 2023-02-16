part of 'geohashing.dart';

/// Calculates all Geohash Base32 values within the bounding box.
/// @param minLat Southwestern corner latitude
/// @param minLng Southwestern corner longitude
/// @param maxLat Northeastern corner latitude
/// @param maxLng Northeastern corner longitude
/// @param length Number of characters in the output string.
/// The bigger the value, the smaller the encoded cell.
/// Must be between 1 and 9.
/// @returns Array of Geohash Base32 strings.

Iterable<String> getHashesWithinBboxBase32({
  required double minLat,
  required double minLng,
  required double maxLat,
  required double maxLng,
  int length = _base32HashMaxLength,
}) {
  assertLatLngIsValid(minLat, minLng);
  assertLatLngIsValid(maxLat, maxLng);
  assertBase32HashLengthIsValid(length);

  final hashesInt = getHashesWithinBboxInt(
    minLat: minLat,
    minLng: minLng,
    maxLat: maxLat,
    maxLng: maxLng,
    bitDepth: length * _base32BitsPerChar,
  );
  return hashesInt.map((hashInt) => intToBase32(hashInt, length));
}

/// Calculates all Geohash integer values within the bounding box.
/// @param minLat Southwestern corner latitude
/// @param minLng Southwestern corner longitude
/// @param maxLat Northeastern corner latitude
/// @param maxLng Northeastern corner longitude
/// @param bitDepth Defines precision of encoding.
/// The bigger the value, the smaller the encoded cell.
/// Can be either even or odd. Must be between 1 and 52.
/// @returns Array of Geohash integers.

List<int> getHashesWithinBboxInt({
  required double minLat,
  required double minLng,
  required double maxLat,
  required double maxLng,
  int bitDepth = _maxBitDepth,
}) {
  assertLatLngIsValid(minLat, minLng);
  assertLatLngIsValid(maxLat, maxLng);
  assertBitDepthIsValid(bitDepth);

  final southWestHashInt = encodeIntNoValidation(
    lat: minLat,
    lng: minLng,
    bitDepth: bitDepth,
  );
  final northEastHashInt = encodeIntNoValidation(
    lat: maxLat,
    lng: maxLng,
    bitDepth: bitDepth,
  );

  final error = decodeInt(hashInt: southWestHashInt, bitDepth: bitDepth);
  final latStep = error.error!.lat * 2;
  final lngStep = error.error!.lng * 2;

  final fromBbox = decodeBboxIntNoValidation(
    southWestHashInt,
    bitDepth,
  );
  final toBbox = decodeBboxIntNoValidation(northEastHashInt, bitDepth);

  final List<int> hashesInt = [];

  for (var lat = fromBbox.minLat + error.error!.lat;
      lat < toBbox.maxLat;
      lat += latStep) {
    for (var lng = fromBbox.minLng + error.error!.lng;
        lng < toBbox.maxLng;
        lng += lngStep) {
      hashesInt.add(
        encodeIntNoValidation(
          lat: lat,
          lng: lng,
          bitDepth: bitDepth,
        ),
      );
    }
  }
  return hashesInt;
}

/// Finds a Geohash Base32 string that represents the smallest cell which the given bbox fits into.
/// @param minLat Southwestern corner latitude
/// @param minLng Southwestern corner longitude
/// @param maxLat Northeastern corner latitude
/// @param maxLng Northeastern corner longitude
/// @returns a Geohash Base32 string or `null` if the bbox cannot be represented by a Geohash
/// as it occupies both eastern and western hemispheres
String? encodeBboxBase32({
  required double minLat,
  required double minLng,
  required double maxLat,
  required double maxLng,
}) {
  final hashIntObject = encodeBboxInt(
    minLat: minLat,
    minLng: minLng,
    maxLat: maxLat,
    maxLng: maxLng,
  );
  if (hashIntObject == null) {
    return null;
  }

  final hashInt = hashIntObject.hashInt;
  final bitDepth = hashIntObject.bitDepth;
  final shiftOrder = bitDepth % _base32BitsPerChar;
  final shiftedHashInt = (hashInt / pow(2, shiftOrder)).floor();
  final length = (bitDepth / _base32BitsPerChar).floor();

  return intToBase32(shiftedHashInt, length);
}

/// Calculates bounding box coordinates of the encoded cell.
/// @param hashBase32 Base32 string (Geohash version of Base32)
/// @returns A {@link Bbox} with coordinates: `minLat`, `minLng`, `maxLat`, `maxLng`.
Bbox decodeBboxBase32(String hashBase32) {
  final hashInt = base32ToInt(hashBase32);
  return decodeBboxInt(
    hashInt: hashInt,
    bitDepth: hashBase32.length * _base32BitsPerChar,
  );
}

/// Finds a Geohash integer that represents the smallest cell which the given bbox fits into.
/// @param minLat Southwestern corner latitude
/// @param minLng Southwestern corner longitude
/// @param maxLat Northeastern corner latitude
/// @param maxLng Northeastern corner longitude
/// @returns a {@link HashInt} containing a Geohash integer and bit depth
/// or `null` if the bbox cannot be represented by a Geohash as it occupies
/// both eastern and western hemispheres

HashInt? encodeBboxInt({
  required double minLat,
  required double minLng,
  required double maxLat,
  required double maxLng,
}) {
  assertLatLngIsValid(minLat, minLng);
  assertLatLngIsValid(maxLat, maxLng);

  final lat = minLat + (maxLat - minLat) / 2;
  final lng = minLng + (maxLng - minLng) / 2;

  var hashInt = encodeIntNoValidation(
    lat: lat,
    lng: lng,
    bitDepth: _maxBitDepth,
  );

  for (int i = _maxBitDepth; i > 0; i--) {
    final bbox = decodeBboxIntNoValidation(hashInt, i);

    if (bbox.minLat <= minLat &&
        bbox.minLng <= minLng &&
        bbox.maxLat >= maxLat &&
        bbox.maxLng >= maxLng) {
      return HashInt(hashInt, i);
    }

    hashInt = (hashInt / 2).floor();
  }

  return null;
}

/// Calculates bounding box coordinates of the encoded cell.
/// @param hashInt Geohash integer
/// @param bitDepth Defines precision of encoding.
/// The bigger the value, the smaller the encoded cell.
/// Can be either even or odd. Must be between 1 and 52.
/// @returns A {@link Bbox} with coordinates: `minLat`, `minLng`, `maxLat`, `maxLng`.
Bbox decodeBboxInt({required int hashInt, int bitDepth = _maxBitDepth}) {
  assertBitDepthIsValid(bitDepth);

  return decodeBboxIntNoValidation(hashInt, bitDepth);
}

Bbox decodeBboxIntNoValidation(int hashInt, int bitDepth) {
  final coordinates = decodeIntNoValidation(hashInt, bitDepth);
  return Bbox(
    minLat: coordinates.lat - coordinates.error!.lat,
    minLng: coordinates.lng - coordinates.error!.lng,
    maxLat: coordinates.lat + coordinates.error!.lat,
    maxLng: coordinates.lng + coordinates.error!.lng,
  );
}
