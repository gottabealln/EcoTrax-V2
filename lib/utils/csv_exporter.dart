import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/car.dart';
import '../models/fuel_entry.dart';

class CsvExporter {
  /// Exports all fuel entries for [car] to a CSV file and shares it.
  /// Returns the file path (or null if it failed).
  static Future<String?> exportFuelEntries(
      Car car,
      List<FuelEntry> entries,
      ) async {
    if (entries.isEmpty) return null;

    // Sort chronologically
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));

    final rows = <List<dynamic>>[
      [
        'Date',
        'Trip Meter (km)',
        'Distance (km)',
        'Litres',
        'Price (Rs/L)',
        'Cost (Rs)',
        'Density (kg/L)',
        'Station',
        'Trip Type',
        'Economy (km/L)',
        'Cost per km (Rs)',
        'Notes',
        'Skipped',
      ],
    ];

    for (final e in sorted) {
      rows.add([
        DateFormat('yyyy-MM-dd HH:mm').format(e.date),
        e.tripMeter,
        e.distance,
        e.litres,
        e.pricePerLitre,
        e.cost,
        e.density,
        e.station.label,
        e.tripType.label,
        e.isSkipped ? '' : e.economy.toStringAsFixed(3),
        e.isSkipped ? '' : e.costPerKm.toStringAsFixed(3),
        e.notes,
        e.isSkipped ? 'YES' : '',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);

    final dir = await getApplicationDocumentsDirectory();
    final safeCarName =
    car.name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final file = File('${dir.path}/EcoTrax_${safeCarName}_$timestamp.csv');
    await file.writeAsString(csvString);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'EcoTrax export — ${car.name}',
    );

    return file.path;
  }
}