import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/card.dart';
import '../services/scryfall_service.dart';
import '../services/ocr_service.dart';
import '../services/history_service.dart';
import '../widgets/card_result.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _service = ScryfallService();
  final _ocrService = OcrService();
  final _historyService = HistoryService();
  final _picker = ImagePicker();
  final _focusNode = FocusNode();

  List<CardModel> _results = [];
  bool _isLoading = false;
  bool _isScanning = false;
  String? _errorMessage;
  String? _scanTip;
  List<String> _history = [];
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _ocrService.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showHistory = _focusNode.hasFocus && _controller.text.isEmpty;
    });
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.getHistory();
    setState(() {
      _history = history;
    });
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _results = [];
      _scanTip = null;
      _showHistory = false;
    });

    try {
      final cards = await _service.searchCards(query);
      // 保存到历史
      await _historyService.addHistory(query);
      _loadHistory();

      setState(() {
        _results = cards;
        _isLoading = false;
        if (cards.isEmpty) {
          _errorMessage = '未找到相关卡牌，请尝试其他关键词';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _scanCard() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (photo == null) return;

      setState(() {
        _isScanning = true;
        _scanTip = '正在识别卡牌...';
        _results = [];
        _errorMessage = null;
      });

      // OCR 识别
      final ocrText = await _ocrService.extractText(photo.path);

      if (ocrText.isEmpty) {
        setState(() {
          _scanTip = '未识别到文字，请重试';
          _isScanning = false;
        });
        return;
      }

      final cardName = _ocrService.extractCardName(ocrText);

      setState(() {
        _scanTip = '识别到: $cardName，正在搜索...';
        _controller.text = cardName;
      });

      // 自动搜索
      final cards = await _service.searchCards(cardName);
      await _historyService.addHistory(cardName);
      _loadHistory();

      setState(() {
        _results = cards;
        _isScanning = false;
        _scanTip = null;
        if (cards.isEmpty) {
          _errorMessage = '未找到 "$cardName"，请手动修正后搜索';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = '扫描失败: $e';
        _isScanning = false;
        _scanTip = null;
      });
    }
  }

  void _selectHistory(String query) {
    _controller.text = query;
    _showHistory = false;
    _search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MTG 卡牌价格查询'),
        centerTitle: true,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await _historyService.clearHistory();
                _loadHistory();
              },
              tooltip: '清除历史',
            ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _isScanning ? null : _scanCard,
            tooltip: '拍照扫描',
          ),
        ],
      ),
      body: Column(
        children: [
          // 扫描提示
          if (_scanTip != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue[50],
              child: Row(
                children: [
                  if (_isScanning)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_scanTip!)),
                ],
              ),
            ),

          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: '输入卡名搜索...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_controller.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              setState(() {
                                _results = [];
                                _errorMessage = null;
                                _showHistory = true;
                              });
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt_outlined),
                          onPressed: _isScanning ? null : _scanCard,
                          tooltip: '拍照扫描',
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _showHistory = value.isEmpty && _focusNode.hasFocus;
                    });
                  },
                  onTap: () {
                    if (_controller.text.isEmpty) {
                      setState(() {
                        _showHistory = true;
                      });
                    }
                  },
                  onSubmitted: (_) => _search(),
                ),

                // 历史记录列表
                if (_showHistory && _history.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final query = _history[index];
                        return ListTile(
                          leading: const Icon(Icons.history, size: 20),
                          title: Text(query),
                          dense: true,
                          onTap: () => _selectHistory(query),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // 搜索按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _search,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('搜索'),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 结果区域
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _search,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty && !_isLoading && !_isScanning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '点击右上角相机图标拍照扫描',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '或输入卡名搜索',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty && (_isLoading || _isScanning)) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        return CardResult(card: _results[index]);
      },
    );
  }
}
