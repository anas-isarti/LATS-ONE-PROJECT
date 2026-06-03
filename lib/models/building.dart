enum ZoneType {
  production,
  transport,
  publicDistribution,
  enterprise,
  residential,
}

/// Type de contrôle UI pour un paramètre
enum ParamControlType {
  slider,   // valeur continue (ex: puissance en MW)
  toggle,   // oui/non (ex: Smart Grid activé)
  stepper,  // valeur entière par paliers (ex: niveau d'automatisation 1-3)
}

/// Un paramètre configurable d'un bâtiment
class BuildingParameter {
  final String id;
  final String label;
  final String unit;          // ex: 'MW', 'MWh', '%', ''
  final double minValue;
  final double maxValue;
  final double defaultValue;
  final double costPerUnit;   // coût supplémentaire par unité choisie
  final double co2PerUnit;    // impact CO2 par unité (négatif = réduit CO2)
  final double energyPerUnit; // énergie produite (+) ou consommée (-) par unité, en MWh
  final ParamControlType controlType;
  final int? steps;           // nombre de paliers pour stepper

  double _value;

  BuildingParameter({
    required this.id,
    required this.label,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    required this.defaultValue,
    required this.costPerUnit,
    this.co2PerUnit = 0,
    this.energyPerUnit = 0,
    this.controlType = ParamControlType.slider,
    this.steps,
  }) : _value = defaultValue;

  double get value => _value;

  void setValue(double v) {
    _value = v.clamp(minValue, maxValue);
  }

  /// Coût additionnel engendré par ce paramètre
  int get additionalCost => ((_value - minValue) * costPerUnit).round();

  /// Impact CO2 engendré par ce paramètre
  double get co2Contribution => _value * co2PerUnit;

  /// Énergie produite ou consommée par ce paramètre
  double get energyContribution => _value * energyPerUnit;

  BuildingParameter copyWith({double? value}) {
    final p = BuildingParameter(
      id: id,
      label: label,
      unit: unit,
      minValue: minValue,
      maxValue: maxValue,
      defaultValue: defaultValue,
      costPerUnit: costPerUnit,
      co2PerUnit: co2PerUnit,
      energyPerUnit: energyPerUnit,
      controlType: controlType,
      steps: steps,
    );
    p._value = value ?? _value;
    return p;
  }
}

class Building {
  final String name;
  final ZoneType zone;
  final int cost;
  final int co2Impact;  // impact de base (sans paramètres)
  final int revenue;
  final String nfcId;
  final List<BuildingParameter> parameters;

  Building({
    required this.name,
    required this.zone,
    required this.cost,
    required this.co2Impact,
    required this.revenue,
    required this.nfcId,
    this.parameters = const [],
  });

  /// Coût total = coût de base + coût de tous les paramètres configurés
  int get totalCost =>
      cost + parameters.fold(0, (sum, p) => sum + p.additionalCost);

  /// Impact CO2 total = base + contributions des paramètres
  double get totalCo2Impact =>
      co2Impact + parameters.fold(0.0, (sum, p) => sum + p.co2Contribution);

  /// Énergie nette produite ou consommée par ce bâtiment (MWh)
  double get netEnergy =>
      parameters.fold(0.0, (sum, p) => sum + p.energyContribution);

  /// Crée une copie avec des paramètres réinitialisés (pour placement)
  Building withFreshParameters() {
    return Building(
      name: name,
      zone: zone,
      cost: cost,
      co2Impact: co2Impact,
      revenue: revenue,
      nfcId: nfcId,
      parameters: parameters
          .map((p) => p.copyWith(value: p.defaultValue))
          .toList(),
    );
  }
}

