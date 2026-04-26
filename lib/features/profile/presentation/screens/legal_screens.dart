import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final List<LegalSection> sections;

  const LegalScreen({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  section.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LegalSection {
  final String title;
  final String content;

  const LegalSection({required this.title, required this.content});
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalScreen(
      title: 'Privacy Policy',
      sections: [
        LegalSection(
          title: '1. Informazioni Generali',
          content: 'Benvenuto in GymCorpus. La tua privacy è estremamente importante per noi. Questa informativa spiega come raccogliamo, utilizziamo e proteggiamo i tuoi dati personali.',
        ),
        LegalSection(
          title: '2. Dati Raccolti',
          content: 'Raccogliamo dati biometrici (peso, altezza, data di nascita) per calcolare i tuoi progressi. Utilizziamo Firebase Auth per l\'autenticazione e Firestore per il backup opzionale dei dati. Tutti gli altri dati sono salvati localmente sul tuo dispositivo.',
        ),
        LegalSection(
          title: '3. Utilizzo dei Dati',
          content: 'I dati vengono utilizzati esclusivamente per fornire le funzionalità di tracking dell\'allenamento e analisi delle performance. Non vendiamo i tuoi dati a terze parti.',
        ),
        LegalSection(
          title: '4. Sicurezza',
          content: 'Adottiamo misure di sicurezza standard del settore per proteggere i tuoi dati. Tuttavia, nessun metodo di trasmissione via Internet è sicuro al 100%.',
        ),
        LegalSection(
          title: '5. I Tuoi Diritti',
          content: 'Puoi cancellare il tuo account e tutti i dati associati in qualsiasi momento dalle impostazioni dell\'app.',
        ),
      ],
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalScreen(
      title: 'Termini di Servizio',
      sections: [
        LegalSection(
          title: '1. Accettazione dei Termini',
          content: 'Utilizzando GymCorpus, accetti di essere vincolato da questi termini. Se non accetti, non utilizzare l\'app.',
        ),
        LegalSection(
          title: '2. Disclaimer Medico',
          content: 'IMPORTANTE: GymCorpus non fornisce consulenza medica. Consulta sempre un medico prima di iniziare un nuovo programma di allenamento. L\'utente si assume la piena responsabilità per eventuali infortuni derivanti dall\'uso dell\'app.',
        ),
        LegalSection(
          title: '3. Utilizzo dell\'Account',
          content: 'Sei responsabile di mantenere la riservatezza delle tue credenziali di accesso. L\'uso dell\'app è personale e non trasferibile.',
        ),
        LegalSection(
          title: '4. Modifiche al Servizio',
          content: 'Ci riserviamo il diritto di modificare o interrompere il servizio in qualsiasi momento. Gli aggiornamenti possono includere nuove funzionalità o la rimozione di quelle esistenti.',
        ),
        LegalSection(
          title: '5. Limitazione di Responsabilità',
          content: 'GymCorpus non sarà responsabile per danni indiretti, incidentali o consequenziali derivanti dall\'uso o dall\'impossibilità di utilizzare l\'app.',
        ),
      ],
    );
  }
}
