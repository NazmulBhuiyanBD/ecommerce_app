import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

class StoreList extends StatelessWidget {
  const StoreList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text("Store List"),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
        elevation: 0,
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("shops").snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final shops = snapshot.data!.docs;

          if (shops.isEmpty) {
            return const Center(child: Text("No shops found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: shops.length,
            itemBuilder: (_, i) {
              final shop = shops[i];
              final shopId = shop.id;

              final shopName = shop["name"] ?? "";
              final banner = shop["bannerImage"] ?? "";
              final ownerId = shop["ownerId"] ?? "";
              final status = shop["status"] ?? "pending";

              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("products")
                    .where("shopId", isEqualTo: shopId)
                    .get(),

                builder: (_, productSnap) {
                  int productCount = 0;
                  if (productSnap.hasData) {
                    productCount = productSnap.data!.docs.length;
                  }

                  return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection("users")
                        .doc(ownerId)
                        .get(),

                    builder: (_, ownerSnap) {
                      String ownerName = "Unknown Owner";

                      if (ownerSnap.hasData && ownerSnap.data!.exists) {
                        ownerName = ownerSnap.data!["name"] ?? "Unknown";
                      }

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15),

                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: banner.isNotEmpty
                                ? Image.network(
                                    banner,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.store, size: 35),
                                  ),
                          ),

                          title: Text(
                            shopName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Owner: $ownerName"),
                              Text("Products: $productCount"),
                              Text(
                                "Status: $status",
                                style: TextStyle(
                                  color: status == "approved"
                                      ? Colors.green
                                      : status == "disabled"
                                          ? Colors.red
                                          : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          trailing: PopupMenuButton(
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                  value: "approve", child: Text("Approve")),
                              const PopupMenuItem(
                                  value: "disable", child: Text("Disable")),
                            ],

                            onSelected: (value) {
                              String newStatus =
                                  value == "approve" ? "approved" : "disabled";

                              FirebaseFirestore.instance
                                  .collection("shops")
                                  .doc(shopId)
                                  .update({"status": newStatus});
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
