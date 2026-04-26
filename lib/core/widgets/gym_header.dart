import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_state.dart';

class GymHeader extends StatelessWidget implements PreferredSizeWidget {
  const GymHeader({super.key, this.title, this.actions});
  final String? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      toolbarHeight: 50,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.primary, size: 24),
              onPressed: () => Navigator.maybePop(context),
            )
          : Padding(
              padding: const EdgeInsets.all(8),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                ).createShader(bounds),
                child: const Icon(Icons.bolt, color: Colors.white, size: 28),
              ),
            ),
      title: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
        ).createShader(bounds),
        child: Text(
          'Gym Corpus',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            fontStyle: FontStyle.italic,
            fontFamily: 'Lexend',
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      centerTitle: false,
      actions: actions ??
          [
            BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                final unread = state.unreadCount;
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () => context.push('/notifications'),
                      icon: Icon(
                        unread > 0
                            ? Icons.notifications_rounded
                            : Icons.notifications_none_rounded,
                        size: 24,
                        color: unread > 0
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
                    if (unread > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4D6A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF4D6A)
                                    .withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              unread > 99 ? '99+' : unread.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Lexend',
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 4),
          ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, Colors.transparent],
              stops: const [0.6, 0.6],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(51); // 50 + 1 for border
}
