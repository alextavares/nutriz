import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Compresses [bytes] to JPEG with max dimension [maxDim] and quality [quality].
/// Returns original bytes if decode fails.
Future<Uint8List> compressToJpeg(Uint8List bytes, {int maxDim = 768, int quality = 85}) async {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    img.Image image = decoded;
    final w = image.width, h = image.height;
    if (w > maxDim || h > maxDim) {
      final scale = (w > h) ? maxDim / w : maxDim / h;
      final nw = (w * scale).round();
      final nh = (h * scale).round();
      image = img.copyResize(image, width: nw, height: nh, interpolation: img.Interpolation.average);
    }
    final jpg = img.encodeJpg(image, quality: quality);
    return Uint8List.fromList(jpg);
  } catch (_) {
    return bytes;
  }
}
