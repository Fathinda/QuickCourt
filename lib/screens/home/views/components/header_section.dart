import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_court_booking/route/screen_export.dart';
// import 'package:quick_court_booking/components/Banner/M/banner_m_style_1.dart';
import 'package:quick_court_booking/screens/home/views/components/offers_carousel.dart';
import 'package:quick_court_booking/screens/list_venue/views/venue_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
      Uri.parse('http://192.168.1.12:8000/api/user'),
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

  @override
  Widget build(BuildContext context) {
    return name == null
        ? const Padding(
            padding: EdgeInsets.all(20),
            child: LinearProgressIndicator(),
          )
        : Stack(
            children: [
              Container(
                height: 290,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/images/header_bg.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          name == 'Guest'
                              ? 'assets/images/signUp_dark.png'
                              : 'assets/images/user.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Hello, ",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: name ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.0, vertical: 13),
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
                    const OffersCarousel(),
                  ],
                ),
              ),
            ],
          );
  }
}
