import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/screens/article_detail_screen.dart';

/// L'icona di condivisione c'era gia', ma non condivideva niente.
void main() {
  const article = {
    'title': 'Proteine dopo l allenamento',
    'content': 'Il momento in cui le assumi conta meno di quanto si creda.',
  };

  group('testo condiviso', () {
    test('porta titolo e contenuto', () {
      final text = articleShareText(article);

      expect(text, contains('Proteine dopo l allenamento'));
      expect(text, contains('meno di quanto si creda'));
    });

    test('cita la provenienza', () {
      expect(articleShareText(article), contains('GymCorpus'));
    });

    test('un articolo senza contenuto non produce un testo vuoto', () {
      final text = articleShareText(const {'title': 'Solo titolo'});

      expect(text.trim(), isNotEmpty);
      expect(text, contains('Solo titolo'));
    });

    test('un contenuto lunghissimo viene accorciato', () {
      // Alcune app rifiutano testi molto lunghi, e comunque si condivide un
      // assaggio, non l'articolo intero.
      final text = articleShareText({
        'title': 'Titolo',
        'content': 'parola ' * 400,
      });

      expect(text.length, lessThan(600));
      expect(text, contains('...'));
    });
  });

  testWidgets('il pulsante di condivisione non e piu inerte', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ArticleDetailScreen(data: article)),
    );

    final button = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.share_outlined),
    );

    expect(button.onPressed, isNotNull);
  });
}
