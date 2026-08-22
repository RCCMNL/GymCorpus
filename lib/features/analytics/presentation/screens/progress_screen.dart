import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/measurements_tab.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/progress_hero.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/progress_shared_widgets.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/weight_history_tab.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reloadProgressData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reloadProgressData() {
    context.read<TrainingBloc>()
      ..add(LoadBodyWeightLogsEvent())
      ..add(LoadBodyMeasurementsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: BlocBuilder<TrainingBloc, TrainingState>(
          builder: (context, state) {
            if (state is TrainingError) {
              return ProgressErrorState(
                message: state.message,
                onRetry: _reloadProgressData,
              );
            }

            if (state is! TrainingLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final profileWeight = context.read<AuthBloc>().state.maybeWhen(
              authenticated: (user) => user.weight,
              orElse: () => null,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: Text(
                    'Progressi',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: ProgressTabBar(controller: _tabController),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _tabController,
                    builder: (context, _) {
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          WeightHistoryTab(
                            logs: state.bodyWeightLogs,
                            profileWeight: profileWeight,
                            settings: state.settings,
                            hero: ProgressHero(
                              logs: state.bodyWeightLogs,
                              profileWeight: profileWeight,
                              measurements: state.bodyMeasurements,
                              settings: state.settings,
                              activeTab: 0,
                            ),
                          ),
                          MeasurementsTab(
                            measurements: state.bodyMeasurements,
                            logs: state.bodyWeightLogs,
                            settings: state.settings,
                            hero: ProgressHero(
                              logs: state.bodyWeightLogs,
                              profileWeight: profileWeight,
                              measurements: state.bodyMeasurements,
                              settings: state.settings,
                              activeTab: 1,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
