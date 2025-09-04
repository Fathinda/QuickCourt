import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_court_booking/components/list_tile/divider_list_tile.dart';
// import 'package:quick_court_booking/components/network_image_with_loader.dart';
import 'package:quick_court_booking/constants.dart';
import 'package:quick_court_booking/models/venue_model.dart';
import 'package:quick_court_booking/route/screen_export.dart';
import 'package:quick_court_booking/screens/admin/owner_dashboard_screen.dart';
import 'package:quick_court_booking/screens/auth_venue/views/signup_venue_screen.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() {
    user = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  Future<void> logout() async {
    print("Mulai logout");

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    print("Selesai logout");

    if (!mounted) {
      print("Context tidak mounted");
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ProfileCard(
            name: user?.displayName ?? "Guest",
            email: user?.email ?? "No Email",
            imageSrc: "assets/images/Fathinda.jpg",
            // proLableText: "Sliver",
            // isPro: true, if the user is pro
            press: () {
              // Navigator.pushNamed(context, userInfoScreenRoute);
            },
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(
          //       horizontal: defaultPadding, vertical: defaultPadding * 1.5),
          //   child: GestureDetector(
          //     onTap: () {},
          //     child: const AspectRatio(
          //       aspectRatio: 1.8,
          //       child:
          //           NetworkImageWithLoader("https://i.imgur.com/dz0BBom.png"),
          //     ),
          //   ),
          // ),

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Account",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          // ProfileMenuListTile(
          //   text: "Profile Info",
          //   svgSrc: "assets/icons/pro.svg",
          //   press: () {
          //     // Navigator.pushNamed(context, ordersScreenRoute);
          //   },
          // ),

          ProfileMenuListTile(
            text: "Owner Panel",
            svgSrc: "assets/icons/Accessories.svg",
            press: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('laravel_token');

              if (token == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please login first!')),
                );
                return;
              }

              try {
                final userResponse = await http.get(
                  Uri.parse('http://192.168.1.19:8000/api/user'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Accept': 'application/json',
                  },
                );

                if (userResponse.statusCode != 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to get user data')),
                  );
                  return;
                }

                final userData = json.decode(userResponse.body);
                final role = userData['role'];

                if (role == 'admin') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminBookingScreen()),
                  );
                  return;
                }

                final venueResponse = await http.get(
                  Uri.parse('http://192.168.1.19:8000/api/owner/check-venue'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Accept': 'application/json',
                  },
                );

                if (venueResponse.statusCode != 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to check venue')),
                  );
                  return;
                }

                final venueData = json.decode(venueResponse.body);
                final venuesList = venueData['venues'];

                if (venueData['exists'] != true ||
                    venuesList == null ||
                    !(venuesList is List) ||
                    venuesList.isEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterVenueScreen()),
                  );
                  return;
                }

                final List<Venue> venues =
                    venuesList.map((json) => Venue.fromJson(json)).toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OwnerDashboardScreen(venues: venues),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
          const SizedBox(height: defaultPadding),
          // Padding(
          //   padding: const EdgeInsets.symmetric(
          //       horizontal: defaultPadding, vertical: defaultPadding / 2),
          //   child: Text(
          //     "Personalization",
          //     style: Theme.of(context).textTheme.titleSmall,
          //   ),
          // ),

          const SizedBox(height: defaultPadding),
          // Padding(
          //   padding: const EdgeInsets.symmetric(
          //       horizontal: defaultPadding, vertical: defaultPadding / 2),
          //   child: Text(
          //     "Settings",
          //     style: Theme.of(context).textTheme.titleSmall,
          //   ),
          // ),

          const SizedBox(height: defaultPadding),

          ListTile(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        print("Mulai logout");

                        await logout();
                        print("Selesai logout");

                        if (!context.mounted) {
                          print("Context tidak mounted");
                          return;
                        }

                        print("Navigasi ke LoginScreen");
                      },
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );
            },
            minLeadingWidth: 24,
            leading: SvgPicture.asset(
              "assets/icons/Logout.svg",
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                errorColor,
                BlendMode.srcIn,
              ),
            ),
            title: const Text(
              "Log Out",
              style: TextStyle(color: errorColor, fontSize: 14, height: 1),
            ),
          )
        ],
      ),
    );
  }
}
