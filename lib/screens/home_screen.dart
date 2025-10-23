import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../services/export_service.dart';
import 'bank_list_screen.dart';
import 'bank_selection_screen.dart';
import 'upcoming_visits_screen.dart';
import '../services/firestore_sync_service.dart';
import '../db/app_database.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Engineer Tracker'),
        actions: [
          IconButton(
            icon: Icon(
              switch (themeMode) {
                ThemeMode.light => Icons.dark_mode,
                ThemeMode.dark => Icons.light_mode,
                ThemeMode.system => Icons.brightness_auto,
              }
            ),
            onPressed: () => _showThemeSelector(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _showExportOptions(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.08)),
                child: FutureBuilder<String>(
                  future: AuthService.getUserName(),
                  builder: (context, snap) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(radius: 28, backgroundColor: Theme.of(context).colorScheme.primary, child: const Icon(Icons.person, color: Colors.white)),
                      const SizedBox(height: 12),
                      Text(snap.data ?? 'Engineer', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
              ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () => _showSettings(context)),
              ListTile(leading: const Icon(Icons.info), title: const Text('About'), onTap: () {}),
              const Spacer(),
              ListTile(leading: const Icon(Icons.logout), title: const Text('Sign out'), onTap: () async { await AuthService.signOut(); Navigator.of(context).pop(); }),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cross = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth < 900 ? 2 : 3);
                  return GridView.count(
                    crossAxisCount: cross,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3,
                    children: [
                      _HomeTile(
                        icon: Icons.account_balance,
                        label: 'View Banks',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BankListScreen())),
                      ),
                      _HomeTile(
                        icon: Icons.add_business,
                        label: 'Add Bank',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BankSelectionScreen())),
                      ),
                      _HomeTile(
                        icon: Icons.miscellaneous_services,
                        label: 'Machines',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BankListScreen())),
                      ),
                      _HomeTile(
                        icon: Icons.calendar_month,
                        label: 'Upcoming Visits',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpcomingVisitsScreen())),
                      ),
                      _HomeTile(
                        icon: Icons.assignment_turned_in,
                        label: 'CSR Status',
                        onTap: () => _showCsrStatusReport(context),
                      ),
                      _HomeTile(
                        icon: Icons.share,
                        label: 'Share App',
                        onTap: () {},
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System'),
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export to Excel'),
              subtitle: const Text('Create spreadsheet with all data'),
              onTap: () => _exportData(context, isExcel: true),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export to PDF'),
              subtitle: const Text('Generate detailed PDF report'),
              onTap: () => _exportData(context, isExcel: false),
            ),
          ],
        ),
      ),
    );
  }

  void _exportData(BuildContext context, {required bool isExcel}) async {
    Navigator.pop(context); // Close bottom sheet
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Export Options'),
              subtitle: Text('Choose data to include in ${isExcel ? 'Excel' : 'PDF'} export'),
            ),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Data'),
              onTap: () => _performExport(context, ExportFilter.all, isExcel),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('CSR Collected'),
              onTap: () => _performExport(context, ExportFilter.csrCollected, isExcel),
            ),
            ListTile(
              leading: const Icon(Icons.pending),
              title: const Text('CSR Pending'),
              onTap: () => _performExport(context, ExportFilter.csrPending, isExcel),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Upcoming Visits (30 days)'),
              onTap: () => _performExport(context, ExportFilter.upcomingVisits, isExcel),
            ),
          ],
        ),
      ),
    );
  }

  void _performExport(BuildContext context, ExportFilter filter, bool isExcel) async {
    try {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparing export...')),
      );

      final filePath = isExcel
          ? await ExportService.exportToExcel(
              banks: [], // TODO: Get from database
              machines: [], // TODO: Get from database
              filter: filter,
            )
          : await ExportService.exportToPdf(
              banks: [], // TODO: Get from database
              machines: [], // TODO: Get from database
              filter: filter,
            );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved to: $filePath'),
            action: SnackBarAction(
              label: 'OPEN',
              onPressed: () {
                // TODO: Open file using platform-specific method
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _showCsrStatusReport(BuildContext context) {
    // TODO: Implement CSR status report screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CSR Status Report'),
        content: const Text('This feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(leading: Icon(Icons.person), title: Text('Engineer')), 
              ListTile(
                leading: const Icon(Icons.health_and_safety),
                title: const Text('Check Firebase Status'),
                onTap: () => _checkFirebaseStatus(context),
              ),
              ListTile(leading: const Icon(Icons.sync), title: const Text('Sync local DB to Firebase'), onTap: () async {
                Navigator.pop(context);
                final scaffold = ScaffoldMessenger.of(context);
                scaffold.showSnackBar(const SnackBar(content: Text('Syncing...')));
                try {
                  final banks = await AppDatabase.instance.getAllBanks();
                  for (final b in banks) {
                    await FirestoreSyncService.pushBank(b);
                  }
                  scaffold.showSnackBar(const SnackBar(content: Text('Sync completed')));
                } catch (e) {
                  scaffold.showSnackBar(SnackBar(content: Text('Sync failed: $e')));
                }
              }),
              const ListTile(leading: Icon(Icons.info_outline), title: Text('About')), 
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _HomeTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.12)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary, child: Icon(icon, color: Colors.white)),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
