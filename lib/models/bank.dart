class BankEntry {
  final int? id;
  final String bankName;
  final String branchName;
  final String? branchCode;
  final String? ifscCode;
  final String? contactName;
  final String? contactPhone;
  final String? address;

  BankEntry({
    this.id,
    required this.bankName,
    required this.branchName,
    this.branchCode,
    this.ifscCode,
    this.contactName,
    this.contactPhone,
    this.address,
  });

  BankEntry copyWith({
    int? id,
    String? bankName,
    String? branchName,
    String? branchCode,
    String? ifscCode,
    String? contactName,
    String? contactPhone,
    String? address,
  }) {
    return BankEntry(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      branchCode: branchCode ?? this.branchCode,
      ifscCode: ifscCode ?? this.ifscCode,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
    );
  }

  factory BankEntry.fromMap(Map<String, dynamic> map) {
    return BankEntry(
      id: map['id'] as int?,
      bankName: map['bankName'] as String? ?? '',
      branchName: map['branchName'] as String? ?? '',
      branchCode: map['branchCode'] as String?,
      ifscCode: map['ifscCode'] as String?,
      contactName: map['contactName'] as String?,
      contactPhone: map['contactPhone'] as String?,
      address: map['address'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'bankName': bankName,
      'branchName': branchName,
      'branchCode': branchCode,
      'ifscCode': ifscCode,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'address': address,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
