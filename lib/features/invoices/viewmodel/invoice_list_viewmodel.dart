import 'package:flutter/material.dart';
import '../../../../core/services/token_storage.dart';
import '../data/invoice_service.dart';
import '../model/invoice_model.dart';
import 'package:dio/dio.dart';

class InvoiceListViewModel extends ChangeNotifier {
  final TokenStorage _tokenStorage;
  final InvoiceService _invoiceService;

  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<InvoiceModel> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  InvoiceListViewModel(this._tokenStorage, this._invoiceService);

  Future<void> fetchInitialData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final String companyType = await _tokenStorage.getCompanyType() ?? '';
      final String companyName = await _tokenStorage.getCompanyName() ?? '';

      // 1. Fetch Invoice Types explicitly to mimic web behavior natively
      await _invoiceService.getInvoiceTypes(companyType);

      // 2. Fetch Column Properties natively
      await _invoiceService.getColumnProperties('invoice_summary');

      // 3. Fetch Invoices from the generic list search endpoint
      final List<dynamic> invoicesData = await _invoiceService.getInvoices(
        pageIndex: 0,
        pageSize: 15,
        companyName: companyName,
      );

      _invoices = invoicesData
          .map((json) => InvoiceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        _errorMessage = e.response!.data['message'];
      } else {
        _errorMessage = e.message ?? "Failed to fetch invoices";
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
