class CartModel {
  final String productId;
  final Map<String, dynamic> product;
  int quantity;

  CartModel({
    required this.productId,
    required this.product,
    required this.quantity,
  });
}
