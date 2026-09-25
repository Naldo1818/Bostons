import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/completed_cut.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final db = DatabaseHelper.instance;

  int waiting = 0;
  int completed = 0;
  double revenue = 0;

  List<CompletedCut> todayCuts = [];

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final waitingCustomers = await db.getWaitingCustomers();

    final cuts = await db.getTodayCompletedCuts();

    double total = 0;

    for (final cut in cuts) {
      total += cut.price;
    }

    if (!mounted) return;

    setState(() {
      waiting = waitingCustomers.length;
      completed = cuts.length;
      revenue = total;
      todayCuts = cuts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'EEEE, d MMMM yyyy',
    ).format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bostons',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              date,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Today',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            StatCard(
              title: 'Customers Waiting',
              value: waiting.toString(),
              icon: Icons.people,
            ),
            StatCard(
              title: 'Completed Cuts',
              value: completed.toString(),
              icon: Icons.check_circle,
            ),
            StatCard(
              title: 'Today\'s Revenue',
              value: 'R${revenue.toStringAsFixed(2)}',
              icon: Icons.payments,
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Cuts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            if (todayCuts.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No completed cuts today.',
                  ),
                ),
              ),
            ...todayCuts.take(5).map(
                  (cut) => Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.content_cut),
                      ),
                      title: Text(cut.customerName),
                      subtitle: Text(cut.haircutName),
                      trailing: Text(
                        'R${cut.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
