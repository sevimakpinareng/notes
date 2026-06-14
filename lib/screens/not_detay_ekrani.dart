import 'package:flutter/material.dart';
import '../database/not_dao.dart';
import '../models/kategori.dart';
import '../models/not.dart';
import '../theme/renkler.dart';
import '../widgets/kategori_etiket.dart';
import 'not_duzenle_ekrani.dart';

/// Salt-okunur not detay ekranı.
/// [not] ve [kategoriler] constructor parametresiyle taşınır.
class NotDetayEkrani extends StatefulWidget {
  final Not not;
  final List<Kategori> kategoriler;
  const NotDetayEkrani({
    super.key,
    required this.not,
    required this.kategoriler,
  });

  @override
  State<NotDetayEkrani> createState() => _NotDetayEkraniState();
}

class _NotDetayEkraniState extends State<NotDetayEkrani> {
  late Not _not;
  final NotDao _dao = NotDao();

  @override
  void initState() {
    super.initState();
    _not = widget.not;
  }

  String _tamTarih(String iso) {
    const aylar = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    final d = DateTime.tryParse(iso) ?? DateTime.now();
    final saat =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '${d.day} ${aylar[d.month - 1]} ${d.year}, $saat';
  }

  Future<void> _favoriToggle() async {
    try {
      final guncellenmis = _not.kopyala(favori: !_not.favori);
      await _dao.favoriDegistir(guncellenmis);
      if (!mounted) return;
      setState(() => _not = guncellenmis);
    } catch (e) {
      if (!mounted) return;
      _hataGoster('Favori güncellenemedi.');
    }
  }

  Future<void> _duzenleAc() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotDuzenleEkrani(
          mevcut: _not,
          kullaniciId: _not.kullaniciId,
          kategoriler: widget.kategoriler,
        ),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        backgroundColor: Renkler.vurgu,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  (Color, String) _oncelikBilgisi(int oncelik) {
    switch (oncelik) {
      case 0:
        return (Renkler.oncelikDusuk, 'Düşük Öncelik');
      case 2:
        return (Renkler.oncelikYuksek, 'Yüksek Öncelik');
      default:
        return (Renkler.oncelikOrta, 'Orta Öncelik');
    }
  }

  @override
  Widget build(BuildContext context) {
    final en = MediaQuery.of(context).size.width;
    final yatay = en * 0.05;
    final (oncelikRenk, oncelikMetin) = _oncelikBilgisi(_not.oncelik);

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
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              onPressed: _favoriToggle,
              icon: Icon(
                _not.favori ? Icons.star_rounded : Icons.star_outline_rounded,
                color: _not.favori ? Colors.amber : Renkler.metin2,
                size: 26,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: yatay),
            child: GestureDetector(
              onTap: _duzenleAc,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Renkler.vurgu,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Düzenle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(yatay, 16, yatay, 40),
        children: <Widget>[
          Row(
            children: <Widget>[
              KategoriEtiket(kategori: _not.kategoriIle(widget.kategoriler)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: oncelikRenk.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  oncelikMetin,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: oncelikRenk,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _tamTarih(_not.olusturmaTarihi),
                style:
                    const TextStyle(fontSize: 12, color: Renkler.metin2),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _not.baslik,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Renkler.metin,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Renkler.metin.withValues(alpha: 0.08)),
          const SizedBox(height: 20),
          Text(
            _not.icerik.isEmpty ? 'İçerik girilmemiş.' : _not.icerik,
            style: const TextStyle(
              fontSize: 16.5,
              height: 1.75,
              color: Renkler.metin,
            ),
          ),
        ],
      ),
    );
  }
}
