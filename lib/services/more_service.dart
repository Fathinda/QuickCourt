import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quick_court_booking/models/venue_model.dart';

class VenueService {
  final String baseUrl = "http://192.168.1.12:8000/api";

  Future<Venue?> getVenueByOwner(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/owner/venue"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Venue.fromJson(data['venue']);
    } else {
      throw Exception("Gagal mengambil data venue");
    }
  }
}
