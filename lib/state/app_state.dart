import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car.dart';
import '../models/fuel_entry.dart';
import '../models/fuel_station.dart';
import '../models/service_record.dart';

class AppState extends ChangeNotifier {
  static const _kCars = 'ecotrax_cars_v2';
  static const _kEntries = 'ecotrax_entries_v2';
  static const _kServices = 'ecotrax_services_v2';
  static const _kActiveCar = 'ecotrax_active_car_v2';

  List<Car> cars = [];
  List<FuelEntry> entries = [];
  List<ServiceRecord> services = [];
  String? activeCarId;
  bool isLoading = true;

  // ---------- Getters ----------

  Car? get activeCar =>
      cars.where((c) => c.id == activeCarId).cast<Car?>().firstOrNull;

  List<FuelEntry> get activeEntries =>
      entries.where((e) => e.carId == activeCarId).toList();

  List<FuelEntry> get activeRealEntries =>
      activeEntries.where((e) => !e.isSkipped).toList();

  List<ServiceRecord> get activeServices =>
      services.where((s) => s.carId == activeCarId).toList();

  List<FuelEntry> get recentEntries {
    final list = [...activeEntries];
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double get lastTripMeter {
    final list = activeEntries;
    return list.isEmpty ? 0 : list.last.tripMeter;
  }

  // ---------- Loading / saving ----------

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final carsJson = prefs.getString(_kCars);
    if (carsJson != null) {
      cars = (jsonDecode(carsJson) as List).map((j) => Car.fromJson(j)).toList();
    }

    final entriesJson = prefs.getString(_kEntries);
    if (entriesJson != null) {
      entries = (jsonDecode(entriesJson) as List)
          .map((j) => FuelEntry.fromJson(j))
          .toList();
    }

    final servicesJson = prefs.getString(_kServices);
    if (servicesJson != null) {
      services = (jsonDecode(servicesJson) as List)
          .map((j) => ServiceRecord.fromJson(j))
          .toList();
    }

    activeCarId = prefs.getString(_kActiveCar);
    if (activeCarId == null && cars.isNotEmpty) {
      activeCarId = cars.first.id;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kCars, jsonEncode(cars.map((c) => c.toJson()).toList()));
    await prefs.setString(
        _kEntries, jsonEncode(entries.map((e) => e.toJson()).toList()));
    await prefs.setString(
        _kServices, jsonEncode(services.map((s) => s.toJson()).toList()));
    if (activeCarId != null) {
      await prefs.setString(_kActiveCar, activeCarId!);
    }
  }

  // ---------- Car management ----------

