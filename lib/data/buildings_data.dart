import '../models/building.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

BuildingParameter _slider(
  String id,
  String label,
  String unit, {
  required double min,
  required double max,
  required double def,
  required double costPerUnit,
  double co2PerUnit = 0,
  double energyPerUnit = 0,
}) =>
    BuildingParameter(
      id: id,
      label: label,
      unit: unit,
      minValue: min,
      maxValue: max,
      defaultValue: def,
      costPerUnit: costPerUnit,
      co2PerUnit: co2PerUnit,
      energyPerUnit: energyPerUnit,
      controlType: ParamControlType.slider,
    );

BuildingParameter _stepper(
  String id,
  String label,
  String unit, {
  required double min,
  required double max,
  required double def,
  required double costPerUnit,
  double co2PerUnit = 0,
  double energyPerUnit = 0,
  int steps = 3,
}) =>
    BuildingParameter(
      id: id,
      label: label,
      unit: unit,
      minValue: min,
      maxValue: max,
      defaultValue: def,
      costPerUnit: costPerUnit,
      co2PerUnit: co2PerUnit,
      energyPerUnit: energyPerUnit,
      controlType: ParamControlType.stepper,
      steps: steps,
    );

BuildingParameter _toggle(
  String id,
  String label, {
  required double costPerUnit,
  double co2PerUnit = 0,
  double energyPerUnit = 0,
}) =>
    BuildingParameter(
      id: id,
      label: label,
      unit: '',
      minValue: 0,
      maxValue: 1,
      defaultValue: 0,
      costPerUnit: costPerUnit,
      co2PerUnit: co2PerUnit,
      energyPerUnit: energyPerUnit,
      controlType: ParamControlType.toggle,
    );

// ─── Catalogue complet ────────────────────────────────────────────────────────

