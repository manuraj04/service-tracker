class ServiceReport {
  final String? id;
  final String visitId;
  final int machineId;
  final DateTime reportDate;
  final String machineStatus;
  final List<String> partReplaced;
  final String recommendations;
  final List<String> photosUrls;

  ServiceReport({
    this.id,
    required this.visitId,
    required this.machineId,
    required this.reportDate,
    required this.machineStatus,
    required this.partReplaced,
    required this.recommendations,
    required this.photosUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      'visitId': visitId,
      'machineId': machineId,
      'reportDate': reportDate.millisecondsSinceEpoch,
      'machineStatus': machineStatus,
      'partReplaced': partReplaced,
      'recommendations': recommendations,
      'photosUrls': photosUrls,
    };
  }

  factory ServiceReport.fromMap(Map<String, dynamic> map, String id) {
    return ServiceReport(
      id: id,
      visitId: map['visitId'] as String,
      machineId: map['machineId'] as int,
      reportDate: DateTime.fromMillisecondsSinceEpoch(map['reportDate'] as int),
      machineStatus: map['machineStatus'] as String,
      partReplaced: List<String>.from(map['partReplaced']),
      recommendations: map['recommendations'] as String,
      photosUrls: List<String>.from(map['photosUrls']),
    );
  }
}