import 'dart:async';

import 'package:intl/date_symbol_data_local.dart';

/// Setup globale eseguito prima di ogni test file in questo progetto.
///
/// L'app inizializza i dati locale 'it_IT' implicitamente tramite i
/// localizationsDelegates di MaterialApp in lib/main.dart. I widget test
/// isolati non passano per quel percorso, quindi qualunque widget che
/// costruisce un DateFormat(..., 'it_IT') (es. storico peso, cronologia
/// cardio) lancerebbe LocaleDataException senza questa inizializzazione
/// esplicita.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await initializeDateFormatting('it_IT');
  await testMain();
}
