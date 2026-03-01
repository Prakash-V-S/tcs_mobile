class BerthScheduleModel {
  final String id;
  final String phase;
  final String vesselName;
  final String visit;
  final String line;
  final String facility;
  final String vesselClass;
  final String ibVyg;
  final String obVyg;
  final String eta;
  final String ata;
  final String etd;
  final String atd;

  BerthScheduleModel({
    required this.id,
    required this.phase,
    required this.vesselName,
    required this.visit,
    required this.line,
    required this.facility,
    required this.vesselClass,
    required this.ibVyg,
    required this.obVyg,
    required this.eta,
    required this.ata,
    required this.etd,
    required this.atd,
  });

  factory BerthScheduleModel.fromJson(Map<String, dynamic> json) {
    return BerthScheduleModel(
      id: json['_id']?.toString() ?? '',
      phase: json['phase']?.toString() ?? 'Unknown',
      vesselName: json['vessel_name']?.toString() ?? 'Unknown Vessel',
      visit: json['visit']?.toString() ?? 'N/A',
      line: json['line']?.toString() ?? 'N/A',
      facility: json['facility']?.toString() ?? 'N/A',
      vesselClass: json['vessel_class']?.toString() ?? 'N/A',
      ibVyg: json['i_b_vyg']?.toString() ?? 'N/A',
      obVyg: json['o_b_vyg']?.toString() ?? 'N/A',
      eta: json['eta']?.toString() ?? 'N/A',
      ata: json['ata']?.toString() ?? 'N/A',
      etd: json['etd']?.toString() ?? 'N/A',
      atd: json['atd']?.toString() ?? 'N/A',
    );
  }
}
