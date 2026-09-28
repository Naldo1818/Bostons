class CallOut {
  final int? id;
  final String customerName;
  final String address;
  final int serviceId;
  final String serviceName;
  final double servicePrice;
  final DateTime callOutTime;
  final String status;
  final DateTime createdAt;

  const CallOut({
    this.id,
    required this.customerName,
    required this.address,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.callOutTime,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'address': address,
      'service_id': serviceId,
      'service_name': serviceName,
      'service_price': servicePrice,
      'call_out_time': callOutTime.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CallOut.fromMap(Map<String, dynamic> map) {
    return CallOut(
      id: map['id'] as int?,
      customerName: map['customer_name'] as String,
      address: map['address'] as String,
      serviceId: map['service_id'] as int,
      serviceName: map['service_name'] as String,
      servicePrice: (map['service_price'] as num).toDouble(),
      callOutTime: DateTime.parse(
        map['call_out_time'] as String,
      ),
      status: map['status'] as String,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
    );
  }
}
