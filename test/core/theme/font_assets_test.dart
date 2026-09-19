import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';

/// Il tema usa Lexend e Inter in tutta l'app, ma per molto tempo non
/// erano dichiarati in pubspec.yaml: Flutter, in quel caso, non segnala
/// nulla e ripiega sul font di sistema. La tipografia progettata non si
/// e' mai vista, e nessun test se ne era accorto.
///
/// I casi coperti qui sono quelli che il compilatore non intercetta:
/// una famiglia usata dal tema ma non dichiarata (il bug originale, che
/// degrada in silenzio), un peso mancante, una licenza non distribuita,
/// o un file che esiste ma non e' un font valido (uno scaricamento
/// finito male passerebbe la build e renderebbe testo vuoto).
///
/// Un asset dichiarato ma assente dal disco, invece, fa gia' fallire la
/// build con "unable to locate asset entry": li' non serve un test.
void main() {
  late String pubspec;

  setUpAll(() {
    pubspec = File('pubspec.yaml').readAsStringSync();
  });

  /// Percorsi degli asset font dichiarati in pubspec.yaml.
  List<String> declaredFontAssets() {
    return RegExp(
      r'-\s*asset:\s*(assets/fonts/\S+\.ttf)',
    ).allMatches(pubspec).map((m) => m.group(1)!).toList();
  }

  test('il tema dichiara le famiglie che usa', () {
    for (final family in ['Lexend', 'Inter']) {
      expect(
        pubspec,
        contains('family: $family'),
        reason:
            "$family e' usato dal tema ma non dichiarato in pubspec.yaml: "
            'Flutter ripiegherebbe sul font di sistema senza avvisare',
      );
    }
  });

  test('ogni font dichiarato esiste ed e un TTF valido', () {
    final assets = declaredFontAssets();
    expect(assets, isNotEmpty, reason: 'nessun font dichiarato in pubspec');

    for (final asset in assets) {
      final file = File(asset);
      expect(file.existsSync(), isTrue, reason: '$asset non esiste');

      // Un file scaricato male (pagina di errore HTML) passerebbe il
      // controllo di esistenza ma non sarebbe un font: qui si guarda la
      // firma del formato.
      final header = file.readAsBytesSync().take(4).toList();
      expect(
        header,
        anyOf([
          equals([0x00, 0x01, 0x00, 0x00]), // TrueType
          equals([0x74, 0x72, 0x75, 0x65]), // 'true'
        ]),
        reason: '$asset non ha una firma TTF valida',
      );
    }
  });

  test('sono dichiarati i pesi che il codice usa davvero', () {
    // Il tema arriva fino a w900 (i titoli): se quel peso non fosse
    // impacchettato, Flutter userebbe il piu' vicino e i titoli
    // perderebbero forza senza che nulla lo segnali.
    for (final weight in [400, 500, 600, 700, 800, 900]) {
      expect(
        pubspec,
        contains('weight: $weight'),
        reason: 'peso $weight non dichiarato per nessuna famiglia',
      );
    }
  });

  test('le licenze OFL dei font sono distribuite insieme ai font', () {
    // I font sono sotto Open Font License, che obbliga a distribuire il
    // testo della licenza.
    for (final font in ['Lexend', 'Inter']) {
      final license = File('assets/fonts/$font-OFL.txt');
      expect(license.existsSync(), isTrue, reason: 'licenza $font mancante');
      expect(license.readAsStringSync(), contains('SIL OPEN FONT LICENSE'));
      expect(
        pubspec,
        contains('assets/fonts/$font-OFL.txt'),
        reason: "la licenza $font non e' impacchettata nell'app",
      );
    }
  });

  test('il tema applica le famiglie ai testi principali', () {
    final theme = AppTheme.darkTheme;

    expect(theme.textTheme.headlineLarge?.fontFamily, 'Lexend');
    expect(theme.textTheme.titleLarge?.fontFamily, 'Lexend');
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(theme.appBarTheme.titleTextStyle?.fontFamily, 'Lexend');
  });

  test('nessuno stile della scala resta senza font della casa', () {
    // Uno stile non definito nel tema non da' errore: Flutter lo riempie
    // con la tipografia di Material, cioe' il font di sistema. Meta' del
    // testo dell'app usava stili lasciati vuoti - bodySmall, titleMedium,
    // headlineSmall - e finiva in Roboto senza che si vedesse.
    final text = AppTheme.darkTheme.textTheme;
    final scale = <String, TextStyle?>{
      'displayLarge': text.displayLarge,
      'displayMedium': text.displayMedium,
      'displaySmall': text.displaySmall,
      'headlineLarge': text.headlineLarge,
      'headlineMedium': text.headlineMedium,
      'headlineSmall': text.headlineSmall,
      'titleLarge': text.titleLarge,
      'titleMedium': text.titleMedium,
      'titleSmall': text.titleSmall,
      'bodyLarge': text.bodyLarge,
      'bodyMedium': text.bodyMedium,
      'bodySmall': text.bodySmall,
      'labelLarge': text.labelLarge,
      'labelMedium': text.labelMedium,
      'labelSmall': text.labelSmall,
    };

    for (final style in scale.entries) {
      expect(
        style.value?.fontFamily,
        anyOf('Lexend', 'Inter'),
        reason:
            '${style.key} non ha un font: chi lo usa scrive nel font di '
            'sistema, e non se ne accorge nessuno',
      );
    }
  });
}
