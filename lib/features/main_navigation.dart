import 'package:flutter/material.dart';

import 'berth_schedule/view/berth_schedule_screen.dart';
import 'tos_reports/view/tos_reports_screen.dart';
import 'invoices/view/invoice_list_screen.dart';
import 'container_search/view/container_search_screen.dart';
import 'container_search/viewmodel/container_search_viewmodel.dart';
import 'container_search/service/container_search_service.dart';
import 'storage_management/view/storage_management_screen.dart';
import 'storage_management/viewmodel/storage_management_viewmodel.dart';
import 'storage_management/service/storage_management_service.dart';
import '../core/services/api_service.dart';
import '../core/services/token_storage.dart';
import 'package:provider/provider.dart';
import '../core/widgets/custom_app_bar.dart';
import 'package:tcs_mobile/features/notifications/viewmodel/notification_viewmodel.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({Key? key, this.initialIndex = 4})
    : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final tokenStorage = TokenStorageImpl();
    final userId = await tokenStorage.getUserId() ?? '';
    final screens = await tokenStorage.getModuleAccess();
    final role = await tokenStorage.getUserRole();
    if (mounted) {
      context.read<NotificationViewModel>().setUserId(userId, screens, role: role);
    }
  }


  // Placeholder screens for unimplemented features
  Widget _buildPlaceholder(String title) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(title: title),
      body: Center(
        child: Text(
          '$title (Coming Soon)',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the active screen based on _currentIndex
    Widget activeScreen;
    switch (_currentIndex) {
      case 0:
        activeScreen = const InvoiceListScreen();
        break;
      case 1:
        activeScreen = ChangeNotifierProvider(
          create: (_) {
            // Need to retrieve userId from TokenStorage
            // Since this is a simple setup, we mock userId resolution or fetch it
            // Assuming the ApiService handles user context
            return ContainerSearchViewModel(
              service: ContainerSearchService(
                apiService: ApiService(tokenStorage: TokenStorageImpl()),
              ),
              userId: '', // Add real userId mapping if stored locally, or handled in API interceptor
            );
          },
          child: const ContainerSearchScreen(),
        );
        break;
      case 2:
        activeScreen = ChangeNotifierProvider(
          create: (_) {
            return StorageManagementViewModel(
              service: StorageManagementService(
                apiService: ApiService(tokenStorage: TokenStorageImpl()),
              ),
              userId: '', // Mocked or handled securely
            );
          },
          child: const StorageManagementScreen(),
        );
        break;
      case 3:
        activeScreen = TosReportsScreen(
          isFromNavigation: true,
        ); // Reports Screen
        break;
      case 4:
      default:
        activeScreen = BerthScheduleScreen(
          isFromNavigation: true,
        ); // Default: Schedule Screen
        break;
    }

    return Scaffold(
      body: activeScreen,
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Invoice',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Storage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_boat),
            label: 'Schedule',
          ), // Index 4
        ],
      ),
    );
  }
}
