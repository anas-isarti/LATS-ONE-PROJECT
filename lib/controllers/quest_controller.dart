import 'package:flutter/foundation.dart';
import '../models/building.dart';
import '../models/game_state.dart';
import '../models/quest.dart';
import '../data/quests_data.dart';

class QuestController extends ChangeNotifier {
  final List<Quest> _activeQuests = [];
  final List<Quest> _completedQuests = [];
  final List<Quest> _pool = buildQuestPool();

  List<Quest> get activeQuests => List.unmodifiable(_activeQuests);
  List<Quest> get completedQuests => List.unmodifiable(_completedQuests);

  static const int _maxActive = 3;

  /// Génère des quêtes adaptées au profil du joueur (zones négligées, CO2, budget).
  /// À appeler au début de chaque tour.
  void generateAdaptiveQuests(GameState state) {
    if (_activeQuests.length >= _maxActive) return;

    final profile = _analyzeProfile(state);
    final candidates = _pool
        .where((q) => !_activeQuests.any((a) => a.id == q.id))
        .where((q) => !_completedQuests.any((c) => c.id == q.id))
        .toList()
      ..sort((a, b) => _relevanceScore(b, profile) - _relevanceScore(a, profile));

    final slots = _maxActive - _activeQuests.length;
    _activeQuests.addAll(candidates.take(slots));
    notifyListeners();
  }

  /// Évalue les quêtes actives et applique les récompenses sur le GameState.
  /// Retourne le budget total gagné lors de cet appel.
  int evaluateAndReward(GameState state) {
    int earned = 0;
    for (final quest in _activeQuests.toList()) {
      if (_isCompleted(quest, state)) {
        quest.isCompleted = true;
        state.budget += quest.rewardBudget;
        earned += quest.rewardBudget;
        _completedQuests.add(quest);
        _activeQuests.remove(quest);
      }
    }
    if (earned > 0) notifyListeners();
    return earned;
  }

  void reset() {
    _activeQuests.clear();
    _completedQuests.clear();
    notifyListeners();
  }

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
    }
  }

  _PlayerProfile _analyzeProfile(GameState state) {
    final byZone = <ZoneType, int>{};
    for (final b in state.activeBuildings) {
      byZone[b.zone] = (byZone[b.zone] ?? 0) + 1;
    }
    return _PlayerProfile(
      neglectedEnergy: (byZone[ZoneType.production] ?? 0) == 0,
      neglectedTransport: (byZone[ZoneType.transport] ?? 0) == 0,
      neglectedPublicServices: (byZone[ZoneType.publicDistribution] ?? 0) == 0,
      highCo2: state.co2 > state.co2Max * 0.5,
      tightBudget: state.budget < GameState.initialBudget * 0.3,
    );
  }

  int _relevanceScore(Quest quest, _PlayerProfile p) {
    int score = 0;
    if (quest.type == QuestType.buildEnergy && p.neglectedEnergy) score += 3;
    if (quest.type == QuestType.buildTransport && p.neglectedTransport) score += 3;
    if (quest.type == QuestType.buildPublicServices && p.neglectedPublicServices) score += 3;
    if (quest.type == QuestType.reduceCo2 && p.highCo2) score += 3;
    if (quest.type == QuestType.manageBudget && p.tightBudget) score += 3;
    return score;
  }
}

class _PlayerProfile {
  final bool neglectedEnergy;
  final bool neglectedTransport;
  final bool neglectedPublicServices;
  final bool highCo2;
  final bool tightBudget;

  const _PlayerProfile({
    required this.neglectedEnergy,
    required this.neglectedTransport,
    required this.neglectedPublicServices,
    required this.highCo2,
    required this.tightBudget,
  });
}
