import 'storage_model.dart';
import '../../container_search/model/container_recent_search_model.dart';

class StorageSearchResponseModel {
  final List<StorageModel> containers;
  final bool allowSubscribe;

  StorageSearchResponseModel({
    required this.containers,
    required this.allowSubscribe,
  });

  factory StorageSearchResponseModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['containerInfo']?['containers'] as List? ?? [];
    return StorageSearchResponseModel(
      containers: rawList.map((e) => StorageModel.fromJson(e)).toList(),
      allowSubscribe: json['allowSubscribe'] ?? false,
    );
  }
}
