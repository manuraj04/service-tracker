class Engineer {
  final String? id;
  final String name;
  final String phone;
  final String email;
  final String assignedArea;
  final List<String> specializations;
  final bool activeStatus;

  Engineer({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.assignedArea,
    required this.specializations,
    this.activeStatus = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'assignedArea': assignedArea,
      'specializations': specializations,
      'activeStatus': activeStatus,
    };
  }

  factory Engineer.fromMap(Map<String, dynamic> map, String id) {
    return Engineer(
      id: id,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      assignedArea: map['assignedArea'] as String,
      specializations: List<String>.from(map['specializations']),
      activeStatus: map['activeStatus'] as bool,
    );
  }
}