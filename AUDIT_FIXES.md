# Piano Correzioni Audit

Questo file raccoglie i problemi emersi dalla review statica della codebase e propone soluzioni operative. Le priorita' sono pensate per rendere l'app piu' sicura, stabile, pulita e professionale.

## Priorita' 1 - Sicurezza E Dati

### 1. Cambio password mostra successo anche se fallisce

File coinvolti:

- `lib/features/profile/presentation/screens/security_screen.dart`
- `lib/features/auth/presentation/bloc/auth_bloc.dart`
- `lib/features/auth/presentation/bloc/auth_state.dart`

Problema:

La bottom sheet invia `AuthEvent.changePasswordRequested`, aspetta un delay fisso e mostra sempre "Password aggiornata con successo". Se Firebase fallisce, l'utente riceve un falso positivo.

Soluzione consigliata:

- Rimuovere il delay fisso da `_submit()`.
- Fare ascoltare alla bottom sheet lo stato di `AuthBloc` con `BlocListener`.
- Mostrare successo solo quando l'operazione termina davvero con esito positivo.
- Mostrare errore se `AuthBloc` emette `AuthState.error`.
- Valutare uno stato dedicato per le operazioni account, ad esempio `passwordChanged`, oppure un risultato locale restituito dal repository senza passare dal router auth globale.

Verifica:

```bash
flutter test
```

Test da aggiungere:

- Cambio password riuscito chiude la sheet e mostra successo.
- Password corrente errata mostra errore e non chiude la sheet.

### 2. Password stampabili nei `toString` generati da Freezed

File coinvolti:

- `lib/features/auth/presentation/bloc/auth_event.dart`
- `lib/features/auth/presentation/bloc/auth_event.freezed.dart`

Problema:

Gli eventi Freezed includono password nel `toString`. Se vengono loggati eventi o crash report, le credenziali possono finire nei log.

Soluzione consigliata:

- Disabilitare il `toString` generato da Freezed per `AuthEvent` con annotazione Freezed adeguata.
- In alternativa, evitare Freezed per eventi contenenti segreti e scrivere classi manuali con `props`/`toString` redatti.
- Rigenerare i file generati dopo la modifica.

Esempio direzione:

```dart
@Freezed(toStringOverride: false)
class AuthEvent with _$AuthEvent {
  // ...
}
```

