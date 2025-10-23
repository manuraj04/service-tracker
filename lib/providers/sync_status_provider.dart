import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_manager.dart';

class SyncStatus {
  final bool isActive;
  final String message;
  final bool hasError;
  final int pendingChanges;
  final String? errorMessage;

  const SyncStatus({
    required this.isActive,
    required this.message,
    this.hasError = false,
    this.pendingChanges = 0,
    this.errorMessage,
  });

  factory SyncStatus.initial() {
    return const SyncStatus(
      isActive: false,
      message: 'Sync Ready',
    );
  }

  SyncStatus copyWith({
    bool? isActive,
    String? message,
    bool? hasError,
    int? pendingChanges,
    String? errorMessage,
  }) {
    return SyncStatus(
      isActive: isActive ?? this.isActive,
      message: message ?? this.message,
      hasError: hasError ?? this.hasError,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final syncStatusProvider = StateNotifierProvider<SyncStatusNotifier, SyncStatus>((ref) {
  return SyncStatusNotifier();
});

class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  SyncStatusNotifier() : super(SyncStatus.initial()) {
    _initialize();
  }

  void _initialize() {
    SyncManager.instance.addListener(_handleSyncUpdate);
  }

  void _handleSyncUpdate(SyncManagerEvent event) {
    switch (event.type) {
      case SyncEventType.started:
        state = state.copyWith(
          isActive: true,
          message: 'Syncing...',
          hasError: false,
        );
        break;
      case SyncEventType.completed:
        state = state.copyWith(
          isActive: false,
          message: 'Sync Complete',
          hasError: false,
          pendingChanges: 0,
        );
        break;
      case SyncEventType.error:
        state = state.copyWith(
          isActive: false,
          message: 'Sync Error',
          hasError: true,
          errorMessage: event.message,
        );
        break;
      case SyncEventType.pendingChanges:
        state = state.copyWith(
          pendingChanges: event.pendingChanges ?? 0,
          message: event.pendingChanges == 0 
              ? 'Sync Ready' 
              : 'Changes Pending',
        );
        break;
    }
  }

  @override
  void dispose() {
    SyncManager.instance.removeListener(_handleSyncUpdate);
    super.dispose();
  }
}