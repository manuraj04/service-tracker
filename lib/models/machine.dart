class Machine {
  final int? id;
  final int bankId;
  final String machineType;
  final String serialNumber;
  final DateTime lastVisitDate;
  final DateTime nextVisitDate;
  final DateTime installationDate;
  final bool isCsrCollected;

  Machine({
    this.id,
    required this.bankId,
    required this.machineType,
    required this.serialNumber,
    required this.lastVisitDate,
    required this.nextVisitDate,
    required this.installationDate,
    required this.isCsrCollected,
  });

  Machine copyWith({
    int? id,
    int? bankId,
    String? machineType,
    String? serialNumber,
    DateTime? lastVisitDate,
    DateTime? nextVisitDate,
    DateTime? installationDate,
    bool? isCsrCollected,
  }) {
    return Machine(
      id: id ?? this.id,
      bankId: bankId ?? this.bankId,
      machineType: machineType ?? this.machineType,
      serialNumber: serialNumber ?? this.serialNumber,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      nextVisitDate: nextVisitDate ?? this.nextVisitDate,
      installationDate: installationDate ?? this.installationDate,
      isCsrCollected: isCsrCollected ?? this.isCsrCollected,
    );
  }

  factory Machine.fromMap(Map<String, dynamic> map) {
    return Machine(
      id: map['id'] as int?,
      bankId: map['bankId'] as int,
      machineType: map['machineType'] as String? ?? '',
      serialNumber: map['serialNumber'] as String? ?? '',
      lastVisitDate: DateTime.fromMillisecondsSinceEpoch(map['lastVisitDate'] as int),
      nextVisitDate: DateTime.fromMillisecondsSinceEpoch(map['nextVisitDate'] as int),
      installationDate: DateTime.fromMillisecondsSinceEpoch(map['installationDate'] as int),
      isCsrCollected: (map['isCsrCollected'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'bankId': bankId,
      'machineType': machineType,
      'serialNumber': serialNumber,
      'lastVisitDate': lastVisitDate.millisecondsSinceEpoch,
      'nextVisitDate': nextVisitDate.millisecondsSinceEpoch,
      'installationDate': installationDate.millisecondsSinceEpoch,
      'isCsrCollected': isCsrCollected ? 1 : 0,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
