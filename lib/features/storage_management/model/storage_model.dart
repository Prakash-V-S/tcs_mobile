class StorageModel {
  final String containerNumber;
  final String lineOperator;
  final String category;
  final String typeIso;
  final String vState;
  final String tState;
  final Map<String, dynamic> storageDetails;

  StorageModel({
    required this.containerNumber,
    required this.lineOperator,
    required this.category,
    required this.typeIso,
    required this.vState,
    required this.tState,
    this.storageDetails = const {},
  });

  factory StorageModel.fromJson(Map<String, dynamic> json) {
    // The API response places variables inside 'storageDetails' array objects
    final detailsMap = json['storageDetails'] as Map<String, dynamic>? ?? {};
    
    String getNestedValue(String key) {
      for (var group in detailsMap.values) {
        if (group is Map<String, dynamic> && group.containsKey(key)) {
           return group[key]?.toString() ?? 'N/A';
        }
      }
      return 'N/A';
    }

    return StorageModel(
      containerNumber: json['container']?.toString() ?? '',
      lineOperator: getNestedValue('line_op'),
      category: json['category']?.toString() ?? 'N/A',
      typeIso: getNestedValue('type_iso'),
      vState: getNestedValue('v_state'),
      tState: getNestedValue('t_state'),
      storageDetails: detailsMap,
    );
  }
}
