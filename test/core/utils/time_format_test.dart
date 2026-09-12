import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/utils/time_format.dart';

void main() {
  group('formatPace', () {
    test('un passo tondo si scrive minuti e secondi', () {
      expect(formatPace(seconds: 1800, distanceKm: 5), '06:00');
    });

    test('i secondi non arrivano mai a 60', () {
      // 3599 s su 10 km fanno 359.9 s al chilometro: diviso prima e
      // arrotondato dopo diventava l'impossibile "05:60".
      expect(formatPace(seconds: 3599, distanceKm: 10), '06:00');
      expect(formatPace(seconds: 1799, distanceKm: 5), '06:00');
    });

    test('i minuti sono sempre due cifre', () {
      expect(formatPace(seconds: 540, distanceKm: 2), '04:30');
    });

    test('un tratto parziale viene riportato al chilometro pieno', () {
      expect(formatPace(seconds: 150, distanceKm: 0.5), '05:00');
    });

    test('senza distanza il passo non esiste', () {
      expect(formatPace(seconds: 1800, distanceKm: 0), '--:--');
      expect(formatPace(seconds: 1800, distanceKm: -1), '--:--');
    });

    test('oltre l ora il passo continua a contare in minuti', () {
      expect(formatPace(seconds: 7200, distanceKm: 1), '120:00');
    });
  });

  group('formatClock', () {
    test('sotto l ora restano minuti e secondi', () {
      expect(formatClock(0), '00:00');
      expect(formatClock(45), '00:45');
      expect(formatClock(2712), '45:12');
    });

    test('oltre l ora compaiono le ore', () {
      expect(formatClock(3661), '01:01:01');
      expect(formatClock(3600), '01:00:00');
    });

    test('il cronometro dell allenamento mostra sempre le ore', () {
      expect(formatClock(2712, alwaysHours: true), '00:45:12');
      expect(formatClock(0, alwaysHours: true), '00:00:00');
    });
  });

  group('formatCompactDuration', () {
    test('sotto il minuto si contano i secondi', () {
      expect(formatCompactDuration(45), '45s');
      expect(formatCompactDuration(0), '0s');
    });

    test('sopra il minuto i secondi non interessano piu', () {
      expect(formatCompactDuration(2712), '45m');
      expect(formatCompactDuration(60), '1m');
    });

    test('oltre l ora si leggono ore e minuti', () {
      expect(formatCompactDuration(4500), '1h 15m');
    });

    test('un ora tonda non si porta dietro uno zero', () {
      expect(formatCompactDuration(7200), '2h');
    });
  });
}
