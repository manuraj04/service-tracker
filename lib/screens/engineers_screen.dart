import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/engineer.dart';
import '../providers/extended_providers.dart';

class EngineersScreen extends ConsumerWidget {
  const EngineersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineersAsync = ref.watch(engineersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Engineers'),
      ),
      body: engineersAsync.when(
        data: (engineers) => engineers.isEmpty
            ? const Center(child: Text('No engineers found'))
            : ListView.builder(
                itemCount: engineers.length,
                itemBuilder: (context, index) {
                  final engineer = engineers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(engineer.name[0].toUpperCase()),
                    ),
                    title: Text(engineer.name),
                    subtitle: Text(engineer.assignedArea),
                    trailing: Icon(
                      engineer.activeStatus ? Icons.check_circle : Icons.error,
                      color: engineer.activeStatus ? Colors.green : Colors.red,
                    ),
                    onTap: () => _showEngineerDetails(context, engineer),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewEngineer(context, ref),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showEngineerDetails(BuildContext context, Engineer engineer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Engineer Details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Name'),
                subtitle: Text(engineer.name),
              ),
              ListTile(
                title: const Text('Phone'),
                subtitle: Text(engineer.phone),
                trailing: IconButton(
                  icon: const Icon(Icons.phone),
                  onPressed: () {/* TODO: Launch phone call */},
                ),
              ),
              ListTile(
                title: const Text('Email'),
                subtitle: Text(engineer.email),
                trailing: IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () {/* TODO: Launch email */},
                ),
              ),
              ListTile(
                title: const Text('Assigned Area'),
                subtitle: Text(engineer.assignedArea),
              ),
              ExpansionTile(
                title: const Text('Specializations'),
                children: engineer.specializations
                    .map((s) => ListTile(title: Text(s)))
                    .toList(),
              ),
              SwitchListTile(
                title: const Text('Active Status'),
                value: engineer.activeStatus,
                onChanged: null, // Read-only in details view
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewEngineer(BuildContext context, WidgetRef ref) {
    // TODO: Navigate to Add Engineer Screen
  }
}