import 'package:flutter/material.dart';
import '../models/kategori.dart';
import '../models/not.dart';
import '../theme/renkler.dart';
import 'kategori_etiket.dart';

/// Not kartı — özelleştirilmiş custom widget (StatelessWidget).
/// Tekrar eden kart yapısını encapsulate eder.
class NotKarti extends StatelessWidget {
  final Not not;
  final List<Kategori> kategoriler; // DB'den yüklenen liste
  final VoidCallback onTiklandi;
  final VoidCallback onFavoriDegisti;

  const NotKarti({
    super.key,
    required this.not,
    required this.kategoriler,
    required this.onTiklandi,
    required this.onFavoriDegisti,
  });

  String _tarihMetni(String iso) {
    const aylar = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
    ];
    final d = DateTime.tryParse(iso) ?? DateTime.now();
    final gun = DateTime.now().difference(d).inDays;
    final saat =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    if (gun <= 0) return 'Bugün $saat';
    if (gun == 1) return 'Dün $saat';
    if (gun < 7) return '$gun gün önce';
    return '${d.day} ${aylar[d.month - 1]}';
  }

  Widget _oncelikRozeti(int oncelik) {
    final Color renk;
    final IconData ikon;
    final String metin;
    switch (oncelik) {
      case 0:
        renk = Renkler.oncelikDusuk;
        ikon = Icons.keyboard_double_arrow_down_rounded;
        metin = 'Düşük';
      case 2:
        renk = Renkler.oncelikYuksek;
        ikon = Icons.keyboard_double_arrow_up_rounded;
        metin = 'Yüksek';
      default:
        renk = Renkler.oncelikOrta;
        ikon = Icons.remove_rounded;
        metin = 'Orta';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(ikon, size: 11, color: renk),
          const SizedBox(width: 3),
          Text(
            metin,
            style: TextStyle(
              fontSize: 10.5,
              color: renk,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTiklandi,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(18, 14, 12, 15),
        decoration: BoxDecoration(
          color: Renkler.yuzey,
          borderRadius: BorderRadius.circular(20),
          boxShadow: Renkler.yumusakGolge,
          border: Border.all(color: Renkler.metin.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                KategoriEtiket(kategori: not.kategoriIle(kategoriler)),
                const SizedBox(width: 6),
                _oncelikRozeti(not.oncelik),
                const Spacer(),
                // Etkileşimli widget — GestureDetector.
                GestureDetector(
                  onTap: onFavoriDegisti,
                  child: Icon(
                    not.favori
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 22,
                    color: not.favori ? Colors.amber : Renkler.metin2,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _tarihMetni(not.olusturmaTarihi),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Renkler.metin2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              not.baslik,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Renkler.metin,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              not.icerik.isEmpty ? 'İçerik yok.' : not.icerik,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.5,
                color: Renkler.metin2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
