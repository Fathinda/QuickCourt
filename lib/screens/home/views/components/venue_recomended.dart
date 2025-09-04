import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_court_booking/screens/list_venue/views/venue_screen.dart';
import 'package:quick_court_booking/screens/venue/views/detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:quick_court_booking/models/venue_model.dart';

class VenueRecomended extends StatefulWidget {
  const VenueRecomended({super.key});

  @override
  State<VenueRecomended> createState() => _VenueRecomendedState();
}

class _VenueRecomendedState extends State<VenueRecomended> {
  late Future<List<Venue>> _venuesFuture;
  final String _baseUrl = 'http://192.168.1.12:8000/api';

  @override
  void initState() {
    super.initState();
    _venuesFuture = _fetchVenues();
  }

  List<String> generateTimeSlots(String openTime, String closeTime) {
    final List<String> slots = [];

    final open = TimeOfDay(
      hour: int.parse(openTime.split(':')[0]),
      minute: int.parse(openTime.split(':')[1]),
    );
    final close = TimeOfDay(
      hour: int.parse(closeTime.split(':')[0]),
      minute: int.parse(closeTime.split(':')[1]),
    );

    TimeOfDay current = open;

    while (current.hour < close.hour ||
        (current.hour == close.hour && current.minute < close.minute)) {
      final timeString =
          '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}';
      slots.add(timeString);

      current = TimeOfDay(hour: current.hour + 1, minute: 0);
    }

    return slots;
  }

  Future<List<Venue>> _fetchVenues() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/home'),
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Venue response: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded == null ||
            decoded['venues'] == null ||
            decoded['venues'] is! List) {
          throw Exception(
              'Format data salah. "venues" tidak ditemukan atau bukan List.');
        }

        List<dynamic> data = decoded['venues'];

        List<Venue> venues = data.map((json) => Venue.fromJson(json)).toList();

        return venues.take(3).toList();
      } else {
        throw Exception('Gagal memuat data (${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching venues: $e');
      throw Exception('Error fetching venues: $e');
    }
  }

  Widget _buildTimeChip(String time) {
    return Chip(
      label: Text(
        time,
        style: const TextStyle(fontSize: 10),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(vertical: -3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    );
  }

  Widget _buildFieldCard(Venue venue) {
    final availableSlots = generateTimeSlots(
      venue.openTime.substring(0, 5),
      venue.closeTime.substring(0, 5),
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          print('Go to ${venue.name} - (ID: ${venue.id})');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailVenueScreen(venueId: venue.id),
            ),
          );
        },
        child: SizedBox(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: SizedBox(
                  width: 120,
                  child:
                      (venue.thumbnail != null && venue.thumbnail!.isNotEmpty)
                          ? Image.network(
                              venue.imageUrl,
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/promotion/promo_1.jpg',
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                              ),
                            )
                          : Image.asset(
                              'assets/promotion/promo_2.png',
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                            ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.sports_soccer,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "Mini Soccer - ${venue.city}",
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          'Selengkapnya →',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      // const Spacer(),
                      const SizedBox(height: 10),
                      // const SizedBox(height: 6,),
                      Column(
                        children: [
                          SizedBox(
                            height: 30,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: availableSlots
                                  .asMap()
                                  .entries
                                  .where((entry) => entry.key.isEven)
                                  .map((entry) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6),
                                        child: _buildTimeChip(entry.value),
                                      ))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 30,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: availableSlots
                                  .asMap()
                                  .entries
                                  .where((entry) => entry.key.isOdd)
                                  .map((entry) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6),
                                        child: _buildTimeChip(entry.value),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerFieldCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
                height: 140, width: double.infinity, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 200, height: 16, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(width: 120, height: 14, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(width: 100, height: 14, color: Colors.white),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(
                      4,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 50,
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text(
              //   'Rekomendasi Venue',
              //   style: Theme.of(context)
              //       .textTheme
              //       .titleMedium
              //       ?.copyWith(fontWeight: FontWeight.bold),
              // ),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Rekomendasi ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'Venue',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {
                  print("Go to all venues");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VenueScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<Venue>>(
            future: _venuesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: List.generate(3, (_) => _buildShimmerFieldCard()),
                );
              } else if (snapshot.hasError) {
                return Column(
                  children: [
                    Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _venuesFuture = _fetchVenues();
                        });
                      },
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Tidak ada venue ditemukan."));
              } else {
                return Column(
                  children: snapshot.data!
                      .map((venue) => _buildFieldCard(venue))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
