/// Raggruppa i nove gruppi muscolari del catalogo per pattern di
/// movimento. Serve al segnaposto degli esercizi privi di foto: la
/// tinta della miniatura codifica cosi' un'informazione reale (che tipo
/// di movimento e') invece di essere decorazione arbitraria, e rende la
/// lista scandagliabile a colpo d'occhio.
enum MuscleRegion {
  /// Petto, Spalle, Tricipiti.
  spinta,

  /// Dorso, Bicipiti, Avambracci.
  trazione,

  /// Gambe, Polpacci.
  gambe,

  /// Addominali.
  core,
}

const Map<String, MuscleRegion> _regionByMuscle = {
  'Petto': MuscleRegion.spinta,
  'Spalle': MuscleRegion.spinta,
  'Tricipiti': MuscleRegion.spinta,
  'Dorso': MuscleRegion.trazione,
  'Bicipiti': MuscleRegion.trazione,
  'Avambracci': MuscleRegion.trazione,
  'Gambe': MuscleRegion.gambe,
  'Polpacci': MuscleRegion.gambe,
  'Addominali': MuscleRegion.core,
};

/// Regione di [targetMuscle]. Il confronto ignora maiuscole e spazi ai
/// lati perche' i nomi arrivano anche dagli esercizi custom dell'utente.
/// Un gruppo sconosciuto ricade su [MuscleRegion.spinta], la tinta
/// primaria dell'app: un colore neutro e' preferibile a un segnaposto
/// senza tinta, che tornerebbe a sembrare un errore di caricamento.
MuscleRegion muscleRegionFor(String targetMuscle) {
  final normalized = targetMuscle.trim().toLowerCase();
  for (final entry in _regionByMuscle.entries) {
    if (entry.key.toLowerCase() == normalized) return entry.value;
  }
  return MuscleRegion.spinta;
}
