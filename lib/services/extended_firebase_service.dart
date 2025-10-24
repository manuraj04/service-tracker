import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_visit.dart';
import '../models/service_report.dart';
import '../models/engineer.dart';
import '../models/notification.dart';
import '../models/spare_part.dart';

class ExtendedFirebaseService {
  static final ExtendedFirebaseService instance = ExtendedFirebaseService._();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ExtendedFirebaseService._();

  // Service Visits
  Future<void> createServiceVisit(ServiceVisit visit) async {
    final doc = _firestore.collection('service_visits').doc();
    await doc.set(visit.toMap());
  }

  Future<List<ServiceVisit>> getServiceVisits({int? bankId, int? machineId}) async {
    Query query = _firestore.collection('service_visits');
    if (bankId != null) {
      query = query.where('bankId', isEqualTo: bankId);
    }
    if (machineId != null) {
      query = query.where('machineId', isEqualTo: machineId);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ServiceVisit.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  // Engineers
  Future<void> createEngineer(Engineer engineer) async {
    final doc = _firestore.collection('engineers').doc();
    await doc.set(engineer.toMap());
  }

  Future<List<Engineer>> getEngineers({String? area}) async {
    Query query = _firestore.collection('engineers');
    if (area != null) {
      query = query.where('assignedArea', isEqualTo: area);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Engineer.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  // Service Reports
  Future<void> createServiceReport(ServiceReport report) async {
    final doc = _firestore.collection('service_reports').doc();
    await doc.set(report.toMap());
  }

  Future<List<ServiceReport>> getServiceReports({String? visitId, int? machineId}) async {
    Query query = _firestore.collection('service_reports');
    if (visitId != null) {
      query = query.where('visitId', isEqualTo: visitId);
    }
    if (machineId != null) {
      query = query.where('machineId', isEqualTo: machineId);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ServiceReport.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  // Notifications
  Future<void> createNotification(Notification notification) async {
    final doc = _firestore.collection('notifications').doc();
    await doc.set(notification.toMap());
  }

  Future<List<Notification>> getNotifications(String recipientId) async {
    final snapshot = await _firestore.collection('notifications')
        .where('recipientId', isEqualTo: recipientId)
        .orderBy('createdAt', descending: true)
        .get();
    
        return snapshot.docs.map((doc) => Notification.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'readAt': DateTime.now().millisecondsSinceEpoch,
      'status': 'read'
    });
  }

  // Spare Parts
  Future<void> createSparePart(SparePart part) async {
    final doc = _firestore.collection('spare_parts_inventory').doc();
    await doc.set(part.toMap());
  }

  Future<List<SparePart>> getSpareParts({String? machineType}) async {
    Query query = _firestore.collection('spare_parts_inventory');
    if (machineType != null) {
      query = query.where('machineTypes', arrayContains: machineType);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => SparePart.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<void> updateSparePartStock(String partId, int newStock) async {
    await _firestore.collection('spare_parts_inventory').doc(partId).update({
      'currentStock': newStock,
      'lastRestockDate': DateTime.now().millisecondsSinceEpoch
    });
  }
}