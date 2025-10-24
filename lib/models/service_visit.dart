class ServiceVisit {
  final String? id;
  final int machineId;
  final int bankId;
  final DateTime visitDate;
  final String engineerId;
  final String serviceType;
  final List<String> issues;
  final List<String> actions;
  final DateTime nextScheduledDate;
  final String? signatureUrl;
  final String? csrDocumentUrl;

  ServiceVisit({
    this.id,
    required this.machineId,
    required this.bankId,
    required this.visitDate,
    required this.engineerId,
    required this.serviceType,
    required this.issues,
    required this.actions,
    required this.nextScheduledDate,
    this.signatureUrl,
    this.csrDocumentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'machineId': machineId,
      'bankId': bankId,
      'visitDate': visitDate.millisecondsSinceEpoch,
      'engineerId': engineerId,
      'serviceType': serviceType,
      'issues': issues,
      'actions': actions,
      'nextScheduledDate': nextScheduledDate.millisecondsSinceEpoch,
      'signatureUrl': signatureUrl,
      'csrDocumentUrl': csrDocumentUrl,
    };
  }

  factory ServiceVisit.fromMap(Map<String, dynamic> map, String id) {
    return ServiceVisit(
      id: id,
      machineId: map['machineId'] as int,
      bankId: map['bankId'] as int,
      visitDate: DateTime.fromMillisecondsSinceEpoch(map['visitDate'] as int),
      engineerId: map['engineerId'] as String,
      serviceType: map['serviceType'] as String,
      issues: List<String>.from(map['issues']),
      actions: List<String>.from(map['actions']),
      nextScheduledDate: DateTime.fromMillisecondsSinceEpoch(map['nextScheduledDate'] as int),
      signatureUrl: map['signatureUrl'] as String?,
      csrDocumentUrl: map['csrDocumentUrl'] as String?,
    );
  }
}