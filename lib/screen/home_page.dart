import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

import 'item_details_screen.dart'; // you'll create or adapt this to show product details

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _topBar(),
            const SizedBox(height: 12),
            _bannerSlider(),
            const SizedBox(height: 18),
            _quickMenu(),
            const SizedBox(height: 18),
            _featuredCategories(),
            const SizedBox(height: 18),
            _featuredProducts(context),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(children: [
      const Icon(Icons.menu),
      const SizedBox(width: 10),
      Expanded(
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Row(children: const [Icon(Icons.search, color: Colors.grey), SizedBox(width: 8), Text('Search', style: TextStyle(color: Colors.grey))]),
        ),
      ),
      const SizedBox(width: 10),
      const Icon(Icons.notifications_none),
    ]);
  }

  Widget _bannerSlider() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('banners').orderBy('order', descending: false).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
        final docs = snap.data!.docs;
        if (docs.isEmpty) return const SizedBox(height: 160, child: Center(child: Text('No banners')));

        return CarouselSlider(
          options: CarouselOptions(height: 160, autoPlay: true, viewportFraction: 1.0, enlargeCenterPage: false),
          items: docs.map((d) {
            final url = d['imageUrl'] ?? '';
            return ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(url, width: double.infinity, fit: BoxFit.cover));
          }).toList(),
        );
      },
    );
  }

  Widget _quickMenu() {
    final items = [
      {'icon': Icons.category, 'label': 'Categories'},
      {'icon': Icons.star, 'label': 'Top'},
      {'icon': Icons.store, 'label': 'Shops'},
      {'icon': Icons.local_offer, 'label': 'Deals'},
      {'icon': Icons.flash_on, 'label': 'Flash'},
    ];
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: items.map((it) {
      return Column(children: [CircleAvatar(radius: 26, backgroundColor: Colors.white, child: Icon(it['icon'] as IconData, color: AppColors.primary)), const SizedBox(height: 6), Text(it['label'] as String, style: const TextStyle(fontSize: 12))]);
    }).toList());
  }

  Widget _featuredCategories() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      SizedBox(
        height: 110,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('categories').snapshots(),
          builder: (ctx, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snap.data!.docs;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final d = docs[i];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(children: [Expanded(child: Image.network(d['image'] ?? '', fit: BoxFit.contain)), const SizedBox(height: 6), Text(d['name'] ?? '', style: const TextStyle(fontSize: 12))]),
                );
              },
            );
          },
        ),
      ),
    ]);
  }

  Widget _featuredProducts(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Featured Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').limit(20).snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.62),
            itemBuilder: (_, i) {
              final p = docs[i];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailsScreen(product: p.data() as Map<String, dynamic>))),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(children: [
                    Expanded(child: Image.network(p['image'] ?? '', fit: BoxFit.cover)),
                    const SizedBox(height: 8),
                    Text(p['name'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text('৳ ${p['price'] ?? ''}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ]),
                ),
              );
            },
          );
        },
      )
    ]);
  }
}
