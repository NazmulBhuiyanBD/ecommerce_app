import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screen/store_details.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  String searchQuery = "";

  
  bool isNetworkImage(String path) {
    return path.startsWith("http");
  }

  Widget shopImage(String? image) {
    if (image == null || image.isEmpty) {
      return Image.asset(
        "assets/notfound.png",
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return isNetworkImage(image)
        ? Image.network(
            image,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Image.asset(
                "assets/notfound.png",
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              );
            },
          )
        : Image.asset(
            "assets/notfound.png",
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.secondary,
        title: const Text("Shops"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.03),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration.collapsed(
                        hintText: "Search shops...",
                      ),
                      onChanged: (v) =>
                          setState(() => searchQuery = v.toLowerCase()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("shops")
                  .where("status", isEqualTo: "approved")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                if (searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name =
                        (data["name"] ?? "").toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(child: Text("No Shop Found"));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
itemBuilder: (context, index) {
  final String shopId = docs[index].id;
  final data = docs[index].data() as Map<String, dynamic>;

  final String name = data["name"] ?? "Unnamed shop";
  final String description =
      data["description"] ?? "No description available";
  final String? bannerImage = data["bannerImage"];

  return Card(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoreDetailsScreen(shopId: shopId),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(14),
            ),
            child: shopImage(bannerImage),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
