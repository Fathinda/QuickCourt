class BookingHistory {
  final int id;
  final String venueName;
  final String venueCity;
  final String imageUrl;
  final String status;
  final String date;
  final String time;
  final double totalPrice;

  BookingHistory({
    required this.id,
    required this.venueName,
    required this.venueCity,
    required this.imageUrl,
    required this.status,
    required this.date,
    required this.time,
    required this.totalPrice,
  });

  factory BookingHistory.fromJson(Map<String, dynamic> json) {
    final venue = (json['venue'] is Map) ? json['venue'] : {};
    final city = (venue['city'] is Map) ? venue['city'] : {'name': ''};

    // String imagePath = '';
    // if (venue['primary_image'] != null &&
    //     venue['primary_image']['image_url'] != null) {
    //   imagePath =
    //       "http://192.168.1.19:8000/storage/${venue['primary_image']['image_url']}";
    // }

    String imagePath = '';
    if (venue['primary_image'] != null && venue['primary_image'] is Map) {
      final primaryImage = venue['primary_image'] as Map<String, dynamic>;
      if (primaryImage['image_url'] != null) {
        imagePath =
            "http://192.168.1.19:8000/storage/${primaryImage['image_url']}";
      }
    }

    return BookingHistory(
      // id: json['id'],
      // venueName: venue['name'] ?? '',
      // venueCity: city['name'] ?? '',
      // imageUrl: imagePath,
      // status: json['status'] ?? '',
      // date: json['booking_date']?.substring(0, 10) ?? '',
      // time: "${json['start_time'] ?? ''} - ${json['end_time'] ?? ''}",
      // totalPrice:
      //     double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      id: json['id'] ?? 0,
      venueName: venue['name'] ?? '',
      venueCity: city['name'] ?? '',
      imageUrl: imagePath,
      status: json['status'] ?? '',
      date: (json['booking_date'] ?? '').toString().substring(0, 10),
      time: "${json['start_time'] ?? ''} - ${json['end_time'] ?? ''}",
      totalPrice:
          double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
    );
  }
}
