import 'package:flutter/material.dart';
// import 'package:quick_court_booking/components/Banner/S/banner_s_style_1.dart';
// import 'package:quick_court_booking/components/Banner/S/banner_s_style_5.dart';
// import 'package:quick_court_booking/constants.dart';
import 'package:quick_court_booking/route/screen_export.dart';
import 'package:quick_court_booking/screens/home/views/components/offers_carousel.dart';
import 'package:quick_court_booking/screens/home/views/components/promo_section.dart';
import 'package:quick_court_booking/screens/home/views/components/venue_recomended.dart';
// import 'package:shimmer/shimmer.dart';

import 'components/header_section.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: HeaderSection()),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Divider(
                  thickness: 0.5,
                  color: Colors.grey,
                ),
              ),
            ),

            SliverToBoxAdapter(child: VenueRecomended()),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Divider(
                  thickness: 0.5,
                  color: Colors.grey,
                ),
              ),
            ),

            SliverToBoxAdapter(child: OffersCarousel()),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Divider(
                  thickness: 0.5,
                  color: Colors.grey,
                ),
              ),
            ),
            
            SliverToBoxAdapter(child: PromoSection()),

            // const SliverToBoxAdapter(child: PopularProducts()),
            // const SliverPadding(
            // padding: EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
            // sliver: SliverToBoxAdapter(child: FlashSale()),
            // ),
            // SliverToBoxAdapter(
            //   child: Column(
            //     children: [
            //       BannerSStyle1(
            //         title: "New \narrival",
            //         subtitle: "SPECIAL OFFER",
            //         discountParcent: 50,
            //         press: () {
            //           Navigator.pushNamed(context, onSaleScreenRoute);
            //         },
            //       ),
            //       const SizedBox(height: defaultPadding / 4),
            //     ],
            //   ),
            // ),
            // const SliverToBoxAdapter(child: BestSellers()),
            // const SliverToBoxAdapter(child: MostPopular()),
            // SliverToBoxAdapter(
            //   child: Column(
            //     children: [
            //       const SizedBox(height: defaultPadding * 1.5),
            //       BannerSStyle5(
            //         title: "Black \nfriday",
            //         subtitle: "50% Off",
            //         bottomText: "COLLECTION",
            //         press: () {
            //           Navigator.pushNamed(context, onSaleScreenRoute);
            //         },
            //       ),
            //       const SizedBox(height: defaultPadding / 4),
            //     ],
            //   ),
            // ),
            // const SliverToBoxAdapter(child: BestSellers()),
          ],
        ),
      ),
    );
  }
}
