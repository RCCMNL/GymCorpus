import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/utils/pending_alarm.dart';

/// Un avviso programmato che non si puo' annullare e' un avviso che
/// arrivera' nel momento sbagliato: qui si verifica che ne resti sempre
/// al massimo uno, e che annullarlo funzioni davvero.
void main() {
  late PendingAlarm alarm;

  setUp(() => alarm = PendingAlarm());
  tearDown(() => alarm.cancel());

  test('scatta quando scade il tempo', () async {
    var fired = 0;

    alarm.schedule(const Duration(milliseconds: 20), () => fired++);
    await Future<void>.delayed(const Duration(milliseconds: 120));

    expect(fired, 1);
  });

  test('riprogrammarlo non lascia in giro quello di prima', () async {
    var fired = 0;

    alarm.schedule(const Duration(milliseconds: 20), () => fired++);
    alarm.schedule(const Duration(milliseconds: 40), () => fired++);
    await Future<void>.delayed(const Duration(milliseconds: 160));

    expect(fired, 1, reason: 'il primo avviso non deve sopravvivere');
  });

  test('annullato non scatta', () async {
    var fired = 0;

    alarm.schedule(const Duration(milliseconds: 20), () => fired++);
    alarm.cancel();
    await Future<void>.delayed(const Duration(milliseconds: 120));

    expect(fired, 0);
  });

  test('sa se c e' ' qualcosa in sospeso', () {
    expect(alarm.isPending, isFalse);

    alarm.schedule(const Duration(seconds: 10), () {});
    expect(alarm.isPending, isTrue);

    alarm.cancel();
    expect(alarm.isPending, isFalse);
  });
}
