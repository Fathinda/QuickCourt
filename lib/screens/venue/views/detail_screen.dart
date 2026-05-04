import 'dart:convert';
import 'dart:ui';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quick_court_booking/constants.dart';
import 'package:http/http.dart' as http;
import 'package:quick_court_booking/helper/category_icon_helper.dart';
import 'package:quick_court_booking/helper/chat_helper.dart';
import 'package:quick_court_booking/helper/facility_icon_helper.dart';
import 'package:quick_court_booking/models/venue_detail_model.dart';
// import 'package:quick_court_booking/screens/booking/views/booking_time_screen.dart';
import 'package:quick_court_booking/screens/booking/views/select_date_screen.dart';
import 'package:quick_court_booking/screens/chat/chat_screen.dart';
// import 'package:quick_court_booking/screens/booking/views/select_date_screen.dart';
import 'package:quick_court_booking/screens/venue/views/components/appbar.dart';
import 'package:quick_court_booking/screens/venue/views/components/venue_carousel.dart';
import 'package:quick_court_booking/screens/venue/views/components/venue_detail_bottom_sheets.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailVenueScreen extends StatefulWidget {
  final int venueId;

  const DetailVenueScreen({super.key, required this.venueId});

  @override
  State<DetailVenueScreen> createState() => _DetailVenueScreenState();
}

