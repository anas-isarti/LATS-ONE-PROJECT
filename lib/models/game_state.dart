import 'building.dart';

class GameState {
  int budget;
  final int initialBudget;
  int co2;
  int currentTurn;
  final int maxTurns;
  final int co2Max;
  final List<Building> activeBuildings;
  bool isGameOver;
  String? gameOverReason;
  int maxCo2EverReached;

  static const int defaultMaxTurns = 3;

  GameState({
    int startBudget = 5000,
    this.co2 = 0,
    this.currentTurn = 1,
    this.maxTurns = defaultMaxTurns,
    this.co2Max = 200,
    List<Building>? activeBuildings,
    this.isGameOver = false,
    this.gameOverReason,
    this.maxCo2EverReached = 0,
  })  : budget = startBudget,
        initialBudget = startBudget,
        activeBuildings = activeBuildings ?? [];

  bool get isLastTurn => currentTurn >= maxTurns;

  int get totalRevenue =>
      activeBuildings.fold(0, (sum, b) => sum + b.revenue);

  int get totalCo2Impact =>
      activeBuildings.fold(0, (sum, b) => sum + b.co2Impact);

  // Score: buildings are the main driver; budget/CO2 are bonuses; missing infrastructure penalized
  int get score {
    final base = activeBuildings.length * 300 +
        (budget / 20).round() +
        (200 - co2) * 2;
    final raw = base - _missingInfraPenalty;
    return raw < 0 ? 0 : raw;
  }

  // Penalize missing critical infrastructure at end-of-game
  int get _missingInfraPenalty {
    var p = 0;
    if (!activeBuildings.any((b) => b.zone == ZoneType.production)) p += 500;
    if (!activeBuildings.any((b) => b.zone == ZoneType.residential)) p += 500;
    if (!activeBuildings.any((b) => b.zone == ZoneType.publicDistribution)) p += 300;
    if (!activeBuildings.any((b) => b.zone == ZoneType.transport)) p += 200;
    return p;
  }
}
