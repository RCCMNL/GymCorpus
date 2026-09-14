/// Dove sta la figura di un esercizio.
///
/// Le figure sono asset nel bundle, non URL: il catalogo e' fisso, si
/// guarda anche senza rete e non costa banda. Il nome del file si ricava
/// dal nome dell'esercizio, cosi' aggiungerne una e' solo copiare il file
/// in `assets/exercises/`, senza toccare i seed.
library;

const _imageFolder = 'assets/exercises';
const _imageExtension = 'webp';

/// Le lettere accentate scritte come la lettera che sono.
const _accents = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ä': 'a',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'ö': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
};

/// Il nome di un esercizio ridotto a nome di file.
///
/// `Distensioni su panca piana (Bilanciere)` diventa
/// `distensioni-su-panca-piana-bilanciere`.
String exerciseImageSlug(String name) {
  final lower = name.toLowerCase();
  final buffer = StringBuffer();

  for (final char in lower.split('')) {
    buffer.write(_accents[char] ?? char);
  }

  return buffer
      .toString()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

/// L'asset della figura di un esercizio, o `null` se il nome non lascia
/// niente da cui ricavare un nome di file.
///
/// Che l'asset esista davvero non lo sa: la figura manca per la gran parte
/// del catalogo, e chi la mostra ha comunque bisogno di un ripiego.
String? exerciseImageAsset(String name) {
  final slug = exerciseImageSlug(name);
  if (slug.isEmpty) return null;
  return '$_imageFolder/$slug.$_imageExtension';
}
