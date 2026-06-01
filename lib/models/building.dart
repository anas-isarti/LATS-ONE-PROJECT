enum ZoneType {
  production,
  transport,
  publicDistribution,
  enterprise,
  residential,
}

class Building {
  final String name;
  final ZoneType zone;
  final int cost;
  final int co2Impact; // negative = réduit CO2, positive = augmente CO2
  final int revenue;   // revenus générés par tour
  final String nfcId;  // correspond au champ "batiment" du JSON ESP32

  const Building({
    required this.name,
    required this.zone,
    required this.cost,
    required this.co2Impact,
    required this.revenue,
    required this.nfcId,
  });
}
