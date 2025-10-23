import 'package:flutter/material.dart';
import '../models/bank_data.dart';
import '../models/bank.dart';
import '../db/app_database.dart';

class BankSelectionScreen extends StatefulWidget {
  const BankSelectionScreen({super.key});

  @override
  State<BankSelectionScreen> createState() => _BankSelectionScreenState();
}

class _BankSelectionScreenState extends State<BankSelectionScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Public Sector Bank',
    'Private Sector Bank',
    'Regional Rural Bank',
    'Small Finance Bank',
    'Cooperative Bank',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BankData> _getFilteredBanks() {
    return banks.where((bank) {
      if (_selectedCategory != 'All' && bank.category != _selectedCategory) {
        return false;
      }
      return bank.searchTerms.any(
        (term) => term.toLowerCase().contains(_searchQuery.toLowerCase())
      );
    }).toList();
  }

  Future<void> _showBranchSelection(BuildContext context, BankData bank) async {
    final branchName = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => BranchSelectionSheet(bank: bank),
    );

    if (branchName != null && mounted) {
      // Create new bank entry
      final newBank = BankEntry(
        bankName: bank.name,
        branchName: branchName,
      );

      try {
        await AppDatabase.instance.createBank(newBank);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bank added successfully')),
          );
          Navigator.pop(context); // Return to previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredBanks = _getFilteredBanks();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bank'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Autocomplete<BankData>(
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return SearchBar(
                      controller: controller,
                      focusNode: focusNode,
                      hintText: 'Search by bank name, code, location...',
                      leading: const Icon(Icons.search),
                      trailing: [
                        if (controller.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              controller.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                      ],
                      onChanged: (value) => setState(() => _searchQuery = value),
                    );
                  },
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<BankData>.empty();
                    }
                    return banks.where((bank) => 
                      bank.searchTerms.any((term) => 
                        term.toLowerCase().contains(textEditingValue.text.toLowerCase())
                      )
                    );
                  },
                  displayStringForOption: (BankData bank) => bank.name,
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final BankData option = options.elementAt(index);
                              return ListTile(
                                leading: Image.asset(
                                  option.logo,
                                  width: 32,
                                  height: 32,
                                  errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.account_balance),
                                ),
                                title: Text(option.name),
                                subtitle: Text('${option.category} • ${option.code}'),
                                onTap: () {
                                  onSelected(option);
                                  setState(() => _searchQuery = option.name);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        selected: _selectedCategory == category,
                        label: Text(category),
                        onSelected: (selected) {
                          setState(() => _selectedCategory = selected ? category : 'All');
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate the optimal number of columns based on width
          int crossAxisCount;
          if (constraints.maxWidth <= 400) {
            crossAxisCount = 1; // Single column for very small screens
          } else if (constraints.maxWidth <= 600) {
            crossAxisCount = 2;
          } else if (constraints.maxWidth <= 900) {
            crossAxisCount = 3;
          } else {
            crossAxisCount = 4; // For very large screens
          }

          // Adjust the aspect ratio based on available width
          double aspectRatio = constraints.maxWidth > 600 ? 1.1 : 0.85;

          return GridView.builder(
            padding: EdgeInsets.all(constraints.maxWidth > 600 ? 24 : 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
              crossAxisSpacing: constraints.maxWidth > 600 ? 24 : 16,
              mainAxisSpacing: constraints.maxWidth > 600 ? 24 : 16,
            ),
            itemCount: filteredBanks.length,
            itemBuilder: (context, index) {
              final bank = filteredBanks[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _showBranchSelection(context, bank),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Image.asset(
                          bank.logo,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.account_balance, size: 48),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  bank.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bank.category,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BranchSelectionSheet extends StatefulWidget {
  final BankData bank;
  const BranchSelectionSheet({super.key, required this.bank});

  @override
  State<BranchSelectionSheet> createState() => _BranchSelectionSheetState();
}

class _BranchSelectionSheetState extends State<BranchSelectionSheet> {
  final _branchController = TextEditingController();
  @override
  void dispose() {
    _branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        // Add bottom padding to account for keyboard
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter Branch Name',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _branchController,
            onChanged: null,
            autofocus: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.location_on),
              labelText: 'Branch Name',
              hintText: 'Enter branch name',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _branchController.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(context, _branchController.text.trim()),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}