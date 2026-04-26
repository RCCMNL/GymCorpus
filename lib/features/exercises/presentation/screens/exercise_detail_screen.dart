import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({required this.exercise, super.key});

  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF94AAFF),
                size: 18,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              'GYM CORPUS',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: const Color(0xFF94AAFF)),
            ),
            Text(
              'Dettagli Esercizio',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF94AAFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<TrainingBloc, TrainingState>(
            builder: (context, state) {
              var isFavorite = exercise.isFavorite;
              if (state is TrainingLoaded) {
                final currentExercise = state.exercises.firstWhere(
                  (e) => e.id == exercise.id,
                  orElse: () => exercise,
                );
                isFavorite = currentExercise.isFavorite;
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_outline,
                      color: const Color(0xFF94AAFF),
                      size: 18,
                    ),
                    onPressed: () {
                      context.read<TrainingBloc>().add(
                        ToggleExerciseFavoriteEvent(exercise.id, isFavorite: !isFavorite),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 380,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                  ),
                  child: exercise.imageUrl != null
                      ? Image.network(
                          exercise.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                                size: 48,
                              ),
                            ),
                          ),
                        )
                      : Image.asset(
                          'assets/images/placeholder-image.png',
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.surface.withValues(alpha: 0.1),
                          Colors.transparent,
                          theme.colorScheme.surface.withValues(alpha: 0.6),
                          theme.colorScheme.surface,
                        ],
                        stops: const [0.0, 0.4, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          exercise.targetMuscle.toUpperCase(),
                          style: TextStyle(
                            color: theme.colorScheme.onTertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exercise.name,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: exercise.name.length > 20 ? 32 : 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bento Info Row
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _BentoCard(
                            title: 'ATTREZZATURA',
                            content: exercise.equipment ?? 'Tappetino',
                            icon: Icons.fitness_center,
                            iconColor: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BentoCard(
                            title: 'AREA FOCUS',
                            content: exercise.focusArea ?? 'Addominali',
                            icon: Icons.track_changes,
                            iconColor: theme.colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Preparation
                  _SectionHeader(
                    title: 'Preparazione',
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  _NumberedList(
                    content: exercise.preparation ??
                        'Sdraiati sulla schiena con le ginocchia piegate e i piedi appoggiati a terra. Posiziona le mani dietro la testa o incrociate sul petto.',
                  ),

                  const SizedBox(height: 40),

                  // Execution
                  _SectionHeader(
                    title: 'Esecuzione',
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ExecutionCard(
                          title: 'La Salita',
                          content: exercise.execution?.split('.').first ??
                              'Solleva le spalle da terra contraendo gli addominali.',
                          label: 'UP',
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ExecutionCard(
                          title: 'La Discesa',
                          content: exercise.execution?.split('.').length == 2
                              ? exercise.execution!.split('.')[1]
                              : 'Ritorna lentamente alla posizione iniziale.',
                          label: 'DOWN',
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Tips
                  _ExpertTipsCard(
                    tip: exercise.tips ??
                        "Evita di tirare il collo con le mani. Concentrati sul movimento guidato dalla contrazione dell'addome.",
                  ),

                  const SizedBox(height: 40),

                  // User Notes
                  _UserNotesCard(exercise: exercise),

                  const SizedBox(height: 140),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String content;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: 0.05,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 32, height: 2, color: color),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: color,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _NumberedList extends StatelessWidget {
  const _NumberedList({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = content.split('.').where((s) => s.trim().isNotEmpty).toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: index == 0
                  ? theme.colorScheme.surfaceContainerHigh
                      .withValues(alpha: 0.3)
                  : null,
              border: index != steps.length - 1
                  ? Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outline.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    steps[index].trim(),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ExecutionCard extends StatelessWidget {
  const _ExecutionCard({
    required this.title,
    required this.content,
    required this.label,
    required this.color,
  });

  final String title;
  final String content;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4),),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.05,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 84,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  content,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpertTipsCard extends StatelessWidget {
  const _ExpertTipsCard({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2),),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -40,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'SUGGERIMENTI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consiglio Esperto',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserNotesCard extends StatefulWidget {
  const _UserNotesCard({required this.exercise});

  final ExerciseEntity exercise;

  @override
  State<_UserNotesCard> createState() => _UserNotesCardState();
}

class _UserNotesCardState extends State<_UserNotesCard> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.exercise.userNotes);
  }

  @override
  void didUpdateWidget(covariant _UserNotesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.userNotes != widget.exercise.userNotes && !_isEditing) {
      _controller.text = widget.exercise.userNotes ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNotes() {
    context.read<TrainingBloc>().add(
      UpdateExerciseNotesEvent(
        widget.exercise.id,
        notes: _controller.text,
      ),
    );
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -40,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'LE TUE NOTE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Appunti Esercizio',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isEditing ? Icons.check : Icons.edit,
                      color: theme.colorScheme.tertiary,
                      size: 20,
                    ),
                    onPressed: () {
                      if (_isEditing) {
                        _saveNotes();
                      } else {
                        setState(() {
                          _isEditing = true;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_isEditing)
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 2,
                  style: theme.textTheme.bodySmall,
                  decoration: InputDecoration(
                    hintText: 'Scrivi qui le tue note...',
                    hintStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.tertiary.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                )
              else
                Text(
                  (_controller.text.isEmpty)
                      ? 'Nessuna nota presente. Tocca la matita per aggiungerne una.'
                      : _controller.text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _controller.text.isEmpty
                        ? theme.colorScheme.outline.withValues(alpha: 0.7)
                        : theme.colorScheme.onSurface,
                    fontStyle: _controller.text.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
