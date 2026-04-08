// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:gym_corpus/core/database/database.dart' as _i158;
import 'package:gym_corpus/core/di/database_module.dart' as _i696;
import 'package:gym_corpus/features/auth/data/datasources/auth_local_data_source.dart'
    as _i975;
import 'package:gym_corpus/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i701;
import 'package:gym_corpus/features/auth/data/repositories/auth_repository_impl.dart'
    as _i328;
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart'
    as _i25;
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart'
    as _i312;
import 'package:gym_corpus/features/training/data/repositories/training_repository_impl.dart'
    as _i871;
import 'package:gym_corpus/features/training/domain/repositories/training_repository.dart'
    as _i949;
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart'
    as _i195;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt initInjectable({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final databaseModule = _$DatabaseModule();
    gh.lazySingleton<_i158.AppDatabase>(() => databaseModule.appDatabase);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
        () => databaseModule.secureStorage);
    gh.lazySingleton<_i59.FirebaseAuth>(() => databaseModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => databaseModule.firestore);
    gh.lazySingleton<_i949.TrainingRepository>(
        () => _i871.TrainingRepositoryImpl(database: gh<_i158.AppDatabase>()));
    gh.factory<_i195.TrainingBloc>(
        () => _i195.TrainingBloc(repository: gh<_i949.TrainingRepository>()));
    gh.lazySingleton<_i975.AuthLocalDataSource>(
        () => _i975.AuthLocalDataSourceImpl(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i701.AuthRemoteDataSource>(
        () => _i701.AuthRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i25.AuthRepository>(() => _i328.AuthRepositoryImpl(
          gh<_i59.FirebaseAuth>(),
          gh<_i975.AuthLocalDataSource>(),
          gh<_i701.AuthRemoteDataSource>(),
        ));
    gh.factory<_i312.AuthBloc>(() => _i312.AuthBloc(gh<_i25.AuthRepository>()));
    return this;
  }
}

class _$DatabaseModule extends _i696.DatabaseModule {}
