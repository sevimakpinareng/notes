import 'package:flutter/material.dart';
import '../database/ayar_dao.dart';
import '../database/kategori_dao.dart';
import '../database/not_dao.dart';
import '../models/ayar.dart';
import '../models/kategori.dart';
import '../models/kullanici.dart';
import '../models/not.dart';
import '../theme/renkler.dart';
import '../widgets/bos_durum.dart';
import '../widgets/filtre_cipi.dart';
import '../widgets/not_karti.dart';
import 'ayarlar_ekrani.dart';
import 'istatistik_ekrani.dart';
import 'not_detay_ekrani.dart';
import 'not_duzenle_ekrani.dart';

enum SiralamaModu { enYeni, enEski, baslikAZ, oncelik }

/// Ana liste ekranı — StatefulWidget + setState ile durum yönetimi.
class NotlarEkrani extends StatefulWidget {
  final Kullanici kullanici;
  const NotlarEkrani({super.key, required this.kullanici});

  @override
  State<NotlarEkrani> createState() => _NotlarEkraniState();
}

class _NotlarEkraniState extends State<NotlarEkrani> {
  final NotDao _dao = NotDao();
  final AyarDao _ayarDao = AyarDao();
  final KategoriDao _kategoriDao = KategoriDao();
  final TextEditingController _aramaCtrl = TextEditingController();

  List<Not> _notlar = [];
  List<Kategori> _kategoriler = []; // tek kaynak — DB
  bool _aramaAcik = false;
  bool _yukleniyor = true;
  bool _siralamaAcik = false; // Stack overlay sıralama menüsü
  int? _seciliKategoriId;
  bool _yalnizFavoriler = false;
  SiralamaModu _siralamaModu = SiralamaModu.enYeni;

  int get _kullaniciId => widget.kullanici.kullaniciId!;

  @override
  void initState() {
    super.initState();
    _ilkYukle();
  }

  // Ayar + kategoriler yüklenir, ardından notlar çekilir.
  Future<void> _ilkYukle() async {
    try {
      final ayar = await _ayarDao.getir(_kullaniciId);
      if (!mounted) return;
      final siralama =
          ayar.varsayilanSiralama.clamp(0, SiralamaModu.values.length - 1);
      setState(() => _siralamaModu = SiralamaModu.values[siralama]);
    } catch (_) {}

    try {
      final liste = await _kategoriDao.hepsiniGetir();
      if (!mounted) return;
      setState(() => _kategoriler = liste);
    } catch (_) {}

    if (!mounted) return;
    _yukle();
  }

  @override
  void dispose() {
    _aramaCtrl.dispose();
    super.dispose();
  }

