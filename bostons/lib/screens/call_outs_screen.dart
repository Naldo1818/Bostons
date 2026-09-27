import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/call_out.dart';
import '../services/notification_service.dart';

class CallOutsScreen extends StatefulWidget {
  const CallOutsScreen({super.key});

  @override
  State<CallOutsScreen> createState() => _CallOutsScreenState();
}

class _CallOutsScreenState extends State<CallOutsScreen> {
  final DatabaseHelper _database = DatabaseHelper();

  List<CallOut> _callOuts = [];

  @override
  void initState() {
    super.initState();
    _loadCallOuts();
  }

  Future<void> _loadCallOuts() async {
    final callOuts = await _database.getCallOuts();

    if (!mounted) return;

    setState(() {
      _callOuts = callOuts;
    });
  }

  Future<void> _addCallOut() async {
    final nameController = TextEditingController();

    final addressController = TextEditingController();

    DateTime selectedDate = DateTime.now();

    TimeOfDay selectedTime = TimeOfDay.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Add Call Out',
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
                        prefixIcon: Icon(
                          Icons.person,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: addressController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(
                          Icons.location_on,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_today,
                      ),
                      title: const Text(
                        'Date',
                      ),
                      subtitle: Text(
                        DateFormat(
                          'dd/MM/yyyy',
                        ).format(
                          selectedDate,
                        ),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(
                              days: 365,
                            ),
                          ),
                        );

                        if (date != null) {
                          setDialogState(
                            () {
                              selectedDate = date;
                            },
                          );
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.access_time,
                      ),
                      title: const Text(
                        'Time',
                      ),
                      subtitle: Text(
                        selectedTime.format(
                          context,
                        ),
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );

                        if (time != null) {
                          setDialogState(
                            () {
                              selectedTime = time;
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter the customer name.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (addressController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter the address.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  child: const Text(
                    'Add Call Out',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      nameController.dispose();
      addressController.dispose();
      return;
    }

    final callOutTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (callOutTime.isBefore(
      DateTime.now(),
    )) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select a future time.',
            ),
          ),
        );
      }

      nameController.dispose();
      addressController.dispose();
      return;
    }

    final callOut = CallOut(
      customerName: nameController.text.trim(),
      address: addressController.text.trim(),
      callOutTime: callOutTime,
      status: 'upcoming',
      createdAt: DateTime.now(),
    );

    final id = await _database.addCallOut(
      callOut,
    );

    await NotificationService.scheduleCallOutReminder(
      id: id,
      customerName: callOut.customerName,
      address: callOut.address,
      callOutTime: callOut.callOutTime,
    );

    nameController.dispose();
    addressController.dispose();

    await _loadCallOuts();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Call out added. Reminder scheduled for 30 minutes before.',
        ),
      ),
    );
  }

  Future<void> _completeCallOut(
    CallOut callOut,
  ) async {
    if (callOut.id == null) {
      return;
    }

    await _database.updateCallOutStatus(
      callOut.id!,
      'completed',
    );

    await NotificationService.cancelCallOutReminder(
      callOut.id!,
    );

    await _loadCallOuts();
  }

  Future<void> _cancelCallOut(
    CallOut callOut,
  ) async {
    if (callOut.id == null) {
      return;
    }

    await _database.updateCallOutStatus(
      callOut.id!,
      'cancelled',
    );

    await NotificationService.cancelCallOutReminder(
      callOut.id!,
    );

    await _loadCallOuts();
  }

  Future<void> _deleteCallOut(
    CallOut callOut,
  ) async {
    if (callOut.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Call Out?',
          ),
          content: Text(
            'Delete the call out for ${callOut.customerName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                false,
              ),
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                true,
              ),
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

    await NotificationService.cancelCallOutReminder(
      callOut.id!,
    );

    await _database.deleteCallOut(
      callOut.id!,
    );

    await _loadCallOuts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Call Outs',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCallOut,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Call Out',
        ),
      ),
      body: _callOuts.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 64,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'No call outs scheduled',
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadCallOuts,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  100,
                ),
                itemCount: _callOuts.length,
                itemBuilder: (context, index) {
                  final callOut = _callOuts[index];

                  return _CallOutCard(
                    callOut: callOut,
                    onComplete: () => _completeCallOut(
                      callOut,
                    ),
                    onCancel: () => _cancelCallOut(
                      callOut,
                    ),
                    onDelete: () => _deleteCallOut(
                      callOut,
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _CallOutCard extends StatelessWidget {
  final CallOut callOut;
  final VoidCallback onComplete;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const _CallOutCard({
    required this.callOut,
    required this.onComplete,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final date = DateFormat(
      'EEE, dd MMM yyyy',
    ).format(
      callOut.callOutTime,
    );

    final time = DateFormat(
      'HH:mm',
    ).format(
      callOut.callOutTime,
    );

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(
                    Icons.directions_car,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    callOut.customerName,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                _StatusBadge(
                  status: callOut.status,
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 20,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    callOut.address,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 20,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(date),
                const SizedBox(
                  width: 16,
                ),
                const Icon(
                  Icons.access_time,
                  size: 20,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(time),
              ],
            ),
            if (callOut.status == 'upcoming') ...[
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(
                      Icons.close,
                    ),
                    label: const Text(
                      'Cancel',
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  FilledButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(
                      Icons.check,
                    ),
                    label: const Text(
                      'Complete',
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
        ),
      ),
    );
  }
}
