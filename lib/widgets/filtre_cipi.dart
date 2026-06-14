import 'package:flutter/material.dart';
import '../theme/renkler.dart';

/// Kategori filtre çipi — özelleştirilmiş custom widget (StatelessWidget).
/// notlar_ekrani'ndaki yatay filtre çubuğunda kullanılır.
class FiltreCipi extends StatelessWidget {
  final String etiket;
  final Color renk;
  final bool secili;
  final VoidCallback onTap;

  const FiltreCipi({
    super.key,
    required this.etiket,
    required this.renk,
    required this.secili,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // GestureDetector + Container + BoxDecoration — ders materyali widget'ları.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: secili ? renk.withValues(alpha: 0.13) : Renkler.yuzey,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: secili ? renk : Renkler.metin.withValues(alpha: 0.10),
            width: 1.5,
          ),
          boxShadow: secili ? [] : Renkler.yumusakGolge,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (secili) ...<Widget>[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              etiket,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: secili ? renk : Renkler.metin2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
