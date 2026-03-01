import 'dart:convert';
import '../../../core/services/api_service.dart';
import '../model/tos_report_model.dart';
import '../model/report_type_model.dart';
import '../model/line_operator_model.dart';
import 'package:dio/dio.dart';

class PaginatedTosReportResponse {
  final List<TosReportModel> data;
  final int totalRecords;
  final int totalPages;
  final int currentPage;

  PaginatedTosReportResponse({
    required this.data,
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
  });

  factory PaginatedTosReportResponse.fromJson(Map<String, dynamic> json) {
    var rawDataList = json['data'] as List? ?? [];
    List<TosReportModel> parsedDataList = rawDataList
        .map((i) => TosReportModel.fromJson(i as Map<String, dynamic>))
        .toList();

    var paginationParams = json['pagination'] as Map<String, dynamic>? ?? {};

    return PaginatedTosReportResponse(
      data: parsedDataList,
      totalRecords: paginationParams['totalItems'] ?? 0,
      totalPages: paginationParams['totalPages'] ?? 1,
      currentPage: paginationParams['currentPage'] ?? 1,
    );
  }
}

class TosReportService {
  final ApiService _apiService;

  TosReportService(this._apiService);

  Future<PaginatedTosReportResponse> fetchReports({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'userId': userId,
        'page': page,
        'limit': limit,
        'filter': '{}',
        'sortField': 'creationTime',
        'sortDirection': 'desc',
      };

      final response = await _apiService.get(
        '/reports',
        queryParameters: queryParams,
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return PaginatedTosReportResponse.fromJson(responseData);
      } else {
        throw Exception(
          'Invalid response metadata handling expected an Object wrapper.',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network Communication Failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReportTypeModel>> fetchReportTypes() async {
    try {
      final response = await _apiService.get('/reports/report-list');
      var responseData = response.data;
      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }
      var rawDataList = responseData as List? ?? [];
      return rawDataList
          .map((i) => ReportTypeModel.fromJson(i as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch report types');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LineOperatorModel>> fetchLineOperators() async {
    try {
      final response = await _apiService.get('/line_opertors');
      var responseData = response.data;
      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      if (responseData is Map<String, dynamic> &&
          responseData['users'] != null) {
        var rawDataList = responseData['users'] as List;
        return rawDataList
            .map((i) => LineOperatorModel.fromJson(i as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch line operators');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> generateReport(Map<String, dynamic> payload) async {
    try {
      final response = await _apiService.post('/reports', data: payload);
      // Backend may return 200 without payload body if scheduled
      if (response.statusCode == 200 || response.statusCode == 201) return true;
      return false;
    } on DioException catch (e) {
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception(e.message ?? 'Failed to generate report');
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getLatestReport(String userId) async {
    try {
      final response = await _apiService.get('/latest-report?userId=$userId');
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['reportId'] != null) {
        return responseData['reportId'].toString();
      }
      throw Exception('Failed to resolve latest report ID.');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch latest report');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> previewReport(String reportId) async {
    try {
      final response = await _apiService.get('/report?reportId=$reportId');
      final responseData = response.data;
      if (responseData is String) {
        return jsonDecode(responseData) as Map<String, dynamic>;
      }
      return responseData as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception(e.message ?? 'Failed to fetch report preview');
    } catch (e) {
      rethrow;
    }
  }
}
