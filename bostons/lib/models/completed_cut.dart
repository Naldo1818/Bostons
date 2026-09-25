class CompletedCut {
  final int? id;
  final String customerName;
  final String haircutName;
  final double price;
  final DateTime completedAt;

  CompletedCut({
    this.id,
    required this.customerName,
    required this.haircutName,
    required this.price,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'haircut_name': haircutName,
      'price': price,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory CompletedCut.fromMap(Map<String, dynamic> map) {
    return CompletedCut(
      id: map['id'],
      customerName: map['customer_name'],
      haircutName: map['haircut_name'],
      price: (map['price'] as num).toDouble(),
      completedAt: DateTime.parse(map['completed_at']),
    );
  }
}
