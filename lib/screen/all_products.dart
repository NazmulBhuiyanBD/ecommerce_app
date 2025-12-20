import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/provider/cart_provider.dart';
import 'package:ecommerce_app/screen/item_details_screen.dart';
import 'package:ecommerce_app/screen/store_details.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  String searchQuery = "";
  String selectedCategory = "All";
  String sortOption = "Newest";
  Set<String> wishlist = {};

  // SORTING
  List<QueryDocumentSnapshot> sortProducts(List<QueryDocumentSnapshot> items) {
    try {
      if (sortOption == "Price Low to High") {
        items.sort((a, b) => (a["price"] ?? 0).compareTo(b["price"] ?? 0));
      } else if (sortOption == "Price High to Low") {
        items.sort((a, b) => (b["price"] ?? 0).compareTo(a["price"] ?? 0));
      } else if (sortOption == "Discount") {
        items.sort((a, b) => (b["discount"] ?? 0).compareTo(a["discount"] ?? 0));
      } else {
        // NEWEST
        items.sort((a, b) {
          Timestamp t1 = a["createdAt"] ?? Timestamp.now();
          Timestamp t2 = b["createdAt"] ?? Timestamp.now();
          return t2.compareTo(t1);
        });
      }
    } catch (e) {
      print("Sort Error: $e");
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.secondary,
appBar: AppBar(
  backgroundColor: AppColors.secondary,
  elevation: 0,
  leading: const BackButton(color: Colors.black),
  title: Container(
    height: 42,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.05),
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
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Search products...",
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: (value) =>
                setState(() => searchQuery = value.toLowerCase()),
          ),
        ),
      ],
    ),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.filter_list, color: Colors.black),
      onPressed: showSortOptions,
    ),
  ],
),


      body: Column(
        children: [
          _categoryTabs(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("products").snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot> products = snap.data!.docs;

                // SEARCH FILTER
                if (searchQuery.isNotEmpty) {
                  products = products.where((e) {
                    String name = (e["name"] ?? "").toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();
                }

                // CATEGORY FILTER
                if (selectedCategory != "All") {
                  products = products.where((e) => e["category"] == selectedCategory).toList();
                }

                // SORT
                products = sortProducts(products);

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: .66,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final productId = products[index].id;
                    final data = products[index].data() as Map<String, dynamic>;

                    final List imgs = data["images"] ?? [];
                    final String image = imgs.isNotEmpty
                        ? imgs[0]
                        : "https://drive.google.com/file/d/1e6cz8vgwIcljKau_pnd3f3-PmTyMXIn2/view?usp=sharing";

                    return _productCard(context, productId, data, image, cart);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(BuildContext context, String productId,
      Map<String, dynamic> p, String image, CartProvider cart) {
    final bool isWishlisted = wishlist.contains(productId);

    final double price = (p["price"] ?? 0).toDouble();
    final double discount = (p["discount"] ?? 0).toDouble();
    final double newPrice = price - discount;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 5, spreadRadius: 1, color: Colors.grey.shade300)
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.network(
                  image,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                right: 6,
                top: 6,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isWishlisted ? wishlist.remove(productId) : wishlist.add(productId);
                    });
                  },
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white.withOpacity(0.7),
                    child: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 17,
                    ),
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 4),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p["name"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),

                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("shops")
                        .doc(p["shopId"])
                        .get(),
                    builder: (_, snap) {
                      if (!snap.hasData) return const SizedBox(height: 14);

                      final shop = snap.data!.data() as Map<String, dynamic>?;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoreDetailsScreen(shopId: p["shopId"]),
                            ),
                          );
                        },
                        child: Text(
                          shop?["name"] ?? "Unknown Store",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 4),

                  // PRICE
                  discount > 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("৳ ${newPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red)),
                            Text("৳ ${price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough)),
                          ],
                        )
                      : Text("৳ $price",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ItemDetailsScreen(product: p, productId: productId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12)),
                    ),
                  ),
                  child: const Icon(Icons.remove_red_eye, color: Colors.black),
                ),
              ),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    cart.addToCart(productId, p);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Added to cart")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(12)),
                    ),
                  ),
                  child: const Icon(Icons.shopping_cart, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _categoryTabs() {
  return SizedBox(
    height: 50,
    child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("categories").snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox();

        final docs = snap.data!.docs;

        List<String> categories = ["All"];
        categories.addAll(
          docs.map((d) => (d["name"] ?? "").toString()),
        );

        return ListView.builder(
          scrollDirection: Axis.horizontal,

          // ✅ THIS FIXES THE LEFT GAP ISSUE
          padding: const EdgeInsets.symmetric(horizontal: 12),

          itemCount: categories.length,
          itemBuilder: (_, i) {
            final c = categories[i];
            final bool isSelected = selectedCategory == c;

            return GestureDetector(
              onTap: () => setState(() => selectedCategory = c),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Text(
                  c,
                  style: TextStyle(
                    color:
                        isSelected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}


  void showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final options = [
          "Newest",
          "Price Low to High",
          "Price High to Low",
          "Discount",
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            return ListTile(
              title: Text(opt),
              trailing: sortOption == opt ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                setState(() => sortOption = opt);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
