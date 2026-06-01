enum QuestType {
  buildEnergy,
  reduceCo2,
  manageBudget,
  buildPublicServices,
  buildTransport,
}

class Quest {
  final String id;
  final QuestType type;
  final String title;
  final String description;
  final int targetValue;
  final int rewardBudget;
  bool isCompleted;

  Quest({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.rewardBudget,
    this.isCompleted = false,
  });
}
