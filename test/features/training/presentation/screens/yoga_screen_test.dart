import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:gym_corpus/features/training/presentation/screens/yoga_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_notifications_bloc.dart';
import '../../../../helpers/narrow_screen.dart';

/// La sezione yoga e' ancora una vetrina: non deve pero' promettere cose
/// che non esistono, ne' scaricare immagini da un servizio esterno.
void main() {
  late MockNotificationsBloc notificationsBloc;

  setUp(() {
    notificationsBloc = MockNotificationsBloc();
    when(() => notificationsBloc.state).thenReturn(const NotificationsState());
  });

  Widget wrap() => BlocProvider<NotificationsBloc>.value(
    value: notificationsBloc,
    child: const MaterialApp(home: YogaScreen()),
  );

  testWidgets('non promette una sessione che non parte', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Inizia Sessione'), findsNothing);
    expect(find.textContaining('non sono ancora disponibili'), findsOneWidget);
  });

  testWidgets('nessun pulsante resta inerte', (tester) async {
    // Un pulsante che non fa niente e' peggio di un pulsante assente:
    // sembra un difetto dell'app.
    await tester.pumpWidget(wrap());

    final buttons = tester.widgetList<ButtonStyleButton>(
      find.byType(ButtonStyleButton),
    );

    expect(
      buttons.every((b) => b.onPressed != null || b.onLongPress != null),
      isTrue,
    );
  });

  testWidgets('non scarica immagini da servizi esterni', (tester) async {
    // Lo sfondo arrivava da Unsplash: una chiamata di rete silenziosa, e
    // una card che si rompe se quell'indirizzo cambia.
    await tester.pumpWidget(wrap());

    expect(find.byType(NetworkImage), findsNothing);
    for (final image in tester.widgetList<Image>(find.byType(Image))) {
      expect(image.image, isNot(isA<NetworkImage>()));
    }
  });

  testWidgets('su uno schermo stretto non taglia niente', (tester) async {
    useNarrowScreen(tester);

    await tester.pumpWidget(wrap());

    expect(tester.takeException(), isNull);
  });
}
