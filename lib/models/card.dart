class CardModel {
  final String id;
  final String name;
  final String manaCost;
  final String typeLine;
  final String oracleText;
  final String rarity;
  final String setName;
  final String? imageUrl;
  final String? priceUsd;
  final String? priceUsdFoil;
  final String? artist;

  CardModel({
    required this.id,
    required this.name,
    this.manaCost = '',
    this.typeLine = '',
    this.oracleText = '',
    this.rarity = '',
    this.setName = '',
    this.imageUrl,
    this.priceUsd,
    this.priceUsdFoil,
    this.artist,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    final prices = json['prices'] as Map<String, dynamic>?;

    return CardModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      manaCost: json['mana_cost'] ?? '',
      typeLine: json['type_line'] ?? '',
      oracleText: json['oracle_text'] ?? '',
      rarity: json['rarity'] ?? '',
      setName: json['set_name'] ?? '',
      artist: json['artist'] ?? '',
      imageUrl: (json['image_uris'] as Map<String, dynamic>?)?['normal'],
      priceUsd: prices?['usd'],
      priceUsdFoil: prices?['usd_foil'],
    );
  }

  String get rarityDisplay {
    switch (rarity) {
      case 'mythic':
        return '秘稀';
      case 'rare':
        return '稀有';
      case 'uncommon':
        return '非普通';
      case 'common':
        return '普通';
      default:
        return rarity;
    }
  }

  /// 清理所有法力符号为可读文字（通用方法）
  String cleanManaSymbols(String text) {
    if (text.isEmpty) return '';

    final symbols = {
      '{W}': '白',
      '{U}': '蓝',
      '{B}': '黑',
      '{R}': '红',
      '{G}': '绿',
      '{C}': '无色',
      '{Phyrexian_W}': '白P',
      '{Phyrexian_U}': '蓝P',
      '{Phyrexian_B}': '黑P',
      '{Phyrexian_R}': '红P',
      '{Phyrexian_G}': '绿P',
      '{X}': 'X',
      '{Y}': 'Y',
      '{Z}': 'Z',
      '{0}': '0',
      '{1}': '1',
      '{2}': '2',
      '{3}': '3',
      '{4}': '4',
      '{5}': '5',
      '{6}': '6',
      '{7}': '7',
      '{8}': '8',
      '{9}': '9',
      '{10}': '10',
      '{11}': '11',
      '{12}': '12',
      '{13}': '13',
      '{14}': '14',
      '{15}': '15',
      '{16}': '16',
      '{17}': '17',
      '{18}': '18',
      '{19}': '19',
      '{20}': '20',
      '{100}': '100',
      '{1000000}': '百万',
      '{½}': '1/2',
      '{∞}': '无限',
      '{hw}': '半白',
      '{2w}': '2白',
      '{2u}': '2蓝',
      '{2b}': '2黑',
      '{2r}': '2红',
      '{2g}': '2绿',
      '{w/u}': '白蓝',
      '{w/b}': '白黑',
      '{u/b}': '蓝黑',
      '{u/r}': '蓝红',
      '{b/r}': '黑红',
      '{b/g}': '黑绿',
      '{r/g}': '红绿',
      '{r/w}': '红白',
      '{g/w}': '绿白',
      '{g/u}': '绿蓝',
      '{w/p}': '白P',
      '{u/p}': '蓝P',
      '{b/p}': '黑P',
      '{r/p}': '红P',
      '{g/p}': '绿P',
    };

    String result = text;
    symbols.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    // 去掉剩余的 {}
    result = result.replaceAll('{', '').replaceAll('}', '');
    return result;
  }

  /// 转换法力符号为可读文字
  /// {R} -> 红, {W} -> 白, {U} -> 蓝, {B} -> 黑, {G} -> 绿
  /// {1} -> 1, {2} -> 2, etc.
  String get manaCostDisplay {
    if (manaCost.isEmpty) return '';

    final symbols = {
      '{W}': '白',
      '{U}': '蓝',
      '{B}': '黑',
      '{R}': '红',
      '{G}': '绿',
      '{C}': '无色',
      '{Phyrexian_W}': '白P',
      '{Phyrexian_U}': '蓝P',
      '{Phyrexian_B}': '黑P',
      '{Phyrexian_R}': '红P',
      '{Phyrexian_G}': '绿P',
      '{X}': 'X',
      '{Y}': 'Y',
      '{Z}': 'Z',
      '{0}': '0',
      '{1}': '1',
      '{2}': '2',
      '{3}': '3',
      '{4}': '4',
      '{5}': '5',
      '{6}': '6',
      '{7}': '7',
      '{8}': '8',
      '{9}': '9',
      '{10}': '10',
      '{11}': '11',
      '{12}': '12',
      '{13}': '13',
      '{14}': '14',
      '{15}': '15',
      '{16}': '16',
      '{17}': '17',
      '{18}': '18',
      '{19}': '19',
      '{20}': '20',
      '{100}': '100',
      '{1000000}': '百万',
      '{½}': '1/2',
      '{∞}': '无限',
      '{hw}': '半白',
      '{2w}': '2白',
      '{2u}': '2蓝',
      '{2b}': '2黑',
      '{2r}': '2红',
      '{2g}': '2绿',
      '{w/u}': '白蓝',
      '{w/b}': '白黑',
      '{u/b}': '蓝黑',
      '{u/r}': '蓝红',
      '{b/r}': '黑红',
      '{b/g}': '黑绿',
      '{r/g}': '红绿',
      '{r/w}': '红白',
      '{g/w}': '绿白',
      '{g/u}': '绿蓝',
      '{w/p}': '白P',
      '{u/p}': '蓝P',
      '{b/p}': '黑P',
      '{r/p}': '红P',
      '{g/p}': '绿P',
    };

    String result = manaCost;
    symbols.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    // 去掉剩余的 {}
    result = result.replaceAll('{', '').replaceAll('}', '');
    return result;
  }
}
