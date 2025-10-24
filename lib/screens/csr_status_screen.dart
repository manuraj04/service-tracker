import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../db/app_database.dart';
import '../models/bank.dart';
import '../models/machine.dart';

final csrDataProvider = FutureProvider<CsrStatusData>((ref) async {
  final db = AppDatabase.instance;
  final banks = await db.getAllBanks();
  final allMachines = <Machine>[];
  
  for (final bank in banks) {
    final machines = await db.getMachinesByBank(bank.id!);
    allMachines.addAll(machines);
  }
  
  return CsrStatusData(banks: banks, machines: allMachines);
});

class CsrStatusData {
  final List<BankEntry> banks;
  final List<Machine> machines;
  
  CsrStatusData({required this.banks, required this.machines});
  
  int get totalMachines => machines.length;
  int get csrCollected => machines.where((m) => m.isCsrCollected).length;
  int get csrPending => machines.where((m) => !m.isCsrCollected).length;
  double get collectionRate => totalMachines > 0 ? (csrCollected / totalMachines) * 100 : 0;
  
  Map<String, int> get bankWiseCollected {
    final result = <String, int>{};
    for (final bank in banks) {
      final bankMachines = machines.where((m) => m.bankId == bank.id);
      result[bank.bankName] = bankMachines.where((m) => m.isCsrCollected).length;
    }
    return result;
  }
  
  Map<String, int> get bankWisePending {
    final result = <String, int>{};
    for (final bank in banks) {
      final bankMachines = machines.where((m) => m.bankId == bank.id);
      result[bank.bankName] = bankMachines.where((m) => !m.isCsrCollected).length;
    }
    return result;
  }
}

class CsrStatusScreen extends ConsumerWidget {
  const CsrStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final csrDataAsync = ref.watch(csrDataProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSR Status Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(csrDataProvider),
          ),
        ],
      ),
      body: csrDataAsync.when(
        data: (data) => _buildContent(context, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(csrDataProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, CsrStatusData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_turned_in, 
                        size: 32, 
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Overall CSR Status',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Progress indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: data.collectionRate / 100,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        data.collectionRate >= 80 
                          ? Colors.green 
                          : data.collectionRate >= 50 
                            ? Colors.orange 
                            : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Machines',
                          value: data.totalMachines.toString(),
                          icon: Icons.devices,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Collected',
                          value: data.csrCollected.toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Pending',
                          value: data.csrPending.toString(),
                          icon: Icons.pending,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Collection rate
                  Center(
                    child: Text(
                      '${data.collectionRate.toStringAsFixed(1)}% Collection Rate',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Bank-wise breakdown
          Text(
            'Bank-wise CSR Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (data.banks.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No banks found'),
                    ],
                  ),
                ),
              ),
            )
          else
            ...data.banks.map((bank) {
              final collected = data.bankWiseCollected[bank.bankName] ?? 0;
              final pending = data.bankWisePending[bank.bankName] ?? 0;
              final total = collected + pending;
              final rate = total > 0 ? (collected / total) * 100 : 0;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: rate >= 80 
                      ? Colors.green.withOpacity(0.2) 
                      : rate >= 50 
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    child: Icon(
                      Icons.account_balance,
                      color: rate >= 80 
                        ? Colors.green 
                        : rate >= 50 
                          ? Colors.orange 
                          : Colors.red,
                    ),
                  ),
                  title: Text(
                    bank.bankName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(bank.branchName),
                  trailing: SizedBox(
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$collected / $total',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${rate.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: rate >= 80 
                              ? Colors.green 
                              : rate >= 50 
                                ? Colors.orange 
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _DetailCard(
                                  label: 'CSR Collected',
                                  value: collected.toString(),
                                  icon: Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DetailCard(
                                  label: 'CSR Pending',
                                  value: pending.toString(),
                                  icon: Icons.pending_outlined,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: rate / 100,
                              minHeight: 8,
                              backgroundColor: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          
          const SizedBox(height: 16),
          
          // Generated timestamp
          Center(
            child: Text(
              'Generated on ${DateFormat.yMMMd().add_jm().format(DateTime.now())}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  
  const _DetailCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
