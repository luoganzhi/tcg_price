import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card.dart';

class ScryfallService {
  static const String _baseUrl = 'https://api.scryfall.com';

  /// 搜索卡牌
  Future<List<CardModel>> searchCards(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final encodedQuery = Uri.encodeComponent(query.trim());
    final url = Uri.parse('$_baseUrl/cards/search?q=$encodedQuery');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['object'] == 'list') {
          final cards = (data['data'] as List)
              .map((card) => CardModel.fromJson(card))
              .toList();
          return cards;
        }
        return [];
      } else if (response.statusCode == 404) {
        // 404 = 未找到卡牌，不算错误
        return [];
      } else {
        throw ScryfallException('搜索失败: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ScryfallException) rethrow;
      throw ScryfallException('网络错误: $e');
    }
  }

  /// 自动补全（用于搜索建议）
  Future<List<String>> autocomplete(String query) async {
    if (query.trim().length < 2) {
      return [];
    }

    final encodedQuery = Uri.encodeComponent(query.trim());
    final url = Uri.parse('$_baseUrl/cards/autocomplete?q=$encodedQuery');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

class ScryfallException implements Exception {
  final String message;
  ScryfallException(this.message);

  @override
  String toString() => message;
}
