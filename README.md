# ⚡ GymCorpus

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg?style=for-the-badge)](LICENSE)

**GymCorpus** è un'applicazione di fitness all'avanguardia progettata per massimizzare le performance atletiche attraverso un tracciamento granulare, un'interfaccia premium e meccaniche di gamification.

---

## ✨ Caratteristiche Principali

- 🚀 **Dashboard Dinamica**: Visualizzazione immediata di XP, Livello e Progressi tramite un'interfaccia ispirata al mondo dei videogame.
- 🏋️ **Gestione Esercizi**: Libreria completa di esercizi con ricerca avanzata, filtri per gruppi muscolari e attrezzatura.
- 📋 **Routine Personalizzate**: Creazione e gestione di workout su misura con editing rapido delle serie (Sets/Reps).
- 🌓 **Design Premium**: Due stati dominanti (Profilo/Impostazioni) con animazioni fluide (`AnimatedCrossFade`) e palette colori curata.
- 📊 **Precisione Metrica**: Conversione automatica tra sistema metrico (KG) e imperiale (LB).
- ☁️ **Cloud Sync**: Integrazione con Firebase per l'autenticazione sicura (Google/Apple) e sincronizzazione dati.

---

## 🛠️ Stack Tecnologico

- **Frontend**: [Flutter](https://flutter.dev) (Clean Architecture)
- **State Management**: [Flutter Bloc](https://pub.dev/packages/flutter_bloc)
- **Database Locale**: [Drift](https://drift.simonbinder.eu/) (SQLite)
- **Autenticazione**: Firebase Auth
- **Navigazione**: [GoRouter](https://pub.dev/packages/go_router)
- **UI Components**: Custom Paint (Radial Pickers), ShaderMask Gradients, Google Fonts (Lexend/Inter).

---

## 📂 Struttura del Progetto

```text
lib/
├── core/               # Layout comuni, costanti, temi e widget globali
├── features/           # Architettura suddivisa per funzionalità (Clean)
│   ├── auth/           # Login, Sign-up, Social Auth
│   ├── training/       # Routine, Esercizi, Workout Logger
│   └── profile/        # Statistiche, Impostazioni, Gamification
├── injection.dart      # Service Locator (GetIt/Injectable)
└── main.dart           # Entry point
```

---

## 🚀 Guida all'Installazione

1. **Prerequisiti**:
   - Flutter SDK (>= 3.0.0)
   - Android Studio / Xcode

2. **Clona il repository**:
   ```bash
   git clone https://github.com/tuo-username/gym_corpus.git
   ```

3. **Installa le dipendenze**:
   ```bash
   flutter pub get
   ```

4. **Generazione Codice**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Avvia l'app**:
   ```bash
   flutter run
   ```

---

## 📦 Build Release (APK)

Per generare la versione finale per Android:
```bash
flutter build apk --release
```
Il file sarà disponibile in: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📄 Licenza

Distribuito sotto Licenza MIT. Vedi `LICENSE` per maggiori informazioni.

---

## 📧 Contatti
- **Email**: riccardiemanuele2016@outlook.it
- **LinkedIn**: [Emanuele Riccardi](https://www.linkedin.com/in/emanuele-riccardi-5819b422a/)
- **Portfolio**: https://portfolio-riccardiemanuele.vercel.app/
- **GitHub**: [@RCCMNL](https://github.com/RCCMNL/)


<p align="center">
  Sviluppato con ❤️ per la Community Fitness
</p>
