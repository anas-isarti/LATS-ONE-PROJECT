enum EventType {
  energyCrisis,
  greenSubsidy,
  naturalDisaster,
  economicBoom,
  pollution,
  internationalAid,
  citizenRevolt,
  techInnovation,
  environmentalInspection,
}

class GameEvent {
  final String id;
  final EventType type;
  final String title;
  final String description;
  final int budgetImpact;
  final int co2Impact;
  final int duration;
  final double weight;

  const GameEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.budgetImpact,
    required this.co2Impact,
    required this.duration,
    required this.weight,
  });
}
