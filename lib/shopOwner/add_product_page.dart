import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:ecommerce_app/utils/env.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameC = TextEditingController();
  final TextEditingController priceC = TextEditingController();
  final TextEditingController descC = TextEditingController();
  final TextEditingController stockC = TextEditingController(text: '0');
  final TextEditingController discountC = TextEditingController(text: '0');

  String? selectedCategory;
  List<String> categories = [];

  List<File> newPickedFiles = [];
  List<String> existingImageUrls = []; // initially empty for add
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final snap = await FirebaseFirestore.instance.collection('categories').orderBy('name').get();
    categories = snap.docs.map((d) => (d.data()['name'] ?? '').toString()).where((s) => s.isNotEmpty).toList();
    if (mounted) setState(() {});
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? picks = await picker.pickMultiImage();
    if (picks == null || picks.isEmpty) return;
    setState(() {
      newPickedFiles.addAll(picks.map((x) => File(x.path)));
    });
  }

  Future<String?> _uploadToCloudinary(File file) async {
    try {
      final uploadUrl = 'https://api.cloudinary.com/v1_1/${Env.cloudName}/image/upload';
      final req = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      req.fields['upload_preset'] = Env.uploadPreset;
      req.files.add(await http.MultipartFile.fromPath('file', file.path));
      final streamed = await req.send();
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode == 200) {
        final map = jsonDecode(body);
        return map['secure_url'] as String?;
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
    }
    return null;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (newPickedFiles.isEmpty && existingImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one image')));
      return;
    }

    setState(() => loading = true);

    List<String> uploadedUrls = [];
    for (final f in newPickedFiles) {
      final url = await _uploadToCloudinary(f);
      if (url != null) uploadedUrls.add(url);
    }
    final allImages = [...existingImageUrls, ...uploadedUrls];

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final shopId = userDoc.data()?['shopId'] ?? '';

      final productDoc = {
        'shopId': shopId,
        'name': nameC.text.trim(),
        'price': double.tryParse(priceC.text.trim()) ?? 0.0,
        'description': descC.text.trim(),
        'images': allImages,
        'category': selectedCategory,
        'stock': int.tryParse(stockC.text.trim()) ?? 0,
        'discount': double.tryParse(discountC.text.trim()) ?? 0.0,
        'createdAt': DateTime.now(),
        'disabled': false,
      };

      await FirebaseFirestore.instance.collection('products').add(productDoc);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _buildImagePreviews() {
    final previews = <Widget>[];

    for (int i = 0; i < existingImageUrls.length; i++) {
      final url = existingImageUrls[i];
      previews.add(Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  existingImageUrls.removeAt(i);
                });
              },
              child: Container(
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          )
        ],
      ));
    }

    for (int i = 0; i < newPickedFiles.length; i++) {
      final f = newPickedFiles[i];
      previews.add(Stack(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(f, width: 100, height: 100, fit: BoxFit.cover)),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  newPickedFiles.removeAt(i);
                });
              },
              child: Container(
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          )
        ],
      ));
    }

    previews.add(GestureDetector(
      onTap: pickImages,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Icon(Icons.add_a_photo)),
      ),
    ));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: previews.map((w) => Padding(padding: const EdgeInsets.only(right: 8), child: w)).toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(title: const Text('Add Product'),backgroundColor: AppColors.secondary,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Form(
            key: _formKey,
            child: Column(children: [
              _buildImagePreviews(),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Enter product name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Enter price' : null,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: stockC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder()),
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Enter stock' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: discountC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Discount', border: OutlineInputBorder()),
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Enter discount (0 if none)' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Category'),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => selectedCategory = v),
                validator: (v) => (v ?? '').isEmpty ? 'Select category' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descC,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : _saveProduct,
                  child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Product'),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
