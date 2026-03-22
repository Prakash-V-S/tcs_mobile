import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodel/notification_viewmodel.dart';
import '../model/notification_model.dart';
import 'widgets/notification_detail_bottom_sheet.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().fetchNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF36519E)),
            tooltip: 'Mark all as read',
            onPressed: () => context.read<NotificationViewModel>().markAllAsRead(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelPadding: const EdgeInsets.only(right: 8),
                tabs: [
                  _buildTab('Subscriptions', 0),
                  _buildTab('General', 1),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<NotificationViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (vm.errorMessage.isNotEmpty) {
                  return Center(child: Text(vm.errorMessage));
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotificationList(vm.subscriptionNotifications, vm),
                    _buildNotificationList(vm.generalNotifications, vm),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<NotificationViewModel>(
        builder: (context, vm, child) {
          if (!vm.isAdmin) return const SizedBox.shrink();
          return _buildCreateNotificationFAB();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTab(String label, int index) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        bool isSelected = _tabController.index == index;
        return Tab(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF36519E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF36519E) : Colors.grey.shade300,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications, NotificationViewModel vm) {
    if (notifications.isEmpty) {
      return const Center(child: Text('No notifications found'));
    }

    return RefreshIndicator(
      onRefresh: () => vm.fetchNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 32),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return InkWell(
            onTap: () => _showNotificationDetail(notification),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.subject,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.readFlag ? FontWeight.normal : FontWeight.bold,
                                color: const Color(0xFF1F1F1F),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('yyyy/MM/dd HH:mm').format(notification.createdDateTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateNotificationFAB() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/create-notification'),
          backgroundColor: const Color(0xFF2E3B84), // Branded blue from reference
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          icon: const Icon(Icons.add, color: Colors.white, size: 24),
          label: const Text(
            'Create notification',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }


  void _showNotificationDetail(NotificationModel notification) {
    if (!notification.readFlag) {
      context.read<NotificationViewModel>().markAsRead(notification.id);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationDetailBottomSheet(notification: notification),
    );
  }
}
