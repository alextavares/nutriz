// ignore_for_file: deprecated_member_use
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(String) onBarcodeScanned;
  final VoidCallback onClose;

  const BarcodeScannerWidget({
    Key? key,
    required this.onBarcodeScanned,
    required this.onClose,
  }) : super(key: key);

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isScanning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) {
        setState(() {
          _errorMessage =
              'Permissão da câmera necessária para escanear códigos de barras';
        });
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'Nenhuma câmera encontrada no dispositivo';
        });
        return;
      }

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao inicializar câmera: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      // Focus mode not supported, continue
    }

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {
        // Flash not supported, continue
      }
    }
  }

  void _simulateBarcodeDetection() {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    // Simulate barcode detection after 2 seconds
    HapticFeedback.selectionClick();
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        HapticFeedback.mediumImpact();
        // Mock barcode for demonstration
        widget.onBarcodeScanned('7891000100103');
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.darkTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Escanear Código de Barras',
                  style: AppTheme.darkTheme.textTheme.titleLarge,
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.darkTheme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),

          // Camera Preview
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildCameraPreview(),
                // dim mask
                IgnorePointer(
                  ignoring: false,
                  child: GestureDetector(
                    onTap: _simulateBarcodeDetection,
                    child: CustomPaint(
                      painter: _ScannerOverlayPainter(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Instructions
          Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Text(
                  'Posicione o código de barras dentro do quadro',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                if (_isScanning)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 4.w,
                        height: 4.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.activeBlue),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Escaneando...',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.activeBlue,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.errorRed,
              size: 12.w,
            ),
            SizedBox(height: 2.h),
            Text(
              _errorMessage!,
              style: AppTheme.darkTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                _initializeCamera();
              },
              child: Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _cameraController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.activeBlue),
            ),
            SizedBox(height: 2.h),
            Text(
              'Inicializando câmera...',
              style: AppTheme.darkTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Camera Preview
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),

        // Scanning Overlay
        Center(
          child: Container(
            width: 60.w,
            height: 30.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.activeBlue,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner indicators
                Positioned(
                  top: -1,
                  left: -1,
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppTheme.activeBlue, width: 4),
                        left: BorderSide(color: AppTheme.activeBlue, width: 4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -1,
                  right: -1,
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppTheme.activeBlue, width: 4),
                        right: BorderSide(color: AppTheme.activeBlue, width: 4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  left: -1,
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: AppTheme.activeBlue, width: 4),
                        left: BorderSide(color: AppTheme.activeBlue, width: 4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: AppTheme.activeBlue, width: 4),
                        right: BorderSide(color: AppTheme.activeBlue, width: 4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tap to scan
        Positioned.fill(
          child: GestureDetector(
            onTap: _simulateBarcodeDetection,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintMask = Paint()..color = Colors.black.withOpacity(0.45);
    final rect = Offset.zero & size;
    canvas.drawRect(rect, paintMask);

    // scan window
    final w = size.width * 0.8;
    final h = size.height * 0.28;
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: w,
        height: h,
      ),
      const Radius.circular(12),
    );

    // cut out
    final clear = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;
    canvas.saveLayer(rect, Paint());
    canvas.drawRRect(r, clear);
    canvas.restore();

    // corners
    final corner = Paint()
      ..color = AppTheme.activeBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final double c = 18;
    // top-left
    canvas.drawLine(
        r.outerRect.topLeft, r.outerRect.topLeft + Offset(c, 0), corner);
    canvas.drawLine(
        r.outerRect.topLeft, r.outerRect.topLeft + Offset(0, c), corner);
    // top-right
    canvas.drawLine(
        r.outerRect.topRight, r.outerRect.topRight - Offset(c, 0), corner);
    canvas.drawLine(
        r.outerRect.topRight, r.outerRect.topRight + Offset(0, c), corner);
    // bottom-left
    canvas.drawLine(
        r.outerRect.bottomLeft, r.outerRect.bottomLeft + Offset(c, 0), corner);
    canvas.drawLine(
        r.outerRect.bottomLeft, r.outerRect.bottomLeft - Offset(0, c), corner);
    // bottom-right
    canvas.drawLine(r.outerRect.bottomRight,
        r.outerRect.bottomRight - Offset(c, 0), corner);
    canvas.drawLine(r.outerRect.bottomRight,
        r.outerRect.bottomRight - Offset(0, c), corner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
