import 'package:intl/intl.dart';

class VenuePromo {
  final int id;
  final int venueId;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;

  VenuePromo({
    required this.id,
    required this.venueId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
  });

  factory VenuePromo.fromJson(Map<String, dynamic> json) {
    print("📥 JSON PROMO: $json"); // Debug

    final baseUrl = "http://192.168.1.19:8000/"; // ganti sesuai IP/backend kamu

    final parsed = VenuePromo(
      id: json['id'],
      venueId: json['venue_id'],
      title: json['title'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );

    print("✅ Parsed VenuePromo: ${parsed.title}, img=${parsed.imageUrl}, "
        "start=${parsed.startDate}, end=${parsed.endDate}"); // Debug hasil parsing

    return parsed;
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd'); // biar sama kayak di DB
    return {
      'id': id,
      'venue_id': venueId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'start_date': dateFormat.format(startDate), // hasil "2025-08-30"
      'end_date': dateFormat.format(endDate),
    };
  }
}
