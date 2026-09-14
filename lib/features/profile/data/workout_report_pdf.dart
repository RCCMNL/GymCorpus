import 'dart:typed_data';

import 'package:gym_corpus/features/profile/domain/workout_report.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Palette del report, adattata alla carta.
///
/// Il navy e il lavanda sono quelli dell'app, ma su bianco il lavanda
/// #94AAFF non regge come colore di testo: per i titoli si usa l'indigo
/// piu' profondo che nell'app fa da primaryContainer, tenendo il lavanda
/// per i filetti e le fasce.
class _ReportPalette {
  static const navy = PdfColor.fromInt(0xFF08082F);
  static const indigo = PdfColor.fromInt(0xFF3738A1);
  static const lavender = PdfColor.fromInt(0xFF94AAFF);
  static const mint = PdfColor.fromInt(0xFFB5FFC2);
  static const ink = PdfColor.fromInt(0xFF1B1C2E);
  static const muted = PdfColor.fromInt(0xFF6C6F8A);
  static const hairline = PdfColor.fromInt(0xFFE2E3EE);
  static const zebra = PdfColor.fromInt(0xFFF5F6FB);
}

/// Impagina il report allenamenti.
///
/// Prima il PDF era il default assoluto della libreria: nessun colore,
/// nessun logo, "Fine del Report" come chiusura. E' l'unico artefatto
/// dell'app che l'utente puo' salvare e mandare a qualcun altro, quindi
/// era anche l'unico posto in cui GymCorpus non si riconosceva.
Future<Uint8List> buildWorkoutReportPdf({
  required WorkoutReportData data,
  Uint8List? logoBytes,
}) async {
  final document = pw.Document(
    title: 'GymCorpus - Report allenamenti',
    author: 'GymCorpus',
  );
  final logo = logoBytes == null ? null : pw.MemoryImage(logoBytes);

  document.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 0, 36, 36),
        theme: pw.ThemeData.withFont().copyWith(
          defaultTextStyle: const pw.TextStyle(
            color: _ReportPalette.ink,
            fontSize: 10,
          ),
        ),
      ),
      header: (context) =>
          context.pageNumber == 1 ? _brandBand(logo) : _runningHeader(),
      footer: _footer,
      build: (context) => [
        pw.SizedBox(height: 24),
        pw.Text(
          'Generato il ${data.generatedAt}',
          style: const pw.TextStyle(color: _ReportPalette.muted, fontSize: 9),
        ),
        pw.SizedBox(height: 20),
        _summaryRow(data),
        pw.SizedBox(height: 28),
        _sectionTitle('Serie registrate'),
        pw.SizedBox(height: 10),
        if (data.hasData) _setsTable(data) else _emptyState(),
      ],
    ),
  );

  return document.save();
}

/// Fascia navy a tutta larghezza con simbolo e wordmark: e' la prima
/// cosa che si vede aprendo il file, e l'unica che dice di chi e'.
pw.Widget _brandBand(pw.MemoryImage? logo) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.fromLTRB(28, 26, 28, 24),
    margin: const pw.EdgeInsets.only(bottom: 4),
    decoration: const pw.BoxDecoration(color: _ReportPalette.navy),
    child: pw.Row(
      children: [
        if (logo != null) ...[
          // Il simbolo e' navy: sulla fascia navy sparirebbe. Sta su una
          // piastrella chiara, come l'icona dell'app.
          pw.Container(
            width: 52,
            height: 52,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Image(logo),
          ),
          pw.SizedBox(width: 16),
        ],
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'GYM CORPUS',
              style: pw.TextStyle(
                color: _ReportPalette.lavender,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Report allenamenti',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Dalla seconda pagina basta un filetto: ripetere la fascia intera
/// sprecherebbe un quarto di pagina ad ogni foglio.
pw.Widget _runningHeader() {
  return pw.Container(
    padding: const pw.EdgeInsets.only(top: 24, bottom: 8),
    margin: const pw.EdgeInsets.only(bottom: 16),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _ReportPalette.hairline)),
    ),
    // I font PDF integrati coprono Latin-1, quindi accenti e simbolo di
    // grado nei nomi degli esercizi vengono resi correttamente (provato
    // con "Pressa 45°" e "Perché Però Città"), ma niente oltre: qui si
    // resta su una barra invece di un separatore tipografico.
    child: pw.Text(
      'GYM CORPUS  /  REPORT ALLENAMENTI',
      style: pw.TextStyle(
        color: _ReportPalette.muted,
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
        letterSpacing: 1.5,
      ),
    ),
  );
}

