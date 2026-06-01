import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';

const _kGold = Color(0xFFFFD700);
const _kGreen = Color(0xFF4CAF50);
const _kRed = Color(0xFFE53935);

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GameController>();
    final state = ctrl.state;
    final history = ctrl.turnHistory;
    final co2Ratio = (state.co2 / state.co2Max).clamp(0.0, 1.0);
    final co2Color =
        co2Ratio < 0.5 ? _kGreen : co2Ratio < 0.75 ? Colors.orange : _kRed;
    final budgetRatio =
        (state.budget / state.initialBudget).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('STATISTIQUES',
              style: TextStyle(
                  color: _kGold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 12),
          _StatCard(children: [
            _StatRow(
              label: 'CO2',
              value: '${state.co2} / ${state.co2Max}',
              valueColor: co2Color,
              progress: co2Ratio,
              progressColor: co2Color,
            ),
            const SizedBox(height: 10),
            _StatRow(
              label: 'Budget',
              value: '${state.budget} ¥',
              valueColor: _kGold,
              progress: budgetRatio,
              progressColor: _kGold,
            ),
            const SizedBox(height: 10),
            _StatRow(
              label: 'Bâtiments',
              value: '${state.activeBuildings.length}',
              valueColor: Colors.white70,
            ),
            const SizedBox(height: 10),
            _StatRow(
              label: 'Score',
              value: '${state.score}',
              valueColor: _kGreen,
            ),
          ]),
          const SizedBox(height: 20),
          const Text('HISTORIQUE DES TOURS',
              style: TextStyle(
                  color: _kGold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 12),
          if (history.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Aucun tour terminé',
                    style: TextStyle(color: Colors.white24)),
              ),
            )
          else
            ...history.map((t) => _TurnCard(summary: t)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final List<Widget> children;
  const _StatCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final double? progress;
  final Color? progressColor;

  const _StatRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.progress,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 13)),
            Text(value,
                style: TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ],
        ),
        if (progress != null) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            color: progressColor,
            backgroundColor: Colors.white10,
          ),
        ],
      ],
    );
  }
}

class _TurnCard extends StatelessWidget {
  final dynamic summary;
  const _TurnCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tour ${summary.turn}',
                style: const TextStyle(
                    color: _kGold, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _TurnRow(
                icon: Icons.attach_money,
                label: 'Revenus',
                value: '+${summary.revenueEarned} ¥',
                color: _kGreen),
            _TurnRow(
                icon: Icons.cloud,
                label: 'CO2 final',
                value: '${summary.co2AfterTurn}',
                color: summary.co2AfterTurn > 100 ? _kRed : Colors.white70),
            _TurnRow(
                icon: Icons.account_balance_wallet,
                label: 'Budget final',
                value: '${summary.budgetAfterTurn} ¥',
                color: Colors.white70),
            if (summary.buildingsPlaced > 0)
              _TurnRow(
                  icon: Icons.domain_add,
                  label: 'Bâtiments construits',
                  value: '${summary.buildingsPlaced}',
                  color: Colors.white70),
            if (summary.eventTitle != null)
              _TurnRow(
                  icon: Icons.warning_amber,
                  label: 'Événement',
                  value: summary.eventTitle!,
                  color: Colors.orange),
          ],
        ),
      ),
    );
  }
}

class _TurnRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TurnRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.white38),
          const SizedBox(width: 6),
          Expanded(
              child: Text(label,
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 12))),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
