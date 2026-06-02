import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../controllers/quest_controller.dart';
import '../models/scenario.dart';
import '../widgets/the_last_one_logo.dart';

const _kGold = Color(0xFFFFD700);
const _kGreen = Color(0xFF4CAF50);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Scenario _scenario = Scenario.balance;
  Difficulty _difficulty = Difficulty.medium;

  @override
  Widget build(BuildContext context) {
    final bestScore = context.watch<GameController>().bestScore;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 28),
              // Logo
              const Center(child: TheLastOneLogo(size: 150)),
              const SizedBox(height: 20),
              // Title
              const Text(
                'THE LAST ONE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
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

              // Scenario selector
              _sectionLabel('SCÉNARIO ADEME'),
              const SizedBox(height: 10),
              _ScenarioSelector(
                selected: _scenario,
                onChanged: (s) => setState(() => _scenario = s),
              ),
              const SizedBox(height: 20),

              // Difficulty selector
              _sectionLabel('DIFFICULTÉ'),
              const SizedBox(height: 10),
              _DifficultySelector(
                selected: _difficulty,
                onChanged: (d) => setState(() => _difficulty = d),
              ),
              const SizedBox(height: 20),

              // Rules card
              _RulesCard(difficulty: _difficulty),
              const SizedBox(height: 20),

              // Best score
              if (bestScore > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _kGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: _kGreen.withValues(alpha: 0.25)),
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

              // Start button
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => _startNewGame(context),
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5),
                    ),
                    child: const Text('NOUVELLE PARTIE'),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Version
              const Text(
                'v0.5',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white24, fontSize: 11),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _startNewGame(BuildContext context) {
    final gameCtrl = context.read<GameController>();
    final questCtrl = context.read<QuestController>();
    gameCtrl.startGame(_scenario, _difficulty);
    questCtrl.reset(difficulty: _difficulty);
    questCtrl.generateAdaptiveQuests(gameCtrl.state);
    Navigator.pushNamed(context, '/city');
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

Widget _sectionLabel(String text) => Text(
      text,
      style: const TextStyle(
          color: _kGold,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 2),
    );

// ── Scenario selector ─────────────────────────────────────────────────────────

class _ScenarioSelector extends StatelessWidget {
  final Scenario selected;
  final ValueChanged<Scenario> onChanged;
  const _ScenarioSelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: Scenario.values
          .map((s) => _SelectionTile(
                label: s.label,
                description: s.description,
                isSelected: s == selected,
                onTap: () => onChanged(s),
                icon: switch (s) {
                  Scenario.sobriety => Icons.eco,
                  Scenario.technology => Icons.science,
                  Scenario.balance => Icons.balance,
                },
              ))
          .toList(),
    );
  }
}

// ── Difficulty selector ───────────────────────────────────────────────────────

class _DifficultySelector extends StatelessWidget {
  final Difficulty selected;
  final ValueChanged<Difficulty> onChanged;
  const _DifficultySelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Difficulty.values
          .map((d) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _DifficultyChip(
                    difficulty: d,
                    isSelected: d == selected,
                    onTap: () => onChanged(d),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final Difficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;
  const _DifficultyChip(
      {required this.difficulty,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      Difficulty.easy => const Color(0xFF4CAF50),
      Difficulty.medium => _kGold,
      Difficulty.hard => const Color(0xFFE53935),
    };
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? color : Colors.white12, width: 1.5),
        ),
        child: Text(
          difficulty.label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: isSelected ? color : Colors.white38,
              fontSize: 13,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const _SelectionTile({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? _kGold.withValues(alpha: 0.08)
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? _kGold : Colors.white12, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isSelected ? _kGold : Colors.white38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: isSelected ? _kGold : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Text(description,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: _kGold, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Rules card ────────────────────────────────────────────────────────────────

class _RulesCard extends StatelessWidget {
  final Difficulty difficulty;
  const _RulesCard({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final co2Color = switch (difficulty) {
      Difficulty.easy => _kGreen,
      Difficulty.medium => _kGold,
      Difficulty.hard => const Color(0xFFE53935),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RÈGLES DU JEU',
              style: TextStyle(
                  color: _kGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 10),
          _RuleRow(Icons.monetization_on_outlined, 'Budget de départ',
              '${difficulty.startBudget} ¥', _kGold),
          const SizedBox(height: 6),
          _RuleRow(Icons.cloud_outlined, 'CO2 maximum',
              '${difficulty.co2Max} unités', co2Color),
          const SizedBox(height: 6),
          _RuleRow(Icons.schedule, 'Durée', '3 tours · 20 minutes',
              Colors.white54),
          const SizedBox(height: 6),
          _RuleRow(Icons.warning_amber_outlined, 'Game over si',
              'CO2 max, budget épuisé ou temps écoulé',
              const Color(0xFFE53935)),
          const SizedBox(height: 6),
          _RuleRow(Icons.domain_outlined, 'Pénalités/tour',
              'Zones vides (énergie, logements, services, transport) → malus budget',
              Colors.orange),
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
    return Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 8),
      Expanded(
          child: Text(label,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 12))),
      Text(value,
          style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
    ]);
  }
}
