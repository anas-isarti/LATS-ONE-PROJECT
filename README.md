# THE LAST ONE

> *"Humanity had thousands of chances. This is the last one."*

Jeu de gestion de ville Smart City développé en Flutter dans le cadre d'un projet d'innovation à l'UTC Shanghai. Le joueur gère une ville en crise climatique : il doit construire des infrastructures, gérer son budget et maintenir un bilan carbone viable — le tout en 3 tours et 20 minutes chrono.

---

## Objectif du jeu

Tu es maire d'une ville en ruine. Tu disposes d'un **budget limité**, d'un **seuil de CO2 à ne pas dépasser**, et de **3 tours** (jours de jeu) pour construire une ville qui tient debout.

Chaque bâtiment que tu poses a un coût, un impact CO2, et génère (ou non) des revenus par tour. La tension centrale : **les bâtiments rentables polluent, les bâtiments écologiques coûtent cher.**

### Comment on gagne

On survit aux 3 tours sans déclencher de game over, puis on cherche à **maximiser son score** :

```
Score = (nombre de bâtiments × 100) + budget restant + (CO2 max − CO2 actuel)
```

Un CO2 négatif (grâce aux bâtiments verts) donne un **bonus supplémentaire** au-delà du plafond normal.

### Comment on perd — Game Over

Il y a 3 façons de perdre :

| Condition | Message |
|---|---|
| CO2 ≥ seuil max | *"La ville est invivable."* |
| Budget ≤ 0 | *"La ville est en faillite."* |
| Timer atteint 00:00 | *"Temps écoulé ! La ville n'a pas été sauvée à temps."* |

---

## Lancer le jeu

### Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.12
- Dart ≥ 3.12 (inclus avec Flutter)
- Chrome (pour le mode web) **ou** un émulateur Android/iOS

### Installation

```bash
git clone https://github.com/anas-isarti/LATS-ONE-PROJECT.git
cd LATS-ONE-PROJECT
flutter pub get
```

### Lancer en mode web (recommandé pour la démo)

```bash
flutter run -d chrome
```

### Lancer sur Android

```bash
flutter run -d android
```

### Vérifier le code

```bash
flutter analyze   # lint
flutter test      # tests unitaires
```

---

## Paramétrage avant une partie

Sur l'écran d'accueil, deux sélecteurs configurent la partie avant de cliquer "NOUVELLE PARTIE".

### Scénario ADEME

Inspirés des scénarios de transition énergétique de l'ADEME :

| Scénario | Slogan | Effet en jeu |
|---|---|---|
| **Sobriété** | *Réduire pour mieux vivre* | Énergie verte : CO2 réduit ×1,5 · Industrie lourde : CO2 augmenté ×1,5 |
| **Technologie** | *Innover pour survivre* | Fusion / Nucléaire / Hydrogène : CO2 réduit ×1,5 · Innovation technologique plus fréquente |
| **Équilibre** | *Trouver le juste milieu* | Aucun bonus/malus — mode standard |

### Difficulté

| Niveau | Budget de départ | CO2 max | Événements négatifs |
|---|---|---|---|
| **Facile** | 8 000 ¥ | 250 | −50 % |
| **Moyen** | 5 000 ¥ | 200 | Standard |
| **Difficile** | 3 000 ¥ | 150 | +50 % |

---

## Déroulement d'une partie

### Structure d'un tour

1. **Phase libre** — Tu places autant de bâtiments que ton budget permet, dans n'importe quelle zone, dans n'importe quel ordre.
2. **Fin de tour** — Tu cliques "FIN DE TOUR X/3" :
   - Les revenus de tous tes bâtiments actifs s'ajoutent au budget
   - Un événement aléatoire adaptatif se déclenche (dialog affiché)
   - Les quêtes actives sont évaluées, les récompenses appliquées
   - De nouvelles quêtes adaptatives sont générées pour le tour suivant

### Timer

Le chrono de **20 minutes** tourne dès le début de la partie, en continu. Il est affiché dans le header. Il passe en **rouge** quand il reste moins de 5 minutes. S'il atteint 00:00 avant la fin du tour 3 → Game Over immédiat.

### Fin de partie

Après le tour 3, un écran récapitulatif affiche :
- Score final
- Nombre de bâtiments construits
- CO2 final
- Budget restant
- Message de performance (Excellent ≥ 6 000 pts / Bien joué ≥ 3 500 pts / Peut mieux faire)

