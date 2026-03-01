import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/berth_schedule_viewmodel.dart';
import 'berth_details_screen.dart';

class BerthScheduleScreen extends StatefulWidget {
  const BerthScheduleScreen({Key? key}) : super(key: key);

  @override
  State<BerthScheduleScreen> createState() => _BerthScheduleScreenState();
}

class _BerthScheduleScreenState extends State<BerthScheduleScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BerthScheduleViewModel>().initLoad();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<BerthScheduleViewModel>().loadMore();
      }
    });

    _searchController.addListener(() {
      context.read<BerthScheduleViewModel>().setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Berth schedule', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder avatar
          ),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: Consumer<BerthScheduleViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.schedules.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage != null && viewModel.schedules.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(viewModel.errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: () => viewModel.initLoad(), child: const Text('Retry')),
                      ],
                    ),
                  );
                }

                if (viewModel.schedules.isEmpty) {
                  return const Center(child: Text("No vessels found"));
                }

                return RefreshIndicator(
                  onRefresh: viewModel.initLoad,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
                    itemCount: viewModel.schedules.length + (viewModel.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == viewModel.schedules.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final schedule = viewModel.schedules[index];
                      return _buildScheduleCard(context, schedule);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar placeholder from mockup
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey,
        currentIndex: 4, // Vessel Schedule active
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Invoice'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Storage'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment_outlined), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_boat), label: 'Schedule'),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vessels',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.black87),
              onPressed: () => _showFilterBottomSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, schedule) {
    Color getBadgeColor(String phase) {
      if (phase.toLowerCase() == 'inbound') return Colors.blue[100]!;
      if (phase.toLowerCase() == 'departed') return Colors.red[100]!;
      return Colors.grey[200]!;
    }

    Color getBadgeTextColor(String phase) {
       if (phase.toLowerCase() == 'inbound') return Colors.blue[900]!;
       if (phase.toLowerCase() == 'departed') return Colors.red[900]!;
       return Colors.grey[800]!;
    }

    final dateFormatObj = schedule.eta; 
    final dateFormatObjEtd = schedule.etd; 
    
    // Formatting N/A cleanly fallback
    final formattedEta = (dateFormatObj != null && dateFormatObj != 'N/A') ? dateFormatObj.toString() : 'N/A';
    final formattedEtd = (dateFormatObjEtd != null && dateFormatObjEtd != 'N/A') ? dateFormatObjEtd.toString() : 'N/A';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BerthDetailsScreen(schedule: schedule)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_boat, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      schedule.vesselName.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                     color: getBadgeColor(schedule.phase),
                     borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    schedule.phase,
                    style: TextStyle(color: getBadgeTextColor(schedule.phase), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ETA', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(formattedEta, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  ],
                ),
                const Icon(Icons.sync_alt, color: Colors.blue, size: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     const Text('ETD', style: TextStyle(color: Colors.grey, fontSize: 12)),
                     const SizedBox(height: 4),
                     Text(formattedEtd, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  ],
                )
              ],
            ),
             const SizedBox(height: 16),
             Text('Line : ${schedule.line}', style: const TextStyle(color: Colors.black87, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext sheetContext) {
        return DefaultTextStyle(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              final viewModel = context.read<BerthScheduleViewModel>();
              String? localSelection = viewModel.selectedPhase;

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Phase', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...['Inbound', 'Outbound', 'Departed', 'Unit Gate in'].map((phase) {
                      return ListTile(
                        title: Text(phase),
                        trailing: Radio<String?>(
                          value: phase,
                          groupValue: localSelection,
                          onChanged: (val) {
                            setModalState(() {
                              localSelection = val;
                            });
                          },
                          activeColor: Colors.blue[900],
                        ),
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                           setModalState(() {
                              localSelection = phase;
                            });
                        }
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              viewModel.setPhaseFilter(null);
                              Navigator.pop(context);
                            },
                            child: Text('Clear all', style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              viewModel.setPhaseFilter(localSelection);
                              Navigator.pop(context);
                            },
                            child: const Text('Apply filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
