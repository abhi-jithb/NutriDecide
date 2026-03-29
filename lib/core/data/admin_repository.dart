import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../features/profile/models/user_profile.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final AdminRepository _instance = AdminRepository._internal();
  factory AdminRepository() => _instance;
  AdminRepository._internal();

  /// Streams all pending products for the admin panel.
  Stream<List<Map<String, dynamic>>> getPendingProducts() {
    return _firestore
        .collection('pending_products')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Approves a product: Reads FULL data from pending_products, copies to global_products.
  Future<void> approveProduct(Map<String, dynamic> productData, String adminId) async {
    final barcode = productData['barcode']?.toString();
    if (barcode == null) throw Exception('Barcode missing');

    // 🔴 SAFETY: Read fresh data from Firestore to avoid stale/partial copies
    final pendingRef = _firestore.collection('pending_products').doc(barcode);
    final pendingSnap = await pendingRef.get();
    if (!pendingSnap.exists) throw Exception('Pending product no longer exists');

    final freshData = pendingSnap.data()!;
    freshData['status'] = 'approved';
    freshData['approvedBy'] = adminId;
    freshData['approvedAt'] = FieldValue.serverTimestamp();

    final batch = _firestore.batch();
    batch.set(_firestore.collection('global_products').doc(barcode), freshData);
    batch.delete(pendingRef);
    await batch.commit();
  }

  /// Rejects a product: Marks it as rejected in pending_products or deletes it.
  /// Using delete as per prompt option.
  Future<void> rejectProduct(String barcode) async {
    await _firestore.collection('pending_products').doc(barcode).delete();
  }

  /// Streams all users for management.
  Stream<List<UserProfile>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserProfile.fromMap(doc.data())).toList();
    });
  }

  /// Checks if a user is an admin.
  Future<bool> isAdmin(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return false;
      final data = doc.data();
      return data != null && data['role'] == 'admin';
    } catch (e) {
      debugPrint('❌ AdminRepository isAdmin Error: $e');
      return false;
    }
  }
}
