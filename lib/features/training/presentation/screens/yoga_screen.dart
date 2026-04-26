import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';

class _YE {
  const _YE(this.name, this.sn, this.desc, this.ben, this.diff, this.icon, this.dur);
  final String name, sn, desc, ben, diff, dur;
  final IconData icon;
}

class _YN {
  const _YN(this.title, this.desc, this.icon, this.gc, this.tag);
  final String title, desc, tag;
  final IconData icon;
  final List<Color> gc;
}

const _exs = [
  _YE('Saluto al Sole', 'Surya Namaskar', 'Sequenza fluida di 12 posizioni che riscalda il corpo, allunga i muscoli e sincronizza il respiro.', 'Flessibilita, circolazione, energia', 'Principiante', Icons.wb_sunny_outlined, '10 min'),
  _YE('Posizione del Guerriero', 'Virabhadrasana', 'Serie di tre posizioni che rafforzano gambe, anche e core. Migliorano equilibrio e concentrazione.', 'Forza gambe, equilibrio, focus', 'Intermedio', Icons.shield_outlined, '5 min'),
  _YE('Posizione dell Albero', 'Vrksasana', 'In piedi su una gamba con l altra appoggiata all interno coscia. Sviluppa equilibrio e radicamento.', 'Equilibrio, concentrazione, stabilita', 'Principiante', Icons.park_outlined, '3 min per lato'),
  _YE('Cane a Testa in Giu', 'Adho Mukha Svanasana', 'Posizione a V invertita che allunga la catena posteriore e rinforza spalle e braccia.', 'Allungamento posteriore, forza spalle', 'Principiante', Icons.pets_outlined, '5 respiri'),
  _YE('Posizione del Cobra', 'Bhujangasana', 'Sdraiati a pancia in giu, solleva il busto aprendo il petto. Rinforza la muscolatura lombare.', 'Postura, flessibilita schiena, apertura petto', 'Principiante', Icons.waves_outlined, '5 respiri'),
  _YE('Posizione del Bambino', 'Balasana', 'Posizione di riposo: in ginocchio, piega il busto in avanti. Calma il sistema nervoso.', 'Rilassamento, stretching schiena, calma', 'Principiante', Icons.child_care_outlined, '1-5 min'),
  _YE('Posizione del Loto', 'Padmasana', 'Posizione seduta classica per la meditazione: gambe incrociate con i piedi sulle cosce opposte.', 'Meditazione, apertura anche, calma mentale', 'Avanzato', Icons.spa_outlined, '5-20 min'),
  _YE('Posizione della Montagna', 'Tadasana', 'Base di tutte le posizioni in piedi. Insegna allineamento, radicamento e consapevolezza.', 'Postura, radicamento, consapevolezza', 'Principiante', Icons.landscape_outlined, '1-3 min'),
  _YE('Posizione del Ponte', 'Setu Bandhasana', 'Sdraiati supini, solleva il bacino formando un ponte. Rinforza glutei e core.', 'Forza glutei, apertura petto, flessibilita', 'Principiante', Icons.architecture_outlined, '5 respiri'),
  _YE('Savasana', 'Savasana', 'Posizione finale: sdraiati supini in totale abbandono per assorbire i benefici della sessione.', 'Rilassamento profondo, recupero, pace mentale', 'Principiante', Icons.nights_stay_outlined, '5-15 min'),
  _YE('Gatto-Mucca', 'Marjariasana-Bitilasana', 'In quadrupedia, alterna inarcamento schiena verso l alto e verso il basso. Scioglie la colonna.', 'Mobilita spinale, rilascio tensione, respiro', 'Principiante', Icons.swap_vert_outlined, '10 cicli'),
  _YE('Posizione del Triangolo', 'Trikonasana', 'Gambe divaricate, piega il busto lateralmente. Allunga fianchi, femorali e apre il torace.', 'Allungamento laterale, apertura torace, equilibrio', 'Intermedio', Icons.change_history_outlined, '5 respiri per lato'),
];