Verifica:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter test
```

### 3. Migrazione Drift distruttiva

File coinvolti:

- `lib/core/database/database.dart`

Problema:

La migration per versioni precedenti alla 9 elimina tutte le tabelle e le ricrea. In produzione questo causa perdita dati locale.

Soluzione consigliata:

- Rimuovere la logica generica che fa `deleteTable` su tutte le tabelle.
- Scrivere migration incrementali per ogni cambio schema.
- Documentare per ogni `schemaVersion` quali colonne/tabelle sono state aggiunte.
- Se alcuni reset erano solo da sviluppo, spostarli dietro flag debug o in utility manuale fuori dalla migration di produzione.

Verifica:

```bash
flutter test
```

Test da aggiungere:

- Test migration da schema precedente a schema corrente con dati esistenti.
- Verifica che routine, esercizi, progressi e settings restino presenti dopo upgrade.

### 4. Delete routine non elimina relazioni figlie

File coinvolti:

- `lib/core/database/database.dart`
- `lib/features/training/data/repositories/training_repository_impl.dart`

Problema:

`deleteRoutine(id)` elimina solo la routine. I record in `routineExercises` possono bloccare la delete o restare orfani.

Soluzione consigliata:

- Eliminare prima le righe in `routineExercises` dentro una transaction.
- Poi eliminare la riga da `routines`.
- In alternativa, dichiarare foreign key con cascade se supportato e coerente con Drift.

Esempio direzione:

```dart
Future<void> deleteRoutine(int id) async {
  await transaction(() async {
    await (delete(routineExercises)..where((t) => t.routineId.equals(id))).go();
    await (delete(routines)..where((t) => t.id.equals(id))).go();
  });
}
```

Verifica:

```bash
flutter test test/features/training/presentation/bloc/training_bloc_test.dart
```

## Priorita' 2 - Stabilita' Runtime

### 5. Deep link possono crashare senza `state.extra`

File coinvolti:

- `lib/main.dart`

Problema:

Alcune route fanno cast forzato con `!`, per esempio detail routine ed exercise detail. Se la route viene aperta senza extra, l'app crasha.

Soluzione consigliata:

- Sostituire i cast forzati con controlli espliciti.
- Mostrare una schermata fallback o redirectare alla lista corretta.
- Per route condivisibili, usare path parameter (`/exercises/:id`, `/custom/:id`) e recuperare i dati dal repository/BLoC.

Verifica:

- Aprire `/custom/detail` senza extra.
- Aprire `/exercises/detail` senza extra.
- Verificare che l'app mostri fallback invece di crashare.

### 6. `.env` incluso negli asset Flutter

File coinvolti:

- `pubspec.yaml`
- `lib/main.dart`
- `.gitignore`

Problema:

`.env` e' ignorato da git ma dichiarato come asset. Questo puo' rompere build su macchine pulite e impacchettare configurazioni dentro l'app.

Soluzione consigliata:

- Rimuovere `.env` dalla sezione `flutter.assets`.
- Valutare se `GOOGLE_SERVER_CLIENT_ID` deve stare in configurazione nativa, remote config o dart-define.
- Se resta `flutter_dotenv`, usare un file template non sensibile, per esempio `.env.example`, e documentare setup locale.

Verifica:

```bash
flutter pub get
flutter build apk --debug
```

### 7. Lifecycle non chiude `AuthBloc` e `BlocRefreshStream`

File coinvolti:

- `lib/main.dart`

Problema:

`AuthBloc` viene creato manualmente e passato con `BlocProvider.value`, ma `_GymAppState` non lo chiude. Anche `BlocRefreshStream` viene creato inline e non conservato/disposto nello State.

Soluzione consigliata:

- Salvare `BlocRefreshStream` in un campo, per esempio `_routerRefresh`.
- Implementare `dispose()`.
- Chiudere `_authBloc` e `_routerRefresh`.

Esempio direzione:

```dart
late final BlocRefreshStream _routerRefresh;

@override
void initState() {
  super.initState();
  _authBloc = di.sl<AuthBloc>()..add(const AuthEvent.checkSessionRequested());
  _routerRefresh = BlocRefreshStream(_authBloc.stream);
  _router = GoRouter(refreshListenable: _routerRefresh, ...);
}

@override
void dispose() {
  _routerRefresh.dispose();
  _authBloc.close();
  super.dispose();
}
```

Verifica:

```bash
flutter analyze
flutter test
```

### 8. iOS usa picker e biometria senza usage keys

File coinvolti:

- `ios/Runner/Info.plist`
- `lib/features/profile/presentation/screens/profile_screen.dart`
- `lib/features/profile/presentation/screens/security_screen.dart`

Problema:

L'app usa `ImagePicker` e `LocalAuthentication`, ma `Info.plist` non dichiara le chiavi privacy necessarie.

Soluzione consigliata:

- Aggiungere `NSPhotoLibraryUsageDescription`.
- Aggiungere `NSFaceIDUsageDescription`.
- Se in futuro si usa camera, aggiungere anche `NSCameraUsageDescription`.
- Se Health su iOS viene realmente integrato, aggiungere le chiavi HealthKit richieste.

Esempio:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>GymCorpus usa la libreria foto per permetterti di aggiornare l'immagine profilo.</string>
<key>NSFaceIDUsageDescription</key>
<string>GymCorpus usa Face ID per proteggere le operazioni sensibili del tuo account.</string>
```

Verifica:

```bash
flutter build ios
```

## Priorita' 3 - Bug Funzionali

### 9. Android potrebbe non avere permesso Internet esplicito

File coinvolti:

- `android/app/src/main/AndroidManifest.xml`

Problema:

L'app usa Firebase, OpenStreetMap e servizi remoti. Nel manifest principale non risulta dichiarato `android.permission.INTERNET`.

Soluzione consigliata:

- Aggiungere il permesso internet nel manifest principale.

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

Verifica:

```bash
flutter build apk --debug
```

### 10. `CardioHistoryScreen` non carica le sessioni se aperta direttamente

File coinvolti:

