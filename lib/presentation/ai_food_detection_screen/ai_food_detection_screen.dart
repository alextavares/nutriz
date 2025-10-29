// ignore_for_file: deprecated_member_use
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/nutrition_storage.dart';
import '../../services/gemini_client.dart';
import '../../services/gemini_service.dart';
import '../../services/fooddb/food_data_central_service.dart';
import '../../services/fooddb/open_food_facts_service.dart';
import '../../services/fooddb/food_normalizer.dart';
import '../../services/env_service.dart';
import '../../theme/design_tokens.dart';
import '../../services/coach_api_service.dart';
import './widgets/camera_controls_widget.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/food_analysis_results_widget.dart';
import './widgets/image_preview_widget.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';

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
  String _targetMealKey = 'snack';
  DateTime? _targetDate;
  final Set<int> _completedIndices = <int>{};
  static const int _overlayRemoveDelayMs = 600;

  // Vision providers
  GeminiClient? _geminiClient;
  late final FoodNormalizerService _normalizer;

  @override
  void initState() {
    super.initState();
    _initializePremiumFeatures();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final mk = args['mealKey'];
        if (mk is String && mk.isNotEmpty) _targetMealKey = mk;
        final td = args['targetDate'];
        if (td is String) {
          try {
            final d = DateTime.parse(td);
            _targetDate = DateTime(d.year, d.month, d.day);
          } catch (_) {}
        }
      }
    });
  }

  void _initializePremiumFeatures() {
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
    // Overrides manuais por item (edição)
    final overrides = <int, Map<String, dynamic>>{};
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        final colors = context.colors;
            final textTheme = Theme.of(context).textTheme;
        return AlertDialog(
          backgroundColor: colors.surfaceContainerHigh,
          title: Text(AppLocalizations.of(context)!.reviewItemsTitle,
              style: textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
              )),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
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
                          color: colors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  colors.outlineVariant.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: selected[i] ?? true,
                                  onChanged: (v) => setStateRow(() => selected[i] = v ?? true),
                                  activeColor: colors.primary,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        items[i].name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodyLarge?.copyWith(
                                          color: colors.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Sugestão: ${items[i].portionSize}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                SizedBox(
                                  width: 180,
                                  child: DropdownButtonFormField<String>(
                                    isDense: true,
                                    value: mealByIndex[i],
                                    items: const [
                                      DropdownMenuItem(value: 'breakfast', child: Text('Café')),
                                      DropdownMenuItem(value: 'lunch', child: Text('Almoço')),
                                      DropdownMenuItem(value: 'dinner', child: Text('Jantar')),
                                      DropdownMenuItem(value: 'snack', child: Text('Lanche')),
                                    ],
                                    onChanged: (v) => setStateRow(() => mealByIndex[i] = v ?? 'snack'),
                                    decoration: const InputDecoration(labelText: 'Período'),
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: TextField(
                                    controller: controllers[i],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'g'),
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    final gramsNow = int.tryParse(controllers[i]?.text.trim() ?? '') ?? 100;
                                    final res = await _openEditDialogDraft(
                                      items[i],
                                      initialGrams: gramsNow,
                                      initialMealKey: mealByIndex[i],
                                    );
                                    if (res != null) {
                                      overrides[i] = res;
                                      controllers[i]?.text = (res['grams'] as int).toString();
                                      setStateRow(() {
                                        mealByIndex[i] = res['mealKey'] as String? ?? mealByIndex[i]!;
                                      });
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    side: BorderSide(color: colors.primary, width: 1),
                                    foregroundColor: colors.primary,
                                  ),
                                  child: const Text('Editar'),
                                ),
                              ],
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
              child: Text(AppLocalizations.of(context)!.cancel,
                  style: TextStyle(color: colors.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Monta lista de itens selecionados com grams
                final List<Map<String, dynamic>> selectedFoods = [];
                final List<int> indicesToRemove = [];
                for (int i = 0; i < items.length; i++) {
                  if (selected[i] != true) continue;
                  indicesToRemove.add(i);
                  final grams =
                      int.tryParse(controllers[i]?.text.trim() ?? '100') ?? 100;
                  final ov = overrides[i];
                  if (ov != null) {
                    final map = <String, dynamic>{
                      'name': ov['name'],
                      'brand': ov['brand'],
                      'calories': ov['calories'],
                      'carbs': ov['carbs'],
                      'protein': ov['protein'],
                      'fat': ov['fat'],
                      'serving': '${ov['grams']} g',
                      'mealTime': ov['mealKey'] ?? (mealByIndex[i] ?? 'snack'),
                      'source': 'AI/edit',
                    };
                    selectedFoods.add(map);
                  } else {
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
                      base['source'] =
                          best.source == 'FDC' ? 'AI/FDC' : 'AI/OFF';
                    } else {
                      base['serving'] = '$grams g';
                    }
                    base['mealTime'] = mealByIndex[i] ?? 'snack';
                    selectedFoods.add(base);
                  }
                }
                if (!mounted) return;
                Navigator.pop(context); // fecha diálogo de revisão
                // Marca itens como concluídos para animar check na lista principal
                setState(() {
                  _completedIndices.addAll(indicesToRemove);
                });
                // Salva em lote e mantém na tela
                final date = _targetDate ?? DateTime.now();
                int okCount = 0;
                for (final f in selectedFoods) {
                  try {
                    await NutritionStorage.addEntry(date, {
                      'name': f['name'],
                      'brand': f['brand'],
                      'calories': (f['calories'] as num?)?.toInt() ?? 0,
                      'carbs': (f['carbs'] as num?)?.toDouble() ?? 0.0,
                      'protein': (f['protein'] as num?)?.toDouble() ?? 0.0,
                      'fat': (f['fat'] as num?)?.toDouble() ?? 0.0,
                      'fiber': (f['fiber'] as num?)?.toDouble(),
                      'sugar': (f['sugar'] as num?)?.toDouble(),
                       'serving': (f['serving']?.toString() ?? AppLocalizations.of(context) !.onePortion),
                      'mealTime': f['mealTime'] ?? 'snack',
                      'createdAt': DateTime.now().toIso8601String(),
                      'source': f['source']?.toString() ?? 'AI/batch',
                    });
                    okCount++;
                  } catch (_) {}
                }
                if (okCount > 0) {
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.itemsAdded(okCount),
                    backgroundColor: AppTheme.successGreen,
                    textColor: AppTheme.textPrimary,
                  );
                  // Remover após breve animação de check
                  Future.delayed(const Duration(milliseconds: _overlayRemoveDelayMs), () {
                    if (!mounted) return;
                    setState(() {
                      if (_analysisResults != null) {
                        final list = List<DetectedFood>.from(_analysisResults!.foods);
                        indicesToRemove.sort((a,b)=>b.compareTo(a));
                        for (final idx in indicesToRemove) {
                          if (idx >= 0 && idx < list.length) list.removeAt(idx);
                        }
                        _analysisResults = FoodNutritionData(foods: list);
                      }
                      _completedIndices.clear();
                    });
                  });
                }
              },
              child: Text(AppLocalizations.of(context)!.addSelected),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeGeminiClient() async {
    GeminiClient? client;
    try {
      await GeminiService.init();
      final service = GeminiService();
      client = GeminiClient(service.dio, service.authApiKey);
    } catch (e) {
      debugPrint('[AiFoodDetection] Gemini indisponível: $e');
    }

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

    if (client != null) {
      _geminiClient = client;
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
        enableAudio: false,
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
          _showCamera = true;
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
      final colors = context.colors;
      Fluttertoast.showToast(
        msg: 'Erro ao capturar foto: $e',
        backgroundColor: colors.error,
        textColor: colors.onError,
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
      final colors = context.colors;
      Fluttertoast.showToast(
        msg: 'Erro ao selecionar imagem: $e',
        backgroundColor: colors.error,
        textColor: colors.onError,
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
      FoodNutritionData? results;
      String providerTag = 'servidor';
      CoachApiException? remoteError;

      try {
        results = await CoachApiService.instance.analyzeFoodImageDetailed(imageFile);
      } on CoachApiException catch (e) {
        remoteError = e;
        debugPrint('[AiFoodDetection] Coach vision fallback: ${e.code} (${e.message})');
      }

      if (results == null) {
        final fallback = _geminiClient;
        if (fallback != null) {
          try {
            results = await fallback.analyzeFoodImage(imageFile);
            providerTag = 'Gemini';
          } catch (fallbackErr) {
            if (remoteError != null) {
              throw Exception(
                  '${remoteError.message}\nFallback Gemini falhou: ${fallbackErr.toString()}');
            }
            rethrow;
          }
        } else if (remoteError != null) {
          throw remoteError;
        } else {
          throw Exception('Nenhum provedor de visão configurado.');
        }
      }

      final data = results;

      setState(() {
        _analysisResults = data;
        _isAnalyzing = false;
        _completedIndices.clear();
      });

      if (data.foods.isEmpty) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.noFoodDetectedInImage,
          backgroundColor: context.semanticColors.warning,
          textColor: context.semanticColors.onWarning,
        );
      } else {
        Fluttertoast.showToast(
          msg: '${data.foods.length} alimento(s) detectado(s) (${providerTag})',
          backgroundColor: context.semanticColors.success,
          textColor: context.semanticColors.onSuccess,
        );
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Erro na análise: ${e.toString()}';
      });

      final colors = context.colors;
      Fluttertoast.showToast(
        msg: 'Erro ao analisar imagem',
        backgroundColor: colors.error,
        textColor: colors.onError,
      );
    }
  }

  int _parseGrams(String? s) {
    if (s == null) return 100;
    final match = RegExp(r"(\d+)").firstMatch(s);
    final g = match != null ? int.tryParse(match.group(1)!) ?? 100 : 100;
    return g <= 0 ? 100 : g;
  }

  Future<void> _editAndAddFood(DetectedFood food) async {
    // Base a partir do normalizador (FDC/OFF) para facilitar edição
    final best = await _normalizer.findBestMatch(food.name);
    Map<String, dynamic> base = food.toFoodMap();
    if (best != null) {
      base['brand'] = best.brand ?? base['brand'];
      base['calories'] = (best.caloriesPer100g).round();
      base['carbs'] = best.carbsPer100g;
      base['protein'] = best.proteinPer100g;
      base['fat'] = best.fatPer100g;
      base['fiber'] = (food.fiber); // manter se IA enviou
      base['sugar'] = (food.sugar);
      base['serving'] = base['serving'] ?? '100 g';
      base['source'] = best.source == 'FDC' ? 'AI/FDC' : 'AI/OFF';
    }

    final nameCtrl =
        TextEditingController(text: base['name']?.toString() ?? '');
    final brandCtrl =
        TextEditingController(text: base['brand']?.toString() ?? '');
    final kcalCtrl = TextEditingController(
        text:
            ((base['calories'] as num?)?.toInt() ?? food.calories).toString());
    final carbsCtrl = TextEditingController(
        text: ((base['carbs'] as num?)?.toDouble() ?? food.carbs)
            .toStringAsFixed(1));
    final protCtrl = TextEditingController(
        text: ((base['protein'] as num?)?.toDouble() ?? food.protein)
            .toStringAsFixed(1));
    final fatCtrl = TextEditingController(
        text:
            ((base['fat'] as num?)?.toDouble() ?? food.fat).toStringAsFixed(1));
    final fiberCtrl = TextEditingController(
        text: ((base['fiber'] as num?)?.toDouble() ?? food.fiber)
            .toStringAsFixed(1));
    final sugarCtrl = TextEditingController(
        text: ((base['sugar'] as num?)?.toDouble() ?? food.sugar)
            .toStringAsFixed(1));
    final gramsCtrl = TextEditingController(
        text: _parseGrams(base['serving']?.toString()).toString());
    String mealKey = _targetMealKey;

    // Recalcular macros ao alterar gramas quando possível
    // per100 preferencialmente do banco; caso não haja, deriva da porção atual
    final int g0 = _parseGrams(base['serving']?.toString());
    final double calsPer100 = (best != null)
        ? best.caloriesPer100g.toDouble()
        : (g0 > 0
            ? (((base['calories'] as num?)?.toDouble() ??
                    food.calories.toDouble()) /
                g0 *
                100.0)
            : 0.0);
    final double carbsPer100 = (best != null)
        ? best.carbsPer100g
        : (g0 > 0
            ? (((base['carbs'] as num?)?.toDouble() ?? food.carbs) / g0 * 100.0)
            : 0.0);
    final double protPer100 = (best != null)
        ? best.proteinPer100g
        : (g0 > 0
            ? (((base['protein'] as num?)?.toDouble() ?? food.protein) /
                g0 *
                100.0)
            : 0.0);
    final double fatPer100 = (best != null)
        ? best.fatPer100g
        : (g0 > 0
            ? (((base['fat'] as num?)?.toDouble() ?? food.fat) / g0 * 100.0)
            : 0.0);
    final double fiberPer100 = (g0 > 0)
        ? (((base['fiber'] as num?)?.toDouble() ?? food.fiber) / g0 * 100.0)
        : 0.0;
    final double sugarPer100 = (g0 > 0)
        ? (((base['sugar'] as num?)?.toDouble() ?? food.sugar) / g0 * 100.0)
        : 0.0;

    gramsCtrl.addListener(() {
      final grams = int.tryParse(gramsCtrl.text.trim()) ?? 0;
      if (grams <= 0) return;
      // Só recalcula se temos base por 100
      if (calsPer100 > 0) {
        kcalCtrl.text = ((calsPer100 * grams) / 100).round().toString();
      }
      if (carbsPer100 > 0) {
        carbsCtrl.text = ((carbsPer100 * grams) / 100).toStringAsFixed(1);
      }
      if (protPer100 > 0) {
        protCtrl.text = ((protPer100 * grams) / 100).toStringAsFixed(1);
      }
      if (fatPer100 > 0) {
        fatCtrl.text = ((fatPer100 * grams) / 100).toStringAsFixed(1);
      }
      if (fiberPer100 > 0) {
        fiberCtrl.text = ((fiberPer100 * grams) / 100).toStringAsFixed(1);
      }
      if (sugarPer100 > 0) {
        sugarCtrl.text = ((sugarPer100 * grams) / 100).toStringAsFixed(1);
      }
    });

    // Estado local para flag de template na ação do diálogo
    bool saveAsTemplate = false;
    final TextEditingController tplLabelCtrl =
        TextEditingController(text: nameCtrl.text.trim());

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryBackgroundDark,
          title: Text(
            AppLocalizations.of(context)!.addOrEdit,
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: brandCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Marca (opcional)'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: gramsCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Porção (g)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: kcalCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.caloriesLabel} (kcal)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: carbsCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.carbsLabel} (g)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: protCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.proteinLabel} (g)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: fatCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.fatLabel} (g)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: fiberCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'Fibras (g)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: sugarCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'Açúcares (g)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: mealKey,
                  decoration: const InputDecoration(labelText: 'Refeição'),
                  items: const [
                    DropdownMenuItem(
                        value: 'breakfast', child: Text('Café da manhã')),
                    DropdownMenuItem(value: 'lunch', child: Text('Almoço')),
                    DropdownMenuItem(value: 'dinner', child: Text('Jantar')),
                    DropdownMenuItem(value: 'snack', child: Text('Lanche')),
                  ],
                  onChanged: (v) => mealKey = v ?? mealKey,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel,
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            // Salvar e adicionar (com opção de salvar como template)
            StatefulBuilder(builder: (context, setBtn) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: saveAsTemplate,
                        onChanged: (v) {
                          setBtn(() {
                            saveAsTemplate = v ?? false;
                          });
                        },
                        activeColor: AppTheme.activeBlue,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: tplLabelCtrl,
                          decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.saveAsMyFoodOptional),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim().isEmpty
                          ? (base['name']?.toString() ?? 'Alimento')
                          : nameCtrl.text.trim();
                      final brand = brandCtrl.text.trim().isEmpty
                          ? null
                          : brandCtrl.text.trim();
                      final grams = int.tryParse(gramsCtrl.text.trim()) ??
                          _parseGrams(base['serving']?.toString());
                      final kcal = int.tryParse(kcalCtrl.text.trim()) ??
                          ((base['calories'] as num?)?.toInt() ?? 0);
                      final carbs = double.tryParse(carbsCtrl.text.trim()) ??
                          ((base['carbs'] as num?)?.toDouble() ?? 0.0);
                      final prot = double.tryParse(protCtrl.text.trim()) ??
                          ((base['protein'] as num?)?.toDouble() ?? 0.0);
                      final fat = double.tryParse(fatCtrl.text.trim()) ??
                          ((base['fat'] as num?)?.toDouble() ?? 0.0);
                      final fiber = double.tryParse(fiberCtrl.text.trim()) ??
                          ((base['fiber'] as num?)?.toDouble() ?? 0.0);
                      final sugar = double.tryParse(sugarCtrl.text.trim()) ??
                          ((base['sugar'] as num?)?.toDouble() ?? 0.0);

                      final date = _targetDate ?? DateTime.now();
                      final entry = <String, dynamic>{
                        'name': name,
                        'brand': brand,
                        'calories': kcal,
                        'carbs': carbs,
                        'protein': prot,
                        'fat': fat,
                        'fiber': fiber,
                        'sugar': sugar,
                        'serving': '${grams} g',
                        'mealTime': mealKey,
                        'createdAt': DateTime.now().toIso8601String(),
                        'source': 'AI/edit',
                      };
                      await NutritionStorage.addEntry(date, entry);
                      if (saveAsTemplate) {
                        final label = (tplLabelCtrl.text.trim().isEmpty)
                            ? name
                            : tplLabelCtrl.text.trim();
                        await NutritionStorage.saveMealTemplate(
                            label: label, items: [entry]);
                      }
                      if (!mounted) return;
                      Navigator.pop(context); // fecha diálogo
                      Fluttertoast.showToast(
                        msg: '$name • +${kcal} kcal no ' +
                            ((mealKey == 'breakfast')
                                ? 'café'
                                : (mealKey == 'lunch')
                                    ? 'almoço'
                                    : (mealKey == 'dinner')
                                        ? 'jantar'
                                        : 'lanche'),
                        backgroundColor: AppTheme.successGreen,
                        textColor: AppTheme.textPrimary,
                      );
                      // Permanece nesta tela para permitir adicionar mais itens sem perder a lista
                    },
                    child: Text(AppLocalizations.of(context)!.saveAndAdd),
                  ),
                ],
              );
            }),
          ],
        );
      },
    );
  }

  // Diálogo de edição para o fluxo em lote; retorna mapa com campos editados
  Future<Map<String, dynamic>?> _openEditDialogDraft(DetectedFood food,
      {int? initialGrams, String? initialMealKey}) async {
    // Base semelhante ao normalizador de adição
    final best = await _normalizer.findBestMatch(food.name);
    Map<String, dynamic> base = food.toFoodMap();
    if (best != null) {
      base['brand'] = best.brand ?? base['brand'];
      base['calories'] = (best.caloriesPer100g).round();
      base['carbs'] = best.carbsPer100g;
      base['protein'] = best.proteinPer100g;
      base['fat'] = best.fatPer100g;
      base['serving'] = base['serving'] ?? '100 g';
      base['source'] = best.source == 'FDC' ? 'AI/FDC' : 'AI/OFF';
    }

    final nameCtrl =
        TextEditingController(text: base['name']?.toString() ?? '');
    final brandCtrl =
        TextEditingController(text: base['brand']?.toString() ?? '');
    final kcalCtrl = TextEditingController(
        text:
            ((base['calories'] as num?)?.toInt() ?? food.calories).toString());
    final carbsCtrl = TextEditingController(
        text: ((base['carbs'] as num?)?.toDouble() ?? food.carbs)
            .toStringAsFixed(1));
    final protCtrl = TextEditingController(
        text: ((base['protein'] as num?)?.toDouble() ?? food.protein)
            .toStringAsFixed(1));
    final fatCtrl = TextEditingController(
        text:
            ((base['fat'] as num?)?.toDouble() ?? food.fat).toStringAsFixed(1));
    final gramsCtrl = TextEditingController(
        text: (initialGrams ?? _parseGrams(base['serving']?.toString()))
            .toString());
    final fiberCtrl = TextEditingController(
        text: ((base['fiber'] as num?)?.toDouble() ?? food.fiber)
            .toStringAsFixed(1));
    final sugarCtrl = TextEditingController(
        text: ((base['sugar'] as num?)?.toDouble() ?? food.sugar)
            .toStringAsFixed(1));
    String mealKey = initialMealKey ?? _targetMealKey;

    // Preparar recálculo por 100g
    final int g0 = _parseGrams(base['serving']?.toString());
    final double calsPer100 = (g0 > 0)
        ? (((base['calories'] as num?)?.toDouble() ??
                food.calories.toDouble()) /
            g0 *
            100.0)
        : 0.0;
    final double carbsPer100 = (g0 > 0)
        ? (((base['carbs'] as num?)?.toDouble() ?? food.carbs) / g0 * 100.0)
        : 0.0;
    final double protPer100 = (g0 > 0)
        ? (((base['protein'] as num?)?.toDouble() ?? food.protein) / g0 * 100.0)
        : 0.0;
    final double fatPer100 = (g0 > 0)
        ? (((base['fat'] as num?)?.toDouble() ?? food.fat) / g0 * 100.0)
        : 0.0;
    final double fiberPer100 = (g0 > 0)
        ? (((base['fiber'] as num?)?.toDouble() ?? food.fiber) / g0 * 100.0)
        : 0.0;
    final double sugarPer100 = (g0 > 0)
        ? (((base['sugar'] as num?)?.toDouble() ?? food.sugar) / g0 * 100.0)
        : 0.0;

    gramsCtrl.addListener(() {
      final grams = int.tryParse(gramsCtrl.text.trim()) ?? 0;
      if (grams <= 0) return;
      if (calsPer100 > 0)
        kcalCtrl.text = ((calsPer100 * grams) / 100).round().toString();
      if (carbsPer100 > 0)
        carbsCtrl.text = ((carbsPer100 * grams) / 100).toStringAsFixed(1);
      if (protPer100 > 0)
        protCtrl.text = ((protPer100 * grams) / 100).toStringAsFixed(1);
      if (fatPer100 > 0)
        fatCtrl.text = ((fatPer100 * grams) / 100).toStringAsFixed(1);
      if (fiberPer100 > 0)
        fiberCtrl.text = ((fiberPer100 * grams) / 100).toStringAsFixed(1);
      if (sugarPer100 > 0)
        sugarCtrl.text = ((sugarPer100 * grams) / 100).toStringAsFixed(1);
    });

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.secondaryBackgroundDark,
            title: Text('Editar item',
                style: AppTheme.darkTheme.textTheme.titleLarge
                    ?.copyWith(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: brandCtrl,
                decoration:
                    const InputDecoration(labelText: 'Marca (opcional)'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: gramsCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Porção (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: kcalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText:
                              '${AppLocalizations.of(context)!.caloriesLabel} (kcal)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: carbsCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText:
                              '${AppLocalizations.of(context)!.carbsLabel} (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: protCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText:
                              '${AppLocalizations.of(context)!.proteinLabel} (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fatCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText:
                              '${AppLocalizations.of(context)!.fatLabel} (g)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: fiberCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Fibras (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: sugarCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Açúcares (g)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: mealKey,
                decoration: const InputDecoration(labelText: 'Refeição'),
                items: const [
                  DropdownMenuItem(
                      value: 'breakfast', child: Text('Café da manhã')),
                  DropdownMenuItem(value: 'lunch', child: Text('Almoço')),
                  DropdownMenuItem(value: 'dinner', child: Text('Jantar')),
                  DropdownMenuItem(value: 'snack', child: Text('Lanche')),
                ],
                onChanged: (v) => mealKey = v ?? mealKey,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop<Map<String, dynamic>>(context, {
                'name': nameCtrl.text.trim().isEmpty
                    ? food.name
                    : nameCtrl.text.trim(),
                'brand': brandCtrl.text.trim().isEmpty
                    ? null
                    : brandCtrl.text.trim(),
                'grams': int.tryParse(gramsCtrl.text.trim()) ??
                    _parseGrams(base['serving']?.toString()),
                'calories': int.tryParse(kcalCtrl.text.trim()) ?? food.calories,
                'carbs': double.tryParse(carbsCtrl.text.trim()) ?? food.carbs,
                'protein':
                    double.tryParse(protCtrl.text.trim()) ?? food.protein,
                'fat': double.tryParse(fatCtrl.text.trim()) ?? food.fat,
                'fiber': double.tryParse(fiberCtrl.text.trim()) ?? food.fiber,
                'sugar': double.tryParse(sugarCtrl.text.trim()) ?? food.sugar,
                'mealKey': mealKey,
              });
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );

    return result;
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
    // Normalize with FDC/OFF if available
    final best = await _normalizer.findBestMatch(food.name);
    Map<String, dynamic> base = food.toFoodMap();
    if (best != null) {
      // Use 100g baseline when exact grams unknown
      base['brand'] = best.brand ?? base['brand'];
      base['calories'] = (best.caloriesPer100g).round();
      base['carbs'] = best.carbsPer100g;
      base['protein'] = best.proteinPer100g;
      base['fat'] = best.fatPer100g;
      base['serving'] = '100 g';
      base['source'] = best.source == 'FDC' ? 'AI/FDC' : 'AI/OFF';
    }

    // Directly save entry and return to previous (faster flow)
    final date = _targetDate ?? DateTime.now();
    final entry = {
      'name': base['name'],
      'brand': base['brand'],
      'calories': (base['calories'] as num?)?.toInt() ?? 0,
      'carbs': (base['carbs'] as num?)?.toDouble() ?? 0.0,
      'protein': (base['protein'] as num?)?.toDouble() ?? 0.0,
      'fat': (base['fat'] as num?)?.toDouble() ?? 0.0,
      'serving': base['serving'] ?? '100 g',
      'mealTime': _targetMealKey,
      'createdAt': DateTime.now().toIso8601String(),
      'source': 'AI/quick',
    };
    try {
      await NutritionStorage.addEntry(date, entry);
      if (!mounted) return;
      // Agenda a remoção após uma curta animação de check
      Future.delayed(const Duration(milliseconds: _overlayRemoveDelayMs), () {
        if (!mounted) return;
        setState(() {
          if (_analysisResults != null) {
            final remaining = List<DetectedFood>.from(_analysisResults!.foods);
            remaining.removeWhere((f) => identical(f, food) ||
                (f.name == food.name && f.calories == food.calories && f.portionSize == food.portionSize));
            _analysisResults = FoodNutritionData(foods: remaining);
          }
          _completedIndices.clear();
        });
      });
      Fluttertoast.showToast(
        msg: '${entry['name']} • +${entry['calories']} kcal no ' +
            ((_targetMealKey == 'breakfast')
                ? 'café'
                : (_targetMealKey == 'lunch')
                    ? 'almoço'
                    : (_targetMealKey == 'dinner')
                        ? 'jantar'
                        : 'lanche'),
        backgroundColor: AppTheme.successGreen,
        textColor: AppTheme.textPrimary,
      );
      // Não navega para fora; mantém na tela para permitir adicionar outros itens
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Erro ao salvar alimento',
        backgroundColor: AppTheme.errorRed,
        textColor: AppTheme.textPrimary,
      );
    }
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
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: [
          // Header
          SafeArea(
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.outline.withValues(alpha: 0.2),
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
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: colors.onSurface,
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
                          AppLocalizations.of(context)!.detectFoodHeadline,
                          style: textTheme.titleLarge,
                        ),
                        Text(
                          AppLocalizations.of(context)!.detectFoodSubtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
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
                        color: colors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.error),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'error',
                            color: colors.error,
                            size: 5.w,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colors.error,
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
                      onGallery: _pickFromGallery,
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
                      onEditFood: _editAndAddFood,
                      onAddAll: _reviewMultiple,
                      completedIndices: _completedIndices,
                      onMarkComplete: (i) {
                        setState(() => _completedIndices.add(i));
                      },
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





