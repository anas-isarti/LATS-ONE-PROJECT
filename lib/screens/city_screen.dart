import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../controllers/quest_controller.dart';
import '../controllers/nfc_controller.dart';
import '../models/building.dart';
import '../models/game_state.dart';
import '../data/buildings_data.dart';
import 'stats_screen.dart';
import 'quest_screen.dart';

const _kGold = Color(0xFFFFD700);
const _kGreen = Color(0xFF4CAF50);
const _kRed = Color(0xFFE53935);
const _kBlue = Color(0xFF2196F3);
const _kCard = Color(0xFF1A1A1A);

extension _ZoneExt on ZoneType {
  String get label => switch (this) {
        ZoneType.production => 'Énergie',
        ZoneType.transport => 'Transport énergie',
        ZoneType.publicDistribution => 'Services',
        ZoneType.enterprise => 'Entreprises',
        ZoneType.residential => 'Particuliers',
      };

  IconData get icon => switch (this) {
        ZoneType.production => Icons.bolt,
        ZoneType.transport => Icons.electrical_services,
        ZoneType.publicDistribution => Icons.school,
        ZoneType.enterprise => Icons.business,
        ZoneType.residential => Icons.home,
      };

  String get nfcZoneId => switch (this) {
        ZoneType.production => 'energie',
        ZoneType.transport => 'transport',
        ZoneType.publicDistribution => 'distribution',
        ZoneType.enterprise => 'entreprises',
        ZoneType.residential => 'particuliers',
      };
}

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;
  late final TabController _zoneTab;
  bool _gameOverShown = false;

  @override
  void initState() {
    super.initState();
    _zoneTab = TabController(length: ZoneType.values.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().addListener(_onGameChanged);
      context.read<NfcController>().addListener(_onNfcScan);
    });
  }

  @override
  void dispose() {
    _zoneTab.dispose();
    try {
      context.read<GameController>().removeListener(_onGameChanged);
      context.read<NfcController>().removeListener(_onNfcScan);
    } catch (_) {}
    super.dispose();
  }

  void _onGameChanged() {
    if (!mounted) return;
    final isOver = context.read<GameController>().state.isGameOver;
    if (isOver && !_gameOverShown) {
      _gameOverShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showGameOverDialog();
      });
    }
  }

  void _onNfcScan() {
    if (!mounted) return;
    final scan = context.read<NfcController>().lastScan;
    if (scan == null) return;

    final template =
        allBuildings.where((b) => b.nfcId == scan.buildingNfcId).firstOrNull;
    if (template == null) return;

    _showParamDialog(template);
  }

  /// Ouvre le dialog de configuration des paramètres, puis place le bâtiment.
  Future<void> _showParamDialog(Building template) async {
    final gameCtrl = context.read<GameController>();
    if (gameCtrl.state.isGameOver) return;
    if (gameCtrl.state.activeBuildings.any((b) => b.nfcId == template.nfcId)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Déjà construit'),
        duration: Duration(seconds: 1),
      ));
      return;
    }

    // Copie fraîche du bâtiment avec paramètres à leur valeur par défaut
    final fresh = template.withFreshParameters();

    final confirmed = await showDialog<Building>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ParamDialog(building: fresh),
    );

    if (confirmed == null || !mounted) return;
    _placeBuilding(confirmed);
  }

  void _placeBuilding(Building building) {
    final gameCtrl = context.read<GameController>();
    final questCtrl = context.read<QuestController>();
    final placed = gameCtrl.placeBuilding(building);
    if (placed) {
      final reward = questCtrl.evaluateAndReward(gameCtrl.state);
      if (reward > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Quête accomplie ! +$reward ¥'),
          backgroundColor: _kGreen,
          duration: const Duration(seconds: 2),
        ));
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Budget insuffisant pour ces paramètres'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void _onEndTurn() {
    final gameCtrl = context.read<GameController>();
    final questCtrl = context.read<QuestController>();
    final turnNumber = gameCtrl.state.currentTurn;
    gameCtrl.endTurn();
    questCtrl.evaluateAndReward(gameCtrl.state);
    questCtrl.generateAdaptiveQuests(gameCtrl.state);

    if (!mounted || gameCtrl.state.isGameOver) return;

    final event = gameCtrl.activeEvent;
    final penalties = gameCtrl.needsPenaltiesLastTurn;

    if (penalties.isNotEmpty || event != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _kCard,
          title: Text('Fin du tour $turnNumber',
              style: const TextStyle(
                  color: _kGold, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (penalties.isNotEmpty) ...[
                  const Text('Infrastructures manquantes / pertes',
                      style: TextStyle(
                          color: _kRed,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...penalties.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                size: 13, color: _kRed),
                            const SizedBox(width: 5),
                            Expanded(
                                child: Text(p,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11))),
                          ],
                        ),
                      )),
                  if (event != null)
                    const Divider(color: Colors.white12, height: 18),
                ],
                if (event != null) ...[
                  Text(event.title,
                      style: const TextStyle(
                          color: _kGold, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(event.description,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK', style: TextStyle(color: _kGold)),
            ),
          ],
        ),
      );
    }
  }

  void _showNfcSimSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetCtx) => _NfcSimSheet(
        onScan: (building) {
          Navigator.pop(sheetCtx);
          _showParamDialog(building);
        },
      ),
    );
  }

  String _buildPerformanceMessage(GameController gameCtrl) {
    final state = gameCtrl.state;
    final buildings = state.activeBuildings;
    final greenCount = buildings.where((b) => b.co2Impact < 0).length;
    final heavyPolluters =
        buildings.where((b) => b.co2Impact >= 40).length;
    final zones = buildings.map((b) => b.zone).toSet().length;
    final co2 = state.co2;
    final budget = state.budget;
    final score = state.score;
    final bestScore = gameCtrl.bestScore;
    final history = gameCtrl.turnHistory;

    final points = <String>[];

    // Indice énergétique
    final ei = state.energyIndex;
    if (ei >= 1.2) {
      points.add(
          'Excellent indice énergétique (${ei.toStringAsFixed(2)}) : votre réseau distribue plus que nécessaire !');
    } else if (ei >= 0.8) {
      points.add(
          'Indice énergétique correct (${ei.toStringAsFixed(2)}) : quelques bâtiments de transport supplémentaires amélioreraient la distribution.');
    } else if (ei < 0.5) {
      points.add(
          'Indice énergétique critique (${ei.toStringAsFixed(2)}) : investissez dans le transport d\'énergie (réseau HT, postes, stockage).');
    }

    // Taux d\'électrification
    final elec = (state.electrificationRate * 100).round();
    if (elec >= 70) {
      points.add('Taux d\'électrification élevé ($elec %) : bravo pour la transition !');
    } else if (elec < 30) {
      points.add(
          'Taux d\'électrification faible ($elec %) : configurez les paramètres de vos bâtiments pour électrifier davantage.');
    }

    // CO2
    if (co2 < 0) {
      points.add(
          'CO2 négatif ($co2) : votre ville absorbe plus de carbone qu\'elle n\'en émet. Exemplaire !');
    } else if (co2 < state.co2Max ~/ 4) {
      points.add(
          'CO2 bien maîtrisé ($co2/${state.co2Max}) : vous gérez bien l\'impact écologique.');
    } else if (co2 > (state.co2Max * 0.75).round()) {
      points.add(
          'CO2 critique ($co2/${state.co2Max}) : investissez en priorité dans les énergies vertes dès le 1er tour.');
    }

    if (greenCount == 0) {
      points.add(
          'Aucun bâtiment écologique : solaire, éolien et hydraulique réduisent le CO2 et génèrent des revenus.');
    } else if (greenCount >= 4) {
      points.add('$greenCount bâtiments écologiques : belle transition énergétique !');
    }

    if (heavyPolluters >= 2) {
      points.add(
          '$heavyPolluters industrie(s) lourde(s)/usine(s) : revenus intéressants mais CO2 très élevé — compensez avec du vert.');
    }

    if (zones < 2) {
      points.add(
          '1 seule zone exploitée : diversifiez votre ville pour débloquer plus de quêtes et de revenus.');
    } else if (zones >= 4) {
      points.add('$zones zones développées : urbanisme équilibré, bravo !');
    }

    if (budget > 3000) {
      points.add(
          'Budget très sain ($budget ¥ restants) : vous n\'avez peut-être pas assez investi dans vos infrastructures.');
    } else if (budget < 300) {
      points.add(
          'Budget très serré ($budget ¥) : priorisez les bâtiments à revenus (éolien, solaire, hydraulique).');
    }

    if (gameCtrl.isNewRecord) {
      points.add(
          'Nouveau record ! Votre meilleur score est maintenant $bestScore pts.');
    } else if (bestScore > 0) {
      final gap = bestScore - score;
      points.add(
          'Score de $score pts, à $gap pts de votre record ($bestScore) — vous pouvez le battre !');
    }

    if (history.length >= 2) {
      final co2Rise =
          history.last.co2AfterTurn - history.first.co2AfterTurn;
      if (co2Rise > 30) {
        points.add(
            'CO2 en forte hausse entre les tours (+$co2Rise) : anticipez l\'écologie plus tôt.');
      }
    }

    return '• ${points.join('\n• ')}';
  }

  void _showGameOverDialog() {
    final gameCtrl = context.read<GameController>();
    final state = gameCtrl.state;
    final score = state.score;
    final isWin = state.currentTurn > state.maxTurns;

    final performanceMsg = _buildPerformanceMessage(gameCtrl);

    final co2 = state.co2;
    Color perfColor;
    if (score >= 3000 || co2 < 0) {
      perfColor = _kGreen;
    } else if (score >= 1500 && co2 < state.co2Max ~/ 2) {
      perfColor = _kGold;
    } else {
      perfColor = Colors.white54;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kCard,
        title: Text(
          isWin ? 'Partie terminée !' : 'GAME OVER',
          style: const TextStyle(
              color: _kGold, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(state.gameOverReason ?? '',
                  style: const TextStyle(color: Colors.white60, height: 1.4)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: _kGreen.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Score final : $score',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: _kGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              _DialogStat(Icons.domain, 'Bâtiments construits',
                  '${state.activeBuildings.length}'),
              _DialogStat(Icons.cloud_outlined, 'CO2 final',
                  '${state.co2} / ${state.co2Max}'),
              _DialogStat(Icons.bolt, 'Indice énergétique',
                  state.energyIndex.toStringAsFixed(2)),
              _DialogStat(Icons.electric_bolt, 'Taux d\'électrification',
                  '${(state.electrificationRate * 100).round()} %'),
              _DialogStat(Icons.monetization_on_outlined, 'Budget restant',
                  '${state.budget} ¥'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  performanceMsg,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: perfColor,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      height: 1.5),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40)),
            child: const Text('Retour au menu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameCtrl = context.watch<GameController>();
    final state = gameCtrl.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('THE LAST ONE'),
        automaticallyImplyLeading: false,
        bottom: _navIndex == 0
            ? TabBar(
                controller: _zoneTab,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: ZoneType.values
                    .map((z) =>
                        Tab(icon: Icon(z.icon, size: 16), text: z.label))
                    .toList(),
              )
            : null,
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _showNfcSimSheet,
        backgroundColor: _kCard,
        foregroundColor: _kGold,
        tooltip: 'Simuler scan NFC',
        child: const Icon(Icons.contactless),
      ),
      body: Column(
        children: [
          _StatsHeader(
              state: state,
              timerDisplay: gameCtrl.timerDisplay,
              isTimerLow: gameCtrl.isTimerLow),
          Expanded(
            child: IndexedStack(
              index: _navIndex,
              children: [
                TabBarView(
                  controller: _zoneTab,
                  children: ZoneType.values
                      .map((zone) => _BuildingList(
                          zone: zone,
                          onPlace: _showParamDialog))
                      .toList(),
                ),
                const StatsScreen(),
                const QuestScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_navIndex == 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: ElevatedButton(
                onPressed: state.isGameOver ? null : _onEndTurn,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                child: Text(
                    'FIN DE TOUR ${state.currentTurn} / ${state.maxTurns}'),
              ),
            ),
          BottomNavigationBar(
            currentIndex: _navIndex,
            onTap: (i) => setState(() => _navIndex = i),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.location_city), label: 'Ville'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart), label: 'Stats'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.task_alt), label: 'Quêtes'),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Dialog de configuration des paramètres ────────────────────────────────────

class _ParamDialog extends StatefulWidget {
  final Building building;
  const _ParamDialog({required this.building});

  @override
  State<_ParamDialog> createState() => _ParamDialogState();
}

class _ParamDialogState extends State<_ParamDialog> {
  late final Building _building;

  @override
  void initState() {
    super.initState();
    _building = widget.building;
  }

  int get _totalCost => _building.totalCost;
  double get _totalCo2 => _building.totalCo2Impact;
  double get _netEnergy => _building.netEnergy;

  @override
  Widget build(BuildContext context) {
    final state = context.read<GameController>().state;
    final canAfford = state.budget >= _totalCost;

    return AlertDialog(
      backgroundColor: _kCard,
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(_building.zone.icon, color: _kGold, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_building.name,
                  style: const TextStyle(
                      color: _kGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ]),
          const SizedBox(height: 10),
          // Résumé coût / CO2 / énergie en temps réel
          _LiveSummary(
            baseCost: _building.cost,
            totalCost: _totalCost,
            totalCo2: _totalCo2,
            netEnergy: _netEnergy,
            canAfford: canAfford,
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _building.parameters.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Aucun paramètre configurable.',
                    style: TextStyle(color: Colors.white54)),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: _building.parameters.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Colors.white10, height: 20),
                itemBuilder: (_, i) {
                  final p = _building.parameters[i];
                  return _ParamControl(
                    param: p,
                    onChanged: () => setState(() {}),
                  );
                },
              ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Annuler',
              style: TextStyle(color: Colors.white38)),
        ),
        ElevatedButton(
          onPressed: canAfford
              ? () => Navigator.pop(context, _building)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canAfford ? _kGold : Colors.white24,
            foregroundColor: Colors.black,
          ),
          child: Text(canAfford
              ? 'Placer ($_totalCost ¥)'
              : 'Budget insuffisant'),
        ),
      ],
    );
  }
}

