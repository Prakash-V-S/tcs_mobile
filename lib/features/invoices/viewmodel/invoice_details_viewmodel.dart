import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../data/invoice_service.dart';
import '../model/invoice_model.dart';
import 'package:dio/dio.dart';

class InvoiceDetailsViewModel extends ChangeNotifier {
  final InvoiceService _invoiceService;
  final InvoiceModel invoice;

  bool _isDownloading = false;
  String _errorMessage = '';

  bool get isDownloading => _isDownloading;
  String get errorMessage => _errorMessage;

  InvoiceDetailsViewModel(this._invoiceService, this.invoice);

  Future<void> previewPdf() async {
    if (_isDownloading) return;

    _isDownloading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final fileBytes = await _invoiceService.downloadInvoice(
        invoice.draftNumber,
      );

      if (fileBytes.isEmpty) {
        throw Exception("Received empty PDF data from server.");
      }

      // 1. Resolve native physical write directory
      final directory = await getApplicationDocumentsDirectory();

      // 2. Build local cache path
      final String safeDraftNumber = invoice.draftNumber.replaceAll(
        RegExp(r'[^a-zA-Z0-9_\-]'),
        '_',
      );
      final File file = File('${directory.path}/Invoice_$safeDraftNumber.pdf');

      // 3. Write data limits
      await file.writeAsBytes(fileBytes);

      // 4. Trigger system handler to open the newly written document natively
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        throw Exception("Could not open file natively: ${result.message}");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _errorMessage = "Invoice PDF record not found on the server.";
      } else {
        _errorMessage = e.message ?? "Failed to download Invoice PDF.";
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }
}
