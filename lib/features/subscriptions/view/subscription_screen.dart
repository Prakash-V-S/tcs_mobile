import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/services/token_storage.dart';
import '../viewmodel/subscription_viewmodel.dart';
import '../model/subscription_model.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tokenStorage = context.read<TokenStorage>();
      final userId = await tokenStorage.getUserId() ?? '';
      if (mounted) {
        final vm = context.read<SubscriptionViewModel>();
        vm.setUserId(userId);
        vm.fetchSubscriptions();
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const CustomAppBar(
            title: 'Subscriptions',
            showBackIcon: true,
          ) as PreferredSizeWidget,
          body: Column(
            children: [
              _buildSearchBar(viewModel),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.errorMessage.isNotEmpty
                        ? Center(child: Text(viewModel.errorMessage, style: const TextStyle(color: Colors.red)))
                        : _buildSubscriptionList(viewModel),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(SubscriptionViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: viewModel.searchController,
        onChanged: viewModel.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search Containers',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF2E3B84)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSubscriptionList(SubscriptionViewModel viewModel) {
    if (viewModel.filteredContainers.isEmpty) {
      return const Center(child: Text('No subscriptions found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: viewModel.filteredContainers.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final container = viewModel.filteredContainers[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: const Icon(Icons.apps, color: Colors.grey, size: 28),
          title: Text(
            container.unitNbr,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          trailing: CircularProgressIndicatorWidget(
            notified: container.notifiedCount,
            total: container.totalCount,
          ),
          onTap: () => _showSubscriptionDetails(context, container),
        );
      },
    );
  }

  void _showSubscriptionDetails(BuildContext context, SubscriptionContainerModel container) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SubscriptionDetailBottomSheet(container: container);
      },
    );
  }
}

class CircularProgressIndicatorWidget extends StatelessWidget {
  final int notified;
  final int total;

  const CircularProgressIndicatorWidget({
    super.key,
    required this.notified,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: CustomPaint(
        painter: CircularProgressPainter(
          notified: notified,
          total: total,
        ),
        child: Center(
          child: Text(
            '$notified/$total',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final int notified;
  final int total;

  CircularProgressPainter({required this.notified, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 4.0;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    if (total > 0) {
      // Progress arc
      final progressPaint = Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final progress = notified / total;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        -pi / 2,
        2 * pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SubscriptionDetailBottomSheet extends StatelessWidget {
  final SubscriptionContainerModel container;

  const SubscriptionDetailBottomSheet({super.key, required this.container});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Container number', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        container.unitNbr,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                CircularProgressIndicatorWidget(
                  notified: container.notifiedCount,
                  total: container.totalCount,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Subscribed events & Holds',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: container.events.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final event = container.events[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    event.displayName,
                    style: const TextStyle(fontSize: 15),
                  ),
                  trailing: Icon(
                    event.isFulfilled ? Icons.check_circle : Icons.sync,
                    color: event.isFulfilled ? const Color(0xFF4CAF50) : Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

