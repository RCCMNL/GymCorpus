import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/utils/date_format.dart';

void main() {
  // Lunedi' 4 maggio 2026, le sei e mezza di sera.
  final date = DateTime(2026, 5, 4, 18, 30);

  test('la data per esteso', () {
    expect(formatFullDate(date), '4 maggio 2026');
  });

  test('la data breve con l ora', () {
    expect(formatDateTimeShort(date), '04 mag 2026, 18:30');
  });

  test('la data breve', () {
    expect(formatShortDate(date), '04 mag 2026');
  });

  test('giorno e mese, quando l anno si capisce da solo', () {
    expect(formatDayMonth(date), '4 maggio');
  });

  test('il mese di un calendario', () {
    expect(formatMonthYear(date), 'maggio 2026');
  });

  test('il giorno della settimana', () {
    expect(formatWeekday(date), 'lunedì');
  });

  test('il giorno della settimana con la data breve', () {
    expect(formatWeekdayShortDate(date), 'lunedì 4 mag');
  });

  test('la data di un campo da compilare', () {
    expect(formatDateInput(date), '04/05/2026');
  });

  test('solo l ora', () {
    expect(formatTime(date), '18:30');
  });

  test('la data e l ora per esteso', () {
    expect(formatDateAtTime(date), '4 maggio 2026 alle 18:30');
  });

  test('le date sono in italiano, non in inglese', () {
    expect(formatFullDate(DateTime(2026, 8, 9)), '9 agosto 2026');
    expect(formatWeekday(DateTime(2026, 8, 9)), 'domenica');
  });
}
