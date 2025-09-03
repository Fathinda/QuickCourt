class FnbCategoriesModel {
  final int id;
  final String name;

  FnbCategoriesModel({required this.id, required this.name});

  factory FnbCategoriesModel.fromJson(Map<String, dynamic> json) {
    return FnbCategoriesModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
