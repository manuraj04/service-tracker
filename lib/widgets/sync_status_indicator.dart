import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';
import '../services/sync_manager.dart';

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFirebaseConnected = ref.watch(firebaseStatusProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    return PopupMenuButton<void>(
      icon: Badge(
        backgroundColor: _getStatusColor(isFirebaseConnected, syncStatus),
        label: const Icon(
          Icons.sync,
          color: Colors.white,
          size: 20,
        ),
      ),
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sync Status',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _buildStatusRow(
                context,
                'Firebase Connection',
                isFirebaseConnected,
                Icons.cloud,
              ),
              const SizedBox(height: 4),
              _buildStatusRow(
                context,
                syncStatus.message,
                syncStatus.isActive,
                Icons.sync,
              ),
              if (syncStatus.pendingChanges > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${syncStatus.pendingChanges} changes pending',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    bool isActive,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isActive ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isActive ? Colors.green : Colors.grey,
              ),
        ),
      ],
    );
  }

  Color _getStatusColor(bool isFirebaseConnected, SyncStatus status) {
    if (!isFirebaseConnected) return Colors.grey;
    if (status.hasError) return Colors.red;
    if (status.pendingChanges > 0) return Colors.orange;
    if (status.isActive) return Colors.blue;
    return Colors.green;
  }
}