Le **meilleur score de session** est conservé sur l'écran d'accueil.

---

## Les bâtiments (25 au total)

Chaque bâtiment ne peut être construit **qu'une seule fois**. Ils sont organisés en 5 zones.

### Zone Énergie (Production)

| Bâtiment | Coût | CO2 | Revenus/tour |
|---|---|---|---|
| Solaire | 500 ¥ | −10 | +50 ¥ |
| Éolien | 400 ¥ | −8 | +40 ¥ |
| Géothermique | 600 ¥ | −12 | +60 ¥ |
| Hydrogène | 800 ¥ | −15 | +80 ¥ |
| Hydraulique | 1 500 ¥ | −30 | +150 ¥ |
| Nucléaire | 2 000 ¥ | −50 | +200 ¥ |
| Fusion | 5 000 ¥ | −100 | +500 ¥ |

### Zone Transport

| Bâtiment | Coût | CO2 | Revenus/tour |
|---|---|---|---|
| Piste banade | 100 ¥ | −3 | +5 ¥ |
| Réseaux distribution | 250 ¥ | +3 | +15 ¥ |
| Réseau eau/gaz | 300 ¥ | +5 | +20 ¥ |
| Bus/tram électrique | 450 ¥ | −8 | +25 ¥ |
| Transport hybride (HTA) | 700 ¥ | −5 | +30 ¥ |

### Zone Services publics (Distribution)

| Bâtiment | Coût | CO2 | Revenus/tour |
|---|---|---|---|
| Pompiers | 250 ¥ | +2 | 0 ¥ |
| Police | 300 ¥ | +3 | 0 ¥ |
| École | 400 ¥ | +5 | 0 ¥ |
| Supermarché | 350 ¥ | +10 | +50 ¥ |
| Hôpital | 800 ¥ | +8 | 0 ¥ |
| Gare | 600 ¥ | +15 | +80 ¥ |

### Zone Entreprises

| Bâtiment | Coût | CO2 | Revenus/tour |
|---|---|---|---|
| Commerces | 400 ¥ | +15 | +100 ¥ |
| Bureaux | 500 ¥ | +10 | +80 ¥ |
| Usines | 800 ¥ | +40 | +150 ¥ |
| Industrie lourde | 1 000 ¥ | +50 | +200 ¥ |

### Zone Particuliers (Résidentiel)

| Bâtiment | Coût | CO2 | Revenus/tour |
|---|---|---|---|
| Logements résidentiels | 200 ¥ | +5 | +30 ¥ |
| Maisons individuelles | 250 ¥ | +10 | +40 ¥ |
| Appartements | 300 ¥ | +8 | +50 ¥ |

---

## Système d'événements adaptatifs

À chaque fin de tour, un événement est tiré au sort parmi 9 possibles. Le tirage est **pondéré** en fonction de l'état de ta ville.

| Événement | Effet | Déclencheur adaptatif |
|---|---|---|
| Crise énergétique | −500 ¥, CO2 +30 | ×2 si aucun bâtiment énergie |
| Subvention verte | +800 ¥, CO2 −10 | ×1,5 si CO2 < 25 % du max |
| Catastrophe naturelle | −1 000 ¥, CO2 +20 | Aléatoire |
| Boom économique | +600 ¥, CO2 +15 | ×1,5 si ≥ 2 entreprises |
| Pic de pollution | −200 ¥, CO2 +40 | ×2 si CO2 > 50 % du max |
| Aide internationale | +400 ¥, CO2 −5 | Aléatoire |
| Révolte citoyenne | −300 ¥ | ×3 si aucun service public après tour 1 |
| Innovation technologique | +400 ¥, CO2 −10 | ×2 si > 3 bâtiments énergie verte |
| Inspection environnementale | Variable | CO2 > 100 → −500 ¥ · CO2 < 0 → +300 ¥ |

Les événements négatifs sont multipliés ou divisés selon la difficulté choisie.

---

## Système de quêtes adaptatif

Jusqu'à **3 quêtes actives** simultanément. Le système analyse **7 signaux** pour proposer les quêtes les plus pertinentes :

- Zones négligées (énergie, transport, services publics)
- Niveau de CO2 actuel
- Pression sur le budget
- Nombre total de bâtiments construits
- Diversité des zones utilisées
- Tours restants
- Quêtes déjà complétées (jamais reproposées)

Au tour 3, seules les quêtes avec une récompense ≥ 400 ¥ sont proposées.

