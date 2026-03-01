import 'package:flutter/foundation.dart';
import '../data/tos_report_service.dart';
import '../model/report_type_model.dart';
import '../model/line_operator_model.dart';
import '../../../core/services/token_storage.dart';

class GenerateTosReportViewModel extends ChangeNotifier {
  final TosReportService _tosReportService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ReportTypeModel> _reportTypes = [];
  List<ReportTypeModel> get reportTypes => _reportTypes;

  List<LineOperatorModel> _lineOperators = [];
  List<LineOperatorModel> get lineOperators => _lineOperators;

  final TokenStorage _tokenStorage;
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;
  String? _base64ExcelFile;
  String? get base64ExcelFile => _base64ExcelFile;

  GenerateTosReportViewModel(this._tosReportService, this._tokenStorage);

  Future<void> initLoad() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final typesFuture = _tosReportService.fetchReportTypes();
      final opsFuture = _tosReportService.fetchLineOperators();

      final results = await Future.wait([typesFuture, opsFuture]);

      _reportTypes = results[0] as List<ReportTypeModel>;
      _lineOperators = results[1] as List<LineOperatorModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> generateReport({
    required ReportTypeModel type,
    required LineOperatorModel operator,
  }) async {
    _isGenerating = true;
    _errorMessage = null;
    _base64ExcelFile = null;
    notifyListeners();

    try {
      final userId = await _tokenStorage.getUserId();
      final username = await _tokenStorage.getUsername();

      final payload = {
        "userName": username,
        "userId": userId,
        "reportName": type.value,
        "withFullName": type.withFullName,
        "label": type.label,
        "reportData": {"LineOp": operator.value},
      };

      await _tosReportService.generateReport(payload);
      final reportId = await _tosReportService.getLatestReport(userId!);
      final previewData = await _tosReportService.previewReport(reportId);

      if (previewData['message'] == "Report is empty (no records)") {
        _errorMessage = previewData['message'];
        return false;
      }

      if (previewData['file'] != null) {
        _base64ExcelFile = previewData['file'];
        return true;
      }

      _errorMessage = "Failed to extract report file block.";
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
}
