import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'order_details_page.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor:AppColors.secondary,
      appBar: AppBar(
        title: const Text(
          "Purchase History",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.secondary,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection("orders")
    .where("userId", isEqualTo: userId)
    .orderBy("timestamp", descending: true)
    .snapshots(),

        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(
              child: Text("No purchase history found"),
            );
          }

          final orders = snap.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final o = orders[i];
              final data = o.data() as Map<String, dynamic>;

              final orderId = o.id;
              final total = (data["totalPrice"] ?? 0).toDouble();
              final payMethod = data["paymentMethod"] ?? "Unknown";
              final status = data["status"] ?? "Pending";

              final timestamp = data["timestamp"] as Timestamp?;
              final date = timestamp != null
                  ? "${timestamp.toDate().day}-${timestamp.toDate().month}-${timestamp.toDate().year}"
                  : "Unknown date";

              final bool isPaid = payMethod != "Cash on Delivery";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OrderDetailsPage(orderId: orderId),
                    ),
                  );
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.06),
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ORDER ID
                      Text(
                        orderId,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(date),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.payment, size: 16, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            "Payment Status - ${isPaid ? "Paid" : "Unpaid"}",
                            style: TextStyle(
                              color: isPaid ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isPaid ? Icons.check_circle : Icons.cancel,
                            color: isPaid ? Colors.green : Colors.red,
                            size: 18,
                          )
                        ],
                      ),

                      const SizedBox(height: 8),

                      // DELIVERY STATUS
                      Row(
                        children: [
                          const Icon(Icons.local_shipping,
                              size: 16, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text("Delivery Status - $status"),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // TOTAL PRICE
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "৳ ${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
