import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diagnosis_result.dart';

class HistoryService {
  static const String _key = 'diagnosis_history';
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  List<DiagnosisResult> _history = [];

  List<DiagnosisResult> get history => List.unmodifiable(_history);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final List<dynamic> decoded = jsonDecode(raw);
      _history = decoded.map((e) => DiagnosisResult.fromJson(e)).toList();
    }
  }

  Future<void> add(DiagnosisResult result) async {
    _history.add(result);
    await _save();
  }

  Future<void> clear() async {
    _history.clear();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_history.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Map<String, int> get counts {
    final map = {'Black Spot': 0, 'Downy Mildew': 0, 'Fresh Leaf': 0};
    for (final h in _history) {
      map[h.label] = (map[h.label] ?? 0) + 1;
    }
    return map;
  }
}
