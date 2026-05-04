import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_court_booking/constants.dart';
import 'package:quick_court_booking/route/screen_export.dart';
import 'package:quick_court_booking/screens/list_venue/views/venue_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'menu_button.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  String? name;
  String photoUrl = 'assets/images/user.png';

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('laravel_token');

    if (!mounted) return;

    if (token == null) {
      setState(() {
        name = 'Guest';
      });
      return;
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.10:8000/api/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        name = data['name'];
        photoUrl = data['photo_url'] ?? 'assets/images/user.png';
      });
    } else {
      setState(() {
        name = 'Guest';
      });
    }
  }

  Widget _buildShimmerHeader() {
    return Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 12),
                Container(width: 180, height: 22, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Container(height: 130, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 130, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return name == null
        ? _buildShimmerHeader()
        : Stack(
            children: [
              // Background image with gradient overlay
              Container(
                height: 280,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/header_bg.png',
                        fit: BoxFit.cover,
                      ),
                      // Premium dark gradient overlay
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0x00000000),
                              Color(0x40000000),
                              Color(0x99000000),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting row with avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Avatar with gradient border
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            gradient: primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              name == 'Guest'
                                  ? 'assets/images/signUp_dark.png'
                                  : 'assets/images/user.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello 👋",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                name ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Menu buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.0, vertical: 0),
                      child: Row(
                        children: [
                          MenuButton(
                            label: "Booking Now",
                            subLabel: "Lapangan Olahraga",
                            imagePath: 'assets/images/booking_now_bg.jpg',
                            icon: Icons.sports_soccer,
                            onTap: () {
                              print('Go To Booking Now');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VenueScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          MenuButton(
                            label: "Food Order",
                            subLabel: "Makanan & Minuman",
                            imagePath: 'assets/images/food_image.jpg',
                            icon: Icons.fastfood,
                            onTap: () {
                              print('Belum tersedia');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const FnbLocationScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
