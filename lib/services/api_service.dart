import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/diagnosis_result.dart';

class ApiService {
  static const String _baseUrl =
      'https://kareyes-rose-disease-detector.hf.space';

  static Future<DiagnosisResult> diagnose(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

    // Gradio 4.x usa /queue/join
    final url = Uri.parse('$_baseUrl/queue/join');
    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data': ['data:$mimeType;base64,$base64Image'],
            'event_data': null,
            'fn_index': 0,
            'session_hash': 'flutter_app',
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception('Error del servidor: ${response.statusCode}');
    }

    // Esperar resultado via /queue/status
    final eventId = jsonDecode(response.body)['event_id'];
    final statusUrl = Uri.parse('$_baseUrl/queue/status?event_id=$eventId&session_hash=flutter_app');
    
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final statusResp = await http.get(statusUrl);
      final statusData = jsonDecode(statusResp.body);
      
      if (statusData['msg'] == 'process_completed') {
        final resultText = statusData['output']['data'][0] as String;
        return _parseResult(resultText);
      }
    }

    throw Exception('Tiempo de espera agotado');
  }

  static DiagnosisResult _parseResult(String markdown) {
    String label = 'Fresh Leaf';
    double confianza = 0.0;

    if (markdown.contains('Mancha Negra') || markdown.contains('Black Spot')) {
      label = 'Black Spot';
    } else if (markdown.contains('Mildiu') || markdown.contains('Downy')) {
      label = 'Downy Mildew';
    } else {
      label = 'Fresh Leaf';
    }

    final confMatch = RegExp(r'(\d+\.?\d*)%').firstMatch(markdown);
    if (confMatch != null) {
      confianza = double.tryParse(confMatch.group(1) ?? '0') ?? 0.0;
    }

    final info = DiagnosisResult.diseaseInfo[label]!;
    return DiagnosisResult(
      label: label,
      nombre: info['nombre'],
      emoji: info['emoji'],
      confianza: confianza,
      descripcion: info['descripcion'],
      tratamiento: List<String>.from(info['tratamiento']),
      fecha: DateTime.now(),
    );
  }
}
