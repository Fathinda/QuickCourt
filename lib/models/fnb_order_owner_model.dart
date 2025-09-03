class FnbOrderOwner {
  final int id;
  final String customerName;
  final String date;
  final String status;
  final int total;
  final List<String> items;

  FnbOrderOwner({
    required this.id,
    required this.customerName,
    required this.date,
    required this.status,
    required this.total,
    required this.items,
  });

  factory FnbOrderOwner.fromJson(Map<String, dynamic> json) {
    return FnbOrderOwner(
      id: json['id'],
      customerName: json['user_id'].toString(), // sementara pakai user_id
      date: json['created_at'] ?? '',
      status: json['status'] ?? 'unknown',
      total: int.tryParse(json['total_amount'].toString()) ?? 0,
      items: (json['items'] as List<dynamic>).map((item) {
        final menuId = item['fnb_menu_id'];
        final qty = item['quantity'];
        return 'Menu ID $menuId x$qty';
      }).toList(),
    );
  }

  FnbOrderOwner copyWith({String? status}) {
    return FnbOrderOwner(
      id: id,
      customerName: customerName,
      date: date,
      status: status ?? this.status,
      total: total,
      items: items,
    );
  }
}
