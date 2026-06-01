import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/building.dart';
import '../models/event.dart';
import '../models/game_state.dart';
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
  final List<TurnSummary> _turnHistory = [];
  int _buildingsAtTurnStart = 0;

  GameState get state => _state;
  GameEvent? get activeEvent => _activeEvent;
  int get bestScore => _bestScore;
  List<TurnSummary> get turnHistory => List.unmodifiable(_turnHistory);

  bool placeBuilding(Building building) {
    if (_state.isGameOver) return false;
    if (_state.budget < building.cost) return false;
    if (_state.activeBuildings.any((b) => b.nfcId == building.nfcId)) return false;

    _state.budget -= building.cost;
    _state.co2 += building.co2Impact;
    _state.activeBuildings.add(building);

    _checkGameOver();
    notifyListeners();
    return true;
  }

  void endTurn() {
    if (_state.isGameOver) return;

    final revenueEarned = _state.totalRevenue;
    _state.budget += revenueEarned;

    _activeEvent = _pickAdaptiveEvent();
    if (_activeEvent != null) {
      _state.budget += _activeEvent!.budgetImpact;
      _state.co2 += _activeEvent!.co2Impact;
    }

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
      if (_state.score > _bestScore) _bestScore = _state.score;
      _state.isGameOver = true;
      _state.gameOverReason = 'Fin de partie — 3 tours terminés.';
    }

    notifyListeners();
  }

  void resetGame() {
    _state = GameState();
    _activeEvent = null;
    _turnHistory.clear();
    _buildingsAtTurnStart = 0;
    notifyListeners();
  }

  void _checkGameOver() {
    if (_state.co2 >= _state.co2Max) {
      if (_state.score > _bestScore) _bestScore = _state.score;
      _state.isGameOver = true;
      _state.gameOverReason = 'CO2 trop élevé ! La ville est invivable.';
    } else if (_state.budget <= 0) {
      if (_state.score > _bestScore) _bestScore = _state.score;
      _state.isGameOver = true;
      _state.gameOverReason = 'Budget épuisé ! La ville est en faillite.';
    }
  }

  GameEvent? _pickAdaptiveEvent() {
    final energyCount = _state.activeBuildings
        .where((b) => b.zone == ZoneType.production)
        .length;
    final co2Ratio = _state.co2 / _state.co2Max;

    final weighted = allEvents.map((e) {
      double w = e.weight;
      if (e.type == EventType.energyCrisis && energyCount == 0) w *= 2.0;
      if (e.type == EventType.pollution && co2Ratio > 0.5) w *= 2.0;
      if (e.type == EventType.greenSubsidy && co2Ratio < 0.25) w *= 1.5;
      if (e.type == EventType.economicBoom) {
        final enterpriseCount = _state.activeBuildings
            .where((b) => b.zone == ZoneType.enterprise)
            .length;
        if (enterpriseCount >= 2) w *= 1.5;
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
}
