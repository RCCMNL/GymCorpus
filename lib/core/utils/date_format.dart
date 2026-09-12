import 'package:intl/intl.dart';

// Come l'app scrive le date.
//
// Ventidue punti costruivano un DateFormat sul posto, e ripetevano
// 'it_IT' diciassette volte: dimenticarlo non da' errore, da' una data in
// inglese. Qui i formati hanno un nome che dice a cosa servono, e il
// vocabolario di date dell'app si legge tutto insieme.

const _it = 'it_IT';

/// `4 maggio 2026`.
String formatFullDate(DateTime date) =>
    DateFormat('d MMMM yyyy', _it).format(date);

/// `04 mag 2026, 18:30`.
String formatDateTimeShort(DateTime date) =>
    DateFormat('dd MMM yyyy, HH:mm', _it).format(date);

/// `04 mag 2026`.
String formatShortDate(DateTime date) =>
    DateFormat('dd MMM yyyy', _it).format(date);

/// `4 maggio`, per quando l'anno si capisce dal contesto.
String formatDayMonth(DateTime date) => DateFormat('d MMMM', _it).format(date);

/// `maggio 2026`, l'intestazione di un calendario.
String formatMonthYear(DateTime date) =>
    DateFormat('MMMM yyyy', _it).format(date);

/// `lunedì`.
String formatWeekday(DateTime date) => DateFormat('EEEE', _it).format(date);

/// `lunedì 4 mag`.
String formatWeekdayShortDate(DateTime date) =>
    DateFormat('EEEE d MMM', _it).format(date);

/// `04/05/2026`, la data come si scrive in un campo da compilare.
String formatDateInput(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

/// `18:30`.
String formatTime(DateTime date) => DateFormat('HH:mm').format(date);

/// `4 maggio 2026 alle 18:30`.
String formatDateAtTime(DateTime date) =>
    DateFormat("d MMMM yyyy 'alle' HH:mm", _it).format(date);

/// `04 mag`, le etichette strette sotto un grafico.
String formatDayMonthShort(DateTime date) =>
    DateFormat('dd MMM', _it).format(date);
