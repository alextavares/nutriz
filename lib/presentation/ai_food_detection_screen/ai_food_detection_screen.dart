// ignore_for_file: deprecated_member_use
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/gemini_client.dart';
import '../../services/gemini_service.dart';
import '../../services/fooddb/food_data_central_service.dart';
import '../../services/fooddb/open_food_facts_service.dart';
import '../../services/fooddb/food_normalizer.dart';
import '../../services/env_service.dart';
import './widgets/camera_controls_widget.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/food_analysis_results_widget.dart';
import './widgets/image_preview_widget.dart';

class AiFoodDetectionScreen extends StatefulWidget {
  const AiFoodDetectionScreen({Key? key}) : super(key: key);

  @override
  State<AiFoodDetectionScreen> createState() => _AiFoodDetectionScreenState();
}

class _AiFoodDetectionScreenState extends State<AiFoodDetectionScreen> {
  // Camera and image handling
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  final ImagePicker _imagePicker = ImagePicker();

  // State management
  File? _selectedImage;
  bool _isCameraInitialized = false;
  bool _isAnalyzing = false;
  bool _showCamera = false;
  FoodNutritionData? _analysisResults;
  String? _errorMessage;

  // Gemini client
  late final GeminiClient _geminiClient;
  late final FoodNormalizerService _normalizer;

  @override
  void initState() {
    super.initState();
    _initializeGeminiClient();
    _requestPermissions();
  }

