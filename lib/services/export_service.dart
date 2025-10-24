import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../models/bank.dart';
import '../models/machine.dart';

final dateFmt = DateFormat.yMMMd();

class ExportService {
  static const _headers = [
    'Bank Name',
    'Branch Name',
    'Machine Type',
    'Serial Number',
    'Installation Date',
    'Last Visit Date',
    'Next Visit Date',
    'CSR Status',
  ];

  static Future<String> _getOutputFile(String fileName) async {
    // Request storage permission
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        // Try manageExternalStorage for Android 11+
        final manageStatus = await Permission.manageExternalStorage.request();
        if (!manageStatus.isGranted) {
          throw Exception('Storage permission denied');
        }
      }
    }
    
    // For Android, save to Downloads folder
    if (Platform.isAndroid) {
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return '${directory.path}/$fileName';
    } else {
      // For other platforms, use documents directory
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}/$fileName';
    }
  }

  static Future<String> exportToExcel({
    required List<BankEntry>banks,
    required List<Machine> machines,
    required ExportFilter filter,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Service Data'];
    
    // Add headers
    for (var i = 0; i < _headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(_headers[i])
        ..cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center
        );
    }

    // Filter and add data
    var rowIndex = 1;
    for (final bank in banks) {
      final bankMachines = machines.where((m) => m.bankId == bank.id);
      for (final machine in bankMachines) {
        if (_shouldInclude(machine, filter)) {
          final rowData = [
            bank.bankName,
            bank.branchName,
            machine.machineType,
            machine.serialNumber,
            machine.installationDate.toString(),
            machine.lastVisitDate.toString(),
            machine.nextVisitDate.toString(),
            machine.isCsrCollected ? 'Collected' : 'Pending',
          ];
          
          for (var colIndex = 0; colIndex < rowData.length; colIndex++) {
            sheet.cell(CellIndex.indexByColumnRow(
              columnIndex: colIndex, 
              rowIndex: rowIndex
            )).value = TextCellValue(rowData[colIndex]);
          }
          rowIndex++;
        }
      }
    }

    // Auto-fit columns
    for (var i = 0; i < _headers.length; i++) {
      sheet.setColumnWidth(i, 15);
    }

    final fileName = 'service_data_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final filePath = await _getOutputFile(fileName);
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);
    
    return file.path;
  }

  static Future<String> exportToPdf({
    required List<BankEntry>banks,
    required List<Machine> machines,
    required ExportFilter filter,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final List<pw.Widget> widgets = [];

          // Add title
          widgets.add(
            pw.Header(
              level: 0,
              child: pw.Text('Service Engineer Report'),
            ),
          );

          // Add date
          widgets.add(
            pw.Paragraph(
              text: 'Generated on: ${DateTime.now().toString()}',
            ),
          );

          // Add data tables
          for (final bank in banks) {
            final bankMachines = machines
                .where((m) => m.bankId == bank.id)
                .where((m) => _shouldInclude(m, filter))
                .toList();

            if (bankMachines.isEmpty) continue;

            widgets.add(
              pw.Header(
                level: 1,
                child: pw.Text('${bank.bankName} - ${bank.branchName}'),
              ),
            );

            widgets.add(
              pw.Table.fromTextArray(
                headers: _headers.sublist(2), // Skip bank name and branch as they're in the header
                data: bankMachines.map((m) => [
                  m.machineType,
                  m.serialNumber,
                  dateFmt.format(m.installationDate),
                  dateFmt.format(m.lastVisitDate),
                  dateFmt.format(m.nextVisitDate),
                  m.isCsrCollected ? 'Collected' : 'Pending',
                ]).toList(),
              ),
            );

            widgets.add(pw.SizedBox(height: 20));
          }

          return widgets;
        },
      ),
    );

    final fileName = 'service_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = await _getOutputFile(fileName);
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }

  static bool _shouldInclude(Machine machine, ExportFilter filter) {
    return switch (filter) {
      ExportFilter.all => true,
      ExportFilter.csrCollected => machine.isCsrCollected,
      ExportFilter.csrPending => !machine.isCsrCollected,
      ExportFilter.upcomingVisits => 
        machine.nextVisitDate.difference(DateTime.now()).inDays <= 30,
    };
  }
}

enum ExportFilter {
  all,
  csrCollected,
  csrPending,
  upcomingVisits,
}