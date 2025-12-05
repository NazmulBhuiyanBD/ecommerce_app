import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;
  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .doc(orderId)
            .snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = snap.data!.data() as Map<String, dynamic>;
          final products = order["products"] as List<dynamic>;
          final timestamp = order["timestamp"] as Timestamp?;

          String orderDate = timestamp != null
              ? DateFormat("dd-MM-yyyy").format(timestamp.toDate())
              : "--";

          // Status steps
          List<String> steps = [
            "Order Placed",
            "Confirmed",
            "On Delivery",
            "Delivered",
          ];

          int currentStep = steps.indexOf(order["status"]);
          if (currentStep < 0) currentStep = 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusIcons(currentStep),
                const SizedBox(height: 20),
                _buildProgressBar(currentStep),
                const SizedBox(height: 25),
                _buildOrderSummary(order, orderDate),
                const SizedBox(height: 20),
                _buildProductList(products),
                const SizedBox(height: 25),
                _buildPriceSection(order),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildStatusIcons(int step) {
    final icons = [
      Icons.receipt_long,
      Icons.thumb_up_alt_outlined,
      Icons.local_shipping,
      Icons.verified,
    ];

    final labels = [
      "Order placed",
      "Confirmed",
      "On Delivery",
      "Delivered",
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (i) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: i <= step ? Colors.red : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icons[i],
                color: i <= step ? Colors.red : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(height: 6),
            Text(labels[i], style: const TextStyle(fontSize: 12)),
          ],
        );
      }),
    );
  }
  Widget _buildProgressBar(int step) {
    return Row(
      children: List.generate(4, (i) {
        bool active = i <= step;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            decoration: BoxDecoration(
              color: active ? Colors.green : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }
  Widget _buildOrderSummary(Map<String, dynamic> order, String orderDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow("Order Code", orderId.toUpperCase(), highlight: true),
          _summaryRow("Order Date", orderDate),
          _summaryRow("Payment Method", order["paymentMethod"]),
          _summaryRow("Payment Status",
              order["paymentStatus"] ?? "Pending"),
          _summaryRow("Delivery Status", order["status"]),
          _summaryRow("Total Amount", "৳ ${order["totalPrice"]}",
              highlight: true),
          const SizedBox(height: 12),
          const Text(
            "Shipping Address",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(order["address"] ?? "",
              style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              color: highlight ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildProductList(List products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ordered Products",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        ...products.map((p) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    p["image"],
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p["name"],
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 5),
                      Text("Quantity: ${p["quantity"]}"),
                    ],
                  ),
                ),

                Text(
                  "৳ ${p["finalPrice"].toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // ---------------------- PRICE BREAKDOWN ----------------------
  Widget _buildPriceSection(Map<String, dynamic> order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _priceRow("SUB TOTAL", order["subtotal"] ?? order["totalPrice"]),
          _priceRow("DISCOUNT", "-৳ ${order["totalDiscount"] ?? 0}"),
          _priceRow("SHIPPING COST", "৳ ${(order["shipping"] ?? 0)}"),
          const Divider(),
          _priceRow("GRAND TOTAL", "৳ ${order["totalPrice"]}",
              highlight: true),
        ],
      ),
    );
  }

  Widget _priceRow(String title, dynamic value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold)),
          Text(
            "$value",
            style: TextStyle(
              fontSize: 16,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              color: highlight ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
