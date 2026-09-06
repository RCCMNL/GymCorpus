import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';

/// Rotte raggiungibili senza aver effettuato l'accesso.
const _publicLocations = {'/login', '/signup', '/splash'};

/// Rotte da cui, una volta dentro con un profilo completo, si viene portati
/// nell'app: sono passaggi, non destinazioni.
const _entryLocations = {'/login', '/signup', '/splash', '/lock', '/onboarding'};

const onboardingLocation = '/onboarding';

/// Decide dove puo' stare l'utente, in base a sessione, blocco applicazione
/// e completezza del profilo.
///
/// Vive fuori dal router per poter essere verificata caso per caso: le
/// condizioni sono poche ma si intrecciano, e sbagliarne una significa
/// chiudere fuori un utente o farne entrare uno con il profilo a meta'.
String? resolveAuthRedirect({
  required AuthState authState,
  required String location,
  required bool isLocked,
}) {
  return authState.maybeWhen(
    authenticated: (user, _) {
      // Il lucchetto viene prima di tutto: un profilo da completare non deve
      // diventare un modo per aggirarlo.
      if (isLocked) return location == '/lock' ? null : '/lock';

      if (!user.isProfileComplete) {
        return location == onboardingLocation ? null : onboardingLocation;
      }

      if (_entryLocations.contains(location)) return '/training';
      return null;
    },
    unauthenticated: () => _redirectToLogin(location),
    error: (_, previousUser) {
      // Con un utente precedente la sessione era attiva: un errore di rete
      // non deve buttare fuori chi stava usando l'app.
      if (previousUser != null) return null;
      return _redirectToLogin(location);
    },
    loading: (_) => null,
    orElse: () => null,
  );
}

String? _redirectToLogin(String location) {
  if (_publicLocations.contains(location) || location.startsWith('/legal')) {
    return null;
  }
  return '/login';
}
