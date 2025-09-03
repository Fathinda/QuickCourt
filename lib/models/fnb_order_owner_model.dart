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
      customerName: json['customer_name'],
      date: json['date'],
      status: json['status'],
      total: json['total'],
      items: List<String>.from(json['items']),
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
