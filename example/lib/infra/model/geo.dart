class Geo {
  final String lat;
  final String lng;

  Geo({required this.lat, required this.lng});

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng};
  }

  factory Geo.fromMap(Map<String, dynamic> map) {
    return Geo(lat: map['lat'] ?? '', lng: map['lng'] ?? '');
  }
}

