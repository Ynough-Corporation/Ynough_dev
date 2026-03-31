import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';
import '../widgets/top_teams_card.dart';
import '../widgets/next_matches_card.dart';
import '../widgets/live_matches_card.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Logique backend  
  // Statistiques globales
  Future<String> getTeamsCount() async => "-";
  Future<String> getMatchesCount() async => "-";
  Future<String> getLiveCount() async => "-";

  // Matchs en direct
  Future<List<Map<String, dynamic>>> getLiveMatches() async => [];

  // Classement et Matchs à venir
  Future<List<Map<String, dynamic>>> getLeaderboard() async => [];
  Future<List<Map<String, dynamic>>> getNextMatches() async => [];

  // Design
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E5F44),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('images/Logo-transparent.png'),
        ),
        title: const Text(
          "YNOUGH BABYFOOT",
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255), 
            fontWeight: FontWeight.w900, 
            fontSize: 28,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            
            // Statistiques
            Row(
              children: [
                Expanded(child: StatCard(title: "Équipes", apiCall: getTeamsCount())),
                const SizedBox(width: 10),
                Expanded(child: StatCard(title: "Matchs", apiCall: getMatchesCount())),
                const SizedBox(width: 10),
                Expanded(child: StatCard(title: "En cours", apiCall: getLiveCount())),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Matchs en direct
            LiveMatchesCard(apiCall: getLiveMatches()),
            
            const SizedBox(height: 24),
            
            // Classement
            TopTeamsCard(apiCall: getLeaderboard()),
            
            const SizedBox(height: 24),
            
            // Prochains matchs
            NextMatchesCard(apiCall: getNextMatches()),
            
            const SizedBox(height: 20), 
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Equipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            selectedIcon: Icon(Icons.sports_soccer),
            label: 'Matchs',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: 'Classements',
          ),
        ],
      ),
    );
  }
}