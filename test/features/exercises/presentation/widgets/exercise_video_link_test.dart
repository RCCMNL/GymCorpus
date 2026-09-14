import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/core/services/external_links.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_video_link.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

class _SpyLinks implements ExternalLinks {
  final aperti = <String>[];
  bool esito = true;

  @override
  Future<bool> open(String url) async {
    aperti.add(url);
    return esito;
  }
}

const _conVideo = ExerciseEntity(
  id: 1,
  name: 'Panca piana',
  targetMuscle: 'Petto',
  referenceVideoUrl: 'https://video.example/panca',
);

const _senzaVideo = ExerciseEntity(
  id: 2,
  name: 'Panca piana',
  targetMuscle: 'Petto',
);

Future<void> _pump(WidgetTester tester, ExerciseEntity exercise) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: ExerciseVideoLink(exercise: exercise)),
    ),
  );
}

void main() {
  late _SpyLinks links;

  setUp(() {
    links = _SpyLinks();
    GetIt.I.registerSingleton<ExternalLinks>(links);
  });

  tearDown(GetIt.I.reset);

  group('ExerciseVideoLink', () {
    testWidgets('senza un indirizzo non occupa spazio', (tester) async {
      await _pump(tester, _senzaVideo);

      expect(find.text('Guarda il video'), findsNothing);
      expect(tester.getSize(find.byType(ExerciseVideoLink)), Size.zero);
    });

    testWidgets('con un indirizzo invita a guardare il video', (tester) async {
      await _pump(tester, _conVideo);

      expect(find.text('Guarda il video'), findsOneWidget);
    });

    testWidgets('dice che il video si apre fuori dall app', (tester) async {
      await _pump(tester, _conVideo);

      expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);
    });

    testWidgets('il tocco chiede di aprire quell indirizzo', (tester) async {
      await _pump(tester, _conVideo);
      await tester.tap(find.text('Guarda il video'));
      await tester.pump();

      expect(links.aperti, ['https://video.example/panca']);
    });

    testWidgets('se non si apre lo dice, invece di non fare niente', (
      tester,
    ) async {
      links.esito = false;

      await _pump(tester, _conVideo);
      await tester.tap(find.text('Guarda il video'));
      await tester.pump();

      expect(find.textContaining('Non riesco ad aprire'), findsOneWidget);
    });
  });
}
