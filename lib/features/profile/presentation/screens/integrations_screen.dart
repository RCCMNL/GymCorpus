import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/core/widgets/section_title.dart';
import 'package:gym_corpus/features/training/domain/repositories/training_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class IntegrationsScreen extends StatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  State<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends State<IntegrationsScreen> {
  bool _isHealthSyncEnabled = false;
  bool _isExporting = false;

  Future<void> _exportAsJson() async {
    setState(() => _isExporting = true);
    try {
      // GetIt, non context.read: TrainingRepository e' registrato solo nel
      // service locator, mai esposto tramite RepositoryProvider nell'albero
      // dei widget. context.read<TrainingRepository>() lanciava sempre
      // ProviderNotFoundException, catturata dal catch generico qui sotto e
      // mostrata come errore vago: l'export non ha mai funzionato.
      final repository = GetIt.I<TrainingRepository>();
      // Get data (simplified)
      final routines = await repository.watchRoutines().first;
      final weightLogs = await repository.watchWeightLogs().first;

      final data = {
        'export_date': DateTime.now().toIso8601String(),
        'routines_count': routines.length,
        'weight_logs': weightLogs
            .map(
              (l) => {
                'date': l.timestamp.toIso8601String(),
                'weight': l.weight,
                'reps': l.reps,
              },
            )
            .toList(),
      };

      final jsonString = jsonEncode(data);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/gym_corpus_export.json');
      await file.writeAsString(jsonString);

      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Esportazione dati GymCorpus');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore durante l'esportazione: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportAsPdf() async {
    setState(() => _isExporting = true);
    try {
      final pdf = pw.Document();
      final repository = GetIt.I<TrainingRepository>();
      final weightLogs = await repository.watchWeightLogs().first;

      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'GymCorpus - Report Allenamenti',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Report generato il ${DateTime.now()}'),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Riepilogo Recente',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                context: context,
                data: [
                  ['Data', 'Peso (kg)', 'Ripetizioni'],
                  for (final l in weightLogs.take(20))
                    [
                      l.timestamp.toIso8601String().split('T')[0],
                      l.weight.toString(),
                      l.reps.toString(),
                    ],
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Center(
                child: pw.Text(
                  'Fine del Report',
                  style: const pw.TextStyle(color: PdfColors.grey),
                ),
              ),
            ];
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'gym_corpus_report.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore durante l'esportazione PDF: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Integrazioni',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 32),
              SectionTitle(
                'SALUTE (IN SVILUPPO)',
                color: theme.colorScheme.outline,
                letterSpacing: 2,
              ),
              const SizedBox(height: 12),
              _buildIntegrationItem(
                icon: Icons.health_and_safety_outlined,
                label: 'Apple Health / Google Fit',
                subtitle: 'Sincronizza passi e calorie',
                trailing: Switch(
                  value: _isHealthSyncEnabled,
                  onChanged: (v) => setState(() => _isHealthSyncEnabled = v),
                  activeThumbColor: theme.colorScheme.primary,
                ),
                theme: theme,
              ),
              const SizedBox(height: 32),
              SectionTitle(
                'ESPORTAZIONE DATI',
                color: theme.colorScheme.outline,
                letterSpacing: 2,
              ),
              const SizedBox(height: 12),
              _buildIntegrationItem(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Esporta Report PDF',
                subtitle: 'Report visuale curato',
                onTap: _isExporting ? null : _exportAsPdf,
                theme: theme,
              ),
              _buildIntegrationItem(
                icon: Icons.code,
                label: 'Esporta Raw Data (JSON)',
                subtitle: 'Per backup dati personali',
                onTap: _isExporting ? null : _exportAsJson,
                theme: theme,
              ),
              if (_isExporting) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Generazione file in corso...',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              const SizedBox(height: 48),
              SectionTitle(
                'GDPR COMPLIANCE',
                color: theme.colorScheme.outline,
                letterSpacing: 2,
              ),
              const SizedBox(height: 12),
              Text(
                'I tuoi dati sono protetti e appartengono a te. Puoi scaricarli o eliminare il tuo account in qualsiasi momento dalla sezione Sicurezza.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntegrationItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required ThemeData theme,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
