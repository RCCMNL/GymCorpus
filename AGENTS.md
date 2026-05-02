# AGENTS.md

## Lingua Predefinita

- Usa sempre l'italiano per risposte, aggiornamenti di stato, spiegazioni tecniche e riepiloghi, salvo richiesta esplicita dell'utente di usare un'altra lingua.
- Mantieni in inglese nomi di classi, API, librerie, comandi shell, path e simboli di codice.

## Panoramica Del Progetto

- `GymCorpus` e' un'app mobile Flutter per tracking degli allenamenti, consultazione esercizi, analytics e gestione profilo.
- L'app viene inizializzata in `lib/main.dart` con Firebase, dotenv, GetIt/Injectable, GoRouter e piu' BLoC.
- La locale attiva e' italiana (`it_IT`) e l'app e' bloccata in orientamento portrait.
- La codebase segue una struttura feature-first con `core/` per l'infrastruttura condivisa e `features/` per le aree funzionali.

## Stack Tecnologico

- Flutter + Dart
- State management: `flutter_bloc`
- Dependency injection: `get_it` + `injectable`
- Database locale: `drift` + SQLite
- Autenticazione e sync remoto profilo: Firebase Auth + Cloud Firestore
- Routing: `go_router`
- Configurazione locale/segreti: `flutter_dotenv`
- Test: `flutter_test`, `bloc_test`, `mocktail`, golden test
- Lint: `very_good_analysis`

## Struttura Della Repository

- `lib/core/`
  Theme condiviso, database, DI, utility e widget riutilizzabili.
- `lib/features/auth/`
  Flussi auth, BLoC, repository e data source locali/remoti.
- `lib/features/training/`
  Routine, set, cardio, impostazioni, preferiti e BLoC principale dell'allenamento.
- `lib/features/exercises/`
  Catalogo esercizi e schermate di dettaglio.
- `lib/features/analytics/`
  Schermate progressi e storico cardio.
- `lib/features/profile/`
  Modifica profilo, sicurezza, integrazioni, record e bacheca trofei/livelli.
- `test/`
  Copertura unit, bloc e golden.
- `assets/images/`
  Asset grafici del brand/app.

## Vincoli Runtime Importanti

- `main()` chiama `dotenv.load()` prima dell'avvio, quindi `.env` deve esistere per i run locali.
- Firebase viene inizializzato tramite `lib/firebase_options.dart`; il progetto al momento e' configurato per Android e iOS. Non assumere supporto web/desktop.
- Il routing di autenticazione dipende dallo stato di `AuthBloc` e dai redirect GoRouter definiti in `lib/main.dart`.
- Il database Drift locale vive nella directory documenti dell'app come `gym_db.sqlite`.
- `AppDatabase` usa attualmente `schemaVersion => 15` e fa seed dei dati iniziali quando la tabella esercizi e' vuota.
- La strategia di migrazione ricrea le tabelle quando si aggiorna da versioni precedenti alla 9. Tratta i cambiamenti database con attenzione e aggiorna le migration in modo esplicito.
- La tabella `Workouts` rappresenta le sessioni di allenamento tracciabili: una sessione viene considerata completata solo quando `completedAt` e' valorizzato.
- `WorkoutSet.workoutId` deve riferirsi a una riga `Workouts`; evita nuovi flussi che usano timestamp sciolti senza creare prima una sessione workout.
- Il sistema livelli/trofei/record e' local-first e calcolato dai dati gia' presenti tramite `AthleteProgressService`, non da dati remoti.
- Gli esercizi a corpo libero sono ora espliciti nel DB tramite `Exercises.isBodyweight`; non inferire piu' questa informazione dal testo di `equipment` nei nuovi flussi.

## Notifiche

- Per GymCorpus, i reminder di prodotto correnti sono `local-first`: stretching, allenamento, timer recupero, badge e record devono vivere prima di tutto come notifiche locali.
- `Firebase/FCM` non e' richiesto per i reminder core dell'app. Valutalo solo per push remote reali, come campagne, messaggi di servizio, re-engagement lato server o eventi cross-device.
- I promemoria stretching restano giornalieri, mentre i promemoria allenamento devono rispettare davvero i giorni selezionati dall'utente.
- Il sistema notifiche locale passa da `NotificationService`, `NotificationsRepository`, `NotificationsBloc` e `NotificationSettingsScreen`; evita percorsi paralleli.
- Se una notifica locale deve comparire anche nel centro notifiche interno, registra esplicitamente il log nel flusso applicativo o usa payload/tap handling coerente.
- La timezone dei reminder deve seguire il device reale; se tocchi lo scheduling, verifica anche il bridge nativo Android/iOS usato per leggere il timezone locale.
- Le notifiche locali gia' supportate hanno ID riservati nel range del bloc notifiche; evita collisioni con nuovi reminder.

## File Generati

Non modificare a mano i file generati, salvo richiesta esplicita dell'utente.

- `*.g.dart`
- `*.freezed.dart`
- `lib/core/service_locator.config.dart`

Dopo modifiche a tabelle Drift, modelli Freezed, tipi JSON-serializable o annotazioni Injectable, rigenera il codice:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Convenzioni Di Lavoro

