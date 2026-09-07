/// Le due fasi in cui la scheda esercizio divide l'esecuzione.
///
/// Il testo salvato e' un paragrafo unico: la prima frase e' la salita, il
/// resto e' la discesa. Prima questo taglio viveva dentro il `build` come
/// `execution.split('.').length == 2 ? ... : <frase generica>`, e siccome
/// ogni testo del catalogo finisce col punto le parti erano sempre tre, mai
/// due: la discesa vera non e' mai stata mostrata a nessuno.
class ExecutionPhases {
  const ExecutionPhases({this.up, this.down});

  factory ExecutionPhases.fromText(String? execution) {
    final sentences = (execution ?? '')
        .split('.')
        .map((sentence) => sentence.trim())
        .where((sentence) => sentence.isNotEmpty)
        .toList();

    if (sentences.isEmpty) return const ExecutionPhases();

    return ExecutionPhases(
      up: '${sentences.first}.',
      down: sentences.length == 1
          ? null
          : '${sentences.skip(1).join('. ')}.',
    );
  }

  /// La prima frase: come si porta il carico.
  final String? up;

  /// Quello che resta: come si torna indietro.
  final String? down;
}
