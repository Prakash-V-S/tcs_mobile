import '../../../core/services/api_service.dart';
import '../../container_search/model/container_search_limit_model.dart';
import '../../container_search/model/container_recent_search_model.dart';
import '../model/storage_search_response_model.dart';

class StorageManagementService {
  final ApiService _apiService;

  StorageManagementService({required ApiService apiService})
      : _apiService = apiService;

  Future<ContainerSearchLimitModel> getSearchLimits() async {
    try {
      final response = await _apiService.get('/limit');
      return ContainerSearchLimitModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getLineOperators(String username) async {
    try {
      final response = await _apiService.get('/line_opertors');
      final users = response.data['users'] as List? ?? [];
      return users
          .map((e) => e['value']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ContainerRecentSearchModel>> getRecentSearches(
      String userId) async {
    try {
      final response = await _apiService.get('/v1/dashboard/searches/$userId');

      if (response.data != null && response.data is List) {
        final list = response.data as List;
        final storageModule = list.firstWhere(
          (module) => module['module'] == 'STORAGE',
          orElse: () => null,
        );

        if (storageModule != null && storageModule['records'] is List) {
          return (storageModule['records'] as List)
              .map((e) => ContainerRecentSearchModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<StorageSearchResponseModel> searchContainers(
      String containers, String lineOperator, String username) async {
    try {
      final response = await _apiService.get(
        '/storage',
        queryParameters: {
          'container_number': containers,
          'lineOperator': lineOperator,
          'user': username,
        },
      );
      return StorageSearchResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