- `lib/features/analytics/presentation/screens/cardio_history_screen.dart`

Problema:

La schermata legge `state.cardioSessions`, ma non invia `LoadCardioSessionsEvent`. Se viene aperta senza passare prima da Analytics, puo' mostrare lista vuota anche con dati presenti.

Soluzione consigliata:

- Convertire la screen in `StatefulWidget`.
- In `initState`, dispatchare `LoadCardioSessionsEvent`.

Verifica:

- Avviare l'app.
- Aprire direttamente `/analytics/cardio-history`.
- Controllare che le sessioni vengano caricate.

### 11. Eliminazione account parziale se Firebase richiede re-auth

File coinvolti:

- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/profile/presentation/screens/security_screen.dart`

Problema:

`deleteAccount()` elimina prima i dati Firestore e poi chiama `user.delete()`. Se `user.delete()` fallisce per `requires-recent-login`, i dati sono gia' stati rimossi ma l'account resta attivo.

Soluzione consigliata:

- Re-autenticare prima l'utente.
- Eseguire `user.delete()` solo dopo re-auth riuscita.
- Eliminare i dati Firestore in modo coordinato, preferibilmente tramite Cloud Function lato server o flow transazionale lato backend.
- Gestire esplicitamente `requires-recent-login` nella UI.

Verifica:

- Test manuale con utente loggato da molto tempo.
- Confermare messaggio re-auth invece di cancellazione parziale.

### 12. Foto profilo salvata come path locale

File coinvolti:

- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/profile/presentation/screens/profile_screen.dart`

Problema:

`updatePhotoURL(filePath)` salva un path locale. Su altri dispositivi quel path non esiste, quindi l'immagine profilo non e' portabile.

Soluzione consigliata:

- Se la foto deve essere sincronizzata, caricarla su Firebase Storage o altro storage remoto e salvare URL pubblico/protetto.
- Se la foto e' solo locale, non salvarla in Firebase come `photoUrl` globale.
- Aggiungere gestione errori se `FileImage` punta a un file non piu' esistente.

Verifica:

- Cambiare foto profilo.
- Riavviare app.
- Accedere da altro device/account session e controllare immagine.

## Priorita' 4 - Pulizia E Professionalita'

### 13. File temporanei e residui di patch

File coinvolti:

- `patch.py`
- `patch.js`
- `analysis.txt`
- `artifacts/test.md`
- `tmp/parse_exercises.py`
- `tmp/generate_seed.py`
- `tmp/initial_exercises.txt`
- `.gemini/`

Problema:

Ci sono file temporanei, script con path assoluti locali e artefatti di test/lavorazione. Alcuni sono tracciati da git, altri sono non tracciati.

Soluzione consigliata:

- Eliminare `patch.py` e `patch.js` se sono solo residui.
- Spostare gli script utili in `tool/` o `scripts/`, rimuovendo path assoluti.
- Eliminare `artifacts/test.md` se non serve.
- Valutare se `analysis.txt` deve diventare documentazione o essere rimosso.
- Aggiungere `tmp/`, `artifacts/` e patch temporanee a `.gitignore` se sono output locali.

Verifica:

```bash
git status --short
```

### 14. Menu con azioni appese

File coinvolti:

- `lib/features/profile/presentation/screens/profile_screen.dart`
- `lib/features/training/presentation/screens/training_dashboard_screen.dart`

Problema:

Molte voci hanno `onTap: () {}` e sembrano funzionalita' reali, ma non fanno nulla. Questo rende l'app meno professionale.

Soluzione consigliata:

- Nascondere le feature non implementate.
- Oppure disabilitarle visivamente con badge "Prossimamente".
- Oppure collegarle a schermate reali.

Esempi:

- `Classifica Utenti`
- `Sfide Community`
- `Bacheca Trofei & Livelli`
- `Record`
- `Obiettivi`
- `Esercizi Preferiti`
- `Programma attuale`
- `Calendario ciclo`
- `QR Check-in`
- `Yoga & Mindfulness`
- `Nutrizione & Dieta`
- `Notifiche`
- `Lingua`
- `Dark Mode`

Verifica:

- Tap manuale su tutte le voci profilo/dashboard.
- Nessuna voce cliccabile deve restare senza effetto.

