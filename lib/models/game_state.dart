import 'building.dart';

class GameState {
  int budget;
  int co2;
  int currentTurn;
  final int maxTurns;
  final int co2Max;
  final List<Building> activeBuildings;
  bool isGameOver;
  String? gameOverReason;

  static const int initialBudget = 5000;
  static const int initialCo2 = 0;
  static const int defaultCo2Max = 200;
  static const int defaultMaxTurns = 3;

  GameState({
    this.budget = initialBudget,
    this.co2 = initialCo2,
    this.currentTurn = 1,
    this.maxTurns = defaultMaxTurns,
    this.co2Max = defaultCo2Max,
    List<Building>? activeBuildings,
    this.isGameOver = false,
    this.gameOverReason,
  }) : activeBuildings = activeBuildings ?? [];

  bool get isLastTurn => currentTurn >= maxTurns;

  int get totalRevenue =>
      activeBuildings.fold(0, (sum, b) => sum + b.revenue);

  int get totalCo2Impact =>
      activeBuildings.fold(0, (sum, b) => sum + b.co2Impact);

  int get score =>
      activeBuildings.length * 100 +
      budget +
      (co2Max - co2).clamp(0, co2Max);
}
