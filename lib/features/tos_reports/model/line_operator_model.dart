class LineOperatorModel {
  final String id;
  final String value;
  final String name;

  LineOperatorModel({
    required this.id,
    required this.value,
    required this.name,
  });

  factory LineOperatorModel.fromJson(Map<String, dynamic> json) {
    return LineOperatorModel(
      id: json['_id'] ?? '',
      value: json['value'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
