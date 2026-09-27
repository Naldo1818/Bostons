import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/customer.dart';
import '../models/haircut.dart';
import '../widgets/customer_card.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  final DatabaseHelper db = DatabaseHelper();

  List<Customer> customers = [];
  List<Haircut> haircuts = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final customerList = await db.getWaitingCustomers();

    final haircutList = await db.getHaircuts();

    if (!mounted) return;

    setState(() {
      customers = customerList;
      haircuts = haircutList;
    });
  }

  Future<void> addCustomer() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    Haircut? selectedHaircut = haircuts.isNotEmpty ? haircuts.first : null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Customer'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Haircut>(
                      initialValue: selectedHaircut,
                      decoration: const InputDecoration(
                        labelText: 'Haircut',
                      ),
                      items: haircuts.map(
                        (haircut) {
                          return DropdownMenuItem(
                            value: haircut,
                            child: Text(
                              '${haircut.name} - R${haircut.price.toStringAsFixed(0)}',
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedHaircut = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      return;
                    }

                    if (selectedHaircut == null) {
                      return;
                    }

                    await db.addCustomer(
                      Customer(
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        haircutId: selectedHaircut!.id!,
                        haircutName: selectedHaircut!.name,
                        price: selectedHaircut!.price,
                        status: 'waiting',
                        createdAt: DateTime.now(),
                      ),
                    );

                    if (!context.mounted) return;

                    Navigator.pop(context);

                    await loadData();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> completeCustomer(
    Customer customer,
  ) async {
    await db.completeCustomer(customer);
    await loadData();
  }

  Future<void> deleteCustomer(
    Customer customer,
  ) async {
    await db.removeCustomer(customer.id!);
    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Queue'),
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: customers.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                  ),
                  SizedBox(height: 12),
                  Text('No customers waiting'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];

                return CustomerCard(
                  customer: customer,
                  onComplete: () {
                    completeCustomer(customer);
                  },
                  onDelete: () {
                    deleteCustomer(customer);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addCustomer,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
      ),
    );
  }
}
