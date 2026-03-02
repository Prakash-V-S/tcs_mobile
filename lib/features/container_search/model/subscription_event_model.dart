class SubscriptionEventModel {
  final String label;
  final String value;
  final bool isChecked;
  final bool isDisabled;

  SubscriptionEventModel({
    required this.label,
    required this.value,
    this.isChecked = false,
    this.isDisabled = false,
  });

  factory SubscriptionEventModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionEventModel(
      label: json['label'] ?? json['key'] ?? '',
      value: json['value'] ?? '',
      isChecked: json['isChecked'] ?? false,
      isDisabled: json['isDisabled'] ?? false,
    );
  }

  SubscriptionEventModel copyWith({
    String? label,
    String? value,
    bool? isChecked,
    bool? isDisabled,
  }) {
    return SubscriptionEventModel(
      label: label ?? this.label,
      value: value ?? this.value,
      isChecked: isChecked ?? this.isChecked,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }
}
