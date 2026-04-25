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
  Modifica profilo, sicurezza e integrazioni.
- `test/`
  Copertura unit, bloc e golden.
- `assets/images/`
  Asset grafici del brand/app.

## Vincoli Runtime Importanti

- `main()` chiama `dotenv.load()` prima dell'avvio, quindi `.env` deve esistere per i run locali.
- Firebase viene inizializzato tramite `lib/firebase_options.dart`; il progetto al momento e' configurato per Android e iOS. Non assumere supporto web/desktop.
- Il routing di autenticazione dipende dallo stato di `AuthBloc` e dai redirect GoRouter definiti in `lib/main.dart`.
- Il database Drift locale vive nella directory documenti dell'app come `gym_db.sqlite`.
- `AppDatabase` usa attualmente `schemaVersion => 10` e fa seed dei dati iniziali quando la tabella esercizi e' vuota.
- La strategia di migrazione ricrea le tabelle quando si aggiorna da versioni precedenti alla 9. Tratta i cambiamenti database con attenzione e aggiorna le migration in modo esplicito.

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
- Rispetta il worktree sporco corrente. Non revertare modifiche dell'utente non correlate.

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
- Per cambiamenti database, aggiorna schema, comportamento di migrazione e qualsiasi seed data toccato dalla feature.
- Per cambiamenti alla dependency injection, rigenera l'output Injectable prima di chiudere il lavoro.

## Flusso Consigliato Per Gli Agenti

1. Leggi `pubspec.yaml`, `lib/main.dart` e la cartella feature rilevante prima di modificare codice.
2. Verifica se il task tocca sorgenti che generano codice, come tabelle Drift, moduli Injectable o modelli Freezed.
3. Esegui modifiche mirate nella feature proprietaria.
4. Se serve generazione, accumula le modifiche correlate e rigenera il codice una sola volta a fine batch.
5. Esegui test mirati rispetto all'area modificata; non eseguire `flutter analyze` automaticamente.
6. Riassumi gli eventuali rischi residui, soprattutto intorno a Firebase, routing e migrazioni database.
