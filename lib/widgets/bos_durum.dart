import 'package:flutter/material.dart';
import '../theme/renkler.dart';

/// Boş durum bloğu — özelleştirilmiş custom widget.
/// [ikon], [baslik] ve [altyazi] parametreleriyle 3 farklı durum desteklenir:
///   • Henüz not yok  • Arama sonuç yok  • Filtre boş
class BosDurum extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String altyazi;
  final Color renkArka;

  const BosDurum({
    super.key,
    this.ikon = Icons.description_outlined,
    this.baslik = 'Henüz not eklenmedi',
    this.altyazi = 'Sağ alttaki + butonuna basarak\nilk notunu oluştur.',
    this.renkArka = Renkler.birincil,
  });

  @override
  Widget build(BuildContext context) {
    // Center + Column + Container + BoxDecoration — ders materyali layout widget'ları.
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: renkArka,
                shape: BoxShape.circle,
              ),
              child: Icon(ikon, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              baslik,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Renkler.metin,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              altyazi,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
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
