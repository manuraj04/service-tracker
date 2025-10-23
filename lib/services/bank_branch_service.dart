import 'dart:convert';
import 'package:http/http.dart' as http;

class BankBranchService {
  static const String _baseUrl = 'https://ifsc.razorpay.com/';
  
  /// Fetch branch details by IFSC code
  static Future<Map<String, dynamic>?> getBranchDetailsByIFSC(String ifsc) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl$ifsc'));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching branch details: $e');
    }
    return null;
  }

  /// Search branches by bank name and city/state
  static Future<List<Map<String, dynamic>>> searchBranches(String bankName, String location) async {
    // Note: This is a placeholder. In production, you would:
    // 1. Use a proper bank branch API
    // 2. Implement pagination
    // 3. Add proper error handling
    // 4. Cache results
    
    // For now return empty list - implement actual API integration later
    return [];
  }

  /// Format branch details for display
  static String formatBranchCode(String bankName, String branchCode) {
    // Format based on bank's convention
    switch (bankName.toUpperCase()) {
      case 'STATE BANK OF INDIA':
        return 'SBI$branchCode';
      case 'PUNJAB NATIONAL BANK':
        return 'PNB$branchCode';
      default:
        return branchCode;
    }
  }
}