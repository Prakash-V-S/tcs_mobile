class ContainerSearchResponseModel {
  final List<ContainerModel> containers;
  final bool allowSubscribe;

  ContainerSearchResponseModel({
    required this.containers,
    required this.allowSubscribe,
  });

  factory ContainerSearchResponseModel.fromJson(Map<String, dynamic> json) {
    return ContainerSearchResponseModel(
      containers: (json['containerInfo'] as List?)
              ?.map((e) => ContainerModel.fromJson(e))
              .toList() ??
          [],
      allowSubscribe: json['allowSubscribe'] ?? false,
    );
  }
}

class ContainerModel {
  final String unitNbr;
  final String? operator;
  final String? state; // e.g. "Inbound" or "Outbound"
  final String? typeIso;
  final String? category;
  final String? vState;
  final String? tState;
  final String? obActualVisit;
  final String? ibActualVisit;
  final String? pol;
  final String? freightKind;
  final List<String> activeHolds;
  final List<String> activePerms;

  ContainerModel({
    required this.unitNbr,
    this.operator,
    this.state,
    this.typeIso,
    this.category,
    this.vState,
    this.tState,
    this.obActualVisit,
    this.ibActualVisit,
    this.pol,
    this.freightKind,
    this.activeHolds = const [],
    this.activePerms = const [],
  });

  factory ContainerModel.fromJson(Map<String, dynamic> json) {
    // Parse holds
    final List<String> holds = [];
    if (json['active_holds'] is List) {
      for (var hold in json['active_holds']) {
        if (hold is Map && hold['displayName'] != null) {
          holds.add(hold['displayName'].toString());
        } else if (hold is String) {
           holds.add(hold);
        }
      }
    }
    
    // Parse perms
    final List<String> perms = [];
    if (json['active_perms'] is List) {
      for (var perm in json['active_perms']) {
        if (perm is Map && perm['displayName'] != null) {
          perms.add(perm['displayName'].toString());
        } else if (perm is String) {
          perms.add(perm);
        }
      }
    }
    
    // Check for SGSM parsed strings mapped as holds based on angular implementation
    if (json['sgsm'] != null && json['sgsm'].toString().isNotEmpty) {
      holds.add('SGSM: ${json['sgsm']}');
    }

    return ContainerModel(
      unitNbr: json['unit_nbr'] ?? '',
      operator: json['line_op'] ?? json['lineOperator'] ?? json['operator'],
      state: json['t_state'] ?? json['state'] ?? 'Inbound', 
      typeIso: json['type_iso'],
      category: json['category'],
      vState: json['v_state'] ?? 'Active',
      tState: json['t_state'],
      obActualVisit: json['o_b_actual_visit'],
      ibActualVisit: json['i_b_actual_visit'],
      pol: json['pol'],
      freightKind: json['frght_kind'],
      activeHolds: holds,
      activePerms: perms,
    );
  }
}
