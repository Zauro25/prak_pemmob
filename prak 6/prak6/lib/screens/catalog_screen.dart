import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/cart_provider.dart';
import '../widgets/badge.dart' as custom_badge;
import 'cart_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  static final List<Item> _catalogItems = [
    Item(name: 'Laptop', price: 999.99),
    Item(name: 'Ipong', price: 699.99),
    Item(name: 'Hengpon', price: 149.99),
    Item(name: 'Keyboard', price: 79.99),
    Item(name: 'Tikus', price: 49.99),
    Item(name: 'Monitor', price: 299.99),
    Item(name: 'Webcam', price: 89.99),
    Item(name: 'USB Cable', price: 12.99),
    Item(name: 'External SSD', price: 159.99),
    Item(name: 'Gaming kursi', price: 249.99),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return custom_badge.CartBadge(
                value: cart.itemCount.toString(),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        itemCount: _catalogItems.length,
        itemBuilder: (context, index) {
          final item = _catalogItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  item.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '\$${item.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Consumer<CartProvider>(
                builder: (context, cart, _) {
                  final qty = cart.quantityFor(item);
                  return SizedBox(
                    width: 130,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Decrease quantity',
                          onPressed: qty > 0
                              ? () {
                                  cart.decrement(item);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${item.name} removed'),
                                      duration: const Duration(milliseconds: 800),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Qty',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              qty.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          tooltip: 'Increase quantity',
                          onPressed: () {
                            cart.increment(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.name} added'),
                                duration: const Duration(milliseconds: 800),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
