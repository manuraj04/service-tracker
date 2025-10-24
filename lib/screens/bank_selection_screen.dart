import 'package:flutter/material.dart';
import '../models/bank.dart';
import '../db/app_database.dart';
import '../data/banks_list.dart';

class BankSelectionScreen extends StatefulWidget {
  const BankSelectionScreen({super.key});

  @override
  State<BankSelectionScreen> createState() => _BankSelectionScreenState();
}

class _BankSelectionScreenState extends State<BankSelectionScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getFilteredBanks() {
    if (_searchQuery.isEmpty) return kAllBanks;
    return kAllBanks.where((bank) =>
      bank.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  Widget _buildBankLogo(String bankName) {
    // Default fallback logo
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          bankName.substring(0, 1),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBanks = _getFilteredBanks();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Select Bank', style: Theme.of(context).appBarTheme.titleTextStyle),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your bank',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold) ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select which bank you have an account with',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color) ?? const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: kAllBanks.length,
              itemBuilder: (context, index) {
                final bank = kAllBanks[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () => _showBranchSelection(context, bank),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              bank.substring(0, 1),
                              style: TextStyle(
                                color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 80,
                          child: Text(
                            bank,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12) ?? const TextStyle(color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color) ?? const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search bank',
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color) ?? const TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredBanks.length,
              itemBuilder: (context, index) {
                final bank = filteredBanks[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  leading: _buildBankLogo(bank),
                  title: Text(
                    bank,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16) ?? const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onTap: () => _showBranchSelection(context, bank),
                );
              },
            ),
          ),
        ],
          ),
          if (_isLoading)
            Container(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showBranchSelection(BuildContext context, String bankName) async {
    final branchName = await showDialog<String>(
      context: context,
      builder: (context) => AddBranchDialog(bankName: bankName),
    );

    if (branchName != null && context.mounted) {
      try {
        setState(() => _isLoading = true);
        // Create new bank entry
        final bank = BankEntry(
          bankName: bankName,
          branchName: branchName,
        );
        await AppDatabase.instance.insertBank(bank);
        
        if (context.mounted) {
          Navigator.pop(context); // Return to previous screen
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding bank: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}

class AddBranchDialog extends StatefulWidget {
  final String bankName;
  
  const AddBranchDialog({
    required this.bankName,
    super.key,
  });

  @override
  State<AddBranchDialog> createState() => _AddBranchDialogState();
}

class _AddBranchDialogState extends State<AddBranchDialog> {
  final _branchController = TextEditingController();
  String _branchName = '';

  @override
  void dispose() {
    _branchController.dispose();
    super.dispose();
  }

  void _handleTextChanged(String value) {
    setState(() {
      _branchName = value.trim();
    });
  }

  void _handleAdd() {
    if (_branchName.isNotEmpty) {
      Navigator.pop(context, _branchName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      title: Text(
        'Add Branch',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank: ${widget.bankName}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _branchController,
            onChanged: _handleTextChanged,
            autofocus: true,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Branch Name',
              labelStyle: Theme.of(context).textTheme.bodySmall,
              hintText: 'Enter branch name',
              hintStyle: Theme.of(context).textTheme.bodySmall,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('CANCEL', style: Theme.of(context).textTheme.labelLarge),
        ),
        TextButton(
          onPressed: _branchName.isNotEmpty ? _handleAdd : null,
          child: const Text('ADD'),
        ),
      ],
    );
  }
}