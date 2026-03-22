import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'berth_schedule/view/berth_schedule_screen.dart';
import 'tos_reports/view/tos_reports_screen.dart';
import 'invoices/view/invoice_list_screen.dart';
import 'container_search/view/container_search_screen.dart';
import 'container_search/viewmodel/container_search_viewmodel.dart';
import 'container_search/service/container_search_service.dart';
import 'storage_management/view/storage_management_screen.dart';
import 'storage_management/viewmodel/storage_management_viewmodel.dart';
import 'storage_management/service/storage_management_service.dart';
import 'subscriptions/view/subscription_screen.dart';
import '../core/services/api_service.dart';
import '../core/services/token_storage.dart';
import '../core/widgets/custom_app_bar.dart';
import 'package:tcs_mobile/features/notifications/viewmodel/notification_viewmodel.dart';

class NavigationTab {
  final String iconPath;
  final String label;
  final Widget screen;
  final String moduleName;

  NavigationTab({
    required this.iconPath,
    required this.label,
    required this.screen,
    required this.moduleName,
  });
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  List<NavigationTab> _activeTabs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final tokenStorage = TokenStorageImpl();
    final userId = await tokenStorage.getUserId() ?? '';
    final moduleAccess = await tokenStorage.getModuleAccess();
    print('moduleAccess: $moduleAccess');
    final role = await tokenStorage.getUserRole();

    if (mounted) {
      // Initialize notifications
      context.read<NotificationViewModel>().setUserId(userId, moduleAccess, role: role);
      
      // Build filtered tabs
      final allTabs = [
        NavigationTab(
          iconPath: 'assets/icons/Invoice summary.svg',
          label: 'Invoice',
          moduleName: 'invoices',
          screen: const InvoiceListScreen(),
        ),
        NavigationTab(
          iconPath: 'assets/icons/Container search.svg',
          label: 'Search',
          moduleName: 'container-search',
          screen: ChangeNotifierProvider(
            create: (_) => ContainerSearchViewModel(
              service: ContainerSearchService(
                apiService: ApiService(tokenStorage: TokenStorageImpl()),
              ),
              userId: userId,
            ),
            child: const ContainerSearchScreen(),
          ),
        ),
        NavigationTab(
          iconPath: 'assets/icons/Empty storage management.svg',
          label: 'Storage',
          moduleName: 'storage-management',
          screen: ChangeNotifierProvider(
            create: (_) => StorageManagementViewModel(
              service: StorageManagementService(
                apiService: ApiService(tokenStorage: TokenStorageImpl()),
              ),
              userId: userId,
            ),
            child: const StorageManagementScreen(),
          ),
        ),
        NavigationTab(
          iconPath: 'assets/icons/tos reports.svg',
          label: 'Reports',
          moduleName: 'tos-reports',
          screen: const TosReportsScreen(isFromNavigation: true),
        ),
        NavigationTab(
          iconPath: 'assets/icons/vessel schedule.svg',
          label: 'Schedule',
          moduleName: 'vessel-schedule',
          screen: const BerthScheduleScreen(isFromNavigation: true),
        ),
      ];

      // Filter tabs based on moduleAccess (case-insensitive)
      final filteredTabs = allTabs.where((tab) {
        return moduleAccess.any((m) => m.toLowerCase().trim() == tab.moduleName.toLowerCase());
      }).toList();

      setState(() {
        _activeTabs = filteredTabs;
        _isLoading = false;

        // Land on the first module from the right (last item) as per requirement
        if (_activeTabs.isNotEmpty) {
          _currentIndex = _activeTabs.length - 1;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_activeTabs.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No module access granted.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _activeTabs.map((tab) => tab.screen).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _activeTabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final bool isSelected = _currentIndex == index;
          return BottomNavigationBarItem(
            icon: SvgPicture.asset(
              tab.iconPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isSelected ? const Color(0xFF2E3B84) : Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}

