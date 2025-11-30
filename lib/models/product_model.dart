import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String shopId;
  final String name;
  final double price;
  final String description;
  final List<String> images;
  final String category;
  final int stock;
  final double discount;
  final DateTime createdAt;
  final bool disabled;

  ProductModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.price,
    required this.description,
    required this.images,
    required this.category,
    required this.stock,
    required this.discount,
    required this.createdAt,
    required this.disabled,
  });

  factory ProductModel.fromSnapshot(DocumentSnapshot snap) {
    final d = snap.data() as Map<String, dynamic>;
    return ProductModel(
      id: snap.id,
      shopId: d['shopId'] ?? '',
      name: d['name'] ?? '',
      price: (d['price'] is num) ? (d['price'] as num).toDouble() : double.tryParse('${d['price']}') ?? 0.0,
      description: d['description'] ?? '',
      images: (d['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      category: d['category'] ?? '',
      stock: (d['stock'] is num) ? (d['stock'] as num).toInt() : int.tryParse('${d['stock']}') ?? 0,
      discount: (d['discount'] is num) ? (d['discount'] as num).toDouble() : double.tryParse('${d['discount']}') ?? 0.0,
      createdAt: (d['createdAt'] is Timestamp) ? (d['createdAt'] as Timestamp).toDate() : DateTime.now(),
      disabled: d['disabled'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'name': name,
      'price': price,
      'description': description,
      'images': images,
      'category': category,
      'stock': stock,
      'discount': discount,
      'createdAt': createdAt,
      'disabled': disabled,
    };
  }
}
