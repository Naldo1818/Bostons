class Customer {
  final int? id;
  final String name;
  final String phone;
  final int haircutId;
  final String haircutName;
  final double price;
  final DateTime createdAt;
  final String status;

  const Customer({
    this.id,
    required this.name,
    required this.phone,
    required this.haircutId,
    required this.haircutName,
    required this.price,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'haircut_id': haircutId,
      'haircut_name': haircutName,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String? ?? '',
      haircutId: map['haircut_id'] as int,
      haircutName: map['haircut_name'] as String,
      price: (map['price'] as num).toDouble(),
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
      status: map['status'] as String,
    );
  }
}
