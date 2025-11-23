import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageProducts extends StatefulWidget {
  const ManageProducts({super.key});

  @override
  State<ManageProducts> createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  String search = "";
  int limit = 10;
  DocumentSnapshot? lastDoc;
  DocumentSnapshot? firstDoc;
  bool hasMore = true;
  bool isLoading = false;

  List<DocumentSnapshot> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts({bool nextPage = false, bool prevPage = false}) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection("products")
        .orderBy("name")
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
      products = snap.docs;
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
        title: const Text("Manage Products"),
      ),

      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                hintText: "Search product...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => search = v.trim().toLowerCase()),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const Center(child: Text("No products found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: products.length,
                        itemBuilder: (_, index) {
                          final p = products[index];
                          final name = p["name"].toString();
                          final shopId = p["shopId"];

                          if (!name.toLowerCase().contains(search)) {
                            return const SizedBox.shrink();
                          }

                          return FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection("shops")
                                .doc(shopId)
                                .get(),
                            builder: (_, s) {
                              String shopName = "Unknown Shop";
                              if (s.hasData && s.data!.exists) {
                                shopName = s.data!["shopName"];
                              }

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  title: Text(name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      "Shop: $shopName\nPrice: ৳${p["price"]}"),
                                  trailing: Switch(
                                    value: p["active"] ?? true,
                                    onChanged: (value) {
                                      FirebaseFirestore.instance
                                          .collection("products")
                                          .doc(p.id)
                                          .update({"active": value});
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),

          // PAGINATION BUTTONS (only if more than 10 products)
          if (products.length == limit || lastDoc != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: firstDoc == null
                      ? null
                      : () => loadProducts(prevPage: true),
                  child: const Text("Previous"),
                ),
                ElevatedButton(
                  onPressed: hasMore ? () => loadProducts(nextPage: true) : null,
                  child: const Text("Next"),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ]
        ],
      ),
    );
  }
}
