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

  // ── Énergie ───────────────────────────────────────────────────────────────

  /// Énergie totale produite (MWh) par les bâtiments de production
  double get energyProduced => activeBuildings
      .where((b) => b.zone == ZoneType.production)
      .fold(0.0, (sum, b) => sum + (b.netEnergy > 0 ? b.netEnergy : 0));

  /// Énergie totale consommée (MWh) par les bâtiments non-production
  double get energyConsumed => activeBuildings
      .where((b) => b.zone != ZoneType.production)
      .fold(0.0, (sum, b) {
        final e = b.netEnergy;
        return sum + (e < 0 ? e.abs() : 0);
      });

  /// Capacité de transport disponible (MWh) — somme des transports
  double get transportCapacity => activeBuildings
      .where((b) => b.zone == ZoneType.transport)
      .fold(0.0, (sum, b) => sum + (b.netEnergy > 0 ? b.netEnergy : 0));

  /// Énergie effectivement distribuée (limitée par la capacité de transport)
  double get energyDistributed {
    if (transportCapacity == 0) return 0;
    return energyProduced < transportCapacity
        ? energyProduced
        : transportCapacity;
  }

  /// Indice énergétique : ratio énergie distribuée / énergie consommée
  /// 1.0 = parfaitement équilibré, >1 = surplus, <1 = déficit
  double get energyIndex {
    if (energyConsumed == 0) return energyDistributed > 0 ? 1.5 : 1.0;
    return (energyDistributed / energyConsumed).clamp(0.0, 2.0);
  }

  /// Taux d'électrification : part des bâtiments ayant des paramètres
  /// d'électrification activés (valeur > minimum)
  double get electrificationRate {
    if (activeBuildings.isEmpty) return 0;
    int electrified = 0;
    for (final b in activeBuildings) {
      final hasElec = b.parameters.any((p) =>
          p.energyPerUnit != 0 && p.value > p.minValue);
      if (hasElec) electrified++;
    }
    return electrified / activeBuildings.length;
  }

  /// Pénalité transport : énergie produite mais non transportable
  double get transportLoss {
    if (transportCapacity == 0 && energyProduced > 0) return energyProduced;
    if (energyProduced > transportCapacity) return energyProduced - transportCapacity;
    return 0;
  }

  // ── Score ─────────────────────────────────────────────────────────────────

  int get score {
    // Base : bâtiments + budget + CO2
    final base = activeBuildings.length * 300 +
        (budget / 20).round() +
        (200 - co2) * 2;

    // Bonus transition énergétique
    final energyBonus = (energyIndex * 500).round();
    final elecBonus = (electrificationRate * 300).round();

    // Malus transport (perte d'énergie)
    final transportMalus = (transportLoss * 10).round();

    final raw = base + energyBonus + elecBonus - transportMalus - _missingInfraPenalty;
    return raw < 0 ? 0 : raw;
  }

  int get _missingInfraPenalty {
    var p = 0;
    if (!activeBuildings.any((b) => b.zone == ZoneType.production)) p += 500;
    if (!activeBuildings.any((b) => b.zone == ZoneType.residential)) p += 500;
    if (!activeBuildings.any((b) => b.zone == ZoneType.publicDistribution)) p += 300;
    if (!activeBuildings.any((b) => b.zone == ZoneType.transport)) p += 200;
    return p;
  }
}
