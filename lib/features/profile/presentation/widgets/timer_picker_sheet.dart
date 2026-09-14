import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/widgets/compact_sheet.dart';
import 'package:gym_corpus/core/widgets/radial_timer_picker.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';

/// Foglio per impostare il timer di recupero tra le serie.
class TimerPickerSheet extends StatefulWidget {
  const TimerPickerSheet({required this.initialValue, super.key});
  final String initialValue;

  @override
  State<TimerPickerSheet> createState() => _TimerPickerSheetState();
}

class _TimerPickerSheetState extends State<TimerPickerSheet> {
  late int _value;
  @override
  void initState() {
    super.initState();
    // Clamp initial value to handle potential 0 or out of range values
    _value = (int.tryParse(widget.initialValue) ?? 90).clamp(1, 300);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SheetSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.tertiary.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.timer_rounded,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Timer di Recupero',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Lexend',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'PAUSA TRA LE SERIE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.5,
                            color: theme.colorScheme.outline,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          RadialTimerPicker(
            initialSeconds: _value,
            size: 260,
            onChanged: (val) {
              setState(() => _value = val);
            },
          ),
          const SizedBox(height: 32),
          Padding(
            padding: EdgeInsets.fromLTRB(48, 0, 48, 24 + bottomPadding),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.read<TrainingBloc>().add(
                    UpdatePreferenceEvent('rest_timer', _value.toString()),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'APPLICA MODIFICHE',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    fontSize: 13,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
