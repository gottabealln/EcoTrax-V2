enum FuelType { petrol, diesel, cng, ev }

extension FuelTypeLabel on FuelType {
  String get label {
    switch (this) {
      case FuelType.petrol:
        return 'Petrol';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.cng:
        return 'CNG';
      case FuelType.ev:
        return 'EV';
    }
  }
}

class Car {
  final String id;
  final String name;      // e.g., "Swift"
  final String model;     // e.g., "VXi 2019"
  final FuelType fuelType;
  final double tankSize;  // litres; 0 = unknown
  final DateTime createdAt;

  Car({
    required this.id,
    required this.name,
    required this.model,
    required this.fuelType,
    required this.tankSize,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'model': model,
    'fuelType': fuelType.name,
    'tankSize': tankSize,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Car.fromJson(Map<String, dynamic> json) => Car(
    id: json['id'],
    name: json['name'],
    model: json['model'],
    fuelType: FuelType.values.firstWhere(
          (f) => f.name == json['fuelType'],
      orElse: () => FuelType.petrol,
    ),
    tankSize: ((json['tankSize'] ?? 0) as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt']),
  );
}