import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../viewmodel/container_search_viewmodel.dart';
import '../model/search_type_model.dart';
import '../model/container_model.dart';

class ContainerSearchScreen extends StatefulWidget {
  const ContainerSearchScreen({Key? key}) : super(key: key);

  @override
  State<ContainerSearchScreen> createState() => _ContainerSearchScreenState();
}

class _ContainerSearchScreenState extends State<ContainerSearchScreen> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (!mounted) return;
      final viewModel = Provider.of<ContainerSearchViewModel>(context, listen: false);
      if (_searchFocusNode.hasFocus) {
         viewModel.setSearchFocused(true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContainerSearchViewModel>(
        context,
        listen: false,
      ).fetchInitialData();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContainerSearchViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: viewModel.isSearchFocused
              ? AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                    onPressed: () {
                      _searchFocusNode.unfocus();
                      viewModel.resetSearch();
                    },
                  ),
                )
              : const CustomAppBar(title: 'Container search') as PreferredSizeWidget,
          body: _buildBody(viewModel),
        );
      },
    );
  }

  Widget _buildBody(ContainerSearchViewModel viewModel) {
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
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchInitialData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (viewModel.isSearchFocused) ...[
                const SizedBox(height: 8),
                const Text(
                  'Search by',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSearchTypes(viewModel),
                const SizedBox(height: 20),
              ] else if (!viewModel.hasSearched) ...[
                const SizedBox(height: 20),
              ],
              _buildSearchBarRow(viewModel),
              const SizedBox(height: 32),
              
              if (viewModel.hasSearched) ...[
                _buildSearchResults(viewModel),
              ] else ...[
                const Text(
                  'Recent searches',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecentSearchesList(viewModel),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTypes(ContainerSearchViewModel viewModel) {
    if (viewModel.searchTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: viewModel.searchTypes.map((type) {
          final isSelected = viewModel.selectedSearchType?.key == type.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(type.label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  viewModel.setSelectedSearchType(type);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFF3F5FC), // Light blue background
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF2E3B84) : Colors.black54,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF2E3B84)
                    : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBarRow(ContainerSearchViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // To align with hint text visually if needed
      children: [
        Expanded(child: _buildSearchBar(viewModel)),
        if (viewModel.hasSearched) ...[
          const SizedBox(width: 12),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.black87),
              onPressed: () {
                // Filter action
              },
            ),
          )
        ]
      ],
    );
  }

  Widget _buildSearchBar(ContainerSearchViewModel viewModel) {
    final hintHelperText = viewModel.getSearchHintText();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: viewModel.isSearchFocused ? const Color(0xFF2E3B84) : Colors.grey.shade300, 
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: viewModel.searchController,
            focusNode: _searchFocusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              viewModel.submitSearch();
            },
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            onChanged: (val) {
              // Trigger UI update for length counter
              setState(() {});
            },
            decoration: InputDecoration(
              prefixIcon: viewModel.isSearchFocused || viewModel.hasSearched 
                  ? const Icon(Icons.search, color: Color(0xFF2E3B84))
                  : const Icon(Icons.search, color: Colors.grey),
              suffixIcon: viewModel.hasSearched
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        viewModel.clearSearchResults();
                        _searchFocusNode.requestFocus();
                      },
                    )
                  : null,
              hintText: viewModel.isSearchFocused ? '|Search Containers' : 'Search Containers',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        if (viewModel.isSearchFocused && hintHelperText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hintHelperText,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '(${viewModel.searchController.text.length}/11)',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRecentSearchesList(ContainerSearchViewModel viewModel) {
    if (viewModel.recentSearches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No Recent searches',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.recentSearches.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final search = viewModel.recentSearches[index];
        // Handle potentially long query strings (like comma separated containers)
        final displayTitle = search.query.containerNumber.length > 35 
          ? '${search.query.containerNumber.substring(0, 35)}...'
          : search.query.containerNumber;

        // Try to map filterType back to the human-readable label if possible
        String displayFilterType = '';
        try {
          // Format filterType visually mapping to UI concept.
          final match = viewModel.searchTypes.firstWhere(
            (element) => element.value == search.query.inputType,
            orElse: () => SearchParameterModel(label: search.filterType, key: '', value: '')
          );
          displayFilterType = match.label;
        } catch (_) {
           displayFilterType = search.filterType;
        }


        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.history, color: Colors.grey),
          title: Text(
            displayTitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            displayFilterType,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF2E3B84), // Match Figma UI
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            viewModel.searchController.text = search.query.containerNumber;
            final match = viewModel.searchTypes.firstWhere(
              (element) => element.value == search.query.inputType,
              orElse: () => viewModel.searchTypes.first
            );
            
            // Set the search type bubble "chip" active, but do not clear the input text.
            viewModel.setSelectedSearchType(match, clearText: false);
            
            // Focus the input to trigger the UI switch into "Active State" (Image 2) instead of auto-submitting.
            _searchFocusNode.requestFocus();
          },
        );
      },
    );
  }

  Widget _buildSearchResults(ContainerSearchViewModel viewModel) {
    if (viewModel.searchResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No matching containers found.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final container = viewModel.searchResults[index];

        return GestureDetector(
          onTap: () {
            _showContainerDetails(context, viewModel, container);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      container.unitNbr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Line operator : ${container.operator ?? '--'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4E5FF), // Light blue background for badge
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF8BADEF)), // Darker blue border
                  ),
                  child: Text(
                    container.state ?? 'Inbound',
                    style: const TextStyle(
                      color: Color(0xFF2E3B84),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContainerDetails(BuildContext context, ContainerSearchViewModel viewModel, ContainerModel container) {
    // Start fetching damages
    viewModel.fetchDamages(container.unitNbr);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) {
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: Consumer<ContainerSearchViewModel>(
            builder: (ctx, vm, child) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.85,
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
                                const Text('Unit Nbr', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                Text(
                                  container.unitNbr,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(bCtx),
                          )
                        ],
                      ),
                    ),
                    // Tabs
                    Expanded(
                      child: DefaultTabController(
                        length: 3,
                        child: Column(
                          children: [
                            const TabBar(
                              labelColor: Color(0xFF2E3B84),
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Color(0xFF2E3B84),
                              tabs: [
                                Tab(text: 'General'),
                                Tab(text: 'Holds/Permission'),
                                Tab(text: 'Damages'),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _buildGeneralTab(container),
                                  _buildHoldsPermsTab(container),
                                  _buildDamagesTab(vm),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Sticky Subscribe Button
                    if (vm.allowSubscribe)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            )
                          ]
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2E3B84),
                              side: const BorderSide(color: Color(0xFF2E3B84)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.bookmark_border),
                            label: const Text('Subscribe', style: TextStyle(fontSize: 16)),
                            onPressed: () {
                               _showSubscribeBottomSheet(context, viewModel, container);
                            },
                          ),
                        ),
                      )
                  ],
                ),
              );
            }
          ),
        );
      }
    );
  }

  Widget _buildGeneralTab(ContainerModel container) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailRow('Category', container.category ?? 'Export'),
        const Divider(),
        _buildDetailRow('ISO', container.typeIso ?? '--'),
        const Divider(),
        _buildDetailRow('Line operator', container.operator ?? '--'),
        const Divider(),
        _buildDetailRow('Freight Kind', container.freightKind ?? 'FCL'),
        const Divider(),
        _buildDetailRow('V state', container.vState ?? 'Active', isBadge: true, badgeColor: Colors.green),
        const Divider(),
        _buildDetailRow('T state', container.tState ?? 'Inbound', isBadge: true, badgeColor: Colors.blue),
        const Divider(),
        _buildDetailRow('OB Actual visit', container.obActualVisit ?? '--'),
        const Divider(),
        _buildDetailRow('IB Actual visit', container.ibActualVisit ?? '--'),
        const Divider(),
        _buildDetailRow('POL', container.pol ?? '--'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBadge = false, MaterialColor? badgeColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          if (isBadge)
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               decoration: BoxDecoration(
                 color: badgeColor?.shade50 ?? Colors.blue.shade50,
                 borderRadius: BorderRadius.circular(4),
                 border: Border.all(color: badgeColor?.shade300 ?? Colors.blue.shade300),
               ),
               child: Text(value, style: TextStyle(color: badgeColor?.shade800 ?? Colors.blue.shade800, fontSize: 12)),
             )
          else
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHoldsPermsTab(ContainerModel container) {
    final combined = [
      ...container.activeHolds.map((h) => {'type': 'Hold/SGSM', 'value': h}),
      ...container.activePerms.map((p) => {'type': 'Permission', 'value': p}),
    ];

    if (combined.isEmpty) {
      return const Center(
        child: Text(
          'No holds or permissions found for this container', 
          style: TextStyle(color: Colors.grey)
        )
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: combined.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = combined[index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item['type']!, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            Expanded(
              child: Text(
                item['value']!, 
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDamagesTab(ContainerSearchViewModel vm) {
    if (vm.isLoadingDamages) {
       return const Center(child: CircularProgressIndicator());
    }
    if (vm.currentDamages.isEmpty) {
       return Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
           const SizedBox(height: 16),
           const Text('No damages found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
           const SizedBox(height: 8),
           Text('No damages found for this container', style: TextStyle(color: Colors.grey)),
         ],
       );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vm.currentDamages.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final damage = vm.currentDamages[index];
        final isMajor = damage.severity.toUpperCase() == 'MAJOR';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(damage.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isMajor ? Colors.red.shade50 : Colors.orange.shade50,
                    border: Border.all(color: isMajor ? Colors.red : Colors.orange),
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: Text(damage.severity, style: TextStyle(fontSize: 10, color: isMajor ? Colors.red : Colors.orange)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text('${damage.component} - ${damage.type}', style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        );
      },
    );
  }

  void _showSubscribeBottomSheet(BuildContext context, ContainerSearchViewModel viewModel, ContainerModel container) {
    viewModel.fetchSubscriptionEvents(container);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) {
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: Consumer<ContainerSearchViewModel>(
            builder: (ctx, vm, child) {
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Choose Subscriptions',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(bCtx),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: vm.isLoadingSubscriptions
                          ? const Center(child: CircularProgressIndicator())
                          : ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                if (vm.subscriptionEvents.isNotEmpty) ...[
                                  const Text(
                                    'Events',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2E3B84)
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...vm.subscriptionEvents.map((e) => CheckboxListTile(
                                        title: Text(e.label),
                                        value: e.isChecked,
                                        onChanged: e.isDisabled ? null : (val) => vm.toggleSubscription(e, false),
                                        controlAffinity: ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                        activeColor: const Color(0xFF2E3B84),
                                      )),
                                  const SizedBox(height: 16),
                                ],
                                if (vm.subscriptionHoldsPerms.isNotEmpty) ...[
                                  const Text(
                                    'Holds & Permissions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2E3B84)
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...vm.subscriptionHoldsPerms.map((e) => CheckboxListTile(
                                        title: Text(e.label),
                                        value: e.isChecked,
                                        onChanged: e.isDisabled ? null : (val) => vm.toggleSubscription(e, true),
                                        controlAffinity: ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                        activeColor: const Color(0xFF2E3B84),
                                      )),
                                ]
                              ],
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () => Navigator.pop(bCtx),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E3B84),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: vm.isLoadingSubscriptions
                                  ? null
                                  : () async {
                                      final success = await vm.submitSubscriptions(container);
                                      if (success && mounted) {
                                        Navigator.pop(bCtx); // Close subscriptions sheet
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Container Subscribed Successfully')),
                                        );
                                      }
                                    },
                              child: vm.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Subscribe'),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      }
    );
  }
}
