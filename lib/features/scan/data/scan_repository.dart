import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/scan_history_item.dart';

class ScanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUid => _auth.currentUser?.uid;

  CollectionReference _historyCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('history');

  Future<void> saveScan(ScanHistoryItem item) async {
    final uid = _currentUid;
    if (uid == null) return;

    try {
      // Create a unique ID or use timestamp
      final docRef = _historyCollection(uid).doc();
      final map = item.toMap();
      map['timestamp'] = FieldValue.serverTimestamp();
      await docRef.set(map);

      // Optional: Prune locally or via cloud function to keep last 20.
      // For now, we'll keep the full history on Firestore as it's more "Production Ready".
    } catch (e) {
      debugPrint('❌ ScanRepository save Error: $e');
    }
  }

  Future<List<ScanHistoryItem>> getHistory() async {
    final uid = _currentUid;
    if (uid == null) return [];

    try {
      final snapshot = await _historyCollection(uid)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();
      
      return snapshot.docs
          .map((doc) => ScanHistoryItem.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ ScanRepository fetch Error: $e');
      return [];
    }
  }

  Future<void> clearHistory() async {
    final uid = _currentUid;
    if (uid == null) return;

    try {
      final snapshot = await _historyCollection(uid).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
       debugPrint('❌ ScanRepository clear Error: $e');
    }
  }
}
