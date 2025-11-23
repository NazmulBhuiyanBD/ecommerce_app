import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageOrders extends StatefulWidget {
  const ManageOrders({super.key});

  @override
  State<ManageOrders> createState() => _ManageOrdersState();
}

class _ManageOrdersState extends State<ManageOrders> {
  String search = "";
  int limit = 10;
  DocumentSnapshot? lastDoc;
  DocumentSnapshot? firstDoc;
  bool hasMore = true;
  bool isLoading = false;

  List<DocumentSnapshot> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders({bool nextPage = false, bool prevPage = false}) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection("orders")
        .orderBy("timestamp", descending: true)
        .limit(limit);

    if (nextPage && lastDoc != null) {
      query = query.startAfterDocument(lastDoc!);
    }

    if (prevPage && firstDoc != null) {
      query = query.endBeforeDocument(firstDoc!);
    }

    final snap = await query.get();

    if (snap.docs.isNotEmpty) {
      firstDoc = snap.docs.first;
      lastDoc = snap.docs.last;
    }

    setState(() {
      orders = snap.docs;
      hasMore = snap.docs.length == limit;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7E9),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F7E9),
        elevation: 0,
        title: const Text("Manage Orders"),
      ),

      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search order or customer...",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => search = v.trim().toLowerCase()),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length,
                    itemBuilder: (_, index) {
                      final o = orders[index];

                      final orderId = o.id;
                      final customer = o["customerName"];
                      final total = o["totalPrice"];
                      final status = o["status"];
                      final shopId = o["shopId"];
                      final time = o["timestamp"];

                      if (!orderId.toLowerCase().contains(search) &&
                          !customer.toLowerCase().contains(search)) {
                        return const SizedBox.shrink();
                      }

                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection("shops")
                            .doc(shopId)
                            .get(),
                        builder: (_, snap) {
                          String shopName = "Unknown Shop";
                          if (snap.hasData && snap.data!.exists) {
                            shopName = snap.data!["shopName"];
                          }

                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(15),

                              title: Text("Order ID: $orderId",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),

                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Customer: $customer"),
                                  Text("Shop: $shopName"),
                                  Text("Total: ৳$total"),
                                  Text("Date: ${DateTime.fromMillisecondsSinceEpoch(time).toString().substring(0, 16)}"),
                                ],
                              ),

                              trailing: DropdownButton<String>(
                                value: status,
                                items: const [
                                  DropdownMenuItem(
                                      value: "Pending", child: Text("Pending")),
                                  DropdownMenuItem(
                                      value: "Processing",
                                      child: Text("Processing")),
                                  DropdownMenuItem(
                                      value: "Shipped", child: Text("Shipped")),
                                  DropdownMenuItem(
                                      value: "Delivered",
                                      child: Text("Delivered")),
                                  DropdownMenuItem(
                                      value: "Cancelled",
                                      child: Text("Cancelled")),
                                ],
                                onChanged: (newStatus) {
                                  FirebaseFirestore.instance
                                      .collection("orders")
                                      .doc(orderId)
                                      .update({"status": newStatus});
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          if (orders.length == limit || lastDoc != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: firstDoc == null
                        ? null
                        : () => loadOrders(prevPage: true),
                    child: const Text("Previous")),

                ElevatedButton(
                    onPressed: hasMore ? () => loadOrders(nextPage: true) : null,
                    child: const Text("Next")),
              ],
            ),
            const SizedBox(height: 12),
          ]
        ],
      ),
    );
  }
}
