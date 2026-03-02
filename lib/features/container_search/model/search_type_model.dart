class SearchParameterModel {
  final String label;
  final String key;
  final String value;

  SearchParameterModel({
    required this.label,
    required this.key,
    required this.value,
  });

  factory SearchParameterModel.fromJson(Map<String, dynamic> json) {
    return SearchParameterModel(
      label: json['label'] ?? '',
      key: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

class SearchTypeResponseModel {
  final String filterName;
  final List<SearchParameterModel> searchParameters;

  SearchTypeResponseModel({
    required this.filterName,
    required this.searchParameters,
  });

  factory SearchTypeResponseModel.fromJson(Map<String, dynamic> json) {
    final typesData = json['searchTypes'] ?? json;
    return SearchTypeResponseModel(
      filterName: typesData['filterName'] ?? '',
      searchParameters: (typesData['searchParameters'] as List?)
              ?.map((item) => SearchParameterModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}
