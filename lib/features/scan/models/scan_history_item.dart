import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      // Default to ISO string, but repository will override with FieldValue.serverTimestamp()
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScanHistoryItem.fromMap(Map<String, dynamic> map) {
    DateTime dt;
    final ts = map['timestamp'];
    if (ts is Timestamp) {
      dt = ts.toDate();
    } else if (ts is String) {
      dt = DateTime.parse(ts);
    } else {
      dt = DateTime.now();
    }

    return ScanHistoryItem(
      barcode: map['barcode'] ?? '',
      productName: map['productName'] ?? '',
      verdict: map['verdict'] ?? '',
      timestamp: dt,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScanHistoryItem.fromJson(String source) =>
      ScanHistoryItem.fromMap(json.decode(source));
}
