import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_court_booking/constants.dart';
import 'package:quick_court_booking/screens/list_venue/views/venue_screen.dart';
import 'package:quick_court_booking/screens/venue/views/detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:quick_court_booking/models/venue_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class VenueRecomended extends StatefulWidget {
  const VenueRecomended({super.key});

  @override
  State<VenueRecomended> createState() => _VenueRecomendedState();
}

class _VenueRecomendedState extends State<VenueRecomended> {
  late Future<List<Venue>> _venuesFuture;
  final String _baseUrl = 'http://192.168.1.10:8000/api';

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

  Widget _buildTimeChip(String time, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: isHighlighted ? primaryGradient : null,
        color: isHighlighted ? null : surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        time,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
          color: isHighlighted ? Colors.white : blackColor60,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFieldCard(Venue venue, int index) {
    final availableSlots = generateTimeSlots(
      venue.openTime.substring(0, 5),
      venue.closeTime.substring(0, 5),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(cardBorderRadius),
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
            height: 155,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with gradient accent strip
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      child: SizedBox(
                        width: 120,
                        height: double.infinity,
                        child: (venue.thumbnail != null &&
                                venue.thumbnail!.isNotEmpty)
                            ? Image.network(
                                venue.imageUrl,
                                fit: BoxFit.cover,
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
                    // Gradient accent on left edge
                    Positioned(
                      left: 0,
                      top: 20,
                      bottom: 20,
                      child: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          gradient: primaryGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venue.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.sports_soccer,
                                size: 13, color: primaryColor.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Mini Soccer • ${venue.city}",
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Selengkapnya',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 14, color: primaryColor),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 6.0,
                              runSpacing: 6.0,
                              children: availableSlots
                                  .asMap()
                                  .entries
                                  .map((entry) => _buildTimeChip(
                                        entry.value,
                                        isHighlighted: entry.key < 2,
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerFieldCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 155,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: softShadowSm,
      ),
      child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerHighlightColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 160, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 10),
                    Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 10),
                    Container(width: 80, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: List.generate(
                        4,
                        (index) => Container(
                          width: 48,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
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
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  print("Go to all venues");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VenueScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 14, color: primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                return AnimationLimiter(
                  child: Column(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 500),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 40.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: snapshot.data!
                          .asMap()
                          .entries
                          .map((entry) => _buildFieldCard(entry.value, entry.key))
                          .toList(),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
