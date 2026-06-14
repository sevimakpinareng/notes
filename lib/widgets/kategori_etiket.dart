import 'package:flutter/material.dart';
import '../models/kategori.dart';

/// Kategori rozeti — küçük renkli etiket.
/// Özelleştirilmiş Widget (custom widget) örneği; kartlarda tekrar kullanılır.
class KategoriEtiket extends StatelessWidget {
  final Kategori kategori;
  const KategoriEtiket({super.key, required this.kategori});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // Kategori renginin çok hafif (yumuşak) tonu — withValues ile opaklık.
        color: kategori.renk.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // sadece içerik kadar genişle
        children: <Widget>[
          // Renkli nokta
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: kategori.renk,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            kategori.kategoriAd,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kategori.renk,
            ),
          ),
        ],
      ),
    );
  }
}
