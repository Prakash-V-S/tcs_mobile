import 'package:flutter/material.dart';
import '../model/subscription_model.dart';
import '../service/subscription_service.dart';

class SubscriptionViewModel extends ChangeNotifier {
  final SubscriptionService _service;
  String? _userId;

  SubscriptionViewModel({
    required SubscriptionService service,
    String? userId,
  })  : _service = service,
        _userId = userId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<SubscriptionContainerModel> _containerSubscriptions = [];
  List<SubscriptionContainerModel> _filteredContainers = [];
  List<SubscriptionContainerModel> get filteredContainers => _filteredContainers;

  final TextEditingController searchController = TextEditingController();

  void setUserId(String userId) {
    _userId = userId;
  }

  Future<void> fetchSubscriptions() async {
    if (_userId == null || _userId!.isEmpty) {
      _errorMessage = 'User ID not found';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _containerSubscriptions = await _service.getSubscriptions(_userId!);
      _filterSubscriptions();
    } catch (e) {
      _errorMessage = 'Failed to load subscriptions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _filterSubscriptions() {
    final query = searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      _filteredContainers = List.from(_containerSubscriptions);
    } else {
      _filteredContainers = _containerSubscriptions
          .where((c) => c.unitNbr.toLowerCase().contains(query))
          .toList();
    }
    notifyListeners();
  }


  void onSearchChanged(String value) {
    _filterSubscriptions();
  }

  Future<void> deleteSubscription(String id) async {
    try {
      await _service.deleteSubscription(id);
      await fetchSubscriptions(); // Refresh after delete
    } catch (e) {
      _errorMessage = 'Failed to delete subscription: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
