
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:quick_court_booking/helper/chat_badge_controller.dart';
import 'package:quick_court_booking/screens/booking/views/booking_history_screen.dart';
import 'package:quick_court_booking/screens/chat/chat_list_screen.dart';

import 'package:quick_court_booking/screens/fnb/views/fnb_location_screen.dart';
import 'package:quick_court_booking/screens/home/views/home_screen.dart';
import 'package:quick_court_booking/screens/list_venue/views/venue_screen.dart';
import 'package:quick_court_booking/screens/profile/views/profile_screen.dart';
import 'package:quick_court_booking/screens/search/views/search_screen.dart';



class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  final List<Widget> _pages = [
    const HomeScreen(),
    const VenueScreen(),
    const FnbLocationScreen(),
    const BookingHistoryScreen(),
    const ProfileScreen(),
  ];

  int _currentIndex = 0;


  @override
  void initState() {
    super.initState();
    listenNewChats();
  }


  void listenNewChats() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('recipientId', isEqualTo: currentUserId)
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          final unreadMessagesCount = snapshot.docs.length;
          chatBadgeController.unreadCount.value = unreadMessagesCount;
        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (_currentIndex == 3 || _currentIndex == 2)
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: const SizedBox(),
              leadingWidth: 0,
              title: SvgPicture.asset(
                "assets/logo/QuickCourt.svg",
                colorFilter: ColorFilter.mode(
                    Theme.of(context).iconTheme.color!, BlendMode.srcIn),
                height: 130,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/Search.svg",
                    height: 24,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).textTheme.bodyLarge!.color!,
                        BlendMode.srcIn),
                  ),
                ),

                IconButton(
                  onPressed: () {
                    final uid = FirebaseAuth.instance.currentUser!.uid;

                    chatBadgeController.reset();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatListScreen(currentUserId: uid),
                      ),
                    );
                  },
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // SvgPicture.asset(
                      //   "assets/icons/Notification.svg",
                      //   height: 24,
                      //   colorFilter: ColorFilter.mode(
                      //     Theme.of(context).textTheme.bodyLarge!.color!,
                      //     BlendMode.srcIn,
                      //   ),
                      // ),
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 24,
                        color: Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: ValueListenableBuilder<int>(
                          valueListenable: chatBadgeController.unreadCount,
                          builder: (context, count, child) {
                            if (count == 0) return const SizedBox.shrink();
                            return Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                count > 99 ? '99+' : count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      body: _pages[_currentIndex],

      
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.textIn,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF101015),
        activeColor: Colors.blue,
        color: Colors.grey,
        items: [
          TabItem(
            icon: SvgPicture.asset(
              "assets/icons/home.svg",
              height: 24,
              color: _currentIndex == 0 ? Colors.blue : Colors.grey,
            ),
            title: "Home",
          ),
          TabItem(
            icon: SvgPicture.asset(
              "assets/icons/building-stadium.svg",
              height: 24,
              color: _currentIndex == 1 ? Colors.blue : Colors.grey,
            ),
            title: "Venue",
          ),
          TabItem(
            icon: SvgPicture.asset(
              "assets/icons/fast_food.svg",
              height: 24,
              color: _currentIndex == 2 ? Colors.blue : Colors.grey,
            ),
            title: "F&B",
          ),
          TabItem(
            icon: SvgPicture.asset(
              "assets/icons/file-invoice.svg",
              height: 24,
              color: _currentIndex == 3 ? Colors.blue : Colors.grey,
            ),
            title: "Booking",
          ),
          TabItem(
            icon: SvgPicture.asset(
              "assets/icons/Profile.svg",
              height: 24,
              color: _currentIndex == 4 ? Colors.blue : Colors.grey,
            ),
            title: "Profile",
          ),
        ],
        initialActiveIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
