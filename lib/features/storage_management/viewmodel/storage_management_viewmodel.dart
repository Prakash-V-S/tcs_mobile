import 'package:flutter/material.dart';
import '../../container_search/model/container_recent_search_model.dart';
import '../../container_search/model/container_search_limit_model.dart';
import '../model/storage_model.dart';
import '../service/storage_management_service.dart';
import '../../../core/services/token_storage.dart';

class StorageManagementViewModel extends ChangeNotifier {
  final StorageManagementService _service;
  final String _userId;

  StorageManagementViewModel({
    required StorageManagementService service,
    required String userId,
  })  : _service = service,
        _userId = userId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<ContainerRecentSearchModel> _recentSearches = [];
  List<ContainerRecentSearchModel> get recentSearches => _recentSearches;

  List<StorageModel> _searchResults = [];
  List<StorageModel> get searchResults => _searchResults;

  ContainerSearchLimitModel? _searchLimit;
  ContainerSearchLimitModel? get searchLimit => _searchLimit;

  List<String> _lineOperators = [];
  List<String> get lineOperators => _lineOperators;

  String? _selectedLineOperator;
  String? get selectedLineOperator => _selectedLineOperator;

  final TextEditingController searchController = TextEditingController();

  bool _isSearchFocused = false;
  bool get isSearchFocused => _isSearchFocused;

  bool _hasSearched = false;
  bool get hasSearched => _hasSearched;

  void setSearchFocused(bool focused) {
    if (_isSearchFocused != focused) {
      _isSearchFocused = focused;
      notifyListeners();
    }
  }

  void resetSearch() {
    _hasSearched = false;
    _searchResults = [];
    searchController.clear();
    _isSearchFocused = false;
    if (_lineOperators.length > 1) {
      _selectedLineOperator = null;
    }
    notifyListeners();
  }

  void clearSearchResults() {
    _hasSearched = false;
    _searchResults = [];
    _isSearchFocused = true;
    notifyListeners();
  }

  void setSelectedLineOperator(String? operator) {
    _selectedLineOperator = operator;
    notifyListeners();
  }

  Future<void> fetchInitialData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final tokenStorage = TokenStorageImpl();
      final username = await tokenStorage.getUsername() ?? '';

      // 1. Fetch Limits
      _searchLimit = await _service.getSearchLimits();

      // 2. Fetch Line Operators
      _lineOperators = await _service.getLineOperators(username);
      if (_lineOperators.length == 1) {
        _selectedLineOperator = _lineOperators.first;
      }

      // 3. Fetch Recent Searches
      _recentSearches = await _service.getRecentSearches(_userId);
    } catch (e) {
      _errorMessage = 'Failed to load storage data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitSearch() async {
    final query = searchController.text.trim();
    if (query.isEmpty || _selectedLineOperator == null) return;

    _isLoading = true;
    _errorMessage = '';
    _hasSearched = true;
    _isSearchFocused = false;
    notifyListeners();

    try {
      final tokenStorage = TokenStorageImpl();
      final username = await tokenStorage.getUsername() ?? '';

      final response = await _service.searchContainers(
          query, _selectedLineOperator!, username);
      _searchResults = response.containers;

      _recentSearches = await _service.getRecentSearches(_userId);
    } catch (e) {
      _errorMessage = 'Failed to search storage: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
