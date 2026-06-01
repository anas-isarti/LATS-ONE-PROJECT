import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../controllers/quest_controller.dart';
import '../models/building.dart';
import '../models/game_state.dart';
import '../models/quest.dart';

const _kGold = Color(0xFFFFD700);
const _kGreen = Color(0xFF4CAF50);

class QuestScreen extends StatelessWidget {
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final questCtrl = context.watch<QuestController>();
    final state = context.watch<GameController>().state;
    final active = questCtrl.activeQuests;
    final done = questCtrl.completedQuests;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Text('QUÊTES ACTIVES',
                style: TextStyle(
                    color: _kGold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _kGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${active.length}/3',
                  style: const TextStyle(color: _kGold, fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (active.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Aucune quête active.\nTerminez un tour pour en recevoir.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white24, height: 1.5),
            ),
          )
        else
          ...active.map((q) => _QuestCard(quest: q, state: state)),
        if (done.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('QUÊTES COMPLÉTÉES',
              style: TextStyle(
                  color: _kGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 12),
          ...done.map((q) => _QuestCard(quest: q, state: state, completed: true)),
        ],
      ],
    );
  }
}

class _QuestCard extends StatelessWidget {
  final Quest quest;
  final GameState state;
  final bool completed;

  const _QuestCard({
    required this.quest,
    required this.state,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = _computeProgress(quest, state).clamp(0.0, 1.0);
    final current = _computeCurrent(quest, state);

    return Opacity(
      opacity: completed ? 0.55 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      quest.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: completed ? _kGreen : Colors.white,
                      ),
                    ),
                  ),
                  if (completed)
                    const Icon(Icons.check_circle, color: _kGreen, size: 18)
                  else
                    Row(
                      children: [
                        const Icon(Icons.attach_money,
                            color: _kGold, size: 14),
                        Text('+${quest.rewardBudget}¥',
                            style: const TextStyle(
                                color: _kGold,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                quest.description,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      color: completed ? _kGreen : _kGold,
                      backgroundColor: Colors.white10,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$current / ${quest.targetValue}',
                    style: TextStyle(
                      color: completed ? _kGreen : Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _computeProgress(Quest quest, GameState state) {
    return _computeCurrent(quest, state) / quest.targetValue;
  }

  int _computeCurrent(Quest quest, GameState state) {
    switch (quest.type) {
      case QuestType.buildEnergy:
        return state.activeBuildings
            .where((b) => b.zone == ZoneType.production)
            .length;
      case QuestType.reduceCo2:
        return state.activeBuildings
            .where((b) => b.co2Impact < 0)
            .fold(0, (s, b) => s + b.co2Impact.abs());
      case QuestType.buildPublicServices:
        return state.activeBuildings
            .where((b) => b.zone == ZoneType.publicDistribution)
            .length;
      case QuestType.buildTransport:
        return state.activeBuildings
            .where((b) => b.zone == ZoneType.transport)
            .length;
      case QuestType.manageBudget:
        return state.budget;
      case QuestType.balancedCity:
        return state.activeBuildings.map((b) => b.zone).toSet().length;
      case QuestType.negativeCo2:
        return state.co2 < 0 ? 1 : 0;
      case QuestType.endTurnBudget:
        return state.budget;
      case QuestType.totalBuildings:
        return state.activeBuildings.length;
      case QuestType.lowCo2AllGame:
        return state.maxCo2EverReached;
    }
  }
}
