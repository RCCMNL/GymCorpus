import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';

class _Art {
  const _Art(this.title, this.excerpt, this.body, this.date, this.tag, this.icon, this.color, this.readMin);
  final String title, excerpt, body, date, tag;
  final IconData icon;
  final Color color;
  final int readMin;
}

const _articles = [
  _Art(
    'L importanza delle proteine post-allenamento',
    'Scopri perche assumere proteine entro 30 minuti dal workout e fondamentale per la sintesi proteica muscolare.',
    'Le proteine sono i mattoni fondamentali per la ricostruzione muscolare. Dopo un allenamento intenso, i muscoli presentano micro-lesioni che necessitano di aminoacidi per la riparazione e la crescita.\n\nLa finestra anabolica, ovvero i 30-60 minuti successivi all allenamento, rappresenta il momento ottimale per assumere proteine. In questa fase, il corpo e particolarmente ricettivo agli aminoacidi e li utilizza in modo piu efficiente per la sintesi proteica.\n\nFonti proteiche consigliate post-workout:\n- Whey protein (assorbimento rapido)\n- Uova (profilo aminoacidico completo)\n- Pollo o tacchino (proteine magre)\n- Yogurt greco (proteine + probiotici)\n\nLa dose raccomandata e di 20-40g di proteine post-allenamento, a seconda del peso corporeo e dell intensita dell esercizio.',
    '25 Apr 2026', 'Proteine', Icons.egg_outlined, Color(0xFFFF9494), 5,
  ),
  _Art(
    'Idratazione e performance sportiva',
    'Anche una disidratazione del 2% puo ridurre le prestazioni. Ecco come mantenere l idratazione ottimale.',
    'L idratazione e uno degli aspetti piu sottovalutati della nutrizione sportiva. Il corpo umano e composto per il 60% da acqua, e durante l esercizio fisico si possono perdere fino a 1-2 litri di liquidi all ora attraverso il sudore.\n\nEffetti della disidratazione:\n- Riduzione della forza muscolare del 5-10%\n- Aumento della frequenza cardiaca\n- Diminuzione della concentrazione\n- Maggiore rischio di crampi\n\nLinee guida per l idratazione:\n- 500ml di acqua 2 ore prima dell allenamento\n- 150-250ml ogni 15-20 minuti durante l esercizio\n- 1.5 litri per ogni kg perso dopo l allenamento\n- Integrare con elettroliti per sessioni superiori a 60 minuti',
    '23 Apr 2026', 'Idratazione', Icons.water_drop_outlined, Color(0xFF4ECDC4), 4,
  ),
  _Art(
    'Macronutrienti: la guida completa',
    'Carboidrati, proteine e grassi: come bilanciarli per massimizzare i risultati in palestra.',
    'I macronutrienti sono i tre pilastri della nutrizione sportiva. Ognuno svolge un ruolo specifico e insostituibile.\n\nCarboidrati (4 kcal/g)\nSono la fonte di energia primaria per l esercizio ad alta intensita. Vengono immagazzinati come glicogeno nei muscoli e nel fegato. Fonti: riso, pasta, patate, avena, frutta.\n\nProteine (4 kcal/g)\nEssenziali per la riparazione e la crescita muscolare. Dose consigliata per atleti: 1.6-2.2g per kg di peso corporeo. Fonti: carni magre, pesce, uova, legumi, latticini.\n\nGrassi (9 kcal/g)\nFondamentali per la produzione ormonale (testosterone), l assorbimento delle vitamine liposolubili e come riserva energetica. Fonti: olio d oliva, avocado, frutta secca, pesce grasso.\n\nRipartizione consigliata per sportivi:\n- 45-55% carboidrati\n- 25-35% proteine\n- 20-30% grassi',
    '20 Apr 2026', 'Fondamenti', Icons.pie_chart_outline, Color(0xFFFDE047), 6,
  ),
  _Art(
    '5 Alimenti per il recupero muscolare',
    'Dalla curcuma alle ciliegie, scopri i cibi che accelerano il recupero e riducono l infiammazione.',
    'Il recupero muscolare non dipende solo dal riposo, ma anche dalla qualita degli alimenti che consumiamo.\n\n1. Ciliegie acide - Contengono antociani che riducono l infiammazione muscolare e il dolore post-allenamento (DOMS). Studi mostrano una riduzione del 13% dei markers infiammatori.\n\n2. Curcuma - La curcumina ha potenti proprieta anti-infiammatorie. Assunta con pepe nero (piperina), l assorbimento aumenta del 2000%.\n\n3. Salmone - Ricco di omega-3 (EPA e DHA) che riducono l infiammazione e supportano la sintesi proteica muscolare.\n\n4. Uova - Contengono tutti gli aminoacidi essenziali, vitamina D e colina. Il tuorlo e ricco di nutrienti fondamentali.\n\n5. Patate dolci - Carboidrati complessi per ripristinare il glicogeno, vitamine A e C per il sistema immunitario.',
    '18 Apr 2026', 'Recupero', Icons.healing_outlined, Color(0xFF8DE8C7), 4,
  ),
  _Art(
    'Timing dei pasti e performance',
    'Quando mangiare e importante quanto cosa mangiare. Ottimizza i pasti intorno ai tuoi allenamenti.',
    'Il nutrient timing puo fare la differenza tra un buon allenamento e uno eccellente.\n\nPre-allenamento (2-3 ore prima)\nPasto completo con carboidrati complessi, proteine moderate e grassi ridotti. Esempio: riso con pollo e verdure.\n\nPre-allenamento (30-60 min prima)\nSnack leggero a base di carboidrati semplici. Esempio: banana, fette biscottate con miele.\n\nDurante l allenamento\nPer sessioni superiori a 60 minuti: 30-60g di carboidrati all ora (bevande sportive, gel energetici).\n\nPost-allenamento (entro 30-60 min)\nCombinazione di proteine e carboidrati in rapporto 1:3. Esempio: frullato proteico con banana.\n\nPrima di dormire\nCaseina o yogurt greco per fornire aminoacidi a rilascio lento durante la notte.',
    '15 Apr 2026', 'Timing', Icons.schedule_outlined, Color(0xFF94AAFF), 5,
  ),
  _Art(
    'Integratori: cosa serve davvero?',
    'Tra marketing e scienza: solo pochi integratori hanno evidenze solide. Scopri quali vale la pena assumere.',
    'Il mercato degli integratori e enorme, ma la scienza supporta solo alcuni prodotti.\n\nIntegratori con forte evidenza scientifica:\n\n1. Creatina monoidrato - L integratore piu studiato al mondo. Aumenta forza, potenza e massa muscolare. Dose: 3-5g al giorno. Sicuro per uso a lungo termine.\n\n2. Proteine in polvere - Non un integratore magico, ma un modo pratico per raggiungere il fabbisogno proteico giornaliero.\n\n3. Caffeina - Migliora la performance del 3-5%. Dose efficace: 3-6mg per kg di peso corporeo, 30-60 min prima dell allenamento.\n\n4. Vitamina D - Essenziale se i livelli ematici sono bassi. Fondamentale per la salute delle ossa e la funzione muscolare.\n\nIntegratori con evidenza limitata:\n- BCAA (inutili se si assumono abbastanza proteine)\n- Glutammina (beneficio marginale per atleti ben nutriti)\n- Booster pre-workout (spesso solo caffeina mascherata)',
    '12 Apr 2026', 'Integratori', Icons.medication_outlined, Color(0xFFB5A8FF), 7,
  ),
];

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      backgroundColor: t.colorScheme.surface,
      appBar: const GymHeader(),
      body: SafeArea(child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NUTRIZIONE & DIETA', style: t.textTheme.labelSmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w900, color: const Color(0xFFFDE047))),
          const SizedBox(height: 8),
          Text('Il tuo blog fitness', style: t.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Lexend')),
          const SizedBox(height: 4),
          Text('Articoli e consigli per ottimizzare i tuoi risultati a tavola', style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.outline)),
        ]))),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        // Featured article
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: _FeaturedCard(a: _articles[0]))),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(24, 32, 24, 16), child: Text('TUTTI GLI ARTICOLI', style: t.textTheme.labelSmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w900, color: t.colorScheme.outline.withValues(alpha: 0.6), fontSize: 10)))),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 24), sliver: SliverList(delegate: SliverChildBuilderDelegate(
          (c, i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _ArticleTile(a: _articles[i + 1])),
          childCount: _articles.length - 1,
        ))),
        const SliverToBoxAdapter(child: SizedBox(height: 60)),
      ])),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.a});
  final _Art a;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push('/training/nutrition/article', extra: {'title': a.title, 'body': a.body, 'date': a.date, 'tag': a.tag, 'readMin': a.readMin, 'color': a.color.value}),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a.color.withValues(alpha: 0.3), a.color.withValues(alpha: 0.1)]),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: a.color.withValues(alpha: 0.15)),
        ),
        child: Stack(children: [
          Positioned(right: -15, bottom: -15, child: Icon(a.icon, size: 120, color: a.color.withValues(alpha: 0.08))),
          Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: a.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('IN EVIDENZA', style: TextStyle(color: a.color, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'Lexend', letterSpacing: 1))),
              const Spacer(),
              Text(a.date, style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.outline, fontSize: 9)),
            ]),
            const SizedBox(height: 16),
            Text(a.title, style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend', height: 1.2)),
            const SizedBox(height: 8),
            Text(a.excerpt, style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.outline, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: a.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(a.tag, style: TextStyle(color: a.color, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Lexend'))),
              const SizedBox(width: 12),
              Icon(Icons.timer_outlined, size: 12, color: t.colorScheme.outline),
              const SizedBox(width: 4),
              Text('${a.readMin} min lettura', style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.outline, fontSize: 9)),
              const Spacer(),
              Text('LEGGI', style: TextStyle(color: a.color, fontWeight: FontWeight.w900, fontSize: 11, fontFamily: 'Lexend', letterSpacing: 1)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 14, color: a.color),
            ]),
          ])),
        ]),
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.a});
  final _Art a;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Material(color: Colors.transparent, borderRadius: BorderRadius.circular(20),
      child: InkWell(borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/training/nutrition/article', extra: {'title': a.title, 'body': a.body, 'date': a.date, 'tag': a.tag, 'readMin': a.readMin, 'color': a.color.value}),
        child: Ink(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: t.colorScheme.surfaceContainer.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(20), border: Border.all(color: t.colorScheme.outline.withValues(alpha: 0.05))),
          child: Row(children: [
            Container(width: 56, height: 56, decoration: BoxDecoration(color: a.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
              child: Icon(a.icon, color: a.color, size: 24)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.title, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend', fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: a.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(a.tag, style: TextStyle(color: a.color, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'Lexend'))),
                const SizedBox(width: 8),
                Text(a.date, style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.outline.withValues(alpha: 0.5), fontSize: 9)),
                const SizedBox(width: 8),
                Icon(Icons.timer_outlined, size: 10, color: t.colorScheme.outline.withValues(alpha: 0.5)),
                const SizedBox(width: 3),
                Text('${a.readMin} min', style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.outline.withValues(alpha: 0.5), fontSize: 9)),
              ]),
            ])),
            Icon(Icons.chevron_right, color: t.colorScheme.outline.withValues(alpha: 0.3), size: 20),
          ])),
        ),
      );
  }
}
