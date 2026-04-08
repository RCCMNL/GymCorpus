# Changelog

Tutti i cambiamenti significativi a questo progetto saranno documentati in questo file.

## [1.0.0+1] - 2026-04-09

### Aggiunto
- **Refactoring Profilo**: Implementata la vista a due stati (Profilo/Impostazioni) con `AnimatedCrossFade`.
- **UI/UX Esercizi**: Risolti i problemi di overflow e aggiunta barra di ricerca colorata.
- **GymHeader**: Sostituita l'icona impostazioni con quella delle notifiche e aggiunto logo dinamico.
- **Supporto Metrico**: Implementata conversione KG/LB in tempo reale nei workout.
- **SnackBars**: Nuovo design premium per le notifiche in-app.
- **Documentazione**: Aggiunto README professionale, LICENSE e .gitignore avanzato.

### Modificato
- Rinominata sezione "Abbonamento" in "Gestione pagamenti" nel menu Impostazioni.
- Icone e testi dei menu aggiornati con stile `Rounded` e font `Lexend`.

### Sicurezza
- Aggiornato `.gitignore` per escludere chiavi e configurazioni sensibili.
- Implementata pulizia automatica dei controller nelle schermate di editing.
