class StopModel {
  final String id;
  final String name;
  final int order;
  final double? lat;
  final double? lng;

  StopModel({
    required this.id,
    required this.name,
    required this.order,
    this.lat,
    this.lng,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) {
    return StopModel(
      id: json['id'] as String,
      name: json['name'] as String,
      order: json['order'] as int,
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
    );
  }
}
