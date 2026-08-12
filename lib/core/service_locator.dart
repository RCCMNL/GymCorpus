import 'package:get_it/get_it.dart';
import 'package:gym_corpus/core/service_locator.config.dart';
import 'package:gym_corpus/core/services/health_service.dart';
import 'package:injectable/injectable.dart';

final sl = GetIt.instance;

@InjectableInit(initializerName: 'initInjectable')
Future<void> configureDependencies() async {
  sl
    ..initInjectable()
    // Registrazioni manuali (non Injectable)
    ..registerLazySingleton<HealthService>(HealthService.new);
}
