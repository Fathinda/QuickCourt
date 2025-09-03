import 'package:flutter/foundation.dart';
import 'package:quick_court_booking/models/cart_model.dart';
import 'package:http/http.dart' as http;
import 'package:quick_court_booking/models/fnb_menu_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_court_booking/state/menu_state.dart';

final ValueNotifier<List<CartItem>> cart = ValueNotifier<List<CartItem>>([]);

const String baseUrl = 'http://192.168.1.22:8000/api';

Future<String> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('laravel_token') ?? '';
  if (token.isEmpty) {
    throw Exception('Token tidak ditemukan. User belum login.');
  }
  return token;
}

Future<void> loadCartFromBackend() async {
  try {
    final token = await getToken();
    debugPrint('🟢 Token didapat: ${token.isNotEmpty ? "ADA" : "TIDAK ADA"}');

    final response = await http.get(
      Uri.parse('$baseUrl/cart-items'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    debugPrint('🟢 Response status code: ${response.statusCode}');
    debugPrint('🟢 Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = json.decode(response.body);

      debugPrint('🟢 Response JSON root keys: ${body.keys.toList()}');

      final List<dynamic> items = body['items'] ?? [];
      debugPrint('🟢 Items count: ${items.length}');

      final fetchedCart = items.map((e) {
        final item = CartItem.fromJson(e);
        debugPrint(
            '🟢 Parsed item: ${item.name}, qty: ${item.qty}, price: ${item.price}');
        return item;
      }).toList();

      cart.value = fetchedCart;
      debugPrint(
          '🟢 Cart updated, total items in cart.value: ${cart.value.length}');
    } else {
      throw Exception('Failed to fetch cart: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('🔴 Error loading cart: $e');
  }
}

Future<void> addToCartBackend(int menuId, int qty) async {
  final token = await getToken();
  final url = Uri.parse('$baseUrl/add-cart');

  debugPrint('🟢 Attempting to call: $url');
  debugPrint('🟢 Token: ${token.isNotEmpty ? "exists" : "missing"}');
  debugPrint(
      '🟢 Payload: ${jsonEncode({"fnb_menu_id": menuId, "quantity": qty})}');

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fnb_menu_id': menuId,
        'quantity': qty,
      }),
    );

    debugPrint('🟢 Response status: ${response.statusCode}');
    debugPrint('🟢 Response body: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('🔴 Backend error: ${response.body}');
      throw Exception('Failed to add to cart. Status: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('🔴 Network error: $e');
    rethrow;
  }
}

Future<void> removeFromCartBackend(int cartItemId) async {
  final token = await getToken();
  final response = await http.delete(
    Uri.parse('$baseUrl/fnb-cart/$cartItemId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception('Failed to remove from cart');
  }
}

Future<void> addToCartLocalAndServer(CartItem item) async {
  try {
    if (item.imageUrl == null) {
      final menuItem = fnbMenuList.value.firstWhere(
        (menu) => menu.id == item.menuId,
        orElse: () => FnbMenu(
          id: 0,
          name: '',
          image: '',
          price: 0,
          categoryId: 0,
        ),
      );
      if (menuItem.id != 0) {
        item = CartItem(
          cartId: item.cartId,
          menuId: item.menuId,
          name: item.name,
          price: item.price,
          imageUrl: item.imageUrl ?? menuItem.imageUrl,
          qty: item.qty,
        );
      }
    }

    await addToCartBackend(item.menuId, item.qty);

    final list = List<CartItem>.from(cart.value);
    final idx = list.indexWhere((e) => e.menuId == item.menuId);
    if (idx >= 0) {
      list[idx].qty += item.qty;
    } else {
      list.add(item);
    }

    cart.value = list;
  } catch (e) {
    debugPrint('Failed to add to cart on backend: $e');
    rethrow;
  }
}

Future<void> removeFromCartLocalAndServer(int menuId, int cartItemId) async {
  try {
    await removeFromCartBackend(cartItemId);
    final list = List<CartItem>.from(cart.value)
      ..removeWhere((e) => e.cartId == cartItemId);
    cart.value = list;
  } catch (e) {
    debugPrint('Failed to remove from cart on backend: $e');
    rethrow;
  }
}

void clearCart() => cart.value = [];

int cartCount() => cart.value.fold(0, (s, e) => s + e.qty);

double cartTotal() =>
    cart.value.fold(0.0, (s, e) => s + e.qty * e.price.toDouble());

Future<void> updateCartQuantityBackend(int cartItemId, int qty) async {
  final token = await getToken();
  final response = await http.put(
    Uri.parse('$baseUrl/fnb-cart/$cartItemId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'quantity': qty}),
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception('Failed to update cart quantity');
  }
}

Future<void> updateQuantityLocalAndServer(CartItem item, int newQty) async {
  if (item.cartId == null) {
    throw Exception('Cart item ID tidak tersedia');
  }
  await updateCartQuantityBackend(item.cartId!, newQty);

  final list = List<CartItem>.from(cart.value);
  final idx = list.indexWhere((e) => e.cartId == item.cartId);
  if (idx >= 0) {
    list[idx].qty = newQty;
    cart.value = list;
  }
}
