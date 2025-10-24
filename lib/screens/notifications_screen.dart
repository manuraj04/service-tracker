import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart' as app_notification;
import '../providers/extended_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  final String userId;

  const NotificationsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => _markAllAsRead(context, ref),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) => notifications.isEmpty
            ? const Center(child: Text('No notifications'))
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isUnread = notification.readAt == null;
                  
                  return ListTile(
                    leading: Icon(
                      _getNotificationIcon(notification.type),
                      color: isUnread ? Theme.of(context).primaryColor : null,
                    ),
                    title: Text(
                      notification.message,
                      style: TextStyle(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      _formatDateTime(notification.createdAt),
                      style: TextStyle(
                        color: isUnread
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ),
                    onTap: () {
                      if (isUnread) {
                        ref
                            .read(notificationsProvider(userId).notifier)
                            .markAsRead(notification.id!);
                      }
                      _showNotificationDetails(context, notification);
                    },
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'visit_reminder':
        return Icons.calendar_today;
      case 'emergency':
        return Icons.warning;
      case 'report_pending':
        return Icons.description;
      default:
        return Icons.notifications;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return dateTime.toString().split(' ')[0];
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showNotificationDetails(
      BuildContext context, app_notification.Notification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getNotificationTitle(notification.type)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 8),
            Text(
              'Received: ${notification.createdAt.toString()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (notification.readAt != null)
              Text(
                'Read: ${notification.readAt.toString()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (notification.type == 'visit_reminder')
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to visit details
                Navigator.pop(context);
              },
              child: const Text('View Visit'),
            ),
        ],
      ),
    );
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'visit_reminder':
        return 'Upcoming Visit';
      case 'emergency':
        return 'Emergency Alert';
      case 'report_pending':
        return 'Report Due';
      default:
        return 'Notification';
    }
  }

  void _markAllAsRead(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark All as Read'),
        content: const Text('Are you sure you want to mark all notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement mark all as read
              Navigator.pop(context);
            },
            child: const Text('Mark All'),
          ),
        ],
      ),
    );
  }
}