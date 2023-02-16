library geohashing;

import 'dart:math';

part 'constants.dart';

part 'bboxes.dart';

part 'helpers.dart';

part 'neighbors.dart';

part 'geo_json.dart';

part 'types.dart';

/// Encodes coordinates and returns a Geohash Base32 string.
/// @param lat Latitude
/// @param lng Longitude
/// @param length Number of characters in the output string.
/// The bigger the value, the smaller the encoded cell.
/// Must be between 1 and 9.
/// @returns Geohash Base32 string (Geohash version of Base32).
String encodeBase32({
  required double lat,
  required double lng,
  int length = _base32HashMaxLength,
}) {
  assertLatLngIsValid(lat, lng);
  assertBase32HashLengthIsValid(length);

  final hashInt =
      encodeInt(lat: lat, lng: lng, bitDepth: length * _base32BitsPerChar);
  return intToBase32(hashInt, length);
}

/// Decodes a Geohash Base32 string.
/// @param hashBase32 Base32 string (Geohash version of Base32)
/// @returns {@link Coordinates} containing latitude, longitude and  corresponding error values.

Coordinates decodeBase32(String hashBase32) {
  final hashInt = base32ToInt(hashBase32);
  return decodeInt(
      hashInt: hashInt, bitDepth: hashBase32.length * _base32BitsPerChar);
}

/// Encodes coordinates and returns a Geohash integer.
/// @param lat Latitude
/// @param lng Longitude
/// @param bitDepth Defines precision of encoding.
/// The bigger the value, the smaller the encoded cell.
/// Can be either even or odd. Must be between 1 and 52.
/// @returns Geohash integer
int encodeInt({
  required double lat,
  required double lng,
  int bitDepth = _maxBitDepth,
}) {
  assertLatLngIsValid(lat, lng);
  assertBitDepthIsValid(bitDepth);

  return encodeIntNoValidation(
    lat: lat,
    lng: lng,
    bitDepth: bitDepth,
  );
}

/// Decodes a Geohash integer and returns coordinates.
/// @param hashInt Geohash integer
/// @param bitDepth Defines precision of the Geohash.
/// {@link Coordinates} containing latitude, longitude and  corresponding error values.

Coordinates decodeInt({required int hashInt, int bitDepth = _maxBitDepth}) {
  assertBitDepthIsValid(bitDepth);

  return decodeIntNoValidation(hashInt, bitDepth);
}

int encodeIntNoValidation({
  required double lat,
  required double lng,
  required int bitDepth,
}) {
  var hashInt = 0;
  var latResidual = lat;
  var lngResidual = lng;

  var latError = _latitudeMaxValue;
  var lngError = _longitudeMaxValue;

  for (int i = bitDepth - 1; i >= 0; i--) {
    int bit;

    if ((bitDepth - i) % 2 == 1) {
      lngError /= 2;

      if (lngResidual >= 0) {
        bit = 1;
        lngResidual -= lngError;
      } else {
        bit = 0;
        lngResidual += lngError;
      }
    } else {
      latError /= 2;

      if (latResidual >= 0) {
        bit = 1;
        latResidual -= latError;
      } else {
        bit = 0;
        latResidual += latError;
      }
    }

    hashInt = hashInt * 2 + bit;
  }

  return hashInt;
}

Coordinates decodeIntNoValidation(int hashInt, int bitDepth) {
  var tail = hashInt;
  var latValue = 0.0;
  var latError = _latitudeMaxValue;
  var lngValue = 0.0;
  var lngError = _longitudeMaxValue;

  int exponent = pow(2, bitDepth).toInt();

  for (int i = bitDepth - 1; i >= 0; i--) {
    exponent ~/= 2;

    final bit = (tail / exponent).floor();

    if ((bitDepth - i) % 2 == 1) {
      lngError /= 2;

      if (bit == 1) {
        lngValue += lngError;
      } else {
        lngValue -= lngError;
      }
    } else {
      latError /= 2;

      if (bit == 1) {
        latValue += latError;
      } else {
        latValue -= latError;
      }
    }

    tail -= bit * exponent;
  }

  return Coordinates(latValue, lngValue, Coordinates(latError, lngError, null));
}
