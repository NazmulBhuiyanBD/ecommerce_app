import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  final bannerController = TextEditingController();
  final categoryController = TextEditingController();
  final offerBannerController = TextEditingController();
  final noticeController = TextEditingController();

  Future addBanner() async {
    if (bannerController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection("banners").add({
      "image": bannerController.text.trim(),
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });

    bannerController.clear();
  }

  Future addCategory() async {
    if (categoryController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection("categories").add({
      "name": categoryController.text.trim(),
    });

    categoryController.clear();
  }

  Future addOfferBanner() async {
    if (offerBannerController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection("offer_banners").add({
      "image": offerBannerController.text.trim(),
    });

    offerBannerController.clear();
  }

  Future updateNotice() async {
    await FirebaseFirestore.instance
        .collection("settings")
        .doc("app")
        .set({"notice": noticeController.text.trim()},
            SetOptions(merge: true));

    noticeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7E9),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Manage App Screen"),
        centerTitle: true,
        backgroundColor: const Color(0xffF4F7E9),
      ),

      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          sectionTitle("Add Home Banner"),
          addInputTile(
            controller: bannerController,
            hint: "Banner image URL",
            onSave: addBanner,
          ),
          streamList("banners", "image"),

          sectionTitle("Add Category"),
          addInputTile(
            controller: categoryController,
            hint: "Category name",
            onSave: addCategory,
          ),
          streamList("categories", "name"),

          sectionTitle("Add Offer Banner"),
          addInputTile(
            controller: offerBannerController,
            hint: "Offer banner image URL",
            onSave: addOfferBanner,
          ),
          streamList("offer_banners", "image"),

          sectionTitle("App Notice Text"),
          addInputTile(
            controller: noticeController,
            hint: "Enter notice",
            onSave: updateNotice,
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget addInputTile({
    required TextEditingController controller,
    required String hint,
    required Function() onSave,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onSave,
          child: const Text("Add"),
        ),
      ],
    );
  }

  Widget streamList(String collection, String field) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox.shrink();

        final items = snap.data!.docs;

        return Column(
          children: items.map((e) {
            return Card(
              child: ListTile(
                title: Text(e[field]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection(collection)
                        .doc(e.id)
                        .delete();
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
