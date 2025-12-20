import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'item_list_by_category.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String query = "";

  // ---------------- IMAGE HELPERS ----------------
  bool _isNetworkImage(String path) {
    return path.startsWith('http');
  }

  String _safeImage(Map<String, dynamic> data) {
    final img = data['image'];
    if (img != null && img.toString().isNotEmpty) {
      return img.toString();
    }
    return "assets/images/notFound.png"; 
  }

  Widget _categoryImage(String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: _isNetworkImage(image)
          ? Image.network(
              image,
              width: 86,
              height: 86,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackIcon(),
            )
          : Image.asset(
              image,
              width: 86,
              height: 86,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      width: 86,
      height: 86,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.category,
        size: 36,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        title: const Text('Categories'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.03),
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
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Search categories...',
                      ),
                      onChanged: (v) =>
                          setState(() => query = v.trim().toLowerCase()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs;
                final filtered = docs.where((d) {
                  final name =
                      (d['name'] ?? '').toString().toLowerCase();
                  return name.contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      query.isEmpty
                          ? 'No categories yet'
                          : 'No results for "$query"',
                    ),
                  );
                }

                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final d = filtered[i];
                    final data = d.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Unnamed';
                    final image = _safeImage(data);

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ItemListByCategory(category: name),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              _categoryImage(image),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'View Products',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration:
                                            TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
