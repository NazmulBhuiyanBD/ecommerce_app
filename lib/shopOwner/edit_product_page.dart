import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:ecommerce_app/utils/env.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditProductPage extends StatefulWidget {
  final String productId;
  const EditProductPage({required this.productId, super.key});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final priceC = TextEditingController();
  final descC = TextEditingController();
  final stockC = TextEditingController();
  final discountC = TextEditingController();

  String? selectedCategory;
  List<String> categories = [];

  List<String> existingImageUrls = [];
  List<File> newPickedFiles = [];

  bool loading = true;
  bool saving = false;
  late DocumentSnapshot productSnap;

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndProduct();
  }

  Future<void> _loadCategoriesAndProduct() async {
    final catSnap = await FirebaseFirestore.instance.collection('categories').orderBy('name').get();
    categories = catSnap.docs.map((d) => (d.data()['name'] ?? '').toString()).where((s) => s.isNotEmpty).toList();

    productSnap = await FirebaseFirestore.instance.collection('products').doc(widget.productId).get();
    final d = productSnap.data() as Map<String, dynamic>;

    nameC.text = d['name'] ?? '';
    priceC.text = (d['price'] ?? 0).toString();
    descC.text = d['description'] ?? '';
    selectedCategory = d['category'];
    existingImageUrls = (d['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    stockC.text = ((d['stock'] ?? 0).toString());
    discountC.text = ((d['discount'] ?? 0).toString());

    if (mounted) setState(() => loading = false);
  }

  Future<void> pickImages() async {
    final p = ImagePicker();
    final List<XFile>? picks = await p.pickMultiImage();
    if (picks == null || picks.isEmpty) return;
    setState(() => newPickedFiles.addAll(picks.map((x) => File(x.path))));
  }

  Future<String?> _uploadToCloudinary(File f) async {
    try {
      final url = 'https://api.cloudinary.com/v1_1/${Env.cloudName}/image/upload';
      final req = http.MultipartRequest('POST', Uri.parse(url));
      req.fields['upload_preset'] = Env.uploadPreset;
      req.files.add(await http.MultipartFile.fromPath('file', f.path));
      final resp = await req.send();
      final body = await resp.stream.bytesToString();
      if (resp.statusCode == 200) {
        final map = jsonDecode(body);
        return map['secure_url'] as String?;
      }
    } catch (e) {
      debugPrint('upload error: $e');
    }
    return null;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select category')));
      return;
    }

    setState(() => saving = true);

    List<String> uploaded = [];
    for (final f in newPickedFiles) {
      final u = await _uploadToCloudinary(f);
      if (u != null) uploaded.add(u);
    }

    final finalImages = [...existingImageUrls, ...uploaded];

    try {
      await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
        'name': nameC.text.trim(),
        'price': double.tryParse(priceC.text.trim()) ?? 0.0,
        'description': descC.text.trim(),
        'images': finalImages,
        'category': selectedCategory,
        'stock': int.tryParse(stockC.text.trim()) ?? 0,
        'discount': double.tryParse(discountC.text.trim()) ?? 0.0,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product updated')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget _imagesRow() {
    final widgets = <Widget>[];
    for (int i = 0; i < existingImageUrls.length; i++) {
      final url = existingImageUrls[i];
      widgets.add(Stack(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover)),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  existingImageUrls.removeAt(i);
                });
              },
              child: Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 18, color: Colors.white)),
            ),
          )
        ],
      ));
    }

    for (int i = 0; i < newPickedFiles.length; i++) {
      final f = newPickedFiles[i];
      widgets.add(Stack(
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
              child: Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 18, color: Colors.white)),
            ),
          )
        ],
      ));
    }

    widgets.add(GestureDetector(
      onTap: pickImages,
      child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Center(child: Icon(Icons.add_a_photo))),
    ));

    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: widgets.map((w) => Padding(padding: const EdgeInsets.only(right: 8), child: w)).toList()));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(title: const Text('Edit Product'),backgroundColor: AppColors.secondary,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Form(
            key: _formKey,
            child: Column(children: [
              _imagesRow(),
              const SizedBox(height: 16),
              TextFormField(controller: nameC, decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()), validator: (v) => (v ?? '').trim().isEmpty ? 'Enter name' : null),
              const SizedBox(height: 12),
              TextFormField(controller: priceC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()), validator: (v) => (v ?? '').trim().isEmpty ? 'Enter price' : null),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextFormField(controller: stockC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder()), validator: (v) => (v ?? '').trim().isEmpty ? 'Enter stock' : null)),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: discountC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Discount', border: OutlineInputBorder()), validator: (v) => (v ?? '').trim().isEmpty ? 'Enter discount' : null)),
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: selectedCategory, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Category'), items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => selectedCategory = v), validator: (v) => (v ?? '').isEmpty ? 'Select category' : null),
              const SizedBox(height: 12),
              TextFormField(controller: descC, maxLines: 4, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), validator: (v) => (v ?? '').trim().isEmpty ? 'Enter description' : null),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: saving ? null : _saveChanges, child: saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes'))),
            ]),
          ),
        ]),
      ),
    );
  }
}
