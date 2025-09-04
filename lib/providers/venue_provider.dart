import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quick_court_booking/models/venue_model.dart';

class VenueProvider with ChangeNotifier {
  List<Venue> _venues = [];
  bool _isLoading = false;

  List<Venue> get venues => _venues;
  bool get isLoading => _isLoading;

  Future<void> searchVenues(String keyword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.12:8000/api/venues?search=$keyword"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _venues = (data['data'] as List).map((e) => Venue.fromJson(e)).toList();
      } else {
        _venues = [];
      }
    } catch (e) {
      _venues = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
