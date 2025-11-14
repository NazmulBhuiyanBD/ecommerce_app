import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  Future<void> loadShopData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    shopId = userDoc["shopId"];

    final shopDoc =
        await FirebaseFirestore.instance.collection("shops").doc(shopId).get();

    name.text = shopDoc["name"];
    description.text = shopDoc["description"];
    bannerImage.text = shopDoc["bannerImage"];

    setState(() => loading = false);
  }

  Future<void> updateShop() async {
    setState(() => loading = true);

    await FirebaseFirestore.instance.collection("shops").doc(shopId).update({
      "name": name.text.trim(),
      "description": description.text.trim(),
      "bannerImage": bannerImage.text.trim(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Saved")));
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    loadShopData();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Shop Settings")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Shop Name"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: bannerImage,
              decoration: const InputDecoration(labelText: "Banner Image URL"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Shop Description"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: updateShop,
              child: const Text("Save Changes"),
            )
          ],
        ),
      ),
    );
  }
}
