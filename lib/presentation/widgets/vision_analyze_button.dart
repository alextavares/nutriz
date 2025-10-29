import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutriz/services/coach_api_service.dart';
import 'package:nutriz/services/gemini_client.dart' show FoodNutritionData;
import '../pages/vision_result_page.dart';

class VisionAnalyzeButton extends StatefulWidget {
  final String label;
  const VisionAnalyzeButton({super.key, this.label = 'Analisar alimento (foto)'});

  @override
  State<VisionAnalyzeButton> createState() => _VisionAnalyzeButtonState();
}

class _VisionAnalyzeButtonState extends State<VisionAnalyzeButton> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    setState(() => _busy = true);
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      // Use bytes on all platforms to avoid IO imports and keep behavior consistent.
      final Uint8List bytes = await picked.readAsBytes();
      final FoodNutritionData data =
          await CoachApiService.instance.analyzeFoodImageBytes(bytes);

      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => VisionResultPage(data: data),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao analisar foto: ' + e.toString())),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _busy ? null : _run,
      icon: _busy
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.photo_camera_outlined),
      label: Text(_busy ? 'Analisando…' : widget.label),
    );
  }
}
