import 'package:flutter/material.dart';

import '../matches/matches_page.dart';
import '../pages/placeholder_page.dart';

const ynoughBlack = Color(0xFF0A0A0A);
const ynoughCream = Color(0xFFFFF7EB);

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static final List<_NavigationPageData> _pages = [
    const _NavigationPageData(
      title: 'Accueil',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      page: PlaceholderPage(
        title: 'Accueil',
        subtitle: 'Match en cours, top 3 classement, prochains matchs',
        icon: Icons.home,
      ),
    ),
    const _NavigationPageData(
      title: 'Equipes',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups,
      page: PlaceholderPage(
        title: 'Equipes',
        subtitle: 'Équipes inscrites, leur nombre de victoires et de défaites, bouton ajouter une équipe',
        icon: Icons.groups,
      ),
    ),
    const _NavigationPageData(
      title: 'Matchs',
      icon: Icons.sports_soccer_outlined,
      selectedIcon: Icons.sports_soccer,
      page: MatchesPage(),
    ),
    const _NavigationPageData(
      title: 'Classement',
      icon: Icons.leaderboard_outlined,
      selectedIcon: Icons.leaderboard,
      page: PlaceholderPage(
        title: 'Classement',
        subtitle: 'Classement général de toutes les équipes',
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
