import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/completed_cut.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseHelper db = DatabaseHelper();

  List<CompletedCut> cuts = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final result = await db.getCompletedCuts();

    if (!mounted) return;

    setState(() {
      cuts = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    double total = 0;

    for (final cut in cuts) {
      total += cut.price;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Cuts'),
        actions: [
          IconButton(
            onPressed: loadHistory,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Revenue'),
                      SizedBox(height: 5),
                      Text(
                        'All completed cuts',
                      ),
                    ],
                  ),
                  Text(
                    'R${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: cuts.isEmpty
                ? const Center(
                    child: Text(
                      'No completed cuts yet.',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cuts.length,
                    itemBuilder: (context, index) {
                      final cut = cuts[index];

                      final date = DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(
                        cut.completedAt,
                      );

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(
                              Icons.check,
                            ),
                          ),
                          title: Text(
                            cut.customerName,
                          ),
                          subtitle: Text(
                            '${cut.haircutName}\n$date',
                          ),
                          isThreeLine: true,
                          trailing: Text(
                            'R${cut.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
