import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/building.dart';
import '../models/event.dart';
import '../models/game_state.dart';
import '../models/scenario.dart';
import '../data/events_data.dart';

class TurnSummary {
  final int turn;
  final int revenueEarned;
  final String? eventTitle;
  final int co2AfterTurn;
  final int budgetAfterTurn;
  final int buildingsPlaced;

  const TurnSummary({
    required this.turn,
    required this.revenueEarned,
    this.eventTitle,
    required this.co2AfterTurn,
    required this.budgetAfterTurn,
    required this.buildingsPlaced,
  });
}

class GameController extends ChangeNotifier {
  GameState _state = GameState();
  GameEvent? _activeEvent;
  int _bestScore = 0;
  bool _isNewRecord = false;
  final List<TurnSummary> _turnHistory = [];
  int _buildingsAtTurnStart = 0;
  List<String> _needsPenaltiesLastTurn = [];

  Scenario _scenario = Scenario.balance;
  Difficulty _difficulty = Difficulty.medium;

  Timer? _gameTimer;
  int _secondsRemaining = 1200; // 20 minutes
  static const int _gameDuration = 1200;

  GameState get state => _state;
  GameEvent? get activeEvent => _activeEvent;
  int get bestScore => _bestScore;
  bool get isNewRecord => _isNewRecord;
  List<TurnSummary> get turnHistory => List.unmodifiable(_turnHistory);
  int get secondsRemaining => _secondsRemaining;
  Scenario get scenario => _scenario;
  Difficulty get difficulty => _difficulty;
  List<String> get needsPenaltiesLastTurn => List.unmodifiable(_needsPenaltiesLastTurn);

  bool get isTimerLow => _secondsRemaining <= 300; // < 5 min

