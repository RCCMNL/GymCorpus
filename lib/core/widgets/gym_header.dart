import 'package:flutter/material.dart';

class GymHeader extends StatelessWidget implements PreferredSizeWidget {
  const GymHeader({super.key, this.title});
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      toolbarHeight: 50,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(Icons.bolt, color: theme.colorScheme.primary, size: 28),
      ),
      title: Text(
        'Gym Corpus',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          fontStyle: FontStyle.italic,
          fontFamily: 'Lexend',
          fontSize: 22,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {
            // Potrebbe navigare alla pagina profilo/settings se non siamo già lì
          },
          icon: const Icon(Icons.settings, size: 20),
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
