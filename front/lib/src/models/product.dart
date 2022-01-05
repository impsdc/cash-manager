/// A placeholder class that represents an entity or model.
class Product {
  final int? id;
  final int price;
  final String name;
  final int quantity;
  final String image;

  const Product(this.id,
      {required this.name,
      required this.price,
      required this.quantity,
      required this.image});
}
