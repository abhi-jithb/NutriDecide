import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManualFoodEntryScreen extends StatefulWidget {
  final String barcode;

  const ManualFoodEntryScreen({super.key, required this.barcode});

  @override
  State<ManualFoodEntryScreen> createState() => _ManualFoodEntryScreenState();
}

class _ManualFoodEntryScreenState extends State<ManualFoodEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sugarController = TextEditingController();
  final _caloriesController = TextEditingController();
  String _selectedCategory = 'Snacks';
  bool _isSaving = false;

  final List<String> _categories = [
    'Snacks',
    'Beverages',
    'Dairy',
    'Grains',
    'Proteins',
    'Fruits',
    'Vegetables',
    'Desserts',
    'Other'
  ];

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('User not logged in');

      final firestore = FirebaseFirestore.instance;

      // 🔴 CHECK 1: Duplicate barcode guard
      final pendingDoc = await firestore.collection('pending_products').doc(widget.barcode).get();
      if (pendingDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This product has already been submitted and is awaiting review.')),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      final globalDoc = await firestore.collection('global_products').doc(widget.barcode).get();
      if (globalDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This product already exists in the global database.')),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      final productData = {
        'barcode': widget.barcode,
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'sugar': double.parse(_sugarController.text),
        'calories': _caloriesController.text.isNotEmpty ? double.parse(_caloriesController.text) : null,
        'createdBy': uid,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      };

      final batch = firestore.batch();

      // 1. Save to global pending_products for Admin Review
      final pendingRef = firestore.collection('pending_products').doc(widget.barcode);
      batch.set(pendingRef, productData);

      // 2. Save to user's private custom_products for immediate access
      final customRef = firestore
          .collection('users')
          .doc(uid)
          .collection('custom_products')
          .doc(widget.barcode);
      batch.set(customRef, productData);

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product submitted for review!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product Manually'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Barcode: ${widget.barcode}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_basket),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sugarController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Sugar (g per 100g)*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.water_drop),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final val = double.tryParse(value);
                  if (val == null) return 'Invalid number';
                  if (val < 0 || val > 100) return 'Must be 0-100g';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Calories (kcal per 100g)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.bolt),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('SUBMIT PRODUCT', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
