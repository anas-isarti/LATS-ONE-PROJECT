import 'building.dart';

class Zone {
  final ZoneType type;
  final String label;
  final List<Building> activeBuildings;

  Zone({
    required this.type,
    required this.label,
    List<Building>? activeBuildings,
  }) : activeBuildings = activeBuildings ?? [];

  // Correspond au champ "zone" du JSON ESP32
  String get nfcZoneId => switch (type) {
        ZoneType.production => 'energie',
        ZoneType.transport => 'transport',
        ZoneType.publicDistribution => 'distribution',
        ZoneType.enterprise => 'entreprises',
        ZoneType.residential => 'particuliers',
      };
}