class _DetailVenueScreenState extends State<DetailVenueScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? venue;
  bool isLoading = true;
  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabScaleAnimation = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.elasticOut,
    );
    fetchVenue();
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  Future<void> fetchVenue() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.10:8000/api/venues/${widget.venueId}'),
      );

      if (!mounted) return; // pastikan widget masih ada

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          venue = data['venue'];
          isLoading = false;
        });
        _fabAnimController.forward();
      } else {
        throw Exception('Failed to load venue');
      }
    } catch (e) {
      print('Error: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _launchMapsUrl(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress');

    if (await canLaunchUrl(googleMapsUrl)) {
      try {
        await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.platformDefault,
        );
      } catch (e) {
        print('Error launching URL: $e');
      }
    } else {
      print('Tidak bisa buka URL maps');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
      );
    }
  }

  String _formatCurrency(dynamic price) {
    if (price == null) return 'Harga tidak tersedia';

    try {
      final intValue = int.tryParse(price.toString()) ?? 0;
      return 'Rp ${intValue.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';
    } catch (e) {
      return 'Rp -';
    }
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
                height: 30,
                width: 200,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8))),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
                height: 20,
                width: 150,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6))),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? _buildShimmer()
          : Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 280,
                      floating: false,
                      pinned: false,
                      backgroundColor: Colors.transparent,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            VenueCarousel(
                              imageUrls: venue?['images'] != null
                                  ? List<String>.from(
                                      venue!['images'].map((img) =>
                                          getFullImageUrl(img['image_url'])),
                                    )
                                  : [],
                            ),
                            // Gradient overlay on hero image
                            const Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: 100,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0x80000000),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -30),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(cardBorderRadius),
                                  boxShadow: softShadow,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.8),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      venue?['name'] ?? 'No name',
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black87,
                                          letterSpacing: -0.3),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color:
                                                primaryColor.withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                getCategoryIcon(
                                                    venue?['category']
                                                            ?['name'] ??
                                                        ''),
                                                size: 14,
                                                color: primaryColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                venue?['category']?['name'] ??
                                                    'Unknown Category',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: blackColor40,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.location_on_outlined,
                                            size: 14, color: blackColor40),
                                        const SizedBox(width: 2),
                                        Text(
                                          venue?['city']?['name'] ??
                                              'Unknown City',
                                          style: TextStyle(
                                            color: blackColor60,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    DottedLine(
                                      direction: Axis.horizontal,
                                      lineLength: double.infinity,
                                      lineThickness: 1.0,
                                      dashLength: 4.0,
                                      dashColor: blackColor10,
                                    ),
                                    const SizedBox(height: 14),
                                    const Text("Deskripsi",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        )),
                                    const SizedBox(height: 4),
                                    Text(
                                      venue?['deskripsi'] ??
                                          'Tidak ada deskripsi.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: blackColor60,
                                        height: 1.5,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text("Rules",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        )),
                                    const SizedBox(height: 4),
                                    Text(
                                      venue?['rules'] ?? 'Tidak ada rules.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: blackColor60,
                                        height: 1.5,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    TextButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          enableDrag: false,
                                          isDismissible: false,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) =>
                                              VenueDetailBottomSheet(
                                                  venue: venue!),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Selengkapnya',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.arrow_forward_rounded,
                                              size: 14, color: primaryColor),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Location card
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(cardBorderRadius),
                                boxShadow: softShadowSm,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(cardBorderRadius),
                                child: InkWell(
                                  borderRadius:
                                      BorderRadius.circular(cardBorderRadius),
                                  onTap: () {
                                    final address = venue?['address'] ?? '';
                                    if (address.isNotEmpty) {
                                      _launchMapsUrl(address);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Alamat tidak tersedia')),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            gradient: primaryGradient,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.location_on,
                                              color: Colors.white, size: 20),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            venue?['address'] ??
                                                'Alamat tidak tersedia',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: blackColor80,
                                              height: 1.4,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios_rounded,
                                            size: 14, color: blackColor40),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Facilities section
                          if (venue?['facilities'] != null &&
                              venue!['facilities'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(cardBorderRadius),
                                  boxShadow: softShadowSm,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          List<Widget> chips = [];
                                          double totalWidth = 0;
                                          const chipSpacing = 8.0;

                                          for (var fasilitas
                                              in venue!['facilities']) {
                                            final estWidth =
                                                (fasilitas['name'] as String)
                                                            .length *
                                                        8 +
                                                    56;
                                            totalWidth +=
                                                estWidth + chipSpacing;

                                            if (totalWidth >
                                                constraints.maxWidth - 0) {
                                              chips.add(
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: surfaceColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const Text("...",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: blackColor60)),
                                                ),
                                              );
                                              break;
                                            }

                                            chips.add(Padding(
                                              padding: const EdgeInsets.only(
                                                  right: chipSpacing),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: surfaceColor,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      getFacilityIcon(
                                                          fasilitas['name']),
                                                      size: 14,
                                                      color: primaryColor,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      fasilitas['name'],
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ));
                                          }

                                          return Row(
                                            children: chips,
                                          );
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: surfaceColor,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor:
                                                Colors.transparent,
                                            builder: (_) =>
                                                VenueDetailBottomSheet(
                                                    venue: venue!),
                                          );
                                        },
                                        child: const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 14,
                                          color: blackColor40,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
                const Positioned(
                  top: 0,
                  left: 10,
                  right: 0,
                  child: SafeArea(child: VenueAppBar()),
                ),
                // Animated FAB
                Positioned(
                  bottom: 30,
                  right: 20,
                  child: ScaleTransition(
                    scale: _fabScaleAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        heroTag: "chat_btn",
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        onPressed: () async {
                          print('venue data: $venue');
                          print(
                              'ownerId from venue: ${venue?['user_id']}');
                          final userId =
                              FirebaseAuth.instance.currentUser?.uid ?? '';
                          final ownerId = venue?['user_id'];

                          if (userId.isEmpty) {
                            print('User belum login');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('User belum login')),
                            );
                            return;
                          }

                          if (ownerId == null) {
                            print(
                                'Owner venue tidak ditemukan di venue data');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Owner venue tidak ditemukan')),
                            );
                            return;
                          }

                          print(
                              'Fetching owner data from API for ownerId: $ownerId');
                          try {
                            final response = await http.get(Uri.parse(
                                'http://192.168.1.10:8000/api/users/id/$ownerId'));

                            print(
                                'API Response status: ${response.statusCode}');
                            print(
                                'API Response body: ${response.body}');

                            if (response.statusCode != 200) {
                              throw Exception(
                                  'Failed to load owner data');
                            }

                            final ownerData =
                                jsonDecode(response.body);
                            print('Owner data decoded: $ownerData');

                            final ownerFirebaseUid =
                                ownerData['firebase_uid'] as String?;
                            final ownerName =
                                ownerData['name'] as String?;

                            if (ownerFirebaseUid == null) {
                              print(
                                  'Owner Firebase UID tidak ditemukan di API response');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Owner Firebase UID tidak ditemukan')),
                              );
                              return;
                            }

                            print(
                                'Owner Firebase UID: $ownerFirebaseUid');
                            print(
                                'Owner Name: ${ownerName ?? 'Owner (default)'}');

                            final chatId =
                                await ChatHelper.createOrGetChat(
                                    userId, ownerFirebaseUid);
                            print(
                                'Chat ID created or retrieved: $chatId');

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  chatId: chatId.toString(),
                                  currentUserId: userId,
                                  peerId: ownerFirebaseUid,
                                  peerName: ownerName ?? 'Owner',
                                ),
                              ),
                            );
                          } catch (e) {
                            print(
                                'Error while fetching owner data or creating chat: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        child:
                            const Icon(Icons.message_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      // Modern bottom bar
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: glassBlur, sigmaY: glassBlur),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              border: Border(
                top: BorderSide(
                  color: blackColor10.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Mulai dari',
                      style: TextStyle(fontSize: 11, color: blackColor40),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(venue?['price']),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
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
                      onTap: () {
                        if (venue != null) {
                          final venueModel = VenueDetail.fromJson(venue!);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectDateScreen(
                                venue: venueModel,
                                venueId: widget.venueId,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Data venue belum tersedia')),
                          );
                        }
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        child: Text(
                          'Pilih Lapangan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
}
