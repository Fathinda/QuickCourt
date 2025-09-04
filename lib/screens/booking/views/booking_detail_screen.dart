import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class DetailBookingScreen extends StatefulWidget {
  final int bookingId;

  const DetailBookingScreen({super.key, required this.bookingId});

  @override
  _DetailBookingScreenState createState() => _DetailBookingScreenState();
}

class _DetailBookingScreenState extends State<DetailBookingScreen> {
  Map<String, dynamic>? booking;
  bool loading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  Future<void> _loadTokenAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("laravel_token");
    await _fetchBookingDetail();
  }

  Future<void> _fetchBookingDetail() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.19:8000/api/bookings/${widget.bookingId}"),
        headers: {
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final result = Map<String, dynamic>.from(jsonDecode(response.body));
        final bookingData = Map<String, dynamic>.from(result['data']);

        setState(() {
          booking = bookingData;
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengambil detail booking")),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetch: $e")),
      );
    }
  }

  Future<void> _showManualPaymentDialog(String rekening, int paymentId) async {
    PlatformFile? selectedFile;
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text("Bayar Manual"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Silakan transfer ke rekening berikut:\n"),
                  SelectableText(rekening,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: Text(selectedFile != null
                        ? "File dipilih: ${selectedFile!.name}"
                        : "Upload Bukti Pembayaran"),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                      );
                      if (result != null && result.files.isNotEmpty) {
                        setState(() {
                          selectedFile = result.files.first;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text("Tutup"),
              ),
              ElevatedButton(
                onPressed: (selectedFile == null || isLoading)
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          final request = http.MultipartRequest(
                            'POST',
                            Uri.parse(
                                "http://192.168.1.19:8000/api/payments/$paymentId/pay"),
                          );

                          if (token != null) {
                            request.headers['Authorization'] = 'Bearer $token';
                          }

                          request.files.add(await http.MultipartFile.fromPath(
                              'receipt', selectedFile!.path!));

                          final response = await request.send();

                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Pembayaran berhasil dikirim")),
                            );
                            Navigator.pop(context);
                            await _fetchBookingDetail();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Gagal mengirim pembayaran")),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Bayar"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _payBooking() async {
    if (booking == null) return;

    try {
      final response = await http.post(
        Uri.parse(
            "http://192.168.1.19:8000/api/bookings/${widget.bookingId}/pay"),
        headers: {
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final paymentId = data['payment_id'];
        final manualInfo = data['manual_payment_info'];

        // Update state booking biar payment tersimpan
        setState(() {
          booking?['payment'] = {
            "id": paymentId,
            "status": "pending",
            "payment_method": "manual",
          };
        });

        // Tampilkan dialog instruksi
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Informasi Pembayaran Manual'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bank: ${manualInfo['bank_name']}'),
                Text('Nomor Rekening: ${manualInfo['account_number']}'),
                Text('Atas Nama: ${manualInfo['account_holder']}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _uploadReceipt(paymentId);
                  },
                  child: const Text('Upload Bukti Pembayaran'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              )
            ],
          ),
        );
      } else {
        final message = data['message'] ?? "Gagal memproses pembayaran manual";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _uploadReceipt(int paymentId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            "http://192.168.1.19:8000/api/payments/$paymentId/upload-receipt"),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files
          .add(await http.MultipartFile.fromPath('receipt', file.path!));

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bukti berhasil diupload")),
        );
        await _fetchBookingDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal upload bukti")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("$label disalin!")));
  }

  void _openMap(double? lat, double? lng) async {
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Koordinat tidak tersedia")),
      );
      return;
    }
    final uri =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareBooking(Map<String, dynamic> booking) {
    final venue = Map<String, dynamic>.from(booking['venue'] ?? {});
    final city = (venue['city'] != null
            ? Map<String, dynamic>.from(venue['city'])['name']
            : '-') ??
        '-';

    final text = """
Booking di ${venue['name'] ?? 'Unknown'}
Kota: $city
Tanggal: ${booking['booking_date']?.substring(0, 10) ?? '-'}
Jam: ${booking['start_time'] ?? '-'} - ${booking['end_time'] ?? '-'}
Harga: Rp${double.tryParse(booking['total_price']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}
Status: ${booking['status'] ?? '-'}
""";
    Share.share(text);
  }

  Widget infoCard(String label, String value, {VoidCallback? onCopy}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: onCopy != null
            ? IconButton(icon: const Icon(Icons.copy), onPressed: onCopy)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Detail Booking")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Detail Booking")),
        body: const Center(child: Text("Booking tidak ditemukan")),
      );
    }

    final venue = Map<String, dynamic>.from(booking!['venue'] ?? {});
    final city = (venue['city'] != null &&
            venue['city'] is Map<String, dynamic> &&
            venue['city']['name'] != null)
        ? venue['city']['name']
        : '-';
    final bookingDate = booking!['booking_date'] ?? '';
    final startTime = booking!['start_time'] ?? '';
    final endTime = booking!['end_time'] ?? '';
    final totalPrice =
        double.tryParse(booking!['total_price']?.toString() ?? '0') ?? 0.0;
    final status = booking!['status'] ?? '';
    final payment = booking!['payment'];

    final imageUrl = (venue['primary_image'] != null &&
            venue['primary_image']['image_url'] != null)
        ? "http://192.168.1.19:8000/storage/${venue['primary_image']['image_url']}"
        : '';

    final lat = double.tryParse(venue['latitude']?.toString() ?? '');
    final lng = double.tryParse(venue['longitude']?.toString() ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Booking"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareBooking(booking!),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, size: 60, color: Colors.grey),
            ),
          const SizedBox(height: 16),
          infoCard("Venue", venue['name'] ?? 'Unknown',
              onCopy: () => _copyToClipboard(venue['name'] ?? '', "Venue")),
          infoCard("Kota", city, onCopy: () => _copyToClipboard(city, "Kota")),
          infoCard("Tanggal",
              bookingDate.isNotEmpty ? bookingDate.substring(0, 10) : '-',
              onCopy: () => _copyToClipboard(
                  bookingDate.isNotEmpty ? bookingDate.substring(0, 10) : '-',
                  "Tanggal")),
          infoCard("Jam", "$startTime - $endTime",
              onCopy: () => _copyToClipboard("$startTime - $endTime", "Jam")),
          infoCard("Harga", "Rp${totalPrice.toStringAsFixed(0)}",
              onCopy: () => _copyToClipboard(
                  "Rp${totalPrice.toStringAsFixed(0)}", "Harga")),
          infoCard("Status", status.toUpperCase()),
          if (lat != null && lng != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: () => _openMap(lat, lng),
                icon: const Icon(Icons.map),
                label: const Text("Buka Map"),
              ),
            ),
          const SizedBox(height: 16),
          if (status.toLowerCase() == 'pending')
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _payBooking,
                  child: const Text("Bayar Sekarang"),
                ),
                const SizedBox(height: 10),
              ],
            ),
        ]),
      ),
    );
  }
}
