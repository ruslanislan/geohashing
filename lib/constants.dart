part of 'geohashing.dart';

const _base32HashMinLength = 1.0;
const _base32HashMaxLength = 9;

const _minBitDepth = 1;
const _maxBitDepth = 52;

const _base32BitsPerChar = 5;

const _latitudeMaxValue = 90.0;
const _longitudeMaxValue = 180.0;

final _base32Digits = '0123456789bcdefghjkmnpqrstuvwxyz'.split('');
final _base32DigitsMap =
    _base32Digits.asMap().map((key, value) => MapEntry(value, key));
