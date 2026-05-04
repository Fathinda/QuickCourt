import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:quick_court_booking/models/venue_promo_model.dart';
import 'package:image_picker/image_picker.dart';

class OwnerPromoListScreen extends StatefulWidget {
  final int venueId;

  const OwnerPromoListScreen({super.key, required this.venueId});

  @override
  State<OwnerPromoListScreen> createState() => _OwnerPromoListScreenState();
}

class _OwnerPromoListScreenState extends State<OwnerPromoListScreen> {
  List<VenuePromo> promos = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPromos();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('laravel_token');
  }

  Future<void> fetchPromos() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final url = Uri.parse(
          "http://192.168.1.10:8000/api/owner/venue/${widget.venueId}/promos");

      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("📥 Raw response: $data");
        if (data is Map<String, dynamic> && data['promos'] is List) {
          final rawPromos = data['promos'] as List<dynamic>;
          for (var p in rawPromos) {
            print("➡️ Promo JSON: $p");
          }
          setState(() {
            promos =
                rawPromos.map((json) => VenuePromo.fromJson(json)).toList();
            isLoading = false;
          });

          for (var p in promos) {
            print("✅ Parsed promo: ${p.title}, img=${p.imageUrl}, "
                "start=${p.startDate}, end=${p.endDate}");
          }
        } else {
          throw Exception("Format data promo tidak sesuai");
        }
      } else {
        throw Exception("Gagal mengambil promo: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> deletePromo(int promoId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final url =
          Uri.parse("http://192.168.1.10:8000/api/owner/promos/$promoId");

      final response = await http.delete(url, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        setState(() {
          promos.removeWhere((promo) => promo.id == promoId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Promo berhasil dihapus")),
        );
      } else {
        throw Exception("Gagal menghapus promo");
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text("Error: $error"))
              : promos.isEmpty
                  ? const Center(child: Text("Belum ada promo"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: promos.length,
                      itemBuilder: (context, index) {
                        final promo = promos[index];

                        final dateFormat = DateFormat('dd MMM yyyy');
                        final start = dateFormat.format(promo.startDate);
                        final end = dateFormat.format(promo.endDate);
                        print(
                            "🖼️ Tampilkan promo: ${promo.title}, img=${promo.imageUrl}");

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Gambar promo
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: promo.imageUrl != null
                                      ? Image.network(
                                          promo.imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            print(
                                                "❌ Gagal load image: ${promo.imageUrl}, error=$error");
                                            return const Icon(
                                                Icons.broken_image,
                                                size: 80);
                                          },
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.local_offer,
                                              size: 40),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                // Info + tombol opsi
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  promo.title,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (promo.description != null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4.0),
                                                    child: Text(
                                                      promo.description!,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  "$start - $end",
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) async {
                                              if (value == "delete") {
                                                final confirmed =
                                                    await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        "Hapus Promo?"),
                                                    content: Text(
                                                        "Yakin ingin hapus '${promo.title}'?"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context, false),
                                                        child:
                                                            const Text("Batal"),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context, true),
                                                        child:
                                                            const Text("Hapus"),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                if (confirmed == true) {
                                                  await deletePromo(promo.id);
                                                }
                                              }
                                            },
                                            itemBuilder: (context) => const [
                                              PopupMenuItem(
                                                  value: "delete",
                                                  child: Text("Hapus")),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddPromoDialog(
              venueId: widget.venueId,
              onPromoAdded: fetchPromos,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddPromoDialog extends StatefulWidget {
  final int venueId;
  final VoidCallback onPromoAdded;

  const AddPromoDialog({
    super.key,
    required this.venueId,
    required this.onPromoAdded,
  });

  @override
  State<AddPromoDialog> createState() => _AddPromoDialogState();
}

class _AddPromoDialogState extends State<AddPromoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  File? _selectedImage;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('laravel_token');
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tanggal mulai dan akhir wajib diisi")),
      );
      return;
    }
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gambar wajib dipilih")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final uri = Uri.parse(
          "http://192.168.1.10:8000/api/owner/venue/${widget.venueId}/promos");
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['title'] = _titleController.text.trim()
        ..fields['description'] = _descriptionController.text.trim()
        ..fields['start_date'] = DateFormat('yyyy-MM-dd').format(_startDate!)
        ..fields['end_date'] = DateFormat('yyyy-MM-dd').format(_endDate!)
        ..files.add(await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        ));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        widget.onPromoAdded();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Promo berhasil ditambahkan")),
        );
      } else {
        final msg = jsonDecode(respStr)['message'] ?? 'Gagal menambahkan promo';
        throw Exception(msg);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Tambah Promo",
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image upload section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!,
                              fit: BoxFit.cover, width: double.infinity),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_a_photo,
                                size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("Pilih Gambar",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Judul Promo",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Judul wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Deskripsi Promo",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? "Deskripsi wajib diisi"
                    : null,
              ),
              const SizedBox(height: 16),
              // Date pickers
              Row(
                children: [
                  Expanded(
                    child: Text(_startDate == null
                        ? "Mulai: Belum dipilih"
                        : "Mulai: ${DateFormat('dd MMM yyyy').format(_startDate!)}"),
                  ),
                  TextButton(
                      onPressed: () => _selectDate(context, true),
                      child: const Text("Pilih")),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(_endDate == null
                        ? "Berakhir: Belum dipilih"
                        : "Berakhir: ${DateFormat('dd MMM yyyy').format(_endDate!)}"),
                  ),
                  TextButton(
                      onPressed: () => _selectDate(context, false),
                      child: const Text("Pilih")),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: const Text("Batal")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Simpan"),
        ),
      ],
    );
  }
}
