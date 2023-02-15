part of 'geohashing.dart';

int compare(int a, int b) {
  return a - b;
}

// export function assert<T, E extends Error>(
// expression: T,
// error: E | { new (): E },
// ): asserts expression {
// if (!expression) {
// throw typeof error === 'function' ? new error() : error;
// }
// }

void assertBase32HashLengthIsValid(int length) {
  const min = _base32HashMinLength;
  const max = _base32HashMaxLength;
  assert(
    length >= min && length <= max,
    RangeError('Number of chars must be between $min and $max'),
  );
}

void assertBitDepthIsValid(int bitDepth) {
  const min = _minBitDepth;
  const max = _maxBitDepth;
  assert(
    bitDepth >= min && bitDepth <= max,
    RangeError('Bit depth must be between $min and $max'),
  );
}

void assertLatitudeIsValid(double lat) {
  const min = -_latitudeMaxValue;
  const max = _latitudeMaxValue;
  assert(
    lat >= min && lat <= max,
    RangeError('Latitude must be between $min and $max'),
  );
}

void assertLongitudeIsValid(double lng) {
  const min = -_longitudeMaxValue;
  const max = _longitudeMaxValue;
  assert(
    lng >= min && lng <= max,
    RangeError('Longitude must be between $min and $max'),
  );
}

void assertLatLngIsValid(double lat, double lng) {
  assertLatitudeIsValid(lat);
  assertLongitudeIsValid(lng);
}

String intToBase32(int intValue, int length) {
  var hash = '';
  var prefix = intValue;

  for (var i = 0; i < length; i++) {
    final code = prefix % 32;
    hash = _base32Digits[code] + hash;
    prefix = (prefix / 32).floor();
  }

  return hash;
}

int base32ToInt(String base32Value) {
  var value = 0;
  final digits = base32Value.split('').reversed.toList();

  for (int i = 0; i < digits.length; i++) {
    final code = _base32DigitsMap[digits[i]];

    if (code == null) {
      throw RangeError('Unknown digit: ${digits[i]}');
    }

    value += code * 32 ^ i;
  }

  return value;
}