  Future<void> _yukle() async {
    Ayar ayar;
    try {
      ayar = await _ayarDao.getir(_kullaniciId);
    } catch (_) {
      ayar = Ayar(kullaniciId: _kullaniciId);
    }

    final favOne = ayar.favoriUstte ? 'favori DESC, ' : '';
    String sirala;
    switch (_siralamaModu) {
      case SiralamaModu.enYeni:
        sirala = '${favOne}olusturma_tarihi DESC';
      case SiralamaModu.enEski:
        sirala = '${favOne}olusturma_tarihi ASC';
      case SiralamaModu.baslikAZ:
        sirala = '${favOne}baslik COLLATE NOCASE ASC';
      case SiralamaModu.oncelik:
        sirala = '${favOne}oncelik DESC, olusturma_tarihi DESC';
    }

    try {
      final anahtar = _aramaCtrl.text.trim();
      List<Not> liste;

      if (anahtar.isNotEmpty) {
        liste = await _dao.ara(_kullaniciId, anahtar, orderBy: sirala);
      } else if (_yalnizFavoriler) {
        liste = await _dao.favorileriGetir(_kullaniciId, orderBy: sirala);
      } else if (_seciliKategoriId != null) {
        liste = await _dao.kategoriyeGoreGetir(
          _kullaniciId,
          _seciliKategoriId!,
          orderBy: sirala,
        );
      } else {
        liste = await _dao.hepsiniGetir(_kullaniciId, orderBy: sirala);
      }

      if (!mounted) return;
      setState(() {
        _notlar = liste;
        _yukleniyor = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _yukleniyor = false);
      _hataGoster('Notlar yüklenemedi.');
    }
  }

  Future<void> _kartaTiklandi(Not not) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            NotDetayEkrani(not: not, kategoriler: _kategoriler),
      ),
    );
    if (!mounted) return;
    _yukle();
  }

  Future<void> _yeniNot() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotDuzenleEkrani(
          kullaniciId: _kullaniciId,
          kategoriler: _kategoriler,
        ),
      ),
    );
    if (!mounted) return;
    _yukle();
  }

  Future<void> _favoriDegistir(Not not) async {
    try {
      await _dao.favoriDegistir(not.kopyala(favori: !not.favori));
      if (!mounted) return;
      _yukle();
    } catch (e) {
      if (!mounted) return;
      _hataGoster('Favori güncellenemedi.');
    }
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

  @override
  Widget build(BuildContext context) {
    final en = MediaQuery.of(context).size.width;
    final yatay = en * 0.05;

    return Scaffold(
      backgroundColor: Renkler.zemin,
      appBar: AppBar(
        backgroundColor: Renkler.zemin,
        elevation: 0,
        toolbarHeight: 76,
        titleSpacing: yatay,
        title: _aramaAcik ? _aramaAlani() : _baslikAlani(),
        actions: <Widget>[
          if (!_aramaAcik) ...<Widget>[
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => IstatistikEkrani(
                    kullaniciId: _kullaniciId,
                    kategoriler: _kategoriler,
                  ),
                ),
              ),
              icon:
                  const Icon(Icons.bar_chart_rounded, color: Renkler.vurgu),
            ),
            // Sıralama — Stack overlay (projedeki overlay yaklaşımı).
            IconButton(
              onPressed: () => setState(() => _siralamaAcik = true),
              icon: const Icon(Icons.sort_rounded, color: Renkler.vurgu),
              tooltip: 'Sırala',
            ),
            IconButton(
              onPressed: () => setState(() => _aramaAcik = true),
              icon: _yuvarlakIkon(Icons.search, Renkler.vurgu),
              padding: EdgeInsets.only(right: yatay),
            ),
          ],
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _filtreCubugu(yatay),
              Expanded(
                child: _yukleniyor
                    ? const SizedBox.shrink()
                    : _notlar.isEmpty
                        ? _bosEkran()
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(yatay, 8, yatay, 110),
                            itemCount: _notlar.length,
                            itemBuilder: (_, i) => NotKarti(
                              not: _notlar[i],
                              kategoriler: _kategoriler,
                              onTiklandi: () => _kartaTiklandi(_notlar[i]),
                              onFavoriDegisti: () =>
                                  _favoriDegistir(_notlar[i]),
                            ),
                          ),
              ),
            ],
          ),
          // Sıralama overlay — Stack + Positioned.fill.
          if (_siralamaAcik) _siralamaOverlay(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton.small(
            heroTag: 'ayarlar',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      AyarlarEkrani(kullanici: widget.kullanici),
                ),
              );
              if (!mounted) return;
              // Kategoriler değişmiş olabilir — tam yeniden yükle.
              _ilkYukle();
            },
            backgroundColor: Renkler.yuzey,
            elevation: 3,
            child: const Icon(
              Icons.settings_outlined,
              color: Renkler.vurgu,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'yeniNot',
            onPressed: _yeniNot,
            backgroundColor: Renkler.birincil,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _bosEkran() {
    if (_aramaCtrl.text.isNotEmpty) {
      return const BosDurum(
        ikon: Icons.search_off_rounded,
        baslik: 'Sonuç bulunamadı',
        altyazi: 'Farklı bir anahtar kelime dene.',
        renkArka: Renkler.vurgu,
      );
    }
    if (_yalnizFavoriler) {
      return const BosDurum(
        ikon: Icons.star_outline_rounded,
        baslik: 'Henüz favori yok',
        altyazi: 'Bir notu yıldızla işaretle\nburada görünsün.',
        renkArka: Renkler.vurgu,
      );
    }
    if (_seciliKategoriId != null) {
      return const BosDurum(
        ikon: Icons.folder_open_rounded,
        baslik: 'Bu kategoride not yok',
        altyazi: 'Farklı bir kategori seç\nveya yeni not ekle.',
        renkArka: Renkler.vurgu,
      );
    }
    return const BosDurum();
  }

  Widget _filtreCubugu(double yatay) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(yatay, 0, yatay, 12),
      child: Row(
        children: <Widget>[
          FiltreCipi(
            etiket: 'Tümü',
            renk: Renkler.vurgu,
            secili: _seciliKategoriId == null && !_yalnizFavoriler,
            onTap: () {
              setState(() {
                _seciliKategoriId = null;
                _yalnizFavoriler = false;
              });
              _yukle();
            },
          ),
          const SizedBox(width: 8),
          FiltreCipi(
            etiket: 'Favoriler',
            renk: Colors.amber,
            secili: _yalnizFavoriler,
            onTap: () {
              setState(() {
                _yalnizFavoriler = !_yalnizFavoriler;
                _seciliKategoriId = null;
              });
              _yukle();
            },
          ),
          const SizedBox(width: 8),
          // DB'den yüklenen kategoriler — for döngüsü.
          for (final k in _kategoriler) ...<Widget>[
            FiltreCipi(
              etiket: k.kategoriAd,
              renk: k.renk,
              secili:
                  _seciliKategoriId == k.kategoriId && !_yalnizFavoriler,
              onTap: () {
                setState(() {
                  _seciliKategoriId = k.kategoriId;
                  _yalnizFavoriler = false;
                });
                _yukle();
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _baslikAlani() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Renkler.metin,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '· ${widget.kullanici.kullaniciAdi}',
              style: const TextStyle(
                fontSize: 16,
                color: Renkler.metin2,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${_notlar.length} not',
          style:
              const TextStyle(fontSize: 14, color: Renkler.metin2),
        ),
      ],
    );
  }

  Widget _aramaAlani() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Renkler.yuzey,
              borderRadius: BorderRadius.circular(15),
              boxShadow: Renkler.yumusakGolge,
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.search, size: 20, color: Renkler.metin2),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _aramaCtrl,
                    autofocus: true,
                    onChanged: (_) => _yukle(),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Notlarda ara...',
                      hintStyle: TextStyle(color: Renkler.metin2),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Renkler.metin,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            setState(() => _aramaAcik = false);
            _aramaCtrl.clear();
            _yukle();
          },
          child: const Text(
            'Vazgeç',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Renkler.vurgu,
            ),
          ),
        ),
      ],
    );
  }

  // Sıralama overlay — Stack + Positioned.fill (silme onayındaki yaklaşımla tutarlı).
  Widget _siralamaOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _siralamaAcik = false),
        child: Container(
          color: const Color(0x55000000),
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: const BoxDecoration(
                color: Renkler.yuzey,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Tutamaç çizgisi
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Renkler.metin.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Sıralama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Renkler.metin,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _siralamaOgesi('En Yeni', Icons.arrow_downward_rounded,
                      SiralamaModu.enYeni),
                  _siralamaOgesi('En Eski', Icons.arrow_upward_rounded,
                      SiralamaModu.enEski),
                  _siralamaOgesi('Başlık A–Z',
                      Icons.sort_by_alpha_rounded, SiralamaModu.baslikAZ),
                  _siralamaOgesi('Önceliğe Göre',
                      Icons.priority_high_rounded, SiralamaModu.oncelik),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _siralamaOgesi(String yazi, IconData ikon, SiralamaModu mod) {
    final secili = _siralamaModu == mod;
    return GestureDetector(
      onTap: () {
        setState(() {
          _siralamaModu = mod;
          _siralamaAcik = false;
        });
        _yukle();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: secili
                    ? Renkler.vurgu.withValues(alpha: 0.12)
                    : Renkler.seftali,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(ikon,
                  size: 18,
                  color: secili ? Renkler.vurgu : Renkler.metin2),
            ),
            const SizedBox(width: 14),
            Text(
              yazi,
              style: TextStyle(
                fontSize: 15.5,
                color: secili ? Renkler.vurgu : Renkler.metin,
                fontWeight:
                    secili ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (secili)
              const Icon(Icons.check_rounded,
                  size: 18, color: Renkler.vurgu),
          ],
        ),
      ),
    );
  }

  Widget _yuvarlakIkon(IconData ikon, Color renk) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Renkler.yuzey,
        shape: BoxShape.circle,
        boxShadow: Renkler.yumusakGolge,
        border: Border.all(color: Renkler.metin.withValues(alpha: 0.06)),
      ),
      child: Icon(ikon, size: 22, color: renk),
    );
  }
}
