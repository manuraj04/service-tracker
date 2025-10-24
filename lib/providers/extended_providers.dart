import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_visit.dart';
import '../models/engineer.dart';
import '../models/service_report.dart';
import '../models/notification.dart' as app_notification;
import '../models/spare_part.dart';
import '../services/extended_firebase_service.dart';

// Service Visits Provider
final serviceVisitsProvider = StateNotifierProvider.family<ServiceVisitsNotifier, AsyncValue<List<ServiceVisit>>, int?>((ref, bankId) {
  return ServiceVisitsNotifier(bankId: bankId);
});

class ServiceVisitsNotifier extends StateNotifier<AsyncValue<List<ServiceVisit>>> {
  final int? bankId;
  final _firebase = ExtendedFirebaseService.instance;

  ServiceVisitsNotifier({this.bankId}) : super(const AsyncValue.loading()) {
    loadVisits();
  }

  Future<void> loadVisits() async {
    try {
      final visits = await _firebase.getServiceVisits(bankId: bankId);
      state = AsyncValue.data(visits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addVisit(ServiceVisit visit) async {
    try {
      await _firebase.createServiceVisit(visit);
      loadVisits();
    } catch (e) {
      rethrow;
    }
  }
}

// Engineers Provider
final engineersProvider = StateNotifierProvider<EngineersNotifier, AsyncValue<List<Engineer>>>((ref) {
  return EngineersNotifier();
});

class EngineersNotifier extends StateNotifier<AsyncValue<List<Engineer>>> {
  final _firebase = ExtendedFirebaseService.instance;

  EngineersNotifier() : super(const AsyncValue.loading()) {
    loadEngineers();
  }

  Future<void> loadEngineers() async {
    try {
      final engineers = await _firebase.getEngineers();
      state = AsyncValue.data(engineers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addEngineer(Engineer engineer) async {
    try {
      await _firebase.createEngineer(engineer);
      loadEngineers();
    } catch (e) {
      rethrow;
    }
  }
}

// Service Reports Provider
final serviceReportsProvider = StateNotifierProvider.family<ServiceReportsNotifier, AsyncValue<List<ServiceReport>>, String?>((ref, visitId) {
  return ServiceReportsNotifier(visitId: visitId);
});

class ServiceReportsNotifier extends StateNotifier<AsyncValue<List<ServiceReport>>> {
  final String? visitId;
  final _firebase = ExtendedFirebaseService.instance;

  ServiceReportsNotifier({this.visitId}) : super(const AsyncValue.loading()) {
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      final reports = await _firebase.getServiceReports(visitId: visitId);
      state = AsyncValue.data(reports);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addReport(ServiceReport report) async {
    try {
      await _firebase.createServiceReport(report);
      loadReports();
    } catch (e) {
      rethrow;
    }
  }
}

// Notifications Provider
final notificationsProvider = StateNotifierProvider.family<NotificationsNotifier, AsyncValue<List<app_notification.Notification>>, String>((ref, recipientId) {
  return NotificationsNotifier(recipientId: recipientId);
});

class NotificationsNotifier extends StateNotifier<AsyncValue<List<app_notification.Notification>>> {
  final String recipientId;
  final _firebase = ExtendedFirebaseService.instance;

  NotificationsNotifier({required this.recipientId}) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final notifications = await _firebase.getNotifications(recipientId);
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firebase.markNotificationAsRead(notificationId);
      loadNotifications();
    } catch (e) {
      rethrow;
    }
  }
}

// Spare Parts Provider
final sparePartsProvider = StateNotifierProvider<SparePartsNotifier, AsyncValue<List<SparePart>>>((ref) {
  return SparePartsNotifier();
});

class SparePartsNotifier extends StateNotifier<AsyncValue<List<SparePart>>> {
  final _firebase = ExtendedFirebaseService.instance;

  SparePartsNotifier() : super(const AsyncValue.loading()) {
    loadSpareParts();
  }

  Future<void> loadSpareParts() async {
    try {
      final parts = await _firebase.getSpareParts();
      state = AsyncValue.data(parts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSparePart(SparePart part) async {
    try {
      await _firebase.createSparePart(part);
      loadSpareParts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStock(String partId, int newStock) async {
    try {
      await _firebase.updateSparePartStock(partId, newStock);
      loadSpareParts();
    } catch (e) {
      rethrow;
    }
  }
}