class _LiveSummary extends StatelessWidget {
  final int baseCost;
  final int totalCost;
  final double totalCo2;
  final double netEnergy;
  final bool canAfford;

  const _LiveSummary({
    required this.baseCost,
    required this.totalCost,
    required this.totalCo2,
    required this.netEnergy,
    required this.canAfford,
  });

  @override
  Widget build(BuildContext context) {
    final paramCost = totalCost - baseCost;
    final co2Sign = totalCo2 >= 0 ? '+' : '';
    final co2Color = totalCo2 <= 0 ? _kGreen : _kRed;
    final energySign = netEnergy >= 0 ? '+' : '';
    final energyColor = netEnergy >= 0 ? _kBlue : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: canAfford
                ? _kGold.withValues(alpha: 0.3)
                : _kRed.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryChip(
            icon: Icons.monetization_on_outlined,
            label: '$totalCost ¥',
            sub: paramCost > 0 ? '+$paramCost param.' : 'base',
            color: canAfford ? _kGold : _kRed,
          ),
          _SummaryChip(
            icon: Icons.cloud_outlined,
            label: '$co2Sign${totalCo2.toStringAsFixed(1)}',
            sub: 'CO2',
            color: co2Color,
          ),
          _SummaryChip(
            icon: Icons.bolt,
            label: '$energySign${netEnergy.toStringAsFixed(1)} MWh',
            sub: 'Énergie',
            color: energyColor,
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  const _SummaryChip(
      {required this.icon,
      required this.label,
      required this.sub,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      Text(sub,
          style: const TextStyle(color: Colors.white38, fontSize: 9)),
    ]);
  }
}

// ── Contrôle d'un paramètre ────────────────────────────────────────────────────

class _ParamControl extends StatefulWidget {
  final BuildingParameter param;
  final VoidCallback onChanged;
  const _ParamControl({required this.param, required this.onChanged});

