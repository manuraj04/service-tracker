import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/bank.dart';
import '../providers/database_provider.dart';
import 'add_edit_machine_screen.dart';
import 'machine_detail_screen.dart';

/// Machine list for a specific bank branch.
class MachineListScreen extends ConsumerWidget {
  final BankEntry bank;
  const MachineListScreen({super.key, required this.bank});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machinesAsync = ref.watch(machineListProvider(bank.id!));

    return Scaffold(
      appBar: AppBar(title: Text('${bank.bankName} - ${bank.branchName}')),
      body: machinesAsync.when(
        data: (machines) {
          if (machines.isEmpty) {
            return const Center(child: Text('No machines found'));
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListView.builder(
              itemCount: machines.length,
              itemBuilder: (context, index) {
                final m = machines[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.miscellaneous_services, color: Colors.white),
                    ),
                    title: Text(
                      m.machineType,
                      style: const TextStyle(fontWeight: FontWeight.w600)
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Next: ${DateFormat.yMMMd().format(m.nextVisitDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (m.isCsrCollected)
                          const Text(
                            'CSR ✓',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Edit',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditMachineScreen(
                                bank: bank,
                                machine: m
                              )
                            )
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          tooltip: 'Details',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MachineDetailScreen(machine: m)
                            )
                          ),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MachineDetailScreen(machine: m)
                      )
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditMachineScreen(bank: bank)
          )
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Machine'),
      ),
    );
  }
}
