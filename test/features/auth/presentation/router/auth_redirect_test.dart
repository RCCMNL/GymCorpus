import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/auth/presentation/router/auth_redirect.dart';

/// La regola che decide dove puo' stare l'utente. Vive fuori dal router
/// proprio per poter essere verificata caso per caso, senza montare l'app.
void main() {
  final completeUser = UserEntity(
    id: '1',
    email: 'mario@example.com',
    firstName: 'Mario',
    lastName: 'Rossi',
    username: 'mario',
    birthDate: DateTime(1990, 5, 12),
    gender: 'Uomo',
  );

  /// Il profilo tipico di chi entra con Google: manca il genere.
  final incompleteUser = UserEntity(
    id: '1',
    email: 'mario@example.com',
    firstName: 'Mario',
    lastName: 'Rossi',
    username: 'mario',
    birthDate: DateTime(1990, 5, 12),
  );

  String? redirect(AuthState state, String location, {bool isLocked = false}) {
    return resolveAuthRedirect(
      authState: state,
      location: location,
      isLocked: isLocked,
    );
  }

  group('senza autenticazione', () {
    test('le schermate dell app riportano al login', () {
      expect(
        redirect(const AuthState.unauthenticated(), '/training'),
        '/login',
      );
    });

    test('login, registrazione, splash e legale restano raggiungibili', () {
      const state = AuthState.unauthenticated();

      expect(redirect(state, '/login'), isNull);
      expect(redirect(state, '/signup'), isNull);
      expect(redirect(state, '/splash'), isNull);
      expect(redirect(state, '/legal/privacy'), isNull);
    });

    test('l onboarding non e raggiungibile senza account', () {
      expect(
        redirect(const AuthState.unauthenticated(), '/onboarding'),
        '/login',
      );
    });
  });

  group('con un profilo completo', () {
    test('le schermate di accesso rimandano all app', () {
      final state = AuthState.authenticated(completeUser);

      expect(redirect(state, '/login'), '/training');
      expect(redirect(state, '/splash'), '/training');
    });

    test('le schermate dell app restano dove sono', () {
      expect(
        redirect(AuthState.authenticated(completeUser), '/profile'),
        isNull,
      );
    });

    test('non si resta sull onboarding una volta compilato', () {
      expect(
        redirect(AuthState.authenticated(completeUser), '/onboarding'),
        '/training',
      );
    });
  });

  group('con un profilo incompleto', () {
    test('ogni schermata porta all onboarding', () {
      final state = AuthState.authenticated(incompleteUser);

      expect(redirect(state, '/training'), '/onboarding');
      expect(redirect(state, '/profile'), '/onboarding');
      expect(redirect(state, '/login'), '/onboarding');
    });

    test('sull onboarding si resta', () {
      expect(
        redirect(AuthState.authenticated(incompleteUser), '/onboarding'),
        isNull,
      );
    });

    test('il blocco applicazione ha la precedenza', () {
      // Un profilo da completare non deve aggirare il lucchetto.
      expect(
        redirect(
          AuthState.authenticated(incompleteUser),
          '/training',
          isLocked: true,
        ),
        '/lock',
      );
    });
  });

  group('stati di passaggio', () {
    test('durante il caricamento non si sposta nessuno', () {
      expect(redirect(const AuthState.loading(), '/training'), isNull);
      expect(redirect(const AuthState.initial(), '/training'), isNull);
    });

    test('un errore su una sessione gia attiva non butta fuori', () {
      expect(
        redirect(
          AuthState.error('rete assente', previousUser: completeUser),
          '/training',
        ),
        isNull,
      );
    });

    test('un errore senza sessione riporta al login', () {
      expect(
        redirect(const AuthState.error('credenziali'), '/training'),
        '/login',
      );
    });
  });
}