  @override
  State<_ParamControl> createState() => _ParamControlState();
}

class _ParamControlState extends State<_ParamControl> {
  BuildingParameter get p => widget.param;

  String get _unitLabel =>
      p.unit.isNotEmpty ? ' ${p.unit}' : '';

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: Text(p.label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          Text('${_fmt(p.value)}$_unitLabel',
              style: const TextStyle(
                  color: _kGold, fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 4),
        _buildControl(),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (p.co2PerUnit != 0)
              _MiniChip(
                icon: Icons.cloud_outlined,
                label:
                    '${p.co2PerUnit >= 0 ? '+' : ''}${(p.co2Contribution).toStringAsFixed(1)} CO2',
                color: p.co2Contribution <= 0 ? _kGreen : _kRed,
              ),
            if (p.energyPerUnit != 0)
              _MiniChip(
                icon: Icons.bolt,
                label:
                    '${p.energyContribution >= 0 ? '+' : ''}${p.energyContribution.toStringAsFixed(1)} MWh',
                color: p.energyContribution >= 0 ? _kBlue : Colors.orange,
              ),
            if (p.additionalCost > 0)
              _MiniChip(
                icon: Icons.monetization_on_outlined,
                label: '+${p.additionalCost} ¥',
                color: Colors.white54,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildControl() {
    switch (p.controlType) {
      case ParamControlType.toggle:
        return Row(children: [
          Switch(
            value: p.value == 1,
            onChanged: (v) {
              setState(() => p.setValue(v ? 1 : 0));
              widget.onChanged();
            },
            activeColor: _kGold,
          ),
          Text(p.value == 1 ? 'Activé' : 'Désactivé',
              style: TextStyle(
                  color: p.value == 1 ? _kGold : Colors.white38,
                  fontSize: 11)),
        ]);

      case ParamControlType.stepper:
        return Row(
          children: List.generate(p.maxValue.round(), (i) {
            final level = i + 1;
            final selected = level <= p.value.round();
            return GestureDetector(
              onTap: () {
                setState(() => p.setValue(level.toDouble()));
                widget.onChanged();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: selected
                      ? _kGold.withValues(alpha: 0.2)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: selected ? _kGold : Colors.white12),
                ),
                child: Center(
                  child: Text('$level',
                      style: TextStyle(
                          color: selected ? _kGold : Colors.white38,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ),
            );
          }),
        );

      case ParamControlType.slider:
        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _kGold,
            thumbColor: _kGold,
            inactiveTrackColor: Colors.white12,
            overlayColor: _kGold.withValues(alpha: 0.1),
            trackHeight: 3,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: p.value,
            min: p.minValue,
            max: p.maxValue,
            divisions: ((p.maxValue - p.minValue) / _sliderStep).round(),
            onChanged: (v) {
              setState(() => p.setValue(v));
              widget.onChanged();
            },
          ),
        );
    }
  }

  double get _sliderStep {
    final range = p.maxValue - p.minValue;
    if (range <= 10) return 1;
    if (range <= 100) return 5;
    if (range <= 500) return 10;
    return 50;
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MiniChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 9, color: color),
      const SizedBox(width: 2),
      Text(label, style: TextStyle(fontSize: 9, color: color)),
    ]);
  }
}

