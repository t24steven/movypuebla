class RouteModel {
  final String id;
  final String name;
  final String code;
  final double baseFareMin;
  final double baseFareMax;
  final double discountDisabled;
  final double discountStudentMin;
  final double discountStudentMax;
  final double discountSeniorMin;
  final double discountSeniorMax;
  final double? nightFare;
  final bool supportsNightService;

  // Campos de búsqueda inteligente (opcionales, solo cuando se busca con coordenadas)
  final String? nearestOriginStop;
  final double? nearestOriginDistKm;
  final String? nearestDestStop;
  final double? nearestDestDistKm;

  RouteModel({
    required this.id,
    required this.name,
    required this.code,
    required this.baseFareMin,
    required this.baseFareMax,
    required this.discountDisabled,
    required this.discountStudentMin,
    required this.discountStudentMax,
    required this.discountSeniorMin,
    required this.discountSeniorMax,
    this.nightFare,
    required this.supportsNightService,
    this.nearestOriginStop,
    this.nearestOriginDistKm,
    this.nearestDestStop,
    this.nearestDestDistKm,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      baseFareMin: (json['baseFareMin'] as num).toDouble(),
      baseFareMax: (json['baseFareMax'] as num).toDouble(),
      discountDisabled: (json['discountDisabled'] as num).toDouble(),
      discountStudentMin: (json['discountStudentMin'] as num).toDouble(),
      discountStudentMax: (json['discountStudentMax'] as num).toDouble(),
      discountSeniorMin: (json['discountSeniorMin'] as num).toDouble(),
      discountSeniorMax: (json['discountSeniorMax'] as num).toDouble(),
      nightFare: json['nightFare'] != null
          ? (json['nightFare'] as num).toDouble()
          : null,
      supportsNightService: json['supportsNightService'] as bool? ?? false,
      nearestOriginStop: json['nearestOriginStop'] as String?,
      nearestOriginDistKm: json['nearestOriginDistKm'] != null
          ? (json['nearestOriginDistKm'] as num).toDouble()
          : null,
      nearestDestStop: json['nearestDestStop'] as String?,
      nearestDestDistKm: json['nearestDestDistKm'] != null
          ? (json['nearestDestDistKm'] as num).toDouble()
          : null,
    );
  }
}
