class Notification {
  final String? id;
  final String recipientId;
  final String type;
  final String message;
  final DateTime createdAt;
  final DateTime? readAt;
  final String status;

  Notification({
    this.id,
    required this.recipientId,
    required this.type,
    required this.message,
    required this.createdAt,
    this.readAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'recipientId': recipientId,
      'type': type,
      'message': message,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'readAt': readAt?.millisecondsSinceEpoch,
      'status': status,
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map, String id) {
    return Notification(
      id: id,
      recipientId: map['recipientId'] as String,
      type: map['type'] as String,
      message: map['message'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      readAt: map['readAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['readAt'] as int) : null,
      status: map['status'] as String,
    );
  }
}