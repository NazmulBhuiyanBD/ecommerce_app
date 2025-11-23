import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShopOwnerOrdersPage extends StatelessWidget {
  const ShopOwnerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final owner = FirebaseAuth.instance.currentUser;

    if (owner == null) {
      return const Scaffold(
        body: Center(child: Text("Please login")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop Orders"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allOrders = snapshot.data!.docs;
          final myOrders = allOrders.where((order) {
            final products = order["products"] as List;

            return products.any((p) => p["shopId"] == owner.uid);
          }).toList();

          if (myOrders.isEmpty) {
            return const Center(child: Text("No orders for your shop yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: myOrders.length,
            itemBuilder: (_, i) {
              final order = myOrders[i];
              final status = order["status"];

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  title: Text("Order ID: ${order.id}"),
                  subtitle: Text("Status: $status"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShopOrderDetailsPage(data: order.data()),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ShopOrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ShopOrderDetailsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final ownerId = FirebaseAuth.instance.currentUser!.uid;
    final products = data["products"] as List;

    // Filter only products that belong to this shop
    final myProducts = products.where((p) => p["shopId"] == ownerId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: myProducts.length,
                itemBuilder: (_, index) {
                  final p = myProducts[index];

                  return ListTile(
                    leading: Image.network(p["image"], width: 50),
                    title: Text(p["name"]),
                    subtitle: Text("৳ ${p["price"]} x ${p["quantity"]}"),
                  );
                },
              ),
            ),

            const Divider(),

            Text("Order Status: ${data["status"]}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
