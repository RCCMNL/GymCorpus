# Cloud Sync Plan

## Obiettivo

Permettere a un utente che cambia telefono o reinstalla l'app di recuperare tutti i propri dati senza perdita di informazioni, mantenendo l'architettura `local-first` attuale.

## Principi

- `Drift/SQLite` resta la fonte locale usata dalla UI.
- `Firestore` diventa il backup/sync store per utente.
- `Firebase Auth` continua a gestire identita' e accesso.
- I dati derivati come livelli, trofei e record non devono essere la fonte primaria remota: vanno ricalcolati dai dati base.

## Dati Da Sincronizzare

Minimo indispensabile:

- `Workouts`
- `WorkoutSets`
- `Routines`
- `RoutineExercises`
- `WeightLogs`
- `BodyMeasurements`
- `CardioSessions`
- `AppSettings`
- preferiti e note utente sugli esercizi

Non necessari come fonte primaria:

- livelli
- trofei
- record

## Struttura Firestore Proposta

Sottocollezioni sotto `users/{uid}`:

- `users/{uid}/workouts/{workoutId}`
- `users/{uid}/workoutSets/{setId}`
- `users/{uid}/routines/{routineId}`
- `users/{uid}/routineExercises/{routineExerciseId}`
- `users/{uid}/weightLogs/{weightLogId}`
- `users/{uid}/bodyMeasurements/{measurementId}`
- `users/{uid}/cardioSessions/{cardioSessionId}`
- `users/{uid}/settings/{key}`
- `users/{uid}/exercisePrefs/{exerciseId}`

## Campi Comuni Dei Documenti Remoti

Ogni documento remoto dovrebbe avere:

- `id`
- `ownerId`
- `schemaVersion`
- `createdAt`
- `updatedAt`
- `deletedAt` nullable
- `sourceDeviceId` opzionale

## Esempio Documento Workout

```json
{
  "id": "w_01JABC...",
  "ownerId": "firebase_uid",
  "schemaVersion": 1,
  "createdAt": "2026-05-02T10:10:00Z",
  "updatedAt": "2026-05-02T10:45:00Z",
  "deletedAt": null,
  "date": "2026-05-02T10:10:00Z",
  "name": "Push Day",
  "routineId": "r_01JDEF...",
  "completedAt": "2026-05-02T10:45:00Z",
  "durationSeconds": 2100
}
```

## Gestione Identificatori

Problema attuale:

- molte tabelle locali usano `autoIncrement()`

Direzione consigliata:

- mantenere l'`id` locale per Drift
- aggiungere un `remoteId` stringa stabile per il sync cloud

Questo riduce il rischio di refactor invasivi immediati.

## Flusso Dati

Quando l'utente modifica qualcosa:

1. scrittura immediata in locale
2. record marcato come `pendingSync`
3. sync worker invia il record a Firestore
4. dopo conferma remota il record passa a `synced`

Quando l'utente apre l'app su un nuovo device:

1. login Firebase
2. caricamento profilo
3. verifica del DB locale
4. download dei dati cloud
5. ricostruzione del DB locale
6. ricalcolo progressi, trofei e record

## Metadati Locali Da Aggiungere

Per ogni tabella sincronizzata:

- `remoteId`
- `updatedAt`
- `deletedAt`
- `syncStatus`
- opzionalmente `lastSyncedAt`

Valori iniziali di `syncStatus`:

- `synced`
- `pendingCreate`
- `pendingUpdate`
- `pendingDelete`

## Strategia Conflitti

Prima versione:

- `last write wins` usando `updatedAt`

Motivo:

- semplice da implementare
- adatta alla fase attuale del progetto

## Strategia Migrazioni Future

Ogni documento remoto deve avere `schemaVersion`.

Quando lo schema cambia:

1. il parser remoto legge sia il formato vecchio sia quello nuovo
2. se trova un record vecchio, lo converte in memoria
3. al prossimo sync il documento viene riscritto nel nuovo formato

Questo permette di evolvere il modello senza perdere compatibilita' durante lo sviluppo.

## Ordine Di Implementazione Consigliato

### 1. Infrastruttura Sync Base

- remote models
- remote data sources
- metadata di sync locale
- bootstrap dopo login

### 2. Sync Entita' Critiche

- `Workouts`
- `WorkoutSets`
- `Routines`
- `RoutineExercises`

### 3. Sync Salute E Progressi

- `WeightLogs`
- `BodyMeasurements`
- `CardioSessions`

### 4. Sync Preferenze Utente

- `AppSettings`
- preferiti esercizi
- note esercizi

### 5. Hardening

- gestione cancellazioni
- sync incrementale
- retry/offline queue

## Struttura Codice Proposta

Possibili nuove aree:

- `lib/core/sync/`
- `lib/features/training/data/datasources/training_remote_data_source.dart`
- `lib/features/training/data/models/remote/`
- `lib/features/training/data/services/training_sync_service.dart`

Per auth/profile:

- riuso del login esistente
- bootstrap sync dopo autenticazione o `checkSession`

## Rischi Principali

- accoppiare troppo Firestore allo schema SQLite locale
- non gestire le cancellazioni
- non distinguere dati seed statici da dati utente
- sincronizzare dati derivati invece dei dati base

## Primo Milestone Consigliato

Partire da:

- backup/ripristino cloud di `Workouts`
- backup/ripristino cloud di `WorkoutSets`
- backup/ripristino cloud di `Routines`
- backup/ripristino cloud di `RoutineExercises`
- backup/ripristino cloud di `WeightLogs`

## Nota

Questo file descrive solo il piano tecnico e l'ordine dei passi.

Non avvia alcuna implementazione.
