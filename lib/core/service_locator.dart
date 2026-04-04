import 'package:get_it/get_it.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/core/database/connection.dart';
import 'package:gym_corpus/features/training/data/repositories/training_repository_impl.dart';
import 'package:gym_corpus/features/training/domain/repositories/training_repository.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<AppDatabase>(
    () => AppDatabase(openConnection()),
  );

  // Repositories
  sl.registerLazySingleton<TrainingRepository>(
    () => TrainingRepositoryImpl(database: sl()),
  );

  // BLoCs
  sl.registerFactory(() => TrainingBloc(repository: sl()));
}
