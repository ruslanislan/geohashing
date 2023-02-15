part of 'geohashing.dart';

/// Converts an array of Geohash Base32 strings
/// to GeoJSON Feature with MultiPolygon geometry.
/// @param hashBase32Array Array of Geohash Base32 strings
/// @returns GeoJSON Feature object with MultiPolygon geometry
GeoJsonFeature<GeoJsonGeometryMultiPolygon> hashBase32ArrayToMultiPolygon(
    List<String> hashBase32Array) {
  final hashIntArray = hashBase32Array.map((hashBase32) => {
        base32ToInt(hashBase32): hashBase32.length * _base32BitsPerChar,
      });
  return hashIntArrayToMultiPolygon(hashIntArray);
}

/// Converts an array of Geohash integer/bit depth pairs
/// to GeoJSON Feature with MultiPolygon geometry.
/// MultiPolygon contains all rectangle areas encoded with provided geohashes.
/// @param hashIntArray Array of Geohash integer/bit depth pairs
/// @returns GeoJSON Feature object with MultiPolygon geometry
GeoJsonFeature<GeoJsonGeometryMultiPolygon> hashIntArrayToMultiPolygon(
    Iterable<Map<int, int>> hashIntArray) {
  final coordinates = hashIntArray.map(
    (e) {
      final hashInt = e.keys.first;
      final bitDepth = e.keys.first;

      final bbox = decodeBboxInt(hashInt: hashInt, bitDepth: bitDepth);
      return [
        [
          [bbox.minLng, bbox.minLat],
          [bbox.maxLng, bbox.minLat],
          [bbox.maxLng, bbox.maxLat],
          [bbox.minLng, bbox.maxLat],
          [bbox.minLng, bbox.minLat],
        ],
      ];
    },
  );

  return GeoJsonFeature(
    type: 'Feature',
    geometry: GeoJsonGeometryMultiPolygon(
      'MultiPolygon',
      coordinates,
    ),
  );
}

/// Coverts a Geohash integer to a GeoJSON object,
/// where the encoded cell is represented by a rectangular
/// [Polygon]{@link https://www.rfc-editor.org/rfc/rfc7946#section-3.1.6}.
/// @see hashIntToPolygon
/// @param hashBase32 Base32 string (Geohash version of Base32)
/// @returns a {@link GeoJsonFeature} object.
GeoJsonFeature<GeoJsonGeometryPolygon> hashBase32ToPolygon(String hashBase32) {
  final hashInt = base32ToInt(hashBase32);
  return hashIntToPolygon(
    hashInt: hashInt,
    bitDepth: hashBase32.length * _base32BitsPerChar,
  );
}

/// Coverts a Geohash integer to a GeoJSON object,
/// where the encoded cell is represented by a rectangular
/// [Polygon]{@link https://www.rfc-editor.org/rfc/rfc7946#section-3.1.6}.
/// @example GeoJSON object
/// {
///   type: 'Feature',
///   bbox: [-4.3505859375, 48.6474609375, -4.306640625, 48.69140625],
///   geometry: {
///     type: 'Polygon',
///     coordinates: [
///       [
///         [-4.3505859375, 48.6474609375],
///         [-4.306640625, 48.6474609375],
///         [-4.306640625, 48.69140625],
///         [-4.3505859375, 48.69140625],
///         [-4.3505859375, 48.6474609375]
///       ]
///     ]
///   },
///   properties: {
///     lat: 48.66943359375,
///     lng: -4.32861328125,
///     error: {
///       lat: 0.02197265625,
///       lng: 0.02197265625
///     }
///   }
/// }
/// @param hashInt Geohash integer
/// @param bitDepth Defines precision of the Geohash.
/// @returns a {@link GeoJsonFeature} object.
GeoJsonFeature<GeoJsonGeometryPolygon> hashIntToPolygon({
  required int hashInt,
  int bitDepth = _maxBitDepth,
}) {
  final coordinates = decodeInt(hashInt: hashInt, bitDepth: bitDepth);
  final bbox = decodeBboxInt(
    hashInt: hashInt,
    bitDepth: bitDepth,
  );

  return GeoJsonFeature(
    type: 'Feature',
    bbox: bbox,
    geometry: GeoJsonGeometryPolygon(
      'Polygon',
      [
        [
          [bbox.minLng, bbox.minLat],
          [bbox.maxLng, bbox.minLat],
          [bbox.maxLng, bbox.maxLat],
          [bbox.minLng, bbox.maxLat],
          [bbox.minLng, bbox.minLat],
        ],
      ],
    ),
    properties: coordinates,
  );
}
