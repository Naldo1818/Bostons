class Customer {
  final int? id;
  final String name;
  final String phone;
  final int haircutId;
  final String haircutName;
  final double price;
  final DateTime createdAt;
  final String status;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    required this.haircutId,
    required this.haircutName,
    required this.price,
    required this.createdAt,
    this.status = 'waiting',
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
      id: map['id'],
      name: map['name'],
      phone: map['phone'] ?? '',
      haircutId: map['haircut_id'],
      haircutName: map['haircut_name'],
      price: (map['price'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at']),
      status: map['status'] ?? 'waiting',
    );
  }
}