| Quête | Objectif | Récompense |
|---|---|---|
| Pionnier de l'énergie | 2 bâtiments énergie | +300 ¥ |
| Ville pour tous | 3 services publics | +400 ¥ |
| Ville connectée | 2 infrastructures transport | +250 ¥ |
| Gestionnaire prudent | Budget > 1 000 ¥ | +200 ¥ |
| Indépendance énergétique | 4 bâtiments énergie | +600 ¥ |
| Objectif zéro carbone | Réduire CO2 de 50 unités | +800 ¥ |
| Équilibre parfait | Bâtiments dans ≥ 3 zones différentes | +500 ¥ |
| CO2 négatif | Atteindre un bilan CO2 < 0 | +600 ¥ |
| Gestionnaire expert | Terminer un tour avec > 3 000 ¥ | +400 ¥ |
| Urbaniste complet | 8 bâtiments au total | +700 ¥ |
| Zéro pollution | Ne jamais dépasser CO2 = 50 | +1 000 ¥ |

---

## Simulation NFC (démo sans hardware)

Le jeu est conçu pour être piloté par des **cartes NFC physiques** posées sur une maquette. Un ESP32 lit les tags et envoie les données à Flutter via WiFi.

Pour la démo sans matériel, un bouton **contactless** (coin bas-droit de l'écran de jeu) ouvre un panneau permettant de choisir n'importe quel bâtiment à "scanner". Cela déclenche exactement la même logique de jeu qu'un vrai tag NFC.

Pour connecter le vrai ESP32 en production :

```dart
context.read<NfcController>().startPolling('http://192.168.x.x');
```

Format JSON attendu de l'ESP32 :

```json
{ "batiment": "solaire", "zone": "energie", "id": "scan_unique_001" }
```

---

## Architecture technique

```
Flutter (Dart)            → logique du jeu + UI complète
ESP32 + 4× PN532         → lecture NFC physique (multiplexeur TCA9548A)
HTTP/JSON WiFi            → communication ESP32 ↔ Flutter
GitHub Actions            → CI/CD automatique à chaque push sur main
```

### Pattern Provider

L'état est géré via le pattern Provider (3 controllers injectés au niveau racine) :

```
MultiProvider
├── GameController    → état du jeu, timer, scénarios, événements
├── QuestController   → quêtes adaptatives
└── NfcController     → polling ESP32 / simulation
```

---

## Structure du projet

```
lib/
├── main.dart
├── models/
│   ├── building.dart       # Bâtiment : nom, zone, coût, CO2, revenus, nfcId
│   ├── zone.dart           # Zone : type enum → nfcZoneId string
│   ├── game_state.dart     # État global : budget, CO2, tour, score (getter)
│   ├── quest.dart          # Quête : type, objectif, récompense
│   ├── event.dart          # Événement : type, impacts, poids
│   └── scenario.dart       # Enums Scenario et Difficulty
├── data/
│   ├── buildings_data.dart # 25 bâtiments
│   ├── events_data.dart    # 9 événements
│   └── quests_data.dart    # 12 quêtes
├── controllers/
│   ├── game_controller.dart   # Logique principale, timer, scénarios
│   ├── quest_controller.dart  # 7 signaux adaptatifs
│   └── nfc_controller.dart    # Polling ESP32 / simulation
├── screens/
│   ├── home_screen.dart    # Accueil : logo, sélecteurs, règles
│   ├── city_screen.dart    # Jeu : zones, bâtiments, FAB NFC, timer
│   ├── stats_screen.dart   # Stats en temps réel + historique
│   └── quest_screen.dart   # Quêtes actives et complétées
└── widgets/
    └── the_last_one_logo.dart  # Logo CustomPainter
```

---

## CI/CD

GitHub Actions se déclenche à chaque push sur `main` qui modifie `lib/`. Il :
1. Build Flutter Web
2. Crée une release versionnée automatiquement (v1, v2, v3…)

Repo : [https://github.com/anas-isarti/LATS-ONE-PROJECT](https://github.com/anas-isarti/LATS-ONE-PROJECT)

---

## Roadmap

- [ ] Intégration Unity pour affichage 3D de la ville
- [ ] Connexion hardware ESP32 + 4× PN532
- [ ] Persistance du meilleur score (SharedPreferences)
- [ ] Mode multijoueur / classement entre joueurs
- [ ] Animations de placement de bâtiments
