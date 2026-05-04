import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quick_court_booking/constants.dart';
import 'package:quick_court_booking/entry_point.dart';
import 'package:quick_court_booking/models/venue_detail_model.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quick_court_booking/screens/booking/views/booking_detail_screen.dart';
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
            // Date selector
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: listHari.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = tanggalTerpilihIndex == index;
                  final parts = listHari[index].split(' ');
                  final day = parts.length > 0 ? parts[0] : '';
                  final date = parts.length > 1 ? parts[1] : '';
                  final month = parts.length > 2 ? parts[2] : '';

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
                          'http://192.168.1.10:8000/api/venues/${widget.venue.id}/available-times?date=$formatted'));

                      if (response.statusCode == 200) {
                        final data = jsonDecode(response.body);
                        setState(() {
                          semuaSlot = data['slots'];
                        });
                      }

                      print('Response body: ${response.body}');
                    },
                    child: AnimatedContainer(
                      duration: animDurationMedium,
                      curve: Curves.easeInOutCubic,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected ? primaryGradient : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? null
                            : Border.all(color: blackColor10, width: 1.5),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : blackColor40,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$date $month',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isSelected ? Colors.white : blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Venue name
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(cardBorderRadius),
                boxShadow: softShadowSm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.venue.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chevron_right,
                        color: primaryColor, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Time slots
            if (semuaSlot.isEmpty && tanggalTerpilihIndex != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(cardBorderRadius),
                ),
                child: const Center(
                  child: Text(
                    'Tidak ada slot tersedia',
                    style: TextStyle(color: blackColor40, fontSize: 14),
                  ),
                ),
              ),

            ...semuaSlot.map<Widget>((slot) {
              final display = '${slot['start_time']} - ${slot['end_time']}';
              final isTerpilih = slotTerpilih.contains(display);
              final isBooked = slot['is_booked'];

              return GestureDetector(
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
                child: AnimatedContainer(
                  duration: animDurationMedium,
                  curve: Curves.easeInOutCubic,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isTerpilih ? primaryGradient : null,
                    color: isBooked
                        ? surfaceColor
                        : isTerpilih
                            ? null
                            : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: (!isTerpilih && !isBooked)
                        ? Border.all(color: blackColor10, width: 1.5)
                        : null,
                    boxShadow: isTerpilih
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Checkmark icon
                          AnimatedContainer(
                            duration: animDurationFast,
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient:
                                  isTerpilih ? null : null,
                              color: isBooked
                                  ? Colors.grey[300]
                                  : isTerpilih
                                      ? Colors.white.withOpacity(0.25)
                                      : surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: isBooked
                                ? const Icon(Icons.close_rounded,
                                    size: 14, color: Colors.grey)
                                : isTerpilih
                                    ? const Icon(Icons.check_rounded,
                                        size: 16, color: Colors.white)
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          isBooked
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(slot['start_time'],
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: blackColor40,
                                            decoration:
                                                TextDecoration.lineThrough)),
                                    const Text(
                                      'Booked',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: errorColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      slot['start_time'],
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isTerpilih
                                            ? Colors.white
                                            : blackColor,
                                      ),
                                    ),
                                    Text(
                                      display,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isTerpilih
                                            ? Colors.white.withOpacity(0.7)
                                            : blackColor40,
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(int.parse(widget.venue.price)),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isBooked
                              ? blackColor40
                              : isTerpilih
                                  ? Colors.white
                                  : primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Total cost section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: softShadowSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Biaya',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
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
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CTA Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: (slotTerpilih.isEmpty || tanggalTerpilihIndex == null)
                    ? null
                    : primaryGradient,
                color: (slotTerpilih.isEmpty || tanggalTerpilihIndex == null)
                    ? blackColor10
                    : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: (slotTerpilih.isEmpty ||
                        tanggalTerpilihIndex == null)
                    ? null
                    : [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap:
                      slotTerpilih.isEmpty || tanggalTerpilihIndex == null
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      KonfirmasiBookingScreen(
                                    venue: widget.venue,
                                    tanggalTerpilih:
                                        listHari[tanggalTerpilihIndex!],
                                    slotTerpilih: slotTerpilih,
                                    hargaTotal: hargaTotal,
                                  ),
                                ),
                              );
                            },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Selanjutnya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color:
                              (slotTerpilih.isEmpty ||
                                      tanggalTerpilihIndex == null)
                                  ? blackColor40
                                  : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
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

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('laravel_token');
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
        Uri.parse('http://192.168.1.10:8000/api/bookings'),
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
          'payment_method': 'manual',
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        final bookingId = responseData['booking_id'];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking berhasil!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DetailBookingScreen(bookingId: bookingId),
          ),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue name card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: premiumGradient,
                borderRadius: BorderRadius.circular(cardBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.venue.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 14, color: Colors.white70),
                      const SizedBox(width: 6),
                      Text(
                        widget.tanggalTerpilih,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text('Jam Booking',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.slotTerpilih
                  .map((slot) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: primaryColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          slot,
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: softShadowSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Biaya',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(
                    NumberFormat.currency(
                            locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                        .format(widget.hargaTotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Confirm button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: isLoading ? null : primaryGradient,
                color: isLoading ? blackColor10 : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: isLoading ? null : _kirimBooking,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Konfirmasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
