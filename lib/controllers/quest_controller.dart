import 'package:flutter/foundation.dart';
import '../models/building.dart';
import '../models/game_state.dart';
import '../models/quest.dart';
import '../models/scenario.dart';
import '../data/quests_data.dart';

class QuestController extends ChangeNotifier {
  final List<Quest> _activeQuests = [];
  final List<Quest> _completedQuests = [];
  final Set<String> _completedQuestIds = {};
  final List<Quest> _pool = buildQuestPool();
  Difficulty _difficulty = Difficulty.medium;

  List<Quest> get activeQuests => List.unmodifiable(_activeQuests);
  List<Quest> get completedQuests => List.unmodifiable(_completedQuests);

  static const int _maxActive = 3;

  void reset({Difficulty difficulty = Difficulty.medium}) {
    _difficulty = difficulty;
    _activeQuests.clear();
    _completedQuests.clear();
    _completedQuestIds.clear();
    notifyListeners();
  }

  /// Generates adaptive quests based on 7 player signals.
  void generateAdaptiveQuests(GameState state) {
    if (_activeQuests.length >= _maxActive) return;

    final profile = _analyzeProfile(state);
    final currentTurn = state.currentTurn;

    final candidates = _pool
        .where((q) => !_activeQuests.any((a) => a.id == q.id))
        .where((q) => !_completedQuestIds.contains(q.id))
        // At turn 3: only high-reward quests
        .where((q) => currentTurn < 3 || q.rewardBudget >= 400)
        // On Facile: avoid quests that are too demanding
        .where((q) {
          if (_difficulty == Difficulty.easy &&
              q.type == QuestType.lowCo2AllGame) { return false; }
          return true;
        })
        .toList()
      ..sort((a, b) =>
          _relevanceScore(b, profile) - _relevanceScore(a, profile));

    final slots = _maxActive - _activeQuests.length;
    _activeQuests.addAll(candidates.take(slots));
    notifyListeners();
  }

  /// Evaluates active quests and applies rewards. Returns total budget earned.
  int evaluateAndReward(GameState state) {
    int earned = 0;
    for (final quest in _activeQuests.toList()) {
      if (_isCompleted(quest, state)) {
        quest.isCompleted = true;
        state.budget += quest.rewardBudget;
        earned += quest.rewardBudget;
        _completedQuestIds.add(quest.id);
        _completedQuests.add(quest);
        _activeQuests.remove(quest);
      }
    }
    if (earned > 0) notifyListeners();
    return earned;
  }

  // ── Completion checks ──────────────────────────────────────────────────

  bool _isCompleted(Quest quest, GameState state) {
    switch (quest.type) {
      case QuestType.buildEnergy:
        return state.activeBuildings
                .where((b) => b.zone == ZoneType.production)
                .length >=
            quest.targetValue;

      case QuestType.reduceCo2:
        final totalReduction = state.activeBuildings
            .where((b) => b.co2Impact < 0)
            .fold(0, (sum, b) => sum + b.co2Impact.abs());
        return totalReduction >= quest.targetValue;

      case QuestType.buildPublicServices:
        return state.activeBuildings
                .where((b) => b.zone == ZoneType.publicDistribution)
                .length >=
            quest.targetValue;

      case QuestType.buildTransport:
        return state.activeBuildings
                .where((b) => b.zone == ZoneType.transport)
                .length >=
            quest.targetValue;

      case QuestType.manageBudget:
        return state.budget >= quest.targetValue;

      case QuestType.balancedCity:
        final zones =
            state.activeBuildings.map((b) => b.zone).toSet();
        return zones.length >= quest.targetValue;

      case QuestType.negativeCo2:
        return state.co2 < 0;

      case QuestType.endTurnBudget:
        return state.budget >= quest.targetValue;

      case QuestType.totalBuildings:
        return state.activeBuildings.length >= quest.targetValue;

      case QuestType.lowCo2AllGame:
        return state.maxCo2EverReached <= quest.targetValue;
    }
  }

  // ── Profile analysis (7 signals) ──────────────────────────────────────

  _PlayerProfile _analyzeProfile(GameState state) {
    final byZone = <ZoneType, int>{};
    for (final b in state.activeBuildings) {
      byZone[b.zone] = (byZone[b.zone] ?? 0) + 1;
    }
    final zonesUsed = byZone.keys.length;
    final turnsRemaining = state.maxTurns - state.currentTurn + 1;

    return _PlayerProfile(
      neglectedEnergy: (byZone[ZoneType.production] ?? 0) == 0,
      neglectedTransport: (byZone[ZoneType.transport] ?? 0) == 0,
      neglectedPublicServices:
          (byZone[ZoneType.publicDistribution] ?? 0) == 0,
      highCo2: state.co2 > state.co2Max * 0.5,
      tightBudget: state.budget < state.initialBudget * 0.3,
      lowDiversity: zonesUsed < 3,
      fewBuildings: state.activeBuildings.length < 4,
      turnsRemaining: turnsRemaining,
    );
  }

  int _relevanceScore(Quest quest, _PlayerProfile p) {
    int score = 0;
    if (quest.type == QuestType.buildEnergy && p.neglectedEnergy) score += 3;
    if (quest.type == QuestType.buildTransport && p.neglectedTransport) {
      score += 3;
    }
    if (quest.type == QuestType.buildPublicServices &&
        p.neglectedPublicServices) { score += 3; }
    if (quest.type == QuestType.reduceCo2 && p.highCo2) { score += 3; }
    if (quest.type == QuestType.manageBudget && p.tightBudget) { score += 3; }
    if (quest.type == QuestType.balancedCity && p.lowDiversity) { score += 3; }
    if (quest.type == QuestType.totalBuildings && p.fewBuildings) { score += 2; }

    // Prefer quick-to-complete quests when few turns remain
    if (p.turnsRemaining <= 1 && quest.rewardBudget >= 500) { score += 2; }

    // Difficulty adjustments
    if (_difficulty == Difficulty.hard && quest.rewardBudget >= 600) {
      score += 1;
    }
    if (_difficulty == Difficulty.easy && quest.rewardBudget <= 300) {
      score += 1;
    }

    return score;
  }
}

class _PlayerProfile {
  final bool neglectedEnergy;
  final bool neglectedTransport;
  final bool neglectedPublicServices;
  final bool highCo2;
  final bool tightBudget;
  final bool lowDiversity;
  final bool fewBuildings;
  final int turnsRemaining;

  const _PlayerProfile({
    required this.neglectedEnergy,
    required this.neglectedTransport,
    required this.neglectedPublicServices,
    required this.highCo2,
    required this.tightBudget,
    required this.lowDiversity,
    required this.fewBuildings,
    required this.turnsRemaining,
  });
}
