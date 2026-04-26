import 'package:flutter/material.dart';

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
            IconButton(
              onPressed: () {
                // Placeholder: Notifiche UI
              },
              icon: const Icon(Icons.notifications_none_rounded, size: 24),
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
