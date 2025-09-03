import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quick_court_booking/entry_point.dart';
import 'package:quick_court_booking/models/venue_detail_model.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_court_booking/helper/chat_helper.dart';

class SelectDateScreen extends StatefulWidget {
  final VenueDetail venue;
  final int venueId;

  const SelectDateScreen({
    super.key,
    required this.venue,
    required this.venueId,
  });

  @override
  State<SelectDateScreen> createState() => _SelectDateScreenState();
}

class _SelectDateScreenState extends State<SelectDateScreen> {
  List<String> slotTerpilih = [];
  int? tanggalTerpilihIndex;
  Set<String> slotTerbooked = {};
  List<dynamic> semuaSlot = [];

  @override
  Widget build(BuildContext context) {
    final sekarang = DateTime.now();
    final formatTanggal = DateFormat('EEE d MMM', 'id_ID');
    final listHari = List.generate(5, (index) {
      return formatTanggal.format(sekarang.add(Duration(days: index)));
    });

    final hargaTotal = slotTerpilih.fold(0, (total, slot) {
      final hargaPerSlot = int.tryParse(widget.venue.price) ?? 0;
      return total + hargaPerSlot;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Jadwal'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: listHari.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        tanggalTerpilihIndex = index;
                        slotTerpilih.clear();
                        semuaSlot.clear();
                      });

                      final selectedDate = listHari[index];
                      final fullDate = DateFormat('EEE d MMM yyyy', 'id_ID')
                          .parseLoose('$selectedDate ${DateTime.now().year}');
                      final formatted =
                          DateFormat('yyyy-MM-dd').format(fullDate);

                      final response = await http.get(Uri.parse(
                          'http://192.168.1.22:8000/api/venues/${widget.venue.id}/available-times?date=$formatted'));

                      if (response.statusCode == 200) {
                        final data = jsonDecode(response.body);
                        setState(() {
                          semuaSlot = data['slots'];
                        });
                      }

                      print('Response body: ${response.body}');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: tanggalTerpilihIndex == index
                            ? Colors.blue[50]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: tanggalTerpilihIndex == index
                              ? Colors.blue[700]!
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          listHari[index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: tanggalTerpilihIndex == index
                                ? Colors.blue[800]
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.venue.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.blue),
              ],
            ),
            const Divider(height: 32),
            Column(
              children: semuaSlot.map<Widget>((slot) {
                final display = '${slot['start_time']} - ${slot['end_time']}';
                final isTerpilih = slotTerpilih.contains(display);
                final isBooked = slot['is_booked'];

                return InkWell(
                  onTap: isBooked
                      ? null
                      : () {
                          setState(() {
                            if (isTerpilih) {
                              slotTerpilih.remove(display);
                            } else {
                              slotTerpilih.add(display);
                            }
                          });
                        },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBooked
                          ? Colors.grey[300]
                          : isTerpilih
                              ? Colors.blue[50]
                              : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isTerpilih ? Colors.blue[700]! : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        isBooked
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(slot['start_time'],
                                      style: const TextStyle(fontSize: 16)),
                                  const Text(
                                    'Booked',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(slot['start_time'],
                                      style: const TextStyle(fontSize: 16)),
                                  Text(display,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600])),
                                ],
                              ),
                        Text(
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(int.parse(widget.venue.price)),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Biaya',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    slotTerpilih.isEmpty
                        ? 'Rp -'
                        : NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(hargaTotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: slotTerpilih.isEmpty || tanggalTerpilihIndex == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KonfirmasiBookingScreen(
                              venue: widget.venue,
                              tanggalTerpilih: listHari[tanggalTerpilihIndex!],
                              slotTerpilih: slotTerpilih,
                              hargaTotal: hargaTotal,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Selanjutnya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KonfirmasiBookingScreen extends StatefulWidget {
  final VenueDetail venue;
  final String tanggalTerpilih;
  final List<String> slotTerpilih;
  final int hargaTotal;

  const KonfirmasiBookingScreen({
    super.key,
    required this.venue,
    required this.tanggalTerpilih,
    required this.slotTerpilih,
    required this.hargaTotal,
  });

  @override
  State<KonfirmasiBookingScreen> createState() =>
      _KonfirmasiBookingScreenState();
}

class _KonfirmasiBookingScreenState extends State<KonfirmasiBookingScreen> {
  bool isLoading = false;

  Future<void> _kirimBooking() async {
    if (widget.slotTerpilih.isEmpty) return;

    setState(() => isLoading = true);

    print("Venue ID: ${widget.venue.id}");
    print("Total price: ${widget.hargaTotal}");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('laravel_token');
      print('Token: $token');

      if (token == null) throw Exception('Token tidak ditemukan');

      final sortedSlots = widget.slotTerpilih..sort();
      final startTime = sortedSlots.first.split(' - ')[0];
      final endTime = sortedSlots.last.split(' - ')[1];

      if (widget.tanggalTerpilih.trim().isEmpty) {
        throw Exception('Tanggal belum dipilih');
      }
      final sekarang = DateTime.now();
      final parsedDate = DateFormat('EEE d MMM yyyy', 'id_ID')
          .parseLoose('${widget.tanggalTerpilih} ${sekarang.year}');
      final bookingDate = DateFormat('yyyy-MM-dd').format(parsedDate);

      final response = await http.post(
        Uri.parse('http://192.168.1.22:8000/api/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'venue_id': widget.venue.id,
          'contact_number': '08123456789',
          'booking_date': bookingDate,
          'start_time': startTime,
          'end_time': endTime,
          'total_price': widget.hargaTotal,
          'payment_method': 'midtrans',
        }),
      );

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 && responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking berhasil!')),
        );

        // final prefs = await SharedPreferences.getInstance();
        // final currentUserId = prefs.getString('user_id') ?? '';
        // final ownerId = widget.venue.ownerId;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EntryPoint()),
        );
      } else {
        throw Exception(responseData['message'] ?? 'Gagal booking');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Booking'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.venue.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Tanggal: ${widget.tanggalTerpilih}'),
            const SizedBox(height: 16),
            const Text('Jam Booking:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.slotTerpilih
                  .map((slot) => Chip(label: Text(slot)))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Biaya',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  NumberFormat.currency(
                          locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                      .format(widget.hargaTotal),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _kirimBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Konfirmasi', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