  String get timerDisplay {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── Public API ──────────────────────────────────────────────────────────

  void startGame(Scenario scenario, Difficulty difficulty) {
    _scenario = scenario;
    _difficulty = difficulty;
    _state = GameState(
      startBudget: difficulty.startBudget,
      co2Max: difficulty.co2Max,
    );
    _activeEvent = null;
    _isNewRecord = false;
    _turnHistory.clear();
    _buildingsAtTurnStart = 0;
    _needsPenaltiesLastTurn = [];
    _secondsRemaining = _gameDuration;
    _startTimer();
    notifyListeners();
  }

  bool placeBuilding(Building building) {
    if (_state.isGameOver) return false;
    if (_state.budget < building.cost) return false;
    if (_state.activeBuildings.any((b) => b.nfcId == building.nfcId)) return false;

    _state.budget -= building.cost;
    final effectiveCo2 = _effectiveCo2Impact(building);
    _state.co2 += effectiveCo2;
    _updateMaxCo2();
    _state.activeBuildings.add(building);

    _checkGameOver();
    notifyListeners();
    return true;
  }

  void endTurn() {
    if (_state.isGameOver) return;

    final revenueEarned = _state.totalRevenue;
    _state.budget += revenueEarned;

    _applyNeedsPenalties();

    _activeEvent = _pickAdaptiveEvent();
    if (_activeEvent != null) {
      _applyEventEffect(_activeEvent!);
    }
    _updateMaxCo2();

    _turnHistory.add(TurnSummary(
      turn: _state.currentTurn,
      revenueEarned: revenueEarned,
      eventTitle: _activeEvent?.title,
      co2AfterTurn: _state.co2,
      budgetAfterTurn: _state.budget,
      buildingsPlaced: _state.activeBuildings.length - _buildingsAtTurnStart,
    ));

    _state.currentTurn++;
    _buildingsAtTurnStart = _state.activeBuildings.length;
    _checkGameOver();

    if (!_state.isGameOver && _state.currentTurn > _state.maxTurns) {
      if (_state.score > _bestScore) { _isNewRecord = true; _bestScore = _state.score; }
      _state.isGameOver = true;
      _state.gameOverReason = 'Fin de partie — 3 tours terminés.';
      _stopTimer();
    }

    notifyListeners();
  }

  // Legacy reset: restarts with stored scenario/difficulty
  void resetGame() => startGame(_scenario, _difficulty);

  // ── Timer ──────────────────────────────────────────────────────────────

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _triggerTimeout();
      }
    });
  }

  void _stopTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void _triggerTimeout() {
    _stopTimer();
    if (_state.isGameOver) return;
    if (_state.score > _bestScore) { _isNewRecord = true; _bestScore = _state.score; }
    _state.isGameOver = true;
    _state.gameOverReason = 'Temps écoulé ! La ville n\'a pas été sauvée à temps.';
    notifyListeners();
  }

  // ── Game over ──────────────────────────────────────────────────────────

  void _applyNeedsPenalties() {
    _needsPenaltiesLastTurn = [];
    final buildings = _state.activeBuildings;

    if (!buildings.any((b) => b.zone == ZoneType.production)) {
      _state.budget -= 400;
      _state.co2 += 15;
      _needsPenaltiesLastTurn.add('Pas d\'énergie : -400 ¥, CO2 +15');
    }
    if (!buildings.any((b) => b.zone == ZoneType.residential)) {
      _state.budget -= 250;
      _needsPenaltiesLastTurn.add('Pas de logements : -250 ¥');
    }
    if (!buildings.any((b) => b.zone == ZoneType.publicDistribution)) {
      _state.budget -= 200;
      _needsPenaltiesLastTurn.add('Pas de services publics (école, hôpital…) : -200 ¥');
    }
    if (!buildings.any((b) => b.zone == ZoneType.transport)) {
      _state.budget -= 150;
      _needsPenaltiesLastTurn.add('Pas de transport : -150 ¥');
    }
  }

  void _checkGameOver() {
    if (_state.isGameOver) return;
    if (_state.co2 >= _state.co2Max) {
      if (_state.score > _bestScore) { _isNewRecord = true; _bestScore = _state.score; }
      _state.isGameOver = true;
      _state.gameOverReason = 'CO2 trop élevé ! La ville est invivable.';
      _stopTimer();
    } else if (_state.budget <= 0) {
      if (_state.score > _bestScore) { _isNewRecord = true; _bestScore = _state.score; }
      _state.isGameOver = true;
      _state.gameOverReason = 'Budget épuisé ! La ville est en faillite.';
      _stopTimer();
    }
  }

  void _updateMaxCo2() {
    if (_state.co2 > _state.maxCo2EverReached) {
      _state.maxCo2EverReached = _state.co2;
    }
  }

  // ── Scenario multipliers ───────────────────────────────────────────────

  int _effectiveCo2Impact(Building building) {
    final base = building.co2Impact;
    switch (_scenario) {
      case Scenario.sobriety:
        // Green energy: 1.5× reduction
        if (building.zone == ZoneType.production && base < 0) {
          return (base * 1.5).round();
        }
        // Industrie lourde: 1.5× pollution
        if (building.nfcId == 'industrie_lourde') {
          return (base * 1.5).round();
        }
        return base;
      case Scenario.technology:
        const techBuildings = ['fusion', 'nucleaire', 'hydrogene'];
        if (techBuildings.contains(building.nfcId) && base < 0) {
          return (base * 1.5).round();
        }
        return base;
      case Scenario.balance:
        return base;
    }
  }

  // ── Event system ───────────────────────────────────────────────────────

  void _applyEventEffect(GameEvent event) {
    if (event.id == 'environmental_inspection') {
      if (_state.co2 > 100) {
        _state.budget -= 500;
      } else if (_state.co2 < 0) {
        _state.budget += 300;
      }
      return;
    }
    _state.budget += event.budgetImpact;
    _state.co2 += event.co2Impact;
  }

  bool _isNegativeEvent(GameEvent e) =>
      e.type == EventType.energyCrisis ||
      e.type == EventType.naturalDisaster ||
      e.type == EventType.pollution ||
      e.type == EventType.citizenRevolt;

  GameEvent? _pickAdaptiveEvent() {
    final energyCount = _state.activeBuildings
        .where((b) => b.zone == ZoneType.production)
        .length;
    final greenEnergyCount = _state.activeBuildings
        .where((b) => b.zone == ZoneType.production && b.co2Impact < 0)
        .length;
    final hasPublicServices = _state.activeBuildings
        .any((b) => b.zone == ZoneType.publicDistribution);
    final co2Ratio = _state.co2 / _state.co2Max;
    final enterpriseCount = _state.activeBuildings
        .where((b) => b.zone == ZoneType.enterprise)
        .length;

    final totalGreenCount = _state.activeBuildings
        .where((b) => b.co2Impact < 0)
        .length;

    final weighted = allEvents.map((e) {
      double w = e.weight;

      // Negative event difficulty multiplier
      if (_isNegativeEvent(e)) w *= _difficulty.negativeEventMultiplier;

      // Green subsidy requires actual ecological effort from the player
      if (e.type == EventType.greenSubsidy && totalGreenCount == 0) w = 0.0;

      // Adaptive weights
      if (e.type == EventType.energyCrisis && energyCount == 0) w *= 2.0;
      if (e.type == EventType.pollution && co2Ratio > 0.5) w *= 2.0;
      if (e.type == EventType.greenSubsidy && co2Ratio < 0.25) w *= 1.5;
      if (e.type == EventType.economicBoom && enterpriseCount >= 2) w *= 1.5;

      // New events
      if (e.id == 'citizen_revolt' &&
          !hasPublicServices &&
          _state.currentTurn > 1) { w *= 3.0; }

      if (e.id == 'tech_innovation' && greenEnergyCount > 3) { w *= 2.0; }

      // Technologie scenario: boost tech innovation
      if (_scenario == Scenario.technology && e.id == 'tech_innovation') {
        w *= 2.0;
      }

      return MapEntry(e, w);
    }).toList();

    final total = weighted.fold(0.0, (sum, e) => sum + e.value);
    double rand = Random().nextDouble() * total;

    for (final entry in weighted) {
      rand -= entry.value;
      if (rand <= 0) return entry.key;
    }
    return weighted.last.key;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
