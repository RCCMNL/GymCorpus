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
- Il database Drift locale vive nella directory documenti dell'app come `gym_db.sqlite` ed e' cifrato con SQLCipher. La chiave sta nel secure storage; `lib/core/database/connection.dart` gestisce apertura, generazione chiave e conversione dei database in chiaro creati da versioni precedenti. Non aggiungere `sqlite3_flutter_libs`: va in conflitto con SQLCipher.
- `AppDatabase` usa attualmente `schemaVersion => 20` e fa seed dei dati iniziali quando la tabella esercizi e' vuota.
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
- Per i messaggi a comparsa usa sempre `AppSnackBar` (`lib/core/widgets/app_snack_bar.dart`): scegli il tono (`neutral`, `success`, `warning`, `error`) e lascia il colore al tema. Non costruire a mano una `SnackBar`, ne' usare `Colors.red`/`Colors.green`/`Colors.orange` diretti.
- Per chiedere conferma prima di un'azione irreversibile usa `ConfirmDialog.ask` (`lib/core/widgets/confirm_dialog.dart`), che ritorna `true` solo se l'utente ha confermato.
- Per il titolo sfumato di una schermata usa `GradientTitle` (`lib/core/widgets/gradient_title.dart`) con una delle tre misure (`compact` 22, `screen` 28, `hero` 32); per icone e logo usa `GradientMask`. Non riscrivere lo `ShaderMask` a mano.
- Per i fogli modali che chiedono un valore usa `CompactSheet`, `DecimalField` e `SheetActions` (`lib/core/widgets/compact_sheet.dart`), e leggi i numeri con `parseDecimalInput`.

## Profilo E Onboarding

- Le informazioni di base del profilo (nome, cognome, username, data di nascita, genere) si chiedono a chiunque crei un account, da qualunque percorso: `UserEntity.isProfileComplete` e' l'unica definizione di "profilo completo".
- Il cancello e' nel router: `resolveAuthRedirect` in `lib/features/auth/presentation/router/auth_redirect.dart` manda su `/onboarding` chi e' autenticato con un profilo incompleto, e ne esce da solo quando il profilo viene salvato. Modifica quella funzione, non la closure `redirect` di `main.dart`.
- Il form dei campi base vive in un solo widget, `ProfileBasicsForm`, condiviso tra registrazione e onboarding: non duplicarlo per aggiungere un percorso nuovo.
- Il genere non ha un valore predefinito e non si prosegue senza sceglierlo. Le opzioni sono Uomo, Donna e Altro, le stesse in registrazione, onboarding e modifica profilo.
- Un salvataggio di profilo fallito viaggia in `AuthState.authenticated(user, actionError: ...)`: l'utente resta autenticato e la schermata che ha chiesto il salvataggio mostra il messaggio. Non trasformarlo in `AuthState.error`, che farebbe sparire l'utente da mezza app.
- L'onboarding ha due passi: informazioni di base (obbligatorie) e peso/altezza (facoltativi, con "Lo faccio dopo"). Il profilo viene scritto una volta sola, alla fine.
- Con un provider esterno i consensi legali si raccolgono prima di autenticare, in un foglio dedicato: il repository cancella l'utente appena creato se non sono stati accettati. Il profilo lo chiede poi l'onboarding.
- Il pulsante Apple compare solo su iOS e macOS (linea guida App Store 4.8).

## Calendario Ciclo

- I dati del ciclo vivono solo nel database locale cifrato, nella tabella `CycleLogs`: non passano da Firestore e non finiscono nel report PDF. Non aggiungerli a flussi di sync o di export senza una richiesta esplicita.
- Giorno del ciclo, fase, medie e previsioni non sono mai salvati: li calcola `CycleForecast` dalle sole date registrate. Quando i dati non bastano lo stato lo dichiara (`CycleDataState`), invece di mostrare valori di comodo.
- `CycleBloc` viene creato dalla rotta `/profile/cycle-calendar`, non dal `MultiBlocProvider` globale: chi non apre la schermata non mette mai in ascolto quei dati.
- La voce di menu e' accesa di default per i profili con `gender == 'Donna'`, ma l'interruttore in Impostazioni la accende o spegne per chiunque: la preferenza `cycle_calendar_enabled` vince sempre sul sesso indicato.
- Il promemoria del ciclo previsto e' una notifica locale una tantum con id riservato 9020, riprogrammata a ogni cambiamento delle registrazioni: la data prevista si sposta, quindi non basta accenderla una volta.

## Cardio

- I punti del percorso (`CardioRoutePoint`) portano il tempo di passaggio: e' quello che rende possibili gli split al chilometro. I percorsi salvati senza tempo restano leggibili e mostrano "split non disponibili".
- Split e passo non sono salvati a database: si ricalcolano da `routeJson` con `CardioSplits`.
- L'obiettivo di sessione (`CardioGoal`) si sceglie prima di partire e viene salvato con la sessione (`goal_type`, `goal_value`): lo storico puo' dire se e' stato raggiunto.
- I tipi di attivita' vivono in `CardioActivity`: l'identificativo e' quello salvato nella colonna `type`, e un valore sconosciuto ricade sulla corsa invece di far fallire la lettura. Le attivita' al chiuso non chiedono il permesso di localizzazione e non hanno pausa automatica.
- Le calorie usano il MET interpolato sulla velocita' media, non un valore fisso per tipo: `CardioActivity.caloriesFor`. Passa sempre da li', cosi' tracker, pannello e inserimento manuale restano coerenti.
- Una sessione puo' essere registrata a posteriori da `ManualCardioEntryScreen`: in quel caso la data la sceglie l'utente e non esiste alcun percorso.

## Gamification, Record E Livelli

- La logica di XP, livelli, trofei e record vive in `lib/features/profile/domain/services/`, divisa in quattro pezzi indipendenti:
  - `athlete_metrics.dart` scorre una volta sola sessioni, set e cardio e ne ricava i numeri (`AthleteMetrics`);
  - `achievement_catalog.dart` e' l'elenco dei trofei: ognuno dichiara con `metric` quale numero guarda;
  - `athlete_level.dart` trasforma metriche e trofei sbloccati in XP e livello;
  - `personal_records.dart` traduce le metriche nelle schede dei primati.
  `athlete_progress_service.dart` li mette in fila e basta.
- Per aggiungere un trofeo aggiungi una voce al catalogo. Se misura qualcosa che non esiste ancora, aggiungi prima il valore ad `AthleteMetric`: il `switch` di `valueOf` non compila finche' non lo gestisci, quindi non puo' restare a zero per sbaglio.
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
- Per cambiamenti a trofei, livelli o record, tocca il file che riguarda quel pezzo (catalogo, metriche, livello o record) e il suo test mirato in `test/features/profile/domain/services/`.
- Per cambiamenti database, aggiorna schema, comportamento di migrazione e qualsiasi seed data toccato dalla feature.
- Per cambiamenti alla dependency injection, rigenera l'output Injectable prima di chiudere il lavoro.

## Flusso Consigliato Per Gli Agenti

1. Leggi `pubspec.yaml`, `lib/main.dart` e la cartella feature rilevante prima di modificare codice.
2. Verifica se il task tocca sorgenti che generano codice, come tabelle Drift, moduli Injectable o modelli Freezed.
3. Esegui modifiche mirate nella feature proprietaria.
4. Se serve generazione, accumula le modifiche correlate e rigenera il codice una sola volta a fine batch.
5. Esegui test mirati rispetto all'area modificata; non eseguire `flutter analyze` automaticamente.
6. Riassumi gli eventuali rischi residui, soprattutto intorno a Firebase, routing e migrazioni database.
