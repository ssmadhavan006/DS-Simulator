import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import 'stack_visualization_screen.dart';
import 'queue_visualization_screen.dart';

/// Home Screen with Data Structure Selection
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withAlpha(31),
              theme.colorScheme.secondary.withAlpha(20),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, theme),
              Expanded(child: _buildDSCards(context, theme, isWide)),
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DSA Visualizer',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Interactive Data Structure Animations',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withAlpha(178),
                ),
              ),
            ],
          ),
          _buildThemeToggle(context),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(31),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: themeProvider.toggleTheme,
            icon: AnimatedSwitcher(
              duration: AppConstants.animationFast,
              child: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(themeProvider.isDarkMode),
              ),
            ),
            tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
        );
      },
    );
  }

  Widget _buildDSCards(BuildContext context, ThemeData theme, bool isWide) {
    final cards = [
      _DSCardData(
        type: DSType.stack,
        icon: Icons.layers,
        gradient: [const Color(0xFF667eea), const Color(0xFF764ba2)],
        onTap: () => _navigateTo(context, const StackVisualizationScreen()),
      ),
      _DSCardData(
        type: DSType.queue,
        icon: Icons.queue,
        gradient: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
        onTap: () => _navigateTo(context, const QueueVisualizationScreen()),
      ),
      _DSCardData(
        type: DSType.tree,
        icon: Icons.account_tree,
        gradient: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
        onTap: () => _showComingSoon(context, 'Tree'),
      ),
      _DSCardData(
        type: DSType.graph,
        icon: Icons.hub,
        gradient: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
        onTap: () => _showComingSoon(context, 'Graph'),
      ),
    ];

    // Use ListView for scrollable cards that won't overflow
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: isWide
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.0,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) =>
                  _buildCard(context, cards[index]),
            )
          : ListView.separated(
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => SizedBox(
                height: 140,
                child: _buildCard(context, cards[index]),
              ),
            ),
    );
  }

  Widget _buildCard(BuildContext context, _DSCardData data) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: data.gradient,
          ),
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: data.gradient.first.withAlpha(102),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                data.icon,
                size: 120,
                color: Colors.white.withAlpha(51),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(data.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data.type.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.type.description,
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Positioned(
              right: 20,
              top: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Select a data structure to begin visualization',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.textTheme.bodySmall?.color?.withAlpha(127),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: AppConstants.animationNormal,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name visualization coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _DSCardData {
  final DSType type;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  _DSCardData({
    required this.type,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
}
