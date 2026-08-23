import 'package:bloc_test/bloc_test.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

/// Mock riutilizzabile di TrainingBloc per i widget test: molti dei widget
/// estratti dalle schermate di training/analytics leggono
/// `context.read<TrainingBloc>()` per lo stato corrente o per inviare
/// eventi, senza montare l'intero bloc con repository reali.
class MockTrainingBloc extends MockBloc<TrainingEvent, TrainingState>
    implements TrainingBloc {}
