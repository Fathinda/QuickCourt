import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quick_court_booking/models/venue_promo_model.dart';

class PromoService {
  static const String baseUrl = "http://192.168.1.10:8000/api"; // sesuaikan IP

  static Future<List<VenuePromo>> fetchPromos() async {
    try {
      final url = Uri.parse("$baseUrl/promos");
      print("🔍 Fetching promos from: $url");
      final response = await http.get(
        url,
        headers: {"Accept": "application/json"}, // penting
      );

      print("📡 Status Code: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // kalau response array langsung
        if (decoded is List) {
          return decoded.map((json) => VenuePromo.fromJson(json)).toList();
        }

        // kalau response object dengan key "data"
        if (decoded is Map<String, dynamic> && decoded.containsKey("data")) {
          final List<dynamic> data = decoded["data"];
          return data.map((json) => VenuePromo.fromJson(json)).toList();
        }

        throw Exception("Format response tidak dikenali");
      } else {
        throw Exception("Gagal fetch promo: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetchPromos: $e");
      rethrow;
    }
  }
}
