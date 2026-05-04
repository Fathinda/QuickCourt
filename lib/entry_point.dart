
import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_court_booking/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class _EntryPointState extends State<EntryPoint> with TickerProviderStateMixin {
  final List<Widget> _pages = [
    const HomeScreen(),
    const VenueScreen(),
    const FnbLocationScreen(),
    const BookingHistoryScreen(),
    const ProfileScreen(),
  ];

  int _currentIndex = 0;
  StreamSubscription? _chatSubscription;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    listenNewChats();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _fabController.dispose();
    super.dispose();
  }

  void listenNewChats() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    _chatSubscription = FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('recipientId', isEqualTo: currentUserId)
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          final unreadMessagesCount = snapshot.docs.length;
          chatBadgeController.unreadCount.value = unreadMessagesCount;
        });
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/Search.svg",
                      height: 20,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).textTheme.bodyLarge!.color!,
                          BlendMode.srcIn),
                    ),
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 20,
                          color: Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
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
                                gradient: errorGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: errorColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
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
                const SizedBox(width: 4),
              ],
            ),
      body: AnimatedSwitcher(
        duration: animDurationMedium,
        child: _pages[_currentIndex],
      ),

      
      bottomNavigationBar: _ModernBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        isDark: isDark,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modern Frosted Glass Bottom Navigation Bar
// ---------------------------------------------------------------------------
class _ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _ModernBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: "assets/icons/home.svg", label: "Home"),
      _NavItem(icon: "assets/icons/building-stadium.svg", label: "Venue"),
      _NavItem(icon: "assets/icons/fast_food.svg", label: "F&B"),
      _NavItem(icon: "assets/icons/file-invoice.svg", label: "Booking"),
      _NavItem(icon: "assets/icons/Profile.svg", label: "Profile"),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF101015).withOpacity(0.92)
            : Colors.white.withOpacity(0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: glassBlur, sigmaY: glassBlur),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final isActive = index == currentIndex;
                  return _NavItemWidget(
                    item: items[index],
                    isActive: isActive,
                    isDark: isDark,
                    onTap: () => onTap(index),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: animDurationMedium,
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isActive ? primaryGradient : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              item.icon,
              height: 22,
              colorFilter: ColorFilter.mode(
                isActive
                    ? Colors.white
                    : (isDark ? Colors.grey[400]! : Colors.grey[500]!),
                BlendMode.srcIn,
              ),
            ),
            AnimatedSize(
              duration: animDurationMedium,
              curve: Curves.easeInOutCubic,
              child: isActive
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
