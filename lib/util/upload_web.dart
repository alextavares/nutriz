import 'dart:async' show Completer;
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Future<String?> pickCsvText() async {
  final completer = Completer<String?>();
  final input = html.FileUploadInputElement()
    ..accept = '.csv,text/csv'
    ..multiple = false;
  input.onChange.listen((_) async {
    if (input.files == null || input.files!.isEmpty) {
      completer.complete(null);
      return;
    }
    final file = input.files!.first;
    final reader = html.FileReader();
    reader.onError.listen((_) => completer.complete(null));
    reader.onLoadEnd.listen((_) {
      final text = reader.result?.toString();
      completer.complete(text);
    });
    reader.readAsText(file);
  });
  input.click();
  return completer.future;
}
