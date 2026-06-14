import 'package:flutter/material.dart';
import '../database/not_dao.dart';
import '../models/kategori.dart';
import '../theme/renkler.dart';
import '../widgets/kategori_etiket.dart';

/// İstatistik ekranı — toplam not sayısı ve kategori dağılımı.
class IstatistikEkrani extends StatefulWidget {
  final int kullaniciId;
  final List<Kategori> kategoriler; // DB'den yüklenen liste
  const IstatistikEkrani({
    super.key,
    required this.kullaniciId,
    required this.kategoriler,
  });

  @override
  State<IstatistikEkrani> createState() => _IstatistikEkraniState();
}

class _IstatistikEkraniState extends State<IstatistikEkrani> {
  final NotDao _dao = NotDao();
  int _toplam = 0;
  Map<int, int> _sayilar = {};
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    try {
      final toplam = await _dao.toplamNotSayisi(widget.kullaniciId);
      final sayilar = await _dao.kategoriSayilari(
        widget.kullaniciId,
        widget.kategoriler,
      );
      if (!mounted) return;
      setState(() {
        _toplam = toplam;
        _sayilar = sayilar;
        _yukleniyor = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final en = MediaQuery.of(context).size.width;
    final yatay = en * 0.05;
    final barGenislik = en - yatay * 2 - 32;

    return Scaffold(
      backgroundColor: Renkler.zemin,
      appBar: AppBar(
        backgroundColor: Renkler.zemin,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: yatay),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Renkler.yuzey,
                shape: BoxShape.circle,
                boxShadow: Renkler.yumusakGolge,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Renkler.metin,
              ),
            ),
          ),
        ),
        title: const Text(
          'İstatistikler',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Renkler.metin,
          ),
        ),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(yatay, 16, yatay, 40),
              children: <Widget>[
                // ── Toplam not kartı ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _kutu(),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Renkler.birincil.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.notes_rounded,
                          color: Renkler.vurgu,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '$_toplam',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Renkler.metin,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Toplam Not',
                            style: TextStyle(
                              fontSize: 14,
                              color: Renkler.metin2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 2, bottom: 14),
                  child: Text(
                    'KATEGORİYE GÖRE',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: Renkler.metin2,
                    ),
                  ),
                ),
                // DB'den yüklenen liste — for döngüsü.
                for (final k in widget.kategoriler)
                  _kategoriSatir(k, _sayilar[k.kategoriId] ?? 0, barGenislik),
              ],
            ),
    );
  }

  Widget _kategoriSatir(Kategori k, int sayi, double barGenislik) {
    final oran = (_toplam == 0) ? 0.0 : sayi / _toplam;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _kutu(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              KategoriEtiket(kategori: k),
              Text(
                '$sayi not',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Renkler.metin,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: <Widget>[
              Container(
                height: 8,
                width: barGenislik,
                decoration: BoxDecoration(
                  color: k.renk.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width: barGenislik * oran,
                decoration: BoxDecoration(
                  color: k.renk,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _kutu() => BoxDecoration(
        color: Renkler.yuzey,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Renkler.yumusakGolge,
        border: Border.all(color: Renkler.metin.withValues(alpha: 0.06)),
      );
}
