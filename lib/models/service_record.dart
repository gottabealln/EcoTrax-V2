class ServiceRecord {
  final String id;
  final String carId;
  final String serviceType;   // free text, e.g. "Oil Change"
  final String notes;
  final double odometerKm;
  final double cost;
  final DateTime date;
  final String? billPhotoPath; // local file path to bill image

  ServiceRecord({
    required this.id,
    required this.carId,
    required this.serviceType,
    required this.notes,
    required this.odometerKm,
    required this.cost,
    required this.date,
    this.billPhotoPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'carId': carId,
    'serviceType': serviceType,
    'notes': notes,
    'odometerKm': odometerKm,
    'cost': cost,
    'date': date.toIso8601String(),
    'billPhotoPath': billPhotoPath,
  };

  factory ServiceRecord.fromJson(Map<String, dynamic> json) => ServiceRecord(
    id: json['id'],
    carId: json['carId'],
    serviceType: json['serviceType'],
    notes: json['notes'] ?? '',
    odometerKm: ((json['odometerKm'] ?? 0) as num).toDouble(),
    cost: ((json['cost'] ?? 0) as num).toDouble(),
    date: DateTime.parse(json['date']),
    billPhotoPath: json['billPhotoPath'],
  );
}