import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/machine.dart';
import 'add_edit_machine_screen.dart';
import '../models/bank.dart';

class MachineDetailScreen extends StatelessWidget {
  final Machine machine;
  const MachineDetailScreen({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat.yMMMd();
    return Scaffold(
      appBar: AppBar(title: const Text('Machine Details')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 28, backgroundColor: Theme.of(context).colorScheme.primary, child: const Icon(Icons.miscellaneous_services, color: Colors.white)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(machine.machineType, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.date_range, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Installation Date: ${dateFmt.format(machine.installationDate)}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(children: [const Icon(Icons.format_list_numbered), const SizedBox(width: 8), Text(machine.serialNumber)]),
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.history), const SizedBox(width: 8), Text('Last: ${dateFmt.format(machine.lastVisitDate)}')]),
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.calendar_today), const SizedBox(width: 8), Text('Next: ${dateFmt.format(machine.nextVisitDate)}')]),
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.receipt), const SizedBox(width: 8), Text('CSR Collected: ${machine.isCsrCollected ? 'Yes' : 'No'}')]),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text('Back'))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton.icon(onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditMachineScreen(bank: BankEntry(id: machine.bankId, bankName: '', branchName: ''), machine: machine)));
                    }, icon: const Icon(Icons.edit), label: const Text('Edit'))),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