final List<Building> allBuildings = [

  // ── PRODUCTION (Énergie) ───────────────────────────────────────────────────

  Building(
    name: 'Solaire',
    zone: ZoneType.production,
    cost: 500,
    co2Impact: -10,
    revenue: 50,
    nfcId: 'solaire',
    parameters: [
      _slider('puissance', 'Puissance installée', 'MWc',
          min: 10, max: 200, def: 10, costPerUnit: 8, co2PerUnit: -0.05, energyPerUnit: 0.9),
      _slider('stockage', 'Capacité de stockage', 'MWh',
          min: 0, max: 100, def: 0, costPerUnit: 12, energyPerUnit: 0.5),
      _stepper('maintenance', 'Niveau de maintenance', '',
          min: 1, max: 3, def: 1, costPerUnit: 50, co2PerUnit: -0.02),
    ],
  ),

  Building(
    name: 'Éolien',
    zone: ZoneType.production,
    cost: 400,
    co2Impact: -8,
    revenue: 40,
    nfcId: 'eolien',
    parameters: [
      _slider('puissance', 'Puissance installée', 'MW',
          min: 10, max: 300, def: 10, costPerUnit: 7, co2PerUnit: -0.04, energyPerUnit: 0.85),
      _slider('stockage', 'Capacité de stockage associée', 'MWh',
          min: 0, max: 150, def: 0, costPerUnit: 11, energyPerUnit: 0.4),
      _stepper('maintenance', 'Niveau de maintenance', '',
          min: 1, max: 3, def: 1, costPerUnit: 40, co2PerUnit: -0.02),
    ],
  ),

  Building(
    name: 'Nucléaire',
    zone: ZoneType.production,
    cost: 2000,
    co2Impact: -50,
    revenue: 200,
    nfcId: 'nucleaire',
    parameters: [
      _slider('puissance', 'Puissance produite', 'MW',
          min: 500, max: 3000, def: 500, costPerUnit: 0.5, co2PerUnit: -0.01, energyPerUnit: 0.95),
      _stepper('maintenance', 'Niveau de maintenance', '',
          min: 1, max: 3, def: 1, costPerUnit: 200, co2PerUnit: -0.03),
      _slider('securite', 'Investissement sécurité', 'k¥',
          min: 0, max: 500, def: 0, costPerUnit: 1, co2PerUnit: -0.005),
    ],
  ),

  Building(
    name: 'Hydraulique',
    zone: ZoneType.production,
    cost: 1500,
    co2Impact: -30,
    revenue: 150,
    nfcId: 'hydraulique',
    parameters: [
      _slider('puissance', 'Puissance produite', 'MW',
          min: 100, max: 2000, def: 100, costPerUnit: 0.6, co2PerUnit: -0.01, energyPerUnit: 0.9),
      _slider('stockage', 'Capacité de stockage', 'MWh',
          min: 0, max: 500, def: 0, costPerUnit: 5, energyPerUnit: 0.8),
      _stepper('maintenance', 'Niveau de maintenance', '',
          min: 1, max: 3, def: 1, costPerUnit: 80, co2PerUnit: -0.02),
    ],
  ),

  Building(
    name: 'Hydrogène',
    zone: ZoneType.production,
    cost: 800,
    co2Impact: -15,
    revenue: 80,
    nfcId: 'hydrogene',
    parameters: [
      _slider('production', 'Production H₂ vert', 'kg/h',
          min: 10, max: 500, def: 10, costPerUnit: 3, co2PerUnit: -0.03, energyPerUnit: 0.6),
      _slider('stockage', 'Capacité de stockage', 'MWh',
          min: 0, max: 200, def: 0, costPerUnit: 8, energyPerUnit: 0.5),
      _slider('rendement', 'Rendement électrolyseurs', '%',
          min: 50, max: 95, def: 50, costPerUnit: 10, co2PerUnit: -0.01, energyPerUnit: 0.01),
    ],
  ),

  Building(
    name: 'Géothermique',
    zone: ZoneType.production,
    cost: 600,
    co2Impact: -12,
    revenue: 60,
    nfcId: 'geothermique',
    parameters: [
      _slider('puissance', 'Puissance produite', 'MW',
          min: 10, max: 500, def: 10, costPerUnit: 5, co2PerUnit: -0.02, energyPerUnit: 0.9),
      _slider('rendement', 'Rendement énergétique', '%',
          min: 40, max: 90, def: 40, costPerUnit: 8, co2PerUnit: -0.01, energyPerUnit: 0.008),
      _stepper('maintenance', 'Niveau de maintenance', '',
          min: 1, max: 3, def: 1, costPerUnit: 60, co2PerUnit: -0.02),
    ],
  ),

  Building(
    name: 'Fusion',
    zone: ZoneType.production,
    cost: 5000,
    co2Impact: -100,
    revenue: 500,
    nfcId: 'fusion',
    parameters: [
      _slider('rd', 'Investissement R&D', 'k¥',
          min: 0, max: 2000, def: 0, costPerUnit: 1, co2PerUnit: -0.02, energyPerUnit: 0.1),
      _stepper('tech', 'Niveau technologique', '',
          min: 1, max: 3, def: 1, costPerUnit: 500, co2PerUnit: -0.05, energyPerUnit: 5),
      _slider('rendement', 'Rendement potentiel', '%',
          min: 30, max: 80, def: 30, costPerUnit: 20, co2PerUnit: -0.01, energyPerUnit: 0.05),
    ],
  ),

  // ── TRANSPORT DE L'ÉNERGIE ────────────────────────────────────────────────

  Building(
    name: 'Réseau haute tension',
    zone: ZoneType.transport,
    cost: 800,
    co2Impact: 5,
    revenue: 30,
    nfcId: 'reseau_ht',
    parameters: [
      _slider('capacite', 'Capacité des lignes', 'MW',
          min: 100, max: 5000, def: 100, costPerUnit: 0.2, energyPerUnit: 0.98),
      _slider('pertes', 'Réduction des pertes électriques', '%',
          min: 0, max: 15, def: 0, costPerUnit: 20, co2PerUnit: -0.05, energyPerUnit: 0.1),
      _stepper('modernisation', 'Niveau de modernisation', '',
          min: 1, max: 3, def: 1, costPerUnit: 150, co2PerUnit: -0.03, energyPerUnit: 0.5),
    ],
  ),

  Building(
    name: 'Poste de transformation',
    zone: ZoneType.transport,
    cost: 500,
    co2Impact: 3,
    revenue: 20,
    nfcId: 'poste_transfo',
    parameters: [
      _slider('capacite', 'Capacité de transformation', 'MVA',
          min: 50, max: 2000, def: 50, costPerUnit: 0.3, energyPerUnit: 0.95),
      _slider('rendement', 'Rendement', '%',
          min: 85, max: 99, def: 85, costPerUnit: 15, co2PerUnit: -0.02, energyPerUnit: 0.05),
      _stepper('automatisation', 'Niveau d\'automatisation', '',
          min: 1, max: 3, def: 1, costPerUnit: 100, co2PerUnit: -0.02, energyPerUnit: 0.3),
    ],
  ),

  Building(
    name: 'Réseau de distribution',
    zone: ZoneType.transport,
    cost: 400,
    co2Impact: 3,
    revenue: 15,
    nfcId: 'reseau_distrib',
    parameters: [
      _slider('capacite', 'Capacité maximale', 'MW',
          min: 50, max: 1000, def: 50, costPerUnit: 0.4, energyPerUnit: 0.92),
      _toggle('smartgrid', 'Smart Grid activé',
          costPerUnit: 300, co2PerUnit: -2, energyPerUnit: 1),
      _slider('reparation', 'Temps de réparation réduit', 'h',
          min: 0, max: 24, def: 0, costPerUnit: 10, energyPerUnit: 0.05),
    ],
  ),

  Building(
    name: 'Station de stockage',
    zone: ZoneType.transport,
    cost: 700,
    co2Impact: 1,
    revenue: 10,
    nfcId: 'station_stockage',
    parameters: [
      _slider('stockage', 'Capacité de stockage', 'MWh',
          min: 50, max: 2000, def: 50, costPerUnit: 0.8, energyPerUnit: 0.6),
      _slider('decharge', 'Puissance de décharge', 'MW',
          min: 10, max: 500, def: 10, costPerUnit: 1.5, energyPerUnit: 0.4),
      _slider('rendement', 'Rendement aller-retour', '%',
          min: 70, max: 97, def: 70, costPerUnit: 12, co2PerUnit: -0.01, energyPerUnit: 0.08),
    ],
  ),

  Building(
    name: 'Bornes de recharge',
    zone: ZoneType.transport,
    cost: 300,
    co2Impact: -2,
    revenue: 15,
    nfcId: 'bornes_recharge',
    parameters: [
      _slider('puissance', 'Puissance disponible', 'kW',
          min: 7, max: 350, def: 7, costPerUnit: 2, co2PerUnit: -0.01, energyPerUnit: -0.2),
      _toggle('gestion', 'Gestion intelligente des charges',
          costPerUnit: 200, co2PerUnit: -1, energyPerUnit: 0.5),
      _slider('occupation', 'Taux d\'occupation', '%',
          min: 10, max: 90, def: 10, costPerUnit: 5, energyPerUnit: -0.1),
    ],
  ),

  // ── SERVICES PUBLICS ──────────────────────────────────────────────────────

  Building(
    name: 'École',
    zone: ZoneType.publicDistribution,
    cost: 400,
    co2Impact: 5,
    revenue: 0,
    nfcId: 'ecole',
    parameters: [
      _stepper('isolation', 'Isolation thermique', '',
          min: 1, max: 3, def: 1, costPerUnit: 60, co2PerUnit: -0.5, energyPerUnit: -0.3),
      _toggle('led', 'Éclairage LED',
          costPerUnit: 80, co2PerUnit: -0.5, energyPerUnit: -0.2),
      _toggle('solaire', 'Panneaux solaires',
          costPerUnit: 200, co2PerUnit: -1, energyPerUnit: 0.5),
    ],
  ),

  Building(
    name: 'Hôpital',
    zone: ZoneType.publicDistribution,
    cost: 800,
    co2Impact: 8,
    revenue: 0,
    nfcId: 'hopital',
    parameters: [
      _stepper('efficacite', 'Efficacité énergétique', '',
          min: 1, max: 3, def: 1, costPerUnit: 150, co2PerUnit: -1, energyPerUnit: -0.5),
      _toggle('batteries', 'Batteries de secours',
          costPerUnit: 300, co2PerUnit: -0.5, energyPerUnit: 0.3),
      _toggle('solaire', 'Panneaux solaires',
          costPerUnit: 250, co2PerUnit: -1.5, energyPerUnit: 0.8),
    ],
  ),

  Building(
    name: 'Police',
    zone: ZoneType.publicDistribution,
    cost: 300,
    co2Impact: 3,
    revenue: 0,
    nfcId: 'police',
    parameters: [
      _toggle('vehicules', 'Véhicules électriques',
          costPerUnit: 200, co2PerUnit: -1.5, energyPerUnit: -0.3),
      _toggle('led', 'Éclairage LED',
          costPerUnit: 50, co2PerUnit: -0.3, energyPerUnit: -0.1),
      _toggle('batteries', 'Batteries de secours',
          costPerUnit: 100, co2PerUnit: -0.2, energyPerUnit: 0.2),
    ],
  ),

  Building(
    name: 'Supermarché',
    zone: ZoneType.publicDistribution,
    cost: 350,
    co2Impact: 10,
    revenue: 50,
    nfcId: 'supermarche',
    parameters: [
      _stepper('frigo', 'Efficacité équipements frigorifiques', '',
          min: 1, max: 3, def: 1, costPerUnit: 80, co2PerUnit: -1, energyPerUnit: -0.5),
      _toggle('led', 'Éclairage LED',
          costPerUnit: 60, co2PerUnit: -0.5, energyPerUnit: -0.2),
      _toggle('solaire', 'Panneaux solaires',
          costPerUnit: 200, co2PerUnit: -1, energyPerUnit: 0.6),
    ],
  ),

  Building(
    name: 'Gare',
    zone: ZoneType.publicDistribution,
    cost: 600,
    co2Impact: 15,
    revenue: 80,
    nfcId: 'gare',
    parameters: [
      _toggle('bornes', 'Bornes de recharge intégrées',
          costPerUnit: 250, co2PerUnit: -2, energyPerUnit: -0.5),
      _toggle('led', 'Éclairage LED',
          costPerUnit: 100, co2PerUnit: -0.8, energyPerUnit: -0.3),
      _toggle('solaire', 'Panneaux solaires',
          costPerUnit: 300, co2PerUnit: -2, energyPerUnit: 1),
    ],
  ),

  Building(
    name: 'Pompiers',
    zone: ZoneType.publicDistribution,
    cost: 250,
    co2Impact: 2,
    revenue: 0,
    nfcId: 'pompiers',
    parameters: [
      _toggle('vehicules', 'Véhicules électriques',
          costPerUnit: 300, co2PerUnit: -2, energyPerUnit: -0.4),
      _toggle('batteries', 'Batteries de secours',
          costPerUnit: 120, co2PerUnit: -0.3, energyPerUnit: 0.3),
      _toggle('solaire', 'Panneaux solaires',
          costPerUnit: 150, co2PerUnit: -0.8, energyPerUnit: 0.4),
    ],
  ),

  // ── ENTREPRISES ───────────────────────────────────────────────────────────

  Building(
    name: 'Industrie lourde',
    zone: ZoneType.enterprise,
    cost: 1000,
    co2Impact: 50,
    revenue: 200,
    nfcId: 'industrie_lourde',
    parameters: [
      _stepper('electrification', 'Électrification des procédés', '',
          min: 1, max: 3, def: 1, costPerUnit: 200, co2PerUnit: -3, energyPerUnit: -1),
      _stepper('efficacite', 'Efficacité énergétique', '',
          min: 1, max: 3, def: 1, costPerUnit: 150, co2PerUnit: -2, energyPerUnit: -0.5),
      _toggle('chaleur', 'Récupération de chaleur',
          costPerUnit: 300, co2PerUnit: -3, energyPerUnit: 0.8),
    ],
  ),

  Building(
    name: 'Commerces',
    zone: ZoneType.enterprise,
    cost: 400,
    co2Impact: 15,
    revenue: 100,
    nfcId: 'commerces',
    parameters: [
      _stepper('isolation', 'Isolation', '',
          min: 1, max: 3, def: 1, costPerUnit: 70, co2PerUnit: -0.8, energyPerUnit: -0.3),
      _toggle('led', 'Éclairage LED',
          costPerUnit: 60, co2PerUnit: -0.6, energyPerUnit: -0.2),
      _toggle('solaire', 'Panneaux solaires',
          costPerUnit: 200, co2PerUnit: -1.2, energyPerUnit: 0.7),
    ],
  ),

  Building(
    name: 'Bureaux',
    zone: ZoneType.enterprise,
    cost: 500,
    co2Impact: 10,
    revenue: 80,
    nfcId: 'bureaux',
    parameters: [
      _toggle('bms', 'Gestion intelligente de l\'énergie',
          costPerUnit: 250, co2PerUnit: -2, energyPerUnit: -0.5),
      _toggle('led', 'Éclairage LED',
          costPerUnit: 80, co2PerUnit: -0.8, energyPerUnit: -0.3),
      _toggle('solaire', 'Panneaux solaires',
          costPerUnit: 220, co2PerUnit: -1.5, energyPerUnit: 0.8),
    ],
  ),

  Building(
    name: 'Usines',
    zone: ZoneType.enterprise,
    cost: 800,
    co2Impact: 40,
    revenue: 150,
    nfcId: 'usines',
    parameters: [
      _stepper('electrification', 'Électrification des machines', '',
          min: 1, max: 3, def: 1, costPerUnit: 180, co2PerUnit: -2.5, energyPerUnit: -0.8),
      _stepper('efficacite', 'Efficacité énergétique', '',
          min: 1, max: 3, def: 1, costPerUnit: 120, co2PerUnit: -1.5, energyPerUnit: -0.4),
      _toggle('stockage', 'Stockage batterie',
          costPerUnit: 250, co2PerUnit: -1, energyPerUnit: 0.5),
    ],
  ),

  // ── PARTICULIERS ──────────────────────────────────────────────────────────

  Building(
    name: 'Logements résidentiels',
    zone: ZoneType.residential,
    cost: 200,
    co2Impact: 5,
    revenue: 30,
    nfcId: 'logements',
    parameters: [
      _stepper('isolation', 'Isolation', '',
          min: 1, max: 3, def: 1, costPerUnit: 50, co2PerUnit: -0.5, energyPerUnit: -0.2),
      _toggle('pac', 'Pompe à chaleur',
          costPerUnit: 150, co2PerUnit: -1.5, energyPerUnit: -0.4),
      _toggle('solaire', 'Panneaux solaires',
          costPerUnit: 120, co2PerUnit: -0.8, energyPerUnit: 0.4),
    ],
  ),

  Building(
    name: 'Appartements',
    zone: ZoneType.residential,
    cost: 300,
    co2Impact: 8,
    revenue: 50,
    nfcId: 'appartements',
    parameters: [
      _stepper('isolation', 'Isolation', '',
          min: 1, max: 3, def: 1, costPerUnit: 60, co2PerUnit: -0.6, energyPerUnit: -0.25),
      _stepper('chauffage', 'Chauffage collectif performant', '',
          min: 1, max: 3, def: 1, costPerUnit: 90, co2PerUnit: -1, energyPerUnit: -0.3),
      _toggle('bornes', 'Bornes de recharge',
          costPerUnit: 180, co2PerUnit: -0.5, energyPerUnit: -0.2),
    ],
  ),

  Building(
    name: 'Maisons individuelles',
    zone: ZoneType.residential,
    cost: 250,
    co2Impact: 10,
    revenue: 40,
    nfcId: 'maisons',
    parameters: [
      _toggle('pac', 'Pompe à chaleur',
          costPerUnit: 180, co2PerUnit: -2, energyPerUnit: -0.5),
      _toggle('pv', 'Panneaux photovoltaïques',
          costPerUnit: 150, co2PerUnit: -1.5, energyPerUnit: 0.6),
      _toggle('batterie', 'Batterie domestique',
          costPerUnit: 200, co2PerUnit: -0.5, energyPerUnit: 0.4),
    ],
  ),
];
