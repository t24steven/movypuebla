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
    );
  }
}
