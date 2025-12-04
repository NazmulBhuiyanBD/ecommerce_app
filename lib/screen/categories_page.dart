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

  String _safeImage(Map<String, dynamic> data) {
    final img = data['image'];
    if (img != null && img.toString().isNotEmpty) return img.toString();
    return 'https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg';
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
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.03), blurRadius: 6)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration.collapsed(hintText: 'Search categories...'),
                      onChanged: (v) => setState(() => query = v.trim().toLowerCase()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('categories').orderBy('name').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs;
                final filtered = docs.where((d) {
                  final name = (d['name'] ?? '').toString().toLowerCase();
                  return name.contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(query.isEmpty ? 'No categories yet' : 'No results for "$query"'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final d = filtered[i];
                    final data = d.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Unnamed';
                    final image = _safeImage(data);

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ItemListByCategory(category: name)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  image,
                                  width: 86,
                                  height: 86,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 86,
                                    height: 86,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.category, size: 36, color: Colors.grey),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              // title + small links
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 8),

                                    // sub-links row
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            // TODO: navigate to sub-categories page if you have one
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('View Sub-Categories tapped')),
                                            );
                                          },
                                          child: Text(
                                            'View Sub-Categories',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text('|', style: TextStyle(color: Colors.grey.shade400)),
                                        const SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => ItemListByCategory(category: name)),
                                            );
                                          },
                                          child: Text(
                                            'View Products',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
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
