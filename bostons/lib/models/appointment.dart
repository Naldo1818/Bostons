class Appointment {
  final int? id;
  final String customerName;
  final String phone;
  final int serviceId;
  final String serviceName;
  final double servicePrice;
  final double bookingFee;
  final DateTime appointmentTime;
  final String status;
  final DateTime createdAt;

  const Appointment({
    this.id,
    required this.customerName,
    required this.phone,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.bookingFee,
    required this.appointmentTime,
    required this.status,
    required this.createdAt,
  });

  double get totalPrice {
    return servicePrice + bookingFee;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'phone': phone,
      'service_id': serviceId,
      'service_name': serviceName,
      'service_price': servicePrice,
      'booking_fee': bookingFee,
      'appointment_time': appointmentTime.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as int?,
      customerName: map['customer_name'] as String,
      phone: map['phone'] as String? ?? '',
      serviceId: map['service_id'] as int,
      serviceName: map['service_name'] as String,
      servicePrice: (map['service_price'] as num).toDouble(),
      bookingFee: (map['booking_fee'] as num).toDouble(),
      appointmentTime: DateTime.parse(
        map['appointment_time'] as String,
      ),
      status: map['status'] as String,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
    );
  }
}