// ── NFC Simulation sheet ───────────────────────────────────────────────────────

class _NfcSimSheet extends StatelessWidget {
  final void Function(Building) onScan;
  const _NfcSimSheet({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            children: [
              const Icon(Icons.contactless, color: _kGold, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Simulation NFC',
                        style: TextStyle(
                            color: _kGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    Text('Choisir un bâtiment à scanner',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close,
                    color: Colors.white38, size: 18),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white12),
        SizedBox(
          height: 320,
          child: ListView.builder(
            itemCount: allBuildings.length,
            itemBuilder: (_, i) {
              final b = allBuildings[i];
              return ListTile(
                dense: true,
                leading: Icon(b.zone.icon, color: _kGold, size: 18),
                title: Text(b.name,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white)),
                subtitle: Text(b.zone.label,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11)),
                trailing: Text('${b.cost} ¥+',
                    style: const TextStyle(
                        color: _kGold, fontSize: 11)),
                onTap: () => onScan(b),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Stats header ───────────────────────────────────────────────────────────────

class _StatsHeader extends StatelessWidget {
  final GameState state;
  final String timerDisplay;
  final bool isTimerLow;
  const _StatsHeader({
    required this.state,
    required this.timerDisplay,
    required this.isTimerLow,
  });

  @override
  Widget build(BuildContext context) {
    final co2Ratio = (state.co2 / state.co2Max).clamp(0.0, 1.0);
    final co2Color =
        co2Ratio < 0.5 ? _kGreen : co2Ratio < 0.75 ? Colors.orange : _kRed;
    final ei = state.energyIndex;
    final eiColor = ei >= 1.0 ? _kBlue : ei >= 0.6 ? Colors.orange : _kRed;
    final elec = (state.electrificationRate * 100).round();

    return Container(
      color: _kCard,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // CO2
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.cloud_outlined,
                          size: 12, color: co2Color),
                      const SizedBox(width: 4),
                      Text('CO2 ${state.co2}/${state.co2Max}',
                          style: TextStyle(
                              fontSize: 11,
                              color: co2Color,
                              fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: co2Ratio,
                      minHeight: 5,
                      color: co2Color,
                      backgroundColor: Colors.white10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Indice énergétique
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.bolt, size: 11, color: eiColor),
                    const SizedBox(width: 2),
                    Text(ei.toStringAsFixed(2),
                        style: TextStyle(
                            color: eiColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ]),
                  Text('Énergie',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 8)),
                ],
              ),
              const SizedBox(width: 8),
              // Taux électrification
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.electric_bolt,
                        size: 11, color: _kGold),
                    const SizedBox(width: 2),
                    Text('$elec %',
                        style: const TextStyle(
                            color: _kGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ]),
                  const Text('Élec.',
                      style: TextStyle(
                          color: Colors.white38, fontSize: 8)),
                ],
              ),
              const SizedBox(width: 8),
              // Budget
              Expanded(
                flex: 3,
                child: Row(children: [
                  const Icon(Icons.monetization_on_outlined,
                      size: 13, color: _kGold),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text('${state.budget} ¥',
                        style: const TextStyle(
                            color: _kGold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ),
              const SizedBox(width: 6),
              // Tour
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('T${state.currentTurn}/${state.maxTurns}',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 6),
              // Timer
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isTimerLow
                      ? _kRed.withValues(alpha: 0.15)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.timer_outlined,
                      size: 11,
                      color: isTimerLow ? _kRed : Colors.white54),
                  const SizedBox(width: 3),
                  Text(timerDisplay,
                      style: TextStyle(
                          color:
                              isTimerLow ? _kRed : Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _CityNeedsRow(buildings: state.activeBuildings),
        ],
      ),
    );
  }
}

class _CityNeedsRow extends StatelessWidget {
  final List<Building> buildings;
  const _CityNeedsRow({required this.buildings});

  @override
  Widget build(BuildContext context) {
    const needs = [
      (ZoneType.production, Icons.bolt, 'Énergie'),
      (ZoneType.residential, Icons.home, 'Logements'),
      (ZoneType.publicDistribution, Icons.school, 'Services'),
      (ZoneType.transport, Icons.electrical_services, 'Transport'),
      (ZoneType.enterprise, Icons.business, 'Économie'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: needs.map((n) {
        final (zone, icon, label) = n;
        final isCritical = zone != ZoneType.enterprise;
        final has = buildings.any((b) => b.zone == zone);
        final color =
            has ? _kGreen : (isCritical ? _kRed : Colors.white38);
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: color,
                  fontWeight: isCritical && !has
                      ? FontWeight.bold
                      : FontWeight.normal)),
        ]);
      }).toList(),
    );
  }
}

// ── Building list ──────────────────────────────────────────────────────────────

class _BuildingList extends StatelessWidget {
  final ZoneType zone;
  final Future<void> Function(Building) onPlace;