  Future<void> _reviewMultiple(List<DetectedFood> items) async {
    if (items.isEmpty) return;
    // Abre um diálogo com lista, cada item com quantidade (g) editável e toggle de seleção
    final controllers = <int, TextEditingController>{};
    final selected = <int, bool>{
      for (var i = 0; i < items.length; i++) i: true
    };
    final mealByIndex = <int, String>{
      for (var i = 0; i < items.length; i++) i: 'snack'
    };
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryBackgroundDark,
          title: Text('Revisar itens',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              )),
          content: SizedBox(
            width: 700,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < items.length; i++)
                    StatefulBuilder(builder: (context, setStateRow) {
                      controllers.putIfAbsent(
                          i, () => TextEditingController(text: '100'));
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBackgroundDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.dividerGray),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: selected[i] ?? true,
                              onChanged: (v) =>
                                  setStateRow(() => selected[i] = v ?? true),
                              activeColor: AppTheme.activeBlue,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(items[i].name,
                                      style: AppTheme
                                          .darkTheme.textTheme.bodyLarge
                                          ?.copyWith(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  Text('Sugestão: ${items[i].portionSize}',
                                      style: AppTheme
                                          .darkTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.textSecondary,
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              child: DropdownButtonFormField<String>(
                                value: mealByIndex[i],
                                items: const [
                                  DropdownMenuItem(
                                      value: 'breakfast', child: Text('Café')),
                                  DropdownMenuItem(
                                      value: 'lunch', child: Text('Almoço')),
                                  DropdownMenuItem(
                                      value: 'dinner', child: Text('Jantar')),
                                  DropdownMenuItem(
                                      value: 'snack', child: Text('Lanche')),
                                ],
                                onChanged: (v) => setStateRow(
                                    () => mealByIndex[i] = v ?? 'snack'),
                                decoration:
                                    const InputDecoration(labelText: 'Período'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: controllers[i],
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: 'g'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Monta lista de itens selecionados com grams
                final List<Map<String, dynamic>> selectedFoods = [];
                for (int i = 0; i < items.length; i++) {
                  if (selected[i] != true) continue;
                  final grams =
                      int.tryParse(controllers[i]?.text.trim() ?? '100') ?? 100;
                  // normaliza
                  final best = await _normalizer.findBestMatch(items[i].name);
                  final base = items[i].toFoodMap();
                  if (best != null) {
                    base['brand'] = best.brand ?? base['brand'];
                    // escala pela porção em g
                    base['calories'] =
                        ((best.caloriesPer100g * grams) / 100).round();
                    base['carbs'] = (best.carbsPer100g * grams) / 100;
                    base['protein'] = (best.proteinPer100g * grams) / 100;
                    base['fat'] = (best.fatPer100g * grams) / 100;
                    base['serving'] = '$grams g';
                    base['source'] = best.source == 'FDC' ? 'AI/FDC' : 'AI/OFF';
                  } else {
                    base['serving'] = '$grams g';
                  }
                  base['mealTime'] = mealByIndex[i] ?? 'snack';
                  selectedFoods.add(base);
                }
                if (!mounted) return;
                Navigator.pop(context);
                // Retorna todos os selecionados para salvamento em lote
                if (selectedFoods.isNotEmpty) {
                  Navigator.pop(context, selectedFoods);
                }
              },
              child: const Text('Adicionar selecionados'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeGeminiClient() async {
    try {
      await GeminiService.init();
      final service = GeminiService();
      _geminiClient = GeminiClient(service.dio, service.authApiKey);
      // Food DB normalizer: FDC (usa key se houver) + OFF fallback
      String fdcKey = const String.fromEnvironment('FDC_API_KEY');
      if (fdcKey.isEmpty) {
        final fromEnv = await EnvService.get('FDC_API_KEY');
        if (fromEnv != null && fromEnv.trim().isNotEmpty) {
          fdcKey = fromEnv.trim();
        }
      }
      final fdc = FoodDataCentralService(
        apiKey: fdcKey.isEmpty ? null : fdcKey,
      );
      final off = OpenFoodFactsService();
      _normalizer = FoodNormalizerService(fdc: fdc, off: off);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao inicializar IA: $e';
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    final cameraStatus = await Permission.camera.request();
    if (cameraStatus.isGranted) {
      await _initializeCamera();
    } else {
      setState(() {
        _errorMessage = 'Permissão de câmera negada';
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'Nenhuma câmera encontrada';
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

      // Apply settings (skip unsupported on web)
      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {
        // Ignore focus mode errors
      }

      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          // Ignore flash mode errors
        }
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao inicializar câmera: $e';
        });
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      final File imageFile = File(photo.path);

      setState(() {
        _selectedImage = imageFile;
        _showCamera = false;
      });

      await _analyzeImage(imageFile);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erro ao capturar foto: $e',
        backgroundColor: AppTheme.errorRed,
        textColor: AppTheme.textPrimary,
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        final File imageFile = File(pickedImage.path);
        setState(() {
          _selectedImage = imageFile;
          _showCamera = false;
        });

        await _analyzeImage(imageFile);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erro ao selecionar imagem: $e',
        backgroundColor: AppTheme.errorRed,
        textColor: AppTheme.textPrimary,
      );
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    setState(() {
      _isAnalyzing = true;
      _analysisResults = null;
      _errorMessage = null;
    });

    try {
      final results = await _geminiClient.analyzeFoodImage(imageFile);

      setState(() {
        _analysisResults = results;
        _isAnalyzing = false;
      });

      if (results.foods.isEmpty) {
        Fluttertoast.showToast(
          msg: 'Nenhum alimento detectado na imagem',
          backgroundColor: AppTheme.warningAmber,
          textColor: AppTheme.textPrimary,
        );
      } else {
        Fluttertoast.showToast(
          msg: '${results.foods.length} alimento(s) detectado(s)',
          backgroundColor: AppTheme.successGreen,
          textColor: AppTheme.textPrimary,
        );
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Erro na análise: ${e.toString()}';
      });

      Fluttertoast.showToast(
        msg: 'Erro ao analisar imagem',
        backgroundColor: AppTheme.errorRed,
        textColor: AppTheme.textPrimary,
      );
    }
  }

  void _toggleCamera() {
    setState(() {
      _showCamera = !_showCamera;
      if (!_showCamera) {
        _selectedImage = null;
        _analysisResults = null;
        _errorMessage = null;
      }
    });
  }

  void _addFoodToMeal(DetectedFood food) async {
    // Tentar normalizar com FDC/OPEN FOOD FACTS
    final best = await _normalizer.findBestMatch(food.name);
    Map<String, dynamic> base = food.toFoodMap();
    if (best != null) {
      // aproximar porção: se IA não deu gramas, manter porção textual; usamos 100g como base
      base['brand'] = best.brand ?? base['brand'];
      base['calories'] = (best.caloriesPer100g).round();
      base['carbs'] = best.carbsPer100g;
      base['protein'] = best.proteinPer100g;
      base['fat'] = best.fatPer100g;
      base['serving'] = '100 g';
      base['source'] = best.source == 'FDC' ? 'AI/FDC' : 'AI/OFF';
    }

    // Levar para a tela de registrar alimento com prefill
    if (!mounted) return;
    Navigator.pop(context, base);
  }

  void _retakePhoto() {
    setState(() {
      _selectedImage = null;
      _analysisResults = null;
      _errorMessage = null;
      _showCamera = true;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          SafeArea(
            child: Container(
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
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: AppTheme.darkTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.darkTheme.colorScheme.onSurface,
                        size: 5.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detectar Alimento por IA',
                          style: AppTheme.darkTheme.textTheme.titleLarge,
                        ),
                        Text(
                          'Capture ou selecione uma foto',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color:
                                AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Error message
                  if (_errorMessage != null)
                    Container(
                      margin: EdgeInsets.all(4.w),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.errorRed),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'error',
                            color: AppTheme.errorRed,
                            size: 5.w,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.errorRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Camera preview or image preview
                  if (_showCamera && _isCameraInitialized)
                    CameraPreviewWidget(
                      controller: _cameraController!,
                      onCapture: _capturePhoto,
                      onClose: _toggleCamera,
                    )
                  else if (_selectedImage != null)
                    ImagePreviewWidget(
                      imageFile: _selectedImage!,
                      isAnalyzing: _isAnalyzing,
                      onRetake: _retakePhoto,
                    )
                  else
                    // Camera controls (initial state)
                    CameraControlsWidget(
                      onCameraPressed: _toggleCamera,
                      onGalleryPressed: _pickFromGallery,
                      isCameraInitialized: _isCameraInitialized,
                    ),

                  // Analysis results
                  if (_analysisResults != null)
                    FoodAnalysisResultsWidget(
                      results: _analysisResults!,
                      onAddFood: _addFoodToMeal,
                      onAddAll: _reviewMultiple,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
