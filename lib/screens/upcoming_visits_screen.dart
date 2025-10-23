import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/database_provider.dart';
import '../models/machine.dart';
import '../db/app_database.dart';

class UpcomingVisitsScreen extends ConsumerWidget {
  const UpcomingVisitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMachinesAsync = ref.watch(allMachinesProvider);
      return Scaffold(
        appBar: AppBar(title: const Text('Upcoming Visits')),
        body: allMachinesAsync.when(
          data: (machines) {
            if (machines.isEmpty) return const Center(child: Text('No upcoming visits'));
            final sorted = [...machines];
            sorted.sort((a, b) => a.nextVisitDate.compareTo(b.nextVisitDate));
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _joinWithBanks(sorted),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
                final items = snap.data ?? [];
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final row = items[index];
                    final m = row['machine'] as Machine;
                    final bankName = row['bankName'] as String;
                    final branchName = row['branchName'] as String;
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary, child: const Icon(Icons.calendar_today, color: Colors.white)),
                        title: Text(m.machineType, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('$bankName - $branchName\n${DateFormat.yMMMd().format(m.nextVisitDate)}'),
                        isThreeLine: true,
                        trailing: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: () {}),
                      ),
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      );
  }

  Future<List<Map<String, dynamic>>> _joinWithBanks(List<Machine> machines) async {
    final db = AppDatabase.instance;
    final List<Map<String, dynamic>> out = [];
    for (final m in machines) {
      final bank = await db.getBank(m.bankId);
      out.add({'machine': m, 'bankName': bank?.bankName ?? '', 'branchName': bank?.branchName ?? ''});
    }
    return out;
  }
}
