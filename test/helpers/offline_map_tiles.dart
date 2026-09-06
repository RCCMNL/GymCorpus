import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// PNG trasparente 1x1, usato al posto delle tile scaricate da OpenStreetMap.
final _transparentTile = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAALSURBVBhXY2AAAgAABQABqtXIUQAAAABJRU5ErkJggg==',
);

class _MockHttpClient extends Mock implements HttpClient {}

class _MockHttpClientRequest extends Mock implements HttpClientRequest {}

class _MockHttpClientResponse extends Mock implements HttpClientResponse {}

class _MockHttpHeaders extends Mock implements HttpHeaders {}

class _OfflineTileOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = _MockHttpClient();
    final request = _MockHttpClientRequest();
    final response = _MockHttpClientResponse();
    final headers = _MockHttpHeaders();

    when(
      () => client.openUrl(any(), any()),
    ).thenAnswer((_) async => request);
    when(() => request.headers).thenReturn(headers);
    // La richiesta viene "pipata": prima lo stream del corpo, poi la
    // chiusura. Senza questo stub addStream restituisce null dove il
    // chiamante attende un Future.
    when(() => request.addStream(any())).thenAnswer((_) async {});
    when(() => request.done).thenAnswer((_) async => response);
    when(request.close).thenAnswer((_) async => response);
    when(() => response.statusCode).thenReturn(HttpStatus.ok);
    when(() => response.reasonPhrase).thenReturn('OK');
    when(() => response.contentLength).thenReturn(_transparentTile.length);
    when(() => response.isRedirect).thenReturn(false);
    when(() => response.redirects).thenReturn(const []);
    when(() => response.persistentConnection).thenReturn(false);
    when(
      () => response.compressionState,
    ).thenReturn(HttpClientResponseCompressionState.notCompressed);
    when(() => response.headers).thenReturn(headers);
    when(
      () => response.listen(
        any(),
        onError: any(named: 'onError'),
        onDone: any(named: 'onDone'),
        cancelOnError: any(named: 'cancelOnError'),
      ),
    ).thenAnswer((invocation) {
      final onData =
          invocation.positionalArguments.first as void Function(List<int>);
      final onDone = invocation.namedArguments[#onDone] as void Function()?;

      return Stream<List<int>>.value(
        _transparentTile,
      ).listen(onData, onDone: onDone);
    });

    return client;
  }
}

/// Serve tile di mappa finte per la durata del gruppo di test corrente.
///
/// I widget con una mappa scaricano davvero le tile da OpenStreetMap: nei
/// test la richiesta fallisce con 400 e l'eccezione asincrona fa cadere la
/// prova, anche quando la mappa non c'entra nulla con cio' che si verifica.
void useOfflineMapTiles() {
  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(const Stream<List<int>>.empty());
    HttpOverrides.global = _OfflineTileOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });
}
