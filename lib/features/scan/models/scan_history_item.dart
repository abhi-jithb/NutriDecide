import 'dart:convert';
import 'nutrition_data.dart';

class ScanHistoryItem {
  final String barcode;
  final String productName;
  final String verdict;
  final DateTime timestamp;

  ScanHistoryItem({
    required this.barcode,
    required this.productName,
    required this.verdict,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'productName': productName,
      'verdict': verdict,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScanHistoryItem.fromMap(Map<String, dynamic> map) {
    return ScanHistoryItem(
      barcode: map['barcode'] ?? '',
      productName: map['productName'] ?? '',
      verdict: map['verdict'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ScanHistoryItem.fromJson(String source) =>
      ScanHistoryItem.fromMap(json.decode(source));
}
