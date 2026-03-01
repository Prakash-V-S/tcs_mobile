class InvoiceModel {
  final String id;
  final String draftNumber;
  final String? finalNumber;
  final String invoiceStatus;
  final String invoiceType;
  final double totalOwed;
  final String currency;
  final String? filePath;
  final String? createdIn;

  InvoiceModel({
    required this.id,
    required this.draftNumber,
    this.finalNumber,
    required this.invoiceStatus,
    required this.invoiceType,
    required this.totalOwed,
    required this.currency,
    this.filePath,
    this.createdIn,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['_id']?.toString() ?? '',
      draftNumber: json['draftNumber']?.toString() ?? '',
      finalNumber: json['finalNumber']?.toString(),
      invoiceStatus: json['invoiceStatus']?.toString() ?? 'Draft',
      invoiceType: json['invoiceType']?.toString() ?? 'UNKNOWN INVOICE',
      totalOwed: (json['totalOwed'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'CFA',
      filePath: json['filePath']?.toString(),
      createdIn: json['createdIn']?.toString(),
    );
  }
}
