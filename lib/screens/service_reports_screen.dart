import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_report.dart';
import '../providers/extended_providers.dart';

class ServiceReportsScreen extends ConsumerWidget {
  final String? visitId;
  final int? machineId;

  const ServiceReportsScreen({
    super.key,
    this.visitId,
    this.machineId,
  }) : assert(visitId != null || machineId != null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(serviceReportsProvider(visitId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Reports'),
      ),
      body: reportsAsync.when(
        data: (reports) => reports.isEmpty
            ? const Center(child: Text('No reports found'))
            : ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Report ${report.id}'),
                      subtitle: Text(
                        'Date: ${report.reportDate.toString().split(' ')[0]}\n'
                        'Status: ${report.machineStatus}',
                      ),
                      trailing: report.photosUrls.isNotEmpty
                          ? const Icon(Icons.photo_library)
                          : null,
                      onTap: () => _showReportDetails(context, report),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewReport(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showReportDetails(BuildContext context, ServiceReport report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Service Report Details',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('Date: ${report.reportDate.toString().split(' ')[0]}'),
              Text('Machine Status: ${report.machineStatus}'),
              const SizedBox(height: 8),
              Text('Parts Replaced:',
                  style: Theme.of(context).textTheme.titleMedium),
              ...report.partReplaced.map((part) => Text('• $part')),
              const SizedBox(height: 8),
              Text('Recommendations:',
                  style: Theme.of(context).textTheme.titleMedium),
              Text(report.recommendations),
              if (report.photosUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Photos:', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: report.photosUrls.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(
                        report.photosUrls[index],
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  TextButton(
                    onPressed: () {/* TODO: Export to PDF */},
                    child: const Text('Export PDF'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewReport(BuildContext context) {
    // TODO: Navigate to Create Report Screen
  }
}