class BankBranchDetails {
  final String bankName;
  final String branchName;
  final String branchCode;
  final String? ifscCode;
  final String? contactName;
  final String? contactPhone;
  final String? address;
  
  const BankBranchDetails({
    required this.bankName,
    required this.branchName,
    required this.branchCode,
    this.ifscCode,
    this.contactName,
    this.contactPhone,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'branchName': branchName,
      'branchCode': branchCode,
      'ifscCode': ifscCode,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'address': address,
    };
  }

  factory BankBranchDetails.fromMap(Map<String, dynamic> map) {
    return BankBranchDetails(
      bankName: map['bankName'] as String,
      branchName: map['branchName'] as String,
      branchCode: map['branchCode'] as String,
      ifscCode: map['ifscCode'] as String?,
      contactName: map['contactName'] as String?,
      contactPhone: map['contactPhone'] as String?,
      address: map['address'] as String?,
    );
  }
}