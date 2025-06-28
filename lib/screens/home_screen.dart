import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'cuisine_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> cuisines = [];
  List<Map<String, dynamic>> cartItems = [];
  String _language = 'en';

  final Map<String, Map<String, String>> localizedStrings = {
    'en': {
      'restaurantName': 'Multi Cuisine Restaurant',
      'topDishes': 'Top Dishes',
      'viewCart': 'View Cart',
    },
    'hi': {
      'restaurantName': 'मल्टी कुज़ीन रेस्टोरेंट',
      'topDishes': 'शीर्ष व्यंजन',
      'viewCart': 'कार्ट देखें',
    }
  };

  @override
  void initState() {
    super.initState();
    fetchCuisines();
  }

  Future<void> fetchCuisines() async {
    final data = await ApiService.getItemList();
    setState(() {
      cuisines = data['cuisines'];
    });
  }

  void addToCart(Map dish, Map cuisine) {
    final existingIndex = cartItems.indexWhere((item) => item['item_id'] == dish['id']);
    setState(() {
      if (existingIndex != -1) {
        cartItems[existingIndex]['item_quantity'] += 1;
      } else {
        cartItems.add({
          'cuisine_id': cuisine['cuisine_id'],
          'item_id': dish['id'],
          'item_name': dish['name'],
          'item_price': double.parse(dish['price']),
          'item_quantity': 1,
          'item_image_url': dish['image_url'],
        });
      }
    });
  }

  void removeFromCart(String itemId) {
    final existingIndex = cartItems.indexWhere((item) => item['item_id'] == itemId);
    if (existingIndex != -1) {
      setState(() {
        if (cartItems[existingIndex]['item_quantity'] > 1) {
          cartItems[existingIndex]['item_quantity'] -= 1;
        } else {
          cartItems.removeAt(existingIndex);
        }
      });
    }
  }

  int getItemCount(String itemId) {
    final existingItem = cartItems.firstWhere(
          (item) => item['item_id'] == itemId,
      orElse: () => {},
    );
    return existingItem.isNotEmpty ? existingItem['item_quantity'] : 0;
  }

  @override
  Widget build(BuildContext context) {
    final langStrings = localizedStrings[_language]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(langStrings['restaurantName']!),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _language = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'hi', child: Text('हिंदी')),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: cuisines.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segment 1: Cuisine Horizontal Scroll
            SizedBox(
              height: 180,
              child: PageView.builder(
                itemCount: cuisines.length,
                controller: PageController(viewportFraction: 0.75),
                itemBuilder: (context, index) {
                  final cuisine = cuisines[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CuisineItemsScreen(
                                cuisineData: cuisine,
                                cartItems: cartItems,
                                addToCart: addToCart,
                                removeFromCart: removeFromCart,
                              )
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image:
                          NetworkImage(cuisine['cuisine_image_url']),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3),
                              BlendMode.darken),
                        ),
                      ),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        cuisine['cuisine_name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Segment 2: Top 4 Dishes
            Text(
              langStrings['topDishes']!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: cuisines
                    .expand((cuisine) => cuisine['items'])
                    .take(4)
                    .length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final allDishes = cuisines
                      .expand((cuisine) => cuisine['items'])
                      .toList();
                  final dish = allDishes[index];
                  final cuisine = cuisines.firstWhere((c) =>
                      c['items'].any((d) => d['id'] == dish['id']));
                  final count = getItemCount(dish['id']);

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            dish['image_url'],
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dish['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text("₹${dish['price']} • ⭐ ${dish['rating']}"),
                              const SizedBox(height: 8),
                              count == 0
                                  ? ElevatedButton.icon(
                                onPressed: () {
                                  addToCart(dish, cuisine);
                                },
                                icon: const Icon(Icons.add),
                                label: const Text("Add"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize:
                                  const Size(double.infinity, 36),
                                ),
                              )
                                  : Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove,
                                        color: Colors.red),
                                    onPressed: () {
                                      removeFromCart(dish['id']);
                                    },
                                  ),
                                  Text('$count',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                          FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add,
                                        color: Colors.green),
                                    onPressed: () {
                                      addToCart(dish, cuisine);
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: cartItems.isNotEmpty
          ? FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.shopping_cart),
        label: Text("${langStrings['viewCart']} (${cartItems.length})"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CartScreen(cartItems: cartItems),
            ),
          );
        },
      )
          : null,
    );
  }
}
