import 'fuel_station.dart';

enum TripType { city, highway, mixed }

extension TripTypeLabel on TripType {
  String get label {
    switch (this) {
      case TripType.city:
        return 'City';
      case TripType.highway:
        return 'Highway';
      case TripType.mixed:
        return 'Mixed';
    }
  }
}

class FuelEntry {
  final String id;
  final String carId;
  final double tripMeter;     // km reading at refuel
  final double litres;        // litres filled
  final double density;       // kg/L
  final double pricePerLitre; // ₹ per litre
  final FuelStation station;
  final TripType tripType;
  final String notes;
  final DateTime date;
  double distance;            // computed from previous entry
  final bool isSkipped;       // true = "I forgot to log" reset marker

  FuelEntry({
    required this.id,
    required this.carId,
    required this.tripMeter,
    required this.litres,
    required this.density,
    required this.pricePerLitre,
    required this.station,
    required this.tripType,
    required this.notes,
    required this.date,
    this.distance = 0,
    this.isSkipped = false,
  });

  /// True km/L (density-independent) for standard fuel-economy display.
  double get economy {
    if (isSkipped) return 0;
    if (distance <= 0 || litres <= 0) return 0;
    return distance / litres;
  }

  /// Density-adjusted economy (mass-based). Used internally if needed.
  double get densityAdjustedEconomy {
    if (isSkipped) return 0;
    if (distance <= 0 || litres <= 0) return 0;
    return (distance / litres) * density;
  }

  /// Cost of this refill in ₹.
  double get cost => litres * pricePerLitre;

  /// Cost per km for this refill in ₹/km.
  double get costPerKm {
    if (isSkipped) return 0;
    if (distance <= 0) return 0;
    return cost / distance;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'carId': carId,
    'tripMeter': tripMeter,
    'litres': litres,
    'density': density,
    'pricePerLitre': pricePerLitre,
    'station': station.name,
    'tripType': tripType.name,
    'notes': notes,
    'date': date.toIso8601String(),
    'distance': distance,
    'isSkipped': isSkipped,
  };

  factory FuelEntry.fromJson(Map<String, dynamic> json) => FuelEntry(
    id: json['id'],
    carId: json['carId'],
    tripMeter: (json['tripMeter'] as num).toDouble(),
    litres: (json['litres'] as num).toDouble(),
    density: (json['density'] as num).toDouble(),
    pricePerLitre: ((json['pricePerLitre'] ?? 0) as num).toDouble(),
    station: FuelStation.values.firstWhere(
          (s) => s.name == json['station'],
      orElse: () => FuelStation.indianOil,
    ),
    tripType: TripType.values.firstWhere(
          (t) => t.name == json['tripType'],
      orElse: () => TripType.mixed,
    ),
    notes: json['notes'] ?? '',
    date: DateTime.parse(json['date']),
    distance: ((json['distance'] ?? 0) as num).toDouble(),
    isSkipped: json['isSkipped'] ?? false,
  );
}