/// Legge un numero decimale scritto a mano in un campo di testo.
///
/// Sulla tastiera italiana il separatore e' la virgola, ma `double.parse`
/// vuole il punto: la stessa `replaceAll(',', '.')` era ripetuta in nove
/// punti dell'app, ogni volta accanto a un `double.tryParse`. Ritorna
/// `null` quando il testo non e' un numero, che per tutti quei campi
/// significa "lascia le cose come stanno".
double? parseDecimalInput(String text) {
  return double.tryParse(text.trim().replaceAll(',', '.'));
}
