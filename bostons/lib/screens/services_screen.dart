import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/haircut.dart';
import '../widgets/service_card.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final db = DatabaseHelper.instance;

  List<Haircut> haircuts = [];

  @override
  void initState() {
    super.initState();
    loadHaircuts();
  }

  Future<void> loadHaircuts() async {
    final result = await db.getHaircuts();

    if (!mounted) return;

    setState(() {
      haircuts = result;
    });
  }

  Future<void> addService() async {
    await showServiceDialog();
  }

  Future<void> editService(Haircut haircut) async {
    await showServiceDialog(haircut: haircut);
  }

  Future<void> showServiceDialog({
    Haircut? haircut,
  }) async {
    final nameController = TextEditingController(
      text: haircut?.name ?? '',
    );

    final priceController = TextEditingController(
      text: haircut?.price.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            haircut == null ? 'Add Service' : 'Edit Service',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Service name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: 'R ',
                ),
              ),
            ],
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
                final name = nameController.text.trim();

                final price = double.tryParse(
                  priceController.text.trim(),
                );

                if (name.isEmpty || price == null) {
                  return;
                }

                if (haircut == null) {
                  await db.addHaircut(
                    Haircut(
                      name: name,
                      price: price,
                    ),
                  );
                } else {
                  await db.updateHaircut(
                    Haircut(
                      id: haircut.id,
                      name: name,
                      price: price,
                    ),
                  );
                }

                if (!context.mounted) return;

                Navigator.pop(context);

                await loadHaircuts();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteService(
    Haircut haircut,
  ) async {
    await db.deleteHaircut(haircut.id!);
    await loadHaircuts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services & Prices'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: haircuts.length,
        itemBuilder: (context, index) {
          final haircut = haircuts[index];

          return ServiceCard(
            haircut: haircut,
            onEdit: () {
              editService(haircut);
            },
            onDelete: () {
              deleteService(haircut);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addService,
        icon: const Icon(Icons.add),
        label: const Text('Service'),
      ),
    );
  }
}
