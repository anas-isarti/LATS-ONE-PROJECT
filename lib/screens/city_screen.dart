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
const _kCard = Color(0xFF1A1A1A);

extension _ZoneExt on ZoneType {
  String get label => switch (this) {
        ZoneType.production => 'Énergie',
        ZoneType.transport => 'Transport',
        ZoneType.publicDistribution => 'Services',
        ZoneType.enterprise => 'Entreprises',
        ZoneType.residential => 'Particuliers',
      };

  IconData get icon => switch (this) {
        ZoneType.production => Icons.bolt,
        ZoneType.transport => Icons.directions_bus,
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

    final building =
        allBuildings.where((b) => b.nfcId == scan.buildingNfcId).firstOrNull;
    if (building == null) return;

    _placeBuilding(building);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('NFC : ${building.name} détecté'),
      backgroundColor: _kGreen,
      duration: const Duration(seconds: 2),
    ));
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
      final canAfford = gameCtrl.state.budget >= building.cost;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(canAfford ? 'Déjà construit' : 'Budget insuffisant'),
        duration: const Duration(seconds: 1),
      ));
    }
  }

  void _onEndTurn() {
    final gameCtrl = context.read<GameController>();
    final questCtrl = context.read<QuestController>();
    gameCtrl.endTurn();
    questCtrl.evaluateAndReward(gameCtrl.state);
    questCtrl.generateAdaptiveQuests(gameCtrl.state);

    final event = gameCtrl.activeEvent;
    if (event != null && mounted && !gameCtrl.state.isGameOver) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _kCard,
          title: Text(event.title, style: const TextStyle(color: _kGold)),
          content: Text(event.description,
              style: const TextStyle(color: Colors.white70)),
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
          context
              .read<NfcController>()
              .simulateScan(building.nfcId, building.zone.nfcZoneId);
        },
      ),
    );
  }

  void _showGameOverDialog() {
    final state = context.read<GameController>().state;
    final score = state.score;
    final isWin = state.currentTurn > state.maxTurns;

    String performanceMsg;
    Color perfColor;
    if (score >= 6000) {
      performanceMsg = 'Excellent ! La ville est un modèle écologique mondial.';
      perfColor = _kGreen;
    } else if (score >= 3500) {
      performanceMsg = 'Bien joué ! La ville est sur la bonne voie.';
      perfColor = _kGold;
    } else {
      performanceMsg = 'Peut mieux faire. La prochaine fois sera meilleure.';
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
        content: Column(
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
                border: Border.all(color: _kGreen.withValues(alpha: 0.3)),
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
            _DialogStat(Icons.domain,
                'Bâtiments construits', '${state.activeBuildings.length}'),
            _DialogStat(Icons.cloud_outlined,
                'CO2 final', '${state.co2} / ${state.co2Max}'),
            _DialogStat(Icons.monetization_on_outlined,
                'Budget restant', '${state.budget} ¥'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                performanceMsg,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: perfColor,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.4),
              ),
            ),
          ],
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
                    .map((z) => Tab(icon: Icon(z.icon, size: 16), text: z.label))
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
          _StatsHeader(state: state),
          Expanded(
            child: IndexedStack(
              index: _navIndex,
              children: [
                TabBarView(
                  controller: _zoneTab,
                  children: ZoneType.values
                      .map((zone) =>
                          _BuildingList(zone: zone, onPlace: _placeBuilding))
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
                child: Text('FIN DE TOUR ${state.currentTurn} / ${state.maxTurns}'),
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

// ── NFC Simulation sheet ──────────────────────────────────────────────────────

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
                        style:
                            TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white38, size: 18),
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
                leading:
                    Icon(b.zone.icon, color: _kGold, size: 18),
                title: Text(b.name,
                    style: const TextStyle(fontSize: 13, color: Colors.white)),
                subtitle: Text(b.zone.label,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11)),
                trailing: Text('${b.cost} ¥',
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

// ── Stats header ─────────────────────────────────────────────────────────────

class _StatsHeader extends StatelessWidget {
  final GameState state;
  const _StatsHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final co2Ratio = (state.co2 / state.co2Max).clamp(0.0, 1.0);
    final co2Color =
        co2Ratio < 0.5 ? _kGreen : co2Ratio < 0.75 ? Colors.orange : _kRed;

    return Container(
      color: _kCard,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.cloud_outlined, size: 12, color: co2Color),
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
          const SizedBox(width: 14),
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
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('T${state.currentTurn}/${state.maxTurns}',
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Building list ─────────────────────────────────────────────────────────────

class _BuildingList extends StatelessWidget {
  final ZoneType zone;
  final void Function(Building) onPlace;

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
        final placed = state.activeBuildings.any((a) => a.nfcId == b.nfcId);
        final canAfford = state.budget >= b.cost;
        final co2Sign = b.co2Impact > 0 ? '+' : '';
        final co2Color = b.co2Impact <= 0 ? _kGreen : _kRed;

        return Card(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                            color: placed ? Colors.white38 : Colors.white,
                          )),
                      const SizedBox(height: 6),
                      Row(children: [
                        _Chip(
                            icon: Icons.monetization_on_outlined,
                            label: '${b.cost} ¥',
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
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Placer'),
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

// ── Shared small widgets ──────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

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
