import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_config.dart';
import 'package:dio/dio.dart';
import '../model/container_search_limit_model.dart';
import '../model/search_type_model.dart';
import '../model/container_recent_search_model.dart';
import '../model/container_model.dart';
import '../model/damage_model.dart';
import '../model/subscription_event_model.dart';
import 'dart:convert';

class ContainerSearchService {
  final ApiService _apiService;

  ContainerSearchService({required ApiService apiService})
      : _apiService = apiService;

  Future<ContainerSearchLimitModel> getSearchLimits() async {
    try {
      final response = await _apiService.get('/limit');
      return ContainerSearchLimitModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<SearchTypeResponseModel> getSearchTypes() async {
    try {
      final response = await _apiService.get('/types');
      return SearchTypeResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ContainerRecentSearchModel>> getRecentSearches(
      String userId) async {
    try {
      final response = await _apiService.get('/v1/dashboard/searches');

      if (response.data is List) {
        // Find the object with module === "CONTAINERS"
        final containerSearchesData = (response.data as List).firstWhere(
            (element) => element['module'] == 'CONTAINERS',
            orElse: () => null);

        if (containerSearchesData != null &&
            containerSearchesData['records'] != null) {
          final List<dynamic> records = containerSearchesData['records'];
          return records
              .map((e) => ContainerRecentSearchModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<ContainerSearchResponseModel> searchContainers(
      String containerNumber, String inputType) async {
    try {
      final response = await _apiService.get(
        '/containers',
        queryParameters: {
          'container_number': containerNumber,
          'inputType': inputType,
        },
      );

      return ContainerSearchResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DamageModel>> getContainerDamages(
      String containerNumber, String username, String customerId) async {
    try {
      final response = await _apiService.get(
        '/damages',
        queryParameters: {
          'container_number': containerNumber,
          'username': username,
          'customerId': customerId,
        },
      );
      
      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((e) => DamageModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, List<SubscriptionEventModel>>> getEvents(
      ContainerModel container) async {
    try {
      final response = await _apiService.get(
        '/v1/events',
        queryParameters: {
          'container': jsonEncode({'unit_nbr': container.unitNbr}),
        },
      );
      
      final eventsData = response.data['events'] as List? ?? [];
      final holdsData = response.data['holdsAndPerms'] as List? ?? [];

      return {
        'events': eventsData.map((e) => SubscriptionEventModel.fromJson(e)).toList(),
        'holdsAndPerms': holdsData.map((e) => SubscriptionEventModel.fromJson(e)).toList(),
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getSubscribedEvents(
      String containerNumber, String userId) async {
    try {
      final response = await _apiService.get(
        '/v1/subscription/container',
        queryParameters: {
          'unit_nbr': containerNumber,
          'user_id': userId,
        },
      );
      
      final subscriptions = response.data['subscriptions'] as List? ?? [];
      return subscriptions
          .map((sub) => sub['event_type'].toString())
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveBulkSubscriptions(List<Map<String, dynamic>> payload) async {
    try {
      await _apiService.post(
        '/subscriptions/bulk',
        data: payload,
      );
    } catch (e) {
      rethrow;
    }
  }
}
