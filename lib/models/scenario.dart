enum Scenario {
  sobriety,
  technology,
  balance;

  String get label => switch (this) {
        Scenario.sobriety => 'Sobriété',
        Scenario.technology => 'Technologie',
        Scenario.balance => 'Équilibre',
      };

  String get description => switch (this) {
        Scenario.sobriety => 'Réduire pour mieux vivre',
        Scenario.technology => 'Innover pour survivre',
        Scenario.balance => 'Trouver le juste milieu',
      };
}

enum Difficulty {
  easy,
  medium,
  hard;

  String get label => switch (this) {
        Difficulty.easy => 'Facile',
        Difficulty.medium => 'Moyen',
        Difficulty.hard => 'Difficile',
      };

  int get startBudget => switch (this) {
        Difficulty.easy => 8000,
        Difficulty.medium => 5000,
        Difficulty.hard => 3000,
      };

  int get co2Max => switch (this) {
        Difficulty.easy => 250,
        Difficulty.medium => 200,
        Difficulty.hard => 150,
      };

  // Applied to negative event weights
  double get negativeEventMultiplier => switch (this) {
        Difficulty.easy => 0.5,
        Difficulty.medium => 1.0,
        Difficulty.hard => 1.5,
      };
}
