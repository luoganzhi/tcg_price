import 'package:flutter/material.dart';
import '../models/card.dart';

class CardResult extends StatelessWidget {
  final CardModel card;

  const CardResult({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡牌图片
          if (card.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                card.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 200,
                  child: Center(child: Icon(Icons.broken_image, size: 48)),
                ),
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 卡名
                Text(
                  card.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // 系列和稀有度
                Row(
                  children: [
                    _tag(card.setName, Colors.blue),
                    const SizedBox(width: 8),
                    _tag(card.rarityDisplay, _getRarityColor(card.rarity)),
                    if (card.manaCost.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(card.manaCostDisplay, style: const TextStyle(fontSize: 16)),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // 价格信息
                Row(
                  children: [
                    Expanded(
                      child: _priceBox('普通', card.priceUsd),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _priceBox('闪卡', card.priceUsdFoil),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 类型和效果
                if (card.typeLine.isNotEmpty)
                  Text(
                    card.cleanManaSymbols(card.typeLine),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                if (card.oracleText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    card.cleanManaSymbols(card.oracleText),
                    style: const TextStyle(fontSize: 13),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                if (card.artist != null && card.artist!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '插画: ${card.artist}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _priceBox(String label, String? price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price != null ? '\$$price' : '-',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'mythic':
        return Colors.orange;
      case 'rare':
        return Colors.amber;
      case 'uncommon':
        return Colors.grey;
      case 'common':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }
}
