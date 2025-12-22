import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:ecommerce_app/utils/env.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ShopSettingsPage extends StatefulWidget {
  const ShopSettingsPage({super.key});

  @override
  State<ShopSettingsPage> createState() => _ShopSettingsPageState();
}

class _ShopSettingsPageState extends State<ShopSettingsPage> {
  final name = TextEditingController();
  final description = TextEditingController();
  final bannerImage = TextEditingController();

  bool loading = true;
  String shopId = "";
  File? pickedImage;

  @override
  void initState() {
    super.initState();
    initShop();
  }

  /// ---------------- CREATE OR LOAD SHOP ----------------
  Future<void> initShop() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userRef =
        FirebaseFirestore.instance.collection("users").doc(uid);
    final userDoc = await userRef.get();

    shopId = (userDoc.data()?["shopId"] ?? "").toString();

    // 🔴 NO SHOP → CREATE ONE
    if (shopId.isEmpty) {
      final shopRef =
          FirebaseFirestore.instance.collection("shops").doc();

      await shopRef.set({
        "name": "My Shop",
        "description": "",
        "bannerImage": "",
        "ownerId": uid,
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      shopId = shopRef.id;

      // assign shopId to user
      await userRef.update({"shopId": shopId});
    }

    // Load shop data
    final shopDoc = await FirebaseFirestore.instance
        .collection("shops")
        .doc(shopId)
        .get();

    name.text = shopDoc.data()?["name"] ?? "";
    description.text = shopDoc.data()?["description"] ?? "";
    bannerImage.text = shopDoc.data()?["bannerImage"] ?? "";

    setState(() => loading = false);
  }

  /// ---------------- IMAGE PICK & UPLOAD ----------------
  Future<void> pickBannerImage() async {
    final XFile? file =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => pickedImage = File(file.path));

    final url = await uploadToCloudinary(pickedImage!);
    if (url == null) return;

    bannerImage.text = url;
  }

  Future<String?> uploadToCloudinary(File file) async {
    try {
      final uploadUrl =
          "https://api.cloudinary.com/v1_1/${Env.cloudName}/image/upload";

      final request =
          http.MultipartRequest("POST", Uri.parse(uploadUrl));

      request.fields["upload_preset"] = Env.uploadPreset;
      request.files
          .add(await http.MultipartFile.fromPath("file", file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(body)["secure_url"];
      }
    } catch (_) {}
    return null;
  }

  /// ---------------- UPDATE SHOP ----------------
  Future<void> updateShop() async {
    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection("shops")
        .doc(shopId)
        .update({
      "name": name.text.trim(),
      "description": description.text.trim(),
      "bannerImage": bannerImage.text.trim(),
    });

    setState(() => loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shop updated successfully")),
      );
    }
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text("Shop Settings"),
        backgroundColor: AppColors.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: pickedImage != null
                  ? Image.file(pickedImage!, height: 180, fit: BoxFit.cover)
                  : bannerImage.text.isNotEmpty
                      ? Image.network(
                          bannerImage.text,
                          height: 180,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 180,
                          color: Colors.grey.shade300,
                          child: const Center(
                              child: Text("No Banner Selected")),
                        ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: pickBannerImage,
              icon: const Icon(Icons.image),
              label: const Text("Choose Banner Image"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: "Shop Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: description,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Shop Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: updateShop,
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
