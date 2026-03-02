class ContainerRecentSearchQueryModel {
  final String containerNumber;
  final String? inputType;

  ContainerRecentSearchQueryModel({
    required this.containerNumber,
    this.inputType,
  });

  factory ContainerRecentSearchQueryModel.fromJson(Map<String, dynamic> json) {
    return ContainerRecentSearchQueryModel(
      containerNumber: json['container_number'] ?? '',
      inputType: json['inputType'],
    );
  }
}

class ContainerRecentSearchModel {
  final String id;
  final ContainerRecentSearchQueryModel query;
  final String filterType;
  final String module;

  ContainerRecentSearchModel({
    required this.id,
    required this.query,
    required this.filterType,
    required this.module,
  });

  factory ContainerRecentSearchModel.fromJson(Map<String, dynamic> json) {
    return ContainerRecentSearchModel(
      id: json['_id'] ?? '',
      query: json['query'] != null
          ? ContainerRecentSearchQueryModel.fromJson(json['query'])
          : ContainerRecentSearchQueryModel(containerNumber: ''),
      filterType: json['filterType'] ?? '',
      module: json['module'] ?? '',
    );
  }
}
