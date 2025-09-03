import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quick_court_booking/models/fnb_order_owner_model.dart';

class FnbOrderListScreen extends StatefulWidget {
  final int venueId;

  const FnbOrderListScreen({super.key, required this.venueId});

  @override
  State<FnbOrderListScreen> createState() => _FnbOrderListScreenState();
}

class _FnbOrderListScreenState extends State<FnbOrderListScreen> {
  bool isLoading = true;
  List<FnbOrderOwner> orders = [];
  String? error;

  String selectedStatusFilter = 'All';
  List<String> statusOptions = ['All', 'Pending', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('laravel_token');
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final url = Uri.parse(
          "http://192.168.1.22:8000/api/owner/venues/${widget.venueId}/fnb-orders");

      print("[DEBUG] Requesting: $url");
      print("[DEBUG] Token: Bearer $token");

      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
      });

      print("[DEBUG] Response status: ${response.statusCode}");
      print("[DEBUG] Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawOrders = data['orders'] as List<dynamic>;

        setState(() {
          orders =
              rawOrders.map((json) => FnbOrderOwner.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Gagal mengambil data: ${response.statusCode}");
      }
    } catch (e, stacktrace) {
      print("[DEBUG] Error: $e");
      print("[DEBUG] Stacktrace: $stacktrace");
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  List<FnbOrderOwner> get filteredOrders {
    if (selectedStatusFilter == 'All') return orders;
    return orders
        .where(
            (o) => o.status.toLowerCase() == selectedStatusFilter.toLowerCase())
        .toList();
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final url = Uri.parse(
          "http://192.168.1.22:8000/api/owner/fnb-orders/$orderId/status");

      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({"status": newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          final idx = orders.indexWhere((o) => o.id == orderId);
          if (idx != -1) {
            orders[idx] = orders[idx].copyWith(status: newStatus);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status pesanan diperbarui ke $newStatus")),
        );
      } else {
        throw Exception("Gagal update status");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan F&B')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text("Filter: "),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedStatusFilter,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedStatusFilter = value;
                      });
                    }
                  },
                  items: statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? ListView.builder(
                    itemCount: 6,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Container(height: 100),
                      ),
                    ),
                  )
                : error != null
                    ? Center(child: Text("Error: $error"))
                    : filteredOrders.isEmpty
                        ? const Center(child: Text("Tidak ada pesanan"))
                        : RefreshIndicator(
                            onRefresh: fetchOrders,
                            child: ListView.builder(
                              itemCount: filteredOrders.length,
                              padding: const EdgeInsets.all(12),
                              itemBuilder: (context, index) {
                                final order = filteredOrders[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(order.customerName,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            statusBadge(order.status),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text("Tanggal: ${order.date}"),
                                        Text(
                                            "Total: Rp ${order.total.toString()}"),
                                        const SizedBox(height: 6),
                                        Text("Item: ${order.items.join(', ')}"),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: PopupMenuButton<String>(
                                            onSelected: (value) {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title:
                                                      const Text("Konfirmasi"),
                                                  content: Text(
                                                      "Yakin ingin ubah status ke '$value'?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child:
                                                          const Text("Batal"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        updateOrderStatus(
                                                            order.id, value);
                                                      },
                                                      child: const Text(
                                                          "Ya, Ubah"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.more_vert),
                                            itemBuilder: (context) => const [
                                              PopupMenuItem(
                                                  value: 'pending',
                                                  child: Text('Pending')),
                                              PopupMenuItem(
                                                  value: 'completed',
                                                  child: Text('Completed')),
                                              PopupMenuItem(
                                                  value: 'cancelled',
                                                  child: Text('Cancelled')),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
