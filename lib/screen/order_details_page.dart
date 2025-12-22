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
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Order Details",
          style: TextStyle(fontWeight: FontWeight.bold),
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
          final List products = order["products"] ?? [];

          final double subtotal = (order["totalPrice"] ?? 0).toDouble();
          final double discount = (order["totalDiscount"] ?? 0).toDouble();
          final double shipping = (order["shipping"] ?? 2).toDouble();

          final double grandTotal = subtotal + shipping - discount;

          final Timestamp? timestamp = order["timestamp"];
          final String orderDate = timestamp != null
              ? DateFormat("dd-MM-yyyy").format(timestamp.toDate())
              : "--";

          // status step mapping
          const steps = [
            "Pending",
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
                _buildOrderSummary(order, orderDate, grandTotal),
                const SizedBox(height: 20),
                _buildProductList(products),
                const SizedBox(height: 25),
                _buildPriceSection(
                  subtotal: subtotal,
                  discount: discount,
                  shipping: shipping,
                  grandTotal: grandTotal,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- STATUS ICONS ----------------
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
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            decoration: BoxDecoration(
              color: i <= step ? Colors.green : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }

  // ---------------- ORDER SUMMARY ----------------
  Widget _buildOrderSummary(
      Map<String, dynamic> order, String date, double total) {
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
          _summaryRow("Order Date", date),
          _summaryRow("Payment Method", order["paymentMethod"]),
          _summaryRow("Payment Status", order["paymentStatus"] ?? "Pending"),
          _summaryRow("Delivery Status", order["status"]),
          _summaryRow(
            "Grand Total",
            "৳ ${total.toStringAsFixed(2)}",
            highlight: true,
          ),
          const SizedBox(height: 12),
          const Text(
            "Shipping Address",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(order["address"] ?? ""),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              color: highlight ? Colors.red : Colors.black,
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
        const Text(
          "Ordered Products",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
                Image.network(
                  p["image"],
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p["name"],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text("Qty: ${p["quantity"]}"),
                    ],
                  ),
                ),
                Text(
                  "৳ ${p["finalPrice"].toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // ---------------- PRICE BREAKDOWN ----------------
  Widget _buildPriceSection({
    required double subtotal,
    required double discount,
    required double shipping,
    required double grandTotal,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _priceRow("SUB TOTAL", subtotal),
          _priceRow("DISCOUNT", -discount),
          _priceRow("DELIVERY CHARGE", shipping),
          const Divider(),
          _priceRow("GRAND TOTAL", grandTotal, highlight: true),
        ],
      ),
    );
  }

  Widget _priceRow(String title, double value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            "৳ ${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              color: highlight ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
