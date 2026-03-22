class NotificationModel {
  final String id;
  final String userId;
  final DateTime createdDateTime;
  final String eventType;
  final int? eventCode;
  final String subject;
  final String message;
  final bool readFlag;
  final String? module;
  final bool isDeleted;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.createdDateTime,
    required this.eventType,
    this.eventCode,
    required this.subject,
    required this.message,
    required this.readFlag,
    this.module,
    required this.isDeleted,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      createdDateTime: json['created_date_time'] != null
          ? DateTime.parse(json['created_date_time'])
          : DateTime.now(),
      eventType: json['event_type']?.toString() ?? '',
      eventCode: json['event_code'] is int ? json['event_code'] : null,
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      readFlag: json['read_flag'] ?? false,
      module: json['module']?.toString(),
      isDeleted: json['is_deleted'] ?? false,
    );
  }

  bool get isSubscription => module == 'subscription' || eventType == 'navis_notification';
}
