# THE LAST ONE - Document de contexte projet

## Concept
Jeu de gestion de ville Smart City interactif.
Le joueur gère une ville en faisant des choix (énergie, transport, industrie, services publics)
en respectant des contraintes de budget, de temps et d'impact environnemental (CO2).
Slogan : "Humanity had thousands of chances. This is the last one."

## Stack technique
- Flutter (Dart) : logique du jeu + UI complète
- Unity : affichage 3D uniquement (intégré dans Flutter via flutter_unity_widget)
- ESP32 + 4x PN532 via multiplexeur TCA9548A : lecture NFC physique
- Communication : HTTP/JSON WiFi entre ESP32 et Flutter
- GitHub Actions : CI/CD automatique à chaque modification de lib/

## Architecture du système
Carte NFC → PN532 (lecture) → ESP32 (traitement + WiFi) → Flutter (logique) → Unity (affichage 3D)

## Communication ESP32 → Flutter
Format JSON envoyé par l'ESP32 :
{ "batiment": "solaire", "zone": "energie" }
Flutter écoute via un serveur HTTP local.

## Zones du jeu (5 zones, 25 cartes NFC total)

### 1. Production (énergie)
- Solaire
- Éolien
- Nucléaire
- Hydraulique
- Hydrogène
- Géothermique
- Fusion

### 2. Transport / Trafic
- Réseau eau/gaz
- Transport hybride (HTA)
- Réseaux de distribution
- Piste banade
- Bus/tram électrique

### 3. Distribution Publique
- École
- Hôpital
- Police
- Supermarché
- Gare
- Pompiers

### 4. Utilisation Entreprises
- Industrie lourde
- Commerces
- Bureaux
- Usines

### 5. Utilisation Particuliers
- Logements résidentiels
- Appartements
- Maisons individuelles

## Mécaniques de jeu

### 3 ressources à gérer
- CO2 (impact environnemental) : doit rester sous un seuil
- Budget (argent) : limité, chaque bâtiment a un coût
- Temps : 3 tours/jours de jeu

### Règles
- Le joueur commence avec un budget de départ
- Chaque bâtiment placé a un coût et un impact CO2
- Certains bâtiments génèrent des revenus ou réduisent le CO2
- Si CO2 dépasse le seuil max → game over
- Si budget tombe à 0 → game over
- Objectif : construire une ville viable en 3 tours

### Système de quêtes adaptatives (ML-like)
- Le système analyse les choix du joueur (zones négligées, CO2 élevé, budget serré)
- Génère des quêtes et événements adaptés au profil du joueur
- Exemples de quêtes : "Construis 2 bâtiments énergétiques", "Réduis ton CO2 de 20%"
- Exemples d'événements : crise énergétique, subvention verte, catastrophe naturelle
- Les événements sont pondérés selon l'historique des choix

### Système de scoring
- Score final basé sur CO2 restant + budget restant + bâtiments construits
- Classement possible entre joueurs

## Structure du projet Flutter
lib/
models/          # Modèles de données
building.dart      # Bâtiment (nom, zone, coût, CO2, revenus)
zone.dart          # Zone (type, bâtiments actifs)
game_state.dart    # État global (budget, CO2, tour, score)
quest.dart         # Quête (type, objectif, récompense)
event.dart         # Événement (type, impact, durée)
controllers/     # Logique du jeu
game_controller.dart   # Contrôleur principal
quest_controller.dart  # Gestion des quêtes adaptatives
nfc_controller.dart    # Réception données ESP32
screens/         # Interfaces utilisateur
home_screen.dart       # Écran principal
city_screen.dart       # Vue de la ville
stats_screen.dart      # Stats CO2/budget/temps
quest_screen.dart      # Quêtes actives
widgets/         # Composants réutilisables
data/            # Données simulées pour tests
buildings_data.dart    # Liste de tous les bâtiments avec valeurs
events_data.dart       # Liste des événements possibles
quests_data.dart       # Liste des quêtes possibles

## Méthode de développement
1. D'abord tout développer avec données simulées (pas besoin du hardware)
2. Tester dans Chrome (flutter run -d chrome)
3. Intégrer Unity ensuite
4. Connecter le hardware ESP32 en dernier
5. Intégration finale

## Règles de développement
- Chaque fonctionnalité = commit séparé avec message clair
- Format commit : "feat: description" / "fix: description" / "refactor: description"
- Toujours tester dans Chrome avant de push
- Ne jamais push du code qui ne compile pas
- Approche évolutive : on part simple et on améliore

## CI/CD
- GitHub Actions déclenché à chaque push sur main qui modifie lib/
- Build Flutter Web automatique
- Release versionnée automatique (v1, v2, v3...)
- Repo : https://github.com/anas-isarti/LATS-ONE-PROJECT