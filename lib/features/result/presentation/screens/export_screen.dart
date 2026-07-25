import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' as xls;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportarResultadosApp extends StatelessWidget {
  const ExportarResultadosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ExportarResultadosScreen();
  }
}

// ---------------------------------------------------------------------------
// Modelos de datos (datos de ejemplo — reemplaza por tus resultados reales)
// ---------------------------------------------------------------------------

class OpcionResultado {
  final String nombre;
  final String? partido;
  final int votos;

  const OpcionResultado({
    required this.nombre,
    this.partido,
    required this.votos,
  });
}

class TarjetonResultado {
  final String titulo;
  final List<OpcionResultado> opciones;

  const TarjetonResultado({required this.titulo, required this.opciones});

  int get totalVotos => opciones.fold(0, (a, o) => a + o.votos);
}

const String _tituloVotacion = 'Elecciones Regionales 2026 - Huila';
const String _rangoFechas = '25 jul 2026, 08:00 a.m. — 6:00 p.m.';

final List<TarjetonResultado> _resultadosEjemplo = [
  TarjetonResultado(
    titulo: 'Gobernación',
    opciones: [
      OpcionResultado(
        nombre: 'Ana Torres',
        partido: 'Partido Verde',
        votos: 48210,
      ),
      OpcionResultado(
        nombre: 'Carlos Ruiz',
        partido: 'Partido Azul',
        votos: 39875,
      ),
      OpcionResultado(
        nombre: 'Marta Gómez',
        partido: 'Movimiento Cívico',
        votos: 21430,
      ),
    ],
  ),
  TarjetonResultado(
    titulo: 'Alcaldía',
    opciones: [
      OpcionResultado(
        nombre: 'Luis Pérez',
        partido: 'Partido Verde',
        votos: 31220,
      ),
      OpcionResultado(
        nombre: 'Sofía León',
        partido: 'Alianza Ciudadana',
        votos: 28640,
      ),
    ],
  ),
  TarjetonResultado(
    titulo: 'Cámara',
    opciones: [
      OpcionResultado(nombre: "", partido: 'Partido Verde', votos: 26010),
      OpcionResultado(nombre: "", partido: 'Partido Azul', votos: 24870),
      OpcionResultado(nombre: "", partido: 'Movimiento Cívico', votos: 15340),
      OpcionResultado(nombre: "", partido: 'Alianza Ciudadana', votos: 12980),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Pantalla principal
// ---------------------------------------------------------------------------

class ExportarResultadosScreen extends StatefulWidget {
  const ExportarResultadosScreen({super.key});

  @override
  State<ExportarResultadosScreen> createState() =>
      _ExportarResultadosScreenState();
}

class _ExportarResultadosScreenState extends State<ExportarResultadosScreen> {
  final List<TarjetonResultado> _resultados = _resultadosEjemplo;

  bool _generandoPdf = false;
  bool _generandoExcel = false;

  int get _totalGeneral => _resultados.fold(0, (a, t) => a + t.totalVotos);

  // ---------- Generación de PDF ----------

  Future<void> _exportarPdf() async {
    setState(() => _generandoPdf = true);
    try {
      final documento = pw.Document();

      documento.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _tituloVotacion,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                _rangoFechas,
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Reporte generado: ${DateTime.now().toString().substring(0, 16)}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
            ],
          ),
          footer: (context) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ),
          build: (context) => [
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total de votos registrados',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    '$_totalGeneral',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            for (final tarjeton in _resultados) ...[
              _buildTarjetonPdfSection(tarjeton),
              pw.SizedBox(height: 18),
            ],
          ],
        ),
      );

      final bytes = await documento.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'resultados_votacion.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al generar el PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _generandoPdf = false);
    }
  }

  pw.Widget _buildTarjetonPdfSection(TarjetonResultado tarjeton) {
    final total = tarjeton.totalVotos;
    final ordenadas = [...tarjeton.opciones]
      ..sort((a, b) => b.votos.compareTo(a.votos));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          tarjeton.titulo,
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 9.5,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.blueGrey800,
          ),
          cellStyle: const pw.TextStyle(fontSize: 9.5),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.centerLeft,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
          },
          headers: ['#', 'Candidato', 'Partido', 'Votos', '%'],
          data: List.generate(ordenadas.length, (i) {
            final o = ordenadas[i];
            final pct = total == 0 ? 0.0 : (o.votos / total) * 100;
            return [
              '${i + 1}',
              o.nombre ?? '—',
              o.partido ?? '—',
              '${o.votos}',
              '${pct.toStringAsFixed(1)}%',
            ];
          }),
        ),
        pw.SizedBox(height: 4),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Total tarjetón: $total votos',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ),
      ],
    );
  }

  // ---------- Generación de Excel ----------

  Future<void> _exportarExcel() async {
    setState(() => _generandoExcel = true);
    try {
      final libro = xls.Excel.createExcel();

      // Hoja de resumen
      final hojaResumen = libro['Resumen'];
      hojaResumen.appendRow([xls.TextCellValue(_tituloVotacion)]);
      hojaResumen.appendRow([xls.TextCellValue(_rangoFechas)]);
      hojaResumen.appendRow([]);
      hojaResumen.appendRow([
        xls.TextCellValue('Tarjetón'),
        xls.TextCellValue('Total de votos'),
      ]);
      for (final tarjeton in _resultados) {
        hojaResumen.appendRow([
          xls.TextCellValue(tarjeton.titulo),
          xls.IntCellValue(tarjeton.totalVotos),
        ]);
      }
      hojaResumen.appendRow([]);
      hojaResumen.appendRow([
        xls.TextCellValue('Total general'),
        xls.IntCellValue(_totalGeneral),
      ]);

      // Una hoja por tarjetón con el detalle de opciones
      for (final tarjeton in _resultados) {
        final nombreHoja = _sanitizarNombreHoja(tarjeton.titulo);
        final hoja = libro[nombreHoja];
        final total = tarjeton.totalVotos;
        final ordenadas = [...tarjeton.opciones]
          ..sort((a, b) => b.votos.compareTo(a.votos));

        hoja.appendRow([
          xls.TextCellValue('#'),
          xls.TextCellValue('Candidato'),
          xls.TextCellValue('Partido'),
          xls.TextCellValue('Votos'),
          xls.TextCellValue('Porcentaje'),
        ]);

        for (int i = 0; i < ordenadas.length; i++) {
          final o = ordenadas[i];
          final pct = total == 0 ? 0.0 : (o.votos / total) * 100;
          hoja.appendRow([
            xls.IntCellValue(i + 1),
            xls.TextCellValue(o.nombre ?? '—'),
            xls.TextCellValue(o.partido ?? '—'),
            xls.IntCellValue(o.votos),
            xls.DoubleCellValue(double.parse(pct.toStringAsFixed(1))),
          ]);
        }
      }

      // El Excel se crea con una hoja "Sheet1" por defecto; se elimina si sobra.
      if (libro.sheets.containsKey('Sheet1') && libro.sheets.length > 1) {
        libro.delete('Sheet1');
      }

      final bytes = libro.save();
      if (bytes == null) {
        throw Exception('No se pudo generar el archivo Excel');
      }

      final directorio = await getTemporaryDirectory();
      final archivo = File('${directorio.path}/resultados_votacion.xlsx');
      await archivo.writeAsBytes(bytes);

      await Share.shareXFiles([
        XFile(archivo.path),
      ], text: 'Resultados de la votación - $_tituloVotacion');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar el Excel: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generandoExcel = false);
    }
  }

  String _sanitizarNombreHoja(String nombre) {
    // Los nombres de hoja de Excel no admiten ciertos caracteres y máximo 31.
    final limpio = nombre.replaceAll(RegExp(r'[\\/*?:\[\]]'), '');
    return limpio.length > 31 ? limpio.substring(0, 31) : limpio;
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Exportar Resultados',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    _tituloVotacion,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    _rangoFechas,
                    style: TextStyle(color: Colors.white54, fontSize: 12.5),
                  ),
                  const SizedBox(height: 20),
                  _buildResumenCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Elige el formato de exportación',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBotonExportar(
                    titulo: 'Exportar a PDF',
                    subtitulo: 'Reporte listo para imprimir o compartir',
                    icono: Icons.picture_as_pdf_outlined,
                    color: const Color(0xFFDC2626),
                    cargando: _generandoPdf,
                    onTap: _exportarPdf,
                  ),
                  const SizedBox(height: 12),
                  _buildBotonExportar(
                    titulo: 'Exportar a Excel',
                    subtitulo: 'Datos en hojas de cálculo para análisis',
                    icono: Icons.table_chart_outlined,
                    color: const Color(0xFF16A34A),
                    cargando: _generandoExcel,
                    onTap: _exportarExcel,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResumenCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.summarize_outlined,
                color: Colors.white54,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Contenido a exportar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final tarjeton in _resultados)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.white38,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${tarjeton.titulo} · ${tarjeton.opciones.length} opciones · ${tarjeton.totalVotos} votos',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(color: Color(0xFF334155), height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total general',
                style: TextStyle(color: Colors.white54, fontSize: 12.5),
              ),
              Text(
                '$_totalGeneral votos',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBotonExportar({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color color,
    required bool cargando,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: cargando ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: cargando
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    )
                  : Icon(icono, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
