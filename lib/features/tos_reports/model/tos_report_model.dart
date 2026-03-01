class TosReportModel {
  final String id;
  final String creationTime;
  final String reportName;
  final String label;

  TosReportModel({
    required this.id,
    required this.creationTime,
    required this.reportName,
    required this.label,
  });

  factory TosReportModel.fromJson(Map<String, dynamic> json) {
    return TosReportModel(
      id: json['_id']?.toString() ?? '',
      creationTime: json['creationTime']?.toString() ?? '',
      reportName: json['reportName']?.toString() ?? 'Unknown',
      label: json['label']?.toString() ?? 'Unnamed Report',
    );
  }
}
