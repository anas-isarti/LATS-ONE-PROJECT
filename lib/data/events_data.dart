import '../models/event.dart';

const List<GameEvent> allEvents = [
  GameEvent(
    id: 'energy_crisis',
    type: EventType.energyCrisis,
    title: 'Crise énergétique',
    description: 'Une pénurie d\'énergie frappe la ville. Budget réduit et CO2 en hausse.',
    budgetImpact: -500,
    co2Impact: 30,
    duration: 1,
    weight: 0.20, // plus probable si peu de bâtiments énergie
  ),
  GameEvent(
    id: 'green_subsidy',
    type: EventType.greenSubsidy,
    title: 'Subvention verte',
    description: 'Le gouvernement récompense vos efforts écologiques.',
    budgetImpact: 800,
    co2Impact: -10,
    duration: 1,
    weight: 0.15, // plus probable si CO2 faible
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
    weight: 0.20, // plus probable si beaucoup d'entreprises
  ),
  GameEvent(
    id: 'pollution_peak',
    type: EventType.pollution,
    title: 'Pic de pollution',
    description: 'Un épisode de pollution touche la ville. Pression sur le budget santé.',
    budgetImpact: -200,
    co2Impact: 40,
    duration: 1,
    weight: 0.15, // plus probable si CO2 élevé
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
];
