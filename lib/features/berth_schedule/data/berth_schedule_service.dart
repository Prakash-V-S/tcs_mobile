import '../../../core/services/api_service.dart';
import '../model/berth_schedule_model.dart';
import 'package:dio/dio.dart';

class PaginatedBerthScheduleResponse {
  final List<BerthScheduleModel> data;
  final int totalRecords;
  final int totalPages;
  final int currentPage;

  PaginatedBerthScheduleResponse({
    required this.data,
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
  });

  factory PaginatedBerthScheduleResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List? ?? [];
    List<BerthScheduleModel> dataList = list.map((i) => BerthScheduleModel.fromJson(i as Map<String, dynamic>)).toList();

    return PaginatedBerthScheduleResponse(
      data: dataList,
      totalRecords: json['totalRecords'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
    );
  }
}

class BerthScheduleService {
  final ApiService _apiService;

  BerthScheduleService(this._apiService);

  Future<PaginatedBerthScheduleResponse> fetchBerthSchedule({
    int page = 0,
    int limit = 15,
    String? searchQuery,
    String? phaseFilter,
  }) async {
    try {
      final Map<String, dynamic> filterData = {};

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
         // Perform regex search on vessel_name or visit for versatile UI testing assuming mongo backend regex
        filterData['\$or'] = [
          {'vessel_name': {'\$regex': searchQuery, '\$options': 'i'}},
          {'visit': {'\$regex': searchQuery, '\$options': 'i'}}
        ];
      }

      if (phaseFilter != null && phaseFilter.isNotEmpty) {
        // According to the layout, filter targets "phase". E.g: "Inbound"
        filterData['phase'] = phaseFilter;
      }

      final payload = {
        "schema": "vessel_schedule",
        "filter": filterData,
        "page": page,
        "limit": limit,
        "sortBy": "eta",
        "sortOrder": "asc"
      };

      final response = await _apiService.post('/v1/search', data: payload);
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return PaginatedBerthScheduleResponse.fromJson(responseData);
      } else {
        throw Exception('Invalid response format expected object payload.');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network Error');
    } catch (e) {
      rethrow;
    }
  }
}
