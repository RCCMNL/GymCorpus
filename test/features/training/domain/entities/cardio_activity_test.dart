import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';

/// Il tipo di attivita' e' salvato come stringa nel database: qui si fissa
/// la corrispondenza con i valori gia' registrati e il comportamento delle
/// attivita' al chiuso, che non hanno GPS.
void main() {
  group('lettura dal database', () {
    test('riconosce i tipi gia salvati', () {
      expect(CardioActivity.fromId('run'), CardioActivity.run);
      expect(CardioActivity.fromId('walk'), CardioActivity.walk);
    });

    test('un tipo sconosciuto ricade sulla corsa invece di far crashare', () {
      // Puo' arrivare da una versione futura o da un dato corrotto.
      expect(CardioActivity.fromId('teletrasporto'), CardioActivity.run);
      expect(CardioActivity.fromId(''), CardioActivity.run);
    });
  });

  group('attivita al chiuso', () {
    test('corsa, camminata e bici seguono il percorso', () {
      expect(CardioActivity.run.tracksLocation, isTrue);
      expect(CardioActivity.walk.tracksLocation, isTrue);
      expect(CardioActivity.bike.tracksLocation, isTrue);
    });

    test('le attivita al chiuso non seguono il percorso', () {
      expect(CardioActivity.treadmill.tracksLocation, isFalse);
      expect(CardioActivity.elliptical.tracksLocation, isFalse);
      expect(CardioActivity.rowing.tracksLocation, isFalse);
    });

    test('sull ellittica la distanza non si misura', () {
      expect(CardioActivity.elliptical.tracksDistance, isFalse);
      expect(CardioActivity.treadmill.tracksDistance, isTrue);
      expect(CardioActivity.rowing.tracksDistance, isTrue);
    });
  });

  group('consumo stimato', () {
    test('camminare piano costa meno che camminare forte', () {
      final slow = CardioActivity.walk.metAt(3);
      final fast = CardioActivity.walk.metAt(6.5);

      expect(slow, lessThan(fast));
    });

    test('correre veloce costa piu che correre piano', () {
      expect(
        CardioActivity.run.metAt(9),
        lessThan(CardioActivity.run.metAt(13)),
      );
    });

    test('una velocita assurda non manda la stima fuori scala', () {
      // Un rimbalzo GPS puo' produrre numeri impossibili: la stima deve
      // restare in un intervallo umano invece di moltiplicarsi.
      expect(CardioActivity.run.metAt(400), lessThanOrEqualTo(20));
      expect(CardioActivity.walk.metAt(-5), greaterThan(0));
    });

    test('le calorie tengono conto di peso e durata', () {
      // Un'ora a MET 9.8 per 70 kg sono circa 686 kcal.
      final calories = CardioActivity.run.caloriesFor(
        speedKmh: 10,
        weightKg: 70,
        seconds: 3600,
      );

      expect(calories, closeTo(686, 20));
    });

    test('mezz ora costa la meta di un ora', () {
      final hour = CardioActivity.bike.caloriesFor(
        speedKmh: 20,
        weightKg: 70,
        seconds: 3600,
      );
      final half = CardioActivity.bike.caloriesFor(
        speedKmh: 20,
        weightKg: 70,
        seconds: 1800,
      );

      expect(half * 2, closeTo(hour, 1));
    });

    test('senza velocita nota resta la stima di base dell attivita', () {
      // Ellittica e vogatore non misurano la distanza: la velocita' non
      // esiste, ma le calorie devono comunque avere un valore sensato.
      expect(CardioActivity.elliptical.metAt(0), greaterThan(3));
      expect(CardioActivity.rowing.metAt(0), greaterThan(3));
    });
  });
}
