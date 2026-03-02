class ContainerSearchLimitModel {
  final int containerSearchLimit;
  final bool enableDamage;
  final bool enableHoldsAndPerms;
  final int dwellLimit;

  ContainerSearchLimitModel({
    required this.containerSearchLimit,
    required this.enableDamage,
    required this.enableHoldsAndPerms,
    required this.dwellLimit,
  });

  factory ContainerSearchLimitModel.fromJson(Map<String, dynamic> json) {
    return ContainerSearchLimitModel(
      containerSearchLimit: json['container_search_limit'] ?? 10,
      enableDamage: json['enableDamage'] ?? false,
      enableHoldsAndPerms: json['enableHoldsAndPerms'] ?? false,
      dwellLimit: json['dwell_limit'] ?? 90,
    );
  }
}
