import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:quick_court_booking/entry_point.dart';
import 'package:quick_court_booking/models/cart_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  File? _paymentReceipt;
  bool _isSubmitting = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _paymentReceipt = File(pickedFile.path);
      });
    }
  }

  Future<void> checkoutFromCart(
      BuildContext rootContext, BuildContext dialogContext) async {
    if (_paymentReceipt == null) {
      ScaffoldMessenger.of(rootContext).showSnackBar(
        const SnackBar(content: Text("Mohon upload bukti pembayaran.")),
      );
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("laravel_token");

      if (token == null) {
        throw Exception("User tidak terautentikasi");
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.10:8000/api/fnb-cart/checkout'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'payment_receipt',
          _paymentReceipt!.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final orderId = data['order']['id'];
        final orderTotal = data['order']['total_amount'];

        if (mounted) {
          Navigator.pop(dialogContext); // tutup dialog konfirmasi

          showDialog(
            context: rootContext,
            builder: (_) => AlertDialog(
              title: const Text("Pesanan Dibuat"),
              content: Text(
                "Order #$orderId berhasil dibuat.\n\n"
                "Total Pembayaran: Rp${orderTotal.toString()}",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(rootContext).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => EntryPoint()),
                      (route) => false,
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? "Gagal membuat pesanan");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(rootContext).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void showPaymentDialog(BuildContext rootContext) {
    showDialog(
      context: rootContext,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter setStateDialog) {
            return AlertDialog(
              title: const Text("Konfirmasi Pembayaran"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Silakan transfer ke rekening berikut:\n\n"
                    "BCA 123456789\nA/N QuickCourt\n\n"
                    "Upload bukti pembayaran di bawah.",
                  ),
                  const SizedBox(height: 10),
                  _paymentReceipt != null
                      ? Image.file(_paymentReceipt!, height: 150)
                      : const Text("Belum ada gambar yang dipilih."),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (pickedFile != null) {
                        setState(() {
                          _paymentReceipt = File(pickedFile.path);
                        });
                        setStateDialog(() {});
                      }
                    },
                    child: const Text("Pilih Bukti Pembayaran"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => checkoutFromCart(rootContext, dialogContext),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text("Bayar"),
                ),
              ],
            );
          },
        );
      },
    );
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
                  ...widget.cartItems.map(
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
                      'Rp${widget.total.toStringAsFixed(0)}',
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
              onPressed: () => showPaymentDialog(context),
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
