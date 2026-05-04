import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:quick_court_booking/models/fnb_categories_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_court_booking/models/fnb_menu_model.dart';
import 'dart:io';

class FnbMenuCrudScreen extends StatefulWidget {
  final int venueId;

  const FnbMenuCrudScreen({super.key, required this.venueId});

  @override
  State<FnbMenuCrudScreen> createState() => _FnbMenuCrudScreenState();
}

class _FnbMenuCrudScreenState extends State<FnbMenuCrudScreen> {
  List<FnbMenu> menus = [];
  List<FnbCategoriesModel> categories = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchMenus();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('laravel_token');
  }

  Future<void> fetchCategories() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final url = Uri.parse("http://192.168.1.10:8000/api/fnb-categories");
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        setState(() {
          categories =
              data.map((json) => FnbCategoriesModel.fromJson(json)).toList();
        });
      } else {
        throw Exception("Gagal mengambil categories");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error load categories: $e")),
      );
    }
  }

  Future<void> fetchMenus() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final url = Uri.parse(
          "http://192.168.1.10:8000/api/owner/venues/${widget.venueId}/fnb-menus");
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data['menus'] is List) {
          final rawMenus = data['menus'] as List<dynamic>;
          setState(() {
            menus = rawMenus.map((json) => FnbMenu.fromJson(json)).toList();
            isLoading = false;
          });
        } else {
          throw Exception("Format data menu tidak sesuai");
        }
      } else {
        throw Exception("Gagal mengambil menu: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> deleteMenu(int menuId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final url =
          Uri.parse("http://192.168.1.10:8000/api/owner/fnb-menus/$menuId");

      final response = await http.delete(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        setState(() {
          menus.removeWhere((menu) => menu.id == menuId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu berhasil dihapus")),
        );
      } else {
        throw Exception("Gagal menghapus menu");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> showAddEditMenuDialog({FnbMenu? menu}) async {
    final nameController = TextEditingController(text: menu?.name ?? "");
    final priceController =
        TextEditingController(text: menu?.price.toString() ?? "");
    final descriptionController =
        TextEditingController(text: menu?.description ?? "");
    // Handle category IDs as Set<int>
    Set<int> selectedCategoryIds = menu != null ? {menu.categoryId} : <int>{};
    File? selectedImage;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            menu == null ? "Tambah Menu" : "Edit Menu",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Upload Gambar
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setStateDialog(() {
                          selectedImage = File(picked.path);
                        });
                      }
                    },
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : menu?.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    menu!.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
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
                  const SizedBox(height: 20),

                  // Nama Menu
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Nama Menu",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "Nama harus diisi"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Harga
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Harga",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Harga harus diisi";
                      }
                      if (int.tryParse(value) == null) {
                        return "Harga harus angka";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Pilih Kategori
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Pilih Kategori",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  categories.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: categories.map((category) {
                            final isSelected =
                                selectedCategoryIds.contains(category.id);
                            return FilterChip(
                              label: Text(category.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setStateDialog(() {
                                  if (selected) {
                                    selectedCategoryIds.add(category.id);
                                  } else {
                                    selectedCategoryIds.remove(category.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 16),

                  // Deskripsi
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Deskripsi",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (selectedCategoryIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Pilih minimal satu kategori")),
                    );
                    return;
                  }

                  final name = nameController.text.trim();
                  final price = int.parse(priceController.text.trim());
                  final description = descriptionController.text.trim();

                  if (menu == null) {
                    await addMenu(
                      name,
                      price,
                      description,
                      selectedImage,
                      selectedCategoryIds.toList(),
                    );
                  } else {
                    await updateMenu(
                      menu.id,
                      name,
                      price,
                      description,
                      selectedImage,
                      selectedCategoryIds.toList(),
                    );
                  }

                  Navigator.pop(context);
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addMenu(String name, int price, String description, File? image,
      List<int> categoryIds) async {
    try {
      print("Starting addMenu...");
      final token = await _getToken();
      print("Token: $token");

      if (token == null) throw Exception("Token tidak ditemukan");

      final uri = Uri.parse(
          "http://192.168.1.10:8000/api/owner/venues/${widget.venueId}/fnb-menus");
      print("POST URI: $uri");

      final request = http.MultipartRequest("POST", uri);

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields['name'] = name;
      request.fields['price'] = price.toString();
      request.fields['description'] = description;
      request.fields['categories_id'] = categoryIds.first.toString();

      print("Fields: ${request.fields}");

      if (image != null) {
        print("Adding image file: ${image.path}");
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      } else {
        print("No image provided");
      }

      final response = await request.send();
      print("Response status code: ${response.statusCode}");

      final respStr = await response.stream.bytesToString();
      print("Response body: $respStr");

      if (response.statusCode == 201) {
        print("Menu successfully added, refreshing menu list...");
        await fetchMenus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu berhasil ditambahkan")),
        );
      } else {
        throw Exception("Gagal tambah menu: $respStr");
      }
    } catch (e) {
      print("Error in addMenu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> updateMenu(int menuId, String name, int price,
      String description, File? image, List<int> categoryIds) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final uri =
          Uri.parse("http://192.168.1.10:8000/api/owner/fnb-menus/$menuId");
      final request = http.MultipartRequest("POST", uri);

      request.headers["Authorization"] = "Bearer $token";
      request.fields['_method'] = 'PUT';

      request.fields['name'] = name;
      request.fields['price'] = price.toString();
      request.fields['description'] = description;
      request.fields['category_ids'] = json.encode(categoryIds);

      if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        await fetchMenus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu berhasil diupdate")),
        );
      } else {
        final respStr = await response.stream.bytesToString();
        throw Exception("Gagal update menu: $respStr");
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
      appBar: AppBar(
        title: const Text("Menu F&B"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditMenuDialog(),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text("Error: $error"))
              : menus.isEmpty
                  ? const Center(child: Text("Belum ada menu"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: menus.length,
                      itemBuilder: (context, index) {
                        final menu = menus[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: menu.imageUrl != null
                                  ? Image.network(
                                      menu.imageUrl!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                    )
                                  : const Icon(Icons.fastfood, size: 40),
                            ),
                            title: Text(menu.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Text("Rp ${menu.price}",
                                style: const TextStyle(fontSize: 14)),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == "edit") {
                                  await showAddEditMenuDialog(menu: menu);
                                } else if (value == "delete") {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Konfirmasi"),
                                      content: Text("Hapus menu ${menu.name}?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Batal")),
                                        ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Hapus")),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await deleteMenu(menu.id);
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                    value: "edit", child: Text("Edit")),
                                const PopupMenuItem(
                                    value: "delete", child: Text("Hapus")),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
