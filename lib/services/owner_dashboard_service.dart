import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quick_court_booking/models/owner_dashboard_model.dart';

class OwnerDashboardService {
  final String baseUrl = "http://192.168.1.12:8000/api";

  Future<OwnerDashboardData> fetchDashboard(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/owner/dashboard'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return OwnerDashboardData.fromJson(data);
    } else {
      throw Exception('Gagal mengambil data dashboard owner');
    }
  }
}
