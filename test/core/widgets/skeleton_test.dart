import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/widgets/skeleton.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('Shimmer', () {
    testWidgets('mostra il contenuto che sta coprendo', (tester) async {
      await tester.pumpWidget(
        wrap(const Shimmer(child: Text('forma del contenuto'))),
      );

      expect(find.text('forma del contenuto'), findsOneWidget);
    });

    testWidgets('si muove: il riflesso non resta fermo', (tester) async {
      await tester.pumpWidget(wrap(const Shimmer(child: SkeletonBox())));

      double position() =>
          tester.state<ShimmerState>(find.byType(Shimmer)).debugPosition;

      final start = position();
      await tester.pump(const Duration(milliseconds: 400));

      expect(position(), isNot(start));

      // Senza questo, il controller resta in corsa a fine test.
      await tester.pumpWidget(wrap(const SizedBox()));
    });
  });

  group('SkeletonBox', () {
    testWidgets('ha la misura e il raggio che gli si chiedono', (tester) async {
      await tester.pumpWidget(
        wrap(const SkeletonBox(width: 120, height: 14, radius: AppRadius.sm)),
      );

      final box = tester.widget<Container>(find.byType(Container));
      final decoration = box.decoration! as BoxDecoration;

      expect(tester.getSize(find.byType(Container)), const Size(120, 14));
      expect(decoration.borderRadius, AppRadius.sm);
    });
  });

  group('SkeletonList', () {
    testWidgets('finge il numero di righe che gli si chiede', (tester) async {
      await tester.pumpWidget(wrap(const SkeletonList(rows: 4)));

      expect(find.byType(SkeletonTile), findsNWidgets(4));

      await tester.pumpWidget(wrap(const SizedBox()));
    });

    testWidgets('una sola animazione per tutta la lista', (tester) async {
      await tester.pumpWidget(wrap(const SkeletonList(rows: 6)));

      // Sei righe non sono sei controller: il riflesso passa sopra la
      // lista intera, ed e' anche l'unico modo perche' i sei blocchi
      // siano in fase fra loro.
      expect(find.byType(Shimmer), findsOneWidget);

      await tester.pumpWidget(wrap(const SizedBox()));
    });
  });
}
