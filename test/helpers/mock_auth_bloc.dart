import 'package:bloc_test/bloc_test.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';

/// Mock riutilizzabile di AuthBloc per i widget che leggono l'utente
/// autenticato (es. peso/altezza profilo) senza montare l'intero flusso di
/// autenticazione.
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
