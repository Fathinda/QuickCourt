class Venue {
  final int id;
  final String name;
  final String address;
  final int capacity;
  final String price;
  final String status;
  final String category;
  final String city;
  final String? thumbnail;
  final String openTime;
  final String closeTime;
  final String? imageUrlFromServer;

  Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.capacity,
    required this.price,
    required this.status,
    required this.category,
    required this.city,
    this.thumbnail,
    required this.openTime,
    required this.closeTime,
    this.imageUrlFromServer,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      capacity: int.tryParse(json['capacity'].toString()) ?? 0,
      price: json['price']?.toString() ?? '0',
      thumbnail: json['thumbnail'] ?? '',
      status: json['status'] ?? '',
      category: json['category']?['name'] ?? '',
      city: json['city']?['name'] ?? '',
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      imageUrlFromServer: json['image_url'] ?? '',
    );
  }

  // String get imageUrl => thumbnail ?? '';
  String get imageUrl {
    final img = (thumbnail != null && thumbnail!.isNotEmpty)
        ? thumbnail
        : imageUrlFromServer;
    if (img == null || img.isEmpty) {
      return "https://via.placeholder.com/150";
    }
    if (img.startsWith("http")) {
      return img;
    }
    return "http://192.168.1.19:8000/storage/$img";
  }
}
