class BankData {
  final String name;
  final String code;
  final String logo;
  final List<String> commonBranches;
  final String category; // Public, Private, Regional Rural, etc.
  final String headquarters;
  final List<String> searchTerms;

  BankData({
    required this.name,
    required this.code,
    required this.logo,
    required this.commonBranches,
    required this.category,
    required this.headquarters,
    List<String>? searchTerms,
  }) : searchTerms = searchTerms ?? 
       [name, code, ...commonBranches, category, headquarters];
  
  bool matchesSearch(String query) {
    final lowercaseQuery = query.toLowerCase();
    return searchTerms.any((term) => 
      term.toLowerCase().contains(lowercaseQuery));
  }
}

final List<BankData> banks = [
  BankData(
    name: 'State Bank of India',
    code: 'SBI',
    logo: 'assets/bank_logos/sbi.png',
    category: 'Public Sector Bank',
    headquarters: 'Mumbai',
    commonBranches: [
      'Patna Main Branch',
      'Bailey Road',
      'Exhibition Road',
      'Boring Road',
      'Danapur',
      'Kankarbagh',
      'Rajendra Nagar',
      'Gandhi Maidan',
      'Frazer Road',
    ],
    searchTerms: [
      'SBI', 'State Bank', 'State Bank of India',
      'PSU Bank', 'Public Sector Bank', 'Government Bank',
    ],
  ),
  BankData(
    name: 'Punjab National Bank',
    code: 'PNB',
    logo: 'assets/bank_logos/pnb.png',
    category: 'Public Sector Bank',
    headquarters: 'New Delhi',
    commonBranches: [
      'Patna Main Branch',
      'Exhibition Road',
      'Boring Road',
      'Kankarbagh',
      'Rajendra Nagar',
      'Fraser Road',
      'Gandhi Maidan',
      'Patliputra Colony',
      'Raja Bazar',
    ],
    searchTerms: [
      'PNB', 'Punjab National Bank', 'Punjab Bank',
      'PSU Bank', 'Public Sector Bank', 'Delhi Bank',
    ],
  ),
  BankData(
    name: 'Bank of Baroda',
    code: 'BOB',
    logo: 'assets/bank_logos/bob.png',
    category: 'Public Sector Bank',
    headquarters: 'Vadodara',
    commonBranches: [
      'Patna Main Branch',
      'Bailey Road',
      'Frazer Road',
      'Boring Road',
      'Fraser Road',
      'Boring Road',
      'Patliputra',
      'Saguna More',
    ],
    searchTerms: [
      'BOB', 'Bank of Baroda', 'Baroda Bank',
      'PSU Bank', 'Public Sector Bank', 'Vadodara',
    ],
  ),
  BankData(
    name: 'HDFC Bank',
    code: 'HDFC',
    logo: 'assets/bank_logos/hdfc.png',
    category: 'Private Sector Bank',
    headquarters: 'Mumbai',
    commonBranches: [
      'Patna Main',
      'Exhibition Road',
      'Bailey Road',
      'Boring Road',
      'Dak Bunglow Road',
    ],
    searchTerms: [
      'HDFC', 'HDFC Bank', 'Housing Development Finance Corporation',
      'Private Bank', 'Private Sector Bank', 'Mumbai',
    ],
  ),
  BankData(
    name: 'ICICI Bank',
    code: 'ICICI',
    logo: 'assets/bank_logos/icici.png',
    category: 'Private Sector Bank',
    headquarters: 'Mumbai',
    commonBranches: [
      'Fraser Road',
      'Exhibition Road',
      'Boring Road',
      'Bailey Road',
    ],
    searchTerms: [
      'ICICI', 'ICICI Bank', 'Industrial Credit and Investment Corporation',
      'Private Bank', 'Private Sector Bank', 'Mumbai',
    ],
  ),
  BankData(
    name: 'State Cooperative Bank',
    code: 'SCB',
    logo: 'assets/bank_logos/scb.png',
    category: 'Cooperative Bank',
    headquarters: 'Patna',
    commonBranches: [
      'Main Branch Patna',
      'Buddha Colony',
      'Patliputra Colony',
    ],
    searchTerms: [
      'SCB', 'State Cooperative Bank', 'Cooperative Bank',
      'State Bank', 'Regional Bank', 'Patna',
    ],
  ),
  BankData(
    name: 'North Regional Gramin Bank',
    code: 'NRGB',
    logo: 'assets/bank_logos/nrgb.png',
    category: 'Regional Rural Bank',
    headquarters: 'Muzaffarpur',
    commonBranches: [
      'Muzaffarpur Main',
      'Sitamarhi',
      'Madhubani',
      'Darbhanga',
    ],
    searchTerms: [
      'NRGB', 'North Regional', 'Gramin Bank',
      'Rural Bank', 'Regional Bank', 'Muzaffarpur',
    ],
  ),
  BankData(
    name: 'Central Regional Gramin Bank',
    code: 'CRGB',
    logo: 'assets/bank_logos/crgb.png',
    category: 'Regional Rural Bank',
    headquarters: 'Patna',
    commonBranches: [
      'Patna Main',
      'Gaya',
      'Nalanda',
      'Bhojpur',
    ],
    searchTerms: [
      'CRGB', 'Central Regional', 'Gramin Bank',
      'Rural Bank', 'Regional Bank', 'Central',
    ],
  ),
  BankData(
    name: 'Central Bank of India',
    code: 'CBI',
    logo: 'assets/bank_logos/cbi.png', 
    category: 'Public Sector Bank',
    headquarters: 'Mumbai',
    commonBranches: [
      'Patna Main Branch',
      'Gandhi Maidan',
      'Boring Road', 
      'Rajendra Nagar',
      'Exhibition Road',
      'Patna Main',
      'Mithapur',
    ],
    searchTerms: [
      'CBI', 'Central Bank', 'Central Bank of India',
      'PSU Bank', 'Public Bank', 'Nationalized Bank',
    ],
  ),
  BankData(
    name: 'Union Bank of India',
    code: 'UBI', 
    logo: 'assets/bank_logos/ubi.png',
    category: 'Public Sector Bank', 
    headquarters: 'Mumbai',
    commonBranches: [
      'Main Branch Patna',
      'Exhibition Road',
      'Kankarbagh',
      'Boring Road',
      'Raja Bazar',
      'Boring Canal Road',
      'Bailey Road',
    ],
    searchTerms: [
      'UBI', 'Union Bank', 'Union Bank of India',
      'PSU Bank', 'Public Bank', 'Mumbai Bank',
    ],
  ),
  BankData(
    name: 'Bank of India',
    code: 'BOI',
    logo: 'assets/bank_logos/boi.png',
    category: 'Public Sector Bank',
    headquarters: 'Mumbai',
    commonBranches: [
      'Gandhi Maidan',
      'Patna City',
      'Boring Canal Road',
      'Kurji',
    ],
    searchTerms: [
      'BOI', 'Bank of India', 'India Bank',
      'PSU Bank', 'Public Bank', 'Mumbai Bank',
    ],
  ),
  BankData(
    name: 'Canara Bank',
    code: 'CNB',
    logo: 'assets/bank_logos/canara.png',
    category: 'Public Sector Bank',
    headquarters: 'Bengaluru',
    commonBranches: [
      'Fraser Road',
      'Patliputra Colony',
      'Kankarbagh',
      'Boring Road',
    ],
    searchTerms: [
      'CNB', 'Canara Bank', 'Kannada Bank',
      'PSU Bank', 'Public Bank', 'Bengaluru Bank',
    ],
  ),
  BankData(
    name: 'Indian Bank',
    code: 'INB',
    logo: 'assets/bank_logos/indian.png',
    category: 'Public Sector Bank',
    headquarters: 'Chennai',
    commonBranches: [
      'Exhibition Road',
      'Gandhi Maidan',
      'Patna City',
      'Rajendra Nagar',
    ],
    searchTerms: [
      'INB', 'Indian Bank', 'India Bank',
      'PSU Bank', 'Public Bank', 'Chennai Bank',
    ],
  ),
];