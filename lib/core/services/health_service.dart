import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// Dati di attività aggregati per una singola giornata.
class DailyActivity {
  const DailyActivity({
    required this.date,
    required this.steps,
    required this.distanceMeters,
    required this.caloriesBurned,
    required this.activeMinutes,
  });

  final DateTime date;
  final int steps;
  final double distanceMeters;
  final double caloriesBurned;
  final int activeMinutes;

  double get distanceKm => distanceMeters / 1000;

  /// Formatta la distanza in una stringa leggibile.
  String get formattedDistance {
    final km = distanceKm;
    if (km < 1) return '${distanceMeters.round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  /// Formatta il tempo attivo in una stringa leggibile.
  String get formattedActiveTime {
    if (activeMinutes < 60) return '${activeMinutes}min';
    final h = activeMinutes ~/ 60;
    final m = activeMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h${m}m';
  }

  /// Formatta i passi con separatore delle migliaia.
  String get formattedSteps {
    if (steps < 1000) return steps.toString();
    final k = steps / 1000;
    if (steps < 10000) return '${k.toStringAsFixed(1)}k';
    return '${k.round()}k';
  }
}

/// Servizio per leggere i dati di salute da Google Fit / Apple Health.
///
/// Usa il plugin `health` per interfacciarsi con Health Connect (Android)
/// e HealthKit (iOS). Non scrive dati: legge solo passi, distanza,
/// calorie e minuti di attività.
class HealthService {
  HealthService() : _health = Health();

  final Health _health;
  bool _isAuthorized = false;

  /// Tipo usato per la distanza percorsa.
  ///
  /// Health Connect e HealthKit espongono la distanza con nomi diversi. Va
  /// letto da qui sia per l'autorizzazione sia per le query: chiedere il
  /// permesso per un tipo e poi interrogarne un altro restituisce sempre
  /// zero, senza alcun errore visibile.
  static HealthDataType get _distanceType => Platform.isAndroid
      ? HealthDataType.DISTANCE_DELTA
      : HealthDataType.DISTANCE_WALKING_RUNNING;

  /// Tipo usato per le calorie, anch'esso diverso tra le due piattaforme.
  static HealthDataType get _caloriesType => Platform.isAndroid
      ? HealthDataType.TOTAL_CALORIES_BURNED
      : HealthDataType.ACTIVE_ENERGY_BURNED;

  /// Tipi di dati che leggiamo.
  static final _readTypes = <HealthDataType>[
    HealthDataType.STEPS,
    _distanceType,
    _caloriesType,
    HealthDataType
        .WORKOUT, // Aggiunto per migliorare il riconoscimento attività
  ];

  /// Controlla se l'utente ha già concesso i permessi.
  bool get isAuthorized => _isAuthorized;

  /// Richiede i permessi all'utente. Restituisce `true` se concessi.
  Future<bool> requestPermissions() async {
    try {
      // Su Android, verifichiamo la disponibilità di Health Connect
      if (Platform.isAndroid) {
        final status = await _health.getHealthConnectSdkStatus();
        if (status != HealthConnectSdkStatus.sdkAvailable) {
          debugPrint(
            '[HealthService] Health Connect SDK non disponibile: $status',
          );
          // Non forziamo l'installazione qui, lo gestiremo nella UI con un messaggio
          return false;
        }
      }

      // Configura l'health plugin
      await _health.configure();

      final permissions = _readTypes.map((_) => HealthDataAccess.READ).toList();
      final granted = await _health.requestAuthorization(
        _readTypes,
        permissions: permissions,
      );

      _isAuthorized = granted;
      debugPrint('[HealthService] Permissions granted: $granted');
      return granted;
    } catch (e) {
      debugPrint('[HealthService] Permission request error: $e');
      _isAuthorized = false;
      return false;
    }
  }

  /// Verifica se i permessi sono già stati concessi (senza richiedere).
  Future<bool> checkPermissions() async {
    try {
      await _health.configure();

      final permissions = _readTypes.map((_) => HealthDataAccess.READ).toList();
      final hasPermissions = await _health.hasPermissions(
        _readTypes,
        permissions: permissions,
      );

      return _isAuthorized = hasPermissions ?? false;
    } catch (e) {
      debugPrint('[HealthService] Check permissions error: $e');
      // Anche lo stato in memoria va invalidato: lasciarlo a true dopo un
      // controllo fallito farebbe partire query destinate a restituire zero.
      _isAuthorized = false;
      return false;
    }
  }

  /// Ottiene l'attività per una data specifica.
  Future<DailyActivity> getDailyActivity(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    try {
      final steps = await _getAggregatedValue(HealthDataType.STEPS, start, end);
      final distance = await _getAggregatedValue(_distanceType, start, end);
      final calories = await _getAggregatedValue(_caloriesType, start, end);

      // Stima minuti attivi: ~100 passi/minuto di camminata media
      final activeMinutes = steps > 0
          ? (steps / 100).round().clamp(0, 1440)
          : 0;

      return DailyActivity(
        date: start,
        steps: steps.round(),
        distanceMeters: distance,
        caloriesBurned: calories,
        activeMinutes: activeMinutes,
      );
    } catch (e) {
      debugPrint('[HealthService] getDailyActivity error: $e');
      return DailyActivity(
        date: start,
        steps: 0,
        distanceMeters: 0,
        caloriesBurned: 0,
        activeMinutes: 0,
      );
    }
  }

  /// Ottiene i passi giornalieri per un range di giorni.
  /// Restituisce una lista ordinata dal giorno più vecchio al più recente.
  Future<List<DailyActivity>> getWeeklyActivity({int days = 7}) async {
    final now = DateTime.now();
    final activities = <DailyActivity>[];

    for (var i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final activity = await getDailyActivity(date);
      activities.add(activity);
    }

    return activities;
  }

  /// Ottiene i passi fatti dall'inizio di una sessione.
  /// Utile per il cardio tracker: chiama con lo startTime della sessione.
  Future<int> getStepsSince(DateTime startTime) async {
    try {
      final steps = await _getAggregatedValue(
        HealthDataType.STEPS,
        startTime,
        DateTime.now(),
      );
      return steps.round();
    } catch (e) {
      debugPrint('[HealthService] getStepsSince error: $e');
      return 0;
    }
  }

  /// Legge e somma i valori per un tipo di dato in un intervallo.
  Future<double> _getAggregatedValue(
    HealthDataType type,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final dataPoints = await _health.getHealthDataFromTypes(
        types: [type],
        startTime: start,
        endTime: end,
      );

      // Rimuovi duplicati (es. da più sorgenti)
      final cleanData = _health.removeDuplicates(dataPoints);

      var total = 0.0;
      for (final point in cleanData) {
        final value = point.value;
        if (value is NumericHealthValue) {
          total += value.numericValue.toDouble();
        }
      }

      return total;
    } catch (e) {
      debugPrint('[HealthService] _getAggregatedValue($type) error: $e');
      return 0;
    }
  }
}