  const _BuildingList({required this.zone, required this.onPlace});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameController>().state;
    final buildings = allBuildings.where((b) => b.zone == zone).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: buildings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final b = buildings[i];
        final placed =
            state.activeBuildings.any((a) => a.nfcId == b.nfcId);
        final canAfford = state.budget >= b.cost;
        final co2Sign = b.co2Impact > 0 ? '+' : '';
        final co2Color = b.co2Impact <= 0 ? _kGreen : _kRed;
        final hasParams = b.parameters.isNotEmpty;

        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color:
                                placed ? Colors.white38 : Colors.white,
                          )),
                      const SizedBox(height: 6),
                      Row(children: [
                        _Chip(
                            icon: Icons.monetization_on_outlined,
                            label: '${b.cost} ¥+',
                            color: canAfford && !placed
                                ? _kGold
                                : Colors.white24),
                        const SizedBox(width: 8),
                        _Chip(
                            icon: Icons.cloud_outlined,
                            label: '$co2Sign${b.co2Impact}',
                            color: placed ? Colors.white24 : co2Color),
                        if (b.revenue > 0) ...[
                          const SizedBox(width: 8),
                          _Chip(
                              icon: Icons.trending_up,
                              label: '+${b.revenue}/t',
                              color: Colors.white38),
                        ],
                        if (hasParams) ...[
                          const SizedBox(width: 8),
                          _Chip(
                              icon: Icons.tune,
                              label: '${b.parameters.length} param.',
                              color: Colors.white38),
                        ],
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (placed)
                  const Icon(Icons.check_circle_outline,
                      color: _kGreen, size: 26)
                else
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: canAfford && !state.isGameOver
                          ? () => onPlace(b)
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14),
                        textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Configurer'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Shared small widgets ───────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 2),
      Text(label, style: TextStyle(fontSize: 11, color: color)),
    ]);
  }
}

class _DialogStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DialogStat(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.white38),
          const SizedBox(width: 6),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12))),
          Text(value,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