pw.Widget _footer(pw.Context context) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(top: 12),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: _ReportPalette.hairline)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Generato con GymCorpus',
          style: const pw.TextStyle(color: _ReportPalette.muted, fontSize: 8),
        ),
        pw.Text(
          '${context.pageNumber} / ${context.pagesCount}',
          style: const pw.TextStyle(color: _ReportPalette.muted, fontSize: 8),
        ),
      ],
    ),
  );
}

pw.Widget _sectionTitle(String text) {
  return pw.Row(
    children: [
      pw.Container(width: 3, height: 14, color: _ReportPalette.lavender),
      pw.SizedBox(width: 8),
      pw.Text(
        text.toUpperCase(),
        style: pw.TextStyle(
          color: _ReportPalette.indigo,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    ],
  );
}

pw.Widget _summaryRow(WorkoutReportData data) {
  return pw.Row(
    children: [
      pw.Expanded(
        child: _summaryCard(
          'Allenamenti completati',
          '${data.completedWorkouts}',
        ),
      ),
      pw.SizedBox(width: 12),
      pw.Expanded(
        child: _summaryCard('Serie registrate', '${data.loggedSets}'),
      ),
      pw.SizedBox(width: 12),
      pw.Expanded(child: _summaryCard('Volume totale', data.totalVolume)),
    ],
  );
}

pw.Widget _summaryCard(String label, String value) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      color: _ReportPalette.zebra,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: _ReportPalette.hairline),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(
            color: _ReportPalette.muted,
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: _ReportPalette.navy,
            fontSize: 17,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _setsTable(WorkoutReportData data) {
  return pw.TableHelper.fromTextArray(
    headers: WorkoutReportData.columns,
    data: [for (final row in data.rows) row.cells],
    border: null,
    headerDecoration: const pw.BoxDecoration(color: _ReportPalette.navy),
    headerHeight: 28,
    cellHeight: 24,
    headerStyle: pw.TextStyle(
      color: PdfColors.white,
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
      letterSpacing: 1,
    ),
    cellStyle: const pw.TextStyle(color: _ReportPalette.ink, fontSize: 9),
    oddRowDecoration: const pw.BoxDecoration(color: _ReportPalette.zebra),
    cellAlignments: {
      0: pw.Alignment.centerLeft,
      1: pw.Alignment.centerLeft,
      2: pw.Alignment.centerRight,
      3: pw.Alignment.centerRight,
    },
    columnWidths: {
      0: const pw.FlexColumnWidth(2.2),
      1: const pw.FlexColumnWidth(4.5),
      2: const pw.FlexColumnWidth(2),
      3: const pw.FlexColumnWidth(1.8),
    },
  );
}

pw.Widget _emptyState() {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(vertical: 28, horizontal: 20),
    decoration: pw.BoxDecoration(
      color: _ReportPalette.zebra,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: _ReportPalette.hairline),
    ),
    child: pw.Column(
      children: [
        pw.Container(width: 28, height: 3, color: _ReportPalette.mint),
        pw.SizedBox(height: 12),
        pw.Text(
          'Nessuna serie registrata',
          style: pw.TextStyle(
            color: _ReportPalette.navy,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Completa un allenamento e il riepilogo comparirà qui.',
          style: const pw.TextStyle(color: _ReportPalette.muted, fontSize: 9),
        ),
      ],
    ),
  );
}
