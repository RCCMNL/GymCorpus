/// Perche' una sessione all'aperto non puo' partire.
///
/// Sta nel dominio e non conosce geolocator: la schermata traduce il
/// permesso del pacchetto in uno di questi casi, cosi' il messaggio da
/// mostrare non dipende dalla libreria di turno.
enum CardioLocationIssue {
  /// La localizzazione del telefono e' spenta del tutto.
  serviceDisabled,

  /// L'utente ha negato il permesso, ma lo si puo' richiedere ancora.
  permissionDenied,

  /// Permesso negato in modo definitivo: si passa dalle impostazioni.
  permissionDeniedForever,
}
