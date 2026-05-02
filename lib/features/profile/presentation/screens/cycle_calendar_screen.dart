import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:intl/intl.dart';

enum CyclePhase { menstrual, follicular, ovulatory, luteal }

class CycleCalendarScreen extends StatefulWidget {
  const CycleCalendarScreen({super.key});
  @override
  State<CycleCalendarScreen> createState() => _CycleCalendarScreenState();
}

class _CycleCalendarScreenState extends State<CycleCalendarScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  int _cycleLength = 28;
  int _currentDayOfCycle = 3;
  bool _isPeriodActive = true;

  final Map<CyclePhase, Map<String, dynamic>> _phaseData = {
    CyclePhase.menstrual: {
      'name': 'Fase Mestruale', 'color': const Color(0xFFFF4B72),
      'advice': 'Ottimo per il recupero attivo, yoga dolce e camminate. Ascolta il tuo corpo.',
      'icon': Icons.water_drop_rounded,
    },
    CyclePhase.follicular: {
      'name': 'Fase Follicolare', 'color': const Color(0xFFFF8FA3),
      'advice': 'Perfetto per aumentare i carichi, HIIT e allenamenti ad alta intensità!',
      'icon': Icons.bolt_rounded,
    },
    CyclePhase.ovulatory: {
      'name': 'Fase Ovulatoria', 'color': const Color(0xFFFFAEBC),
      'advice': 'Picco di energia! Tenta i tuoi massimali (PR) o sfide impegnative.',
      'icon': Icons.local_fire_department_rounded,
    },
    CyclePhase.luteal: {
      'name': 'Fase Luteale', 'color': const Color(0xFFF0A8D0),
      'advice': 'L energia inizia a calare. Concentrati su forza a media intensità o pilates.',
      'icon': Icons.self_improvement_rounded,
    },
  };

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  CyclePhase get _currentPhase {
    if (_currentDayOfCycle <= 5) return CyclePhase.menstrual;
    if (_currentDayOfCycle <= 13) return CyclePhase.follicular;
    if (_currentDayOfCycle <= 16) return CyclePhase.ovulatory;
    return CyclePhase.luteal;
  }

  void _togglePeriod() => setState(() {
    _isPeriodActive = !_isPeriodActive;
    _currentDayOfCycle = _isPeriodActive ? 1 : 6;
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = _phaseData[_currentPhase]!;
    final color = info['color'] as Color;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const GymHeader(title: 'Ciclo & Fitness'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Questa è un\'anteprima grafica. La funzione di tracciamento reale è attualmente in fase di sviluppo.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text('Calendario Ciclo', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend', color: color)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PREVIEW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            Text('Ottimizza i tuoi allenamenti in base al tuo corpo.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 32),
            Center(
              child: SizedBox(
                height: 260, width: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (ctx, _) => Container(
                        width: 220 + (_pulseCtrl.value * 20), height: 220 + (_pulseCtrl.value * 20),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.1)),
                      ),
                    ),
                    CustomPaint(size: const Size(220, 220), painter: _RingPainter(_currentDayOfCycle, _cycleLength, color, theme.colorScheme.surfaceContainerHighest)),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(info['icon'] as IconData, color: color, size: 28),
                        Text('Giorno $_currentDayOfCycle', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
                        Text(info['name'] as String, style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _togglePeriod();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Dati non salvati: questa è un\'anteprima interattiva.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: theme.colorScheme.secondary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPeriodActive ? theme.colorScheme.surfaceContainerHigh : const Color(0xFFFF4B72),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(_isPeriodActive ? 'SEGNA FINE CICLO' : 'SEGNA INIZIO CICLO', style: TextStyle(color: _isPeriodActive ? theme.colorScheme.onSurface : Colors.white, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  Icon(Icons.fitness_center, color: color),
                  const SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Allenamento ideale', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
                      Text(info['advice'] as String, style: theme.textTheme.bodyMedium),
                    ],
                  )),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('STORICO & PREVISIONI', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w900, color: theme.colorScheme.outline)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(24), border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1))),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(DateFormat('MMMM yyyy', 'it_IT').format(DateTime.now()).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Lexend', fontSize: 14)),
                    const Row(children: [Icon(Icons.chevron_left, color: Colors.grey), SizedBox(width: 16), Icon(Icons.chevron_right, color: Colors.grey)]),
                  ]),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
                    itemCount: 31,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final isPeriod = day <= 5;
                      final isToday = day == DateTime.now().day;
                      return Container(
                        decoration: BoxDecoration(
                          color: isPeriod ? const Color(0xFFFF4B72).withValues(alpha: 0.2) : (isToday ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent),
                          shape: BoxShape.circle,
                          border: isPeriod ? Border.all(color: const Color(0xFFFF4B72), width: 1.5) : (isToday ? Border.all(color: theme.colorScheme.primary, width: 1) : null),
                        ),
                        child: Center(child: Text(day.toString(), style: TextStyle(fontWeight: isPeriod || isToday ? FontWeight.bold : FontWeight.normal, color: isPeriod ? const Color(0xFFFF4B72) : (isToday ? theme.colorScheme.primary : theme.colorScheme.onSurface), fontSize: 13))),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('SINTOMI DI OGGI', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w900, color: theme.colorScheme.outline)),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: [
              _SymptomChip(label: 'Crampi', icon: Icons.sick_outlined, color: const Color(0xFFFF8FA3), theme: theme),
              _SymptomChip(label: 'Energica', icon: Icons.battery_charging_full_rounded, color: const Color(0xFF8DE8C7), theme: theme),
              _SymptomChip(label: 'Stanca', icon: Icons.battery_alert_rounded, color: Colors.orangeAccent, theme: theme),
              _SymptomChip(label: 'Sensibile', icon: Icons.favorite_border_rounded, color: const Color(0xFFF0A8D0), theme: theme),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SymptomChip extends StatefulWidget {
  const _SymptomChip({required this.label, required this.icon, required this.color, required this.theme});
  final String label; final IconData icon; final Color color; final ThemeData theme;
  @override State<_SymptomChip> createState() => _SymptomChipState();
}

class _SymptomChipState extends State<_SymptomChip> {
  bool _selected = false;
  @override Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _selected = !_selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _selected ? widget.color.withValues(alpha: 0.2) : widget.theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _selected ? widget.color : widget.theme.colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(widget.icon, size: 16, color: _selected ? widget.color : widget.theme.colorScheme.outline), const SizedBox(width: 8), Text(widget.label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _selected ? widget.theme.colorScheme.onSurface : widget.theme.colorScheme.outline))]),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.d, this.tot, this.c, this.bg);
  final int d; final int tot; final Color c; final Color bg;
  @override void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 10;
    canvas.drawCircle(center, r, Paint()..color = bg..style = PaintingStyle.stroke..strokeWidth = 16..strokeCap = StrokeCap.round);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), -math.pi / 2, 2 * math.pi * (d / tot), false, Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = 16..strokeCap = StrokeCap.round);
  }
  @override bool shouldRepaint(covariant CustomPainter o) => true;
}
