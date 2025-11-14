import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShopOrdersPage extends StatelessWidget {
  const ShopOrdersPage({super.key});

  Future<String> getShopId() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    return userDoc["shopId"];
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

        final shopId = snap.data as String;

        return Scaffold(
          appBar: AppBar(title: const Text("Shop Orders")),

          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("orders")
                .where("shopId", isEqualTo: shopId)
                .snapshots(),

            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final orders = snapshot.data!.docs;

              if (orders.isEmpty) {
                return const Center(child: Text("No orders yet"));
              }

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (_, index) {
                  final o = orders[index];

                  return Card(
                    child: ListTile(
                      title: Text("Order #${o.id}"),
                      subtitle: Text("Total: ৳ ${o["totalPrice"]}"),
                      trailing: Text(o["status"]),
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
}
