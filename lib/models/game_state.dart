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

  // CO2 negative counts as bonus (no upper cap)
  int get score =>
      activeBuildings.length * 100 +
      budget +
      (co2Max - co2 > 0 ? co2Max - co2 : 0);
}
