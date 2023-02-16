part of 'geohashing.dart';

class Coordinates {
  final double lat;
  final double lng;
  final Coordinates? error;

  Coordinates(this.lat, this.lng, this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coordinates &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lng == other.lng &&
          error == other.error;

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode ^ error.hashCode;

  @override
  String toString() {
    return 'Coordinates{lat: $lat, lng: $lng, error: $error}';
  }
}

class HashInt {
  final int hashInt;
  final int bitDepth;

  HashInt(this.hashInt, this.bitDepth);
}

class Bbox {
  final double minLat;
  final double minLng;
  final double maxLat;
  final double maxLng;

  Bbox({
    required this.minLat,
    required this.minLng,
    required this.maxLat,
    required this.maxLng,
  });

  @override
  String toString() {
    return 'Bbox{minLat: $minLat, minLng: $minLng, maxLat: $maxLat, maxLng: $maxLng}';
  }
}

enum Direction {
  north,
  northEast,
  east,
  southEast,
  south,
  southWest,
  west,
  northWest,
}

abstract class IGeoJsonGeometry {}

class GeoJsonGeometryPolygon implements IGeoJsonGeometry {
  final String type;
  final Iterable<List<List<double>>> coordinates;

  GeoJsonGeometryPolygon(this.type, this.coordinates);
}

class GeoJsonGeometryMultiPolygon implements IGeoJsonGeometry {
  final String type;
  final Iterable<List<List<List<double>>>> coordinates;

  GeoJsonGeometryMultiPolygon(this.type, this.coordinates);
}

class GeoJsonFeature<T extends IGeoJsonGeometry> {
  final String type;
  final T geometry;
  final Coordinates? properties;
  final Bbox? bbox;

  GeoJsonFeature({
    required this.type,
    required this.geometry,
    this.properties,
    this.bbox,
  });
}