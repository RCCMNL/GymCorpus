import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Apre un indirizzo fuori dall'app.
///
/// Esiste come servizio, e non come chiamata diretta a `launchUrl`, perche'
/// e' un confine con il mondo: chi lo attraversa deve poter essere provato
/// senza che si apra davvero un browser.
// Un solo metodo, ma resta un'interfaccia e non una funzione: e' proprio
// il poterla sostituire che la rende utile.
// ignore: one_member_abstracts
abstract class ExternalLinks {
  /// Apre [url] nell'app che lo gestisce. Restituisce `false` se il
  /// dispositivo non sa dove mandarlo, o se l'indirizzo non e' valido.
  Future<bool> open(String url);
}

class UrlLauncherLinks implements ExternalLinks {
  const UrlLauncherLinks();

  @override
  Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object catch (error) {
      debugPrint('Non riesco ad aprire $url: $error');
      return false;
    }
  }
}
