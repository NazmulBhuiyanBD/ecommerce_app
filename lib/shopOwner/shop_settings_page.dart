import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    loadShopData();
  }

  Future<void> loadShopData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    shopId = userDoc["shopId"];

    final shopDoc =
        await FirebaseFirestore.instance.collection("shops").doc(shopId).get();

    name.text = shopDoc["name"] ?? "";
    description.text = shopDoc["description"] ?? "";
    bannerImage.text = shopDoc["bannerImage"] ?? "";

    setState(() => loading = false);
  }

  Future<void> pickBannerImage() async {
    final XFile? file =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        pickedImage = File(file.path);
      });
      final url = await uploadToCloudinary(pickedImage!);

      if (url != null) {
        setState(() {
          bannerImage.text = url;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Banner Image Uploaded Successfully")),
        );
      }
    }
  }

  Future<String?> uploadToCloudinary(File file) async {
    try {
      final uploadUrl =
          "https://api.cloudinary.com/v1_1/${Env.cloudName}/image/upload";

      final request = http.MultipartRequest("POST", Uri.parse(uploadUrl));
      request.fields["upload_preset"] = Env.uploadPreset;

      request.files.add(await http.MultipartFile.fromPath("file", file.path));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(resBody);
        return jsonData["secure_url"];
      } else {
        print("Cloudinary upload error: $resBody");
      }
    } catch (e) {
      print("Cloudinary Error: $e");
    }
    return null;
  }

  Future<void> updateShop() async {
    setState(() => loading = true);

    await FirebaseFirestore.instance.collection("shops").doc(shopId).update({
      "name": name.text.trim(),
      "description": description.text.trim(),
      "bannerImage": bannerImage.text.trim(),
    });

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Shop Settings Updated")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop Settings"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: pickedImage != null
                        ? Image.file(
                            pickedImage!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : (bannerImage.text.isNotEmpty
                            ? Image.network(
                                bannerImage.text,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.grey.shade300,
                                child: const Center(
                                    child: Text("No Banner Selected")),
                              )),
                  ),
                  
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: pickBannerImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Choose Banner Image"),
                  ),
                ],
              ),
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
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: updateShop,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
