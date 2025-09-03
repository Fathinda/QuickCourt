import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_court_booking/helper/category_icon_helper.dart';
import 'package:quick_court_booking/providers/venue_provider.dart';
import 'package:quick_court_booking/models/venue_model.dart';
import 'package:quick_court_booking/screens/venue/views/detail_screen.dart'; 

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearch(BuildContext context) {
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      context.read<VenueProvider>().searchVenues(keyword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Cari venue...",
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _onSearch(context),
            ),
          ),
          onSubmitted: (_) => _onSearch(context),
        ),
      ),
      body: Consumer<VenueProvider>(
        builder: (context, venueProvider, child) {
          if (venueProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (venueProvider.venues.isEmpty) {
            return const Center(child: Text("Belum ada hasil"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: venueProvider.venues.length,
            itemBuilder: (context, index) {
              final Venue venue = venueProvider.venues[index];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailVenueScreen(venueId: venue.id),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          venue.imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              venue.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(240, 240, 240, 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        getCategoryIcon(venue.category),
                                        size: 12,
                                        color: const Color.fromARGB(96, 29, 24, 24),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        venue.category,
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.brightness_1,
                                  size: 8,
                                  color: Color.fromRGBO(0, 0, 0, 0.4),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    venue.city,
                                    style: const TextStyle(
                                      color: Color.fromRGBO(0, 0, 0, 0.6),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
