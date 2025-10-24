class SparePart {
  final String? id;
  final String partNumber;
  final String name;
  final List<String> machineTypes;
  final int currentStock;
  final int minThreshold;
  final DateTime lastRestockDate;

  SparePart({
    this.id,
    required this.partNumber,
    required this.name,
    required this.machineTypes,
    required this.currentStock,
    required this.minThreshold,
    required this.lastRestockDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'partNumber': partNumber,
      'name': name,
      'machineTypes': machineTypes,
      'currentStock': currentStock,
      'minThreshold': minThreshold,
      'lastRestockDate': lastRestockDate.millisecondsSinceEpoch,
    };
  }

  factory SparePart.fromMap(Map<String, dynamic> map, String id) {
    return SparePart(
      id: id,
      partNumber: map['partNumber'] as String,
      name: map['name'] as String,
      machineTypes: List<String>.from(map['machineTypes']),
      currentStock: map['currentStock'] as int,
      minThreshold: map['minThreshold'] as int,
      lastRestockDate: DateTime.fromMillisecondsSinceEpoch(map['lastRestockDate'] as int),
    );
  }
}