### 15. README e licenza incoerenti

File coinvolti:

- `README.md`
- `LICENSE`

Problema:

Il badge indica licenza proprietaria e `LICENSE` dice "all rights reserved", ma il README dichiara MIT.

Soluzione consigliata:

- Decidere licenza reale.
- Se proprietaria, correggere la sezione README.
- Se MIT, sostituire il file `LICENSE` con testo MIT valido.

Verifica:

- README e LICENSE devono comunicare la stessa licenza.

### 16. `.gitignore` incoerente per Firebase config

File coinvolti:

- `.gitignore`
- `firebase.json`

Problema:

Le regole provano a re-includere Firebase config, ma `git check-ignore` indica che `android/app/src/main/google-services.json` e `ios/Runner/GoogleService-Info.plist` restano ignorati.

Soluzione consigliata:

- Scegliere una policy chiara.
- Se i file Firebase config vanno committati, rimuovere le regole globali che li ignorano o aggiungere eccezioni dopo le regole globali.
- Se non vanno committati, aggiornare README con istruzioni per generarli.

Verifica:

```bash
git check-ignore -v android/app/src/main/google-services.json
git check-ignore -v ios/Runner/GoogleService-Info.plist
```

### 17. Errori silenziati con `catch (_) {}`

File coinvolti:

- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/analytics/presentation/screens/cardio_history_screen.dart`
- `lib/features/profile/presentation/screens/security_screen.dart`
- `lib/features/training/presentation/screens/workout_page.dart`
- `lib/features/training/presentation/screens/workout_detail_screen.dart`

Problema:

Gli errori vengono ingoiati senza log, fallback visibile o tracking. Questo rende difficile diagnosticare bug reali.

Soluzione consigliata:

- Dove l'errore e' recuperabile, mostrare fallback esplicito.
- Dove l'errore indica dati corrotti, loggare in debug e ripulire il dato.
- Evitare messaggi tecnici all'utente finale, ma non perdere il segnale in sviluppo.

Verifica:

```bash
flutter analyze
flutter test
```

## Migliorie Architetturali Consigliate

### A. Separare stato auth da operazioni account

Problema:

`AuthBloc` gestisce login/sessione e anche operazioni puntuali come cambio password, delete account, update profilo. Alcune UI devono evitare `loading` per non interferire con GoRouter.

Soluzione:

- Introdurre stati/side effects dedicati per operazioni account.
- Oppure creare un `AccountCubit` per cambio password, update profilo, biometria, delete account.
- Lasciare `AuthBloc` responsabile solo di sessione/autenticazione globale.

### B. Migliorare routing con ID invece di `extra`

Problema:

Molte schermate detail dipendono da oggetti passati in memoria.

Soluzione:

- Usare route come `/custom/:routineId` e `/exercises/:exerciseId`.
- Caricare i dati da BLoC/repository.
- Tenere `extra` solo come ottimizzazione opzionale.

### C. Rendere le feature incompiute esplicite

Problema:

La UI promette funzionalita' non implementate.

Soluzione:

- Nascondere feature non pronte.
- Usare badge "Prossimamente" con tap disabilitato.
- Evitare CTA che non portano da nessuna parte.

## Ordine Di Intervento Suggerito

1. Sistemare cambio password e leak password nei `toString`.
2. Sistemare migration Drift e delete routine.
3. Rimuovere `.env` dagli asset e chiarire configurazione Firebase.
4. Aggiungere permessi iOS/Android mancanti.
5. Mettere fallback alle route con `state.extra`.
6. Chiudere lifecycle di `AuthBloc` e `BlocRefreshStream`.
7. Pulire file temporanei, README/LICENSE e `.gitignore`.
8. Ripassare menu e feature appese.
9. Eseguire `flutter analyze`.
10. Eseguire `flutter test`.

## Comandi Finali Di Verifica

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter test test/core/utils/training_calculations_test.dart
flutter test test/features/training/presentation/bloc/training_bloc_test.dart
flutter test test/features/training/presentation/widgets/exercise_card_test.dart
```

Nota: durante la review iniziale `flutter` non era disponibile nel PATH della shell, quindi analyzer e test vanno eseguiti in un ambiente Flutter configurato.
