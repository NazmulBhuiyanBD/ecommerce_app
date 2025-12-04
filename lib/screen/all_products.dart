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

  // SORTING FUNCTION
  List<QueryDocumentSnapshot> sortProducts(List<QueryDocumentSnapshot> items) {
    try {
      if (sortOption == "Price Low to High") {
        items.sort((a, b) => (a["price"] ?? 0).compareTo(b["price"] ?? 0));
      } else if (sortOption == "Price High to Low") {
        items.sort((a, b) => (b["price"] ?? 0).compareTo(a["price"] ?? 0));
      } else if (sortOption == "Discount") {
        items.sort((a, b) => (b["discount"] ?? 0).compareTo(a["discount"] ?? 0));
      } else if (sortOption == "Newest") {
        items.sort((a, b) {
          Timestamp t1 = a["createdAt"] ?? Timestamp.now();
          Timestamp t2 = b["createdAt"] ?? Timestamp.now();
          return t2.compareTo(t1);
        });
      }
    } catch (e) {
      print("Sorting error: $e");
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
        leading: BackButton(color: Colors.black),
        title: TextField(
          decoration: const InputDecoration(
            hintText: "Search products...",
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () => showSortOptions(),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Column(
          children: [
            categoryTabs(),
        
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection("products").snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
        
                  List<QueryDocumentSnapshot> products = snap.data!.docs;
        
                  // SEARCH FILTER
                  if (searchQuery.isNotEmpty) {
                    products = products.where((e) {
                      String name = (e["name"] ?? "").toLowerCase();
                      return name.contains(searchQuery);
                    }).toList();
                  }
        
                  // CATEGORY FILTER
                  if (selectedCategory != "All") {
                    products = products.where((e) {
                      return e["category"] == selectedCategory;
                    }).toList();
                  }
        
                  // SORTING
                  products = sortProducts(products);
        
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: .66,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index].data() as Map<String, dynamic>? ?? {};
                      final id = products[index].id;
        
                      final List images = p["images"] ?? [];
                      final image = images.isNotEmpty
                          ? images[0]
                          : "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/480px-No_image_available.svg.png";
        
                      return productCard(context, p, id, image, cart);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PRODUCT CARD
Widget productCard(BuildContext context, Map<String, dynamic> p, String id,
    String image, CartProvider cart) {
  
  final price = p["price"] ?? 0;
  final discount = p["discount"] ?? 0.0;
  final newPrice = price - (price * discount);
  final bool isWishlisted = wishlist.contains(id);

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          blurRadius: 5,
          spreadRadius: 1,
          color: Colors.grey.shade300,
        )
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
                height: 136,
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
                    isWishlisted ? wishlist.remove(id) : wishlist.add(id);
                  });
                },
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white.withOpacity(0.7),
                  child: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 3.5),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // NAME
                Text(
                  p["name"] ?? "Unknown Product",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 4),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("shops")
                      .doc(p["shopId"] ?? "0")
                      .get(),
                  builder: (_, snap) {
                    if (!snap.hasData) {
                      return const SizedBox(height: 14);
                    }

                    final data = snap.data!.data() as Map<String, dynamic>?;
                    final storeName = data?["name"] ?? "Unknown Store";

                    return GestureDetector(
                      onTap: () {
                        if (p["shopId"] == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                StoreDetailsScreen(shopId: p["shopId"]),
                          ),
                        );
                      },
                      child: Text(
                        storeName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
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
                          Text(
                            "৳ $newPrice",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            "৳ $price",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        "৳ $price",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
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
                      builder: (_) => ItemDetailsScreen(product: p),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                ),
                child: const Text("View"),
              ),
            ),

            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  cart.addToCart(p);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Added to cart")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ),
                child:
                    const Text("Add", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  // CATEGORY FILTER ROW
  Widget categoryTabs() {
    return SizedBox(
      height: 45,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("categories").snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const SizedBox();

          final docs = snap.data!.docs;

          List<String> categories = ["All"];
          for (var d in docs) {
            categories.add(d["name"] ?? "");
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final c = categories[i];
              final bool isSelected = c == selectedCategory;

              return GestureDetector(
                onTap: () => setState(() => selectedCategory = c),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primary,
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

  // SORT OPTIONS BOTTOM SHEET
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

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              return ListTile(
                title: Text(opt),
                trailing: sortOption == opt
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() => sortOption = opt);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

