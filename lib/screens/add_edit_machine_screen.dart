import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bank.dart';
import '../models/machine.dart';
import '../providers/database_provider.dart';
import '../widgets/custom_date_picker.dart';
import '../services/calendar_service.dart';

class AddEditMachineScreen extends ConsumerStatefulWidget {
  final BankEntry bank;
  final Machine? machine;
  const AddEditMachineScreen({super.key, required this.bank, this.machine});

  @override
  ConsumerState<AddEditMachineScreen> createState() => _AddEditMachineScreenState();
}

class _AddEditMachineScreenState extends ConsumerState<AddEditMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeController;
  late TextEditingController _serialController;
  late DateTime _lastVisit;
  late DateTime _nextVisit;
  late DateTime _installationDate;
  bool _isCsr = false;

  @override
  void initState() {
    super.initState();
    final m = widget.machine;
    _typeController = TextEditingController(text: m?.machineType ?? '');
    _serialController = TextEditingController(text: m?.serialNumber ?? '');
    _lastVisit = m?.lastVisitDate ?? DateTime.now();
    _nextVisit = m?.nextVisitDate ?? DateTime.now().add(const Duration(days: 30));
    _installationDate = m?.installationDate ?? DateTime.now();
    _isCsr = m?.isCsrCollected ?? false;
  }

  @override
  void dispose() {
    _typeController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  Future<void> _pickLast() async {
    final picked = await CustomDatePicker.pickDate(context, _lastVisit);
    if (picked != null) setState(() => _lastVisit = picked);
  }

  Future<void> _pickNext() async {
    final picked = await CustomDatePicker.pickDate(context, _nextVisit);
    if (picked != null) setState(() => _nextVisit = picked);
  }

  Future<void> _pickInstallation() async {
    final picked = await CustomDatePicker.pickDate(context, _installationDate);
    if (picked != null) setState(() => _installationDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final machine = Machine(
      id: widget.machine?.id,
      bankId: widget.bank.id!,
      machineType: _typeController.text.trim(),
      serialNumber: _serialController.text.trim(),
      lastVisitDate: _lastVisit,
      nextVisitDate: _nextVisit,
      installationDate: _installationDate,
      isCsrCollected: _isCsr,
    );

    final notifier = ref.read(machineListProvider(widget.bank.id!).notifier);
    try {
      if (widget.machine == null) {
        await notifier.addMachine(machine);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Machine added')));
      } else {
        await notifier.updateMachine(machine);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Machine updated')));
      }

      // Create calendar event for nextVisitDate
      try {
        final title = 'Service Visit - ${widget.bank.bankName} ${widget.bank.branchName}';
        final desc = 'Service for ${machine.machineType} (S/N: ${machine.serialNumber})';
        await CalendarService.instance.createAllDayEvent(date: machine.nextVisitDate, title: title, description: desc);
      } catch (_) {
        // ignore calendar errors but don't block save
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.machine == null ? 'Add Machine' : 'Edit Machine')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.miscellaneous_services), labelText: 'Machine Type'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter machine type' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _serialController,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.format_list_numbered), labelText: 'Serial Number'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter serial number' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Last Visit Date'),
                subtitle: Text(CustomDatePicker.format(_lastVisit)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickLast,
              ),
              ListTile(
                title: const Text('Next Visit Date'),
                subtitle: Text(CustomDatePicker.format(_nextVisit)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickNext,
              ),
              ListTile(
                title: const Text('Installation Date'),
                subtitle: Text(CustomDatePicker.format(_installationDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickInstallation,
              ),
              SwitchListTile(
                title: const Text('CSR Collected'),
                value: _isCsr,
                onChanged: (v) => setState(() => _isCsr = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), label: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Save'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
