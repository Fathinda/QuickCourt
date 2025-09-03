import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_court_booking/models/cart_model.dart';

class CheckoutScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.total,
  });

  Future<void> createManualPayment(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.22:8000/api/manual-payments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'total': total,
          'items': cartItems
              .map((item) => {
                    'menu_id': item.cartId,
                    'name': item.name,
                    'qty': item.qty,
                    'price': item.price,
                  })
              .toList(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // ambil orderId & total dari backend
        final orderId = data['order']['id'];
        final orderTotal = data['total'];

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Pesanan Dibuat"),
            content: Text(
              "Order #$orderId berhasil dibuat.\n\n"
              "Total Pembayaran: Rp${orderTotal.toString()}\n\n"
              "Silakan transfer ke:\n"
              "BCA 123456789 a/n QuickCourt",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? "Gagal membuat pesanan");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pemesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    'Ringkasan Pesanan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  ...cartItems.map(
                    (item) => ListTile(
                      title: Text(item.name),
                      subtitle: Text('Qty: ${item.qty}'),
                      trailing: Text(
                        'Rp${(item.price * item.qty).toStringAsFixed(0)}',
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      'Rp${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => createManualPayment(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Buat Pesanan'),
            ),
          ],
        ),
      ),
    );
  }
}
