import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/report_type_model.dart';
import '../model/line_operator_model.dart';
import '../viewmodel/generate_tos_report_viewmodel.dart';

class GenerateTosReportScreen extends StatefulWidget {
  const GenerateTosReportScreen({Key? key}) : super(key: key);

  @override
  State<GenerateTosReportScreen> createState() =>
      _GenerateTosReportScreenState();
}

class _GenerateTosReportScreenState extends State<GenerateTosReportScreen> {
  ReportTypeModel? _selectedReportType;
  LineOperatorModel? _selectedLineOperator;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GenerateTosReportViewModel>().initLoad();
    });
  }

  void _showReportTypeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Required for floating X button overlay
      builder: (context) {
        final viewModel = context.read<GenerateTosReportViewModel>();
        ReportTypeModel? localSelection = _selectedReportType;
        final reportTypes = viewModel.reportTypes;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24, // Padding above modal
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topRight,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 48,
                      bottom: 24,
                    ), // Push down to make space for X
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Select report',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...reportTypes.map((type) {
                          final isSelected =
                              localSelection?.value == type.value;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() => localSelection = type);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.indigo.withOpacity(0.05)
                                    : Colors.white, // White when unselected
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.indigo.shade800
                                      : Colors.grey.withOpacity(
                                          0.2,
                                        ), // Light grey matching mockup
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    type.label,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: isSelected
                                        ? Colors.indigo.shade800
                                        : Colors.grey.shade400,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.indigo.shade800, // Matching dark button
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedReportType = localSelection;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Select',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLineOperatorBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Required for floating X button overlay
      builder: (context) {
        final viewModel = context.read<GenerateTosReportViewModel>();
        LineOperatorModel? localSelection = _selectedLineOperator;
        final operators = viewModel.lineOperators;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24, // Padding above modal
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topRight,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 48,
                      bottom: 24,
                    ), // Push down to make space for X
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Select line operator',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search line operator',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: ListView(
                            shrinkWrap: true,
                            children: operators.map((op) {
                              final isSelected = localSelection?.id == op.id;
                              return ListTile(
                                onTap: () {
                                  setModalState(() => localSelection = op);
                                },
                                title: Text(
                                  op.value,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                  ), // Remove bolding for consistency
                                ),
                                trailing: Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? Colors.indigo.shade800
                                      : Colors.grey.shade400,
                                ),
                                contentPadding: EdgeInsets.zero,
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.indigo.shade800, // Matching dark button
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedLineOperator = localSelection;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Select',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Generate report',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<GenerateTosReportViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.initLoad,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          bool isComplete =
              _selectedReportType != null && _selectedLineOperator != null;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Report',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showReportTypeBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedReportType?.label ?? 'Select Report',
                          style: TextStyle(
                            color: _selectedReportType != null
                                ? Colors.black
                                : Colors.grey[500],
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Select line operator',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showLineOperatorBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedLineOperator?.value ??
                              'Select line operator',
                          style: TextStyle(
                            color: _selectedLineOperator != null
                                ? Colors.black
                                : Colors.grey[500],
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isComplete
                          ? Colors.indigo[900]
                          : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isComplete && !viewModel.isGenerating
                        ? () async {
                            final success = await viewModel.generateReport(
                              type: _selectedReportType!,
                              operator: _selectedLineOperator!,
                            );
                            if (!context.mounted) return;

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Report generated successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(
                                context,
                              ); // Optional: close screen after generation
                            } else if (viewModel.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(viewModel.errorMessage!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        : null,
                    child: viewModel.isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : Text(
                            'Generate report',
                            style: TextStyle(
                              color: isComplete ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
