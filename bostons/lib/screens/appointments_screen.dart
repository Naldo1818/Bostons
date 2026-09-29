import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/appointment.dart';
import '../models/haircut.dart';
import '../services/notification_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({
    super.key,
  });

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final DatabaseHelper _database = DatabaseHelper();

  List<Appointment> _appointments = [];
  List<Haircut> _services = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final appointments = await _database.getAppointments();

    final services = await _database.getHaircuts();

    if (!mounted) {
      return;
    }

    setState(() {
      _appointments = appointments;
      _services = services;
      _loading = false;
    });
  }

  Future<void> _showAddAppointmentDialog() async {
    if (_services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add a service first.',
          ),
        ),
      );
      return;
    }

    final nameController = TextEditingController();

    final phoneController = TextEditingController();

    final bookingFeeController = TextEditingController(
      text: '30',
    );

    Haircut selectedService = _services.first;

    DateTime selectedDate = DateTime.now().add(
      const Duration(days: 1),
    );

    TimeOfDay selectedTime = const TimeOfDay(
      hour: 10,
      minute: 0,
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final appointmentDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );

            final bookingFee = double.tryParse(
                  bookingFeeController.text.trim(),
                ) ??
                0;

            final total = selectedService.price + bookingFee;

            return AlertDialog(
              title: const Text(
                'Book Appointment',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    DropdownButtonFormField<Haircut>(
                      initialValue: selectedService,
                      decoration: const InputDecoration(
                        labelText: 'Service',
                        prefixIcon: Icon(
                          Icons.content_cut,
                        ),
                      ),
                      items: _services.map(
                        (
                          service,
                        ) {
                          return DropdownMenuItem<Haircut>(
                            value: service,
                            child: Text(
                              '${service.name} - R${service.price.toStringAsFixed(2)}',
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (service) {
                        if (service == null) {
                          return;
                        }

                        setDialogState(() {
                          selectedService = service;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextField(
                      controller: bookingFeeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Booking Fee',
                        prefixText: 'R ',
                        prefixIcon: Icon(
                          Icons.payments,
                        ),
                      ),
                      onChanged: (_) {
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_month,
                      ),
                      title: const Text(
                        'Appointment Date',
                      ),
                      subtitle: Text(
                        DateFormat(
                          'EEEE, dd MMMM yyyy',
                        ).format(
                          selectedDate,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(
                              days: 365,
                            ),
                          ),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.access_time,
                      ),
                      title: const Text(
                        'Appointment Time',
                      ),
                      subtitle: Text(
                        selectedTime.format(
                          context,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _priceRow(
                              'Service',
                              selectedService.price,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            _priceRow(
                              'Booking Fee',
                              bookingFee,
                            ),
                            const Divider(
                              height: 24,
                            ),
                            _priceRow(
                              'Total',
                              total,
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Reminder: 30 minutes before appointment',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format(
                        appointmentDateTime,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    final name = nameController.text.trim();

                    final phone = phoneController.text.trim();

                    final fee = double.tryParse(
                      bookingFeeController.text.trim(),
                    );

                    if (name.isEmpty) {
                      _showMessage(
                        'Enter the customer name.',
                      );
                      return;
                    }

                    if (fee == null || fee < 0) {
                      _showMessage(
                        'Enter a valid booking fee.',
                      );
                      return;
                    }

                    if (appointmentDateTime.isBefore(
                      DateTime.now(),
                    )) {
                      _showMessage(
                        'Appointment must be in the future.',
                      );
                      return;
                    }

                    final appointment = Appointment(
                      customerName: name,
                      phone: phone,
                      serviceId: selectedService.id!,
                      serviceName: selectedService.name,
                      servicePrice: selectedService.price,
                      bookingFee: fee,
                      appointmentTime: appointmentDateTime,
                      status: 'booked',
                      createdAt: DateTime.now(),
                    );

                    final id = await _database.addAppointment(
                      appointment,
                    );

                    await NotificationService.scheduleAppointmentReminder(
                      id: 100000 + id,
                      customerName: name,
                      serviceName: selectedService.name,
                      appointmentTime: appointmentDateTime,
                    );

                    if (!dialogContext.mounted) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                    );

                    await _loadData();

                    if (!mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(
                      this.context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Appointment booked successfully.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.check,
                  ),
                  label: const Text(
                    'Book',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
    bookingFeeController.dispose();
  }

  Widget _priceRow(
    String label,
    double amount, {
    bool bold = false,
  }) {
    final style = bold
        ? const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          )
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: style,
        ),
        Text(
          'R${amount.toStringAsFixed(2)}',
          style: style,
        ),
      ],
    );
  }

  Future<void> _completeAppointment(
    Appointment appointment,
  ) async {
    await _database.completeAppointment(
      appointment,
    );

    await NotificationService.cancelAppointmentReminder(
      100000 + appointment.id!,
    );

    await _loadData();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${appointment.customerName} completed. R${appointment.totalPrice.toStringAsFixed(2)} added to completed cuts.',
        ),
      ),
    );
  }

  Future<void> _cancelAppointment(
    Appointment appointment,
  ) async {
    await _database.updateAppointmentStatus(
      appointment.id!,
      'cancelled',
    );

    await NotificationService.cancelAppointmentReminder(
      100000 + appointment.id!,
    );

    await _loadData();
  }

  Future<void> _deleteAppointment(
    Appointment appointment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Appointment?',
          ),
          content: Text(
            'Delete the appointment for ${appointment.customerName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await NotificationService.cancelAppointmentReminder(
      100000 + appointment.id!,
    );

    await _database.deleteAppointment(
      appointment.id!,
    );

    await _loadData();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Color _statusColor(
    BuildContext context,
    String status,
  ) {
    switch (status) {
      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      case 'no_show':
        return Colors.orange;

      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _statusText(
    String status,
  ) {
    switch (status) {
      case 'completed':
        return 'Completed';

      case 'cancelled':
        return 'Cancelled';

      case 'no_show':
        return 'No Show';

      default:
        return 'Booked';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAppointmentDialog,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Book Appointment',
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _appointments.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 100,
                    ),
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      return _buildAppointmentCard(
                        _appointments[index],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'No appointments',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'Book your first appointment using the button below.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    Appointment appointment,
  ) {
    final date = DateFormat(
      'EEE, dd MMM yyyy',
    ).format(
      appointment.appointmentTime,
    );

    final time = DateFormat(
      'HH:mm',
    ).format(
      appointment.appointmentTime,
    );

    final statusColor = _statusColor(
      context,
      appointment.status,
    );

    final isBooked = appointment.status == 'booked';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Text(
                    appointment.customerName
                        .substring(
                          0,
                          1,
                        )
                        .toUpperCase(),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.customerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (appointment.phone.isNotEmpty)
                        Text(
                          appointment.phone,
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'cancel') {
                      _cancelAppointment(
                        appointment,
                      );
                    } else if (value == 'delete') {
                      _deleteAppointment(
                        appointment,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    if (isBooked)
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Text(
                          'Cancel',
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  12,
                ),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          time,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                const Icon(
                  Icons.content_cut,
                  size: 20,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    appointment.serviceName,
                  ),
                ),
                Text(
                  'R${appointment.servicePrice.toStringAsFixed(2)}',
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Icon(
                  Icons.payments,
                  size: 20,
                ),
                const SizedBox(
                  width: 8,
                ),
                const Expanded(
                  child: Text(
                    'Booking Fee',
                  ),
                ),
                Text(
                  'R${appointment.bookingFee.toStringAsFixed(2)}',
                ),
              ],
            ),
            const Divider(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  'R${appointment.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    _statusText(
                      appointment.status,
                    ),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (isBooked)
                  FilledButton.icon(
                    onPressed: () {
                      _completeAppointment(
                        appointment,
                      );
                    },
                    icon: const Icon(
                      Icons.check,
                    ),
                    label: const Text(
                      'Complete',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
