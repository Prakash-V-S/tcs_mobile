class DamageModel {
  final String date;
  final String component;
  final String type;
  final String severity;

  DamageModel({
    required this.date,
    required this.component,
    required this.type,
    required this.severity,
  });

  factory DamageModel.fromJson(Map<String, dynamic> json) {
    return DamageModel(
      date: json['reported'] ?? '',
      component: json['component'] ?? '',
      type: json['type'] ?? '',
      severity: json['severity'] ?? '',
    );
  }
}
