import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Gestione base Adaptive: layout switch per schermi larghi e piccoli
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    if (isDesktop) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.fitness_center),
                    label: Text('Training'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.list),
                    label: Text('Esercizi'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.analytics),
                    label: Text('Analytics'),
                  ),
                ],
                selectedIndex: _calculateSelectedIndex(context),
                onDestinationSelected: (index) => _onItemTapped(index, context),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    // Piattaforme iOS (Cupertino) per schermi standard
    if (!kIsWeb && Platform.isIOS) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.flame), label: 'Training'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.list_bullet), label: 'Esercizi'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.graph_square), label: 'Analytics'),
          ],
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
        ),
        tabBuilder: (context, index) {
          // Cupertino impone la tab construction in modo specifico,
          // qui passiamo semplicemente il current branch gestito da ShellRoute
          return CupertinoPageScaffold(child: child);
        },
      );
    }

    // Material 3 / Custom Stitch Design Default 
    return Scaffold(
      extendBody: true, // Important to see blur over content
      body: child,
      bottomNavigationBar: _buildCustomNavBar(context),
    );
  }

  Widget _buildCustomNavBar(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF08082F).withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, -12), // Adjusted to go upwards
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, 0, Icons.list_alt, 'Esercizi', selectedIndex),
                _buildNavItem(context, 1, Icons.dashboard_customize, 'Custom', selectedIndex),
                _buildNavItem(context, 2, Icons.fitness_center, 'Training', selectedIndex),
                _buildNavItem(context, 3, Icons.insights, 'Analytics', selectedIndex),
                _buildNavItem(context, 4, Icons.person, 'Profile', selectedIndex),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, int selectedIndex) {
    final theme = Theme.of(context);
    final isSelected = index == selectedIndex;
    final isTraining = label.toUpperCase() == 'TRAINING';
    
    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isTraining ? 14 : 10, 
          vertical: isTraining ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isTraining 
                  ? const Color(0xFF3367FF) 
                  : const Color(0xFF3367FF).withValues(alpha: 0.2)) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(isTraining ? 20 : 24),
          boxShadow: isSelected && isTraining ? [
            BoxShadow(
              color: const Color(0xFF3367FF).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ] : null,
          gradient: isSelected && isTraining ? const LinearGradient(
            colors: [Color(0xFF3367FF), Color(0xFF94AAFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? (isTraining ? Colors.white : const Color(0xFF94AAFF)) 
                  : theme.colorScheme.outline.withValues(alpha: isTraining ? 0.8 : 0.5),
              size: isTraining ? 26 : 22,
            ),
            SizedBox(height: isTraining ? 2 : 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 8,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                letterSpacing: 0.8,
                color: isSelected 
                    ? (isTraining ? Colors.white : const Color(0xFF94AAFF)) 
                    : theme.colorScheme.outline.withValues(alpha: isTraining ? 0.8 : 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/exercises')) return 0;
    if (location.startsWith('/custom')) return 1;
    if (location.startsWith('/training')) return 2;
    if (location.startsWith('/analytics')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/exercises');
      case 1:
        context.go('/custom');
      case 2:
        context.go('/training');
      case 3:
        context.go('/analytics');
      case 4:
        context.go('/profile');
    }
  }
}
