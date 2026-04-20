import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/blood_pressure_reading.dart';
import '../data/gemini_ocr_service.dart';
import 'readings_controller.dart';

class CameraScannerScreen extends ConsumerStatefulWidget {
  const CameraScannerScreen({super.key});

  @override
  ConsumerState<CameraScannerScreen> createState() =>
      _CameraScannerScreenState();
}

class _CameraScannerScreenState extends ConsumerState<CameraScannerScreen> {
  CameraController? _cameraController;
  final GeminiOcrService _ocrService = GeminiOcrService();
  bool _isProcessing = false;

  bool _hasResult = false;
  String _statusText = 'Point at the display and tap Capture';

  // Controladores para edição manual dos valores lidos
  final TextEditingController _sysController = TextEditingController();
  final TextEditingController _diaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      debugPrint('No cameras found.');
      return;
    }

    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _captureAndProcess() async {
    if (_isProcessing || _cameraController == null) return;

    setState(() {
      _isProcessing = true;
      _statusText = 'Processing photo in Gemini...';
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      debugPrint('Photo taken: \${photo.path}');

      setState(() {
        _statusText = 'Analyzing LCD digits...';
      });

      final resultado = await _ocrService.processPhotoFile(photo.path);

      if (resultado != null) {
        HapticFeedback.heavyImpact(); // Haptic feedback on success
        setState(() {
          _sysController.text = resultado.systolic.toString();
          _diaController.text = resultado.diastolic.toString();
          _hasResult = true;
          _statusText = 'Values detected! You can correct them if needed.';
        });
      } else {
        setState(() {
          _statusText =
              'Could not read the numbers.\nGet closer and try again.';
        });
      }
    } catch (e) {
      debugPrint('Capture error: \$e');
      setState(() {
        _statusText = 'Erro: \$e';
      });
    }

    setState(() {
      _isProcessing = false;
    });
  }

  void _resetCapture() {
    setState(() {
      _hasResult = false;
      _sysController.clear();
      _diaController.clear();
      _statusText = 'Point at the display and tap Capture';
    });
  }

  void _saveReading() {
    final sys = int.tryParse(_sysController.text);
    final dia = int.tryParse(_diaController.text);

    if (sys == null || dia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid values. Please fill in correctly.'),
        ),
      );
      return;
    }

    final leitura = BloodPressureReading()
      ..systolic = sys
      ..diastolic = dia
      ..measuredAt = DateTime.now();

    ref.read(readingsControllerProvider.notifier).addReading(leitura);
    context.pop();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _sysController.dispose();
    _diaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Scan Monitor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),

          // Custom Overlay for the Scanner (Darkens the background, leaving a clear "hole" with corners)
          CustomPaint(
            painter: _ScannerOverlayPainter(
              scanWindowSize: const Size(280, 180),
              isSuccess: _hasResult,
            ),
          ),

          // Status Text Positioned above the scanner window
          Positioned(
            top:
                MediaQuery.of(context).size.height / 2 -
                180, // Moved higher up to avoid covering the scan window
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Bottom card with results and buttons
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hasResult) ...[
                      const Text(
                        'Confirm Reading',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _sysController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Systolic (SYS)',
                                labelStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.red.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _diaController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Diastolic (DIA)',
                                labelStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.blue.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _resetCapture,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Retake',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveReading,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      if (_isProcessing)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: CircularProgressIndicator(),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _captureAndProcess,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text(
                            'Capture Photo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Um CustomPainter que pinta a tela de preto semi-transparente, deixando o centro livre
/// e adicionando bordas em estilo de cantoneira de "scanners".
class _ScannerOverlayPainter extends CustomPainter {
  final Size scanWindowSize;
  final bool isSuccess;

  _ScannerOverlayPainter({
    required this.scanWindowSize,
    required this.isSuccess,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Tinta para a área escura
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    // 2. Calcula as posições da "janela" de corte
    final left = (size.width - scanWindowSize.width) / 2;
    final top = (size.height - scanWindowSize.height) / 2;
    final rect = Rect.fromLTWH(
      left,
      top,
      scanWindowSize.width,
      scanWindowSize.height,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    // A mágica: Usar path.fillType = PathFillType.evenOdd para fazer o 'furo' na tela
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // 3. Desenhar os cantos de foco (Bracket corners)
    final cornerPaint = Paint()
      ..color = isSuccess ? Colors.greenAccent : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final length = 30.0; // Comprimento de cada lado da cantoneira

    // Top-Left
    canvas.drawLine(Offset(left, top + length), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + length, top), cornerPaint);

    // Top-Right
    canvas.drawLine(
      Offset(rect.right - length, top),
      Offset(rect.right, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, top),
      Offset(rect.right, top + length),
      cornerPaint,
    );

    // Bottom-Left
    canvas.drawLine(
      Offset(left, rect.bottom - length),
      Offset(left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, rect.bottom),
      Offset(left + length, rect.bottom),
      cornerPaint,
    );

    // Bottom-Right
    canvas.drawLine(
      Offset(rect.right - length, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - length),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.isSuccess != isSuccess ||
        oldDelegate.scanWindowSize != scanWindowSize;
  }
}
