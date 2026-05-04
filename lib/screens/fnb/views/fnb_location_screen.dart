import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quick_court_booking/models/city_model.dart';
import 'package:quick_court_booking/screens/fnb/views/components/fnb_offer_carousel.dart';
import 'package:quick_court_booking/helper/category_icon_helper.dart';
import 'package:quick_court_booking/screens/fnb/views/fnb_menu_screen.dart';

class FnbLocationScreen extends StatefulWidget {
  const FnbLocationScreen({super.key});

  @override
  State<FnbLocationScreen> createState() => _FnbLocationScreenState();
}

class _FnbLocationScreenState extends State<FnbLocationScreen> {
  List<City> cities = [];
  City? selectedCity;
  List<Venue> venues = [];

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  Future<void> fetchCities() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.10:8000/api/fnb/cities'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final loadedCities =
          List<City>.from(data.map((city) => City.fromJson(city)));

      if (!mounted) return;
      setState(() {
        cities = loadedCities;
        if (cities.isNotEmpty) {
          selectedCity = cities[0];
          fetchVenues();
        }
      });
    } else {
      print('Failed to load cities');
    }
  }

  Future<void> fetchVenues() async {
    if (selectedCity == null) return;

    print(
        "Fetching venues for city: ${selectedCity!.name} (ID: ${selectedCity!.id})");

    final response = await http.get(
      Uri.parse('http://192.168.1.10:8000/api/fnb/venues/${selectedCity!.id}'),
    );

    print("Response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Fetched venue list: $data");

      final loadedVenues = List<Venue>.from(data.map((v) => Venue.fromJson(v)));

      if (!mounted) return;
      setState(() {
        venues = loadedVenues;
      });
    } else {
      print('Failed to load venues');
    }
  }

  void showCitySelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: cities.length,
          itemBuilder: (context, index) {
            final city = cities[index];
            return ListTile(
              title: Text(city.name),
              onTap: () {
                setState(() {
                  selectedCity = city;
                });
                fetchVenues();
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temukan FNB Venue'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: FnbOfferCarousel()),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      selectedCity?.name ?? 'Pilih Kota',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: showCitySelector,
                      child: const Text("Change",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            if (venues.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    "Belum ada venue di kota ini.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final venue = venues[index];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            venue.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(venue.address),
                          leading: Icon(
                            getCategoryIcon(venue.category),
                            color: Colors.blue,
                          ),
                          onTap: () {
                            print("Tombol venue ditekan: ${venue.name}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FnbMenuScreen(
                                  venueId: venue.id,
                                  venueName: venue.name,
                                ),
                              ),
                            );
                          },
                        ),
                        if (index != venues.length - 1)
                          const Divider(
                            height: 1,
                            color: Colors.grey,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                      ],
                    );
                  },
                  childCount: venues.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
