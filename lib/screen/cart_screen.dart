import 'package:ecommerce_app/provider/cart_provider.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) {
                      final c = cart.items[i];
                      return ListTile(
                        leading: Image.network(c.product['image'], width: 60, height: 60, fit: BoxFit.cover),
                        title: Text(c.product['name']),
                        subtitle: Text('৳ ${c.product['price']}'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.remove), onPressed: () => cart.decrease(c.product)),
                          Text('${c.quantity}'),
                          IconButton(icon: const Icon(Icons.add), onPressed: () => cart.increase(c.product)),
                        ]),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: ৳ ${cart.totalPrice().toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: () {
                          // implement checkout (create order in Firestore)
                        },
                        child: const Text('Checkout'),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
