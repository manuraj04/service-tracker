import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bank.dart';
import '../providers/database_provider.dart';
import '../data/banks_list.dart';

class AddEditBankScreen extends ConsumerStatefulWidget {
  final BankEntry? bank;
  const AddEditBankScreen({super.key, this.bank});

  @override
  ConsumerState<AddEditBankScreen> createState() => _AddEditBankScreenState();
}

class _AddEditBankScreenState extends ConsumerState<AddEditBankScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bankController;
  late TextEditingController _branchController;
  late TextEditingController _branchCodeController;
  late TextEditingController _ifscController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _addressController;
  final bool _isSearchingBranch = false;

  @override
  void initState() {
    super.initState();
    _bankController = TextEditingController(text: widget.bank?.bankName ?? '');
    _branchController = TextEditingController(text: widget.bank?.branchName ?? '');
    _branchCodeController = TextEditingController(text: widget.bank?.branchCode ?? '');
    _ifscController = TextEditingController(text: widget.bank?.ifscCode ?? '');
    _contactNameController = TextEditingController(text: widget.bank?.contactName ?? '');
    _contactPhoneController = TextEditingController(text: widget.bank?.contactPhone ?? '');
    _addressController = TextEditingController(text: widget.bank?.address ?? '');
  }

  @override
  void dispose() {
    _bankController.dispose();
    _branchController.dispose();
    _branchCodeController.dispose();
    _ifscController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final bank = BankEntry(
      id: widget.bank?.id,
      bankName: _bankController.text.trim(),
      branchName: _branchController.text.trim(),
      branchCode: _branchCodeController.text.trim(),
      ifscCode: _ifscController.text.trim(),
      contactName: _contactNameController.text.trim(),
      contactPhone: _contactPhoneController.text.trim(),
      address: _addressController.text.trim(),
    );
    final notifier = ref.read(bankListProvider.notifier);
    try {
      if (widget.bank == null) {
        await notifier.addBank(bank);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bank added')));
      } else {
        await notifier.updateBank(bank);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bank updated')));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text(widget.bank == null ? 'Add Bank' : 'Edit Bank')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width < 600 ? width - 24 : 600),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: _bankController.text),
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                      final input = textEditingValue.text.toLowerCase();
                      return kAllBanks.where((b) => b.toLowerCase().contains(input));
                    },
                    onSelected: (selection) {
                      _bankController.text = selection;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.account_balance), labelText: 'Bank Name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter bank name' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _branchController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on), labelText: 'Branch Name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter branch name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _branchCodeController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.code), labelText: 'Branch Code'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter branch code' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ifscController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.numbers), labelText: 'IFSC Code'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter IFSC code' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contactNameController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.person), labelText: 'Contact Name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contactPhoneController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.phone), labelText: 'Contact Phone'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.location_city), labelText: 'Branch Address'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.cancel), label: const Text('Cancel'))),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Save'))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
