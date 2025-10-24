import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_visit.dart';
import '../providers/extended_providers.dart';
import '../models/bank.dart';

class ServiceVisitListScreen extends ConsumerWidget {
  final BankEntry bank;

  const ServiceVisitListScreen({super.key, required this.bank});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(serviceVisitsProvider(bank.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Service Visits - ${bank.bankName}'),
      ),
      body: visitsAsync.when(
        data: (visits) => visits.isEmpty 
          ? const Center(child: Text('No service visits found'))
          : ListView.builder(
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];
                return ListTile(
                  title: Text('Visit on ${visit.visitDate.toString().split(' ')[0]}'),
                  subtitle: Text('Machine ID: ${visit.machineId}'),
                  trailing: Text(visit.serviceType),
                  onTap: () => _showVisitDetails(context, visit),
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewVisit(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showVisitDetails(BuildContext context, ServiceVisit visit) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Visit Details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Date: ${visit.visitDate.toString().split(' ')[0]}'),
              Text('Service Type: ${visit.serviceType}'),
              Text('Machine ID: ${visit.machineId}'),
              const SizedBox(height: 8),
              Text('Issues:', style: Theme.of(context).textTheme.titleMedium),
              ...visit.issues.map((i) => Text('• $i')),
              const SizedBox(height: 8),
              Text('Actions:', style: Theme.of(context).textTheme.titleMedium),
              ...visit.actions.map((a) => Text('• $a')),
              const SizedBox(height: 8),
              Text('Next Visit: ${visit.nextScheduledDate.toString().split(' ')[0]}'),
              if (visit.signatureUrl != null)
                Image.network(visit.signatureUrl!, height: 100),
              if (visit.csrDocumentUrl != null)
                ElevatedButton(
                  onPressed: () {/* TODO: View CSR document */},
                  child: const Text('View CSR Document'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewVisit(BuildContext context) {
    // TODO: Navigate to Add Visit Screen
  }
}