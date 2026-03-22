import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../model/invoice_model.dart';
import '../viewmodel/invoice_list_viewmodel.dart';
import 'invoice_details_screen.dart';
import 'package:intl/intl.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceListViewModel>(
        context,
        listen: false,
      ).fetchInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Invoice'),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Consumer<InvoiceListViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          viewModel.errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                        TextButton(
                          onPressed: () => viewModel.fetchInitialData(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.invoices.isEmpty) {
                  return const Center(child: Text('No Invoices Found'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: viewModel.invoices.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final invoice = viewModel.invoices[index];
                    return _buildInvoiceCard(invoice, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () {
          // TODO: Navigate to generation tab dynamically
        },
        backgroundColor: const Color(0xFF2E3B84),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Invoice',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const TextField(
          style: TextStyle(fontSize: 16, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Color(0xFF2E3B84)),
            hintText: 'Search draft no',
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
            suffixIcon: Icon(Icons.qr_code_scanner, color: Color(0xFF2E3B84)),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice, BuildContext context) {
    // ...
    final currencyFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: invoice.currency + ' ', // CFA format prefix
      decimalDigits: 2,
    );
    final String displayAmount = currencyFormat.format(invoice.totalOwed);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceDetailsScreen(invoice: invoice),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${invoice.draftNumber}',
                  style: const TextStyle(
                    color: Color(0xFF2E3B84),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    invoice.invoiceType.toUpperCase(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Amount',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  displayAmount,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: invoice.invoiceStatus.toLowerCase() == 'draft'
                        ? Colors.yellow.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: invoice.invoiceStatus.toLowerCase() == 'draft'
                          ? Colors.yellow.shade700
                          : Colors.green.shade700,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        invoice.invoiceStatus.toLowerCase() == 'draft'
                            ? Icons.description
                            : Icons.check_circle,
                        size: 14,
                        color: invoice.invoiceStatus.toLowerCase() == 'draft'
                            ? Colors.yellow.shade800
                            : Colors.green.shade800,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        invoice.invoiceStatus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: invoice.invoiceStatus.toLowerCase() == 'draft'
                              ? Colors.yellow.shade800
                              : Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
