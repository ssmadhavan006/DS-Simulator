import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import 'stack_visualization_screen.dart';
import 'queue_visualization_screen.dart';
import 'tree_visualization_screen.dart';
import 'graph_visualization_screen.dart';
import 'sorting_visualization_screen.dart';

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
        onTap: () => _navigateTo(context, const TreeVisualizationScreen()),
      ),
      _DSCardData(
        type: DSType.graph,
        icon: Icons.hub,
        gradient: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
        onTap: () => _navigateTo(context, const GraphVisualizationScreen()),
      ),
      _DSCardData(
        type: DSType.sorting,
        icon: Icons.bar_chart,
        gradient: [const Color(0xFFfa709a), const Color(0xFFfee140)],
        onTap: () => _navigateTo(context, const SortingVisualizationScreen()),
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
              separatorBuilder: (_, _) => const SizedBox(height: 12),
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
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(data.icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        data.type.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        data.type.description,
                        style: TextStyle(
                          color: Colors.white.withAlpha(204),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
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
        'Built by S.S. Madhavan',
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
