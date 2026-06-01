import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../controllers/quest_controller.dart';

const _kGold = Color(0xFFFFD700);
const _kGreen = Color(0xFF4CAF50);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bestScore = context.watch<GameController>().bestScore;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _CityIllustration(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 28),
                    const Text(
                      'THE LAST ONE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _kGold,
                        letterSpacing: 5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '"Humanity had thousands of chances.\nThis is the last one."',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.white38,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _RulesCard(),
                    const SizedBox(height: 20),
                    if (bestScore > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _kGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _kGreen.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.emoji_events,
                                color: _kGreen, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Meilleur score : $bestScore',
                              style: const TextStyle(
                                color: _kGreen,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    ElevatedButton(
                      onPressed: () => _startNewGame(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                      ),
                      child: const Text('NOUVELLE PARTIE'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startNewGame(BuildContext context) {
    context.read<GameController>().resetGame();
    context.read<QuestController>().reset();
    context.read<QuestController>().generateAdaptiveQuests(
      context.read<GameController>().state,
    );
    Navigator.pushNamed(context, '/city');
  }
}

// ── City illustration ─────────────────────────────────────────────────────────

class _CityIllustration extends StatelessWidget {
  const _CityIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF050510), Color(0xFF0D0D0D)],
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Subtle star dots
          const Positioned(top: 14, left: 30,
              child: _StarDot(size: 2)),
          const Positioned(top: 8, right: 55,
              child: _StarDot(size: 1.5)),
          const Positioned(top: 28, left: 110,
              child: _StarDot(size: 1.5)),
          const Positioned(top: 18, right: 130,
              child: _StarDot(size: 2)),
          const Positioned(top: 6, left: 200,
              child: _StarDot(size: 1.5)),
          // Skyline icons at varying heights
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _SkyIcon(icon: Icons.home, size: 36,
                    color: Color(0xFF1E3A5F)),
                _SkyIcon(icon: Icons.apartment, size: 54,
                    color: Color(0xFF243B55)),
                _SkyIcon(icon: Icons.business, size: 62,
                    color: Color(0xFF1A2E4A)),
                _SkyIcon(icon: Icons.bolt, size: 38, color: _kGold),
                _SkyIcon(icon: Icons.domain, size: 70,
                    color: Color(0xFF1A2E4A)),
                _SkyIcon(icon: Icons.factory, size: 50,
                    color: Color(0xFF1E3A5F)),
                _SkyIcon(icon: Icons.eco, size: 34, color: _kGreen),
                _SkyIcon(icon: Icons.apartment, size: 44,
                    color: Color(0xFF243B55)),
                _SkyIcon(icon: Icons.home, size: 30,
                    color: Color(0xFF1E3A5F)),
              ],
            ),
          ),
          // Green ground line
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: _kGreen.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkyIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  const _SkyIcon(
      {required this.icon, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Icon(icon, size: size, color: color),
    );
  }
}

class _StarDot extends StatelessWidget {
  final double size;
  const _StarDot({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
          color: Colors.white54, shape: BoxShape.circle),
    );
  }
}

// ── Rules card ────────────────────────────────────────────────────────────────

class _RulesCard extends StatelessWidget {
  const _RulesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'RÈGLES DU JEU',
            style: TextStyle(
                color: _kGold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
          ),
          SizedBox(height: 12),
          _RuleRow(Icons.monetization_on_outlined,
              'Budget de départ', '5 000 ¥', _kGold),
          SizedBox(height: 8),
          _RuleRow(Icons.cloud_outlined,
              'CO2 maximum', '200 unités', Color(0xFF4CAF50)),
          SizedBox(height: 8),
          _RuleRow(Icons.schedule,
              'Durée de la partie', '3 tours', Colors.white54),
          SizedBox(height: 8),
          _RuleRow(Icons.warning_amber_outlined,
              'Game over si', 'CO2 max ou budget épuisé', Color(0xFFE53935)),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _RuleRow(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
