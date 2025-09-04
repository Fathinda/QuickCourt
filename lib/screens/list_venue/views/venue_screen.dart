import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_court_booking/models/category.dart';
import 'dart:convert';
import 'package:quick_court_booking/models/venue_model.dart';
import 'components/venue_shimmer_card.dart';
import 'components/venue_card.dart';

class VenueScreen extends StatefulWidget {
  const VenueScreen({super.key});

  @override
  State<VenueScreen> createState() => _VenueScreenState();
}

class _VenueScreenState extends State<VenueScreen> {
  List<Venue> latestVenues = [];
  List<Venue> allVenues = [];
  List<Category> categories = [];
  int selectedCategoryId = 0;
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchVenues();
    fetchCategories();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> fetchVenues({bool isLoadMore = false}) async {
    if (isLoading || (!hasMore && isLoadMore)) return;

    if (!isLoadMore) {
      setState(() {
        currentPage = 1;
        latestVenues.clear();
        allVenues.clear();
        hasMore = true;
      });
    }

    setState(() {
      isLoading = true;
    });

    try {
      String url = 'http://192.168.1.12:8000/api/venues?page=$currentPage';
      if (selectedCategoryId != 0) {
        url += '&category=$selectedCategoryId';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final fetchedVenues = (jsonData['data'] as List)
            .map((item) => Venue.fromJson(item))
            .toList();

        const int pageSize = 10;

        if (!mounted) return;

        setState(() {
          if (currentPage == 1) {
            latestVenues = fetchedVenues.take(5).toList();
            allVenues = fetchedVenues.skip(5).toList();
          } else {
            allVenues.addAll(fetchedVenues);
          }

          hasMore = fetchedVenues.length == pageSize;
          currentPage++;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching venues: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchCategories() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.12:8000/api/categories'));

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);

      if (!mounted) return;
      setState(() {
        categories = jsonData.map((item) => Category.fromJson(item)).toList();
      });
    } else {
      print('Failed to fetch categories');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      fetchVenues(isLoadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari venue...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              enabled: true,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  FilterChip(
                    label: const Text("Semua"),
                    selected: selectedCategoryId == 0,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedCategoryId = 0;
                        currentPage = 1;
                        hasMore = true;
                        allVenues.clear();
                        latestVenues.clear();
                      });
                      fetchVenues();
                    },
                  ),
                  const SizedBox(width: 8),
                  ...categories.map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category.name),
                          selected: selectedCategoryId == category.id,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedCategoryId = category.id;
                              currentPage = 1;
                              hasMore = true;
                              allVenues.clear();
                              latestVenues.clear();
                            });
                            fetchVenues();
                          },
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading && currentPage == 1 && latestVenues.isEmpty) ...[
              const Text('Venue Terbaru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: VenueShimmerCard(isHorizontal: true),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else if (latestVenues.isNotEmpty) ...[
              const Text('Venue Terbaru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: latestVenues.length,
                  itemBuilder: (context, index) {
                    final venue = latestVenues[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: VenueCard(venue: venue, isHorizontal: true),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text('Semua Venue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: (isLoading && currentPage == 1 && allVenues.isEmpty)
                  ? ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: VenueShimmerCard(),
                      ),
                    )
                  : allVenues.isEmpty
                      ? const Center(child: Text("Tidak ada venue ditemukan."))
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: allVenues.length + (hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < allVenues.length) {
                              final venue = allVenues[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: VenueCard(venue: venue),
                              );
                            } else {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
