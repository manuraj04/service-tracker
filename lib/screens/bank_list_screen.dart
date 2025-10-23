import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_provider.dart';
import 'add_edit_bank_screen.dart';
import 'machine_list_screen.dart';

class BankListScreen extends ConsumerStatefulWidget {
  const BankListScreen({super.key});

  @override
  ConsumerState<BankListScreen> createState() => _BankListScreenState();
}

class _BankListScreenState extends ConsumerState<BankListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final banksAsync = ref.watch(bankListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Banks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Material(
              elevation: 1,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search banks or branches',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
            ),
          ),
          Expanded(
            child: banksAsync.when(
              data: (banks) {
                final filtered = banks.where((b) => b.bankName.toLowerCase().contains(_query.toLowerCase()) || b.branchName.toLowerCase().contains(_query.toLowerCase())).toList();
                if (filtered.isEmpty) return const Center(child: Text('No banks found'));
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final bank = filtered[index];
                    return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary, child: const Icon(Icons.account_balance, color: Colors.white)),
                            title: Text(bank.bankName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(bank.branchName),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.list, size: 20),
                                  tooltip: 'Machines',
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MachineListScreen(bank: bank))),
                                ),
                            IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  tooltip: 'Edit Bank',
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditBankScreen(bank: bank))),
                                ),
                            IconButton(
                                  icon: const Icon(Icons.delete_forever, size: 20, color: Colors.redAccent),
                                  tooltip: 'Delete Bank',
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete bank?'), content: Text('Delete ${bank.bankName} - ${bank.branchName}? This will remove associated machines.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'))]));
                                    if (ok == true) {
                                      try {
                                        await ref.read(bankListProvider.notifier).deleteBank(bank.id!);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bank deleted')));
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                        }
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MachineListScreen(bank: bank))),
                          ),
                        );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditBankScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
