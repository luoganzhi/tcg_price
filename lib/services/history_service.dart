import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _key = 'search_history';
  static const int _maxItems = 20;

  /// 获取搜索历史
  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];
    return history;
  }

  /// 添加搜索记录
  Future<void> addHistory(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];

    // 移除已存在的相同记录
    history.remove(query);

    // 添加到最前面
    history.insert(0, query);

    // 限制数量
    if (history.length > _maxItems) {
      history.removeRange(_maxItems, history.length);
    }

    await prefs.setStringList(_key, history);
  }

  /// 清除历史
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// 删除单条记录
  Future<void> removeHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];
    history.remove(query);
    await prefs.setStringList(_key, history);
  }
}
