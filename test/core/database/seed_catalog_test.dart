import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/database/seed_data.dart';

/// Il catalogo seed e' l'unica fonte dei testi degli esercizi predefiniti:
/// a ogni apertura il database viene riallineato a questi valori, ritrovando
/// le righe per nome e muscolo. Due voci con la stessa coppia si
/// sovrascriverebbero a vicenda.
void main() {
  final catalogo = getSeedExercises();

  test('ogni esercizio del catalogo e identificato da nome e muscolo', () {
    final conteggi = <String, int>{};
    for (final esercizio in catalogo) {
      final chiave =
          '${esercizio.name.value} | ${esercizio.targetMuscle.value}';
      conteggi[chiave] = (conteggi[chiave] ?? 0) + 1;
    }

    final doppioni = [
      for (final voce in conteggi.entries)
        if (voce.value > 1) voce.key,
    ];

    expect(doppioni, isEmpty);
  });

  test('le parentesi nei nomi degli esercizi sono chiuse', () {
    final storti = [
      for (final esercizio in catalogo)
        if ('('.allMatches(esercizio.name.value).length !=
            ')'.allMatches(esercizio.name.value).length)
          esercizio.name.value,
    ];

    expect(storti, isEmpty);
  });
}
