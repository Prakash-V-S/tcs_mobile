import 'package:flutter/material.dart';
import '../model/container_recent_search_model.dart';
import '../model/search_type_model.dart';
import '../model/container_search_limit_model.dart';
import '../model/container_model.dart';
import '../model/damage_model.dart';
import '../model/subscription_event_model.dart';
import '../service/container_search_service.dart';
import '../../../core/services/token_storage.dart';

class ContainerSearchViewModel extends ChangeNotifier {
  final ContainerSearchService _service;
  final String _userId;

  ContainerSearchViewModel({
    required ContainerSearchService service,
    required String userId,
  })  : _service = service,
        _userId = userId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<ContainerRecentSearchModel> _recentSearches = [];
  List<ContainerRecentSearchModel> get recentSearches => _recentSearches;

  List<ContainerModel> _searchResults = [];
  List<ContainerModel> get searchResults => _searchResults;

  List<DamageModel> _currentDamages = [];
  List<DamageModel> get currentDamages => _currentDamages;

  bool _isLoadingDamages = false;
  bool get isLoadingDamages => _isLoadingDamages;

  List<SubscriptionEventModel> _subscriptionEvents = [];
  List<SubscriptionEventModel> get subscriptionEvents => _subscriptionEvents;

  List<SubscriptionEventModel> _subscriptionHoldsPerms = [];
  List<SubscriptionEventModel> get subscriptionHoldsPerms => _subscriptionHoldsPerms;

  bool _isLoadingSubscriptions = false;
  bool get isLoadingSubscriptions => _isLoadingSubscriptions;

  List<SearchParameterModel> _searchTypes = [];
  List<SearchParameterModel> get searchTypes => _searchTypes;

  SearchParameterModel? _selectedSearchType;
  SearchParameterModel? get selectedSearchType => _selectedSearchType;

  ContainerSearchLimitModel? _searchLimit;
  ContainerSearchLimitModel? get searchLimit => _searchLimit;

  final TextEditingController searchController = TextEditingController();

  bool _isSearchFocused = false;
  bool get isSearchFocused => _isSearchFocused;

  bool _hasSearched = false;
  bool get hasSearched => _hasSearched;

