import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NfcScan {
  final String buildingNfcId; // champ "batiment" du JSON ESP32
  final String zoneNfcId;     // champ "zone" du JSON ESP32
  final DateTime timestamp;

  NfcScan({required this.buildingNfcId, required this.zoneNfcId})
      : timestamp = DateTime.now();
}

class NfcController extends ChangeNotifier {
  bool isSimulationMode = true;
  NfcScan? lastScan;
  bool isConnected = false;
  String? connectionError;

  Timer? _pollingTimer;
  String? _esp32BaseUrl;
  // Évite de traiter deux fois le même scan (même timestamp côté ESP32)
  String? _lastProcessedKey;

  static const Duration _pollingInterval = Duration(milliseconds: 500);

  /// Mode simulation : déclenche un scan sans hardware.
  /// nfcId = valeur "batiment", zoneId = valeur "zone" du JSON ESP32.
  void simulateScan(String nfcId, String zoneId) {
    lastScan = NfcScan(buildingNfcId: nfcId, zoneNfcId: zoneId);
    notifyListeners();
  }

  /// Démarre le polling HTTP vers l'ESP32 (mode hardware).
  /// L'ESP32 doit exposer GET /last_scan → { "batiment": "...", "zone": "..." }
  void startPolling(String esp32BaseUrl) {
    isSimulationMode = false;
    _esp32BaseUrl = esp32BaseUrl;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => _pollEsp32());
    notifyListeners();
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    isConnected = false;
    notifyListeners();
  }

  Future<void> _pollEsp32() async {
    if (_esp32BaseUrl == null) return;
    try {
      final response = await http
          .get(Uri.parse('$_esp32BaseUrl/last_scan'))
          .timeout(const Duration(milliseconds: 400));

      if (response.statusCode == 200) {
        isConnected = true;
        connectionError = null;
        _processScan(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (e) {
      isConnected = false;
      connectionError = e.toString();
      notifyListeners();
    }
  }

  void _processScan(Map<String, dynamic> json) {
    final nfcId = json['batiment'] as String?;
    final zone = json['zone'] as String?;
    final scanKey = json['id'] as String? ?? '$nfcId-$zone';

    if (nfcId == null || zone == null) return;
    if (scanKey == _lastProcessedKey) return; // scan déjà traité

    _lastProcessedKey = scanKey;
    lastScan = NfcScan(buildingNfcId: nfcId, zoneNfcId: zone);
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
