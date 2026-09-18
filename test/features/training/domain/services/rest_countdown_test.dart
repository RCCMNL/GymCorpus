import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/services/rest_countdown.dart';

/// Il recupero fra una serie e l'altra continua mentre l'app e' in
/// background, ma deve fermarsi quando l'utente mette in pausa: e' la
/// distinzione che la schermata sbagliava.
void main() {
  late DateTime now;
  late RestCountdown rest;

  void advance(int seconds) => now = now.add(Duration(seconds: seconds));

  setUp(() {
    now = DateTime(2026, 9, 18, 10);
    rest = RestCountdown(now: () => now);
  });

  test('appena avviato ha davanti tutti i secondi', () {
    rest.start(90);

    expect(rest.remaining, 90);
    expect(rest.isRunning, isTrue);
    expect(rest.isOver, isFalse);
  });

  test('ricorda da quanti secondi e partito', () {
    // La barra di avanzamento si misura su questo, non su un campo tenuto
    // aggiornato dentro build.
    rest
      ..start(90)
      ..tick()
      ..tick();

    expect(rest.total, 90);
    expect(rest.remaining, 88);
  });

  test('ogni tick toglie un secondo', () {
    rest
      ..start(90)
      ..tick()
      ..tick();

    expect(rest.remaining, 88);
  });

  test('in background il tempo passa lo stesso', () {
    rest.start(90);

    advance(60);
    rest.onForeground();

    expect(rest.remaining, 30);
  });

  test('un recupero scaduto in background risulta finito', () {
    rest.start(90);

    advance(120);
    rest.onForeground();

    expect(rest.remaining, 0);
    expect(rest.isOver, isTrue);
  });

  test('in pausa il tempo non passa', () {
    rest
      ..start(90)
      ..pause();

    advance(300);
    rest.onForeground();

    expect(rest.remaining, 90);
    expect(rest.isRunning, isFalse);
  });

  test('riprendendo si riparte da dove ci si era fermati', () {
    rest
      ..start(90)
      ..tick()
      ..tick()
      ..pause();
    advance(300);

    rest.resume();
    advance(10);
    rest.onForeground();

    expect(rest.remaining, 78);
  });

  test('fermato non ha piu' ' nulla da scontare', () {
    rest
      ..start(90)
      ..stop();

    expect(rest.isRunning, isFalse);
    expect(rest.remaining, 0);
  });

  test('i tick di troppo non portano il recupero sotto zero', () {
    rest
      ..start(2)
      ..tick()
      ..tick()
      ..tick();

    expect(rest.remaining, 0);
  });
}