const _news = [
  _YN('Riduzione dello Stress con lo Yoga', 'Studi confermano che la pratica regolare riduce il cortisolo fino al 25%, migliorando ansia e sonno.', Icons.psychology_outlined, [Color(0xFF4ECDC4), Color(0xFF2C7873)], 'Benessere'),
  _YN('Mindfulness: la Scienza dell Attenzione', 'La respirazione consapevole attiva il sistema parasimpatico. Focalizzati sul flusso dell aria.', Icons.self_improvement, [Color(0xFF8DE8C7), Color(0xFF56C596)], 'Mindfulness'),
  _YN('Body Scan: Ascolta il Tuo Corpo', 'Porta l attenzione su ogni parte del corpo dalla testa ai piedi, notando tensioni senza giudicare.', Icons.accessibility_new, [Color(0xFF7B68EE), Color(0xFF5B4FCF)], 'Tecnica'),
  _YN('Yoga e Performance Atletica', 'L integrazione dello yoga migliora flessibilita (+35%), previene infortuni e accelera il recupero.', Icons.fitness_center, [Color(0xFFFF9494), Color(0xFFD66B6B)], 'Sport'),
  _YN('Drishti: il Potere dello Sguardo', 'Scegli un punto fisso su cui posare lo sguardo durante gli esercizi per concentrazione ed equilibrio.', Icons.visibility_outlined, [Color(0xFFFFA07A), Color(0xFFE07B5B)], 'Consiglio'),
];

Color _dc(String d) => d == 'Intermedio' ? const Color(0xFFFFA07A) : d == 'Avanzato' ? const Color(0xFFFF9494) : const Color(0xFF8DE8C7);

class YogaScreen extends StatelessWidget {
  const YogaScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      backgroundColor: t.colorScheme.surface,
      appBar: const GymHeader(),
      body: SafeArea(child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('YOGA & MINDFULNESS', style: t.textTheme.labelSmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w900, color: const Color(0xFF8DE8C7))),
          const SizedBox(height: 8),
          Text('Trova il tuo equilibrio', style: t.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Lexend')),
          const SizedBox(height: 4),
          Text('Unisci corpo e mente attraverso la pratica consapevole', style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.outline)),
        ]))),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(24, 28, 24, 16), child: Text('CONSIGLI & APPROFONDIMENTI', style: t.textTheme.labelSmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w900, color: t.colorScheme.outline.withValues(alpha: 0.6), fontSize: 10)))),
        const SliverToBoxAdapter(child: _Carousel()),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(24, 32, 24, 16), child: Row(children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF8DE8C7), Color(0xFF4ECDC4)]), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Text('ESERCIZI YOGA', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Lexend', color: const Color(0xFF8DE8C7))),
          const Spacer(),
          Text('${_exs.length} posizioni', style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.outline, fontWeight: FontWeight.w600)),
        ]))),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 24), sliver: SliverList(delegate: SliverChildBuilderDelegate((c, i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _Tile(e: _exs[i])), childCount: _exs.length))),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ])),
    );
  }
}

