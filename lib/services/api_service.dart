import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/diagnosis_result.dart';

class ApiService {
  static const String _baseUrl =
      'https://kareyes-rose-disease-detector.hf.space';

  /// Sends image to HuggingFace Gradio API and returns DiagnosisResult
  static Future<DiagnosisResult> diagnose(File imageFile) async {
    // Convert image to base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

    // Gradio API call
    final url = Uri.parse('$_baseUrl/api/predict');
    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data': [
              'data:$mimeType;base64,$base64Image',
            ],
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Error del servidor: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    // Parse the markdown result from Gradio
    final resultText = decoded['data'][0] as String;
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

    // Extract confidence
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
