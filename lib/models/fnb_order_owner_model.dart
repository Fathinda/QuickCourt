class FnbOrderOwner {
  final int id;
  final String customerName;
  final String date;
  final String status;
  final String paymentStatus;
  final int total;
  final List<String> items;
  final String? receiptUrl;     // ✅ bukti transfer (opsional)
  final String? receiptStatus;  // ✅ status bukti (waiting, verified, rejected)

  FnbOrderOwner({
    required this.id,
    required this.customerName,
    required this.date,
    required this.status,
    required this.paymentStatus,
    required this.total,
    required this.items,
    this.receiptUrl,     // ✅ ikutkan
    this.receiptStatus,  // ✅ ikutkan
  });

  factory FnbOrderOwner.fromJson(Map<String, dynamic> json) {
    return FnbOrderOwner(
      id: json['id'],
      customerName: json['customer_name'] ?? '-',
      date: json['created_at'] ?? '',
      status: json['status'] ?? 'unknown',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      total: int.tryParse(json['total_amount'].toString()) ?? 0,
      items: (json['items'] as List<dynamic>).map((item) {
        final menuName = item['menu_name'] ?? 'Unknown Menu';
        final qty = item['quantity'];
        return '$menuName x$qty';
      }).toList(),
      receiptUrl: json['receipt_url'],        // ✅ ambil dari API
      receiptStatus: json['receipt_status'],  // ✅ ambil dari API
    );
  }

  FnbOrderOwner copyWith({
    int? id,
    String? customerName,
    String? date,
    String? status,
    String? paymentStatus,
    int? total,
    List<String>? items,
    String? receiptUrl,
    String? receiptStatus,
  }) {
    return FnbOrderOwner(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      date: date ?? this.date,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      total: total ?? this.total,
      items: items ?? this.items,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      receiptStatus: receiptStatus ?? this.receiptStatus,
    );
  }
}