class _Carousel extends StatefulWidget {
  const _Carousel();
  @override State<_Carousel> createState() => _CarouselS();
}
class _CarouselS extends State<_Carousel> {
  final _pc = PageController(viewportFraction: 0.88);
  int _cur = 0; Timer? _tmr;
  @override void initState() { super.initState(); _tmr = Timer.periodic(const Duration(seconds: 5), (_) { if (_pc.hasClients) _pc.animateToPage((_cur + 1) % _news.length, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut); }); }
  @override void dispose() { _tmr?.cancel(); _pc.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(children: [
      SizedBox(height: 200, child: PageView.builder(controller: _pc, onPageChanged: (i) => setState(() => _cur = i), itemCount: _news.length, itemBuilder: (_, i) {
        final n = _news[i];
        return Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: n.gc), borderRadius: BorderRadius.circular(28)),
          child: Stack(children: [
            Positioned(right: -10, bottom: -10, child: Icon(n.icon, size: 100, color: Colors.white.withValues(alpha: 0.08))),
            Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: Text(n.tag, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Lexend', letterSpacing: 0.5))),
              const SizedBox(height: 12),
              Text(n.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Lexend', fontSize: 16, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Expanded(child: Text(n.desc, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontFamily: 'Inter', fontSize: 12, height: 1.4), maxLines: 4, overflow: TextOverflow.ellipsis)),
            ])),
          ]),
        ));
      })),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_news.length, (i) => AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 3), width: _cur == i ? 20 : 6, height: 6, decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: _cur == i ? const Color(0xFF8DE8C7) : t.colorScheme.outline.withValues(alpha: 0.2))))),
    ]);
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.e});
  final _YE e;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context); final c = _dc(e.diff);
    return Material(color: Colors.transparent, borderRadius: BorderRadius.circular(20), child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => _detail(context, t),
      child: Ink(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: t.colorScheme.surfaceContainer.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(20), border: Border.all(color: t.colorScheme.outline.withValues(alpha: 0.05))),
        child: Row(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.withValues(alpha: 0.25), c.withValues(alpha: 0.1)]), borderRadius: BorderRadius.circular(16)), child: Icon(e.icon, color: c, size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.name, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend', fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(e.sn, style: t.textTheme.labelSmall?.copyWith(color: c, fontStyle: FontStyle.italic, fontSize: 10)),
            const SizedBox(height: 6),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Text(e.diff, style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'Lexend'))),
              const SizedBox(width: 8),
              Icon(Icons.timer_outlined, size: 12, color: t.colorScheme.outline.withValues(alpha: 0.5)),
              const SizedBox(width: 3),
              Text(e.dur, style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.outline.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.w700)),
            ]),
          ])),
          Icon(Icons.chevron_right, color: t.colorScheme.outline.withValues(alpha: 0.3), size: 20),
        ])),
    ));
  }
  void _detail(BuildContext context, ThemeData t) {
    final c = _dc(e.diff);
    showModalBottomSheet<void>(context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.9,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(color: t.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
          child: ListView(controller: ctrl, padding: const EdgeInsets.all(24), children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: t.colorScheme.outline.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Container(width: 72, height: 72, decoration: BoxDecoration(gradient: LinearGradient(colors: [c.withValues(alpha: 0.25), c.withValues(alpha: 0.1)]), borderRadius: BorderRadius.circular(20)), child: Icon(e.icon, color: c, size: 36)),
            const SizedBox(height: 20),
            Text(e.name, style: t.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Lexend')),
            const SizedBox(height: 4),
            Text(e.sn, style: TextStyle(color: c, fontStyle: FontStyle.italic, fontFamily: 'Inter', fontSize: 14)),
            const SizedBox(height: 20),
            Row(children: [_Ch(l: e.diff, c: c), const SizedBox(width: 8), _Ch(l: e.dur, c: t.colorScheme.primary)]),
            const SizedBox(height: 24),
            Text('DESCRIZIONE', style: t.textTheme.labelSmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w900, color: t.colorScheme.outline.withValues(alpha: 0.6), fontSize: 10)),
            const SizedBox(height: 8),
            Text(e.desc, style: t.textTheme.bodyMedium?.copyWith(height: 1.6)),
            const SizedBox(height: 24),
            Text('BENEFICI', style: t.textTheme.labelSmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w900, color: t.colorScheme.outline.withValues(alpha: 0.6), fontSize: 10)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: e.ben.split(', ').map((b) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withValues(alpha: 0.2))), child: Text(b, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Lexend')))).toList()),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }
}

class _Ch extends StatelessWidget {
  const _Ch({required this.l, required this.c});
  final String l; final Color c;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Text(l, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 11, fontFamily: 'Lexend')));
}