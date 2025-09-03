class FnbMenu {
  final int id;
  final String name;
  final String image;
  final String? imageUrl;
  final int price;
  final int categoryId;
  final String description;

  FnbMenu({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.categoryId,
    this.imageUrl,
    this.description = "",
  });

  factory FnbMenu.fromJson(Map<String, dynamic> json) {
    return FnbMenu(
      id: json['id'],
      name: json['name'],
      image: json['image'] ?? '',
      imageUrl: json['image_url'],
      price: json['price'],
      categoryId: json['categories_id'],
      description: json['description'] ?? "",
    );
  }

  FnbMenu copyWith({
    int? id,
    String? name,
    String? image,
    String? imageUrl,
    int? price,
    int? categoryId,
    String? description,
  }) {
    return FnbMenu(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
    );
  }
}
