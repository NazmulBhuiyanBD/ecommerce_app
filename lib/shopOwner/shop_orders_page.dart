import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShopOrdersPage extends StatelessWidget {
  const ShopOrdersPage({super.key});

  Future<String> getShopId() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    return userDoc.data()?["shopId"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getShopId(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final String shopId = snap.data ?? "";

        if (shopId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("No shop assigned to this account.")),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.secondary,
          appBar: AppBar(
            title: const Text("Shop Orders"),
            backgroundColor: AppColors.secondary,
            elevation: 0,
          ),

          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("orders")
                .orderBy("timestamp", descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              /// FILTER ORDERS THAT CONTAIN THIS SHOP'S PRODUCTS
              final shopOrders = snap.data!.docs.where((order) {
                final List items = order["products"] ?? [];
                return items.any((p) => (p["shopId"] ?? "") == shopId);
              }).toList();

              if (shopOrders.isEmpty) {
                return const Center(
                  child: Text(
                    "No orders for your shop yet",
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: shopOrders.length,
                itemBuilder: (_, i) {
                  final o = shopOrders[i];
                  final String status = o["status"] ?? "Pending";

                  /// Calculate total amount ONLY for this shop’s products
                  double shopTotal = 0;

                  final List products = o["products"] ?? [];
                  for (var p in products) {
                    if ((p["shopId"] ?? "") == shopId) {
                      double finalPrice =
                          double.tryParse(p["finalPrice"].toString()) ?? 0.0;
                      int qty = p["quantity"] ?? 1;
                      shopTotal += finalPrice * qty;
                    }
                  }

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),

                      title: Text(
                        "Order #${o.id}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text("Your Items Total: ৳ ${shopTotal.toStringAsFixed(2)}"),
                          Text("Status: $status"),
                        ],
                      ),

                      trailing: _statusDropdown(context, o.id, status),
                      onTap: () {
                        /// Optional: open order details page
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  /// STATUS DROPDOWN FOR SHOP OWNER
  Widget _statusDropdown(
      BuildContext context, String orderId, String status) {
    List<String> allowedStatuses;

    if (status == "Pending") {
      allowedStatuses = ["Pending", "Processing", "Cancelled"];
    } else if (status == "Processing") {
      allowedStatuses = ["Processing", "Cancelled"];
    } else {
      allowedStatuses = [status]; // Locked
    }

    return DropdownButton<String>(
      value: status,
      underline: const SizedBox(),
      items: allowedStatuses
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),

      onChanged: (newStatus) async {
        if (newStatus == null) return;

        await FirebaseFirestore.instance
            .collection("orders")
            .doc(orderId)
            .update({"status": newStatus});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order updated to $newStatus")),
        );
      },
    );
  }
}
