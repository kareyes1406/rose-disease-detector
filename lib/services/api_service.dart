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

    // Paso 1: enviar imagen
    final url = Uri.parse('$_baseUrl/call/diagnosticar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'data': ['data:$mimeType;base64,$base64Image'],
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Error del servidor: ${response.statusCode} - ${response.body}');
    }

    final eventId = jsonDecode(response.body)['event_id'];

    // Paso 2: obtener resultado
    final resultUrl = Uri.parse('$_baseUrl/call/diagnosticar/$eventId');
    final resultResp = await http.get(resultUrl)
        .timeout(const Duration(seconds: 60));

    if (resultResp.statusCode != 200) {
      throw Exception('Error obteniendo resultado: ${resultResp.statusCode}');
    }

    // Parsear SSE response
    final lines = resultResp.body.split('\n');
    String? dataLine;
    for (final line in lines) {
      if (line.startsWith('data: ')) {
        dataLine = line.substring(6);
      }
    }

    if (dataLine == null) {
      throw Exception('Respuesta vacía del servidor');
    }

    final data = jsonDecode(dataLine);
    final resultText = data[0] as String;
    return _parseResult(resultText);
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
