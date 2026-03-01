import 'package:flutter/material.dart';
import '../data/berth_schedule_service.dart';
import '../model/berth_schedule_model.dart';
import 'dart:async';

class BerthScheduleViewModel extends ChangeNotifier {
  final BerthScheduleService _berthScheduleService;

  BerthScheduleViewModel(this._berthScheduleService);

  List<BerthScheduleModel> _schedules = [];
  List<BerthScheduleModel> get schedules => _schedules;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentPage = 0;
  int _totalPages = 1;
  final int _limit = 15;
  // Based on the example, page 0 means there's another page if page < (totalPages - 1)
  bool get hasMore => _currentPage < (_totalPages - 1);

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _selectedPhase;
  String? get selectedPhase => _selectedPhase;

  Timer? _debounceTimer;

  // Initialize and load first page
  Future<void> initLoad() async {
    _currentPage = 0;
    _schedules.clear();
    _errorMessage = null;
    await _fetchData(isLoadMore: false);
  }

  // Load next page
  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _isLoading) return;

    _currentPage++;
    await _fetchData(isLoadMore: true);
  }

  // Set Search text and retrigger fetching dynamically
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;

    _searchQuery = query;
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      initLoad();
    });
  }

  // Apply Phase Filters
  void setPhaseFilter(String? phase) {
    if (_selectedPhase == phase) return;
    _selectedPhase = phase;
    initLoad();
  }

  Future<void> _fetchData({required bool isLoadMore}) async {
    if (isLoadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
    }
    notifyListeners();

    try {
      final response = await _berthScheduleService.fetchBerthSchedule(
        page: _currentPage,
        limit: _limit,
        searchQuery: _searchQuery,
        phaseFilter: _selectedPhase,
      );

      _totalPages = response.totalPages;

      if (isLoadMore) {
        _schedules.addAll(response.data);
      } else {
        _schedules = response.data;
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      // If pagination fails, rollback the page number
      if (isLoadMore) _currentPage--;
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
