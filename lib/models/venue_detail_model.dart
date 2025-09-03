import 'facility_model.dart';

String getFullImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http') || path.startsWith('https')) return path;
  return 'http://192.168.1.22:8000/storage/$path';
}

class VenueDetail {
  final int id;
  final String name;
  final String address;
  final String price;
  final String openTime;
  final String closeTime;
  final String category;
  final String city;
  final List<String> images;
  final String deskripsi;
  final List<Facility> facilities;
  final String rules;
  final String ownerId;

  VenueDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.price,
    required this.openTime,
    required this.closeTime,
    required this.category,
    required this.city,
    required this.images,
    required this.deskripsi,
    required this.facilities,
    required this.rules,
    // required this.ownerId,
    required this.ownerId,
  });

  factory VenueDetail.fromJson(Map<String, dynamic> json) {
    return VenueDetail(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      price: json['price']?.toString() ?? '0',
      openTime: json['open_time'],
      closeTime: json['close_time'],
      category: json['category']['name'],
      city: json['city']['name'],
      // images: List<String>.from(json['images'].map((img) => img['image_url'])),
      images: List<String>.from(
        json['images'].map((img) => getFullImageUrl(img['image_url'])),
      ),
      deskripsi: json['deskripsi'],
      facilities: (json['facilities'] as List<dynamic>)
          .map((f) => Facility.fromJson(f))
          .toList(),
      rules: json['rules'],
      ownerId: json['user_id'].toString(),
    );
  }
}
