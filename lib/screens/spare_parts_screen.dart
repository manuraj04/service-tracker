import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spare_part.dart';
import '../providers/extended_providers.dart';

class SparePartsScreen extends ConsumerWidget {
  const SparePartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partsAsync = ref.watch(sparePartsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spare Parts Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: partsAsync.when(
        data: (parts) => parts.isEmpty
            ? const Center(child: Text('No spare parts found'))
            : ListView.builder(
                itemCount: parts.length,
                itemBuilder: (context, index) {
                  final part = parts[index];
                  final isLowStock = part.currentStock <= part.minThreshold;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(part.name),
                      subtitle: Text('Part #: ${part.partNumber}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isLowStock ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Stock: ${part.currentStock}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _updateStock(context, ref, part),
                          ),
                        ],
                      ),
                      onTap: () => _showPartDetails(context, part),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewPart(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Parts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Low Stock Only'),
              value: false, // TODO: Implement filter state
              onChanged: (value) {
                // TODO: Implement filtering
                Navigator.pop(context);
              },
            ),
            CheckboxListTile(
              title: const Text('Recently Updated'),
              value: false, // TODO: Implement filter state
              onChanged: (value) {
                // TODO: Implement filtering
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPartDetails(BuildContext context, SparePart part) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Part Details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Part Name'),
                subtitle: Text(part.name),
              ),
              ListTile(
                title: const Text('Part Number'),
                subtitle: Text(part.partNumber),
              ),
              ListTile(
                title: const Text('Current Stock'),
                subtitle: Text(part.currentStock.toString()),
                trailing: Text(
                  part.currentStock <= part.minThreshold ? 'LOW STOCK' : 'OK',
                  style: TextStyle(
                    color: part.currentStock <= part.minThreshold
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Minimum Threshold'),
                subtitle: Text(part.minThreshold.toString()),
              ),
              ListTile(
                title: const Text('Last Restocked'),
                subtitle: Text(part.lastRestockDate.toString().split(' ')[0]),
              ),
              ExpansionTile(
                title: const Text('Compatible Machines'),
                children: part.machineTypes
                    .map((type) => ListTile(title: Text(type)))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateStock(BuildContext context, WidgetRef ref, SparePart part) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: TextFormField(
          initialValue: part.currentStock.toString(),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'New Stock Level',
          ),
          onFieldSubmitted: (value) {
            final newStock = int.tryParse(value);
            if (newStock != null) {
              ref
                  .read(sparePartsProvider.notifier)
                  .updateStock(part.id!, newStock);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Submit form
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _addNewPart(BuildContext context) {
    // TODO: Navigate to Add Part Screen
  }
}