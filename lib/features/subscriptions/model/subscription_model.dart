class SubscriptionEventModel {
  final String eventType;
  final String eventLabel;
  final String state;
  final int count;
  final DateTime latestTimestamp;

  SubscriptionEventModel({
    required this.eventType,
    required this.eventLabel,
    required this.state,
    required this.count,
    required this.latestTimestamp,
  });

  factory SubscriptionEventModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionEventModel(
      eventType: json['event_type']?.toString() ?? '',
      eventLabel: json['event_label']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      latestTimestamp: json['latestTimestamp'] != null 
          ? DateTime.tryParse(json['latestTimestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  bool get isFulfilled => state == 'fulfilled' || state == 'fulfilled'.toUpperCase();

  String get displayName {
    if (eventLabel.isNotEmpty) return eventLabel;
    if (eventType.isEmpty) return 'Unknown Event';
    switch (eventType.toUpperCase()) {
      case 'UNIT_DISCH':
        return 'Discharged';
      case 'UNIT_IN_GATE':
        return 'Entered Port';
      case 'UNIT_OUT_GATE':
        return 'Exited Port';
      case 'UNIT_LOAD':
        return 'Loaded';
      default:
        // Fallback for other types: UNIT_GATE_IN -> Unit Gate In
        try {
          return eventType.split('_').where((w) => w.isNotEmpty).map((word) {
            return word[0].toUpperCase() + word.substring(1).toLowerCase();
          }).join(' ');
        } catch (_) {
          return eventType;
        }
    }
  }
}


class SubscriptionContainerModel {
  final String unitNbr;
  final String userId;
  final List<SubscriptionEventModel> events;
  final DateTime latestTimestamp;
  final String title;
  final int percentage;

  SubscriptionContainerModel({
    required this.unitNbr,
    required this.userId,
    required this.events,
    required this.latestTimestamp,
    required this.title,
    required this.percentage,
  });

  factory SubscriptionContainerModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> eventsJson = json['events'] is List ? json['events'] : [];
    return SubscriptionContainerModel(
      unitNbr: json['unit_nbr']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      events: eventsJson.map((e) => SubscriptionEventModel.fromJson(e as Map<String, dynamic>)).toList(),
      latestTimestamp: json['latestTimestamp'] != null 
          ? DateTime.tryParse(json['latestTimestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      title: json['title']?.toString() ?? '0/0',
      percentage: int.tryParse(json['percentage']?.toString() ?? '0') ?? 0,
    );
  }


  int get notifiedCount {
    final parts = title.split('/');
    if (parts.length == 2) {
      return int.tryParse(parts[0]) ?? 0;
    }
    return 0;
  }

  int get totalCount {
    final parts = title.split('/');
    if (parts.length == 2) {
      return int.tryParse(parts[1]) ?? 0;
    }
    return events.length;
  }
}
