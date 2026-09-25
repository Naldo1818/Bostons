class Haircut {
  final int? id;
  final String name;
  final double price;

  Haircut({
    this.id,
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  factory Haircut.fromMap(Map<String, dynamic> map) {
    return Haircut(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
    );
  }
}
