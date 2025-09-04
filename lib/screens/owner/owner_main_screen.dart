import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:quick_court_booking/helper/chat_badge_controller.dart';
import 'package:quick_court_booking/models/venue_model.dart';
import 'package:quick_court_booking/screens/chat/chat_list_screen.dart';
import 'package:quick_court_booking/screens/owner/fnb/fnb_choose_screen.dart';
import 'package:quick_court_booking/screens/owner/lainnya/lainnya_screen.dart';
import 'package:quick_court_booking/screens/owner/promo/owner_promo_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'booking/booking_list_screen.dart';

class OwnerVenueDashboard extends StatefulWidget {
  final int venueId;
  final String venueName;
  const OwnerVenueDashboard(
      {super.key, required this.venueId, required this.venueName});

  @override
  State<OwnerVenueDashboard> createState() => _OwnerVenueDashboardState();
}

class _OwnerVenueDashboardState extends State<OwnerVenueDashboard> {
  int _selectedIndex = 0;
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('laravel_token');

      if (token == null) throw Exception("Token tidak ditemukan");

      final url =
          "http://192.168.1.19:8000/api/owner-dashboard/${widget.venueId}";
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          dashboardData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Gagal ambil data - Status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() => isLoading = false);
    }
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (dashboardData == null)
      return const Center(child: Text("Data tidak tersedia"));

    switch (_selectedIndex) {
      case 0:
        return _buildHome();
      case 1:
        return OwnerPromoListScreen(venueId: widget.venueId);
      case 2:
        return FnbDashboardScreen(venueId: widget.venueId);
      case 3:
        return BookingListScreen(venueId: widget.venueId);
      case 4:
        final venueJson = dashboardData!['venue'];

        if (venueJson == null) {
          print("Venue dengan id ${widget.venueId} tidak ditemukan");
          print('Dashboard Data: $dashboardData');
          return Center(child: Text("Venue tidak ditemukan"));
        }

        print("Venue ditemukan: $venueJson");

        return OwnerVenueMoreScreen(
          venue: Venue.fromJson(venueJson),
        );
      default:
        return _buildHome();
    }
  }

  Widget _buildHome() {
    final bookingsData =
        (dashboardData?['charts']?['bookingsPerMonth'] as List<dynamic>?) ?? [];
    final incomeData =
        (dashboardData?['charts']?['incomePerMonth'] as List<dynamic>?) ?? [];

    List<FlSpot> bookingSpots = [];
    List<BarChartGroupData> incomeBars = [];

    double maxBookingY = 10;
    double maxIncomeY = 1;

    for (var entry in bookingsData) {
      final month = entry['month'] ?? 0;
      final total = (entry['total'] ?? 0).toDouble();
      bookingSpots.add(FlSpot(month.toDouble(), total));
      if (total > maxBookingY) maxBookingY = total;
    }

    for (var entry in incomeData) {
      final month = entry['month'] ?? 0;
      final amount = (entry['total'] ?? 0).toDouble();
      incomeBars.add(
        BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
              toY: amount,
              width: 16,
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      if (amount > maxIncomeY) maxIncomeY = amount;
    }

    return RefreshIndicator(
      onRefresh: fetchDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.venueName,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 16),
            // Statistik
            SizedBox(
              height: 3 * 90 + 12 * 2,
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.0,
                children: [
                  _statCard(
                      "Perlu Diproses",
                      dashboardData!["summary"]["perluDiproses"].toString(),
                      Colors.orange),
                  _statCard(
                      "Kendala",
                      dashboardData!["summary"]["kendala"].toString(),
                      Colors.red),
                  _statCard(
                      "Dibatalkan",
                      dashboardData!["summary"]["dibatalkan"].toString(),
                      Colors.grey),
                  _statCard(
                      "Total Bookings",
                      dashboardData!["summary"]["totalBookings"].toString(),
                      Colors.blue),
                  _statCard(
                      "Total Transactions",
                      dashboardData!["summary"]["totalTransactions"].toString(),
                      Colors.green),
                  _statCard(
                      "Balance",
                      "Rp ${dashboardData!["summary"]["totalBalance"]}",
                      Colors.teal),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Grafik Booking
            const Text("Grafik Booking per Bulan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 1,
                  maxX: 12,
                  minY: 0,
                  maxY: maxBookingY + 5,
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Colors.black54),
                      bottom: BorderSide(color: Colors.black54),
                    ),
                  ),
                  titlesData: _buildTitlesData(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: bookingSpots,
                      isCurved: false,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                          show: true, color: Colors.blue.withOpacity(0.2)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Grafik Income
            const Text("Grafik Income/Bulan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: incomeBars,
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Colors.black54),
                      bottom: BorderSide(color: Colors.black54),
                    ),
                  ),
                  titlesData: _buildTitlesData(),
                  maxY: ((maxIncomeY + 10000) / 10000).ceil() * 10000,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) {
            const months = [
              '',
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'Mei',
              'Jun',
              'Jul',
              'Agu',
              'Sep',
              'Okt',
              'Nov',
              'Des'
            ];
            return Text(
              months[value.toInt()],
              style: const TextStyle(fontSize: 10),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 10),
            );
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                SvgPicture.asset(
                  "assets/icons/Notification.svg",
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge!.color!,
                    BlendMode.srcIn,
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
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Promo"),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: "F&B"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Booking"),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz), label: "Lainnya"),
        ],
      ),
    );
  }
}
