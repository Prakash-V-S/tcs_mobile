import 'package:flutter/material.dart';
import '../../../core/services/token_storage.dart';
import '../data/tos_report_service.dart';
import '../model/tos_report_model.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class TosReportsViewModel extends ChangeNotifier {
  final TosReportService _tosReportService;
  final TokenStorage _tokenStorage;

  TosReportsViewModel(this._tosReportService, this._tokenStorage);

  List<TosReportModel> _reports = [];
  List<TosReportModel> get reports => _reports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _profileLogoBase64;
  String? get profileLogoBase64 => _profileLogoBase64;

  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 10;
  bool get hasMore => _currentPage < _totalPages;

  // Initialize and load first page
  Future<void> initLoad() async {
    _currentPage = 1;
    _reports.clear();
    _errorMessage = null;
    await _fetchData(isLoadMore: false);
  }

  // Load next page
  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _isLoading) return;

    _currentPage++;
    await _fetchData(isLoadMore: true);
  }

  Future<void> _fetchData({required bool isLoadMore}) async {
    if (isLoadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
    }
    notifyListeners();

    try {
      String? loggedInUserId = await _tokenStorage.getUserId();

      if (loggedInUserId == null || loggedInUserId.isEmpty) {
        throw Exception("You must be logged in to view reports.");
      }

      // Fetch Profile Logo asynchronously for UI Header Layer
      _profileLogoBase64 = await _tokenStorage.getProfileLogo();

      final response = await _tosReportService.fetchReports(
        userId: loggedInUserId,
        page: _currentPage,
        limit: _limit,
      );

      _totalPages = response.totalPages;

      if (isLoadMore) {
        _reports.addAll(response.data);
      } else {
        _reports = response.data;
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (isLoadMore) _currentPage--;
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Handle native file downloading
  Future<void> downloadReport(String reportId, String reportLabel) async {
    try {
      final responseMap = await _tosReportService.previewReport(reportId);
      final String? base64String = responseMap['file'];

      if (base64String == null || base64String.isEmpty) {
        throw Exception("Report file is empty or missing from backend.");
      }

      // 1. Clean Base64 format if backend dynamically injects MIME type prefixes
      final pureBase64 = base64String.replaceFirst(RegExp(r'data:[^;]+;base64,'), '');
      final fileBytes = base64Decode(pureBase64);

      // 2. Resolve native physical write directory
      final directory = await getApplicationDocumentsDirectory();
      
      // Assume .xlsx given the 0M8R4KGx (Office Open XML header) context.
      // E.g. "ETAT_DU_STOCK_697787d.xlsx"
      final sanitizedLabel = reportLabel.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final extension = '.xlsx';
      final file = File('${directory.path}/${sanitizedLabel}_${reportId.substring(0, 6)}$extension');

      // 3. Write data to OS limits
      await file.writeAsBytes(fileBytes);

      // 4. Trigger system handler to open the newly written document natively
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
         throw Exception("Could not open file natively: ${result.message}");
      }
    } catch (e) {
      // Let the view handle the error rendering
      rethrow;
    }
  }

  // Handle report deletion natively
  Future<void> deleteReport(String reportId) async {
    try {
      final username = await _tokenStorage.getUsername();
      if (username == null || username.isEmpty) {
        throw Exception("You must be logged in to delete reports.");
      }

      final success = await _tosReportService.deleteReport(reportId, username);
      if (success) {
         // Locally cascade report drop out of list immediately without full network refresh
        _reports.removeWhere((report) => report.id == reportId);
        notifyListeners();
      } else {
         throw Exception("Failed to delete report. Please try again later.");
      }
    } catch (e) {
      // Let the view handle the error rendering
      rethrow;
    }
  }
}