  bool _allowSubscribe = false;
  bool get allowSubscribe => _allowSubscribe;

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
    notifyListeners();
  }

  void clearSearchResults() {
    _hasSearched = false;
    _searchResults = [];
    _isSearchFocused = true; // Go back to focused state to edit query
    notifyListeners();
  }

  void setSelectedSearchType(SearchParameterModel type, {bool clearText = true}) {
    _selectedSearchType = type;
    if (clearText) {
      searchController.clear();
    }
    notifyListeners();
  }

  Future<void> fetchInitialData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // 1. Fetch Limits
      _searchLimit = await _service.getSearchLimits();

      // 2. Fetch Types
      final typeResponse = await _service.getSearchTypes();
      _searchTypes = typeResponse.searchParameters;
      if (_searchTypes.isNotEmpty) {
        _selectedSearchType = _searchTypes.first; // Default to first (e.g., Container no)
      }

      // 3. Fetch Recent Searches
      _recentSearches = await _service.getRecentSearches(_userId);

    } catch (e) {
      _errorMessage = 'Failed to load container search data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getSearchHintText() {
    if (_selectedSearchType?.key == 'unit_nbr') {
      return 'Container number must be 11 characters';
    }
    return '';
  }

  Future<void> submitSearch() async {
    final query = searchController.text.trim();
    if (query.isEmpty || _selectedSearchType == null) return;

    _isLoading = true;
    _errorMessage = '';
    _hasSearched = true;
    _isSearchFocused = false;
    notifyListeners();

    try {
      final response =
          await _service.searchContainers(query, _selectedSearchType!.value);
      _searchResults = response.containers;
      _allowSubscribe = response.allowSubscribe;
      
      // Fetch updated history after search
      _recentSearches = await _service.getRecentSearches(_userId);
    } catch (e) {
      _errorMessage = 'Failed to search containers: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDamages(String containerNumber) async {
    _isLoadingDamages = true;
    _currentDamages = [];
    notifyListeners();

    try {
      final tokenStorage = TokenStorageImpl();
      final username = await tokenStorage.getUsername() ?? '';
      final customerId = ''; // Not stored locally currently

      _currentDamages = await _service.getContainerDamages(
          containerNumber, username, customerId);
    } catch (e) {
      _currentDamages = [];
    } finally {
      _isLoadingDamages = false;
      notifyListeners();
    }
  }

  void clearDamages() {
    _currentDamages = [];
    _isLoadingDamages = false;
    notifyListeners();
  }

  Future<void> fetchSubscriptionEvents(ContainerModel container) async {
    _isLoadingSubscriptions = true;
    _subscriptionEvents = [];
    _subscriptionHoldsPerms = [];
    notifyListeners();

    try {
      // Fetch available events
      final eventsResp = await _service.getEvents(container);
      
      // Fetch user's currently subscribed events
      final subscribedEventKeys = await _service.getSubscribedEvents(container.unitNbr, _userId);

      // Process events to mark already subscribed ones as checked and disabled
      _subscriptionEvents = eventsResp['events']!.map((e) {
        if (subscribedEventKeys.contains(e.value)) {
          return e.copyWith(isChecked: true, isDisabled: true);
        }
        return e;
      }).toList();

      _subscriptionHoldsPerms = eventsResp['holdsAndPerms']!.map((e) {
        if (subscribedEventKeys.contains(e.value)) {
          return e.copyWith(isChecked: true, isDisabled: true);
        }
        return e;
      }).toList();

    } catch (e) {
       _subscriptionEvents = [];
       _subscriptionHoldsPerms = [];
    } finally {
      _isLoadingSubscriptions = false;
      notifyListeners();
    }
  }

  void toggleSubscription(SubscriptionEventModel event, bool isHoldsPerm) {
    if (event.isDisabled) return;

    if (isHoldsPerm) {
      final index = _subscriptionHoldsPerms.indexWhere((e) => e.value == event.value);
      if (index != -1) {
        _subscriptionHoldsPerms[index] = event.copyWith(isChecked: !event.isChecked);
        notifyListeners();
      }
    } else {
      final index = _subscriptionEvents.indexWhere((e) => e.value == event.value);
      if (index != -1) {
        _subscriptionEvents[index] = event.copyWith(isChecked: !event.isChecked);
        notifyListeners();
      }
    }
  }

  Future<bool> submitSubscriptions(ContainerModel container) async {
    _isLoading = true;
    notifyListeners();

    try {
      final tokenStorage = TokenStorageImpl();
      final username = await tokenStorage.getUsername() ?? '';

      final commonData = {
        'unit_nbr': container.unitNbr,
        'created_by': username,
        'category': container.category,
        'o_b_actual_visit': container.obActualVisit,
        'i_b_actual_visit': container.ibActualVisit,
        'line_op': container.operator,
        'user_id': _userId,
      };

      final List<Map<String, dynamic>> payload = [];

      // Only subscribe to newly checked ones (not the already disabled ones)
      for (var e in _subscriptionEvents) {
        if (e.isChecked && !e.isDisabled) {
          payload.add({
            ...commonData,
            'event_type': e.value,
            'subscription_type': 'events'
          });
        }
      }

      for (var e in _subscriptionHoldsPerms) {
        if (e.isChecked && !e.isDisabled) {
           payload.add({
            ...commonData,
            'event_type': e.value,
            'subscription_type': 'holdsAndPerms'
          });
        }
      }

      if (payload.isNotEmpty) {
         await _service.saveBulkSubscriptions(payload);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save subscriptions: $e';
      return false;
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