  Future<void> addCar(
      String name,
      String model, {
        FuelType fuelType = FuelType.petrol,
        double tankSize = 0,
        bool makeActive = true,
      }) async {
    final car = Car(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      model: model,
      fuelType: fuelType,
      tankSize: tankSize,
      createdAt: DateTime.now(),
    );
    cars.add(car);
    if (makeActive || activeCarId == null) {
      activeCarId = car.id;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> updateCar(String carId, Car updated) async {
    final idx = cars.indexWhere((c) => c.id == carId);
    if (idx == -1) return;
    cars[idx] = updated;
    await _persist();
    notifyListeners();
  }

  Future<void> deleteCar(String carId) async {
    cars.removeWhere((c) => c.id == carId);
    entries.removeWhere((e) => e.carId == carId);
    services.removeWhere((s) => s.carId == carId);

    if (activeCarId == carId) {
      activeCarId = cars.isEmpty ? null : cars.first.id;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setActiveCar(String carId) async {
    activeCarId = carId;
    await _persist();
    notifyListeners();
  }

  // ---------- Refill ----------

  Future<void> addRefill({
    required double tripMeter,
    required double litres,
    required double density,
    required double pricePerLitre,
    required FuelStation station,
    required TripType tripType,
    required String notes,
  }) async {
    if (activeCarId == null) return;

    final entry = FuelEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      carId: activeCarId!,
      tripMeter: tripMeter,
      litres: litres,
      density: density,
      pricePerLitre: pricePerLitre,
      station: station,
      tripType: tripType,
      notes: notes,
      date: DateTime.now(),
    );

    // distance = tripMeter - previous entry's tripMeter (skipped entries
    // still count as anchors so we don't lose distance)
    if (activeEntries.isNotEmpty) {
      entry.distance = entry.tripMeter - activeEntries.last.tripMeter;
    }

    entries.add(entry);
    await _persist();
    notifyListeners();
  }

  /// "I forgot to log last refill" — inserts a marker entry with
  /// isSkipped=true. It anchors the trip meter for the next refill,
  /// but is excluded from all economy analytics.
  Future<void> skipLastRefill({required double tripMeter}) async {
    if (activeCarId == null) return;

    final entry = FuelEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      carId: activeCarId!,
      tripMeter: tripMeter,
      litres: 0,
      density: 0,
      pricePerLitre: 0,
      station: FuelStation.indianOil,
      tripType: TripType.mixed,
      notes: 'Forgot to log',
      date: DateTime.now(),
      isSkipped: true,
    );

    if (activeEntries.isNotEmpty) {
      entry.distance = entry.tripMeter - activeEntries.last.tripMeter;
    }

    entries.add(entry);
    await _persist();
    notifyListeners();
  }

  Future<void> updateRefill(FuelEntry updated) async {
    final idx = entries.indexWhere((e) => e.id == updated.id);
    if (idx == -1) return;
    entries[idx] = updated;
    _recomputeDistances(updated.carId);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteRefill(String id) async {
    final entry = entries.where((e) => e.id == id).firstOrNull;
    if (entry == null) return;
    entries.removeWhere((e) => e.id == id);
    _recomputeDistances(entry.carId);
    await _persist();
    notifyListeners();
  }

  /// After edit/delete, recompute `distance` for all entries of the car
  /// so the economy numbers stay consistent.
  void _recomputeDistances(String carId) {
    final carEntries = entries.where((e) => e.carId == carId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    for (int i = 0; i < carEntries.length; i++) {
      if (i == 0) {
        carEntries[i].distance = 0;
      } else {
        carEntries[i].distance =
            carEntries[i].tripMeter - carEntries[i - 1].tripMeter;
      }
    }
  }

  // ---------- Service records ----------

  Future<void> addService({
    required String serviceType,
    required String notes,
    required double odometerKm,
    required double cost,
    required DateTime date,
    String? billPhotoPath,
  }) async {
    if (activeCarId == null) return;
    final record = ServiceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      carId: activeCarId!,
      serviceType: serviceType,
      notes: notes,
      odometerKm: odometerKm,
      cost: cost,
      date: date,
      billPhotoPath: billPhotoPath,
    );
    services.add(record);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteService(String id) async {
    services.removeWhere((s) => s.id == id);
    await _persist();
    notifyListeners();
  }

  // ---------- Analytics ----------

  /// Average km/L across all *real* entries (skipped excluded).
  double get overallAverage {
    final list = _validEconomies(activeRealEntries);
    if (list.isEmpty) return 0;
    return list.reduce((a, b) => a + b) / list.length;
  }

  /// Most recent real entry's km/L.
  double get lastEconomy {
    final list = _validEconomies(activeRealEntries);
    return list.isEmpty ? 0 : list.last;
  }

  /// Best density (kg/L) with its average economy and entry count.
  ({double density, double avg, int count})? get bestDensity {
    final map = <double, List<double>>{};
    for (final e in activeRealEntries) {
      if (e.distance <= 0 || e.litres <= 0) continue;
      map.putIfAbsent(e.density, () => []).add(e.economy);
    }
    if (map.isEmpty) return null;
    double bestD = 0, bestAvg = -1;
    int bestN = 0;
    map.forEach((d, list) {
      final avg = list.reduce((a, b) => a + b) / list.length;
      if (avg > bestAvg) {
        bestAvg = avg;
        bestD = d;
        bestN = list.length;
      }
    });
    return (density: bestD, avg: bestAvg, count: bestN);
  }

  /// Best fuel station by average economy.
  ({FuelStation station, double avg, int count})? get bestStation {
    final map = <FuelStation, List<double>>{};
    for (final e in activeRealEntries) {
      if (e.distance <= 0 || e.litres <= 0) continue;
      map.putIfAbsent(e.station, () => []).add(e.economy);
    }
    if (map.isEmpty) return null;
    FuelStation best = FuelStation.indianOil;
    double bestAvg = -1;
    int bestN = 0;
    map.forEach((s, list) {
      final avg = list.reduce((a, b) => a + b) / list.length;
      if (avg > bestAvg) {
        bestAvg = avg;
        best = s;
        bestN = list.length;
      }
    });
    return (station: best, avg: bestAvg, count: bestN);
  }

  /// Best trip type by average economy.
  ({TripType tripType, double avg, int count})? get bestTripType {
    final map = <TripType, List<double>>{};
    for (final e in activeRealEntries) {
      if (e.distance <= 0 || e.litres <= 0) continue;
      map.putIfAbsent(e.tripType, () => []).add(e.economy);
    }
    if (map.isEmpty) return null;
    TripType best = TripType.mixed;
    double bestAvg = -1;
    int bestN = 0;
    map.forEach((t, list) {
      final avg = list.reduce((a, b) => a + b) / list.length;
      if (avg > bestAvg) {
        bestAvg = avg;
        best = t;
        bestN = list.length;
      }
    });
    return (tripType: best, avg: bestAvg, count: bestN);
  }

  /// Average ₹/km across all real entries.
  double get costPerKm {
    final totalCost = activeRealEntries.fold<double>(0, (s, e) => s + e.cost);
    final totalDist = activeRealEntries.fold<double>(0, (s, e) => s + e.distance);
    if (totalDist <= 0) return 0;
    return totalCost / totalDist;
  }

  /// Total ₹ spent on fuel (all-time for active car).
  double get totalFuelSpend =>
      activeRealEntries.fold<double>(0, (s, e) => s + e.cost);

  /// Total ₹ spent on services (all-time for active car).
  double get totalServiceSpend =>
      activeServices.fold<double>(0, (s, e) => s + e.cost);

  /// Last 3 vs previous 3 economies → trend (-1 down, 0 stable, 1 up).
  int get economyTrend {
    final list = _validEconomies(activeRealEntries);
    if (list.length < 6) return 0;
    final recent = list.sublist(list.length - 3);
    final previous = list.sublist(list.length - 6, list.length - 3);
    final rAvg = recent.reduce((a, b) => a + b) / 3;
    final pAvg = previous.reduce((a, b) => a + b) / 3;
    if (pAvg == 0) return 0;
    final change = (rAvg - pAvg) / pAvg;
    if (change > 0.05) return 1;
    if (change < -0.05) return -1;
    return 0;
  }

  /// Monthly summary for a given year/month.
  ({
  double avgEconomy,
  double totalDistance,
  double totalLitres,
  double totalCost,
  int entries,
  }) summaryForMonth(int year, int month) {
    final list = activeRealEntries.where((e) =>
    e.date.year == year && e.date.month == month).toList();
    if (list.isEmpty) {
      return (
      avgEconomy: 0,
      totalDistance: 0,
      totalLitres: 0,
      totalCost: 0,
      entries: 0,
      );
    }
    final valid = _validEconomies(list);
    final avg = valid.isEmpty
        ? 0.0
        : valid.reduce((a, b) => a + b) / valid.length;
    return (
    avgEconomy: avg,
    totalDistance: list.fold<double>(0, (s, e) => s + e.distance),
    totalLitres: list.fold<double>(0, (s, e) => s + e.litres),
    totalCost: list.fold<double>(0, (s, e) => s + e.cost),
    entries: list.length,
    );
  }

  /// All economies in chronological order for charting.
  List<({DateTime date, double economy})> get economySeries {
    final list = activeRealEntries
        .where((e) => e.distance > 0 && e.litres > 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list.map((e) => (date: e.date, economy: e.economy)).toList();
  }

  /// Average economy per station.
  Map<FuelStation, double> get stationAverages {
    final map = <FuelStation, List<double>>{};
    for (final e in activeRealEntries) {
      if (e.distance <= 0 || e.litres <= 0) continue;
      map.putIfAbsent(e.station, () => []).add(e.economy);
    }
    return map.map((k, v) =>
        MapEntry(k, v.reduce((a, b) => a + b) / v.length));
  }

  List<double> _validEconomies(List<FuelEntry> list) {
    return list
        .where((e) => !e.isSkipped && e.distance > 0 && e.litres > 0)
        .map((e) => e.economy)
        .toList();
  }
}