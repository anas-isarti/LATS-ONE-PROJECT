import '../models/event.dart';

const List<GameEvent> allEvents = [
  // ── Événements originaux ─────────────────────────────────────────────────
  GameEvent(
    id: 'energy_crisis',
    type: EventType.energyCrisis,
    title: 'Crise énergétique',
    description: 'Une pénurie d\'énergie frappe la ville. Budget réduit et CO2 en hausse.',
    budgetImpact: -500,
    co2Impact: 30,
    duration: 1,
    weight: 0.20,
  ),
  GameEvent(
    id: 'green_subsidy',
    type: EventType.greenSubsidy,
    title: 'Subvention verte',
    description: 'Le gouvernement récompense vos efforts écologiques.',
    budgetImpact: 800,
    co2Impact: -10,
    duration: 1,
    weight: 0.15,
  ),
  GameEvent(
    id: 'natural_disaster',
    type: EventType.naturalDisaster,
    title: 'Catastrophe naturelle',
    description: 'Une inondation endommage les infrastructures de la ville.',
    budgetImpact: -1000,
    co2Impact: 20,
    duration: 2,
    weight: 0.10,
  ),
  GameEvent(
    id: 'economic_boom',
    type: EventType.economicBoom,
    title: 'Boom économique',
    description: 'L\'économie locale est en plein essor. Les revenus augmentent.',
    budgetImpact: 600,
    co2Impact: 15,
    duration: 1,
    weight: 0.20,
  ),
  GameEvent(
    id: 'pollution_peak',
    type: EventType.pollution,
    title: 'Pic de pollution',
    description: 'Un épisode de pollution touche la ville. Pression sur le budget santé.',
    budgetImpact: -200,
    co2Impact: 40,
    duration: 1,
    weight: 0.15,
  ),
  GameEvent(
    id: 'international_aid',
    type: EventType.internationalAid,
    title: 'Aide internationale',
    description: 'Une ONG internationale finance un projet écologique.',
    budgetImpact: 400,
    co2Impact: -5,
    duration: 1,
    weight: 0.20,
  ),

  // ── Nouveaux événements ──────────────────────────────────────────────────
  GameEvent(
    id: 'citizen_revolt',
    type: EventType.citizenRevolt,
    title: 'Révolte citoyenne',
    description: 'Les habitants protestent contre le manque de services publics. -300 ¥',
    budgetImpact: -300,
    co2Impact: 0,
    duration: 1,
    weight: 0.10, // ×3 si aucun service public après tour 1
  ),
  GameEvent(
    id: 'tech_innovation',
    type: EventType.techInnovation,
    title: 'Innovation technologique',
    description: 'Votre investissement dans l\'énergie verte porte ses fruits. +400 ¥, CO2 -10',
    budgetImpact: 400,
    co2Impact: -10,
    duration: 1,
    weight: 0.15, // ×2 si >3 bâtiments énergie verte
  ),
  GameEvent(
    id: 'environmental_inspection',
    type: EventType.environmentalInspection,
    title: 'Inspection environnementale',
    description: 'Les autorités évaluent votre impact écologique. Effect selon CO2.',
    budgetImpact: 0, // géré dynamiquement dans GameController
    co2Impact: 0,
    duration: 1,
    weight: 0.15,
  ),
];
