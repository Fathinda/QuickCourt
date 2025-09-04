import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_court_booking/models/cart_model.dart';
import 'dart:convert';

import 'package:quick_court_booking/models/fnb_category_model.dart';
import 'package:quick_court_booking/models/fnb_menu_model.dart';
import 'package:quick_court_booking/screens/cart/views/cart_screen.dart';
import 'package:quick_court_booking/services/cart_services.dart';

class FnbMenuScreen extends StatefulWidget {
  final int venueId;
  final String venueName;

  const FnbMenuScreen({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  State<FnbMenuScreen> createState() => _FnbMenuScreenState();
}

class _FnbMenuScreenState extends State<FnbMenuScreen> {
  List<FnbCategory> categories = [];
  List<FnbMenu> allMenus = [];
  List<FnbMenu> filteredMenus = [];
  List<FnbMenu> cartItems = [];
  int? selectedCategoryId;

  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    print("Memuat FNB untuk venueId: ${widget.venueId}");
    fetchCategoriesAndMenus();
  }

  Future<void> fetchCategoriesAndMenus() async {
    try {
      final catRes = await http.get(
        Uri.parse(
            'http://192.168.1.19:8000/api/fnb/categories/venue/${widget.venueId}'),
      );
      final menuRes = await http.get(
        Uri.parse(
            'http://192.168.1.19:8000/api/fnb/menu/venue/${widget.venueId}'),
      );

      if (!mounted) return;

      if (catRes.statusCode == 200 && menuRes.statusCode == 200) {
        final catData = jsonDecode(catRes.body) as List;
        final menuData = jsonDecode(menuRes.body) as List;

        setState(() {
          categories = catData.map((e) => FnbCategory.fromJson(e)).toList();
          allMenus = menuData.map((e) => FnbMenu.fromJson(e)).toList();
          filteredMenus = allMenus;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      print("Fetch error: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  void filterMenusByCategory(int? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      if (categoryId == null) {
        filteredMenus = allMenus;
      } else {
        filteredMenus =
            allMenus.where((m) => m.categoryId == categoryId).toList();
      }
    });
  }

  Widget buildImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 40),
      );
    } else {
      return const Icon(Icons.fastfood, size: 40);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FNB Zone'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Center(child: Text("Gagal memuat data. Coba lagi nanti."))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.blue.shade200],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                            widget.venueName,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Change",
                                style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text("All"),
                            selected: selectedCategoryId == null,
                            onSelected: (_) => filterMenusByCategory(null),
                          ),
                          const SizedBox(width: 6),
                          ...categories.map((c) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: ChoiceChip(
                                  label: Text(c.name),
                                  selected: selectedCategoryId == c.id,
                                  onSelected: (_) =>
                                      filterMenusByCategory(c.id),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                        child: filteredMenus.isEmpty
                            ? const Center(child: Text("Belum ada menu FNB."))
                            : ListView.separated(
                                itemCount: filteredMenus.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final item = filteredMenus[index];

                                  return SizedBox(
                                    height: 100,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: buildImage(item.imageUrl),
                                        ),
                                      ),
                                      title: Text(
                                        item.name,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        "Rp${item.price}",
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      trailing: SizedBox(
                                        width: 70,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final newItem = CartItem(
                                              menuId: item.id,
                                              name: item.name,
                                              price: item.price,
                                              imageUrl: item.imageUrl,
                                              qty: 1,
                                            );

                                            try {
                                              await addToCartLocalAndServer(
                                                  newItem);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "${item.name} ditambahkan ke keranjang")),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "Gagal menambahkan ${item.name} ke keranjang")),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.zero,
                                            textStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          child: const Text("Add"),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )),
                  ],
                ),
    );
  }
}