- Rispetta la struttura feature-first esistente. Tieni il codice vicino alla feature proprietaria, salvo casi chiaramente cross-cutting.
- Preferisci estendere repository, BLoC e widget esistenti invece di introdurre una nuova astrazione parallela.
- Preserva il copy UI rivolto all'utente in italiano, salvo task espliciti di localizzazione o revisione contenuti.
- Molti metodi dei repository restituiscono `Either<Failure, ...>` e si appoggiano a stream per aggiornare lo stato UI. Mantieni coerente questo pattern.
- L'app usa gia' in alcuni punti un comportamento local-first, soprattutto nei flussi auth/profile. Evita modifiche che rendano la UI dipendente da round-trip remoti lenti quando ci si aspetta un aggiornamento locale immediato.
- Per gamification, tieni le definizioni statiche dei badge in codice e salva/calcola solo lo stato utente necessario. Non creare tabelle di definizioni badge statiche salvo esigenza esplicita.
- Rispetta il worktree sporco corrente. Non revertare modifiche dell'utente non correlate.

## Gamification, Record E Livelli

- La logica di XP, livelli, trofei e record vive in `lib/features/profile/domain/services/athlete_progress_service.dart`.
- Le schermate dedicate sono `TrophyBoardScreen` e `RecordsScreen`, raggiungibili dal menu profilo.
- `TrainingState.loaded` espone `workoutSessions`, `weightLogs`, `cardioSessions` ed `exercises`; usa questi dati come input per `AthleteProgressService.calculate`.
- `TrainingScreen` deve creare una sessione con `StartWorkoutSessionEvent` all'avvio e completarla con `CompleteWorkoutSessionEvent` quando l'ultimo set viene concluso.
- Prima di aggiungere badge basati sulla "singola sessione", verifica che i dati richiesti siano aggregabili per `workoutId`.
- Evita badge facilmente farmabili tramite micro-azioni. Preferisci milestone basate su workout completati, cardio completati, record, varieta' e streak.
- Per record personali, mantieni separata la logica utile all'utente dalla bacheca trofei: record e trofei possono usare gli stessi dati, ma hanno scopi UI diversi.

## Test E Verifica

Esegui i controlli piu' mirati possibile rispetto all'area che modifichi.

Per velocizzare lo sviluppo:

- Esegui test mirati invece di `flutter test` completo a ogni micro-modifica.
- Non lanciare `flutter analyze` automaticamente: l'utente lo esegue da console quando serve, perche' puo' richiedere troppo tempo.
- Evita modifiche inutili a file molto grandi, come `lib/features/profile/presentation/screens/profile_screen.dart`.
- Riduci l'uso di Freezed/build_runner per modelli semplici quando non serve davvero generazione.
- Accumula le modifiche che richiedono generazione e lancia `build_runner` una sola volta alla fine.
- Regola pratica: lavora per batch e verifica con test mirati durante lo sviluppo; usa verifiche piu' ampie solo su richiesta esplicita.

Comandi comuni:

```bash
flutter test
flutter test test/core/utils/training_calculations_test.dart
flutter test test/features/profile/domain/services/athlete_progress_service_test.dart
flutter test test/features/training/presentation/bloc/training_bloc_test.dart
flutter test test/features/training/presentation/widgets/exercise_card_test.dart
flutter test --update-goldens
```

Note:

- I golden file di `ExerciseCard` sono in `test/features/training/presentation/widgets/goldens/`.
- Se una modifica UI cambia intenzionalmente gli snapshot della card, riesegui il comando di update goldens e rivedi le immagini generate.

## Linee Guida Per Le Modifiche

- Per cambiamenti di routing, verifica sia il flusso autenticato sia quello non autenticato, perche' i redirect sono centralizzati in `lib/main.dart`.
- Per cambiamenti auth, controlla sia lo stato Firebase sia la gestione sessione locale in `auth_repository_impl.dart`.
- Per cambiamenti training, ispeziona insieme `TrainingBloc`, `TrainingRepository` e l'accesso Drift prima di modificare il comportamento, perche' molti flussi sono guidati da stream.
- Per cambiamenti a trofei, livelli o record, aggiorna `AthleteProgressService` e il test mirato `test/features/profile/domain/services/athlete_progress_service_test.dart`.
- Per cambiamenti database, aggiorna schema, comportamento di migrazione e qualsiasi seed data toccato dalla feature.
- Per cambiamenti alla dependency injection, rigenera l'output Injectable prima di chiudere il lavoro.

## Flusso Consigliato Per Gli Agenti

1. Leggi `pubspec.yaml`, `lib/main.dart` e la cartella feature rilevante prima di modificare codice.
2. Verifica se il task tocca sorgenti che generano codice, come tabelle Drift, moduli Injectable o modelli Freezed.
3. Esegui modifiche mirate nella feature proprietaria.
4. Se serve generazione, accumula le modifiche correlate e rigenera il codice una sola volta a fine batch.
5. Esegui test mirati rispetto all'area modificata; non eseguire `flutter analyze` automaticamente.
6. Riassumi gli eventuali rischi residui, soprattutto intorno a Firebase, routing e migrazioni database.
