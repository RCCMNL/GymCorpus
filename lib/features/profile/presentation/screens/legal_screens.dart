import 'package:flutter/material.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({required this.title, required this.sections, required this.icon, super.key});
  final String title;
  final IconData icon;
  final List<LegalSection> sections;

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Lexend')), centerTitle: true),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          itemCount: widget.sections.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                      theme.colorScheme.tertiary.withValues(alpha: 0.08),
                    ]),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                      child: Icon(widget.icon, color: theme.colorScheme.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ShaderMask(
                        shaderCallback: (b) => LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.tertiary]).createShader(b),
                        child: Text(widget.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend', color: Colors.white)),
                      ),
                      const SizedBox(height: 4),
                      Text('Ultimo aggiornamento: Aprile 2026', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, fontWeight: FontWeight.w500)),
                    ])),
                  ]),
                ),
              );
            }
            final section = widget.sections[index - 1];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 400 + index * 60),
              curve: Curves.easeOutCubic,
              builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 12 * (1 - v)), child: child)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.06)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [theme.colorScheme.primary, theme.colorScheme.tertiary]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text('$index', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, fontFamily: 'Lexend'))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(section.title.replaceFirst(RegExp(r'^\d+\.\s*'), ''), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.primary, fontFamily: 'Lexend')),
                      const SizedBox(height: 8),
                      Text(section.content, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6, color: theme.colorScheme.onSurface.withValues(alpha: 0.75))),
                    ])),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LegalSection {
  const LegalSection({required this.title, required this.content});
  final String title;
  final String content;
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const LegalScreen(title: 'Privacy Policy', icon: Icons.privacy_tip_rounded, sections: [
      LegalSection(title: '1. Informazioni Generali', content: 'Benvenuto in GymCorpus. La tua privacy e importante per noi. Questa informativa spiega quali dati trattiamo, perche li usiamo e quali controlli hai sul tuo account.'),
      LegalSection(title: '2. Dati Raccolti', content: 'Raccogliamo i dati necessari alla registrazione e al profilo: nome, cognome, username, email, data di nascita, genere e, se li inserisci, peso, altezza e obiettivi. L app registra anche allenamenti, set, cardio, routine, record, livelli e badge per mostrarti progressi e statistiche.'),
      LegalSection(title: '3. Utilizzo dei Dati', content: 'Usiamo i dati per autenticarti, salvare il profilo, mostrare storico allenamenti, calcolare statistiche, record personali, livelli e trofei. Non vendiamo i tuoi dati a terze parti. Marketing e profilazione commerciale richiedono consensi separati e facoltativi.'),
      LegalSection(title: '4. Servizi Tecnici', content: 'Usiamo Firebase Auth per l autenticazione e Cloud Firestore per il profilo remoto quando disponibile. Il database degli allenamenti e gestito localmente sul dispositivo tramite SQLite/Drift, con approccio local-first.'),
      LegalSection(title: '5. Sicurezza', content: 'Adottiamo misure ragionevoli per proteggere account e dati. Nessun sistema connesso a Internet puo pero essere considerato sicuro al 100%, quindi ti invitiamo a usare una password robusta e a proteggere il dispositivo.'),
      LegalSection(title: '6. I Tuoi Diritti', content: 'Puoi aggiornare i dati del profilo e cancellare l account dalle impostazioni dell app. Puoi anche revocare i consensi facoltativi quando introdurremo preferenze dedicate per marketing e profilazione.'),
    ]);
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const LegalScreen(title: 'Termini di Servizio', icon: Icons.gavel_rounded, sections: [
      LegalSection(title: '1. Accettazione dei Termini', content: 'Creando un account o usando GymCorpus accetti questi Termini. Se non li accetti, non creare un account e non usare l app.'),
      LegalSection(title: '2. Disclaimer Medico', content: 'GymCorpus non fornisce consulenza medica, diagnosi o programmi sanitari personalizzati. Consulta un medico o un professionista qualificato prima di iniziare un nuovo programma di allenamento. L uso dell app e sotto la tua responsabilita.'),
      LegalSection(title: "3. Utilizzo dell'Account", content: 'Sei responsabile della riservatezza delle credenziali e dell uso del tuo account. Non usare l app per attivita illegali, abusive, fraudolente o per compromettere servizi, dati o altri utenti.'),
      LegalSection(title: '4. Contenuti e Proprieta Intellettuale', content: 'Design, testi, logiche, esercizi, schermate e contenuti dell app appartengono ai rispettivi titolari. Puoi usare GymCorpus per finalita personali e non puoi copiare, rivendere o distribuire parti dell app senza autorizzazione.'),
      LegalSection(title: '5. Pagamenti e Abbonamenti', content: 'Al momento GymCorpus non gestisce acquisti o abbonamenti in app. Se in futuro verranno introdotti servizi a pagamento, mostreremo condizioni specifiche su prezzi, rinnovi, cancellazioni e rimborsi prima dell acquisto.'),
      LegalSection(title: '6. Modifiche al Servizio', content: 'Possiamo aggiornare o interrompere funzionalita dell app, inclusi tracking, statistiche, badge, livelli e record. Le modifiche importanti ai Termini saranno comunicate in modo adeguato.'),
      LegalSection(title: '7. Limitazione di Responsabilita', content: 'Nei limiti consentiti dalla legge, GymCorpus non risponde di danni indiretti, incidentali o consequenziali derivanti dall uso improprio dell app, da dati inseriti in modo errato o dall impossibilita temporanea di usare il servizio.'),
    ]);
  }
}

class CookiePolicyScreen extends StatelessWidget {
  const CookiePolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const LegalScreen(title: 'Cookie Policy', icon: Icons.cookie_rounded, sections: [
      LegalSection(title: '1. App Mobile', content: 'GymCorpus e attualmente una app mobile Flutter per Android e iOS. Non assumiamo supporto web o desktop e non usiamo cookie di profilazione nella registrazione o nel login mobile.'),
      LegalSection(title: '2. Tecnologie Tecniche Necessarie', content: 'Per far funzionare login, sicurezza, sessione utente e salvataggio locale possono essere usati identificativi tecnici, Firebase Auth, cache locale e database SQLite/Drift. Questi elementi sono necessari per erogare il servizio e non richiedono un consenso separato.'),
      LegalSection(title: '3. Statistiche e Marketing', content: 'Se in futuro verranno introdotti strumenti di analytics, marketing, newsletter o profilazione commerciale non necessari, chiederemo un consenso separato, specifico e non preselezionato.'),
      LegalSection(title: '4. Revoca dei Consensi', content: 'I consensi facoltativi devono poter essere modificati o revocati. La registrazione salva separatamente consenso marketing e consenso alla profilazione, cosi da poterli gestire in modo granulare nelle impostazioni profilo.'),
    ]);
  }
}
