import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';

class InvoiceService {
  final ApiService _apiService;

  InvoiceService(this._apiService);

  Future<List<dynamic>> getInvoiceTypes(String companyType) async {
    try {
      final payload = {
        "schema": "invoice_types",
        "filter": {"companyAccess": companyType},
        "page": 0,
        "limit": 15,
        "sortBy": "",
        "sortOrder": "desc",
      };

      final response = await _apiService.post('/v1/search', data: payload);
      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map && data.containsKey('data')) {
        return List<dynamic>.from(data['data']);
      } else if (data is List) {
        return List<dynamic>.from(data);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getInvoices({
    required int pageIndex,
    required int pageSize,
    String? companyName,
  }) async {
    try {
      final Map<String, dynamic> filter = {"deletedBy": null};
      if (companyName != null &&
          companyName.isNotEmpty &&
          companyName.toLowerCase() != 'terminal admin') {
        filter['createdCompany'] = companyName;
      }

      final payload = {
        "schema": "invoices",
        "filter": filter,
        "page": pageIndex,
        "limit": pageSize,
        "sortBy": "eta",
        "sortOrder": "desc",
      };

      final response = await _apiService.post('/v1/search', data: payload);
      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map && data.containsKey('data')) {
        return List<dynamic>.from(data['data']);
      } else if (data is List) {
        return List<dynamic>.from(data);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getColumnProperties(String module) async {
    try {
      final response = await _apiService.get(
        '/v1/columns',
        queryParameters: {'module': module},
      );
      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      return data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }

  Future<List<int>> downloadInvoice(String draftNumber) async {
    try {
      final response = await _apiService.get(
        '/invoice/download',
        queryParameters: {'draftNumber': draftNumber},
        options: Options(responseType: ResponseType.bytes),
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
