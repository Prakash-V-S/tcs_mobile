import 'package:flutter/material.dart';
import '../../../core/services/token_storage.dart';
import '../data/tos_report_service.dart';
import '../model/tos_report_model.dart';
import 'dart:async';

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
}
