import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/constants/app_constants.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback() async {
    final subject = _subjectController.text.trim();
    final description = _descriptionController.text.trim();

    if (subject.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore, compila tutti i campi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthBloc>().state;
      final user = authState.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );

      final deviceInfo = DeviceInfoPlugin();
      String deviceModel = '';
      String osVersion = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceModel = androidInfo.model;
        osVersion = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceModel = iosInfo.utsname.machine;
        osVersion = 'iOS ${iosInfo.systemVersion}';
      }

      // Salvataggio su Firestore
      // Struttura compatibile con l'estensione "Trigger Email"
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'to': AppConstants.supportEmail,
        'message': {
          'subject': '[GYMCORPUS] Segnalazione: $subject',
          'html': '''
            <h3>Nuova segnalazione da GymCorpus</h3>
            <p><strong>Utente:</strong> ${user?.fullName ?? 'Anonimo'} (${user?.email ?? 'N/D'})</p>
            <p><strong>Oggetto:</strong> $subject</p>
            <p><strong>Descrizione:</strong><br>$description</p>
            <hr>
            <p><strong>Dati Dispositivo:</strong></p>
            <ul>
              <li>Modello: $deviceModel</li>
              <li>OS: $osVersion</li>
              <li>App Version: 1.0.0</li>
              <li>User ID: ${user?.uid ?? 'N/D'}</li>
            </ul>
          ''',
        },
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user?.uid,
        'metadata': {
          'device': deviceModel,
          'os': osVersion,
          'subject': subject,
        }
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Segnalazione inviata con successo!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante l\'invio: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surface,
      title: Row(
        children: [
          Icon(Icons.bug_report_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Segnala un Problema',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Oggetto',
                hintText: 'Esempio: Errore nel salvataggio peso',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Descrizione',
                hintText: 'Cosa è successo? Come possiamo riprodurre il problema?',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ANNULLA'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendFeedback,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('INVIA SEGNALAZIONE'),
        ),
      ],
    );
  }
}
