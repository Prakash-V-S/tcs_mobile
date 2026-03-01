class ReportTypeModel {
  final String value;
  final String label;
  final String type;
  final bool withFullName;

  ReportTypeModel({
    required this.value,
    required this.label,
    required this.type,
    required this.withFullName,
  });

  factory ReportTypeModel.fromJson(Map<String, dynamic> json) {
    return ReportTypeModel(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? '',
      withFullName: json['withFullName'] ?? false,
    );
  }
}
