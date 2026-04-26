class DiagnosisResult {
  final String label;
  final String nombre;
  final String emoji;
  final double confianza;
  final String descripcion;
  final List<String> tratamiento;
  final DateTime fecha;

  DiagnosisResult({
    required this.label,
    required this.nombre,
    required this.emoji,
    required this.confianza,
    required this.descripcion,
    required this.tratamiento,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'nombre': nombre,
        'emoji': emoji,
        'confianza': confianza,
        'descripcion': descripcion,
        'tratamiento': tratamiento,
        'fecha': fecha.toIso8601String(),
      };

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) =>
      DiagnosisResult(
        label: json['label'],
        nombre: json['nombre'],
        emoji: json['emoji'],
        confianza: json['confianza'].toDouble(),
        descripcion: json['descripcion'],
        tratamiento: List<String>.from(json['tratamiento']),
        fecha: DateTime.parse(json['fecha']),
      );

  static Map<String, Map<String, dynamic>> get diseaseInfo => {
        'Black Spot': {
          'nombre': 'Mancha Negra',
          'emoji': '🖤',
          'descripcion': 'Enfermedad fúngica. Manchas negras con bordes amarillos.',
          'tratamiento': [
            'Retirar hojas infectadas',
            'Aplicar fungicida cúprico',
            'Evitar mojar el follaje',
            'Mejorar circulación de aire',
          ],
          'color': 0xFF8B0000,
        },
        'Downy Mildew': {
          'nombre': 'Mildiu Velloso',
          'emoji': '🌫️',
          'descripcion': 'Alta humedad. Manchas amarillas y pelusa grisácea.',
          'tratamiento': [
            'Mejorar ventilación',
            'Aplicar fungicida mancozeb',
            'Regar en la mañana',
            'Podar ramas densas',
          ],
          'color': 0xFF4A708B,
        },
        'Fresh Leaf': {
          'nombre': 'Hoja Sana',
          'emoji': '🌿',
          'descripcion': 'Sin signos de enfermedad detectados.',
          'tratamiento': [
            'Continuar riego regular',
            'Fertilización cada 15 días',
            'Inspección semanal preventiva',
            'Mantener buena aireación',
          ],
          'color': 0xFF2E8B57,
        },
      };
}
