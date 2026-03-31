import 'package:flutter/material.dart';
import 'package:ynough/pageEquipe/screen/teams_screen.dart';

const ynoughBlack = Color(0xFF0A0A0A);
const ynoughCream = Color(0xFFFFF7EB);

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<_NavigationPageData> _pages = [
    _NavigationPageData(
      title: 'Accueil',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      page: SectionPage(
        title: 'Accueil',
        subtitle: 'Match en cours, top 3 classement, prochains matchs',
        icon: Icons.home,
      ),
    ),
    _NavigationPageData(
      title: 'Equipes',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups,
      page: TeamsScreen(),
    ),
    _NavigationPageData(
      title: 'Matchs',
      icon: Icons.sports_soccer_outlined,
      selectedIcon: Icons.sports_soccer,
      page: SectionPage(
        title: 'Matchs',
        subtitle: 'Matchs en cours, a venir et termines, ajouter match',
        icon: Icons.sports_soccer,
      ),
    ),
    _NavigationPageData(
      title: 'Classements',
      icon: Icons.leaderboard_outlined,
      selectedIcon: Icons.leaderboard,
      page: SectionPage(
        title: 'Classements',
        subtitle: 'Classement general de toutes les equipes',
        icon: Icons.leaderboard,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages.map((pageData) => pageData.page).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _pages
            .map(
              (pageData) => NavigationDestination(
                icon: Icon(pageData.icon),
                selectedIcon: Icon(pageData.selectedIcon),
                label: pageData.title,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavigationPageData {
  const _NavigationPageData({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });

  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}

class SectionPage extends StatelessWidget {
  const SectionPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 8, 24),
      color: ynoughCream,
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: ynoughBlack,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: _YnoughHeaderLogo(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Card(
                    elevation: 0,
                    color: ynoughBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 72, color: ynoughCream),
                          const SizedBox(height: 20),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: ynoughCream.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 class _YnoughHeaderLogo extends StatelessWidget {
  const _YnoughHeaderLogo();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'images/Logo-transparent.png',
        width: 86,
        height: 86,
        fit: BoxFit.contain,
      ),
    );
  }
}
