import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingService {
  static Future<void> sendBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('laravel_token');

    if (token == null) {
      print("❌ Token tidak ditemukan!");
      return;
    }

    print("🔑 Token yang akan digunakan: $token");

    final url = Uri.parse('http://192.168.1.12:8000/api/bookings');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "venue_id": 2,
        "contact_number": "08929129",
        "booking_date": "2025-08-04",
        "start_time": "09:00",
        "end_time": "10:00",
        "total_price": "100000",
      }),
    );

    if (response.statusCode == 200) {
      print("✅ Booking sukses: ${response.body}");
    } else {
      print("❌ Gagal booking: ${response.statusCode} - ${response.body}");
    }
  }
}
