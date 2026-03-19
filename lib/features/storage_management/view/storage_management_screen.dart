import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../model/storage_model.dart';
import '../viewmodel/storage_management_viewmodel.dart';

class StorageManagementScreen extends StatefulWidget {
  const StorageManagementScreen({super.key});

  @override
  State<StorageManagementScreen> createState() => _StorageManagementScreenState();
}

class _StorageManagementScreenState extends State<StorageManagementScreen> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StorageManagementViewModel>().fetchInitialData();
      }
    });

    _searchFocusNode.addListener(() {
      if (mounted) {
        if (_searchFocusNode.hasFocus) {
          final vm = context.read<StorageManagementViewModel>();
          vm.setSearchFocused(true);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageManagementViewModel>(
      builder: (context, viewModel, child) {
        final isInitial = !viewModel.isSearchFocused && !viewModel.hasSearched;
        final isActiveSearch = viewModel.isSearchFocused && !viewModel.hasSearched;
        final isResults = viewModel.hasSearched;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            title: 'Storage management',
            showAvatar: isInitial || isResults,
            showBackIcon: isActiveSearch,
            onBackPressed: isActiveSearch
                ? () {
                    _searchFocusNode.unfocus();
                    viewModel.setSearchFocused(false);
                    viewModel.resetSearch();
                  }
                : null,
          ),
          body: Column(
            children: [
              _buildTopSection(viewModel, isInitial, isActiveSearch, isResults),
              Expanded(
                child: _buildBodyContent(viewModel, isInitial, isActiveSearch, isResults),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopSection(StorageManagementViewModel viewModel, bool isInitial,
      bool isActiveSearch, bool isResults) {
    if (isResults) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        viewModel.searchController.text,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        viewModel.clearSearchResults();
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _searchFocusNode.requestFocus();
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.grey, size: 20),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.tune, color: Colors.blueGrey),
            )
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isActiveSearch && viewModel.lineOperators.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: viewModel.selectedLineOperator,
                  hint: const Text('Select line operator'),
                  items: viewModel.lineOperators.map((op) {
                    return DropdownMenuItem<String>(
                      value: op,
                      child: Text(op),
                    );
                  }).toList(),
                  onChanged: (val) {
                    viewModel.setSelectedLineOperator(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          TextField(
            key: const ValueKey('searchContainerTextField'),
            controller: viewModel.searchController,
            focusNode: _searchFocusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
               if (viewModel.selectedLineOperator == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a Line Operator'))
                  );
                  _searchFocusNode.requestFocus();
               } else {
                 viewModel.submitSearch();
               }
            },
            decoration: InputDecoration(
              hintText: 'Search Containers',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF2E3B84)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: isActiveSearch
                        ? const Color(0xFF2E3B84)
                        : Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2E3B84), width: 1.5),
              ),
            ),
          ),
          
          if (isActiveSearch && viewModel.searchLimit != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Container number must be 11 characters',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                      '(${viewModel.searchController.text.split(',').where((e) => e.isNotEmpty).length}/${viewModel.searchLimit!.containerSearchLimit})',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(StorageManagementViewModel viewModel, bool isInitial,
      bool isActiveSearch, bool isResults) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            viewModel.errorMessage,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (isResults) {
      return _buildSearchResultsList(viewModel);
    }

    return _buildRecentSearchesList(viewModel, isActiveSearch);
  }

  Widget _buildRecentSearchesList(
      StorageManagementViewModel viewModel, bool isActive) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Recent searches',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: viewModel.recentSearches.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final search = viewModel.recentSearches[index];
              final queryStr = search.query.containerNumber;
              final lineOpStr = search.query.lineOperator ?? '';

              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey, size: 20),
                title: Text(queryStr,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  viewModel.searchController.text = queryStr;
                  if (viewModel.lineOperators.contains(lineOpStr)) {
                     viewModel.setSelectedLineOperator(lineOpStr);
                  }
                  if (isActive) {
                    _searchFocusNode.requestFocus();
                  } else {
                    _searchFocusNode.requestFocus();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultsList(StorageManagementViewModel viewModel) {
    if (viewModel.searchResults.isEmpty) {
      return const Center(child: Text('No storage records found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final container = viewModel.searchResults[index];
        return GestureDetector(
          onTap: () => _showStorageDetails(context, container),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade200)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      container.containerNumber,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Line operator : ${container.lineOperator}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    )
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    container.tState.isNotEmpty && container.tState != 'N/A' 
                       ? container.tState
                       : container.category,
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
    );
  }

  void _showStorageDetails(BuildContext context, StorageModel container) {
    final tabs = container.storageDetails.keys.toList();
    if (tabs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No storage details available for this container')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) {
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
                            container.containerNumber,
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
                  length: tabs.length,
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: tabs.length > 3,
                        labelColor: const Color(0xFF2E3B84),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: const Color(0xFF2E3B84),
                        tabs: tabs.map((t) => Tab(text: _formatLabel(t))).toList(),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: tabs.map((t) {
                            final Map<String, dynamic> tabData = container.storageDetails[t] ?? {};
                            return ListView(
                              padding: const EdgeInsets.all(16),
                              children: tabData.entries.map((e) {
                                return Column(
                                  children: [
                                    _buildDetailRow(_formatLabel(e.key), e.value?.toString() ?? 'N/A'),
                                    const Divider(),
                                  ],
                                );
                              }).toList(),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatLabel(String key) {
    if (key.isEmpty) return '';
    return key.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14))),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
