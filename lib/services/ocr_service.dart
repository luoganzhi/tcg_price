import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final _recognizer = TextRecognizer();

  /// 从图片提取文字
  Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _recognizer.processImage(inputImage);

    return recognizedText.text;
  }

  /// 从识别的文字中提取卡名关键词
  /// MTG 卡名通常是第一行或最大的文字
  String extractCardName(String ocrText) {
    final lines = ocrText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) return '';

    // 取第一行作为卡名（通常 MTG 卡名在卡面上方）
    // 如果第一行太短或太奇怪，尝试前几行
    for (int i = 0; i < lines.length && i < 3; i++) {
      final line = lines[i];

      // 过滤掉明显的非卡名内容
      if (_isLikelyCardName(line)) {
        return line;
      }
    }

    // 兜底：返回第一行
    return lines.first;
  }

  /// 判断这行文字是否可能是卡名
  bool _isLikelyCardName(String text) {
    // 卡名通常 2-4 个单词，不会太长
    final wordCount = text.split(RegExp(r'\s+')).length;
    if (wordCount > 6 || wordCount < 1) return false;

    // 过滤掉包含版权信息、系列名等的内容
    final excludePatterns = [
      '©', 'wizards', 'konami', 'pokemon', '™', '®',
      'mythic', 'rare', 'uncommon', 'common',
      'collector', 'set', 'series',
    ];

    final lower = text.toLowerCase();
    for (final pattern in excludePatterns) {
      if (lower.contains(pattern)) return false;
    }

    return true;
  }

  void dispose() {
    _recognizer.close();
  }
}
