import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quick_court_booking/components/Banner/M/banner_m_style_1.dart';
import 'package:quick_court_booking/components/dot_indicators.dart';

import '../../../../constants.dart';

class OffersCarousel extends StatefulWidget {
  const OffersCarousel({
    super.key,
  });

  @override
  State<OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<OffersCarousel> {
  int _selectedIndex = 0;
  late PageController _pageController;
  late Timer _timer;

  
  List offers = const [
    SimpleBanner(imagePath: 'assets/promotion/promo_1.jpg'),
    SimpleBanner(imagePath: 'assets/promotion/promo_2.png'),
    SimpleBanner(imagePath: 'assets/promotion/promo_3.png'),
    SimpleBanner(imagePath: 'assets/promotion/promo_4.jpg'),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_selectedIndex < offers.length - 1) {
        _selectedIndex++;
      } else {
        _selectedIndex = 0;
      }

      _pageController.animateToPage(
        _selectedIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(cardBorderRadius),
            child: AspectRatio(
              aspectRatio: 1.87,
              child: PageView.builder(
                controller: _pageController,
                itemCount: offers.length,
                onPageChanged: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                itemBuilder: (context, index) => offers[index],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Modern dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              offers.length,
              (index) {
                final isActive = index == _selectedIndex;
                return AnimatedContainer(
                  duration: animDurationMedium,
                  curve: Curves.easeInOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: isActive ? 24 : 6,
                  decoration: BoxDecoration(
                    gradient: isActive ? primaryGradient : null,
                    color: isActive ? null : blackColor20,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
