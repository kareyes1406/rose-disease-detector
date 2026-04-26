import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../services/history_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _isGenerating = false;
  String? _successMessage;

  Future<void> _generatePdf() async {
    final history = HistoryService().history;
    if (history.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _successMessage = null;
    });

    try {
      final counts = HistoryService().counts;
      final total = history.length;
      final pdf = pw.Document();

      final greenColor = PdfColor.fromHex('2E8B57');
      final lightGreen = PdfColor.fromHex('90EE90');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.letter,
          margin: const pw.EdgeInsets.all(40),
          build: (ctx) => [
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('0d1f0d'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'Reporte de Diagnostico de Rosas',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: greenColor,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generado: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    style: pw.TextStyle(fontSize: 11, color: PdfColors.grey400),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Resumen General',
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: greenColor),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: greenColor, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: greenColor),
                  children: [
                    _pdfHeaderCell('Diagnostico'),
                    _pdfHeaderCell('Cantidad'),
                    _pdfHeaderCell('Porcentaje')
                  ],
                ),
                _pdfRow3(
                    'Mancha Negra',
                    counts['Black Spot'].toString(),
                    total > 0
                        ? '${(counts['Black Spot']! / total * 100).toStringAsFixed(1)}%'
                        : '0%',
                    PdfColors.grey100),
                _pdfRow3(
                    'Mildiu Velloso',
                    counts['Downy Mildew'].toString(),
                    total > 0
                        ? '${(counts['Downy Mildew']! / total * 100).toStringAsFixed(1)}%'
                        : '0%',
                    PdfColors.white),
                _pdfRow3(
                    'Hoja Sana',
                    counts['Fresh Leaf'].toString(),
                    total > 0
                        ? '${(counts['Fresh Leaf']! / total * 100).toStringAsFixed(1)}%'
                        : '0%',
                    PdfColors.grey100),
                _pdfRow3('TOTAL', total.toString(), '100%',
                    PdfColor.fromHex('d4edda'),
                    bold: true),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'Historial Detallado',
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: greenColor),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: lightGreen, width: 0.4),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2.5),
                3: const pw.FixedColumnWidth(80),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: greenColor),
                  children: [
                    _pdfHeaderCell('#'),
                    _pdfHeaderCell('Fecha'),
                    _pdfHeaderCell('Diagnostico'),
                    _pdfHeaderCell('Confianza')
                  ],
                ),
                ...history.asMap().entries.map((entry) {
                  final i = entry.key;
                  final h = entry.value;
                  final bg = i.isEven ? PdfColors.grey100 : PdfColors.white;
                  return _pdfRow4(
                    (i + 1).toString(),
                    '${h.fecha.day}/${h.fecha.month}/${h.fecha.year} ${h.fecha.hour}:${h.fecha.minute.toString().padLeft(2, '0')}',
                    '${h.emoji} ${h.nombre}',
                    '${h.confianza}%',
                    bg,
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(color: greenColor),
            pw.SizedBox(height: 8),
            pw.Text(
              'Detector de Enfermedades en Hojas de Rosa - Proyecto de Investigacion',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/reporte_rosas.pdf');
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles([XFile(file.path)],
          subject: 'Reporte Diagnostico de Rosas');
      setState(() {
        _isGenerating = false;
        _successMessage = 'PDF generado exitosamente';
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error generando PDF: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  pw.Widget _pdfHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text,
          style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10),
          textAlign: pw.TextAlign.center),
    );
  }

  pw.TableRow _pdfRow3(String a, String b, String c, PdfColor bg,
      {bool bold = false}) {
    final style = pw.TextStyle(
        fontSize: 10,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal);
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bg),
      children: [a, b, c]
          .map((t) => pw.Padding(
                padding: const pw.EdgeInsets.all(7),
                child: pw.Text(t, style: style, textAlign: pw.TextAlign.center),
              ))
          .toList(),
    );
  }

  pw.TableRow _pdfRow4(String a, String b, String c, String d, PdfColor bg,
      {bool bold = false}) {
    final style = pw.TextStyle(
        fontSize: 10,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal);
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bg),
      children: [a, b, c, d]
          .map((t) => pw.Padding(
                padding: const pw.EdgeInsets.all(7),
                child: pw.Text(t, style: style, textAlign: pw.TextAlign.center),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = HistoryService().history;
    final counts = HistoryService().counts;
    final total = history.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('📄 Exportar PDF')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1e3a1e), AppTheme.surface],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.cardBorder.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  const Text('🌹', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  const Text('Reporte de Diagnóstico',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('de Rosas',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 16,
                          letterSpacing: 1)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statItem('📋', total.toString(), 'diagnósticos'),
                      _statItem('🖤', counts['Black Spot'].toString(),
                          'mancha negra'),
                      _statItem(
                          '🌿', counts['Fresh Leaf'].toString(), 'hojas sanas'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('El PDF incluye:',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...[
              ('📊', 'Tabla resumen con totales y porcentajes'),
              ('📋', 'Historial detallado con fechas y confianza'),
              ('🗓️', 'Fecha y hora de generación'),
              ('🌹', 'Diseño profesional listo para presentar'),
            ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                            child: Text(item.$1,
                                style: const TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(width: 12),
                      Text(item.$2,
                          style: const TextStyle(
                              color: AppTheme.textPrimary, fontSize: 14)),
                    ],
                  ),
                )),
            const SizedBox(height: 32),
            if (_successMessage != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.primary),
                    const SizedBox(width: 10),
                    Text(_successMessage!,
                        style: const TextStyle(color: AppTheme.primary)),
                  ],
                ),
              ),
            ],
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (total > 0 && !_isGenerating) ? _generatePdf : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  disabledBackgroundColor: AppTheme.surfaceLight,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('Generando PDF...',
                              style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.picture_as_pdf, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            total > 0
                                ? 'Generar y Compartir PDF'
                                : 'Sin diagnósticos aún',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),
            ),
            if (total == 0) ...[
              const SizedBox(height: 12),
              const Center(
                child: Text(
                    'Ve a Diagnóstico primero para\nanalizar hojas de rosa',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}
